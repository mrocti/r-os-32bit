FROM --platform=linux/386 i386/alpine:3.18

# Enable main and community repositories
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories

# Install base system, kernel, Xorg, input drivers, eudev, and XFCE desktop packages
RUN apk update && apk add --no-cache \
    openrc \
    alpine-base \
    linux-lts \
    linux-firmware-none \
    syslinux \
    e2fsprogs \
    bash \
    nano \
    htop \
    neofetch \
    sudo \
    xorg-server \
    xf86-video-vesa \
    xfce4-session \
    xfce4-panel \
    xfdesktop \
    xfwm4 \
    xfce4-terminal \
    dbus \
    setxkbmap \
    kbd-bkeymaps \
    alpine-conf \
    eudev \
    xf86-input-libinput \
    xf86-input-evdev

# Enable essential background services for device and bus discovery
RUN rc-update add devfs sysinit \
    && rc-update add dmesg sysinit \
    && rc-update add udev sysinit \
    && rc-update add udev-trigger sysinit \
    && rc-update add bootmisc boot \
    && rc-update add hostname boot \
    && rc-update add sysctl boot \
    && rc-update add syslog boot \
    && rc-update add dbus default

# Set the OS hostname
RUN echo "raduos" > /etc/hostname

# Configure auto-login for root on tty1
RUN sed -i 's/tty1::respawn:\/sbin\/getty 38400 tty1/tty1::respawn:\/sbin\/getty -n -l \/usr\/local\/bin\/autologin 38400 tty1/' /etc/inittab

# Create autologin script and launch XFCE automatically
RUN printf '#!/bin/sh\nexec /bin/login -f root\n' > /usr/local/bin/autologin \
    && chmod +x /usr/local/bin/autologin \
    && echo "exec startxfce4" > /root/.xinitrc \
    && printf '\nif [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then\n  startx\nfi\n' >> /root/.profile

# Set empty password for root
RUN passwd -d root

# Ensure /tmp has correct permissions for Xorg lock files
RUN chmod 1777 /tmp

# Configure keyboard layout for virtual console and X11
RUN setup-keymap de de \
    && mkdir -p /etc/X11/xorg.conf.d \
    && echo 'Section "InputClass"' > /etc/X11/xorg.conf.d/00-keyboard.conf \
    && echo '  Identifier "system-keyboard"' >> /etc/X11/xorg.conf.d/00-keyboard.conf \
    && echo '  MatchIsKeyboard "on"' >> /etc/X11/xorg.conf.d/00-keyboard.conf \
    && echo '  Option "XkbLayout" "de"' >> /etc/X11/xorg.conf.d/00-keyboard.conf \
    && echo 'EndSection' >> /etc/X11/xorg.conf.d/00-keyboard.conf

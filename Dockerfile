FROM i386/alpine:3.18

# Enable main and community repositories
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories

# Install base system, kernel, Xorg, input drivers, eudev, and XFCE desktop packages
RUN apk update && apk add --no-cache \
    openrc \
    alpine-base \
    eudev \
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
    xf86-input-libinput \
    xf86-input-evdev \
    xfce4-session \
    xfce4-panel \
    xfdesktop \
    xfwm4 \
    xfce4-terminal \
    dbus \
    ttf-dejavu

# Enable essential background services for device and bus discovery
RUN rc-update add devfs sysinit \
    && rc-update add dmesg sysinit \
    && rc-update add mdev sysinit \
    && rc-update add udev sysinit \
    && rc-update add udev-trigger sysinit \
    && rc-update add dbus default

# Configure auto-login for root on tty1
RUN sed -i 's/tty1::respawn:\/sbin\/getty 38400 tty1/tty1::respawn:\/sbin\/getty -n -l \/usr\/local\/bin\/autologin 38400 tty1/' /etc/inittab

# Create autologin script and launch XFCE automatically
RUN echo -e '#!/bin/sh\nexec /bin/login -f root' > /usr/local/bin/autologin \
    && chmod +x /usr/local/bin/autologin \
    && echo "exec startxfce4" > /root/.xinitrc \
    && echo -e '\nif [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then\n  startx\nfi' >> /root/.profile

# Set empty password for root
RUN passwd -d root

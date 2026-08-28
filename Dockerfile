FROM i386/alpine:3.18

# Install base system, kernel, X11, XFCE4 desktop, and utilities
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
    xf86-video-modesetting \
    xf86-input-mouse \
    xf86-input-keyboard \
    xfce4 \
    xfce4-terminal \
    dbus \
    mesa-dri-swrast

# Enable services to launch XFCE on boot
RUN rc-update add devfs sysinit \
    && rc-update add dmesg sysinit \
    && rc-update add mdev sysinit \
    && rc-update add hwdeps sysinit \
    && rc-update add dbus default

# Configure auto-login and start XFCE automatically
RUN sed -i 's/tty1::respawn:\/sbin\/getty 38400 tty1/tty1::respawn:\/sbin\/getty -n -l \/usr\/local\/bin\/autologin 38400 tty1/' /etc/inittab

# Create autologin and desktop start script
RUN echo -e '#!/bin/sh\nexec /bin/login -f root' > /usr/local/bin/autologin \
    && chmod +x /usr/local/bin/autologin \
    && echo "exec startxfce4" > /root/.xinitrc \
    && echo -e '\nif [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then\n  startx\nfi' >> /root/.profile

# Set root password to empty
RUN passwd -d root

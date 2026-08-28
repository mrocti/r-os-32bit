FROM i386/alpine:3.18

# Enable main and community repositories
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories

# Install base system, kernel, Xorg, input drivers, and XFCE desktop packages
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
    xf86-input-mouse \
    xf86-input-kbd \
    xfce4-session \
    xfce4-panel \
    xfdesktop \
    xfwm4 \
    xfce4-terminal \
    dbus \
    ttf-dejavu

# Create static Xorg configuration for v86 PS/2 input and VESA graphics
RUN mkdir -p /etc/X11 && \
    echo 'Section "ServerLayout"' > /etc/X11/xorg.conf && \
    echo '    Identifier "Layout0"' >> /etc/X11/xorg.conf && \
    echo '    Screen 0 "Screen0"' >> /etc/X11/xorg.conf && \
    echo '    InputDevice "Keyboard0" "CoreKeyboard"' >> /etc/X11/xorg.conf && \
    echo '    InputDevice "Mouse0" "CorePointer"' >> /etc/X11/xorg.conf && \
    echo 'EndSection' >> /etc/X11/xorg.conf && \
    echo 'Section "InputDevice"' >> /etc/X11/xorg.conf && \
    echo '    Identifier "Keyboard0"' >> /etc/X11/xorg.conf && \
    echo '    Driver "kbd"' >> /etc/X11/xorg.conf && \
    echo '    Option "Device" "/dev/input/event0"' >> /etc/X11/xorg.conf && \
    echo 'EndSection' >> /etc/X11/xorg.conf && \
    echo 'Section "InputDevice"' >> /etc/X11/xorg.conf && \
    echo '    Identifier "Mouse0"' >> /etc/X11/xorg.conf && \
    echo '    Driver "mouse"' >> /etc/X11/xorg.conf && \
    echo '    Option "Protocol" "auto"' >> /etc/X11/xorg.conf && \
    echo '    Option "Device" "/dev/input/mice"' >> /etc/X11/xorg.conf && \
    echo '    Option "ZAxisMapping" "4 5"' >> /etc/X11/xorg.conf && \
    echo 'EndSection' >> /etc/X11/xorg.conf && \
    echo 'Section "Device"' >> /etc/X11/xorg.conf && \
    echo '    Identifier "Card0"' >> /etc/X11/xorg.conf && \
    echo '    Driver "vesa"' >> /etc/X11/xorg.conf && \
    echo 'EndSection' >> /etc/X11/xorg.conf && \
    echo 'Section "Screen"' >> /etc/X11/xorg.conf && \
    echo '    Identifier "Screen0"' >> /etc/X11/xorg.conf && \
    echo '    Device "Card0"' >> /etc/X11/xorg.conf && \
    echo '    DefaultDepth 24' >> /etc/X11/xorg.conf && \
    echo '    SubSection "Display"' >> /etc/X11/xorg.conf && \
    echo '        Depth 24' >> /etc/X11/xorg.conf && \
    echo '        Modes "1024x768" "800x600"' >> /etc/X11/xorg.conf && \
    echo '    EndSubSection' >> /etc/X11/xorg.conf && \
    echo 'EndSection' >> /etc/X11/xorg.conf

# Enable essential background services
RUN rc-update add devfs sysinit \
    && rc-update add dmesg sysinit \
    && rc-update add mdev sysinit \
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

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
RUN mkdir -p /etc/X11 && cat << "EOF" > /etc/X11/xorg.conf
Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0"
    InputDevice    "Keyboard0" "CoreKeyboard"
    InputDevice    "Mouse0" "CorePointer"
EndSection

Section "InputDevice"
    Identifier     "Keyboard0"
    Driver         "kbd"
    Option         "Device" "/dev/input/event0"
EndSection

Section "InputDevice"
    Identifier     "Mouse0"
    Driver         "mouse"
    Option         "Protocol" "auto"
    Option         "Device" "/dev/input/mice"
    Option         "ZAxisMapping" "4 5"
EndSection

Section "Device"
    Identifier     "Card0"
    Driver         "vesa"
EndSection

Section "Screen"
    Identifier     "Screen0"
    Device         "Card0"
    DefaultDepth   24
    SubSection "Display"
        Depth      24
        Modes      "1024x768" "800x600"
    EndSubSection
EndSection
EOF

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

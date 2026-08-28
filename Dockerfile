FROM --platform=linux/386 i386/alpine:3.18.6

# Set hostname and install tools
RUN apk add --no-cache \
    openrc \
    agetty \
    alpine-base \
    htop \
    fastfetch \
    curl \
    nano

# Configure auto-login for root
RUN sed -i 's/getty 38400 tty1/agetty --autologin root tty1 linux/' /etc/inittab
RUN echo 'ttyS0::once:/sbin/agetty --autologin root -s ttyS0 115200 vt100' >> /etc/inittab
RUN echo "root:root" | chpasswd

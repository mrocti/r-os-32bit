# R-OS (32-bit x86 Linux Distribution)

A lightweight 32-bit Linux operating system built with Alpine Linux and XFCE, designed specifically to run inside browser-based PC emulators like **v86** (`copy.sh/v86`).

---

## ⚠️ STRICT AGENT / AI INSTRUCTIONS & GUARDRAILS (FOR JULES / AUTOMATION)

Any automated agent (including Jules) modifying this repository **MUST** follow these mandatory rules:

### 1. 32-bit Architecture Only (Non-Negotiable)
- **Always target `i386` / `x86_32`:** Never upgrade the base image to `x86_64` or `amd64`.
- The base container **must remain** `i386/alpine:3.18` (or another explicit 32-bit base).
- Docker builds must always specify `--platform linux/386`.

### 2. v86 Hardware & Boot Compatibility
- **Disk Format:** Must output a raw MBR partition table with an `ext4` primary partition formatted without 64-bit metadata features (`-O ^64bit,^metadata_csum`).
- **Bootloader:** Must use **Syslinux / Extlinux** with `mbr.bin`. Do not replace with GRUB2/UEFI as v86 uses standard legacy BIOS boot.
- **Kernel Parameters:** The bootloader configuration (`extlinux.conf`) must include:
  `APPEND root=/dev/sda1 rootfstype=ext4 modules=ext4,sd-mod,loop rw console=tty0`
- **Read-Write Root:** The filesystem **must** mount as `rw` with valid `/tmp` sticky-bit permissions (`chmod 1777 /tmp`) for Xorg lock files.

### 3. Graphical Interface & Input Rules
- **Desktop Environment:** XFCE4.
- **Display Driver:** `xf86-video-vesa` (VESA compatible with v86's Bochs/Cirrus VGA).
- **Input Drivers:** Use `eudev`, `xf86-input-evdev`, and `xf86-input-libinput`.
- **Auto-Login:** Must boot directly into `root` on `tty1` and trigger `startx` automatically.
- **Do not install:** `font-dejavu`, `xf86-video-modesetting`, `xf86-input-mouse`, or `xf86-input-kbd` (these package names do not exist in Alpine 3.18). Use `ttf-dejavu` and `xf86-input-evdev` instead.

---

## 🚀 How to Run in v86

1. Go to [v86 in browser](https://copy.sh/v86/).
2. Under **Hard disk image**, upload `r-os-32bit.img`.
3. Set **Memory size** to `512 MB`.
4. Set **Video memory (VRAM)** to `16 MB`.
5. Click **Start Emulation**.

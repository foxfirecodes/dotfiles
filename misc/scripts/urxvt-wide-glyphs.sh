#!/bin/bash

if [[ ! -d /usr/include/X11/Xft ]]; then
    echo "Error: Xft headers could not be found, compilation will now stop." 1>&2
    exit 1
fi

set -ex

PKGBUILD_DIR=urxvt-pkgbuild

[[ -d "$PKGBUILD_DIR" ]] || git clone https://github.com/foxfirecodes/PKGBUILD-rxvt-unicode-wide.git "$PKGBUILD_DIR"
cd "$PKGBUILD_DIR"

cvs -z3 -d :pserver:anonymous@cvs.schmorp.de/schmorpforge co rxvt-unicode
cd rxvt-unicode

patch --silent --forward -p0 -i ../font-width-fix.patch
patch --silent --forward -p0 -i ../line-spacing-fix.patch
patch --silent --forward -p1 -i ../enable-wide-glyphs.patch

(
    cd libptytty
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_SHARED_LIBS=ON -S .. .
    cmake --build .
    sudo cmake --install .
)

./configure \
    --prefix=/usr \
    --enable-256-color \
    --enable-combining \
    --enable-fading \
    --enable-font-styles \
    --enable-iso14755 \
    --enable-keepscrolling \
    --enable-lastlog \
    --enable-mousewheel \
    --enable-next-scroll \
    --enable-perl \
    --enable-pointer-blank \
    --enable-rxvt-scroll \
    --enable-selectionscrolling \
    --enable-slipwheeling \
    --enable-smart-resize \
    --enable-startup-notification \
    --enable-transparency \
    --enable-unicode3 \
    --enable-utmp \
    --enable-wide-glyphs \
    --enable-wtmp \
    --enable-xft \
    --enable-xim \
    --enable-xterm-scroll

make -j 8
sudo make install

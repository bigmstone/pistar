#!/bin/bash
set -e

BUILD_OPTIONS="-DCMAKE_BUILD_TYPE=RelWithDebInfo -Dcompile_options=OFF "
ahp_correlator=On

SWAP_DIR="/swapfile"
SWAP_SIZE="12"
SWAP_SUFFIX="G"
SWAP_BLOCKS=$(($SWAP_SIZE*1024))

BASE_DIR=$(realpath ~)
PROJECTS_DIR="$BASE_DIR/Projects"
BUILD_DIR="$PROJECTS_DIR/build"
NUM_JOBS="-j16"


function section_text() {
    text="# $1 #"
    len=$((${#text}+1))
    border=$(head -c $len < /dev/zero | tr '\0' "#")
    echo ""
    echo ""
    echo "$border"
    echo "$text"
    echo "$border"
    echo ""
}

function build_swap() {
    section_text "Building swap file"
    if [ ! -f $SWAP_DIR ]; then
        sudo fallocate -l "$SWAP_SIZE$SWAP_SUFFIX" $SWAP_DIR
        sudo dd if=/dev/zero of=$SWAP_DIR bs=1M count=$SWAP_BLOCKS
        sudo chmod 600 $SWAP_DIR
        sudo mkswap $SWAP_DIR
        sudo swapon $SWAP_DIR
    else
        echo "Swap exists, skipping..."
    fi
}

function install_deps() {
    section_text "Installing Dependencies"
	sudo apt-get install -y \
        breeze-icon-theme \
        build-essential \
        cdbs \
        cmake \
        dkms \
        extra-cmake-modules \
        fxload \
        gettext \
        git \
        kinit-dev \
        libavcodec-dev \
        libavdevice-dev \
        libboost-dev \
        libboost-regex-dev \
        libcfitsio-dev \
        libcurl4-gnutls-dev \
        libdc1394-dev \
        libeigen3-dev \
        libev-dev \
        libfftw3-dev \
        libftdi-dev \
        libftdi1-dev \
        libgphoto2-dev \
        libgps-dev \
        libgsl-dev \
        libindi-dev \
        libjpeg-dev \
        libkf5crash-dev \
        libkf5doctools-dev \
        libkf5kio-dev \
        libkf5newstuff-dev \
        libkf5notifications-dev \
        libkf5notifyconfig-dev \
        libkf5plotting-dev \
        libkf5xmlgui-dev \
        libkrb5-dev \
        liblimesuite-dev \
        libnova-dev \
        libopencv-dev \
        libqt5datavisualization5-dev \
        libqt5svg5-dev \
        libqt5websockets5-dev \
        libraw-dev \
        librtlsdr-dev \
        libsecret-1-dev \
        libstellarsolver-dev \
        libtheora-dev \
        libtiff-dev \
        libusb-1.0-0-dev \
        libusb-dev \
        libwxgtk3.2-dev \
        libx11-dev \
        pkg-config \
        qt5keychain-dev \
        qtdeclarative5-dev \
        wcslib-dev \
        wx-common \
        wx3.2-i18n \
        xplanet \
        xplanet-images \
        zlib1g-dev
}

function setup_dirs() {
    mkdir -p $PROJECTS_DIR
    mkdir -p $BUILD_DIR
}

function build() {
    src_dir=$1

    if [ -z $2 ]; then
        build_dir=$1
    else
        build_dir=$2
    fi

    if [ -z $3 ]; then
        buildopts="$BUILD_OPTIONS"
    else
        buildopts="$BUILD_OPTIONS $3"
    fi

    section_text "Building $src_dir into $build_dir with buildopts of \"$buildopts\""

    mkdir -p "$BUILD_DIR/$build_dir"
    cd "$BUILD_DIR/$build_dir"
    cmake -DCMAKE_INSTALL_PREFIX=/usr $buildopts "$PROJECTS_DIR/$src_dir"
    make $NUM_JOBS
    sudo make install
}

function build_indi() {
    section_text "Installing indi"
    echo "Cloning indi repo..."
    cd $PROJECTS_DIR
    git clone --depth 1 http://github.com/indilib/indi.git

    echo "Building indi..."
    build "indi" "indi-core"

    echo "Cloning indi-3rdparty repo"
    cd $PROJECTS_DIR
    git clone --depth 1 http://github.com/indilib/indi-3rdparty.git
    echo "Building indi-3rdparty libs..."
    build "indi-3rdparty" "indi-3rdparty-libs" "-DBUILD_LIBS=1"
}

function build_kstars() {
    section_text "Installing kstars"
    echo "Cloning kstars repo..."
    cd $PROJECTS_DIR
    git clone http://invent.kde.org/education/kstars.git
    echo "Building kstars..."
    build "kstars"
}

function build_phd2() {
    section_text "Installing PHD2"
    cd $PROJECTS_DIR
    echo "Cloning phd2 repo..."
    git clone https://github.com/OpenPHDGuiding/phd2
    echo "Building PHD2..."
    build "phd2"
}

function build_stellarsolver () {
    section_text "Installing stellarsolver"
    echo "Cloning stellarsolver repo..."
    cd $PROJECTS_DIR
    git clone https://github.com/rlancaste/stellarsolver.git
    echo "Building stellarsolver..."
    $PROJECTS_DIR/stellarsolver/linux-scripts/installStellarSolverLibraryQt6.sh
}

function main() {
    section_text "Starting Install Script"
    echo "This might take some time. Go have yourself a snack."
    build_swap
    install_deps
    setup_dirs
    build_indi
    build_phd2
    build_kstars
    build_stellarsolver
}

main $@

#!/bin/bash
set -e

function main() {
    if [ -z $1 ]; then
        echo "No package selected: build.sh <package>"
        exit 1
    else
        PACKAGE=$1
    fi

    BASE_DIR="$(realpath ~/Projects)"
    BUILD_DIR="$BASE_DIR/build"
    PACKAGE_BUILD_PATH="$BUILD_DIR/$1"
    INDI_3P_PATH="$BASE_DIR/indi-3rdparty"
    PACKAGE_PATH="$INDI_3P_PATH/$1"

    if [ ! -d $PACKAGE_PATH ]; then
        echo "$PACKAGE_PATH does not exist."
        exit 1
    fi

    mkdir -p $PACKAGE_BUILD_PATH
    cd $PACKAGE_BUILD_PATH
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Debug $PACKAGE_PATH
    make -j4
    sudo make install
}

main $@

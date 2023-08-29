#!/bin/bash

set -ex
set -o pipefail

THIS_DIR=$(dirname "$(readlink -f "$0")")
GUEST_REPO="guest_repo"
HOST_REPO="host_repo"
STATUS_DIR="${THIS_DIR}/build-status"
LOG_DIR="${THIS_DIR}/build-logs"

export DEBIAN_FRONTEND=noninteractive

GUEST_DEFAULT_PKG="
"

HOST_DEFAULT_PKG=" td-migration_*_amd64.deb vtpm-td_*_amd64.deb \
"

build_check() {
    sudo apt update

    if ! command -v "dpkg-scanpackages"
    then
        sudo apt install dpkg-dev -y
    fi

    [[ -d "$LOG_DIR" ]] || mkdir "$LOG_DIR"
    [[ -d "$STATUS_DIR" ]] || mkdir "$STATUS_DIR"
    if [[ "$1" == clean-build ]]; then
        rm -rf "${STATUS_DIR:?}"/*
    fi

    if [[ ! -z ${rust_mirror} ]]; then
        mkdir -p ~/.cargo
        cat > ~/.cargo/config << EOL
[source.crates-io]
replace-with = 'mirror'

[source.mirror]
registry = "${rust_mirror}"

[registries.mirror]
index = "${rust_mirror}"
EOL
    fi

    if [[ ! -z ${rustup_dist_server} ]]; then
        export RUSTUP_DIST_SERVER="${rustup_dist_server}"
    fi
    if [[ ! -z ${rustup_update_server} ]]; then
        export RUSTUP_UPDATE_SERVER="${rustup_update_server}"
    fi
}

build_migtd () {
    pushd intel-mvp-tdx-migration
    [[ -f $STATUS_DIR/migtd.done ]] || ./build.sh 2>&1 | tee "$LOG_DIR"/migtd.log
    touch "$STATUS_DIR"/migtd.done
    cp td-migration_*_amd64.deb ../$HOST_REPO/more/
    popd
}

build_vtpm-td () {
    pushd intel-mvp-vtpm-td
    [[ -f $STATUS_DIR/vtpm-td.done ]] || ./build.sh 2>&1 | tee "$LOG_DIR"/vtpm-td.log
    touch "$STATUS_DIR"/vtpm-td.done
    cp vtpm-td_*_amd64.deb ../$HOST_REPO/more/
    popd
}

build_repo () {
    # move necessary packages to repo root directory.
    # so the local file installation keeps same as before.
    pushd $GUEST_REPO/more
    mv $GUEST_DEFAULT_PKG ../
    popd

    pushd $HOST_REPO/more
    mv $HOST_DEFAULT_PKG ../
    popd

    pushd $HOST_REPO && dpkg-scanpackages . > Packages && popd
    pushd $GUEST_REPO && dpkg-scanpackages . > Packages && popd
}

build_check "$1"

pushd "$THIS_DIR"
mkdir -p $GUEST_REPO/more
mkdir -p $HOST_REPO/more

#build_migtd
#build_vtpm-td
#build_repo

popd

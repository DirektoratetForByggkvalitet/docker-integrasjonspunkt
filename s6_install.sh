#!/bin/bash

: "${TARGETARCH:=}"
: "${S6_OVERLAY_VERSION:=3.1.4.2}"

echo "Installerer S6-overlay"
declare -a files=("s6-overlay-noarch.tar.xz" "s6-overlay-symlinks-noarch.tar.xz" "s6-overlay-${TARGETARCH}.tar.xz" "s6-overlay-symlinks-arch.tar.xz")
for file in "${files[@]}"
do
    echo "Behandler '${file}'"
    curl -Lso /tmp/${file} https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/${file}
    tar -C / -Jxpf /tmp/${file}
done

echo "S6-overlay installert"

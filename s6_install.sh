#!/bin/bash

: "${TARGETARCH:=}"
: "${S6_OVERLAY_VERSION:=v3.1.5.0}"

echo "Installerer S6-overlay, ${S6_OVERLAY_VERSION}, for ${TARGETARCH}"

# Endrer på filnavnet etter arkitektur.
if [ "$TARGETARCH" = "arm64" ]; then
  code="aarch64"
elif [ "$TARGETARCH" = "amd64" ]; then
  code="x86_64"
else
  code=${TARGETARCH}
fi

declare -a files=("s6-overlay-noarch.tar.xz" "s6-overlay-symlinks-noarch.tar.xz" "s6-overlay-${code}.tar.xz" "s6-overlay-symlinks-arch.tar.xz")
for file in "${files[@]}"
do
    echo "Behandler '${file}'"
    curl -Lo /tmp/${file} https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/${file}
    tar -C / -Jxpf /tmp/${file}
done

echo "S6-overlay installert"

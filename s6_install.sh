#!/bin/bash

: "${S6_OVERLAY_VERSION:=3.1.4.2}"
: "${TARGETARCH:=}"

echo "Installerer S6-overlay"
curl -Lso /tmp/s6-overlay-noarch.tar.xz  https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz
curl -Lso /tmp/s6-overlay-symlinks-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz
curl -Lso /tmp/s6-overlay-${TARGETARCH}.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${TARGETARCH}.tar.xz
curl -Lso /tmp/s6-overlay-${TARGETARCH}.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-${TARGETARCH}.tar.xz

tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz
tar -C / -Jxpf /tmp/s6-overlay-${TARGETARCH}.tar.xz
tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz

echo "S6-overlay installert"

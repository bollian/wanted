# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Build image
FROM ghcr.io/ublue-os/kinoite-main:latest as build

RUN dnf group install -y kde-software-development && \
    dnf install -y extra-cmake-modules
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    mkdir /build && \
    cd /build && \
    cmake /ctx/material-decoration -DQT_MAJOR_VERSION=6 -DQT_VERSION_MAJOR=6 && \
    make -j

# Base Image
FROM ghcr.io/ublue-os/kinoite-main:latest

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=build,source=/build,target=/build \
    /ctx/build.sh && \
    make -C /build install && \
    ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

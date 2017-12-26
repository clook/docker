#!/bin/bash -e

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

while getopts "a:v:d:t:" opt; do
    case "$opt" in
    a)  ARCH=$OPTARG
        ;;
    v)  VERSION=$OPTARG
        ;;
    d)  DOCKER_REPO=$OPTARG
        ;;
    t)  TAG_ARCH=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

TMP=tmp
ROOTFS=rootfs

# create Dockerfile from template
sed -i.bak "s/ENV release=.*/ENV release=\"$VERSION\"/;s/ENV arch=.*/ENV arch=\"$ARCH\"/;s@FROM multiarch/alpine:amd64@FROM multiarch/alpine:${TAG_ARCH}@" Dockerfile


# build
docker build -t "${DOCKER_REPO}:${TAG_ARCH}-${VERSION}" .


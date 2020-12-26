#!/bin/bash -e

# See https://stafwag.github.io/blog/blog/2019/04/22/building-your-own-docker-images_part1/

if [ $(id -u) -ne 0 ] ; then
    echo "This script must be run as root!"
    exit 1
fi

SRCDIR="$(cd "$(dirname "${0}")" && pwd)"
TMPDIR="${PWD}/tmp"
mkdir -p "${TMPDIR}"
cd "${TMPDIR}"

git clone --depth 1 -b v20.10.0-beta1 https://github.com/moby/moby.git
cd moby
patch -p1 -i "${SRCDIR}/moby-patches/0001-Use-old-style-apt.conf-config-comments.patch"
patch -p1 -i "${SRCDIR}/moby-patches/0002-Dont-check-auth-and-release-date.patch"
cd ..
cd moby/contrib
./mkimage.sh \
    -d "${TMPDIR}" \
    --no-compression \
    debootstrap \
    --no-check-gpg \
    --no-check-certificate \
    --components=main,contrib,non-free \
    --arch=i386 \
    lenny http://archive.debian.org/debian/
cd "${TMPDIR}"
xz -z9ev --threads=0 rootfs.tar
mv rootfs.tar.xz ../rootfs.tar.xz

cd ..
rm -rf "${TMPDIR}"

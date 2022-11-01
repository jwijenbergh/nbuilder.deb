#!/bin/sh

DISTRO_SUITE_LIST="
	debian|buster
	debian|bullseye
	ubuntu|focal
	ubuntu|jammy
"

for DISTRO_SUITE in ${DISTRO_SUITE_LIST}; do
    DISTRO=$(echo "${DISTRO_SUITE}" | cut -d '|' -f 1)
    SUITE=$(echo "${DISTRO_SUITE}" | cut -d '|' -f 2)
    
    CHROOT_DIR="/srv/chroot/${SUITE}-amd64-sbuild"
    
    if [ "${DISTRO}" = "debian" ]; then
        if ! [ -d "${CHROOT_DIR}" ]; then
            sudo sbuild-createchroot \
                --command-prefix=eatmydata \
                --include=eatmydata,aptitude \
                --extra-repository="deb http://localhost:3142/deb.debian.org/debian ${SUITE}-backports main" \
                "${SUITE}" \
                "${CHROOT_DIR}" \
                http://localhost:3142/deb.debian.org/debian
            # install Go from backports
            sudo sbuild-update -u "${SUITE}"
            sudo sbuild-apt "${SUITE}" apt-get install golang-go/${SUITE}-backports golang-src/${SUITE}-backports
            if [ "${SUITE}" = "bullseye" ]; then
                # on bullseye, install pkg-php-tools from backports, I forgot why...
                sudo sbuild-apt "${SUITE}" apt-get install pkg-php-tools/${SUITE}-backports
            fi
            sudo sbuild-update -udcar "${SUITE}"
        else
            # update instead
            sudo sbuild-update -udcar "${SUITE}"
        fi
    elif [ "${DISTRO}" = "ubuntu" ]; then
        if ! [ -d "${CHROOT_DIR}" ]; then
            sudo sbuild-createchroot \
                --command-prefix=eatmydata \
                --components=main,universe \
                --include=eatmydata,aptitude \
                "${SUITE}" \
                "${CHROOT_DIR}" \
                http://localhost:3142/archive.ubuntu.com/ubuntu
        else
            # update instead
            sudo sbuild-update -udcar "${SUITE}"
        fi
    else
        echo "ERROR: distribution '${DISTRO}' not supported!"
        exit 1
    fi
done

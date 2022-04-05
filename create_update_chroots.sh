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
                --include=eatmydata \
                "${SUITE}" \
                "${CHROOT_DIR}" \
                http://localhost:3142/deb.debian.org/debian
        else
            # update instead
            sudo sbuild-update -udcar "${SUITE}"
        fi
    elif [ "${DISTRO}" = "ubuntu" ]; then
        if ! [ -d "${CHROOT_DIR}" ]; then
            sudo sbuild-createchroot \
                --command-prefix=eatmydata \
                --components=main,universe \
                --include=eatmydata \
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

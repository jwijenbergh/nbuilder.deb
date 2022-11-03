#!/bin/sh

DISTRO_SUITE_LIST="
	debian|bullseye
	ubuntu|bionic
	ubuntu|focal
	ubuntu|jammy
"

for DISTRO_SUITE in ${DISTRO_SUITE_LIST}; do
    DISTRO=$(echo "${DISTRO_SUITE}" | cut -d '|' -f 1)
    SUITE=$(echo "${DISTRO_SUITE}" | cut -d '|' -f 2)

    ARCHS="
	amd64
	i386
    "

    for ARCH in ${ARCHS}; do
	    CHROOT_DIR="/srv/chroot/${SUITE}-${ARCH}-sbuild"

	    if [ "${DISTRO}" = "debian" ]; then
		if ! [ -d "${CHROOT_DIR}" ]; then
		    sudo sbuild-createchroot \
			--arch="${ARCH}" \
			--command-prefix=eatmydata \
			--include=eatmydata,aptitude \
			"${SUITE}" \
			"${CHROOT_DIR}"
		    sudo sbuild-update -udcar "${SUITE}"
		else
		    # update instead
		    sudo sbuild-update -udcar "${SUITE}"
		fi
	    elif [ "${DISTRO}" = "ubuntu" ]; then
		if ! [ -d "${CHROOT_DIR}" ]; then
		    sudo sbuild-createchroot \
			--arch="${ARCH}" \
			--command-prefix=eatmydata \
			--components=main,universe \
			--include=eatmydata \
			"${SUITE}" \
			"${CHROOT_DIR}" \
			"http://archive.ubuntu.com/ubuntu"
		    sudo sbuild-update -udcar "${SUITE}"
		else
		    # update instead
		    sudo sbuild-update -udcar "${SUITE}"
		fi
	    else
		echo "ERROR: distribution '${DISTRO}' not supported!"
		exit 1
	    fi
    done
done

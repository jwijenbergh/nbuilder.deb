#!/bin/sh

REPO_DIR=${HOME}/repos/$(basename "${0}" .sh)
mkdir -p "${REPO_DIR}/conf"
cp "$(basename "${0}" .sh)".distributions "${REPO_DIR}"/conf/distributions

DISTRO_SUITE_LIST="
    debian|buster
	debian|bullseye
	ubuntu|focal
	ubuntu|jammy
"

BASE_PACKAGE_URL_LIST="
	https://git.sr.ht/~fkooman/php-secookie.deb|main
	https://git.sr.ht/~fkooman/php-jwt.deb|main
	https://git.sr.ht/~fkooman/php-oauth2-server.deb|main
	https://git.sr.ht/~fkooman/php-otp-verifier.deb|main
	https://git.sr.ht/~fkooman/php-sqlite-migrate.deb|main
	https://git.sr.ht/~fkooman/vpn-ca.deb|main
	https://git.sr.ht/~fkooman/vpn-daemon.deb|main
	https://git.sr.ht/~fkooman/vpn-lib-common.deb|main
	https://git.sr.ht/~fkooman/vpn-server-api.deb|main
	https://git.sr.ht/~fkooman/vpn-user-portal.deb|main
	https://git.sr.ht/~fkooman/vpn-server-node.deb|main
	https://git.sr.ht/~fkooman/vpn-maint-scripts.deb|main
	https://git.sr.ht/~fkooman/vpn-portal-artwork-eduVPN.deb|main
	https://git.sr.ht/~fkooman/vpn-portal-artwork-LC.deb|main
	https://git.sr.ht/~fkooman/php-saml-sp.deb|main
	https://git.sr.ht/~fkooman/php-saml-sp-artwork-eduVPN.deb|main
"

DEBIAN_EXTRA_PACKAGE_URL_LIST="
	https://salsa.debian.org/php-team/pear/php-constant-time|debian/2.4.0-1
"

TMP_DIR=$(mktemp -d)

for DISTRO_SUITE in ${DISTRO_SUITE_LIST}; do
	DISTRO=$(echo "${DISTRO_SUITE}" | cut -d '|' -f 1)
	SUITE=$(echo "${DISTRO_SUITE}" | cut -d '|' -f 2)

    PACKAGE_URL_LIST=${BASE_PACKAGE_URL_LIST}
    EXTRA_DEP=""

	if [ "debian" = "${DISTRO}" ]; then
	    # on Debian we need to include php-constant-time as it is not part of 
	    # the normal repository
		PACKAGE_URL_LIST=${DEBIAN_EXTRA_PACKAGE_URL_LIST} ${BASE_PACKAGE_URL_LIST}

		# we want to use the backports of Golang on Debian, I have no idea how
		# to make this less awkward...
		if [ "bullseye" = "${SUITE}" ]; then
            # https://packages.debian.org/bullseye/golang-go
		    EXTRA_DEP="--build-dep-resolver=aptitude --add-depends='golang-go (>= 2:1.16)'"
	    fi
		if [ "buster" = "${SUITE}" ]; then
            # https://packages.debian.org/buster/golang-go
		    EXTRA_DEP="--build-dep-resolver=aptitude --add-depends='golang-go (>= 2:1.12)'"
	    fi
    fi

	for PACKAGE_URL_BRANCH in ${PACKAGE_URL_LIST}; do
		PACKAGE_URL=$(echo "${PACKAGE_URL_BRANCH}" | cut -d '|' -f 1)
		PACKAGE_BRANCH=$(echo "${PACKAGE_URL_BRANCH}" | cut -d '|' -f 2)
		cd "${TMP_DIR}" || exit 1
		PACKAGE_NAME=$(basename "${PACKAGE_URL}")
		echo "${PACKAGE_NAME}"
		git clone -b "${PACKAGE_BRANCH}" "${PACKAGE_URL}"
		cd "${PACKAGE_NAME}" || exit
		uscan --download-current-version
		dch --force-distribution -m -D "${SUITE}" -l "+${SUITE}+" "${SUITE}"
		git diff 
		sbuild -d "${SUITE}" --no-run-lintian --extra-package ../ "${EXTRA_DEP}" || exit 1
		git checkout -- .
	done

	# binaries
	for PACKAGE in "${TMP_DIR}"/*"${SUITE}"*.deb; do
		reprepro -b "${REPO_DIR}" includedeb "${SUITE}" "${PACKAGE}" || true
	done

	# sources
	for PACKAGE in "${TMP_DIR}"/*"${SUITE}"*.dsc; do
		reprepro -b "${REPO_DIR}" includedsc "${SUITE}" "${PACKAGE}" || true
	done
done

echo "*** DONE ***"
echo "Result in: ${TMP_DIR}"

#!/bin/sh

set -e -x

REPO_DIR=${HOME}/repos/$(basename ${0} .sh)
rm -rf "${REPO_DIR}"
mkdir -p "${REPO_DIR}/conf"
cp $(basename ${0} .sh).distributions "${REPO_DIR}/conf/distributions"

DISTRO_SUITE_LIST="
	debian|buster|deb10
	debian|bullseye|deb11
"

PACKAGE_URL_LIST="
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

TMP_DIR=$(mktemp -d)

for DISTRO_SUITE in ${DISTRO_SUITE_LIST}; do
	(
		DISTRO=$(echo ${DISTRO_SUITE} | cut -d '|' -f 1)
		SUITE=$(echo ${DISTRO_SUITE} | cut -d '|' -f 2)
		VERSION=$(echo ${DISTRO_SUITE} | cut -d '|' -f 3)

		if [ "debian" = "${DISTRO}" ]; then
			# on Debian we need php-constant-time as it is not
			# part of the distribution...
			if [ "buster" = "${SUITE}" ]; then
				PACKAGE_URL_LIST="
					https://git.sr.ht/~fkooman/php-constant-time.deb|2.x
					${PACKAGE_URL_LIST}
				"
			elif [ "bullseye" = "${SUITE}" ]; then
				PACKAGE_URL_LIST="
					https://salsa.debian.org/php-team/pear/php-constant-time|debian/2.6.3-1
					${PACKAGE_URL_LIST}
				"
			fi
		fi

		for PACKAGE_URL_BRANCH in ${PACKAGE_URL_LIST}; do
			PACKAGE_URL=$(echo ${PACKAGE_URL_BRANCH} | cut -d '|' -f 1)
			PACKAGE_BRANCH=$(echo ${PACKAGE_URL_BRANCH} | cut -d '|' -f 2)
			PACKAGE_NAME=$(basename ${PACKAGE_URL})

			mkdir -p "${TMP_DIR}/${SUITE}"
			cd "${TMP_DIR}/${SUITE}"

			git clone -b "${PACKAGE_BRANCH}" "${PACKAGE_URL}"
			cd "${PACKAGE_NAME}"
			uscan --overwrite-download --download-current-version
			dch --force-distribution -m -D "${SUITE}" -l "+${VERSION}+" "${SUITE}"

			sbuild \
				-d "${SUITE}" \
				--build-dep-resolver=aptitude \
				--extra-package ../

			git checkout -- .
		done

		for PACKAGE in ${TMP_DIR}/${SUITE}/*+${VERSION}+*.deb; do
			echo "Adding ${PACKAGE}..."
			reprepro -b "${REPO_DIR}" includedeb "${SUITE}" "${PACKAGE}"
		done
	)
done

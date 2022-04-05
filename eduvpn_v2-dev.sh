#!/bin/sh

REPO_DIR=${HOME}/repos/$(basename ${0} .sh)
mkdir -p ${REPO_DIR}/conf
cp $(basename ${0} .sh).distributions ${REPO_DIR}/conf/distributions

DISTRO_SUITE_LIST="
	debian|buster
	debian|bullseye
	ubuntu|focal
"

BASE_PACKAGE_URL_LIST="
	https://git.sr.ht/~fkooman/php-secookie.deb|main
	https://git.sr.ht/~fkooman/php-jwt.deb|main
	https://git.sr.ht/~fkooman/php-oauth2-server.deb|main
	https://git.sr.ht/~fkooman/php-openvpn-connection-manager.deb|main
	https://git.sr.ht/~fkooman/php-otp-verifier.deb|main
	https://git.sr.ht/~fkooman/php-sqlite-migrate.deb|main
	https://git.sr.ht/~fkooman/vpn-ca.deb|main
	https://git.sr.ht/~fkooman/vpn-daemon.deb|main
	https://git.sr.ht/~fkooman/vpn-lib-common.deb|main
	https://git.sr.ht/~fkooman/vpn-server-api.deb|main
	https://git.sr.ht/~fkooman/vpn-user-portal.deb|main
	https://git.sr.ht/~fkooman/vpn-server-node.deb|main
	https://git.sr.ht/~fkooman/vpn-maint-scripts.deb|main
"

DEBIAN_PACKAGE_URL_LIST="
	https://salsa.debian.org/php-team/pear/php-constant-time|debian/2.4.0-1
	${BASE_PACKAGE_URL_LIST}
"

TMP_DIR=$(mktemp -d)

for DISTRO_SUITE in ${DISTRO_SUITE_LIST}; do
	DISTRO=$(echo ${DISTRO_SUITE} | cut -d '|' -f 1)
	SUITE=$(echo ${DISTRO_SUITE} | cut -d '|' -f 2)

	if [ "debian" = "${DISTRO}" ]; then
		PACKAGE_URL_LIST=${DEBIAN_PACKAGE_URL_LIST}
	else
		PACKAGE_URL_LIST=${BASE_PACKAGE_URL_LIST}
	fi

	for PACKAGE_URL_BRANCH in ${PACKAGE_URL_LIST}; do
		PACKAGE_URL=$(echo ${PACKAGE_URL_BRANCH} | cut -d '|' -f 1)
		PACKAGE_BRANCH=$(echo ${PACKAGE_URL_BRANCH} | cut -d '|' -f 2)
		cd ${TMP_DIR}
		PACKAGE_NAME=$(basename ${PACKAGE_URL})
		echo ${PACKAGE_NAME}
		git clone -b ${PACKAGE_BRANCH} ${PACKAGE_URL}
		cd ${PACKAGE_NAME} || exit
		uscan --download-current-version
		dch --force-distribution -m -D ${SUITE} -l "+${SUITE}+" ${SUITE}
		git diff 
		sbuild -d ${SUITE} --no-run-lintian --extra-package ../ || exit 1
		git checkout -- .
	done

	# binaries
	for PACKAGE in ${TMP_DIR}/*${SUITE}*.deb; do
		reprepro -b ${REPO_DIR} includedeb ${SUITE} "${PACKAGE}" || true
	done

	# sources
	for PACKAGE in ${TMP_DIR}/*${SUITE}*.dsc; do
		reprepro -b ${REPO_DIR} includedsc ${SUITE} "${PACKAGE}" || true
	done
done

echo "*** DONE ***"
echo "Result in: ${TMP_DIR}"

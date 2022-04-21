#!/bin/sh

set -e -x

REPO_DIR=${HOME}/repos/$(basename ${0} .sh)
rm -rf "${REPO_DIR}"
mkdir -p "${REPO_DIR}/conf"
cp $(basename ${0} .sh).distributions "${REPO_DIR}/conf/distributions"

DISTRO_SUITE_LIST="
	debian|bullseye
	ubuntu|jammy
"

PACKAGE_URL_LIST="
	https://git.sr.ht/~fkooman/php-secookie.deb|v6
	https://git.sr.ht/~fkooman/php-oauth2-server.deb|v7
	https://git.sr.ht/~fkooman/vpn-ca.deb|main
	https://git.sr.ht/~fkooman/vpn-daemon.deb|v3
	https://git.sr.ht/~fkooman/vpn-user-portal.deb|v3
	https://git.sr.ht/~fkooman/vpn-server-node.deb|v3
	https://git.sr.ht/~fkooman/vpn-maint-scripts.deb|v3
"

TMP_DIR=$(mktemp -d)

for DISTRO_SUITE in ${DISTRO_SUITE_LIST}; do
	DISTRO=$(echo ${DISTRO_SUITE} | cut -d '|' -f 1)
	SUITE=$(echo ${DISTRO_SUITE} | cut -d '|' -f 2)
	for PACKAGE_URL_BRANCH in ${PACKAGE_URL_LIST}; do
		PACKAGE_URL=$(echo ${PACKAGE_URL_BRANCH} | cut -d '|' -f 1)
		PACKAGE_BRANCH=$(echo ${PACKAGE_URL_BRANCH} | cut -d '|' -f 2)
		PACKAGE_NAME=$(basename ${PACKAGE_URL})

		mkdir -p "${TMP_DIR}/${SUITE}"
		cd "${TMP_DIR}/${SUITE}"

		git clone -b "${PACKAGE_BRANCH}" "${PACKAGE_URL}"
		cd "${PACKAGE_NAME}"
		uscan --overwrite-download --download-current-version
		dch --force-distribution -m -D "${SUITE}" -l "+${SUITE}+" "${SUITE}"

		sbuild \
			-d "${SUITE}" \
			--no-run-lintian \
			--extra-package ../

		git checkout -- .
	done

	for PACKAGE in ${TMP_DIR}/${SUITE}/*${SUITE}*.deb; do
		echo "Adding ${PACKAGE}..."
		reprepro -b "${REPO_DIR}" includedeb "${SUITE}" "${PACKAGE}"
	done
done

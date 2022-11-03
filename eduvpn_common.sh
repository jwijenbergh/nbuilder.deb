#!/bin/sh

set -e -x

REPO_DIR=${HOME}/repos/$(basename ${0} .sh)
rm -rf "${REPO_DIR}"
mkdir -p "${REPO_DIR}/conf"
cp $(basename ${0} .sh).distributions "${REPO_DIR}/conf/distributions"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

DISTRO_SUITE_LIST="
	debian|bullseye|debian+11
	ubuntu|bionic|ubuntu+18.04
	ubuntu|focal|ubuntu+20.04
	ubuntu|jammy|ubuntu+22.04
"

PACKAGE_URL_LIST="
	https://github.com/jwijenbergh/python-eduvpn-common.deb|main|go
	https://github.com/jwijenbergh/python-eduvpn-client|debian
"
#386,i386|1.19.3|4f055d40cbd3047b90f5b6c2d30a7fc6732aa1475f372f37ac574f725340aab3
#arm64,arm64|1.19.3|99de2fe112a52ab748fb175edea64b313a0c8d51d6157dba683a6be163fd5eab
GO_ARCH_VERSIONS="
	amd64,amd64|1.19.3|74b9640724fd4e6bb0ed2a1bc44ae813a03f1e72a4c76253e2d5c015494430ba
"

TMP_DIR=$(mktemp -d)

for DISTRO_SUITE in ${DISTRO_SUITE_LIST}; do
	DISTRO=$(echo ${DISTRO_SUITE} | cut -d '|' -f 1)
	SUITE=$(echo ${DISTRO_SUITE} | cut -d '|' -f 2)
	VERSION=$(echo ${DISTRO_SUITE} | cut -d '|' -f 3)
	for PACKAGE_URL_BRANCH in ${PACKAGE_URL_LIST}; do
		PACKAGE_URL=$(echo ${PACKAGE_URL_BRANCH} | cut -d '|' -f 1)
		PACKAGE_BRANCH=$(echo ${PACKAGE_URL_BRANCH} | cut -d '|' -f 2)
		PACKAGE_OVERRIDE=$(echo ${PACKAGE_URL_BRANCH} | cut -d '|' -f 3)
		PACKAGE_NAME=$(basename ${PACKAGE_URL})

		mkdir -p "${TMP_DIR}/${SUITE}"
		cd "${TMP_DIR}/${SUITE}"

		git clone -b "${PACKAGE_BRANCH}" "${PACKAGE_URL}"
		cd "${PACKAGE_NAME}"
		uscan --overwrite-download --download-current-version
		dch --force-distribution -m -D "${SUITE}" -l "+${VERSION}+" "${SUITE}"

		if [ "${PACKAGE_OVERRIDE}" = "go" ]; then
			echo "Overriding Deb Go version"
			for GO_ARCH_VERSION in ${GO_ARCH_VERSIONS}; do
				GO_ARCH=$(echo ${GO_ARCH_VERSION} | cut -d '|' -f 1)
				GO_ARCH_SBUILD=$(echo ${GO_ARCH} | cut -d ',' -f 1)
				GO_ARCH_URL=$(echo ${GO_ARCH} | cut -d ',' -f 2)
				GO_VERSION=$(echo ${GO_ARCH_VERSION} | cut -d '|' -f 2)
				GO_HASH=$(echo ${GO_ARCH_VERSION} | cut -d '|' -f 3)
				SBUILD_CONFIG="${SCRIPT_DIR}/go-override-sbuild.conf" sbuild \
					--host="${GO_ARCH_SBUILD}" \
					-d "${SUITE}" \
					--extra-package ../ \
					--pre-build-commands="cat ${SCRIPT_DIR}/get-go.sh | %SBUILD_CHROOT_EXEC sh -c 'cat > /tmp/get-go.sh'" \
					--starting-build-commands="sh /tmp/get-go.sh ${GO_VERSION} ${GO_ARCH_URL} ${GO_HASH}"
			done
		else
			sbuild \
				-d "${SUITE}" \
				--extra-package ../
		fi



		git checkout -- .
	done

	for PACKAGE in ${TMP_DIR}/${SUITE}/*+${VERSION}+*.deb; do
		echo "Adding ${PACKAGE}..."
		reprepro -b "${REPO_DIR}" includedeb "${SUITE}" "${PACKAGE}"
	done
done

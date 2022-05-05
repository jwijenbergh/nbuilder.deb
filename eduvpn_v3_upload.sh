#!/bin/sh

REPO_DIR=${HOME}/repos/eduvpn_v3

SERVER_LIST="
	eduvpn-repo@tromso-cdn.eduroam.no
	eduvpn-repo@ifi2-cdn.eduroam.no
	eduvpn-repo@ams-cdn.eduvpn.org
"

for SERVER in ${SERVER_LIST}; do
	rsync -e ssh -rltO --delete ${REPO_DIR}/dists ${REPO_DIR}/pool "${SERVER}:/srv/repo.eduvpn.org/www/v3/deb"
done

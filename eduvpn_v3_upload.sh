#!/bin/sh

REPO_DIR=${HOME}/repos/eduvpn_v3

#ams-cdn.eduvpn.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9xsoHonghdxsMFzlSBRpF+ZWEWlPselk7S3AQ4LAbw
#tromso-cdn.eduroam.no ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnl+83/iCGbibgmsuDzDMunX1B6hDAEEvk3eKl3gljp
#ifi2-cdn.eduroam.no ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1f3xpRfaOUmtIvs+x/v2GlzGKHQDmLiscRkZqQd931

SERVER_LIST="
	eduvpn-repo@tromso-cdn.eduroam.no
	eduvpn-repo@ifi2-cdn.eduroam.no
	eduvpn-repo@ams-cdn.eduvpn.org
"

for SERVER in ${SERVER_LIST}; do
	rsync -e ssh -rltO --delete ${REPO_DIR}/dists ${REPO_DIR}/pool "${SERVER}:/srv/repo.eduvpn.org/www/v3/deb"
done

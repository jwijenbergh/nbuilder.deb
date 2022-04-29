#!/bin/sh

REPO_DIR=${HOME}/repos/python-eduvpn-client_v2-dev
rsync -e ssh -rltO --delete ${REPO_DIR}/dists ${REPO_DIR}/pool "repo@argon.tuxed.net:/var/www/repo.tuxed.net/python-eduvpn-client/v2-dev/deb"

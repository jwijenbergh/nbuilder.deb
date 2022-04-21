#!/bin/sh

REPO_DIR=${HOME}/repos/eduvpn_v2-dev
rsync -e ssh -rltO --delete ${REPO_DIR}/dists ${REPO_DIR}/pool "repo@argon.tuxed.net:/var/www/repo.tuxed.net/eduVPN/v2-dev/deb"

#!/bin/sh

REPO_DIR=${HOME}/repos/php-saml-sp_v2
rsync -e ssh -rltO --delete ${REPO_DIR}/dists ${REPO_DIR}/pool "repo@argon.tuxed.net:/var/www/repo.php-saml-sp.eu/v2/deb"

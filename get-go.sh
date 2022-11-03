#!/bin/sh

set -e

apt-get install -y ca-certificates wget
wget "https://go.dev/dl/go$1.linux-$2.tar.gz" -O go.tar.gz
echo "$3  go.tar.gz" | sha256sum --check
rm -rf /usr/local/go/
tar -C /usr/local -xzf "go.tar.gz"

# Builder

## Requirements

devscripts
build-essential
apt-cacher-ng
sbuild
pkg-php-tools
dh-golang dh-sysuser apache2-dev
reprepro

# check dependencies to see if there's anything interesting here
# sbuild-debian-developer-setup --suite bullseye

sbuild-createchroot \
	--command-prefix=eatmydata \
        --include=eatmydata \
        bullseye \
        /srv/chroot/bullseye-amd64-sbuild \
        http://localhost:3142/deb.debian.org/debian

sbuild-createchroot \
        --command-prefix=eatmydata \
        --components=main,universe \
        --include=eatmydata \
        focal \
        /srv/chroot/focal-amd64-sbuild \
        http://localhost:3142/archive.ubuntu.com/ubuntu


sudo usermod -a -G sbuild $(whoami)



Generate an RSA 3072 key that expires in 5 years:

```bash
$ gpg --batch --passphrase '' --quick-generate-key "Debian Packaging Key <debian@example.org>" default default 5y
```


for ubuntu images:

W: Cannot check Release signature; keyring file not available /usr/share/keyrings/ubuntu-archive-keyring.gpg


The "chroots" are installed under /var/lib/schroot/chroots



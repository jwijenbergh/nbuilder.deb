# Builder

## Requirements

```bash
$ sudo apt install devscripts build-essential apt-cacher-ng sbuild pkg-php-tools dh-golang dh-sysuser apache2-dev reprepro
```

Make sure your user is a member of the `sbuild` group:

```bash
$ sudo usermod -a -G sbuild $(whoami)
```

Make sure you have a PGP key, .e.g.:

```bash
$ gpg --batch --passphrase '' --quick-generate-key "Debian Packaging Key <debian@example.org>" default default 5y
```

## Create Chroots

### Debian 11

```bash
$ sudo sbuild-createchroot \
    --command-prefix=eatmydata \
    --include=eatmydata \
    bullseye \
    /srv/chroot/bullseye-amd64-sbuild \
    http://localhost:3142/deb.debian.org/debian
```

### Ubuntu 20.04 LTS

**TODO**: we need to figure out where to get the Ubuntu release key.

```bash
$ sudo sbuild-createchroot \
    --command-prefix=eatmydata \
    --components=main,universe \
    --include=eatmydata \
    focal \
    /srv/chroot/focal-amd64-sbuild \
    http://localhost:3142/archive.ubuntu.com/ubuntu
```

## Build, Sign & Repository

Run the build scripts, e.g. `php-saml-sp_v2.sh`. This will build the packages,
add them to the repository and sign the packages. Ready to be installed.

# Builder

## Requirements

When you are building for Ubuntu as well, it is highly recommended you use 
Ubuntu to build your packages, including the ones for Debian. Use the latest 
stable Ubuntu release for this, which at this time of writing is Ubuntu 21.10.

```bash
$ sudo apt install \
    debian-keyring \
    devscripts \
    build-essential \
    apt-cacher-ng \
    sbuild \
    pkg-php-tools \
    dh-golang \
    dh-sysuser \
    apache2-dev \
    reprepro
```

Make sure your user is a member of the `sbuild` group:

```bash
$ sudo usermod -a -G sbuild $(whoami)
```

Make sure you have a PGP key, .e.g.:

```bash
$ gpg \
    --batch \
    --passphrase '' \
    --quick-generate-key "Debian Packaging Key <debian@example.org>" \
    default \
    default \
    5y
```

Make sure you have only one (private) key installed, so that one gets picked. 
If you have multiple, update `SignWith` field in the `.distributions` file to 
list the Key ID. You can list the available Key IDs using `gpg -K`.

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

### Ubuntu 20.04

**NOTE**: on Debian 11, there is no Ubuntu keyring available anymore to verify 
the Ubuntu repository files so a warning will be printed. On Debian 10 you can 
install the `ubuntu-keyring` package. If you are building for Ubuntu as well,
it is recommended to use Ubuntu to build (all) of your packages.

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

To change the distributions to build for and make available in the repository, 
modify the `.distributions` file and also update the `.sh` script by modifying
the `DISTRO_SUITE_LIST` variable.

Run the `.sh` script to build the packages and add them to the local repository
in `${HOME}/repos`. The `_upload.sh` script can be used to upload the 
repository to a remote web server.

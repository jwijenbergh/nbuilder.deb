# Builder

## Requirements

When you are building for Ubuntu as well, it is highly recommended you use 
Ubuntu to build your packages, including the ones for Debian. Use the latest 
stable Ubuntu release for this, which at this time of writing is Ubuntu 21.10.

```bash
$ sudo apt install \
    debian-archive-keyring \
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
    --quick-generate-key "Repository Signing Key <me+repo@example.org>" \
    future-default \
    default \
    10y
```

If you use `future-default` instead of `default` in the key generation command 
it will use Curve 25519 instead of RSA 3072 on Debian/Ubuntu.

Make sure you have only one (private) key installed, so that one gets picked. 
If you have multiple, update `SignWith` field in the `.distributions` file to 
list the Key ID. You can list the available Key IDs using `gpg -K`.

## Create Chroots

The script `create_update_chroots.sh` can be used to create the _chroots_ and
update them.

Modify `DISTRO_SUITE_LIST` and set the distributions/suites you want and then
run the script.

## Build, Sign & Repository

To change the distributions to build for and make available in the repository, 
modify the `.distributions` file and also update the `.sh` script by modifying
the `DISTRO_SUITE_LIST` variable.

Run the `.sh` script to build the packages and add them to the local repository
in `${HOME}/repos`. The `_upload.sh` script can be used to upload the 
repository to a remote web server.

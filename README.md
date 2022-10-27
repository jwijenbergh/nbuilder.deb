# Builder

## Requirements

When you are building for Ubuntu as well, it is highly recommended you use 
Ubuntu to build your packages, including the ones for Debian. Use the latest 
stable Ubuntu release for this, which at this time of writing is Ubuntu 22.04.

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
    reprepro \
    git-buildpackage
```

Make sure your user is a member of the `sbuild` group:

```bash
$ sudo usermod -a -G sbuild $(whoami)
$ newgrp sbuild
```

Make sure you have a PGP key, .e.g.:

```bash
$ gpg \
    --batch \
    --passphrase '' \
    --quick-generate-key "Repository Signing Key <me+repo@example.org>" \
    future-default \
    sign \
    10y
```

If you use `future-default` instead of `default` in the key generation command 
it will use Curve 25519 instead of RSA 3072 on Debian/Ubuntu.

Make sure you have only one (private) key installed, so that one gets picked. 
If you have multiple, update `SignWith` field in the `.distributions` file to 
list the Key ID. You can list the available Key IDs using `gpg -K`.

You can export your key for import in the Debian / Ubuntu system that will 
install your packages like this:

```
$ gpg --output me+repo@example.org.gpg --export me+repo@example.org
```

On the system using the package repository, place this file in 
`/etc/apt/trusted.gpg.d`.

## Clone Repository

```bash
$ git clone https://git.sr.ht/~fkooman/nbuilder.deb
```

All commands below are executed _inside_ the `nbuilder.deb` folder.

## Create Chroots

The script `create_update_chroots.sh` can be used to create the _chroots_ and
update them.

Modify `DISTRO_SUITE_LIST` and set the distributions/suites you want and then
run the script.

```bash
$ ./create_update_chroots.sh
```

## Build, Sign & Repository

To change the distributions to build for and make available in the repository, 
modify the `.distributions` file for the software you want to build, e.g. 
`eduvpn_v3.distributions`. Also modify the shell script, e.g. `eduvpn_v3.sh` by 
modifying the `DISTRO_SUITE_LIST` variable.

Run the shell script to build the packages and add them to the local repository
in `${HOME}/repos`. The `_upload.sh` script can be used to upload the 
repository to a remote web server. Modify to point to your own server.

Also, do NOT forget to modify the `.distributions` file to set the `SignWith` 
field to point to your key, e.g.:

```
SignWith: me+repo@example.org
```

To run the builder:

```
$ ./eduvpn_v3.sh
```

To start the repository upload:

```
$ ./eduvpn_v3_upload.sh
```

## Updating Packages

**NOTE**: only do this if you want to package newer versions of the software,
NOT run the builder.

### Environment

Make sure the variables `DEBFULLNAME` and `DEBEMAIL` are set. This makes sure 
`dch` below uses this information to update the `debian/changelog` file. Add 
this to the bottom of `${HOME}/.profile`:

```bash
export DEBFULLNAME="François Kooman"
export DEBEMAIL=fkooman@deic.dk
```

After this make sure you logout and in again.

### Updating

In order to update a package, you can use the following commands, if necessary
first fork the repository to a place where you can "push" to:

```bash
$ git clone git@git.sr.ht:~fkooman/vpn-user-portal.deb
```

We need to make the `upstream` branch available locally, not sure how to do
that properly, but this works:

```bash
$ git checkout upstream
$ git checkout v3
```

Download the latest upstream tar release and verify the signature:

```bash
$ uscan
```

Import the new release in the Git repository:

```bash
$ gbp import-orig ../vpn-user-portal_3.0.5.orig.tar.xz
```

Update the `debian/changelog` file. Your editor will be opened.

```bash
$ dch -v 3.0.5-1
```

The update message could be "update to 3.0.5". If you make any other changes to
the package, note them here as well. Finalize the changes:

```bash
$ dch -r --distribution unstable
```

Review the changes:

```bash
$ git diff
```

If all looks good, commit and push the changes:

```bash
$ git commit -a -m 'update to 3.0.5'
```

Now push all branches/tags to the server:

```bash
$ git push origin --all
$ git push origin --tags
```

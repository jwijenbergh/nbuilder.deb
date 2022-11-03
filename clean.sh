#!/bin//sh

sudo schroot --end-session --all-sessions
sudo rm -rf /etc/schroot/chroot.d/*
sudo rm -rf /srv/chroot/*
sudo rm -rf /etc/sbuild/chroot/*

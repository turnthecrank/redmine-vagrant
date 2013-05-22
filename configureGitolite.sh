#!/bin/bash
# Configure gitolite for use with the Redmine Git Hosting Plugin from 
# https://github.com/jbox-web/redmine_git_hosting

# As user root, prep to make gitolite keys at default location used by Redmine Git Hosting Plugin
sudo mkdir ~www-data/.ssh
sudo chmod 700 ~www-data/.ssh
sudo chown www-data.www-data ~www-data/.ssh

# as user www-data, make those keys with the default names used by Redmine Git Hosting Plugin
sudo su - www-data
ssh-keygen -N '' -f ~/.ssh/redmine_gitolite_admin_id_rsa

# Still as user www-data, link private key to default ssh keyfile name to simplify testing
cd ~/.ssh
ln -s redmine_gitolite_admin_id_rsa id_rsa

# we're done being user www-data
exit

# As user root, copy the ssh public key redmine will use to connect to the gitolite admin repo
# make it aacessible for gitolite setup
sudo cp ~www-data/.ssh/redmine_gitolite_admin_id_rsa.pub ~git/
sudo chown git.git ~git/redmine_gitolite_admin_id_rsa.pub

# As user git, configure git.  It shouldn't be needed, but we should set reasonable defaults
sudo su - git
git config --global user.email "redmine@localhost"
git config --global user.name "Redmine"

# Still as user git clean up any messes from failed gitolite setups
rm .ssh/authorized_keys
rm ~/.gitolite/keydir/*
rm -rf repositories/gitolite-admin.git/
rm gitolite-admin.pub

# Symlink our public key to the default gitolite admin, "gitolite-admin"
ln -s redmine_gitolite_admin_id_rsa.pub gitolite-admin.pub

# Still as user git, setup Gitolite
gitolite setup -pk gitolite-admin.pub
exit

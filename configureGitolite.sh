#!/bin/bash
# Configure gitolite for use with the Redmine Git Hosting Plugin from 
# https://github.com/jbox-web/redmine_git_hosting

# As user root, prep to make gitolite keys at default location used by Redmine Git Hosting Plugin
sudo mkdir ~www-data/.ssh
sudo chmod 700 ~www-data/.ssh
sudo chown www-data.www-data ~www-data/.ssh

# as user www-data, make those keys with the default names used by Redmine Git Hosting Plugin
sudo -u www-data ssh-keygen -N '' -f ~/.ssh/redmine_gitolite_admin_id_rsa

# Still as user www-data, link private key to default ssh keyfile name to simplify testing
sudo -u www-data ln -s ~www-data/.ssh/redmine_gitolite_admin_id_rsa ~www-data/.ssh/id_rsa

# As user root, copy the ssh public key redmine will use to connect to the gitolite admin repo
# make it aacessible for gitolite setup
sudo cp ~www-data/.ssh/redmine_gitolite_admin_id_rsa.pub ~git/
sudo chown git.git ~git/redmine_gitolite_admin_id_rsa.pub

# As user git, configure git.  It shouldn't be needed, but we should set reasonable defaults
sudo -u git git config --global user.email "redmine@localhost"
sudo -u git git config --global user.name "Redmine"

# Still as user git clean up any messes from failed gitolite setups
sudo -u git rm ~git/.ssh/authorized_keys
sudo -u git rm ~git/.gitolite/keydir/*
sudo -u git rm -rf ~git/repositories/gitolite-admin.git/
sudo -u git rm ~git/gitolite-admin.pub

# Symlink our public key to the default gitolite admin, "gitolite-admin"
sudo -u git ln -s ~git/redmine_gitolite_admin_id_rsa.pub ~git/gitolite-admin.pub

# Still as user git, setup Gitolite
sudo -u git ~git/bin/gitolite setup -pk ~git/gitolite-admin.pub

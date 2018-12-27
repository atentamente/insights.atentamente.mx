#!/bin/bash
#==========================================================================================
# written by:   mcdaniel
# date:         dec-2018
#
# usage:        Build edX Insights application server.
#==========================================================================================

# Run this script to set up the analytics pipeline
echo "Assumes that there's a tracking.log file in \$HOME"
sleep 2

echo "Create ssh key"
ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''
echo >> ~/.ssh/authorized_keys # Make sure there's a newline at the end
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# check: ssh localhost "echo It worked!" -- make sure it works.

# Fix ubuntu locale problems. these affect python and pip.
sudo locale-gen en_US en_US.UTF-8
sudo dpkg-reconfigure locales
export LANG="en_US.utf8"
export LANGUAGE="en_US.utf8"
export LC_ALL="en_US.utf8"


echo "Install needed packages"

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y git python-pip python-dev libmysqlclient-dev
sudo pip install virtualenv
sudo reboot

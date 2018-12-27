#!/bin/bash
#==========================================================================================
# written by:   mcdaniel
# date:         dec-2018
#
# usage:        Build edX Insights application server.
#==========================================================================================
LMS_HOSTNAME="https://educacion.atentamente.mx"
INSIGHTS_HOSTNAME="http://3.81.115.185:8110"  # Change this to the externally visible domain and scheme for your Insights install, ideally HTTPS
DB_USERNAME="read_only"
DB_HOST="educacion.atentamente.mx"
DB_PASSWORD="ZRdHqYAr0qWw8srWT44jfj2OTnqGbYlgF1R"
DB_PORT="3306"
# Run this script to set up the analytics pipeline
echo "Assumes that there's a tracking.log file in \$HOME"
sleep 2

echo "Create ssh key"
ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''
echo >> ~/.ssh/authorized_keys # Make sure there's a newline at the end
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# check: ssh localhost "echo It worked!" -- make sure it works.

# Fix ubuntu locale problems. these affect python and pip.
sudo locale-gen "en_US.UTF-8"
sudo dpkg-reconfigure locales
export LANG="en_US.utf8"
export LANGUAGE="en_US.utf8"
export LC_ALL="en_US.utf8"

echo "Install needed packages"

sudo apt-get update
sudo apt-get install -y git python-pip python-dev libmysqlclient-dev
sudo pip install virtualenv

echo 'create an "ansible" virtualenv and activate it'
virtualenv ansible
. ansible/bin/activate
git clone -b open-release/hawthorn.master https://github.com/edx/configuration.git

cd configuration/
make requirements
cd playbooks/
echo "running ansible -- it's going to take a while"
ansible-playbook -i localhost, -c local analytics_single.yml --extra-vars "INSIGHTS_LMS_BASE=$LMS_HOSTNAME INSIGHTS_BASE_URL=$INSIGHTS_HOSTNAME"

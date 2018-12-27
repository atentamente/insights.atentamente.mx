#!/bin/bash
#==========================================================================================
# written by:   mcdaniel
# date:         dec-2018
#
# usage:        Build edX Insights application server.
#==========================================================================================
LMS_HOSTNAME="https://educacion.atentamente.mx"
INSIGHTS_HOSTNAME="http://34.235.170.31:8110"  # Change this to the externally visible domain and scheme for your Insights install, ideally HTTPS
DB_USERNAME="read_only"
DB_HOST="educacion.atentamente.mx"
DB_PASSWORD="ZRdHqYAr0qWw8srWT44jfj2OTnqGbYlgF1R"
DB_PORT="3306"

echo 'create an "ansible" virtualenv and activate it'
virtualenv ansible
. ansible/bin/activate
git clone -b open-release/ginkgo.master https://github.com/edx/configuration.git

cd configuration/
make requirements
cd playbooks/
echo "running ansible -- it's going to take a while"
ansible-playbook -i localhost, -c local analytics_single.yml --extra-vars "INSIGHTS_LMS_BASE=$LMS_HOSTNAME INSIGHTS_BASE_URL=$INSIGHTS_HOSTNAME"


echo "-- Set up pipeline"
cd $HOME
sudo mkdir -p /edx/var/log/tracking
sudo cp ~/tracking.log /edx/var/log/tracking
sudo chown hadoop /edx/var/log/tracking/tracking.log

echo "Waiting 70 seconds to make sure the logs get loaded into HDFS"
# Hack hackity hack hack -- cron runs every minute and loads data from /edx/var/log/tracking
sleep 70

# Make a new virtualenv -- otherwise will have conflicts
echo "Make pipeline virtualenv"
virtualenv pipeline
. pipeline/bin/activate

echo "Check out pipeline"
git clone https://github.com/edx/edx-analytics-pipeline
cd edx-analytics-pipeline
make bootstrap
# HACK: make ansible do this
cat <<EOF > /edx/etc/edx-analytics-pipeline/input.json
{"username": $DB_USERNAME, "host": $DB_HOST, "password": $DB_PASSWORD, "port": $DB_PORT}
EOF

echo "Run the pipeline"
# Ensure you're in the pipeline virtualenv
remote-task --host localhost --repo https://github.com/edx/edx-analytics-pipeline --user ubuntu --override-config $HOME/edx-analytics-pipeline/config/devstack.cfg --wheel-url http://edx-wheelhouse.s3-website-us-east-1.amazonaws.com/Ubuntu/precise --remote-name analyticstack --wait TotalEventsDailyTask --interval 2016 --output-root hdfs://localhost:9000/output/ --local-scheduler

echo "If you got this far without error, you should try running the real pipeline tasks listed/linked below"

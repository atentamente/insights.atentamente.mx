#!/bin/bash
#==========================================================================================
# written by:   mcdaniel
# date:         dec-2018
#
# usage:        Build edX Insights application server.
#==========================================================================================

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

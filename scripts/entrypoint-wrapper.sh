#!/bin/bash

# Permissions
mkdir -p /home/jenkins
echo "[INFO] Setting permissions on /home/jenkins... this may take a while"
rm -rf /home/jenkins/workspace
mkdir -p /home/jenkins/workspace
chown -R jenkins:jenkins /home/jenkins
echo "[INFO] Done setting permissions"

# Launch the original entrypoint script
#   This basically is just deferring the `USER jenkins` directive
gosu jenkins /docker-entrypoint.sh "$@"

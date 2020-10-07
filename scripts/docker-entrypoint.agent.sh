#!/bin/bash

# GitHub Setup
mkdir -p ~/.ssh
chmod 700 ~/.ssh
if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
  ssh-keygen -t rsa -b 4096 -C "jenkins-key" -N '' -f ~/.ssh/id_rsa
  echo "### New SSH Public Key:"
  cat  "${HOME}/.ssh/id_rsa.pub"
  echo "### Add to GitHub for jenkins things..."
fi
rm -rf ~/.ssh/known_hosts
ssh-keyscan -H github.sherwin.com >> ~/.ssh/known_hosts
ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# Source RVM stuff
source /etc/profile.d/rvm.sh

# Run the original script, passing any arguments on
exec /usr/local/bin/jenkins-slave "$@"

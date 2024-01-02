#!/usr/bin/env bash

set -xeo pipefail

mkdir -p /gitlab-shell
cp -av /home/git/gitlab-shell/{bin,config.yml} /gitlab-shell
chown -R root:root /gitlab-shell

cp -av /scripts/templates/sshd_config /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config
chmod 0600 /etc/ssh/sshd_config

if [[ ! -e /home/git/ssh_host_rsa_key ]]; then
  su git -c 'ssh-keygen -t rsa -N "" -f /home/git/ssh_host_rsa_key'
fi

cp /home/git/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
chown root:root /etc/ssh/ssh_host_rsa_key
chmod 0600 /etc/ssh/ssh_host_rsa_key
mkdir -p /run/sshd

# SSH login fix. Otherwise user is kicked off after login
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

exec /usr/sbin/sshd -D -e "$@"

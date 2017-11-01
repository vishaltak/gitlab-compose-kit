#!/bin/bash

set -xe

cat <<EOF > /etc/ssh/sshd_config
AllowUsers git
AuthenticationMethods publickey
HostKey /etc/ssh/ssh_host_rsa_key
PidFile none
ListenAddress 0.0.0.0:2222
LogLevel VERBOSE
PasswordAuthentication no
PidFile none
Protocol 2
StrictModes no
UseLogin no
UsePAM no

Match User git
AuthorizedKeysFile /home/git/.ssh/authorized_keys
EOF

if [[ ! -e /home/git/ssh_host_rsa_key ]]; then
  su git -c 'ssh-keygen -t rsa -N "" -f /home/git/ssh_host_rsa_key'
fi

cp /home/git/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
chown root:root /etc/ssh/ssh_host_rsa_key
chmod 0600 /etc/ssh/ssh_host_rsa_key
mkdir -p /run/sshd

# SSH login fix. Otherwise user is kicked off after login
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

exec /usr/sbin/sshd -D "$@"

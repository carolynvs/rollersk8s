#!/bin/sh
# Copy this file to post-install.sh and customize
set -eou pipefail

echo "executing post-install script..."

# Add authorized_keys
USERNAME="username"
echo "adding authorized_keys to $USERNAME"
mkdir -p /home/$USERNAME/.ssh
cat <<EOF >/home/$USERNAME/.ssh/authorized_keys
ssh-rsa my-public-key
EOF

# Pretty colors
echo ""
cp /etc/skel/.bashrc /root/

echo "post-install script complete"

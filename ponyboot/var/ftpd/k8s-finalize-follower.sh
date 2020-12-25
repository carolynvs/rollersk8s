#!/bin/bash
set -xeou pipefail

# Install k8s
curl -O tftp://raspberrypi/k8s.sh
bash k8s.sh follower

curl -O tftp://raspberrypi/join
chmod o+x join
./join

# Only run the installation once
systemctl disable install-k8s

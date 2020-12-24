#!/bin/bash
set -xeou pipefail

# Install k8s
curl -O tftp://raspberrypi/k8s.sh
bash k8s.sh follower

printf "first run the following command on the master to get the cluster token:\n\n"
printf "\tsudo kubeadm token list\n\n"
printf "then run the following command on this node to join the cluster:\n\n"
printf "\tkubeadm join --token <TOKEN> <MASTERHOSTNAME>:6443\n"

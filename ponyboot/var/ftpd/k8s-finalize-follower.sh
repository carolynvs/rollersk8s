#!/bin/sh
set -eou pipefail

printf "first run the following command on the master to get the cluster token:\n\n"
printf "\tsudo kubeadm token list\n\n"
printf "then run the following command on this node to join the cluster:\n\n"
printf "\tkubeadm join --token <TOKEN> <MASTERHOSTNAME>:6443\n"

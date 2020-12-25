#!/bin/bash
set -xeou pipefail

# Install k8s
curl -O tftp://raspberrypi/k8s.sh
bash k8s.sh leader

# Create the initial cluster
# Specify a CIDR to make flannel happy
echo "creating a new cluster..."
kubeadm init --pod-network-cidr=10.244.0.0/16

# Point kubectl at the cluster
export KUBECONFIG=/etc/kubernetes/admin.conf

# Sanity check that the cluster was created sucessfully
echo "verify the master node is in the cluster..."
kubectl get node/`hostname`

# Configure the cluster network to use flannel
echo "enabling flannel..."
kubectl apply -f /root/manifests/kube-flannel.yml

# Allow workloads to run on the master by removing the master taint
# it will still be labeled as a master
echo "allowing workloads to run on master..."
kubectl taint node `hostname` node-role.kubernetes.io/master-

echo "new cluster setup complete, waiting for nodes to join"
curl -O tftp://raspberrypi/advertise && chmod o+x advertise

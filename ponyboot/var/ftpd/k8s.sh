#!/bin/sh

TYPE=$1
if [ "$TYPE" == "" ]; then
  echo "usage: k8s.sh master|node"
  exit 1
fi

echo "configuring as a Kubernetes $TYPE"

# Add the kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update

# Install Docker
apt-get install -y docker-engine

# Install kubernetes
apt-get install -y kubelet kubeadm kubernetes-cni kubectl

echo "finished Kubernetes configuration! 🎉"

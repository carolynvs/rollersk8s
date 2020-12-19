#!/bin/sh
set -eou pipefail

K8S_VERSION="1.20.1-00"
ETCD_VERSION="3.4.14"

TYPE=$1
if [ "$TYPE" == "" ]; then
  echo "usage: k8s.sh leader|follower"
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
apt-get install -y kubelet=$K8S_VERSION kubeadm=$K8S_VERSION kubectl=$K8S_VERSION

if [[ "$TYPE" == "leader" ]]; then

  ##
  ## Leader Setup
  ##

  # Automatically load the cluster credentials into kubectl
  cat <<EOF >>/root/.bashrc
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF

  # Download flannel configuration
  mkdir -p /root/manifests
  cd /root/manifests
  curl -sLO https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

  # Install etcdctl so you can do backups later
  cd /root
  curl -sLO https://github.com/coreos/etcd/releases/download/v$ETCD_VERSION/etcd-v$ETCD_VERSION-linux-amd64.tar.gz
  tar -xzf etcd-v$ETCD_VERSION-linux-amd64.tar.gz
  mv etcd-v$ETCD_VERSION-linux-amd64/etcdctl /usr/bin/

  # Download the finalize script
  curl -O tftp://raspberrypi/k8s-finalize-leader.sh

  echo "after rebooting, run the following command to create the cluster:"
  printf "\tbash k8s-finalize-leader.sh\n"

else

  ##
  ## Follower Setup
  ##

  # Download the finalize script
  cd /root
  curl -O tftp://raspberrypi/k8s-finalize-follower.sh
  echo "after rebooting, run the following command to join the cluster:"
  printf "\tbash k8s-finalize-follower.sh\n"

fi

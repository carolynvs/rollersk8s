#!/bin/sh
set -eou pipefail

K8S_VERSION="1.20.1-00"
DOCKER_VERSION="5:20.10.1~3-0~debian-buster"
CONTAINERD_VERSION="1.4.3-1"
ETCD_VERSION="3.4.14"

TYPE=$1
if [ "$TYPE" == "" ]; then
  echo "usage: k8s.sh leader|follower"
  exit 1
fi

echo "configuring as a Kubernetes $TYPE"

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Add the Docker repository
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable
EOF

# Add the kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Refresh apt cache
apt-get update

# Install Docker
apt-get install -y docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io=$CONTAINERD_VERSION
mkdir -p /etc/docker
cat <<EOF >> /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

# Install kubernetes
apt-get install -y kubelet=$K8S_VERSION kubeadm=$K8S_VERSION kubectl=$K8S_VERSION

# Prefetch the k8s images we need to run kubeadm
kubeadm config images pull

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

# ROLLERSK8S
The official guide to creating your own pony cluster

# Useful commands
* Find the master nodes: `kubectl get nodes -l node-role.kubernetes.io/master=`
* Drain a node: `kubectl drain <NODE>`
* Reschedule a node: `kubectl uncordon <NODE>`
* Get the cluster token: `kubeadm token list | sed -n 2p | cut -d" " -f1`
* Join node to cluster: `kubeadm join --token <TOKEN> <MASTERHOSTNAME>:6443`
* What version of etcd am I running on the master? `curl -L http://127.0.0.1:2379/version`

# Backup etcd
```
mkdir -p /tmp/deathstar/Backups/mlp/etcd/2017.09.20
etcdctl backup \
      --data-dir /var/lib/etcd/ \
      --backup-dir /tmp/deathstar/Backups/mlp/etcd/2017.09.20
mkdir -p /deathstar/Backups/mlp/etcd/
mv /tmp/deathstar/Backups/mlp/etcd/2017.09.20 /deathstar/Backups/mlp/etcd/
```

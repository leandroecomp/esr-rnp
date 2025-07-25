#!/usr/bin/env bash

CONTAINERD_VERSION="1.6.20-1"
DOCKER_VERSION="5:23.0.5-1~debian.$(cat /etc/debian_version | cut -d'.' -f1)~$(lsb_release -cs)"
K8S_VERSION="1.27.1-00"

MYIFACE="eth1"
MYIP="$( ip -4 addr show ${MYIFACE} | grep -oP '(?<=inet\s)\d+(\.\d+){3}' )"

PLABS_PROXY="192.168.255.13"
PLABS_PORT="8080"


# # #


setproxy() {
cat << EOF > /etc/profile.d/proxy.sh
export http_proxy="http://${PLABS_PROXY}:${PLABS_PORT}/"
export HTTP_PROXY="http://${PLABS_PROXY}:${PLABS_PORT}/"
export https_proxy="http://${PLABS_PROXY}:${PLABS_PORT}/"
export HTTPS_PROXY="http://${PLABS_PROXY}:${PLABS_PORT}/"
export ftp_proxy="http://${PLABS_PROXY}:${PLABS_PORT}/"
export FTP_PROXY="http://${PLABS_PROXY}:${PLABS_PORT}/"
export no_proxy="127.0.0.1,localhost,192.168.68.20,192.168.68.25"
export NO_PROXY="127.0.0.1,localhost,192.168.68.20,192.168.68.25"
EOF
chmod +x /etc/profile.d/proxy.sh

cat << EOF > ~/.wgetrc
use_proxy = on
http_proxy = http://${PLABS_PROXY}:${PLABS_PORT}/
https_proxy = http://${PLABS_PROXY}:${PLABS_PORT}/
ftp_proxy = http://${PLABS_PROXY}:${PLABS_PORT}/
EOF

cat << EOF > /etc/apt/apt.conf.d/99proxy
Acquire::http::proxy "http://${PLABS_PROXY}:${PLABS_PORT}/";
Acquire::https::proxy "http://${PLABS_PROXY}:${PLABS_PORT}/";
Acquire::ftp::proxy "ftp://${PLABS_PROXY}:${PLABS_PORT}/";
EOF

mkdir -p /root/.docker
cat << EOF > /root/.docker/config.json
{
 "proxies": {
   "default":   {
     "httpProxy": "http://${PLABS_PROXY}:${PLABS_PORT}/",
     "httpsProxy": "http://${PLABS_PROXY}:${PLABS_PORT}/",
     "ftpProxy": "http://${PLABS_PROXY}:${PLABS_PORT}/",
     "noProxy": "localhost,127.0.0.0/8,192.168.68.0/24"
   }
 }
}
EOF
}


# # #


# Configure proxy if running on PracticeLabs
if nc -w3 -z ${PLABS_PROXY} ${PLABS_PORT}; then
  setproxy
fi

# Basic package installation
apt update
apt install -y vim dos2unix jq w3m
cat << EOF > /root/.vimrc
set nomodeline
set bg=dark
set tabstop=2
set expandtab
set ruler
set nu
syntax on
EOF
find /usr/local/bin -name lab-* | xargs dos2unix

# Prepare SSH inter-VM communication
mv /home/vagrant/ssh/* /home/vagrant/.ssh
rm -r /home/vagrant/ssh
dos2unix /home/vagrant/.ssh/tmpkey
dos2unix /home/vagrant/.ssh/tmpkey.pub
cat /home/vagrant/.ssh/tmpkey.pub >> /home/vagrant/.ssh/authorized_keys
cat << EOF >> /home/vagrant/.ssh/config
Host s2-*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF
chown vagrant. /home/vagrant/.ssh/config
chmod 600 /home/vagrant/.ssh/config /home/vagrant/.ssh/tmpkey

# Setup /etc/hosts
cat << EOF >> /etc/hosts
192.168.68.20 s2-master-1
192.168.68.25 s2-node-1
EOF

# Install Docker
apt install -y apt-transport-https \
               ca-certificates     \
               curl                \
               gnupg               \
               lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y containerd.io \
               docker-ce \
               docker-ce-cli
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "log-opts": {
    "max-size": "100m"
  }
}
EOF

# Enable and configure required modules
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# install cri-dockerd
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.18/cri-dockerd_0.3.18.3-0.debian-bullseye_amd64.deb
apt install -y ./cri-dockerd_0.3.18.3-0.debian-bullseye_amd64.deb

mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

# Enable bridged traffic through iptables
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

# Configure containerd
mkdir -p /etc/containerd
containerd config default | \
  sed 's/^\([[:space:]]*SystemdCgroup = \).*/\1true/' | \
  tee /etc/containerd/config.toml

# Disable swap
swapoff -a
sed -i 's/^\(.*vg-swap.*\)/#\1/' /etc/fstab

# Install kubeadm and friends
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
#apt upgrade -y
# apt install -y kubelet=${K8S_VERSION} \
#               kubeadm=${K8S_VERSION} \
#               kubectl=${K8S_VERSION}

apt install -y kubelet \
              kubeadm \
              kubectl

apt-mark hold kubelet \
              kubeadm \
              kubectl

# Set correct IP address for kubelet, also use cri-dockerd
echo "KUBELET_EXTRA_ARGS=\"--node-ip=${MYIP} --container-runtime-endpoint=unix:///var/run/cri-dockerd.sock\"" >> /etc/default/kubelet
systemctl restart kubelet

# Configure kubectl autocompletion
kubectl completion bash > /etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

if [ "$1" == "master" ]; then
  # Initialize cluster
  kubeadm config images pull --cri-socket unix:///var/run/cri-dockerd.sock
  kubeadm init --apiserver-advertise-address=${MYIP} \
    --apiserver-cert-extra-sans=${MYIP} \
    --cri-socket unix:///var/run/cri-dockerd.sock \
    --node-name="$( hostname )" \
    --pod-network-cidr=10.32.0.0/12 \
    --ignore-preflight-errors="all"

  # Configure kubectl
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config

  # Install Calico CNI plugin
  # kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.2/manifests/calico.yaml
  kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml


  # Create kubeadm join token
  join_command="$( kubeadm token create --print-join-command )"
  echo "${join_command} --cri-socket unix:///var/run/cri-dockerd.sock" > /opt/join_token

  # Copy exercise scripts, set permissions
  mv /home/vagrant/scripts/* /usr/local/bin
  rm -r /home/vagrant/scripts
  chown root. /usr/local/bin/*
  chmod +x /usr/local/bin/*
else
  # Copy join token and enter cluster
  sudo -u vagrant scp -i /home/vagrant/.ssh/tmpkey vagrant@s2-master-1:/opt/join_token /tmp
  echo -n " --cri-socket unix:///var/run/cri-dockerd.sock" >> /tmp/join_token
  sh /tmp/join_token
  rm -f /tmp/join_token
fi

#!/bin/bash
sudo apt update -y 
# 1. Disable Swap
swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab


# 2. Set Up IPV4 Bridge
sudo bash -c 'cat <<EOL > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOL'

sudo modprobe overlay
sudo modprobe br_netfilter

# 3. Create Private Key
echo '' > /home/ubuntu/test.pem #insert master private file
chmod 400 /home/ubuntu/test.pem
sudo chown ubuntu:ubuntu /home/ubuntu/test.pem

# 3. Set Up Sysctl Configurations
sudo bash -c 'cat <<EOL > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOL'

sudo sysctl --system

# 4. Install Kubernetes Components
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir /etc/apt/keyrings
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update -y
sudo apt install -y kubeadm kubelet kubectl
sudo apt-mark hold kubeadm kubelet kubectl

# 5. Install Docker
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl enable docker


# 6. Configure Containerd
sudo mkdir -p /etc/containerd
if [ ! -f /etc/containerd/config.toml ]; then
  sudo containerd config default | sudo tee /etc/containerd/config.toml
fi

# Update the SystemdCgroup setting
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart services
sudo systemctl restart containerd.service
sudo systemctl restart kubelet.service
sudo systemctl enable kubelet.service



# 7. Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Get the token and CA cert hash
TOKEN=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/test.pem ubuntu@10.0.2.5 "sudo kubeadm token list | awk 'NR>1 {print \$1}'")
HASH=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/test.pem ubuntu@10.0.2.5 "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'")

# Join the cluster
sudo kubeadm join 10.0.2.5:6443 --token $TOKEN --discovery-token-ca-cert-hash sha256:$HASH


echo "Worker node and monitoring setup complete!"
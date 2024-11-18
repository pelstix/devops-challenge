#!/bin/bash
sudo apt update -y
# 1. Disable Swap
swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 2. Set Hostname
sudo hostnamectl set-hostname "master-node"

# 3. Create Private Key
echo '' > /home/ubuntu/bastion-key.pem #insert bastion host pem file
chmod 400 /home/ubuntu/bastion-key.pem
sudo chown ubuntu:ubuntu /home/ubuntu/bastion-key.pem

# 4. Set Up IPV4 Bridge
sudo bash -c 'cat <<EOL > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOL'

sudo modprobe overlay
sudo modprobe br_netfilter

# 5. Set Up Sysctl Configurations
sudo bash -c 'cat <<EOL > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOL'


sudo sysctl --system


# 5. Install Kubernetes Components
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update -y
sudo apt install -y kubeadm kubelet kubectl
sudo apt-mark hold kubeadm kubelet kubectl

# 6. Install Docker
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl enable docker


# 7. Configure Containerd
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


# 8. Initialize Kubernetes Cluster
sudo kubeadm config images pull
sudo kubeadm init --pod-network-cidr=10.10.0.0/16

# Set up kubeconfig for kubectl
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


#9. Configure Calico Network Plugin
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml
kubectl create -f custom-resources.yaml



# 10. Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 11. Add Helm repositories for Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 12. Create a namespace for monitoring
kubectl create namespace monitoring

# 13. Install Prometheus
helm install prometheus prometheus-community/prometheus --namespace monitoring

# 14. Install Grafana
helm install grafana grafana/grafana --namespace monitoring

# 15. Optional: Install Loki and Promtail for logs
helm install loki grafana/loki-stack --namespace monitoring


cat <<EOL | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 3000
    nodePort: 30080 # You can specify a custom NodePort or let Kubernetes assign one
  selector:
    app.kubernetes.io/name: grafana
EOL

kubectl create ns bird-apps

echo "Master node and monitoring setup complete!"

# Remove the old kubeconfig from the Bastion host
ssh -i /home/ubuntu/bastion-key.pem -o StrictHostKeyChecking=no ubuntu@10.0.1.5 "rm -f /home/ubuntu/.kube/config" && \
# Copy kubeconfig to Bastion host
sudo scp -i /home/ubuntu/bastion-key.pem -o StrictHostKeyChecking=no /etc/kubernetes/admin.conf ubuntu@10.0.1.5:/home/ubuntu/.kube/config


#restart coredns deployment
(sleep 300 && kubectl rollout restart deployment coredns -n kube-system) &



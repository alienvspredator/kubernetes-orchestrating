sudo apt-get update && sudo apt-get install curl

# Add zsh
echo "Installing zsh..."
sudo apt-get update && sudo apt-get install zsh -y
sudo chsh -s /bin/zsh vagrant

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# OMZ Theme
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc

echo "Installing Docker..."
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io
echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
sudo apt-get install apt-transport-https ca-certificates software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"
sudo apt-get update
sudo apt-get install -y docker-ce
# Restart docker to make sure we get the latest version of the daemon if there is an upgrade
sudo service docker restart
# Make sure we can actually use docker as the vagrant user
sudo usermod -aG docker vagrant
sudo docker --version
sudo curl -sSL "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

for bin in cfssl cfssl-certinfo cfssljson; do
	echo "Installing $bin..."
	curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 >/tmp/${bin}
	sudo install /tmp/${bin} /usr/local/bin/${bin}
done

# TMux Configuration
echo "Configuring tmux..."
(
	cat <<-EOF
		set-option -g mouse on
		set-option -g set-titles on
		set-option -g set-titles-string '#T'

		# Toggle mouse on
		bind-key M \\
		  set-option -g mouse on \\;\\
		  display-message 'Mouse: ON'

		# Toggle mouse off
		bind-key m \\
		  set-option -g mouse off \\;\\
		  display-message 'Mouse: OFF'
	EOF
) | tee ~/.tmux.conf

echo "Installing cni plugins..."
curl -sSL -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
rm cni-plugins.tgz

echo "Installing Helm, Minikube and kubectl..."
grep -E --color 'vmx|svm' /proc/cpuinfo
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
curl -sSLo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 &&
	chmod +x minikube
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/
rm minikube
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

# dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.4/aio/deploy/recommended.yaml

# Kubectl and Minikube autocompletion
(
	cat <<-EOF

		# kubernetes and helm completion
		source <(kubectl completion zsh)
		source <(minikube completion zsh)
		source <(kubeadm completion zsh)
		source <(helm completion zsh)
	EOF
) | tee -a ~/.zshrc

sudo snap install microk8s --classic

# OMZ plugins
sed -i 's/plugins=(git)/plugins=(ubuntu git kubectl minikube microk8s docker-compose docker)/g' ~/.zshrc

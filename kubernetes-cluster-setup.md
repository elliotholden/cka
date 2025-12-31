# Kubernetes Cluster Setup

## Introduction
To get a good working cluster setup for practicing, testing, or studying for the CKA exam you will need to provision **3 nodes** that all exsist on the same physical network. The examples below were done using Google Cloud. To get started you need to create a NEW Google Cloud account. As of November 2025 Google is offering $300 worth of compute credit for FREE for 3 months. You can use an existing Google account if you have "Never" activated Google's "Cloud" service on that Google account before.

## Provision Nodes
#### Node Requirments:
2 CPU</br>
2 GiB Memory</br>
Ubuntu 22.04 or higher</br>

1. Create a Project named __CKA Lab__ ([Instructions Here](https://docs.cloud.google.com/appengine/docs/standard/nodejs/building-app/creating-project))<br />
        a. If prompted Enable the Compute API
2. From the web console, provision 1 control node and 2 worker nodes with the following specs:<br />
    - **Instance names:** control-1 / worker-1 / worker-2
    - **Region:** us-east1 (South Carolina)
    - **Zone:** Any
    - **Instance type:** e2-small
    - **OS:** Ubuntu 24.04 LTS *(use the same OS version for all nodes)*
    - **Disk:** SSD persistent disk / 20GB
    - **Data protection:** No backups
    - **Hostnames:** control1.cka, worker1.cka, worker2.cka
    - **IP Forwarding:** Enabled
3. Make sure IP Forwarding was __enabled__ when initially provisioning the node in the Google Cloud web console.
4. Repeat steps 1 - 3 for the remaining nodes (worker-1, worker-2)

## Enable IP Forwarding (from within the OS)
1. Enable IP forwarding on *each* __node__ from within the OS by doing the following from the command line:

   - The following __systctl__ kernel paremeters need to be set to __1__:

        net.ipv4.ip_forward = 1<br />
        net.ipv6.conf.all.forwarding = 1<br />
        net.bridge.bridge-nf-call-iptables = 1<br />
        net.bridge.bridge-nf-call-ip6tables = 1<br />

    - Run the following command to check:

          sudo sysctl -a | grep -Ew 'net.ipv4.ip_forward|net.bridge.bridge-nf-call-iptables|net.ipv6.conf.all.forwarding|net.bridge.bridge-nf-call-ip6tables'

        >There is a possibility you may not see __net.bridge.bridge-nf-call-iptables__ *and* __net.bridge.bridge-nf-call-ip6tables__ when running the __sysctl -a__ command.

    - If any of those parameters are not set to __1__ then create a file named __99-kubernetes-cri.conf__ inside the /etc/sysctl.d directory and add them. The name of the file does not really matter as long as it ends in __.conf__
        
          sudo vi /etc/sysctl.d/99-kubernetes-cri.conf 

    - Activate the newly created systctl configuration

          sudo sysctl -p /etc/sysctl.d/99-kubernetes-cri.conf

    - Check to make sure the settings have been saved:

          sudo sysctl -a | grep -Ew 'net.ipv4.ip_forward|net.bridge.bridge-nf-call-iptables|net.ipv6.conf.all.forwarding|net.bridge.bridge-nf-call-ip6tables'

**NOTE:** *Make sure to repeat the IP forwarding steps on the __worker-1__ and __worker-2__ nodes.*

## Install containerd and kube tools (kubeadm, kubectl, kubelet)
__NOTE:__ The following steps for installing __containerd__ and __kubetools__ are to be done on ALL nodes (control and workers). There are 2 different options for each installation procedure. The first option leverages scripts written by [Sander van Vugt](https://github.com/sandervanvugt/cka). The second option is the more manual approace that you really SHOULD learn anyway.

### Containerd

#### OPTION 1 - Super EASY - using [Sander van Vugt](https://github.com/sandervanvugt/cka) scripts

1. Create the directory __~/repos__ and cd into it. Clone the Sander van Vugt CKA repo:

        git clone git@github.com:sandervanvugt/cka

2. Install __containerd__ by running the ./setup-container.sh script.

        ~/repos/cka/setup-container.sh

3. Verfiy __containerd__ is running:

        systemctl status containerd

#### OPTION 2 - Manual install using the [Getting Started](https://github.com/containerd/containerd/blob/main/docs/getting-started.md) docs from the Containerd github repo.

1. Follow the [Getting Started](https://github.com/containerd/containerd/blob/main/docs/getting-started.md) documentation to install [__containerd__](https://github.com/containerd/containerd/releases)
2. Follow the [Getting Started](https://github.com/containerd/containerd/blob/main/docs/getting-started.md) documentation to install [__runc__](https://github.com/opencontainers/runc/releases)
3. Follow the [Getting Started](https://github.com/containerd/containerd/blob/main/docs/getting-started.md) documentaion to install [__CNI plugins__](https://github.com/containernetworking/plugins/releases)
4. Verify containerd is running.

### Kubernetes - kubetools
#### OPTION 1 - Super EASY - using [Sander van Vugt](https://github.com/sandervanvugt/cka) scripts
1. Assuming you've already clone the __cka__ repo from Sander van Vugt github - Install the kube tools (kubeadm, kubectl, kubelet) by running the __setup-kubetools.sh__ script.

        ~/repos/cka/setup-kubetools.sh

2. Verify __kubeadm__, __kubectl__, and __kubelet__ are installed and that the kubelet service is running:

        which kubeadm kubectl kubelet

        systemctl status kubelet

5. __Note:__ *make sure the version of all tools are the same.*

        kubectl version
        kubeadm version
        kubelet --version

#### OPTION 2 - Manual install using k8s repos
These instructions are for Kubernetes v1.34. taken from [Kubernetes.io](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
1.  Update the apt package index and install packages needed to use the Kubernetes apt repository:

       > apt-transport-https may be a dummy package; if so, you can skip that package


        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl gpg

2. Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL:

    > If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.

    >sudo mkdir -p -m 755 /etc/apt/keyrings

       curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

      >Note: In releases older than Debian 12 and Ubuntu 22.04, directory /etc/apt/keyrings does not exist by default, and it should be created before the curl command.

3. Add the appropriate Kubernetes apt repository. Please note that this repository have packages only for Kubernetes 1.34; for other Kubernetes minor versions, you need to change the Kubernetes minor version in the URL to match your desired minor version (you should also check that you are reading the documentation for the version of Kubernetes that you plan to install).

      This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list

       echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

      Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:

       sudo apt-get update
       sudo apt-get install -y kubelet kubeadm kubectl
       sudo apt-mark hold kubelet kubeadm kubectl

      (Optional) Enable the kubelet service before running kubeadm:

       sudo systemctl enable --now kubelet


*The kubelet may not actually be running until the a cluster has been initialized on the Control Node (or in the case of the worker nodes, if they've actually joined a cluster)*

## Initialize Cluster

1. Run __kubeadm init__ ONLY on the __control__ node<br/>
   >If you run __kubeadm init__ on any other nodes then you will end up with *multiple* clusters instead of just *one*.

        sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --apiserver-cert-extra-sans control-1.elliotmywebguy.com c1.elliotmywebguy.com control.elliotmywebguy.com

2. To start using your cluster, you need to run the following as a regular user:

        mkdir -p $HOME/.kube

        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

3. Test access to your cluster:

        kubectl get nodes -o wide

## Install Networking Plugin
You can find the installation insructions for Calico on the [Tigera](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart ) website

1. Install the Calico netowrk plugin by running the following 2 commands:

       kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/tigera-operator.yaml

       kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/custom-resources.yaml

## Initialize Worker Nodes 

__NOTE:__ If you need to regenerate tokens for joining worker nodes to the cluster run the following on the *control* node:

        kubeadm token create --print-join-command

1. The following *join* command needs to be done on the __worker__ nodes. Change the IP address to the IP address of *your* API server. The __--token__ and __--discovery-token-ca-cert-hash__ should be relative to your cluster as well. The folloiwng is just an example and should not be used literally.

        kubeadm join 10.142.0.2:6443 --token m01jry.1bz7ntr2bgof59gm --discovery-token-ca-cert-hash sha256:1ae716d8075436f064b9f7f336bbdb8660557812cbb1e00b33dcc9c9036e70cf

2. If you want to use __kubectl__ on the worker nodes, then you will need to create  a __.kube__ directory in your ~ home directory on the worker node and copy the /etc/kubernetes/__admin.conf__ file from the __control__ node to __~/.kube/config__ on the worker node.
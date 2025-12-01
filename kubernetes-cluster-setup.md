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
__NOTE:__ The following steps (installing kubetools) to be done on ALL nodes (control and workers). These steps leverage scripts written by Sander van Vugt.

### Containerd

1. Create the directory __~/repos__ and cd into it. Clone the Sander van Vugt CKA repo:

        git clone git@github.com:sandervanvugt/cka

2. Install __containerd__ by running the ./setup-container.sh script.

        ~/repos/cka/setup-container.sh

    Verfiy __containerd__ is running:

        systemctl status containerd

### Kubernetes
3. Install the kube tools (kubeadm, kubectl, kubelet) by running the __setup-kubetools.sh__ script.

        ~/repos/cka/setup-kubetools.sh

4. Verify __kubeadm__, __kubectl__, and __kubelet__ are installed and that the kubelet service is running:

        which kubeadm kubectl kubelet

        systemctl status kubelet

5. __Note:__ *make sure the version of all tools are the same.*

        kubectl version
        kubeadm version
        kubelet --version

*The kubelet may not actually be running until the a cluster has been initialized on the Control Node (or in the case of the worker nodes, if they've actually joined a cluster)*

## Initialize Cluster

1. Run __kubeadm init__ ONLY on the __control__ node<br/>
   >If you run __kubeadm init__ on any other nodes then you will end up with *multiple* clusters instead of just *one*.

2. To start using your cluster, you need to run the following as a regular user:

        mkdir -p $HOME/.kube

        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

3. Test access to your cluster:

        kubectl get nodes -o wide

## Install Networking Plugin
You can find the differenct releases for Calico here: https://github.com/projectcalico/calico/releases

1. Install the calico netowrk plugin by running the following:

        kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.5/manifests/calico.yaml

## Initialize Worker Nodes 

__NOTE:__ If you need to regenerate tokens for joining worker nodes to the cluster run the following on the *control* node:

        kubeadm token create --print-join-command

1. Change the IP address to the IP address of *your* API server. The __--token__ and __--discovery-token-ca-cert-hash__ should be relative to your cluster as well. The folloiwng is just an example and should not be used literally.

        kubeadm join 10.142.0.2:6443 --token m01jry.1bz7ntr2bgof59gm --discovery-token-ca-cert-hash sha256:1ae716d8075436f064b9f7f336bbdb8660557812cbb1e00b33dcc9c9036e70cf
        kubeadm token create --print-join-command

2. If you want to use __kubectl__ on the worker nodes, then you will need to create  a __.kube__ directory in your ~ home directory on the worker node and copy the /etc/kubernetes/__admin.conf__ file from the __control__ node to __~/.kube/config__ on the worker node.
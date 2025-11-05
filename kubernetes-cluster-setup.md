# Kubernetes Cluster Setup

## Provision Nodes
To get a good working cluster setup for practicing, testing, or studying for an exam (CKA, CKAD, CKS etc.) would will need to provision 3 nodes that all exsist on the same physical network. The examples below were done using Google Cloud. To get started you need to create a NEW Google Cloud account. As of November 2025 Google is offering $300 worth of compute credit for FREE for 3 months.

#### Node Requirments:
2 CPU</br>
2 GiB Memory</br>
Ubuntu 22.04 or higher</br>

1. From the Google Cloud Web Console provision 1 control node and 2 worker nodes with the following specs: **2 CPU / 2 GiB memory / Ubuntu 22.04 or higher**
2. Enable IP Forwarding when initially provisioning the node in the Google Cloud web console.
3. Enable IP forwarding from within the OS as well by doing the following:
    - Create a file name __99-kubernetes-cri.conf__ inside the /etc/sysctl.d directory.
        
        > sudo vi /etc/sysctl.d/__99-kubernetes-cri.conf__ 
        > sudo vi /etc/sysctl.d/__99-kubernetes-cri.conf__ 
    - Add the following to the file you just created:

            net.ipv4.ip_forward = 1
            net.ipv4.ip_forward = 1

            net.ipv6.conf.all.forwarding = 1
            net.ipv6.conf.all.forwarding = 1

    - Activate the newly created systctl configuration

        > sudo sysctl -p /etc/sysctl.d/99-kubernetes-cri.conf

    - Check to make sure the settings have been saved:
        >sudo sysctl -a | grep -E 'net.ipv4.ip_forward | net.ipv6.conf.all.forwarding'

## Install containerd and kube tools (kubeadm, kubectl, kubelet)
4. Create the directory __~/repos__ and cd into it. Clone the Sander van Vugt CKA repo:
    >git clone git@github.com:sandervanvugt/cka
5. Install __containerd__ by running the ./setup-container.sh script.
    >~/repos/cka/set-container.sh

    Verfiy __containerd__ is running:
    >systemctl status containerd

6. Install the kube tools (kubeadm, kubectl, kubelet) by running the __setup-kubetools.sh__ script.
    >~/.repos/cka/set-kubetools.sh

    Verify __kubeadm__, __kubectl__, and __kubelet__ are installed:
     >which kubeadm kubectl kubelet

   *The kubelet may not actually be running until the a cluster has been initialized on the Control Node (or for the Worker Nodes, if they've actually joing a cluster)*

    >systemctl status kubelet
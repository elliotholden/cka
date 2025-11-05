# Kubernetes Cluster Setup

## Introduction
To get a good working cluster setup for practicing, testing, or studying for the CKA exam you will need to provision **3 nodes** that all exsist on the same physical network. The examples below were done using Google Cloud. To get started you need to create a NEW Google Cloud account. As of November 2025 Google is offering $300 worth of compute credit for FREE for 3 months. You can use an existing Google account if you have "Never" activated Google's "Cloud" servervice on that Google account before. Instructions for determining whether you have every activated the Google "Cloud" service on your existing Google account can be found __<here\>__.

## Provision Nodes
#### Node Requirments:
2 CPU</br>
2 GiB Memory</br>
Ubuntu 22.04 or higher</br>

1. Create a Project named __CKA Lab__ ([Instructions Here](https://cloud.google.com/distributed-cloud/sandbox/latest/create-project?_gl=1*jyiq3z*_up*MQ..&gclid=Cj0KCQiAiKzIBhCOARIsAKpKLAP8Km_yi7WhS-AcbVFpX32gpJ4Y72krgd_Yu7q4fSnYktEFQiTRSHoaAqzhEALw_wcB&gclsrc=aw.ds))
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
4. Enable IP forwarding from within the OS as well by doing the following from the command line:
    - Create a file name __99-kubernetes-cri.conf__ inside the /etc/sysctl.d directory.
        
        > sudo vi /etc/sysctl.d/__99-kubernetes-cri.conf__ 

    - Add the following to the file you just created:

            net.ipv4.ip_forward = 1
            net.ipv6.conf.all.forwarding = 1

    - Activate the newly created systctl configuration

        > sudo sysctl -p /etc/sysctl.d/99-kubernetes-cri.conf

    - Check to make sure the settings have been saved:

        >sudo sysctl -a | grep -wE 'net.ipv4.ip_forward|net.ipv6.conf.all.forwarding'

## Install containerd and kube tools (kubeadm, kubectl, kubelet)
4. Create the directory __~/repos__ and cd into it. Clone the Sander van Vugt CKA repo:

    > git clone git@github.com:sandervanvugt/cka

5. Install __containerd__ by running the ./setup-container.sh script.

    > ~/repos/cka/setup-container.sh

    Verfiy __containerd__ is running:

    >systemctl status containerd

6. Install the kube tools (kubeadm, kubectl, kubelet) by running the __setup-kubetools.sh__ script.

    > ~/repos/cka/setup-kubetools.sh

    Verify __kubeadm__, __kubectl__, and __kubelet__ are installed:

    > which kubeadm kubectl kubelet

*The kubelet may not actually be running until the a cluster has been initialized on the Control Node (or in the case of the worker nodes, if they've actually joined a cluster)*

    > systemctl status kubelet
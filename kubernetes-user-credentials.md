# How to Create Kubernetes Credentials

## Introdction

In the is lab we will learn how to creating credentials to authenticate with a Kubernetes cluster. We will start with generating a private key, then creating a CSR and finally siging the CSR which in the process will create the CERT. All of these steps will be done using the __openssl__ command.


1. In the example below we generate Private Key file named "tobin.key"

        openssl genrsa -out tobin.key 2048

2. Next we generate the Certificate Signing Request (CSR) with few "subeject alternative names" (SANs). The SANs are used to define what names this certificate will be allowed to use when contacting the k8s api server.

        openssl req -new -key tobin.key --subj "/CN=tobin/O=k8s" -addext "subjectAltName=DNS:example.com,DNS:www.example.com,IP:10.0.0.1" -out tobin.csr

3. Finally we sign the csr and generate the certificate. This step will need access to the private key and certificate of the Kubernetes Certificate Authority (CA). These files will typically reside on the Kubernetes control node in the following the directory: ___/etc/kubernetes/pki___. The following command will create a cert that is valid for 30 days.

        sudo opensll x509 -req -in tobin.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out tobin.crt -days 30
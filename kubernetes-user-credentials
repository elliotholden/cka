# How to Create Kubernetes Credentials

## Introdction

Creating credentials to authenticate with a Kubernetes cluster starts with generated and private key

Generate Private Key 

    openssl genrsa -out tobin.key 2048

Generate CSR

    openssl req -new -key tobin.key --subj "/CN=tobin/O=k8s" -addext "subjectAltName=DNS:example.com,DNS:www.example.com,IP:10.0.0.1" -out tobin.csr
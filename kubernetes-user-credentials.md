# How to Create Kubernetes Credentials

## Introdction

In the is lab we will learn how to creating credentials to authenticate with a Kubernetes cluster. We will start with generating a private key, then creating a CSR and finally siging the CSR which is the process will create the CERT. All of these steps will be done using the __openssl__ command.

### Key Terms
__SANs__ - Subject Alternative Names<br />
__CSR__ - Certficate Signing Request

## Create client cert for authentication with Kubernetes
1. In the example below we generate a Private Key file named "tobin.key"

        openssl genrsa -out tobin.key 2048

2. Next we generate the Certificate Signing Request (CSR)

        openssl req -new -key tobin.key --subj "/CN=tobin/O=k8s" -out tobin.csr

3. Finally we sign the csr and generate the certificate. This step will need access to the private key and certificate of the Kubernetes Certificate Authority (CA). These files will typically reside on the Kubernetes control node in the following the directory: ___/etc/kubernetes/pki___. The following command will create a cert that is valid for 30 days.

        sudo opensll x509 -req -in tobin.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out tobin.crt -days 30

## Client Certificate and Server Certificate differences:

Both the __client certificate__ (used in _.kube/config_) and the __server certficated__ (located on the controlplane node in _/etc/kubernetes/pki/apiserver.crt_) use the same X.509 format, but with different extensions and purposes. The API server cert needs __SANs__ for hostname validation, while user certs use __CN__ for identity (SANs ignored). This is standard TLS client/server certificate separation, not Kubernetes-specific.

### API Server Certificate (apiserver.crt):
- Type: Server certificate
- Purpose: Identifies the server (Kubernetes API)
- SANs: REQUIRED for TLS validation
- CN: Mostly ignored (deprecated for servers)
- Location: On API server node, presented during TLS handshake
- Used for: Clients verifying they're talking to the real API server

### User/Client Certificate (in .kube/config):
- Type: Client certificate
- Purpose: Identifies the user/client
- SANs: Optional (and ignored for Kubernetes auth)
- CN: USED as username for RBAC
- O fields: Used as group membership
- Location: In client's kubeconfig, sent during TLS handshake
- Used for: API server verifying user identity


### Visual comparison:
    X.509 Certificate Template:

    ├── Version
    ├── Serial Number
    ├── Signature Algorithm
    ├── Issuer (CA info)
    ├── Validity Period
    ├── Subject:
    │   ├── CN (Common Name)          ← Used differently!
    │   └── O (Organization)          ← Used differently!
    ├── Subject Public Key Info
    ├── X509v3 Extensions:
    │   ├── Subject Alternative Name  ← Used differently!
    │   ├── Key Usage                 ← Different flags!
    │   └── Extended Key Usage        ← Different purposes!
    └── Signature (CA's signature)

### Check the differences:

    # API Server cert:
    openssl x509 -in apiserver.crt -noout -text | grep -i "key usage"
    # Key Usage: Digital Signature, Key Encipherment
    # Extended Key Usage: TLS Web Server Authentication

    # User cert:
    openssl x509 -in user.crt -noout -text | grep -i "key usage"  
    # Key Usage: Digital Signature, Key Encipherment
    # Extended Key Usage: TLS Web Client Authentication


## SANs

### How to see what SANs your API server is configured for:
The Subject Alternative Names are the names that your Kubernetes API server can be accessed by.

#### On control plane node
    sudo openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text | grep -A1 "Subject Alternative Name"

#### Or from anywhere with kubectl access
    openssl s_client -connect <API_SERVER_IP>:6443 -showcerts 2>/dev/null | openssl x509 -noout -text | grep -A1 "Subject Alternative Name"

### Skip TLS verify

If you get an error similar to the follwing:

 >"Unhandled Error" err="couldn't get current server API group list: Get \"https://34.74.64.149:6443/api?timeout=32s\": tls: failed to verify certificate: x509: certificate is valid for 10.96.0.1, 10.142.0.2, not 34.74.64.149"

You can skip the TLS verification step, thus being able to acces your cluster by any __server:__ 'name' in your .kube/config file.

    kubectl -n kube-system --insecure-skip-tls-verify=true get pods

<br /><br />
## Differences between ca.crt and apiserver.crt
__/etc/kubernetes/pki/ca.crt__ <br />
__/etc/kubernetes/pki/apiserver.crt__

### What does the certificate-authority-data in .kube/config refer to?

#### 1. certificate-authority-data in kubeconfig
- This is the CA certificate (ca.crt)
- Used to verify the API server's certificate
- Location: /etc/kubernetes/pki/ca.crt
- Contains: Public key of the cluster CA

#### 2. API Server's certificate (apiserver.crt)
- This is the server certificate signed by the CA
- Presented by the API server during TLS handshake
- Location: /etc/kubernetes/pki/apiserver.crt
- Contains: SANs for all valid access points

### Certificate files in /etc/kubernetes/pki/:
    /etc/kubernetes/pki/
    ├── ca.crt           ← THIS goes in kubeconfig as certificate-authority-data
    ├── ca.key           ← PRIVATE - never leaves control plane
    ├── apiserver.crt    ← Presented by API server (has SANs)
    ├── apiserver.key    ← PRIVATE - API server's private key
    ├── apiserver-kubelet-client.crt
    └── ... other certs

### Visual relationship:
    Cluster CA (ca.crt)  [PUBLIC - in kubeconfig]
        │
        └── Signs ──→ API Server Certificate (apiserver.crt)  [PRIVATE - on server]
                        │
                        ├── SAN: DNS:kubernetes
                        ├── SAN: DNS:kubernetes.default
                        ├── SAN: IP:10.96.0.1
                        └── SAN: IP:<PUBLIC_IP>

### How TLS handshake works:
    Client (kubectl)                         API Server
        │                                       │
        │───1. "Hello"─────────────────────────>│
        │<──2. "Here's my cert (apiserver.crt)"─│
        │                                       │
        │ 3. Client checks:                     │
        │    - Is cert signed by trusted CA?    │
        │    - (Uses ca.crt from kubeconfig)    │
        │    - Do SANs match server address?    │
        │                                       │
        │───4. Encrypted session───────────────>│
# How to Create Kubernetes Credentials

## Introdction

In the is lab we will learn how to create client credentials to authenticate with a Kubernetes cluster. We will start with generating a private key, then create a CSR, and finally sign the CSR (which in the process will create the actual CERT). All of these steps will be done using the __openssl__ command.

### Key Terms
- __SANs__ - Subject Alternative Names<br>
- __CSR__ - Certficate Signing Request<br>
- __CN__ - Common Name

<br>

## Create a Client Cert for Authentication with Kubernetes
1. First we generate a Private Key file named "tobin.key"

        openssl genrsa -out tobin.key 2048

2. Next we generate the Certificate Signing Request (CSR)

       openssl req -new -key tobin.key --subj "/CN=tobin/O=k8s" -out tobin.csr

3. Finally we sign the csr and generate the certificate. This step will need access to the private key and certificate of the Kubernetes Certificate Authority (CA). These files will typically reside on the Kubernetes control node in the following the directory: ___/etc/kubernetes/pki___. The following command will create a cert that is valid for 30 days.

       sudo opensll x509 -req -in tobin.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out tobin.crt -days 30
<br>

>__IMPORTANT NOTES:__ The __private key__ and __csr__ could and "probably" should be created by the end user who is going to use the __cert__ and __private key__ in _their_ .kube/config file. They would then submit the __csr__ to the Kubernetes admin for signing and cert generation. The Kubernetes admin whould then deliver the __cert__ to the end user. Best practice would suggest that the end user NOT share their __private key__ with anyone. The end user would then add their __private key__ and __cert__ (that they received from the Kubernetes admin) to their ~/.kube/config file.

<br>

## Use a Client Cert in a Kube Config File 

To use a client __cert__ and __private key__ in a kube config file (for example: ~/.kube/config) you have 2 options: You can use either __A.__ the __client-certificate__ and __client-key__ fields or __B.__ the __client-certificate-data__ and __client-key-data__ fields in the kube config file. The _data_ fields are expecting a __base64__ string of your __cert__ and __private key__ while the _NON-data_ fields are expecting the location path of the actual __cert__ and __private key__ files.

### EXAMPLES

__client-certificate-data__ and __client-key-data__

    users:
    - name: tobin
        user:
        client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN1akNDQWFJQ0ZCME... 
        client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2QUlCQURBTkJna3...

__client-certificate__ and __client-key__

    users:
    - name: tobin 
    user:
        client-certificate: /Users/emwg/Documents/tobin/tobin.crt
        client-key: /Users/emwg/Documents/tobin/tobin.key

>__\*****IMPORTANT NOTE\*\*\***__ <br><br> To create the __base64__ strings needed in the *_data_* fields do the following: <br><br> base64 -i /Users/emwg/Documents/tobin/tobin.crt | tr -d '\n' <br> base64 -i /Users/emwg/Documents/tobin/tobin.key | tr -d '\n'

<br>

## Client Certificate and Server Certificate differences:

Both a __client certificate__ (used in _.kube/config_) and a __server certficate__ (for example: __apiserver.crt__ located on the controlplane node in _/etc/kubernetes/pki/apiserver.crt_) use the same X.509 format, but with different extensions and purposes. The API server cert needs __SANs__ for hostname validation, while user certs use __CN__ for identity (SANs ignored). This is standard TLS client/server certificate separation, not Kubernetes-specific.

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
<br />


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
<br />

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
<br />

# Update the apiserver.crt file
Sometimes you need to add extra SANs to a cert or delete (or maybe fix) a SAN that was incorrectly entered when you initially created the cert. To do this, you can simply recreate the cert with the __openssl__ command. 

>Always backup important files first

    sudo cp /etc/kubernetes/pki/apiserver.crt /etc/kubernetes/pki/apiserver.crt.backup

### Generate new cert with all required SANs

Create a new CSR using the original private key:

1.     sudo openssl req -new -key /etc/kubernetes/pki/apiserver.key -subj "/CN=kube-apiserver" -addext "subjectAltName = DNS:anjuna.elliotmywebguycom,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local,IP:10.96.0.1,IP:10.142.0.2,IP:34.74.64.149" -out /tmp/apiserver.csr
<br />

Sign the newly created CSR with the CA credentials

2.     sudo openssl x509 -req -in /tmp/apiserver.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /etc/kubernetes/pki/apiserver.crt -days 365 -copy_extensions copy
<br />

Resert the kube-apiserver

3.     sudo systemctl restart kube-apiserver
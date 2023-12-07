# Kubernetes Cluster on Proxmox VE hypervisor (on-premise cluster)
The project is based on a proof of concept for a Kubernetes cluster on the Proxmox VE virtualizer. The setup includes 1 master node, 2 worker nodes, and an NFS machine, as depicted in the following diagram:

## Terraform manifests:
**OBS: It's a prerequisite for setting up the cluster to have a Linux VM template (preferably Ubuntu/Debian based).**

To provision the cluster, the infrastructure-as-code tool **Terraform** is used. 

Firstly, you need to use your PVE username, password, and the Proxmox cluster address in the `terraform/Datacenter.tfvars` file. You can change the variables in the `var.auto.tfvars` file according to your cluster's requirements. Note: In this scenario, static IPs with VLAN are used, along with SSH password instead of SSH key

The Terraform manifest files for each virtual machine are separated in different directories:

### Master node:
The installation of Kubernetes services is automated within the *provisioner* block of the Terraform manifest. 

`cd terraform/k8s_master_node_01`
`nano /var.auto.tfvars`
`terraform init`
`terraform apply`

### Worker nodes:

`cd terraform/k8s_worker_node_01`
`nano /var.auto.tfvars`
`terraform init`
`terraform apply`

`cd terraform/k8s_worker_node_02`
`nano /var.auto.tfvars`
`terraform init`
`terraform apply`

### NFS Server:

`cd terraform/nfs_node`
`nano /var.auto.tfvars`
`terraform init`
`terraform apply`

Note: The script located at terraform/scripts/nfs-install.sh is used for the installation and configuration of the NFS Server. The authorized IPs can be modified within this script.

## Post-installation resources
### Monitoring tools (Prometheus/Grafana)
**Prometheus:** It's a monitoring system that collects and processes metrics from different sources. It helps in monitoring and alerting for system and application performance.

**Grafana:** Grafana is a visualization tool that works well with Prometheus. It creates customizable dashboards and visual representations of metrics collected by Prometheus or other sources. It helps in displaying and analyzing monitoring data effectively.

`kubectl apply -f ./monitoring/kube-state-metrics/`
`kubectl apply -f ./monitoring/k8s-prometheus/`
`kubectl apply -f ./monitoring/k8s-grafana/`

### Ingress Controller
The Ingress Controller is a component in Kubernetes that manages incoming traffic to the cluster, typically acting as a reverse proxy to route requests to the appropriate services. It works by reading Ingress resources to define routing rules.

- Install NGINX Ingress Controller:
`kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml`

### Cert Manager
Cert Manager is a specialized tool within Kubernetes that automates the management of SSL/TLS certificates. It simplifies the process of obtaining, configuring, and renewing certificates from Certificate Authorities like Let's Encrypt. By handling these tasks automatically, Cert Manager ensures secure connections by providing and renewing certificates for applications within Kubernetes clusters.

- Required to change the 'email' field for create Let's Encrypt account:

`cert-manager/prod_issuer.yaml`
`cert-manager/staging_issuer.yaml`

- Apply/install cert-manager:
`kubectl apply -f ./cert-manager/`

### MetalLB LoadBalancer
MetalLB is a load balancer designed for Kubernetes on on-premise clusters. It enables the use of standard network protocols to distribute incoming traffic across services within the cluster (such as layer 2 or BGP protocol). 

- Use your own IP addreses by changing the "addresses:" parameter on the file `metallb/ipaddresspool.yaml`
- Apply to create IPAddressPool resource:
`kubectl apply -f metallb/ipaddresspool.yaml`

- If BGP is used, change the "ASN" and "PeerAddress" specifications on file `metallb/bgpadvertisement.yaml` and apply:
`kubectl apply -f metallb/bgpadvertisement.yaml`

- If Layer2 is used, apply:
`kubectl apply -f metallb/layer2advertisement.yaml`

### NFS Provisioner
The NFS provisioner is a tool used in Kubernetes that dynamically creates and manages PersistentVolumes to allow storage using Network File System (NFS) shares. It automatically creates the necessary volumes and handles the lifecycle of storage resources, making it easier to use NFS storage in Kubernetes clusters without manual configuration.

- In nfs-provisioner/nfs-deployment.yaml two different pods are deployed, one representing nfs for HDD and the other for SSD. The NFS server address can be changed in the following snippet:

```
env:
    - name: PROVISIONER_NAME
      value: ff1.dev/ssd 
    - name: NFS_SERVER
      value: 10.0.0.2 #Server IP
    - name: NFS_PATH
      value: /ssd01 #NFS server path
```


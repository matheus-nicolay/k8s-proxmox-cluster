target_node = "pve"
vm_name = "k8s-worker-node02"
vm_desc = ""
template = "PackerImage-ubuntu-server22.04" #VM Template 
vm_cpu_number = 2
vm_memory = 4096
disk_size = "30G"
disk_storage = "SAS01" #Storage
vlan_tag = "1010" #VLAN if is used
private_ip = "10.0.0.122" #Private IP, behind NAT
public_ip = "10.3.3.122" #Public IP, behind NAT
subnet = "24"
gateway = "10.0.0.254"
vm_user = "ubuntu"
vm_password = "ubuntu-k8s@1" 
default_user_password = "ubuntu-k8s@1" 

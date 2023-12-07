# Proxmox Full-Clone
# ---
# Create a new VM from a clone

resource "proxmox_vm_qemu" "linux-VM" {
    
    # VM General Settings
    target_node = var.target_node
    vmid = 0
    name = var.vm_name
    desc = var.vm_desc

    force_create = true

    # VM Advanced General Settings
    onboot = true 

    # VM OS Settings
    clone = var.template

    # VM System Settings
    agent = 1
    
    # VM CPU Settings
    cores = var.vm_cpu_number
    sockets = 1
    cpu = "kvm64"    
    
    # VM Memory Settings
    memory = var.vm_memory

    disk {
        #slot = 0
        type = "scsi"
        storage = var.disk_storage
        size = var.disk_size
        format = "raw"
    }

    # VM Network Settings
    network {
        bridge = "vmbr0"
        model  = "virtio"
        firewall  = false
        tag = var.vlan_tag
    }

    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # (Optional) IP Address and Gateway
    ipconfig0 = "ip=${var.private_ip}/${var.subnet},gw=${var.gateway}"
    
    # (Optional) Default User
    ciuser = var.vm_user
    cipassword = var.vm_password
    nameserver = "1.1.1.1 8.8.8.8"

    # (Optional) Add your SSH KEY
    # sshkeys = <<EOF
    # #YOUR-PUBLIC-SSH-KEY
    # EOF

    # generic remote provisioners (i.e. file/remote-exec)
    connection {
        type     = "ssh"
        user     = var.vm_user
        password = var.vm_password
        host     = var.public_ip
        timeout = 45
    }

    provisioner "local-exec" {
      command = "until (/usr/bin/nmap ${var.public_ip} -p 22 -Pn | grep open); do echo 'Waiting for cloud-init...'; sleep 1; done"
    }

    provisioner "file" {
        source      = "../scripts/script.sh"
        destination = "/tmp/script.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/script.sh",
            "/tmp/script.sh args",
            "sudo hostnamectl set-hostname master-node01",
            "sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=10.0.0.100",
            "mkdir -p $HOME/.kube",
            "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
            "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
            "mkdir -p /root/.kube",
            "sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config",
            "sudo chown root:root /root/.kube/config",
            "kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml",
            "kubectl get pods --all-namespaces"
        ]
    }

}
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
            "sudo hostnamectl set-hostname worker-node02",
            "sudo kubeadm join 10.0.0.100:6443 --token 5t8kmg.k6p7ifq6ejt3ok9n --discovery-token-ca-cert-hash sha256:f4f89d1b9be4523b71091ddce2e9890602639d1a09c4b0119f2ce2b33f2fa04e",
        ]
    }

}
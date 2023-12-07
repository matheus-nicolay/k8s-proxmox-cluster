sudo apt update -y
sudo apt install -y nfs-kernel-server
sudo mkdir -p /ssd01 
sudo mkdir -p /hdd01 
sudo mount /dev/sdb1 /ssd01
sudo mount /dev/sdc1 /hdd01
sudo chown nobody:nogroup /ssd01 
sudo chown nobody:nogroup /hdd01 
sudo echo "/dev/sdb1	/ssd01	ext4	defaults     0   0" >> /etc/fstab
sudo echo "/dev/sdc1	/hdd01 	ext4	defaults     0   0" >> /etc/fstab
sudo echo "/ssd01    10.0.0.0/24(rw,async,no_subtree_check,no_root_squash)" >> /etc/exports
sudo echo "/hdd01    10.0.0.0/24(rw,async,no_subtree_check,no_root_squash)" >> /etc/exports
sudo systemctl restart nfs-kernel-server
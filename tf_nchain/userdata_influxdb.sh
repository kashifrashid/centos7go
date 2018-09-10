
yum update -y

# Format attached disks

# lsblk
# ls -al /dev/disk/by-uuid/


# /etc/fstab


# Assuming that you find /dev/xvda1 to ha

# lsblk /dev/xvdh

# if [[ $? -eq 0 ]]; then
#     mkfs.ext4 /dev/xvdh
# fi
#!/bin/bash -e

#Cleanup APT
apt-get clean

#Remove files that shouldn't exist in the image
rm -f /var/spool/cloud/*
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -rf /var/lib/rightscale
rm -rf ~rightscale/.ssh
rm -rf /tmp/*
rm -rf /tmp/.[^.]*
rm -rf /tmp/..?*
rm -rf /var/cache/*
rm -rf /var/mail/*
rm -rf /var/lib/ntp/ntp.drift
rm -f /etc/hosts.backup.*
rm -rf /etc/pki/tls/private/*
rm -rf /root/.ssh
rm -rf /root/.gem
rm -f /root/*.tar
rm -rf /root/files
rm -f /root/*
rm -f /root/.*_history /root/.vim* /root/.lesshst /root/.gemrc
rm -rf /root/.cache /root/.vim
find /etc -name \*~ -exec rm -- {} \;
find /etc -name \*.backup* -exec rm -- {} \;

#Create/Clear require files
find /var/spool -type f -exec cp /dev/null {} \;
find /var/log -type f -exec cp /dev/null {} \;
find /etc/ssh/ssh_host_* -type f -exec cp /dev/null {} \;
sed -i s/root::/root:*:/ /etc/shadow
mkdir -p /var/cache/logwatch /var/cache/man /var/cache/nscd
mkdir -p /var/cache/apt/archives/partial /var/cache/debconf

#Generate APT package lists and man files
apt-cache gencaches
mandb --create
updatedb
sync

echo "This instance is ready to be registered"
echo "Use the following command on a machine with the aws cli"
INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`
echo "aws ec2 create-image --instance-id=$INSTANCE_ID --name=custom_image_name_goes_here"

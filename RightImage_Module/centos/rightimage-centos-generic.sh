yum update -y
yum install lynx vim-enhanced glibc.i686 libgcc.i686 libX11.i686 -y
yum groupinstall "Development Tools" -y
rpm --import http://mirror.rightscale.com/rightlink/rightscale.pub
cat >/etc/yum.repos.d/RightScale-epel.repo<<-EOF
[rightscale-epel]
name=RightScale Software
baseurl=http://island1.rightscale.com/rightscale_software/epel/6/x86_64/archive/latest/
gpgcheck=1
enabled=1
gpgkey=http://mirror.rightscale.com/rightlink/rightscale.pub
EOF

yum install rightimage-extras-base -y
cat <<EOF> /etc/yum.repos.d/rightlink.repos
[rightlink]
name= RightLink- $basearch
baseurl=http://island1.rightscale.com/rightlink/yum/1/el/6/x86_64/
failovermethod=priority
enabled=1
gpgcheck=0
EOF
yum install rightlink6-cloud-rackspace -y

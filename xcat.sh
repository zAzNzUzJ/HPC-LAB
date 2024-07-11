 ONLY FOR STATEFULLL
 
 
 
 sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
 sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*



echo "Xcat installation"

yum -y install yum-utils

wget -P /etc/yum.repos.d https://xcat.org/files/xcat/repos/yum/latest/xcat-core/xcat-core.repo

wget -P /etc/yum.repos.d https://xcat.org/files/xcat/repos/yum/xcat-dep/rh7/x86_64/xcat-dep.repo

yum -y install xCAT

. /etc/profile.d/xcat.sh

chdef -t site dhcpinterfaces="ens36"

copycds /home/admin/Downloads/CentOS-7-x86_64-DVD-2009.iso 
echo "Check image files "

lsdef -t osimage
# set domain name add the domain mane here 
chdef -t site domain=master

#add the mac n ip host only ip 
mkdef -t node cn01 groups=compute,all installnic=mac  mac=00:0c:29:a4:79:e0 netboot=xnba arch=x86_64 mgt=xcat postscripts=otherpkgs postscripts="syslog,remoteshell,syncfiles,confignetwork -s"


# set the passord n user
chtab key=system passwd.username=root passwd.password=1234

makehosts

makenetworks

makedhcp -n
# add range and restart dhcpd 

makedns -n 

# set the hosts

nodeset cn01 osimage=centos7.9-x86_64-install-compute
# chek with lsdef -t osimage


echo "START WAREWULF INSTALLATION " 
# before running the script disable  firewalld and selinux -- 
# add etc/hosts hostonly ip to the hosts and check all the interface are added 

#in this script every where iP used is Hostonly IP change it as per the required
# change ip and mac and hostip as per ur system
yum install http://repos.openhpc.community/OpenHPC/2/EL_8/x86_64/ohpc-release-2-1.el8.x86_64.rpm
# check if it gets installed correctly else -- 
yum install ohpc-base ohpc-warewulf hwloc-ohpc

# check the host only interface -- set it correct

perl -pi -e "s/device = eth1/device = ens224/" /etc/warewulf/provision.conf

ip link set dev ens224 up

systemctl start httpd

systemctl enable httpd

systemctl enable dhcpd

systemctl enable tftp

systemctl restart httpd

systemctl restart tftp

perl -pi -e &quot;s/^\s+disable\s+= yes/ disable = no/&quot; /etc/xinetd.d/tftp

systemctl restart xinetd


export CHROOT=/opt/ohpc/admin/images/rocky8.8

wwmkchroot -v rocky-8 $CHROOT

dnf -y --installroot $CHROOT install epel-release

cp -p /etc/yum.repos.d/OpenHPC*.repo $CHROOT/etc/yum.repos.d

yum -y --installroot=$CHROOT install ohpc-base-compute

cp -p /etc/resolv.conf $CHROOT/etc/resolv.conf

yum -y --installroot=$CHROOT install kernel-`uname -r`

yum -y --installroot=$CHROOT install lmod-ohpc

wwinit database

wwinit ssh_keys

# use host only ip 

echo "192.168.11.128:/home /home nfs nfsvers=3,nodev,nosuid 0 0" >> $CHROOT/etc/fstab

echo "192.168.11.128:/opt/ohpc/pub /opt/ohpc/pub nfs nfsvers=3,nodev 0 0" >> $CHROOT/etc/fstab

echo "/home *(rw,no_subtree_check,fsid=10,no_root_squash)" >> /etc/exports

echo "/opt/ohpc/pub *(ro,no_subtree_check,fsid=11)" >> /etc/exports

exportfs -a

systemctl restart nfs-server

systemctl enable nfs-server

systemctl restart rsyslog

echo 'module(load="imudp")' >> /etc/rsyslog.d/ohpc.conf

echo 'input(type="imudp" port="514")' >> /etc/rsyslog.d/ohpc.conf


systemctl restart rsyslog

# use hostonly ip 

echo "*.* @192.168.11.128:514" >> $CHROOT/etc/rsyslog.conf

echo "Target=\"192.168.11.128\" Protocol=\"udp\"" >> $CHROOT/etc/rsyslog.conf

# perl cmmds may show warning could not find  directory ingnore them

perl -pi -e "s/^\*\.info/\\#\*\.info/" $CHROOT/etc/rsyslog.conf


perl -pi -e "s/^authpriv/\\#authpriv/" $CHROOT/etc/rsyslog.conf

 perl -pi -e "s/^mail/\\#mail/" $CHROOT/etc/rsyslog.confperl -pi -e "s/^mail/\\#mail/" $CHROOT/etc/rsyslog.conf

 perl -pi -e "s/^cron/\\#cron/" $CHROOT/etc/rsyslog.conf

 perl -pi -e "s/^uucp/\\#uucp/" $CHROOT/etc/rsyslog.conf

yum -y install clustershell


wwsh file import /etc/passwd
 
wwsh file import /etc/group
 
wwsh file import /etc/shadow

export WW_CONF=/etc/warewulf/bootstrap.conf


echo "drivers += updates/kernel/" >> $WW_CONF

wwbootstrap `uname -r`

wwvnfs --chroot $CHROOT

echo "GATEWAYDEV=ens224" > /tmp/network.$$

wwsh -y file import /tmp/network.$$ --name network

wwsh -y file set network --path /etc/sysconfig/network --mode=0644 --uid=0

# chenge the IP and MAC for the client also check the interface name

wwsh -y node new cn01 --ipaddr=192.168.11.20 --hwaddr=00:0C:29:6D:38:2B -D ens224


wwsh -y provision set cn01 --vnfs=rocky8.8 --bootstrap=`uname -r` =dynamic_hosts,passwd,group,shadow,network

systemctl restart dhcpd

systemctl status dhcpd 

wwsh pxe update


echo "Done installation and node gets booted  Thank Anuj"
echo " else call Anuj for help"

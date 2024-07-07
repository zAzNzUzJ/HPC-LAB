##########
echo "NAGIOS SETUP -- "

yum install ohpc-nagios

psh cn01 yum -y install nagios-plugins-all-ohpc nrpe-ohpc
psh cn01 systemctl enable nrpe
psh cn01 perl -pi -e "\""s/^allowed_hosts=/\#allowed_hosts=/"\"" /etc/nagios/nrpe.cfg
psh cn01 echo "\""nrpe : master : ALLOW"\"" \>\> /etc/hosts.allow
psh cn01 echo "\""nrpe 5666/tcp \#NRPE"\"" \>\>  /etc/services
psh cn01 echo "\""nrpe : ALL : DENY"\""\>\> /etc/hosts.allow
psh cn01 "usr/sbin/useradd -c "\""NRPE user for the NRPE service"\"" -d /var/run/nrpe -r -g nrpe -s /sbin/nologin nrpe"

psh cn01 /usr/sbin/groupadd -r nrpe

mv /etc/nagios/conf.d/services.cfg.example /etc/nagios/conf.d/services.cfg
mv /etc/nagios/conf.d/hosts.cfg.example  /etc/nagios/conf.d/hosts.cfg
psh cn01 "echo command[check_ssh]=/usr/lib64/nagios/plugins/check_ssh localhost /etc/nagios/nrpe.cfg"

vim /etc/nagios/conf.d/hosts.cfg


chkconfig nagios on



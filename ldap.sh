
echo "setup LDAP                            "


#AJ#
#READ IT FULL BEFORE EXECUTING IT
#yum install openldap-servers openldap-clients

#systemctl enable --now slapd
# generate the password and save the SHA text created 
# slappasswd
####################################################3
#ADD THE PAssword to
#vi chrootpw.ldif
###############################
#add in that file
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}xxxxxxxxxxxxxxxxxxxxxxxx
##########################

#add it to ldap
##############################3
ldapadd -Y EXTERNAL -H ldapi:/// -f chrootpw.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
##################################333
# vi chdomain.ldif
## ADD TH FOLLOWING AND REPLACE THE REQUIRED
####################################################################3
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
  read by dn.base="cn=Manager,dc=srv,dc=world" read by * none

dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=srv,dc=world

dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=srv,dc=world

dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}xxxxxxxxxxxxxxxxxxxxxxxx

dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=Manager,dc=srv,dc=world" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=srv,dc=world" write by * read

################

# sed -i 's/dc=srv/dc=local/g' chdomain.ldif
# sed -i 's/dc=world/dc=com/g' chdomain.ldif

# add the generated password from previous
##############################


ldapmodify -Y EXTERNAL -H ldapi:/// -f chdomain.ldif

vi basedomain.ldif


##### ADD THE FOLOWING###########
dn: dc=srv,dc=world
objectClass: top
objectClass: dcObject
objectclass: organization
o: Server World
dc: srv

dn: cn=Manager,dc=srv,dc=world
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=srv,dc=world
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=srv,dc=world
objectClass: organizationalUnit
ou: Group

##########RELPACE AAS ABOVE###################


ldapadd -x -D cn=Manager,dc=srv,dc=world -W -f basedomain.ldif



##################ADD USER###################

vi ldapuser.ldif

dn: uid=centos,ou=People,dc=srv,dc=world
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: CentOS
sn: Linux
userPassword: {SSHA}xxxxxxxxxxxxxxxxx
loginShell: /bin/bash
uidNumber: 2000
gidNumber: 2000
homeDirectory: /home/centos

dn: cn=centos,ou=Group,dc=srv,dc=world
objectClass: posixGroup
cn: centos
gidNumber: 2000
memberUid: centos

#########BETTER TO USE SAME PASSWORD AND REPLACE IT WITH DC 

ldapadd -x -D cn=Manager,dc=srv,dc=world -W -f ldapuser.ldif



##CLIENT SIDE###########


# yum install openldap-clients nss-pam-ldapd


#### configure the server path
#add the domain proporly as m=pre required
# authconfig --enableldap --enableldapauth --ldapserver=master.local.com --ldapbasen="dc=local,dc=com" --enablemkhomedir --update
###########################################

## check it with 
#id cent<username>




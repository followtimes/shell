#!/bin/bash
LOCALIP=`/sbin/ifconfig|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|head -1|tr -d "addr:"`
yum install -q -y sudo
SUDOPATH=`sudo -V|grep "ldap.conf path"|awk '{print $3}'`

[ $# -eq 1 ] && [ $1 = "-uninstall" ] && {
sed -i '/xiaomi/d' $SUDOPATH;
sed -i '/sudoers/d' /etc/nsswitch.conf;
sed -i '/pam_mkhomedir/d' /etc/pam.d/sshd;
sed -i '/KerberosAuthentication yes/d' /etc/ssh/sshd_config;
sed -i '/KerberosOrLocalPasswd yes/d' /etc/ssh/sshd_config;
sed -i '/GSSAPIAuthentication yes/d' /etc/ssh/sshd_config;
sed -i '/GSSAPICleanupCredentials yes/d' /etc/ssh/sshd_config;
sed -i '/GSSAPIStrictAcceptorCheck no/d' /etc/ssh/sshd_config;
sed -i 's/sss //g' /etc/nsswitch.conf;
sed -i '/pam_krb5.so/d' /etc/pam.d/sshd;
sed -i '/xcu=/d' /etc/bashrc;
rm -f /etc/krb5.keytab;
curl -s "http://ldap1.xiaomi.net/index.php?del=$LOCALIP";

/etc/init.d/sshd reload;
exit 0; }

[ $# -eq 2 ] || { echo -e "Errror!Please check option!\nUseage:$0 department product!\nExp:$0 miliao miliao"; exit 1; }

if [ -d /etc/openldap/cacerts ]; then
 	echo "/etc/openldap/cacerts exist."
else
	echo "Create /etc/openldap/cacerts."
	mkdir /etc/openldap/cacerts
fi
wget "http://ldap1.xiaomi.net/godlike/krb5.conf" -O /etc/krb5.conf || { echo "wget krb5.conf error!";exit 1; }
wget "http://ldap1.xiaomi.net/godlike/cacert.pem" -O /etc/openldap/cacerts/cacert.pem || { echo "wget cacert.pem error!";exit 1; }

#centos6 config
OSVER=`cat /etc/issue|head -1|awk -F[.] '{print $1}'`
if [ "$OSVER" = "CentOS release 6" ] 
then
#install authentication and authorization  module
yum install -q -y nss-pam-ldapd || { echo "install nslcd error!Please check yum config!";exit 1; }
yum install -q -y pam_krb5 || { echo "install pam error!";exit 1; }
fi

#centos5 config
OSVER=`cat /etc/issue|head -1|awk -F[.] '{print $1}'`
if [ "$OSVER" = "CentOS release 5" ] 
then
	groupadd -g 999 nslcd || { echo "groupadd error!";exit 1; }
	useradd nslcd -u 999 -g nslcd || { echo "useradd error!";exit 1; }
	rpm -ivh http://ldap1.xiaomi.net/nslcd-0.8-12.x86_64.rpm
fi
chkconfig nslcd on

#copy configuration files
[ -f "krb5.conf" ] || { echo "Can not find krb5.conf"; exit 1; }
\cp -f krb5.conf /etc/krb5.conf

#configure sudo from ldap
echo sudoers:    ldap >> /etc/nsswitch.conf
#config auto make home dir
echo session    required     pam_mkhomedir.so skel=/etc/skel/ umask=0077 >> /etc/pam.d/sshd

#sshd config
SSHDVER=`ssh -v 2>&1|head -1|awk -F[,] '{print $1}'`
[ ${SSHDVER} = "OpenSSH_5.3p1" ] || { echo "Ssh version error!This verion is $SSHDVER";exit 1; }
[ -f "/etc/ssh/sshd_config" ] || { echo "Can not sshd_config"; exit 1; }
echo KerberosAuthentication yes >> /etc/ssh/sshd_config
echo KerberosOrLocalPasswd yes >> /etc/ssh/sshd_config
echo GSSAPIAuthentication yes >> /etc/ssh/sshd_config
echo GSSAPICleanupCredentials yes >> /etc/ssh/sshd_config
echo GSSAPIStrictAcceptorCheck no >> /etc/ssh/sshd_config

groupadd -g 2002 rd
useradd rd -u 1000 -g rd || { echo "rd user add error!";exit 1; }
chmod 777 -R /home/rd

#configure authentication method
authconfig  --enableldap  --enableldaptls --ldapserver="ldap://ldap1.xiaomi.net/" --ldapbasedn="ou=$2,ou=$1,ou=auth,dc=xiaomi,dc=com" --update
authconfig --enablekrb5 --enablekrb5kdcdns --krb5kdc="krb1.xiaomi.net" --krb5adminserver="krb1.xiaomi.net" --krb5realm="XIAOMI.NET" --update
if [ "$OSVER" = "CentOS release 5" ] 
then
	BASE=`grep dc=xiaomi /etc/openldap/ldap.conf |awk '{print $2}'`
	for I in $BASE 
	do
		echo "base $I" >> /etc/nslcd.conf
	done
fi
echo uri ldap://ldap1.xiaomi.net/ >> $SUDOPATH
echo sudoers_base ou=SUDOers,ou=$2,ou=$1,ou=auth,dc=xiaomi,dc=com >> $SUDOPATH

#get kerberos keytab
wget "http://krb1.xiaomi.net/index.php?host=$LOCALIP&group=ou=$2,ou=$1" -O /etc/krb5.keytab || { echo "Can not wget keytab!";exit 1; } 
FSIZE=`ls -l /etc/krb5.keytab| cut -d' ' -f 5`
if [ $FSIZE -lt 100 ]; then
	echo "Keytab error!"
	exit 1
fi
/etc/init.d/nslcd restart
/etc/init.d/sshd reload 
#xcu config
echo alias xcu=\'sudo -i -u\' >> /etc/bashrc

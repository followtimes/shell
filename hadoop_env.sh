#!/bin/bash

# write by liuyayun
# Date 2013/1/18

echo "install krb5 ..."
yum -y install krb5-devel krb5-libs  krb5-workstation

echo "install jdk&jce"
cd /tmp/
wget http://lg-hadoop-build03.bj/share/infra/jdk1.6.0_37.tar.gz
yum -y erase java
mkdir -p /opt/soft
tar -xf jdk1.6.0_37.tar.gz -C /opt/soft/

mkdir -p  /opt/soft/jdk1.6.0_37/jre/lib/security/
wget http://lg-hadoop-build03.bj/share/infra/jce_policy-6.zip 
unzip jce_policy-6.zip
cd jce &&
cp jce/* /opt/soft/jdk1.6.0_37/jre/lib/security/


ln -sf /opet/soft/jdk1.6.0_37 /opt/soft/jdk &&
ln -sf /opt/soft/jdk/bin/java /usr/bin/java &&
ln -sf /opt/soft/jdk/bin/javac /usr/bin/javac &&
ln -sf /opt/soft/jdk/bin/javadoc /usr/bin/javadoc &&
ln -sf /opt/soft/jdk/bin/javap /usr/bin/javap &&
ln -sf /opt/soft/jdk/bin/javah /usr/bin/javah ||
{ echo -e "\033[41;36m  java install failed \033[0m"; exit 2; }

grep "JAVA_HOME=/opt/soft/jdk" /etc/profile ||
echo -e 'export JAVA_HOME=/opt/soft/jdk \nexport PATH=$JAVA_HOME/bin:$PATH \nexport CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/rt.jar:$CLASSPATH \nexport LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH' >> /etc/profile

grep "JAVA_HOME=/opt/soft/jdk" /etc/bashrc ||
echo "export JAVA_HOME=/opt/soft/jdk" >> /etc/bashrc

cd /etc/
wget http://lg-hadoop-build03.bj/share/infra/krb5.conf
wget http://lg-hadoop-build03.bj/share/infra/krb5-hadoop.conf

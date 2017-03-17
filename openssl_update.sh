cd
wget https://www.openssl.org/source/openssl-1.0.2g.tar.gz
tar -zxf openssl-1.0.2g.tar.gz 
cd openssl-1.0.2g/
./config shared zlib
make
make install
mv /usr/bin/openssl /usr/bin/openssl.bak
mv /usr/include/openssl /usr/include/openssl.bak
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl
echo “/usr/local/ssl/lib” >> /etc/ld.so.conf
ldconfig -v
openssl version -a

cd
rm -rf openssl-1.0.2g*

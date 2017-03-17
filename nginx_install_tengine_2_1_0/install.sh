#!/bin/bash

#prepare env
[ -z "`lsmod | grep toa`" ] && /sbin/modprobe toa #load toa module
if [ -z "`grep net.core.somaxconn /etc/sysctl.conf`" ]; then
   echo "net.core.somaxconn = 262144" >> /etc/sysctl.conf
   echo "net.ipv4.tcp_max_orphans = 262144" >> /etc/sysctl.conf
   echo "net.core.netdev_max_backlog = 262144" >> /etc/sysctl.conf
   echo "net.ipv4.tcp_max_syn_backlog = 262144" >> /etc/sysctl.conf
fi
/sbin/sysctl -p
#

WORK_DIR="$PWD"
TARGET_DIR="$1"

#NGINX_TAR="tengine-2.0.1_with_libs.tar.bz2"
#LUAJIT_TAR="luajit-2.1.tar.bz2"
OPENSSL_DIR="./src/openssl-1.0.1k"

NGINX_DIR="tengine-2.0.1"
LUAJIT_DIR="luajit-2.1"

help_() {
  echo -e "
===
Usage: $0 NGINX_PREFIX_DIR [--with-openssl-static]

  * NGINX_PREFIX_DIR: nginx install dir
  * --with-openssl-static: compile openssl static
===
"
}

info_() {
 echo -e "
* nginx version = tengine 2.0.1, luajit version = luajit 2.1
* nginx install dir: ${1:-\$1}
* luajit lib install dir: /usr/local/lib
* luajit include install dir: /usr/local/include/luajit-2.1
* luajit LIB and INC define: /etc/profile
"
}

case $# in
    1)
        if [ "$@" = "-h" -o "$@" = "--help" ];then
            help_
            info_
            exit 0
        elif ! [ -d "${1}" ] ;then
            echo -e "\nERROR: invalid args or dir not found --> $@"
            help_
            exit 3
        else
            :
        fi
        ;;
    2)
        if ! [ -d "${1}" ] ;then
            echo -e "\nERROR: invalid args or dir not found --> $@"
            help_
            exit 3
        elif [ "$2" = "--with-openssl-static" ]; then
            ADD_ARGS="--with-openssl=${OPENSSL_DIR}"
        else
            help_
            exit 3
        fi
        ;;
    *)
        help_
        exit 1
        ;;
esac

if (pgrep -f 'nginx.*master' &>/dev/null); then
    echo 'Warning: old nginx proc is exist. STOP INSTALL!!'
    exit 4
fi

yum install gcc pcre pcre-devel xz -y >/dev/null
/bin/rm tengine-2.0.1/src/pcre-8.32/Makefile > /dev/null
touch -d $(date -d '1 seconds' +%T) tengine-2.0.1/${OPENSSL_DIR}/Makefile

#rm -rf "${NGINX_DIR}"
#rm -rf "${LUAJIT_DIR}"

#mkdir -v "${NGINX_DIR}"
#mkdir -v  "${LUAJIT_DIR}"

#tar xf ${NGINX_TAR} -C "${NGINX_DIR}" && tar xf ${LUAJIT_TAR} -C "${LUAJIT_DIR}"

echo "compiling luajit..."
cd "${LUAJIT_DIR}" &&\
make >/dev/null && make install >/dev/null \
&& cd /usr/local/bin && ln -sf luajit-2.1.0-alpha luajit \
&& sed -ri '/export.*LUAJIT_(LIB|INC)/d' /etc/profile \
&& echo -e "\nexport LUAJIT_LIB=/usr/local/lib\nexport LUAJIT_INC=/usr/local/include/luajit-2.1\nexport LD_LIBRARY_PATH=\$LUAJIT_LIB:\$LD_LIBRARY_PATH" >> /etc/profile \
&& . /etc/profile

cd "${WORK_DIR}"
echo "compiling nginx..."
cd "${NGINX_DIR}" &&\
./configure --prefix="${TARGET_DIR}" \
--with-http_realip_module \
--with-http_gzip_static_module \
--with-http_addition_module \
--with-http_ssl_module \
--with-http_upstream_session_sticky_module=shared \
--with-http_sub_module \
--without-mail_smtp_module \
--without-mail_imap_module \
--without-mail_pop3_module \
--with-pcre=./src/pcre-8.32  \
--add-module=./src/nginx-upstream-fair \
--add-module=./src/ngx_devel_kit-0.2.18 \
--add-module=./src/ngx_cache_purge-1.6 \
--add-module=./src/headers-more-nginx-module-master \
--add-module=./src/lua-nginx-module-0.9.5rc2 \
--with-pcre-jit \
--with-openssl-opt='-O3 -fPIC' ${ADD_ARGS} >/dev/null &&\
make >/dev/null && make install >/dev/null

cd - && cp -f nginx.conf ${TARGET_DIR}/conf/

echo
echo '* Done. u must run this command at first time *'
echo "source /etc/profile; ${TARGET_DIR}/sbin/nginx"
echo

#!/bin/bash

set -e

WORK_DIR="$PWD"
TARGET_DIR="$1"

OPENSSL_DIR="./src/openssl-1.0.2j"

NGINX_DIR="tengine-2.1.0"
LUAJIT_DIR="luajit-2.1"

help_() {
  echo -e "
===
Usage: $0 NGINX_PREFIX_DIR [OPENSSL_DIR]

  * NGINX_PREFIX_DIR: nginx install dir
  * OPENSSL_DIR: openssl src dir (compile openssl static)
===
"
}

info_() {
 echo -e "
* nginx version = tengine 2.1.0, luajit version = luajit 2.1
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
        elif [ -d "${2}" ]; then
            OPENSSL_DIR="${2}"
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
/bin/rm -f tengine-2.1.0/src/pcre-8.32/Makefile > /dev/null

rm -rf tengine-2.1.0
tar zxf tengine-2.1.0.tar.gz

if ! (ls /usr/local/bin/luajit-2.1.0-alpha &>/dev/null); then
  echo "compiling luajit..."
  cd "${LUAJIT_DIR}" &&\
  make >/dev/null && make install >/dev/null \
  && cd /usr/local/bin && ln -sf luajit-2.1.0-alpha luajit \
  && sed -ri '/export.*LUAJIT_(LIB|INC)/d' /etc/profile \
  && echo -e "\nexport LUAJIT_LIB=/usr/local/lib\nexport LUAJIT_INC=/usr/local/include/luajit-2.1\nexport LD_LIBRARY_PATH=\$LUAJIT_LIB:\$LD_LIBRARY_PATH" >> /etc/profile
fi
. /etc/profile

cd "${WORK_DIR}"
echo "compiling nginx..."
cd "${NGINX_DIR}"
touch -d $(date -d '1 seconds' +%T) ${OPENSSL_DIR}/Makefile
./configure --prefix="${TARGET_DIR}" \
--with-http_realip_module \
--with-http_gzip_static_module \
--with-http_addition_module \
--with-http_ssl_module \
--with-http_upstream_session_sticky_module=shared \
--with-http_spdy_module \
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
--with-openssl=${OPENSSL_DIR} \
--with-openssl-opt='-O3 -fPIC'
make #> /dev/null
#make install > /dev/null

#cd - && cp -f nginx.conf ${TARGET_DIR}/conf/

echo
echo '* Done. u must run this command at first time *'
echo "source /etc/profile; ${TARGET_DIR}/sbin/nginx"
echo

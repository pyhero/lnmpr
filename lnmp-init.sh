#!/bin/bash
#
# Author: Panda
# Update: 2015-06-18

nginx='nginx-1.6.3'
mysql="mysql-5.7.16"
# percona url need to modify!!!
#mysql="percona-server-5.6.29-76.2"
php="php-5.6.21"
#redis="redis-2.8.21"
redis="redis-3.2.8"
file="tar.gz"

# install / update edit
echo -e "\e[36mInstall plugins ... \e[0m"
yum -q install -y gcc* autoconf automake ncurses-devel make cmake

# install / update plugin
yum -q install -y zlib-devel openssl openssl-devel libxml2-devel libjpeg-devel libpng-devel freetype-devel libcurl-devel libmcrypt-devel ncurses-devel libtool-ltdl-devel bison bison-devel pcre pcre-devel libxslt libxslt-devel perl perl-devel perl-ExtUtils-Embed GeoIP GeoIP-devel re2c bzip2 bzip2-devel openldap-devel ImageMagick-devel

# Test directory exits,if not mkdir it
test_dir () {
	if [ ! -d $dir ];then
		mkdir -p $dir
	fi
}

# if last action is not ok , then make a chose
test_act () {
	if [ $? -ne 0 ];then
		while : ; do 
			echo ""
			read -p "undone,go on ? {y|n} : " inp
			case $inp in
				y|Y)
					echo -e "\nGoing on..."
					break;
					;;
				n|N)
					echo -e "\nExitting!"
					exit;
					;;
				*)
					echo -e "Tell me {\e[33my|n\e[0m}"
					continue;
			esac
		done
	fi
}

DIR=$(cd `dirname $0`;echo $PWD)
plugin="$DIR/scripts"
conf="$DIR/conf"
soft="$DIR/src"
src=/ROOT/src
dir=$src && test_dir

# Create or renew user www or mysql.
create_user_www () {
	userdel -r www &> /dev/null; groupadd -g 701 www && useradd -u 701 -g 701 www
}

create_user_mysql () {
	userdel -r mysql &> /dev/null; groupadd -g 702 mysql && useradd -u 702 -g 702 mysql
}

create_user_redis () {
	userdel -r redis &> /dev/null; groupadd -g 703 redis && useradd -u 703 -g 703 redis
}

notice () {
	echo -e "\n\e[35mGo to renew your dir's owner:\n/ROOT/data\n/ROOT/logs\e[0m..."
}

while : ; do
	echo -e "\n\e[36mCreate or renew users: ...\e[0m"
	read -p "Would you want to create/renew your user {www|mysql|redis|all|no} ? " inp
	case $inp in
		www)
			create_user_www
			notice
			continue
			;;
		mysql)
			create_user_mysql
			notice
			continue
			;;
		redis)
			create_user_redis
			notice
			continue
			;;
		all)
			create_user_www
			create_user_mysql
			create_user_redis
			notice
			break
			;;
		no)
			break
			;;
		*)
			echo -e "Tell me {\e[33mwww|mysql|redis|all|no\e[0m}"
			continue
	esac
done

# get soft version
get_soft () {
	echo $(yum info $soft | grep -i 'Name' | awk '{print $NF}')-$(yum info $soft | grep -i 'Version' | awk '{print $NF}')
}

get_ver () {
	soft=zlib
	zlib=$(get_soft)
	soft=openssl
	openssl=$(get_soft)
}

download () {
	# Define des & url first
	cd $soft
	if [ ! -f $src_insall ];then
		wget $url
	fi
}

# install nginx
install_nginx () {
	echo -e "\e[36mInstall nginx ... \e[0m"
	src_insall=${nginx}.${file}
	url="http://nginx.org/download/$src_insall"
	download
	test_act
	tar zxf $src_insall -C $src/ && cd $src/$nginx
	./configure --prefix=/ROOT/server/nginx --sbin-path=/ROOT/bin --conf-path=/ROOT/conf/nginx/nginx.conf --pid-path=/ROOT/tmp/nginx.pid --lock-path=/ROOT/tmp/nginx.lock --user=www --group=www --with-ipv6 --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-poll_module --with-http_xslt_module --with-http_dav_module --with-http_sub_module --with-http_addition_module --with-http_spdy_module --with-http_geoip_module --with-http_flv_module --with-http_mp4_module --with-http_gzip_static_module --with-http_random_index_module --with-http_stub_status_module --with-http_secure_link_module --with-http_perl_module --http-client-body-temp-path=/ROOT/data/nginx/temp/client --http-proxy-temp-path=/ROOT/data/nginx/temp/proxy --http-fastcgi-temp-path=/ROOT/data/nginx/temp/fastcgi --http-uwsgi-temp-path=/ROOT/data/nginx/temp/uwsgi --http-scgi-temp-path=/ROOT/data/nginx/temp/scgi --with-pcre --with-pcre-jit --with-cc-opt='-O2 -g' > /dev/null
	# on CentOS 7
	#./configure --prefix=/ROOT/server/nginx --sbin-path=/ROOT/bin --conf-path=/ROOT/conf/nginx/nginx.conf --pid-path=/ROOT/tmp/nginx.pid --lock-path=/ROOT/tmp/nginx.lock --user=www --group=www --with-ipv6 --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-poll_module --with-http_xslt_module --with-http_dav_module --with-http_sub_module --with-http_addition_module --with-http_spdy_module --with-http_geoip_module --with-http_flv_module --with-http_mp4_module --with-http_gzip_static_module --with-http_random_index_module --with-http_stub_status_module --with-http_secure_link_module --with-http_perl_module --http-client-body-temp-path=/ROOT/data/nginx/temp/client --http-proxy-temp-path=/ROOT/data/nginx/temp/proxy --http-fastcgi-temp-path=/ROOT/data/nginx/temp/fastcgi --http-uwsgi-temp-path=/ROOT/data/nginx/temp/uwsgi --http-scgi-temp-path=/ROOT/data/nginx/temp/scgi --with-pcre --with-pcre-jit --with-http_perl_module --with-ld-opt=-Wl,-E
	test_act
	make > /dev/null && make install > /dev/null
	test_act
	cd $DIR

	# mkdir temp directory
	mkdir -p /ROOT/data/nginx/temp/client /ROOT/data/nginx/temp/proxy /ROOT/data/nginx/temp/fastcgi /ROOT/data/nginx/temp/uwsgi /ROOT/data/nginx/temp/scgi
	mkdir -p /ROOT/logs/nginx
	chown -R www.www /ROOT/data/nginx /ROOT/logs/nginx

	# copy configure files and start scripts
	rsync -az --delete $conf/nginx /ROOT/conf/
	rsync -az $plugin/nginx /etc/init.d/

	/etc/init.d/nginx start
	test_act
	chkconfig nginx on

	# rotatelog configure
	mkdir -p /ROOT/logs/nginx/Rotates
	rsync -az $conf/log/nginx /etc/logrotate.d/
}

# install php
install_php () {
	echo -e "\e[36mInstall php ... \e[0m"
	cp /usr/lib64/libldap* /usr/lib/
	src_insall=${php}.${file}
	url="http://cn2.php.net/distributions/$src_insall"
	download
	test_act
	tar zxf $src_insall -C $src/ && cd $src/$php
	./configure --prefix=/ROOT/server/php --bindir=/ROOT/bin --sbindir=/ROOT/bin --sbindir=/ROOT/bin --with-config-file-path=/ROOT/conf/php --with-config-file-scan-dir=/ROOT/conf/php/php.d --with-curl --with-gd --enable-gd-native-ttf --with-ldap --with-bz2 --with-gettext --with-mysql --with-pdo-mysql --with-mcrypt --with-png-dir --with-jpeg-dir --with-freetype-dir --with-iconv-dir --with-libxml-dir --enable-fpm --enable-ftp --enable-json --enable-mbstring --enable-sockets --enable-exif --enable-bcmath --enable-pcntl --enable-sigchild --enable-sysvmsg --enable-soap --enable-zip --disable-debug --with-openssl-dir --with-zlib-dir --with-openssl --disable-fileinfo > /dev/null
	test_act
	make > /dev/null && make install > /dev/null
	test_act

	mkdir -p /ROOT/logs/php /ROOT/logs/php-fpm
	chown -R www.www /ROOT/logs/php-fpm /ROOT/logs/php
	rsync -az --delete $conf/php /ROOT/conf/

	# install extend
	# pecl install has bug!
	cd $src
	rm -rf pecl
	mkdir pecl
	cd pecl
	yum install -y librabbitmq-devel > /dev/null
	for i in zip mongo redis amqp igbinary imagick memcache;do
		pecl download $i && test_act
		srf=$(ls | grep -i $i)
		srd=$(echo $srf | sed 's/\.tgz//')
		tar zxf $srf && cd $srd
		test_act
		phpize > /dev/null && ./configure --with-php-config=/ROOT/bin/php-config > /dev/null
		test_act
		make > /dev/null && make install > /dev/null
		test_act
		cd $src/pecl
	done

	rsync -az $plugin/php-fpm /etc/init.d/
	/etc/init.d/php-fpm start
	test_act
	chkconfig php-fpm on

	# rotatelog configure
	mkdir -p /ROOT/logs/php-fpm/Rotates
	rsync -az $conf/log/php-fpm /etc/logrotate.d/
	cd $DIR
}

# install mysql
install_mysql () {
	echo -e "\e[36mInstall mysql ... \e[0m"
	#src_insall=$(echo ${mysql}|sed 's/mysql/mysql-boost/').${file}
	src_insall=${mysql}.${file}
	url="http://cdn.mysql.com/Downloads/MySQL-5.7/$src_insall"
	#url="https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-5.6.29-76.2/source/tarball/$src_insall"
	download
	test_act
	tar zxf $src_insall -C $src/ && cd $src/$mysql
	#cmake -DCMAKE_INSTALL_PREFIX=/ROOT/server/mysql-5.6 -DMYSQL_DATADIR=/ROOT/data/mysql -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_DEBUG=0 -DENABLED_LOCAL_INFILE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EDITLINE=bundled > /dev/null
	cmake -DCMAKE_INSTALL_PREFIX=/ROOT/server/mysql-5.7 -DMYSQL_DATADIR=/ROOT/data/mysql -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_DEBUG=0 -DENABLED_LOCAL_INFILE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EDITLINE=bundled -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/ROOT/server/mysql-5.7/boost > /dev/null
	test_act
	make > /dev/null && make install > /dev/null
	test_act

	mkdir -p /ROOT/logs/mysql/3306 /ROOT/logs/mybinlog/3306 /ROOT/data/mysql/3306 /ROOT/conf/mysql
	chown -R mysql.mysql /ROOT/logs/mysql /ROOT/logs/mybinlog /ROOT/data/mysql
	chmod 750 /ROOT/logs/mybinlog /ROOT/data/mysql
	rsync -az --delete $conf/mysql/3306.cnf /ROOT/conf/mysql/
	mydef=/etc/my.cnf
	if [ -f $mydef ];then
		today=$(date "+%F")
		mv $mydef $mydef.$today
	fi
	rsync -az $conf/mysql/my.cnf $mydef

	# initinlize database!
	cd /ROOT/server/mysql-5.7
	rsync -az /ROOT/server/mysql-5.7/bin/mysql* /ROOT/bin/
	#./scripts/mysql_install_db --user=mysql --datadir=/ROOT/data/mysql/3306 --defaults-file=/ROOT/data/mysql/3306/3306.cnf
	/ROOT/bin/mysql_install_db --defaults-file=/ROOT/conf/mysql/3306.cnf --user=mysql --datadir=/ROOT/data/mysql/3306 --basedir=/ROOT/server/mysql-5.7

	rsync -az $plugin/mysqld-3306 /etc/init.d/
	rsync -az $plugin/myinit /ROOT/sh
	chmod 750 /ROOT/sh/myinit
	/etc/init.d/mysqld-3306 start
	test_act
	
	cd $DIR
}

# install redis-2.8
install_redis () {
	echo -e "\e[36mInstall redis ... \e[0m"
	src_insall=${redis}.${file}
	url="http://download.redis.io/releases/$src_insall"
	download
	test_act
	tar zxf $src_insall -C $src/ && cd $src/$redis
	test_act
	make > /dev/null && make PREFIX=/ROOT/ install > /dev/null
	test_act

	mkdir -p /ROOT/logs/redis /ROOT/data/redis/6379 /ROOT/conf/redis
	chown -R redis.redis /ROOT/logs/redis /ROOT/data/redis/6379
	rsync -az --delete $conf/reids/6379.conf /ROOT/conf/redis

	rsync -az $plugin/redis-6379 /etc/init.d/
	/etc/init.d/redis-6379 start
	test_act
	
	cd $DIR
}

# Install software.
again () {
	while : ; do
		echo -e "\n\e[36mInstall other software ...\e[0m"
		read -p "Would you want to install other soft? {y|n} " ag
		case $ag in
			y)
				re=yew
				break
				;;
			n)
				re=no
				break
				;;
			*)
				echo -e "Tell me {\e[33my|n\e[0m}!"
				continue
		esac
	done
	case $re in
		yes)
			continue
			;;
		no)
			break
			;;
	esac
}

while : ; do
	echo -e "\n\e[36mInstall software ... \e[0m"
	read -p "What do you want to install {nginx|php|mysql|redis|all|no} " inp
	case $inp in
		nginx)
			install_nginx
			again
			;;
		php)
			install_php
			again
			;;
		mysql)
			install_mysql
			again
			;;
		redis)
			install_redis
			again
			;;
		all)
			install_nginx
			install_mysql
			install_php
			install_redis
			break
			;;
		no)
			break
			;;
		*)
			echo -e "Tell me {\e[33mnginx|php|mysql|redis|all|no\e[0m}"
			continue
	esac
done

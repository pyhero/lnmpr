#!/bin/bash
#
# Author: Xu Panda
# Update: 2015-06-18

if [ $# -lt 1 ];then
	echo -e "Useage:$0 {\e[32mport\e[0m}"
	exit 2
fi
port=$1
while read -p "Will init mysql with port: $port  (y|n)?: " inp;do
	case $inp in
		y)
			echo "Init mysql-$port ..."
			break
			;;
		n)
			echo "Retry:$0 {port}"
			exit
			;;
		*)
			continue
	esac
done

dir=$(cd `dirname $0`;echo $PWD) && cd $dir
srcconf=$dir/conf/3306.cnf
if [ ! -f $srcconf ];then
	echo "$srcconf: no such file or directory!"
	exit 2
fi
desconf=$dir/conf/$port.cnf
rsync -az $srcconf $desconf
sed -i "s/3306/$port/" $desconf
mkdir -p /ROOT/log/mysql/$port /ROOT/log/mybinlog/$port /ROOT/data/mysql/$port
chown -R mysql.mysql /ROOT/log/mysql /ROOT/log/mybinlog /ROOT/data/mysql
chmod 750 /ROOT/log/mybinlog /ROOT/data/mysql
rsync -az $desconf /ROOT/data/mysql/$port/

srcinit=$dir/conf/mysqld-3306
if [ ! -f $srcinit ];then
	echo "$srcinit: no such file or directory!"
	exit 2
fi
desinit=$dir/conf/mysqld-$port
rsync -az $srcinit $desinit
sed -i "/^port=/s/.*/port=$port/" $desinit
rsync -az $desinit /etc/init.d/

# init dbs:
mybase=/ROOT/server/mysql-5.6 && cd $mybase
./scripts/mysql_install_db \
		--user=mysql --datadir=/ROOT/data/mysql/$port \
		--defaults-file=/ROOT/data/mysql/$port/$port.cnf \
		> /dev/null

echo -e "\n\n\nstart mysql-$port manual:\n\e[32m/etc/init.d/mysqld-$port start && chkconfig mysqld-$port on\e[0m\n"

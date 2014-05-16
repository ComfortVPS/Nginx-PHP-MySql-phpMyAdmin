#!/bin/sh
# Script for automatically install Nginx + PHP(php-fpm) + MySql + phpMyAdmin

# Installation Requirement:
# CentOS 5.x 32 bit and 64 bit / CentOS 6.x 32 bit and 64 bit
# Guarantee Memory >= 128MB, Free Disk space >=2GB



########## Prepare repo for YUM ##########


arch=`uname -m`
OS_MAJOR_VERSION=`sed -rn 's/.*([0-9])\.[0-9].*/\1/p' /etc/redhat-release`
OS_MINOR_VERSION=`sed -rn 's/.*[0-9].([0-9]).*/\1/p' /etc/redhat-release`
if [ "$arch" = "x86_64" ]; then
	if [ "$OS_MAJOR_VERSION" = 5 ]; then
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm;
		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-5.rpm;
	else 
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm;
		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm;
	fi
else
	if [ "$OS_MAJOR_VERSION" = 5 ]; then
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm;
		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-5.rpm;
	else 
		rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm;
		rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm;
	fi
fi


cat > /etc/yum.repos.d/nginx.repo<<EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF

useradd myweb --home-dir=/www;




########## Install Nginx PHP MySql via YUM ##########

# You may want remove first if your server is not a clean OS
# yum -y remove httpd nginx php php-* mysqld;

yum -y install yum-fastestmirror;

yum --enablerepo=remi -y install make gcc gcc-c++ patch gcc-g77 flex bison tar unzip ntp pcre perl pcre-devel httpd-devel zlib zlib-devel GeoIP GeoIP-devel openssl openssl openssl-devel

yum --enablerepo=remi -y install nginx mysql mysql-server php php-common php-fpm php-mysql php-pgsql php-pecl-mongo php-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml php-pecl-apc php-cli php-pear php-pdo

service httpd stop; chkconfig httpd off;
service nginx start; chkconfig nginx on;
service mysqld start; chkconfig mysqld on;
service php-fpm start; chkconfig php-fpm on;




########## Download nginx config files ##########




wget --no-check-certificate -O /etc/nginx/nginx.conf https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-main-conf.txt;

wget --no-check-certificate -O /etc/nginx/conf.d/default.conf  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-default-conf.txt;

wget --no-check-certificate -O /etc/nginx/conf.d/example.com.conf  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-custom-config-example.txt;

wget --no-check-certificate -O /etc/nginx/conf.d/my_domain https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-my-domain-conf.txt;

rm -f /etc/nginx/conf.d/example_ssl.conf

service nginx restart;





########## Set up a random password for mysql ##########



pass1=`openssl rand 6 -base64`;
pass2="cft.${pass1}";
echo "mysql root password is ${pass2}";
mysqladmin -u root password "${pass2}";


mkdir -p /www/ip.com/custom_error_page;
cd /www/ip.com;


wget --no-check-certificate -O /www/ip.com/index.php  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-default-index.html;


wget --no-check-certificate -O /www/mysql-and-sftp-password.php  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-mysql-password.html;

sed -i "s/COMFORTVPSPASSWORD/${pass2}/g" /www/mysql-and-sftp-password.php;




########## Download error pages ##########

wget --no-check-certificate -O /www/ip.com/custom_error_page/404.html  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-404.html;
wget --no-check-certificate -O /www/ip.com/custom_error_page/403.html  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-403.html;
wget --no-check-certificate -O /www/ip.com/custom_error_page/50x.html  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/nginx-50x.html;






########## Install phpMyAdmin ##########

wget --no-check-certificate -O /www/ip.com/phpmyadmin_url.txt  https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/phpmyadmin_url.txt
wget --no-check-certificate -O /www/ip.com/phpMyAdmin4.tar.gz -i /www/ip.com/phpmyadmin_url.txt

tar -zxvf phpMyAdmin*.gz > /dev/null;
rm -f phpMyAdmin*.gz;
mv phpMyAdmin-*-all-languages phpMyAdmin4U;

echo myweb:"${pass2}" | chpasswd;
chown -R myweb:myweb /www;
chmod +x /www;
chmod +x -R /www/ip.com;


########## Display information after installation ##########

clear
echo -e "\n\n\n";
echo "====== Nginx + PHP-FPM + MYSQL Successfully installed";
echo "====== MySql root password is ${pass2}";
echo "====== SFTP Username is myweb";
echo "====== SFTP Password is ${pass2}";
echo "====== Website document root is /www/yourdomain";
echo "====== Add websites tutorials: http://goo.gl/sdDF9";
echo -e "\n\n\n";
echo "====== Now you can visit http://your-ip-address/ ";
echo "====== Eg. http://`hostname -i`/";
echo "====== phpMyAdmin: http://`hostname -i`/phpMyAdmin4U/";
echo -e "\n\n\n";
echo "====== More tutorials: http://goo.gl/tNFb0";
echo -e "\n\n\n\n";



########## Fast install command line ########## 
# What's you need to do is: Copy and post/run below single command line via SSH root login. Wait 5-15 minutes(depending on the software download speed from your server), Everything is Done!

# wget --no-check-certificate -O /tmp/install-nginx-php-mysql.sh https://raw.github.com/ComfortVPS/Nginx-PHP-MySql-phpMyAdmin/master/install-nginx-php-mysql.sh; sh /tmp/install-nginx-php-mysql.sh;




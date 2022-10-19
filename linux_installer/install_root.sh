#!/usr/bin/env bash


###############################################################################
# Functions                                                                   #
###############################################################################

function Mount_ARM(){

cd /home/$username/linux_installer

if [[ -d /mnt/ARM ]];
then
    echo 'Каталог /mnt/ARM уже существует' >> $log_file
else
		echo 'Создание каталога /mnt/ARM' >> $log_file
		mkdir /mnt/ARM
		if [[ $? -eq 0 ]];
    then
        echo 'Каталог /mnt/ARM создан' >> $log_file
    else
        echo 'Невозможно создать каталог /mnt/ARM' >> $log_file
    fi
fi

if [[ -d /mnt/ARM/APP ]];
then
    echo 'Каталог /mnt/ARM/APP уже монтирован' >> $log_file
else
    if [[ $distr = 'AstraLinux' ]];
    then
        echo 'Монтирование каталога' >> $log_file
				if [[ $domain = '' ]];
        then
            sudo mount -t cifs //$ip_mount/ARIADNA/ /mnt/ARM -o username=$username_share,rw,password=$password_share
				else
            sudo mount -t cifs //$ip_mount/ARIADNA/ /mnt/ARM -o username=$username_share,rw,password=$password_share,domain=$domain
				fi
    else
        echo 'Монтирование каталога' >> $log_file
				if [[ $domain = '' ]];
        then
            mount -t cifs //$ip_mount/ARIADNA/ /mnt/ARM -o username=$username_share,rw,password=$password_share
				else
            mount -t cifs //$ip_mount/ARIADNA/ /mnt/ARM -o username=$username_share,rw,password=$password_share,domain=$domain
				fi
			  echo 'Каталог с АРМами монтирован в каталог /mnt/ARM' >> $log_file
    fi
fi

if [[ -f updater.sh ]];
then
    echo 'updater.sh уже существует' >> $log_file
else
		cd /home/$username
		echo 'Создание updater.sh' >> $log_file
		touch updater.sh
		echo 'Файл updater.sh создан' >> $log_file
fi

if [[ $distr = 'AltLinux8' || $distr = 'AltLinux9' || $distr = 'Centos8' || $distr = 'RedOS' ]];
then
    {
      echo 'sleep 30'
      echo 'mount -t cifs //'$ip_mount'/ARIADNA/ /mnt/ARM -o username='$username_share',rw,password='$password_share''
      echo 'sleep 10'
      echo 'cp -a -u -f /mnt/ARM/APP/. /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo 'chown -R '$username':'$username' /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo 'chmod -R 777 /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo -e '\n'
    } > 'updater.sh'
fi

if [[ $distr = 'AstraLinux' || $distr = 'RosaLinux' || $distr = 'Ubuntu' ]];
then
    {
      echo 'sleep 30'
      echo 'sudo mount -t cifs //'$ip_mount'/ARIADNA/ /mnt/ARM -o username='$username_share',rw,password='$password_share''
      echo 'sleep 10'
      echo 'sudo cp -a -u -f /mnt/ARM/APP/. /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo 'chown -R '$username':'$username' /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo 'chmod -R 777 /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo -e '\n'
    } > 'updater.sh'
fi

if [[ $distr = 'AstraLinux' || $distr = 'RosaLinux' || $distr = 'Ubuntu' ]]; then
	sudo echo '@reboot sh /home/'$username'/updater.sh' > /var/spool/cron/root
	else
	echo '@reboot sh /home/'$username'/updater.sh' > /var/spool/cron/root
	fi

}

###############################################################################

function Install_Java(){

cd /home/$username/linux_installer

#Java 6 Version x32
if [[ $url_java = 'http://klokan.spb.ru/PUB/jre-6u45-linux-i586.bin' ]];
then

    if [ -d /opt/java/jre1.6.0_45 ];
    then
        echo 'Каталог /opt/java/jre1.6.0_45 уже создан, JAVA установлена' >> $log_file
		else
        echo 'Создание каталога /opt/java' >> $log_file
        mkdir /opt/java
    fi

    if [ -f jre-6u45-linux-i586.bin ];
    then
		    echo 'Дистрибутив JAVA уже скачан' >> $log_file
		else
				echo 'Дистрибутива JAVA нет' >> $log_file
				echo 'Скачивание дистрибутива java' >> $log_file
				wget $url_java
    fi

    if [ -d /home/$username/jre1.6.0_45 ];
    then
		    echo 'JAVA Распакована'  >> $log_file
		else
        echo 'Разархивация JAVA'  >> $log_file
        chmod a+x /home/$username/linux_installer/jre-6u45-linux-i586.bin
        /home/$username/linux_installer/jre-6u45-linux-i586.bin
        echo 'Удаление jre-6u45-linux-i586.bin' >> $log_file
        rm -f jre-6u45-linux-i586.bin
    fi

    if [ -d /opt/java/jre1.6.0_45 ];
    then
		    echo 'Найдена JAVA в каталоге /opt/java/jre1.6.0_45' >> $log_file
		else
        echo 'Перемещение каталога /home/'$username'/linux_installer/jre1.6.0_45 в /opt/java/jre1.6.0_45' >> $log_file
        mv /home/$username/linux_installer/jre1.6.0_45 /opt/java/jre1.6.0_45
        echo 'Каталог перемещен'  >> $log_file
        echo 'Регистрация JAVA в PATH' >> $log_file
        export PATH=$PATH:/opt/java/jre1.6.0_45/bin/
        echo 'PATH зарегистрирован' >> $log_file
    fi
fi

#Java 6 Version x64
if [[ $url_java = 'http://klokan.spb.ru/PUB/jre-6u45-linux-x64.bin' ]];
then

    if [ -d /opt/java/jre1.6.0_45 ];
    then
        echo 'Каталог /opt/java/jre1.6.0_45 уже создан, JAVA установлена' >> $log_file
		else
        echo 'Создание каталога /opt/java' >> $log_file
        mkdir /opt/java
    fi

    if [ -f jre-6u45-linux-x64.bin ];
    then
		    echo 'Дистрибутив JAVA уже скачан' >> $log_file
		else
				echo 'Дистрибутива JAVA нет' >> $log_file
				echo 'Скачивание дистрибутива java' >> $log_file
				wget $url_java
    fi

    if [ -d /home/$username/jre1.6.0_45 ];
    then
		    echo 'JAVA Распакована'  >> $log_file
		else
        echo 'Разархивация JAVA'  >> $log_file
        chmod a+x /home/$username/linux_installer/jre-6u45-linux-x64.bin
        /home/$username/linux_installer/jre-6u45-linux-x64.bin
        echo 'Удаление jre-6u45-linux-x64.bin' >> $log_file
        rm -f jre-6u45-linux-x64.bin
    fi

    if [ -d /opt/java/jre1.6.0_45 ];
    then
        echo 'Найдена JAVA в каталоге /opt/java/jre1.6.0_45' >> $log_file
		else
			  echo 'Перемещение каталога /home/'$username'/linux_installer/jre1.6.0_45 в /opt/java/jre1.6.0_45' >> $log_file
			  mv /home/$username/linux_installer/jre1.6.0_45 /opt/java/jre1.6.0_45
			  echo 'Каталог перемещен'  >> $log_file
			  echo 'Регистрация JAVA в PATH' >> $log_file
			  export PATH=$PATH:/opt/java/jre1.6.0_45/bin/
			  echo 'PATH зарегистрирован' >> $log_file
    fi
fi

#Java 8 Version x32
if [[ $url_java = 'http://klokan.spb.ru/PUB/jre-8u301-linux-i586.tar' ]];
then
    if [ -d /opt/java/jre1.8.0_301 ];
    then
        echo 'Каталог /opt/java/jre1.8.0_301 уже создан, JAVA установлена' >> $log_file
		else
        echo 'Создание каталога /opt/java' >> $log_file
        mkdir /opt/java
    fi

    if [ -f jre-8u301-linux-i586.tar ];
    then
		    echo 'Дистрибутив JAVA уже скачан' >> $log_file
    else
        echo 'Дистрибутива JAVA нет' >> $log_file
        echo 'Скачивание дистрибутива java' >> $log_file
				wget $url_java
    fi

    if [ -d /home/$username/jre1.8.0_301 ];
    then
		    echo 'JAVA Распакована'  >> $log_file
		else
        echo 'Разархивация JAVA'  >> $log_file
			  tar -xf /home/$username/linux_installer/jre-8u301-linux-i586.tar
			  echo 'Удаление jre-8u301-linux-i586.tar' >> $log_file
        rm -f jre-8u301-linux-i586.tar
    fi

    if [ -d /opt/java/jre1.8.0_301 ];
    then
		    echo 'Найдена JAVA в каталоге /opt/java/jre1.8.0_301' >> $log_file
    else
        echo 'Перемещение каталога /home/'$username'/linux_installer/jre1.8.0_301 в /opt/java/jre1.8.0_301' >> $log_file
        mv /home/$username/linux_installer/jre1.8.0_301 /opt/java/jre1.8.0_301
        echo 'Каталог перемещен'  >> $log_file
        echo 'Регистрация JAVA в PATH' >> $log_file
        export PATH=$PATH:/opt/java/jre1.8.0_301/bin/
        echo 'PATH зарегистрирован' >> $log_file
    fi
fi

#Java 8 Version x64
if [[ $url_java = 'http://klokan.spb.ru/PUB/jre-8u301-linux-x64.tar' ]];
then
    if [ -d /opt/java/jre1.8.0_301 ];
    then
        echo 'Каталог /opt/java/jre1.8.0_301 уже создан, JAVA установлена' >> $log_file
		else
        echo 'Создание каталога /opt/java' >> $log_file
        mkdir /opt/java
    fi

    if [ -f jre-8u301-linux-x64.tar ];
    then
		    echo 'Дистрибутив JAVA уже скачан' >> $log_file
    else
				echo 'Дистрибутива JAVA нет' >> $log_file
				echo 'Скачивание дистрибутива java' >> $log_file
				wget $url_java
    fi

    if [ -d /home/$username/jre1.8.0_301 ];
    then
		    echo 'JAVA Распакована'  >> $log_file
    else
        echo 'Разархивация JAVA'  >> $log_file
        tar -xf /home/$username/linux_installer/jre-8u301-linux-x64.tar
        echo 'Удаление jre-8u301-linux-x64.tar' >> $log_file
        rm -f jre-8u301-linux-x64.tar
    fi

    if [ -d /opt/java/jre1.8.0_301 ];
    then
		    echo 'Найдена JAVA в каталоге /opt/java/jre1.8.0_301' >> $log_file
    else
        echo 'Перемещение каталога /home/'$username'/linux_installer/jre1.8.0_301 в /opt/java/jre1.8.0_301' >> $log_file
        mv /home/$username/linux_installer/jre1.8.0_301 /opt/java/jre1.8.0_301
        echo 'Каталог перемещен'  >> $log_file
        echo 'Регистрация JAVA в PATH' >> $log_file
        export PATH=$PATH:/opt/java/jre1.8.0_301/bin/
        echo 'PATH зарегистрирован' >> $log_file
    fi
fi

if [[ $distr = 'AltLinux8' ]]; then
    apt-get install i586-libXtst.32bit -y
fi

if [[ $distr = 'AltLinux9' ]]; then
    apt-get install i586-libXtst.32bit i586-libnsl1.32bit libnsl1 -y
fi

if [[ $distr = 'Ubuntu' ]]; then
    apt-get apt-get install libxtst6:i386 -y
fi

if [[ $distr = 'Centos8' ]]; then
    wget http://repo.okay.com.mx/centos/8/x86_64/release/libXtst-1.2.3-7.el8.x86_64.rpm
    rpm -ivh libXtst-1.2.3-7.el8.x86_64.rpm
    rm libXtst-1.2.3-7.el8.x86_64.rpm
    yum install libnsl.i686 -y
    yum install libnsl.x86_64 -y
fi

}

###############################################################################

function Install_Wine() {

cd /home/$username/linux_installer

if [[ $distr = 'AstraLinux' ]];
then
  	echo 'Установка wine, конфигурация AstraLinux' >> $log_file
  	apt-get update && apt-get upgrade -y
  	apt-get install wine winetricks zenity -y
fi

if [[ $distr = 'Ubuntu' ]];
then
  	echo 'Установка wine, конфигурация Ubuntu' >> $log_file
  	apt-get update && apt-get upgrade -y
  	apt-get install wine winetricks zenity -y
fi

if [[ $distr = 'AltLinux8' ]];
then
  	echo 'Установка wine, конфигурация AltLinux8' >> $log_file
  	apt-get update && apt-get dist-upgrade -y
    if [[ $longbit -eq 0 ]];
    then
        ## /bin/bash /home/$username/linux_installer/alt_wine_install_8.sh
        apt-get install i586-wine.32bit wine-gecko wine-mono winetricks -y
    else
  	    apt-get install i586-wine.32bit wine-gecko wine-mono winetricks -y
    fi
fi

if [[ $distr = 'AltLinux9' ]];
then
  	echo 'Установка wine, конфигурация AltLinux9' >> $log_file
  	apt-get update && apt-get dist-upgrade -y
  	apt-get install i586-wine.32bit wine-mono winetricks -y
fi

if [[ $distr = 'RedOS' ]];
then
  	echo 'Установка wine, конфигурация RedOS' >> $log_file
  	yum update && yum upgrade -y
  	yum install wine winetricks wine-mono -y
fi

if [[ $distr = 'RosaLinux' ]];
then
  	echo 'Установка wine, конфигурация RosaLinux' >> $log_file
  	yum update && yum upgrade -y
  	sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
  	cd /home/$username/linux_installer
  	mkdir /home/$username/linux_installer/cache_rpm
  	cd /home/$username/linux_installer
  	yumdownloader p11-kit-0.20.7-3.res7.i686.rpm
  	rpm -ivh p11-kit-0.20.7-3.res7.i686.rpm --replacefiles
  	yum install audit-libs.i686 cracklib.i686 libdb.i686 libselinux.i686 libsepol.i686 pcre.i686 -y
  	yumdownloader pam-1.1.8-18.res7.i686.rpm
  	rpm -ivh pam-1.1.8-18.res7.i686.rpm --replacefiles
  	yumdownloader pango-1.36.8-2.res7.i686
  	rpm -ivh pango-1.36.8-2.res7.i686.rpm --replacefiles
  	yumdownloader nss-3.28.4-11.res7c.i686
  	yumdownloader nss-pem-1.0.3-4.res7.i686.rpm
  	rpm -ivh nss-3.28.4-11.res7c.i686.rpm nss-pem-1.0.3-4.res7.i686.rpm --replacefiles
  	yum install gcc.i686 libffi.i686 glib2.i686 libthai.i686 cairo.i686 libXft.i686 harfbuzz.i686 nspr.i686 nss-util.i686 nss-softokn.i686 cabextract -y
  	yum install wine.i686 -y
  	rm -rf *.rpm
fi

if [[ $distr = 'Centos8' ]];
then
  	echo 'Установка wine, конфигурация Centos8' >> $log_file
  	yum update && yum upgrade -y
  	dnf groupinstall 'Development Tools' -y
  	dnf -y install epel-release
  	yum -y install libxslt-devel libpng-devel libX11-devel zlib-devel dbus-devel libtiff-devel freetype-devel libjpeg-turbo-devel  fontconfig-devel gnutls-devel gstreamer1-devel libxcb-devel  libxml2-devel libgcrypt-devel libXcursor-devel libXi-devel libXrandr-devel libXfixes-devel libXinerama-devel libXcomposite-devel libpcap-devel libv4l-devel libgphoto2-devel libusb-devel gstreamer1-devel libgudev SDL2-devel mesa-libOSMesa-devel gsm-devel libudev-devel libvkd3d-devel
  	sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
  	cd /home/$username/linux_installer
  	mkdir /home/$username/linux_installer/cache_rpm
  	cd /home/$username/linux_installer
  	wget -P /etc/yum.repos.d/ ftp://ftp.stenstorp.net/wine32.repo
  	wget http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/SDL2-2.0.10-2.el8.i686.rpm
  	wget http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/glibc-2.28-151.el8.i686.rpm
  	wget http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/libgcc-8.4.1-1.el8.i686.rpm
  	wget http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/libstdc++-8.4.1-1.el8.i686.rpm
  	wget http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/spirv-tools-libs-2020.5-3.20201208.gitb27b1af.el8.i686.rpm
  	wget https://pkgs.dyn.su/el8/extras/x86_64/libvkd3d-shader-1.2-2.el8.i686.rpm
  	wget https://pkgs.dyn.su/el8/extras/x86_64/libvkd3d-1.2-2.el8.i686.rpm
  	rpm -ivh glibc-2.28-151.el8.i686.rpm SDL2-2.0.10-2.el8.i686.rpm libgcc-8.4.1-1.el8.i686.rpm libstdc++-8.4.1-1.el8.i686.rpm spirv-tools-libs-2020.5-3.20201208.gitb27b1af.el8.i686.rpm libvkd3d-shader-1.2-2.el8.i686.rpm
  	dnf install wine wine.i686 -y
  	yum install winetricks -y
  	rm -rf *.rpm
  	yum install libreoffice -y
fi
}

###############################################################################

function Run_Crontab() {
    if [[ 'AstraLinux' || $distr = 'RosaLinux' || $distr = 'Ubuntu' ]];
    then
        sudo systemctl enable cron
        sudo systemctl start cron
    fi

    systemctl enable crond
    systemctl start crond
    echo 'Служба Crontab включена, автозапуск добавлен' >> $log_file
}

###############################################################################

function Host_for_oracle_client() {
    echo '127.0.0.1	'$HOSTNAME' localhost' > /etc/hosts
}

###############################################################################

case $EUID in
   0) ;;
   *) echo "Требуется повышение привилегий - введите пароль root:"
      su root -c $0 "$@" ;;
esac

if [ $EUID == 0 ];
then

  ###############################################################################
  # Variables                                                                   #
  ###############################################################################

  username=''
  ip_mount=''
  username_share=''
  password_share=''
  domain=''

  #Варианты AltLinux8,AltLinux9,RedOS,AstraLinux,RosaLinux,Ubuntu,Centos8
  distr=''
  url_java=""

  source ./main.cfg

  log_file="/home/$username/linux_installer/install_log.log"

  ###############################################################################
  # Load CFG                                                                    #
  ###############################################################################


  if ! [ -f $log_file ];
  then
    touch $log_file
  fi

  if ! [[ -f $log_file ]];
  then
    mkdir /home/$username/linux_installer
    touch /home/$username/linux_installer/install_log.log
    echo "[INFO] Файл логов создан." >> /home/$username/linux_installer/install_log.log
  fi

  Mount_ARM
  Install_Java
  Install_Wine
  Run_Crontab
  Host_for_oracle_client
fi

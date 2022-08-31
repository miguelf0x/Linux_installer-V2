#!/usr/bin/env bash


##############################################################################
#                              genconfig script    							             #
#                                                                            #
# This script is designed for configuring ARIADNA MIS installer for Linux OS #
#                                                                            #
##############################################################################

###############################################################################
# Variables                                                                   #
###############################################################################

username='username'
ip_mount='192.168.0.0'
username_share='share'
password_share=''
domain=''
distr=''	      # AltLinux8,AltLinux9,RedOS,AstraLinux,RosaLinux,Ubuntu,Centos8
icon_version=0  # 6 для Java 6, 8 для Java 8
url_java=''
name_db=''              #Название БД(обычно MED)
ip_base='192.168.0.0'   #IP сервера с БД
oracle_version=''
postgre_sql=''		#При использовании указать версию 13.
java_home=''
msoffice=1  # не используется по умолчанию
long_bit=2  # 0 - true

#Ссылка на клиенты Oracle, можно указать на локальный каталог(Опционально)
url_oracle_client_11='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/XP_WIN2003_client_32bit/oracle_client_x32.tar'
url_oracle_client_12='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/win32_12201_client.tar'
url_instant_client='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/instant_client19.tar'

#Ссылка на PostgreSQLODBC, можно указать на локальный каталог(Опционально)
url_postgre_sql='https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc_13_01_0000-x86.zip'

libre_office_home='/usr/lib64/LibreOffice/program/classes/'
libre_office_install_location='/usr/lib64/LibreOffice/'

###############################################################################
# Functions                                                                   #
###############################################################################

function Get_Base_Info(){

    read -r -p "Введите имя пользователя: " response
    username=$response

    until [[ $ip_mount =~ ^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$ ]]
    do
      read -r -p "Введите IP-адрес сетевой папки: " response
      ip_mount=$response
    done

    read -r -p "Введите имя аккаунта с доступом к папке ARIADNA: " response
    username_share=$response

    read -r -p "Введите пароль от данного аккаунта: " response
    password_share=$response

    read -r -p "Введите доменное имя [при наличии]: " response
    domain=$response

}

##############################################################################

function Select_Distro(){

    echo "Полуавтоматическая установка доступна для дистрибутивов:"
    echo "1. Alt Linux 8"
    echo "2. Alt Linux 9"
    echo "3. RedOS"
    echo "4. Astra Linux"
    echo "5. ROSA Linux"
    echo "6. Ubuntu"
    echo "7. CentOS 8"

    while [[ $distr = "" ]]
    do
        read -r -p "Введите порядковый номер используемого дистрибутива: " response
        if [[ $response -eq 1 ]];
        then
            distr='AltLinux8'
        elif [[ $response -eq 2 ]];
        then
            distr='AltLinux9'
        elif [[ $response -eq 3 ]];
        then
            distr='RedOS'
        elif [[ $response -eq 4 ]];
        then
            distr='AstraLinux'
        elif [[ $response -eq 5 ]];
        then
            distr='RosaLinux'
        elif [[ $response -eq 6 ]];
        then
            distr='Ubuntu'
        elif [[ $response -eq 7 ]];
        then
            distr='Centos8'
        else
            echo "Некорректный ввод."
        fi
    done

}

##############################################################################

function Select_Java_Version(){

    if [[ $(getconf LONG_BIT) -eq 64 ]];
    then

        longbit=0
        echo "Доступны следующие дистрибутивы Java:"
        echo "1. Java Runtime Environment 8 x64"
        echo "2. Java Runtime Environment 6 x64"

        while [[ $url_java = "" ]]
        do
            read -r -p "Выберите версию дистрибутива Java: " response
            if [[ $response -eq 1 ]];
            then
                url_java="http://klokan.spb.ru/PUB/jre-8u301-linux-x64.tar.gz"
				        java_home='/opt/java/jre1.8.0_301'
                icon_version=8
            elif [[ $response -eq 2 ]];
            then
                url_java="http://klokan.spb.ru/PUB/jre-6u45-linux-x64.bin"
				        java_home='/opt/java/jre1.6.0_45'
                icon_version=6
            else
                echo "Некорректный ввод."
            fi
        done

    else

        longbit=1
        echo "Доступны следующие дистрибутивы Java:"
        echo "1. Java Runtime Environment 8 i586"
        echo "2. Java Runtime Environment 6 i586"

        while [[ $url_java = "" ]]
        do
            read -r -p "Выберите версию дистрибутива Java: " response
            if [[ $response -eq 1 ]];
            then
                url_java="http://klokan.spb.ru/PUB/jre-8u301-linux-i586.tar.gz"
				        java_home='/opt/java/jre1.8.0_301'
                icon_version=8
            elif [[ $response -eq 2 ]];
            then
                url_java="http://klokan.spb.ru/PUB/jre-6u45-linux-i586.bin"
				        java_home='/opt/java/jre1.6.0_45'
                icon_version=6
            else
                echo "Некорректный ввод."
            fi
        done

    fi

}

##############################################################################

function Get_DB_Info(){

	echo "Допустимые версии Oracle Client:"
	echo "1. Oracle Client 12"
	echo "2. Oracle InstantClient [работает с АРМ после обновления от 28.05.20]"
	echo "3. Oracle Client 11"

	while [[ $oracle_version = "" ]]
      do
          read -r -p "Введите порядковый номер необходимой версии: " response
          if [[ $response -eq 1 ]];
          then
              oracle_version='12'

              read -r -p "Использовать адрес для скачивания клиента Oracle по умолчанию? [д/Н] " response
          	  if [[ "$response" =~ ^([nN][oO]|[nN]|[нН][еЕ][тТ]|[нН])$ ]]
          	  then
          		    read -r -p "Введите URL или локальный каталог" response
                  url_oracle_client_12=response
          	  fi

          elif [[ $response -eq 2 ]];
          then

              oracle_version='InstantClient'

              read -r -p "Использовать адрес для скачивания клиента Oracle по умолчанию? [д/Н] " response
          	  if [[ "$response" =~ ^([nN][oO]|[nN]|[нН][еЕ][тТ]|[нН])$ ]]
          	  then
          		    read -r -p "Введите URL или локальный каталог" response
                  url_instant_client=response
          	  fi

          elif [[ $response -eq 3 ]];
          then

              oracle_version='11'

              read -r -p "Использовать адрес для скачивания клиента Oracle по умолчанию? [д/Н] " response
          	  if [[ "$response" =~ ^([nN][oO]|[nN]|[нН][еЕ][тТ]|[нН])$ ]]
          	  then
          		    read -r -p "Введите URL или локальный каталог" response
                  url_oracle_client_11=response
          	  fi

          else
  			      echo "Некорректный ввод."
  		    fi
      done

    read -r -p "Будет ли использоваться PostgreSQL [работает с АРМ после обновления от 23.08.21]? [д/Н] " response
	  if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[дД][аА]|[дД])$ ]]
	  then
		    postgre_sql='13'
        read -r -p "Использовать адрес для скачивания PostgreSQLODBC по умолчанию? [д/Н] " response
        if [[ "$response" =~ ^([nN][oO]|[nN]|[нН][еЕ][тТ]|[нН])$ ]]
        then
            read -r -p "Введите URL или локальный каталог" response
            url_postgre_sql=response
        fi
	  fi

    read -r -p "Для печати будет использоваться Microsoft Office? [д/Н] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[дД][аА]|[дД])$ ]]
    then
        msoffice=0
    fi

    read -r -p "Введите имя БД: " response
    name_db=$response

    until [[ response =~ ^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$ ]]
    do
      read -r -p "Введите IP-адрес БД: " response
      ip_base=$response
    done
}

##############################################################################

function Generate_Config(){

    echo "# Имя пользователя" > ./main.cfg
    echo "username=$username" >> ./main.cfg
    echo "" >> ./main.cfg
    echo "# IP-адрес общей папки" >> ./main.cfg
    echo "ip_mount=$ip_mount" >> ./main.cfg
    echo "# Имя пользователя с доступом к общей папке" >> ./main.cfg
    echo "username_share=$username_share" >> ./main.cfg
    echo "# Пароль пользователя с доступом к общей папке" >> ./main.cfg
    echo "password_share=$password_share" >> ./main.cfg
    echo "# Домен (при необходимости)" >> ./main.cfg
    echo "domain=$domain" >> ./main.cfg
    echo "" >> ./main.cfg
    echo "# Дистрибутив" >> ./main.cfg
    echo "distr=$distr" >> ./main.cfg
    echo "# Разрядность системы" >> ./main.cfg
    echo "longbit=$longbit" >> ./main.cfg
    echo "" >> ./main.cfg
    echo "# Версия ярлыков" >> ./main.cfg
    echo "icon_version=$icon_version" >> ./main.cfg
    echo "# URL для скачивания JRE" >> ./main.cfg
    echo "url_java=$url_java" >> ./main.cfg
    echo "# Имя БД" >> ./main.cfg
    echo "name_db=$name_db" >> ./main.cfg
    echo "# IP-адрес БД" >> ./main.cfg
    echo "ip_base=$ip_base" >> ./main.cfg
    echo "# Версия Oracle Client" >> ./main.cfg
    echo "oracle_version=$oracle_version" >> ./main.cfg
    echo "# Версия PostgreSQL" >> ./main.cfg
    echo "postgre_sql=$postgre_sql" >> ./main.cfg
    echo "# Домашний каталог JRE" >> ./main.cfg
    echo "java_home=$java_home" >> ./main.cfg
    echo "# Признак использования MS Office [0 - да]" >> ./main.cfg
    echo "msoffice=$msoffice" >> ./main.cfg
    echo "# Домашний каталог LibreOffice" >> ./main.cfg
    echo "libre_office_home=$libre_office_home" >> ./main.cfg
    echo "# Расположение LibreOffice" >> ./main.cfg
    echo "libre_office_install_location=$libre_office_install_location" >> ./main.cfg
    echo "# Конфиг создан $(date)" >> ./main.cfg

    if [[ -f main.cfg ]];
    then
        echo "main.cfg создан успешно"
        echo "main.cfg создан успешно" >> /home/$username/linux_installer/install_log.log
    fi

}

##############################################################################

Select_Distro
Get_Base_Info
Select_Java_Version
Get_DB_Info
Generate_Config

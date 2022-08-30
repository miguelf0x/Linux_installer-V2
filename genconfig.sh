#!/usr/bin/env bash


##############################################################################
#                              genconfig script    							 #
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
distr=''	#Варианты AltLinux8,AltLinux9,RedOS,AstraLinux,RosaLinux,Ubuntu,Centos8
url_java=''
name_db=''      		#Название БД(обычно MED)
ip_base='192.168.0.0'  	#IP сервера с БД
oracle_version=''
postgre_sql=''		#При использовании указать версию 13.
java_home=''

#Ссылка на Oracle Client 11, можно указать на локальный каталог(Опционально)
url_oracle_client_11='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/XP_WIN2003_client_32bit/oracle_client_x32.tar'

#Ссылка на Oracle Client 12, можно указать на локальный каталог(Опционально)
url_oracle_client_12='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/win32_12201_client.tar'

#Ссылка на Instant Client, можно указать на локальный каталог(Опционально) 
url_instant_client='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/instant_client19.tar'

#Ссылка на PosgreSQLODBC, можно указать на локальный каталог(Опционально) 
url_postgre_sql='https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc_13_01_0000-x86.zip'

###############################################################################
# Functions                                                                   #
###############################################################################

function Get_Base_Info(){

    read -r -p "Введите имя пользователя: " response
    username=$response

    read -r -p "Введите IP-адрес сервера данных: " response
    ip_mount=$response

    read -r -p "Введите имя аккаунта с доступом к папке ARIADNA: " response
    username_share=$response

    read -r -p "Введите пароль от данного аккаунта: " response
    password_share=$response

    read -r -p "Введите доменное имя [при наличии]: " response
    domain=$response

}

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

function Select_Java_Version(){

    if [[ $(getconf LONG_BIT) -eq 64 ]];
    then

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
            elif [[ $response -eq 2 ]];
            then
                url_java="http://klokan.spb.ru/PUB/jre-6u45-linux-x64.bin"
				java_home='/opt/java/jre1.6.0_45'
            else
                echo "Некорректный ввод."
            fi
        done

    else

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
            elif [[ $response -eq 2 ]];
            then
                url_java="http://klokan.spb.ru/PUB/jre-6u45-linux-i586.bin"
				java_home='/opt/java/jre1.6.0_45'
            else
                echo "Некорректный ввод."
            fi
        done

    fi

}

function Get_DB_Info(){
	
	source ./config.source
	
	echo "Допустимые версии Oracle Client:"
	echo "1. Oracle Client 12"
	echo "2. Oracle InstantClient"
	echo "3. Oracle Client 11"

	while [[ $oracle_version = "" ]]
    do
        read -r -p "Введите порядковый номер необходимой версии: " response
        if [[ $response -eq 1 ]];
        then
            oracle_version='12'
			#TODO: добавить ручной ввод URL
        elif [[ $response -eq 2 ]];
        then
            oracle_version='InstantClient'
			#TODO: добавить ручной ввод URL
        elif [[ $response -eq 3 ]];
        then
			oracle_version='11'
			#TODO: добавить ручной ввод URL
		else
			echo "Некорректный ввод."
		fi
	done

    read -r -p "Будет ли использоваться PostgreSQL? [д/Н] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY]|[дД]|[дД][аА])$ ]]
	then
		postgre_sql='13'
		#TODO: добавить ручной ввод URL
	fi
 
}

function Generate_Config(){
	echo "username=$username" > ./config.source
    echo "distr=$distr" >> ./config.source
    echo "source.config записан!" >> /home/$username/linux_installer/install_log.log
}
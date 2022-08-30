#!/usr/bin/env bash

###############################################################################
# Variables                                                                   #
###############################################################################

username=''
distr=''

#InstantClient работает с АРМами после обновления от 28.05.20
#PosgreSQLODBC работает с АРМами после обновления от 23.08.21
oracle_version='' 	#Приоритет использования версий: 12, InstantClient, 11.
postgre_sql=''		#При использовании указать версию 13.

#Ссылки на Oracle Client, можно указать на локальный каталог(Опционально)
url_oracle_client_11='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/XP_WIN2003_client_32bit/oracle_client_x32.tar'
url_oracle_client_12='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/win32_12201_client.tar'
url_instant_client='http://klokan.spb.ru/PUB/oraarch/ORACLE%20CLIENT/instant_client19.tar'

#Ссылка на PosgreSQLODBC, можно указать на локальный каталог(Опционально)
url_postgre_sql='https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc_13_01_0000-x86.zip'
wine=''

###############################################################################
# Load CFG                                                                    #
###############################################################################

source ./main.cfg


###############################################################################
# Functions                                                                   #
###############################################################################


###############################################################################
# Install Wine and stuff                                                      #
###############################################################################

function Select_Wine() {

	if [ -f /usr/bin/wine ];
	then
			wine='/usr/bin/wine'
	elif [ -f /usr/bin/wine64 ];
	then
			wine='/usr/bin/wine64'
	else
			echo "ERR: No Wine found" >> /home/$username/linux_installer/install_log.log
	fi

}

function Install_Winetricks() {

if [ -d /home/$username/.wine ];
then

	winetricks ie8
	winetricks vb6run
	winetricks mdac28
	winetricks vcrun6
	winetricks vcrun2010
	winetricks vcrun2005

else

	if [[ $distr = 'AstraLinux' || $distr = 'Ubuntu' ]];
	then
		WINEARCH=win32 winecfg
	fi

	if [ $distr = 'Centos8' ];
	then
		WINEARCH=win32 WINEPREFIX=~/.wine $wine wineboot
	fi

	if [ $distr = 'RosaLinux' ];
	then
		cd /home/$username
		wget http://www.kegel.com/wine/winetricks
		chmod a+x winetricks
	fi

	winecfg
	winetricks ie8
	winetricks vb6run
	winetricks mdac28
	winetricks vcrun6
	winetricks vcrun2010
	winetricks vcrun2005

	if [ $distr = 'Centos8' ];
	then
		$wine ~/.cache/winetricks/vcrun2010/vcredist_x86.exe
		$wine ~/.cache/winetricks/vcrun2005/vcredist_x86.exe
	fi

	if [ $distr = 'AltLinux8' || $distr = 'AltLinux9' ];
	then
		cd ~/.cache/winetricks/vcrun2005
		$wine vcredist_x86.EXE
		cd ~/.cache/winetricks/vcrun2010
		$wine vcredist_x86.EXE
	fi

fi


if [[ $distr = 'Ubuntu' || $distr = 'Centos8' ]];
then
	winetricks ie8
fi

if [ $distr = 'AstraLinux' ];
then

	cd /home/$username/linux_installer

	if [ -f wine_gecko-2.47-x86.msi ];
	then
		echo 'wine_gecko-2.47-x86.msi уже скачан' >> /home/$username/linux_installer/install_log.log
	else
		echo 'Загрузка wine_gecko-2.47-x86.msi' >> /home/$username/linux_installer/install_log.log
		wget http://dl.winehq.org/wine/wine-gecko/2.47/wine_gecko-2.47-x86.msi
	fi

	$wine msiexec /i wine_gecko-2.47-x86.msi

	if [ -f wine_gecko-2.47-x86_64.msi ];
	then
		echo 'wine_gecko-2.47-x86.msi уже скачан' >> /home/$username/linux_installer/install_log.log
	else
		echo 'Загрузка wine_gecko-2.47-x86.msi' >> /home/$username/linux_installer/install_log.log
		wget http://dl.winehq.org/wine/wine-gecko/2.47/wine_gecko-2.47-x86_64.msi
	fi

	$wine msiexec /i wine_gecko-2.47-x86_64.msi

fi
}

function Install_Oracle_12() {

cd /home/$username/linux_installer

if [ $oracle_version = '12' ];
then

	if [ -f win32_12201_client.tar ];
	then
		echo 'Дистрибутив OracleClient уже скачан' >> /home/$username/linux_installer/install_log.log
	else
		echo 'Дистрибутива OracleClient нет' >> /home/$username/linux_installer/install_log.log
		echo 'Скачивание дистрибутива OracleClient' >> /home/$username/linux_installer/install_log.log
		wget $url_oracle_client_12
		mkdir /home/$username/.wine/drive_c/distrib
		cp /home/$username/linux_installer/win32_12201_client.tar /home/$username/.wine/drive_c/distrib/win32_12201_client.tar
	fi

	if [ -d /home/$username/.wine/drive_c/distrib/client32 ];
	then
		cd /home/$username/.wine/drive_c/distrib/client32
	else
		cd /home/$username/.wine/drive_c/distrib
		echo'Распаковка win32_12201_client.tar' >> /home/$username/linux_installer/install_log.log
		tar -xvf win32_12201_client.tar
		cd /home/$username/.wine/drive_c/distrib/client32
	fi

	if [ -f setup.exe ];
	then
		echo 'Установка OracleClient' >> /home/$username/linux_installer/install_log.log
		$wine setup.exe -ignorePrereq -J"-Doracle.install.client.validate.clientSupportedOSCheck=false"
	else
		echo 'ERR: Setup.exe не найден' >> /home/$username/linux_installer/install_log.log
	fi

fi

}

function Install_Oracle_11() {

cd /home/$username/linux_installer

if [ $oracle_version = '11' ];
then

	if [ -f oracle_client_x32.tar ];
	then
		echo 'Дистрибутив OracleClient уже скачан' >> /home/$username/linux_installer/install_log.log
	else
		echo 'Дистрибутива OracleClient нет' >> /home/$username/linux_installer/install_log.log
		echo 'Скачивание дистрибутива OracleClient' >> /home/$username/linux_installer/install_log.log
		wget $url_oracle_client_11
		mkdir /home/$username/.wine/drive_c/distrib
		cp /home/$username/linux_installer/oracle_client_x32.tar /home/$username/.wine/drive_c/distrib/oracle_client_x32.tar
	fi

	if [ -d /home/$username/.wine/drive_c/distrib/client32 ];
	then
		cd /home/$username/.wine/drive_c/distrib/client32
	else
		echo'Распаковка oracle_client_x32.tar' >> /home/$username/linux_installer/install_log.log
		tar -xvf oracle_client_x32.tar
		cd /home/$username/.wine/drive_c/distrib/client
	fi

	if [ -f setup.exe ];
	then
		echo 'Установка OracleClient' >> /home/$username/linux_installer/install_log.log
		$wine setup.exe
	else
		echo 'ERR: Setup.exe не найден' >> /home/$username/linux_installer/install_log.log
	fi

fi

}

function Install_Oracle_Instant() {

	cd /home/$username/linux_installer

if [ $oracle_version = 'InstantClient' ];
then

	if [ -d /home/$username/.wine/drive_c/oracle ];
	then
		echo 'Каталог /home/$username/.wine/drive_c/oracle уже создан' >> /home/$username/linux_installer/install_log.log
	else
		mkdir /home/$username/.wine/drive_c/oracle
	fi

	if [ -f instant_client19 ];
	then
		echo 'Дистрибутив oracle_instantclient19 уже скачан' >> /home/$username/linux_installer/install_log.log
	else
		echo 'Дистрибутива oracle_instantclient19 нет' >> /home/$username/linux_installer/install_log.log
		echo 'Скачивание дистрибутива oracle_instantclient19' >> /home/$username/linux_installer/install_log.log
		wget $url_instant_client
	fi

	if [ -d /home/$username/linux_installer/instant_client ];
	then
		echo 'Копирование instant_client в /home/'$username'/.wine/drive_c/oracle' >> /home/$username/linux_installer/install_log.log
		cp -a -u -f /home/$username/linux_installer/instant_client/. /home/$username/.wine/drive_c/oracle
	else
		echo 'Распаковка oracle_instantclient19.tar' >> /home/$username/linux_installer/install_log.log
		tar -xvf instant_client19.tar
		echo 'Копирование instant_client в /home/'$username'/.wine/drive_c/oracle' >> /home/$username/linux_installer/install_log.log
		cp -a -u -f /home/$username/linux_installer/instant_client/. /home/$username/.wine/drive_c/oracle
	fi

fi

}

function Install_Postgre_Sql() {

	cd /home/$username/linux_installer

if [ $postgre_sql = '13' ];
then

	if [ -f psqlodbc_13_01_0000-x86.zip ];
	then
		echo 'Дистрибутив PostgreSQL Client уже скачан' >> /home/$username/linux_installer/install_log.log
	else
		echo 'Дистрибутива PostgreSQL Client нет' >> /home/$username/linux_installer/install_log.log
		echo 'Скачивание дистрибутива PostgreSQL Client' >> /home/$username/linux_installer/install_log.log
		wget $url_postgre_sql --no-check-certificate
		mkdir /home/$username/.wine/drive_c/distrib
		cp /home/$username/linux_installer/psqlodbc_13_01_0000-x86.zip /home/$username/.wine/drive_c/distrib/psqlodbc_13_01_0000-x86.zip
	fi

	if [ -d /home/$username/.wine/drive_c/distrib ];
	then
		cd /home/$username/.wine/drive_c/distrib
	else
		cd /home/$username/.wine/drive_c/distrib
		echo 'Распаковка psqlodbc_13_01_0000-x86.zip' >> /home/$username/linux_installer/install_log.log
		unzip psqlodbc_13_01_0000-x86.zip
	fi

	if [ -f psqlodbc_x86.msi ];
	then
		echo 'Установка PostgreSQL Client' >> /home/$username/linux_installer/install_log.log
		$wine start psqlodbc_x86.msi
	else
		echo 'ERR: psqlodbc_x86.msi не найден' >> /home/$username/linux_installer/install_log.log
	fi

fi

}


function Cp_Arm(){

	if [ -d /mnt/ARM/APP ]; then
      echo 'Копирование АРМов с монтированного каталога на локальный'
      echo 'Копирование АРМов с монтированного каталога на локальный' >> /home/$username/linux_installer/install_log.log

	if [ -d /home/$username/.wine/drive_c/ARIADNA ]; then
      echo 'Каталог /home/'$username'/.wine/drive_c/ARIADNA создан'
      echo 'Каталог /home/'$username'/.wine/drive_c/ARIADNA создан' >> /home/$username/linux_installer/install_log.log
	else
      echo 'Создание каталога /home/'$username'/.wine/drive_c/ARIADNA'
      echo 'Создание каталога /home/'$username'/.wine/drive_c/ARIADNA' >> /home/$username/linux_installer/install_log.log
      mkdir /home/$username/.wine/drive_c/ARIADNA
	fi

  if [ -d /home/$username/.wine/drive_c/ARIADNA/APP ]; then
      echo 'Каталог /home/'$username'/.wine/drive_c/ARIADNA/APP создан'
	    echo 'Каталог /home/'$username'/.wine/drive_c/ARIADNA/APP создан' >> /home/$username/linux_installer/install_log.log
	else
      echo 'Создание каталога /home/'$username'/.wine/drive_c/ARIADNA/APP'
      echo 'Создание каталога /home/'$username'/.wine/drive_c/ARIADNA/APP' >> /home/$username/linux_installer/install_log.log
      mkdir /home/$username/.wine/drive_c/ARIADNA/APP
	fi

	cp -r /mnt/ARM/APP/. /home/$username/.wine/drive_c/ARIADNA/APP
  		else
  		echo 'ERR: Каталог /mnt/ARM/APP/ не монтирован' >> /home/$username/linux_installer/install_log.log
	fi
}


function Create_C_ico_legacy(){

  local catalog_ico='/home/'$username'/linux_installer/ico/'
  local C_catalog_arm='/home/'$username'/.wine/drive_c/ARIADNA/APP/'
  local C_catalog_img_ico='/home/'$username'/linux_installer/cpp_ico/'

  if [ -d $catalog_ico ]; then
  	cd $catalog_ico
  else
  	mkdir $catalog_ico
  	echo 'Каталог '$catalog_ico' создан' >> /home/$username/linux_installer/install_log.log
  	cd $catalog_ico
  fi

  local C_index[0]=0
  local C_index[1]=1
  local C_index[2]=2
  local C_index[3]=3
  local C_index[4]=4
  local C_index[5]=5
  local C_index[6]=6
  local C_index[7]=7
  local C_index[8]=8
  local C_index[9]=9
  local C_index[10]=10
  local C_index[11]=11
  local C_index[12]=12
  local C_index[13]=13
  local C_index[14]=14
  local C_index[15]=15
  local C_index[16]=16
  local C_index[17]=17
  local C_index[18]=18
  local C_index[19]=19
  local C_index[20]=20
  local C_index[21]=21
  local C_index[22]=22
  local C_index[23]=23
  local C_index[24]=24
  local C_index[25]=25
  local C_index[26]=26
  local C_index[27]=27
  local C_index[28]=28

  local C_name_desktop[0]='Регистратура.desktop'
  local C_name_arm[0]='Регистратура'
  local C_name_ico[0]='MAIN-Registratura.ico'
  local C_name_file[0]='ArmRegistry.exe'

  local C_name_desktop[1]='Абулаторная_история_лечения.desktop'
  local C_name_arm[1]='Абулаторная_история_лечения'
  local C_name_ico[1]='MAIN-History.ico'
  local C_name_file[1]='ArmAmbHistory.exe'

  local C_name_desktop[2]='Аптека.desktop'
  local C_name_arm[2]='Аптека'
  local C_name_ico[2]='MAIN-Apteka.ico'
  local C_name_file[2]='ArmApteka.exe'

  local C_name_desktop[3]='Отделение_переливания_крови.desktop'
  local C_name_arm[3]='Отделение_переливания_крови'
  local C_name_ico[3]='MAIN-Blood.ico'
  local C_name_file[3]='ArmOPK.exe'

  local C_name_desktop[4]='ПАО.desktop'
  local C_name_arm[4]='ПАО'
  local C_name_ico[4]='MAIN-Diagnostic.ico'
  local C_name_file[4]='ArmPAO.exe'

  local C_name_desktop[5]='Функциональная_диагностика.desktop'
  local C_name_arm[5]='Функциональная_диагностика'
  local C_name_ico[5]='MAIN-Diagnostic.ico'
  local C_name_file[5]='ArmFunc.exe'

  local C_name_desktop[6]='ЭКГ.desktop'
  local C_name_arm[6]='ЭКГ'
  local C_name_ico[6]='MAIN-Diagnostic.ico'
  local C_name_file[6]='ArmEkg.exe'

  local C_name_desktop[7]='Ангинография.desktop'
  local C_name_arm[7]='Ангинография'
  local C_name_ico[7]='MAIN-Diagnostic2.ico'
  local C_name_file[7]='ArmAngio.exe'

  local C_name_desktop[8]='Коронарография.desktop'
  local C_name_arm[8]='Коронарография'
  local C_name_ico[8]='MAIN-Diagnostic2.ico'
  local C_name_file[8]='ArmCoron.exe'

  local C_name_desktop[9]='КТ.desktop'
  local C_name_arm[9]='КТ'
  local C_name_ico[9]='MAIN-Diagnostic2.ico'
  local C_name_file[9]='ArmKT.exe'

  local C_name_desktop[10]='Лазерная_медицина.desktop'
  local C_name_arm[10]='Лазерная_медицина'
  local C_name_ico[10]='MAIN-Diagnostic2.ico'
  local C_name_file[10]='ArmLaser.exe'

  local C_name_desktop[11]='Лучевая_диагностика.desktop'
  local C_name_arm[11]='Лучевая_диагностика'
  local C_name_ico[11]='MAIN-Diagnostic2.ico'
  local C_name_file[11]='ArmRadio.exe'

  local C_name_desktop[12]='МРТ.desktop'
  local C_name_arm[12]='МРТ'
  local C_name_ico[12]='MAIN-Diagnostic2.ico'
  local C_name_file[12]='ArmMRT.exe'

  local C_name_desktop[13]='УЗИ.desktop'
  local C_name_arm[13]='УЗИ'
  local C_name_ico[13]='MAIN-Diagnostic2.ico'
  local C_name_file[13]='ArmUzi.exe'

  local C_name_desktop[14]='Эндоскопия.desktop'
  local C_name_arm[14]='Эндоскопия'
  local C_name_ico[14]='MAIN-Diagnostic2.ico'
  local C_name_file[14]='ArmEndoscopy.exe'

  local C_name_desktop[15]='Рентген.desktop'
  local C_name_arm[15]='Рентген'
  local C_name_ico[15]='MAIN-Diagnostic2.ico'
  local C_name_file[15]='ArmRentgen.exe'

  local C_name_desktop[16]='Выписной_эпикриз.desktop'
  local C_name_arm[16]='Выписной_эпикриз'
  local C_name_ico[16]='MAIN-Epikriz.ico'
  local C_name_file[16]='ArmConclusion.exe'

  local C_name_desktop[17]='Скорая_помощь.desktop'
  local C_name_arm[17]='Скорая_помощь'
  local C_name_ico[17]='MAIN-Ambulance.ico'
  local C_name_file[17]='ArmER.exe'

  local C_name_desktop[18]='Информер.desktop'
  local C_name_arm[18]='Информер'
  local C_name_ico[18]='MAIN-Informer.ico'
  local C_name_file[18]='ArmInformer.exe'

  local C_name_desktop[19]='Врач_дневного_стационара.desktop'
  local C_name_arm[19]='Врач_дневного_стационара'
  local C_name_ico[19]='MAIN-Medic.ico'
  local C_name_file[19]='ArmDayStac.exe'

  local C_name_desktop[20]='Врач_поликлиники.desktop'
  local C_name_arm[20]='Врач_поликлиники'
  local C_name_ico[20]='MAIN-Medic.ico'
  local C_name_file[20]='ArmAmbDoctor.exe'

  local C_name_desktop[21]='Монитор_стационара.desktop'
  local C_name_arm[21]='Монитор_стационара'
  local C_name_ico[21]='MAIN-Monitor.ico'
  local C_name_file[21]='ArmHospMonitor.exe'

  local C_name_desktop[22]='Реагент.desktop'
  local C_name_arm[22]='Реагент'
  local C_name_ico[22]='MAIN-Reagents.ico'
  local C_name_file[22]='ArmReagent.exe'

  local C_name_desktop[23]='Приемное_отделение.desktop'
  local C_name_arm[23]='Приемное_отделение'
  local C_name_ico[23]='MAIN-Reception.ico'
  local C_name_file[23]='ArmReception.exe'

  local C_name_desktop[24]='Постовая_сестра.desktop'
  local C_name_arm[24]='Постовая Сестра'
  local C_name_ico[24]='MAIN-Sestra.ico'
  local C_name_file[24]='ArmMoving.exe'

  local C_name_desktop[25]='Медицинский_склад.desktop'
  local C_name_arm[25]='Медицинский_склад'
  local C_name_ico[25]='MAIN-Sklad.ico'
  local C_name_file[25]='ArmStorage.exe'

  local C_name_desktop[26]='ТВ.desktop'
  local C_name_arm[26]='ТВ'
  local C_name_ico[26]='MAIN-Tv.ico'
  local C_name_file[26]='ArmTV.exe'

  local C_name_desktop[27]='Бюро_госпитализации.desktop'
  local C_name_arm[27]='Бюро_госпитализации'
  local C_name_ico[27]='MAIN-Waiting.ico'
  local C_name_file[27]='ArmHospOffice.exe'

  local C_name_desktop[28]='Врач_стационара.desktop'
  local C_name_arm[28]='Врач_стационара'
  local C_name_ico[28]='MAIN-Medic.ico'
  local C_name_file[28]='ArmStacDoctor.exe'

	echo 'Создание С ярлыков' >> /home/$username/linux_installer/install_log.log
	for i in ${C_index[@]}
		do
			if [ -f $C_catalog_arm''${C_name_file[$i]} ]; then
				sleep 0.1
				touch ${C_name_desktop[$i]}
				chmod +x ${C_name_desktop[$i]}
				{
				 echo '[Desktop Entry]'
				 echo 'Name='${C_name_arm[$i]}
				 echo 'Comment='
				 echo 'GenericName='
				 echo 'Keywords='
				 echo 'Exec=wine ' $C_catalog_arm''${C_name_file[$i]}
				 echo 'Terminal=false'
				 echo 'Type=Application'
				 echo 'Icon='$C_catalog_img_ico''${C_name_ico[$i]}
				 echo 'Path='$C_catalog_arm
				 echo 'Categories='
				 echo 'NoDisplay=false'
				} > ${C_name_desktop[$i]}
				echo 'Ярлык '${C_name_arm[$i]}' создан' >> /home/$username/linux_installer/install_log.log
			fi
		done

	touch /home/$username/.local/share/applications/wine-extension-pdf.desktop
				chmod +x /home/$username/.local/share/applications/wine-extension-pdf.desktop
				{
				 echo '[Desktop Entry]'
				echo 'Type=Application'
				echo 'Name=winebrowser'
				echo 'MimeType=application/pdf;'
				echo 'Exec=env WINEPREFIX="/home/user/.wine"  /home/user/.wine/drive_c/windows/run_off /usr/bin/atril %f'
				echo 'NoDisplay=true'
				echo 'StartupNotify=true'
				echo 'Icon=7765_winebrowser.0'
				} > /home/$username/.local/share/applications/wine-extension-pdf.desktop
}

function Create_java_ico_sh_legacy(){

  local catalog_ico='/home/'$username'/linux_installer/ico/'
  local JAVA_catalog_arm='/home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  local JAVA_catalog_img_ico='/home/'$username'/linux_installer/java_ico/'

  if [ -d $catalog_ico ]; then
      cd $catalog_ico
  else
  		mkdir $catalog_ico
  		echo 'Каталог '$catalog_ico' создан' >> /home/$username/linux_installer/install_log.log
  		cd $catalog_ico
  fi

  local libpath='java.library.path=../lib/'

  local JAVA_index[0]=0
  local JAVA_index[1]=1
  local JAVA_index[2]=2
  local JAVA_index[3]=3
  local JAVA_index[4]=4
  local JAVA_index[5]=5
  local JAVA_index[6]=6
  local JAVA_index[7]=7
  local JAVA_index[8]=8
  local JAVA_index[9]=9
  local JAVA_index[10]=10
  local JAVA_index[11]=11
  local JAVA_index[12]=12
  local JAVA_index[13]=13
  local JAVA_index[14]=14
  local JAVA_index[15]=15
  local JAVA_index[16]=16
  local JAVA_index[17]=17
  local JAVA_index[18]=18

  local JAVA_name_desktop[0]='Ковертер_JAVA.desktop'
  local JAVA_name_arm[0]='Конвертер_JAVA'
  local JAVA_name_ico[0]='AriadnaConverter.ico'
  local JAVA_name_file[0]='ArmConverter.sh'

  local JAVA_name_desktop[1]='Зарплата_JAVA.desktop'
  local JAVA_name_arm[1]='Зарплата_JAVA'
  local JAVA_name_ico[1]='ArmSalary.ico'
  local JAVA_name_file[1]='ArmSalary.sh'

  local JAVA_name_desktop[2]='Администратор_JAVA.desktop'
  local JAVA_name_arm[2]='Администратор_JAVA'
  local JAVA_name_ico[2]='ArmAdministrator.ico'
  local JAVA_name_file[2]='ArmAdministrator.sh'

  local JAVA_name_desktop[3]='Системный_Администратор_JAVA.desktop'
  local JAVA_name_arm[3]='Системный_Администратор_JAVA'
  local JAVA_name_ico[3]='ArmAdminSys.ico'
  local JAVA_name_file[3]='ArmAdminSys.sh'

  local JAVA_name_desktop[4]='Врач_поликлиники_JAVA.desktop'
  local JAVA_name_arm[4]='Врач_поликлиники_JAVA'
  local JAVA_name_ico[4]='ArmAmbDoctor.ico'
  local JAVA_name_file[4]='ArmAmbDoctor.sh'

  local JAVA_name_desktop[5]='Архив_JAVA.desktop'
  local JAVA_name_arm[5]='Архив_JAVA'
  local JAVA_name_ico[5]='ArmArchive.ico'
  local JAVA_name_file[5]='ArmArchive.sh'

  local JAVA_name_desktop[6]='Счетчик_клеток_JAVA.desktop'
  local JAVA_name_arm[6]='Счетчик_клеток_JAVA'
  local JAVA_name_ico[6]='ArmCellCounter.ico'
  local JAVA_name_file[6]='ArmCellCounter.sh'

  local JAVA_name_desktop[7]='Контент_JAVA.desktop'
  local JAVA_name_arm[7]='Контент_JAVA'
  local JAVA_name_ico[7]='ArmContent.ico'
  local JAVA_name_file[7]='ArmContent.sh'

  local JAVA_name_desktop[8]='Экономист_JAVA.desktop'
  local JAVA_name_arm[8]='Экономист_JAVA'
  local JAVA_name_ico[8]='ArmEconom.ico'
  local JAVA_name_file[8]='ArmEconom.sh'

  local JAVA_name_desktop[9]='Справки_JAVA.desktop'
  local JAVA_name_arm[9]='Справки_JAVA'
  local JAVA_name_ico[9]='ArmSpravka.ico'
  local JAVA_name_file[9]='ArmSpravka.sh'

  local JAVA_name_desktop[10]='Сортер_JAVA.desktop'
  local JAVA_name_arm[10]='Сортер_JAVA'
  local JAVA_name_ico[10]='ArmSorter.ico'
  local JAVA_name_file[10]='ArmSorter.sh'

  local JAVA_name_desktop[11]='Стоматолог_JAVA.desktop'
  local JAVA_name_arm[11]='Стоматолог_JAVA'
  local JAVA_name_ico[11]='ArmStomatology.ico'
  local JAVA_name_file[11]='ArmStomatology.sh'

  local JAVA_name_desktop[12]='Финансы_JAVA.desktop'
  local JAVA_name_arm[12]='Финансы_JAVA'
  local JAVA_name_ico[12]='ArmFinance.ico'
  local JAVA_name_file[12]='ArmFinance.sh'

  local JAVA_name_desktop[13]='Лаборатория_JAVA.desktop'
  local JAVA_name_arm[13]='Лаборатория_JAVA'
  local JAVA_name_ico[13]='ArmLab.ico'
  local JAVA_name_file[13]='ArmLab.sh'

  local JAVA_name_desktop[14]='ОперБлок_JAVA.desktop'
  local JAVA_name_arm[14]='ОперБлок_JAVA'
  local JAVA_name_ico[14]='ArmOpers.ico'
  local JAVA_name_file[14]='ArmOpers.sh'

  local JAVA_name_desktop[15]='Контроль_качества_JAVA.desktop'
  local JAVA_name_arm[15]='Контроль_качества_JAVA'
  local JAVA_name_ico[15]='ArmQC.ico'
  local JAVA_name_file[15]='ArmQC.sh'

  local JAVA_name_desktop[16]='Расписание_JAVA.desktop'
  local JAVA_name_arm[16]='Расписание_JAVA'
  local JAVA_name_ico[16]='ArmSchedule.ico'
  local JAVA_name_file[16]='ArmSchedule.sh'

  local JAVA_name_desktop[17]='Субподряд_JAVA.desktop'
  local JAVA_name_arm[17]='Субподряд_JAVA'
  local JAVA_name_ico[17]='ArmSubcontract.ico'
  local JAVA_name_file[17]='ArmSubcontract.sh'

  local JAVA_name_desktop[18]='Вакцинация_JAVA.desktop'
  local JAVA_name_arm[18]='Вакцинация_JAVA'
  local JAVA_name_ico[18]='ArmVaccination.ico'
  local JAVA_name_file[18]='ArmVaccination.sh'

	echo 'Создание JAVA ярлыков' >> /home/$username/linux_installer/install_log.log
	for i in ${JAVA_index[@]}
		do
			if [ -f $JAVA_catalog_arm''${JAVA_name_ico[$i]} ]; then
				sleep 0.1
				touch ${JAVA_name_desktop[$i]}
				chmod +x ${JAVA_name_desktop[$i]}
				{
				 echo '[Desktop Entry]'
				 echo 'Name='${JAVA_name_arm[$i]}
				 echo 'Comment='
				 echo 'GenericName='
				 echo 'Keywords='
				 echo 'Exec=sh ' $JAVA_catalog_arm''${JAVA_name_file[$i]}
				 echo 'Terminal=false'
				 echo 'Type=Application'
				 echo 'Icon='$JAVA_catalog_img_ico''${JAVA_name_ico[$i]}
				 echo 'Path='$JAVA_catalog_arm
				 echo 'Categories='
				 echo 'NoDisplay=false'
				} > ${JAVA_name_desktop[$i]}
				echo 'Ярлык '${JAVA_name_arm[$i]}' создан' >> /home/$username/linux_installer/install_log.log
			fi
		done
	echo 'Создание sh сценариев для JAVA АРМов' >> /home/$username/linux_installer/install_log.log
	for i in ${JAVA_index[@]}
		do
			if [ -f $JAVA_catalog_arm''${JAVA_name_ico[$i]} ]; then
				sleep 0.1
				touch $JAVA_catalog_arm''${JAVA_name_file[$i]}
				chmod +x $JAVA_catalog_arm''${JAVA_name_file[$i]}
			fi
		done

	if [ -f $JAVA_catalog_arm'ArmConverter.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmConverter.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmConverter.sh'
		echo 'ArmConverter.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmAdministrator.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmAdministrator.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar:../lib/javac2.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmAdministrator.sh'
		echo 'ArmAdministrator.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmAdminSys.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmAdminSys.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar:../lib/javac2.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmAdminSys.sh'
		echo 'ArmAdminSys.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmAmbDoctor.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/slf4j-api-1.7.22.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmAmbDoctor.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo 'export CLASSPATH=$CLASSPATH:/lib/MDateSelector.jar:../lib/balloontip.jar:../lib/mail.jar:../lib/jortho.jar:../lib/jtidy-8.0.jar:../lib/novaworx-syntax-0.0.7.jar:../lib/sam.jar:../lib/javac2.jar:../lib/jasper/*:../lib/pdf/*'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH ambdoctor.app.Application'
		} > $JAVA_catalog_arm'ArmAmbDoctor.sh'
		echo 'ArmAmbDoctor.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmArchive.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmArchive.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmArchive.sh'
		echo 'ArmArchive.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmCellCounter.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmCellCounter.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmCellCounter.sh'
		echo 'ArmCellCounter.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmContent.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmContent.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmContent.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/commons-collections-3.2.1.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.3.jar:../lib/javac2.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmContent.sh'
		echo 'ArmContent.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmEconom.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmEconom.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/MDateSelector.jar:../lib/balloontip.jar:../lib/mail.jar:../lib/iText-2.0.8.jar:../lib/core-renderer.jar:../lib/joda-time-2.3.jar:../lib/javac2.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmEconom.sh'
		echo 'ArmEconom.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmSpravka.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSpravka.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSpravka.jar:../lib/iText-2.0.8.jar:../lib/mail.jar:../lib/balloontip.jar:../lib/ojdbc14.jar:../lib/DbfReader.jar:../lib/zxing-2.2.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmSpravka.sh'
		echo 'ArmSpravka.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmSorter.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSorter.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmSorter.sh'
		echo 'ArmSorter.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmStomatology.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmStomatology.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/MDateSelector.jar:../lib/balloontip.jar:../lib/jortho.jar:../lib/mail.jar:../lib/javac2.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmStomatology.sh'
		echo 'ArmStomatology.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmFinance.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmFinance.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmFinance.sh'
		echo 'ArmFinance.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmLab.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmLab.jar:../lib/gson-2.8.2.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmLab.sh'
		echo 'ArmLab.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmOpers.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmOpers.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmOpers.sh'
		echo 'ArmOpers.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmQC.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmQC.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmQC.sh'
		echo 'ArmQC.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmSalary.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSalary.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmSalary.sh'
		echo 'ArmSalary.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmSchedule.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSchedule.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmSchedule.sh'
		echo 'ArmSchedule.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmSubcontract.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSubcontract.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmSubcontract.sh'
		echo 'ArmSubcontract.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
	sleep 0.1
	if [ -f $JAVA_catalog_arm'ArmVaccination.ico' ]; then
		{
		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
		echo 'export PATH=$PATH:'$java_home'/bin/'
		echo 'export JAVA_HOME='$java_home''
		echo 'export LIBPATH=java.library.path=../lib/'
		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jre6.jar'
		echo 'export ENCODING=-Dfile.encoding=cp866'
		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmVaccination.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
		} > $JAVA_catalog_arm'ArmVaccination.sh'
		echo 'ArmVaccination.sh создан' >> /home/$username/linux_installer/install_log.log
	fi
}

function Create_C_ico(){
local C_index[0]=0
local C_index[1]=1
local C_index[2]=2
local C_index[3]=3
local C_index[4]=4
local C_index[5]=5
local C_index[6]=6
local C_index[7]=7
local C_index[8]=8
local C_index[9]=9
local C_index[10]=10
local C_index[11]=11
local C_index[12]=12
local C_index[13]=13
local C_index[14]=14
local C_index[15]=15
local C_index[16]=16
local C_index[17]=17
local C_index[18]=18
local C_index[19]=19
local C_index[20]=20
local C_index[21]=21
local C_index[22]=22
local C_index[23]=23
local C_index[24]=24
local C_index[25]=25
local C_index[26]=26
local C_index[27]=27
local C_index[28]=28

local C_name_desktop[0]='Регистратура.desktop'
local C_name_arm[0]='Регистратура'
local C_name_ico[0]='MAIN-Registratura.ico'
local C_name_file[0]='ArmRegistry.exe'

local C_name_desktop[1]='Абулаторная_история_лечения.desktop'
local C_name_arm[1]='Абулаторная_история_лечения'
local C_name_ico[1]='MAIN-History.ico'
local C_name_file[1]='ArmAmbHistory.exe'

local C_name_desktop[2]='Аптека.desktop'
local C_name_arm[2]='Аптека'
local C_name_ico[2]='MAIN-Apteka.ico'
local C_name_file[2]='ArmApteka.exe'

local C_name_desktop[3]='Отделение_переливания_крови.desktop'
local C_name_arm[3]='Отделение_переливания_крови'
local C_name_ico[3]='MAIN-Blood.ico'
local C_name_file[3]='ArmOPK.exe'

local C_name_desktop[4]='Врач_ПАО.desktop'
local C_name_arm[4]='Врач_ПАО'
local C_name_ico[4]='MAIN-Diagnostic.ico'
local C_name_file[4]='ArmPAO.exe'

local C_name_desktop[5]='Функциональная_диагностика.desktop'
local C_name_arm[5]='Функциональная_диагностика'
local C_name_ico[5]='MAIN-Diagnostic.ico'
local C_name_file[5]='ArmFunc.exe'

local C_name_desktop[6]='ЭКГ.desktop'
local C_name_arm[6]='ЭКГ'
local C_name_ico[6]='MAIN-Diagnostic.ico'
local C_name_file[6]='ArmEkg.exe'

local C_name_desktop[7]='Ангинография.desktop'
local C_name_arm[7]='Ангинография'
local C_name_ico[7]='MAIN-Diagnostic2.ico'
local C_name_file[7]='ArmAngio.exe'

local C_name_desktop[8]='Коронарография.desktop'
local C_name_arm[8]='Коронарография'
local C_name_ico[8]='MAIN-Diagnostic2.ico'
local C_name_file[8]='ArmCoron.exe'

local C_name_desktop[9]='КТ.desktop'
local C_name_arm[9]='КТ'
local C_name_ico[9]='MAIN-Diagnostic2.ico'
local C_name_file[9]='ArmKT.exe'

local C_name_desktop[10]='Лазерная_медицина.desktop'
local C_name_arm[10]='Лазерная_медицина'
local C_name_ico[10]='MAIN-Diagnostic2.ico'
local C_name_file[10]='ArmLaser.exe'

local C_name_desktop[11]='Лучевая_диагностика.desktop'
local C_name_arm[11]='Лучевая_диагностика'
local C_name_ico[11]='MAIN-Diagnostic2.ico'
local C_name_file[11]='ArmRadio.exe'

local C_name_desktop[12]='МРТ.desktop'
local C_name_arm[12]='МРТ'
local C_name_ico[12]='MAIN-Diagnostic2.ico'
local C_name_file[12]='ArmMRT.exe'

local C_name_desktop[13]='УЗИ.desktop'
local C_name_arm[13]='УЗИ'
local C_name_ico[13]='MAIN-Diagnostic2.ico'
local C_name_file[13]='ArmUzi.exe'

local C_name_desktop[14]='Эндоскопия.desktop'
local C_name_arm[14]='Эндоскопия'
local C_name_ico[14]='MAIN-Diagnostic2.ico'
local C_name_file[14]='ArmEndoscopy.exe'

local C_name_desktop[15]='Рентгенография.desktop'
local C_name_arm[15]='Рентгенография'
local C_name_ico[15]='MAIN-Diagnostic2.ico'
local C_name_file[15]='ArmRentgen.exe'

local C_name_desktop[16]='Выписной_эпикриз.desktop'
local C_name_arm[16]='Выписной_эпикриз'
local C_name_ico[16]='MAIN-Epikriz.ico'
local C_name_file[16]='ArmConclusion.exe'

local C_name_desktop[17]='Скорая_помощь.desktop'
local C_name_arm[17]='Скорая_помощь'
local C_name_ico[17]='MAIN-Ambulance.ico'
local C_name_file[17]='ArmER.exe'

local C_name_desktop[18]='Информер.desktop'
local C_name_arm[18]='Информер'
local C_name_ico[18]='MAIN-Informer.ico'
local C_name_file[18]='ArmInformer.exe'

local C_name_desktop[19]='Врач_дневного_стационара.desktop'
local C_name_arm[19]='Врач_дневного_стационара'
local C_name_ico[19]='MAIN-Medic.ico'
local C_name_file[19]='ArmDayStac.exe'

local C_name_desktop[20]='Врач_поликлиники.desktop'
local C_name_arm[20]='Врач_поликлиники'
local C_name_ico[20]='MAIN-Medic.ico'
local C_name_file[20]='ArmAmbDoctor.exe'

local C_name_desktop[21]='Монитор_стационара.desktop'
local C_name_arm[21]='Монитор_стационара'
local C_name_ico[21]='MAIN-Monitor.ico'
local C_name_file[21]='ArmHospMonitor.exe'

local C_name_desktop[22]='Реагент.desktop'
local C_name_arm[22]='Реагент'
local C_name_ico[22]='MAIN-Reagents.ico'
local C_name_file[22]='ArmReagent.exe'

local C_name_desktop[23]='Приемное_отделение.desktop'
local C_name_arm[23]='Приемное_отделение'
local C_name_ico[23]='MAIN-Reception.ico'
local C_name_file[23]='ArmReception.exe'

local C_name_desktop[24]='Движение_пациентов.desktop'
local C_name_arm[24]='Движение_пациентов'
local C_name_ico[24]='MAIN-Sestra.ico'
local C_name_file[24]='ArmMoving.exe'

local C_name_desktop[25]='Медицинский_склад.desktop'
local C_name_arm[25]='Медицинский_склад'
local C_name_ico[25]='MAIN-Sklad.ico'
local C_name_file[25]='ArmStorage.exe'

local C_name_desktop[26]='ТВ.desktop'
local C_name_arm[26]='ТВ'
local C_name_ico[26]='MAIN-Tv.ico'
local C_name_file[26]='ArmTV.exe'

local C_name_desktop[27]='Бюро_госпитализации.desktop'
local C_name_arm[27]='Бюро_госпитализации'
local C_name_ico[27]='MAIN-Waiting.ico'
local C_name_file[27]='ArmHospOffice.exe'

local C_name_desktop[28]='Стационар.desktop'
local C_name_arm[28]='Стационар'
local C_name_ico[28]='MAIN-Medic.ico'
local C_name_file[28]='ArmStacDoctor.exe'

	echo 'Создание С ярлыков'
	for i in ${C_index[@]}
		do
			if [ -f $C_catalog_arm''${C_name_file[$i]} ]; then
				sleep 0.1
				touch ${C_name_desktop[$i]}
				chmod +x ${C_name_desktop[$i]}
				{
				 echo '[Desktop Entry]'
				 echo 'Name='${C_name_arm[$i]}
				 echo 'Comment='
				 echo 'GenericName='
				 echo 'Keywords='
				 echo 'Exec=wine ' $C_catalog_arm''${C_name_file[$i]}
				 echo 'Terminal=false'
				 echo 'Type=Application'
				 echo 'Icon='$C_catalog_img_ico''${C_name_ico[$i]}
				 echo 'Path='$C_catalog_arm
				 echo 'Categories='
				 echo 'NoDisplay=false'
				} > ${C_name_desktop[$i]}
				echo 'Ярлык '${C_name_arm[$i]}' создан'
			fi
		done
}

function Create_java_ico_sh(){

  local JAVA_index[0]=0
  local JAVA_index[1]=1
  local JAVA_index[2]=2
  local JAVA_index[3]=3
  local JAVA_index[4]=4
  local JAVA_index[5]=5
  local JAVA_index[6]=6
  local JAVA_index[7]=7
  local JAVA_index[8]=8
  local JAVA_index[9]=9
  local JAVA_index[10]=10
  local JAVA_index[11]=11
  local JAVA_index[12]=12
  local JAVA_index[13]=13
  local JAVA_index[14]=14
  local JAVA_index[15]=15
  local JAVA_index[16]=16
  local JAVA_index[17]=17
  local JAVA_index[18]=18

  local JAVA_name_desktop[0]='Ковертер_JAVA.desktop'
  local JAVA_name_arm[0]='Конвертер_JAVA'
  local JAVA_name_ico[0]='AriadnaConverter.ico'
  local JAVA_name_file[0]='ArmConverter.sh'

  local JAVA_name_desktop[1]='Зарплата_JAVA.desktop'
  local JAVA_name_arm[1]='Зарплата_JAVA'
  local JAVA_name_ico[1]='ArmSalary.ico'
  local JAVA_name_file[1]='ArmSalary.sh'

  local JAVA_name_desktop[2]='Администратор_JAVA.desktop'
  local JAVA_name_arm[2]='Администратор_JAVA'
  local JAVA_name_ico[2]='ArmAdministrator.ico'
  local JAVA_name_file[2]='ArmAdministrator.sh'

  local JAVA_name_desktop[3]='Системный_Администратор_JAVA.desktop'
  local JAVA_name_arm[3]='Системный_Администратор_JAVA'
  local JAVA_name_ico[3]='ArmAdminSys.ico'
  local JAVA_name_file[3]='ArmAdminSys.sh'

  local JAVA_name_desktop[4]='Врач_поликлиники_JAVA.desktop'
  local JAVA_name_arm[4]='Врач_поликлиники_JAVA'
  local JAVA_name_ico[4]='ArmAmbDoctor.ico'
  local JAVA_name_file[4]='ArmAmbDoctor.sh'

  local JAVA_name_desktop[5]='Архив_JAVA.desktop'
  local JAVA_name_arm[5]='Архив_JAVA'
  local JAVA_name_ico[5]='ArmArchive.ico'
  local JAVA_name_file[5]='ArmArchive.sh'

  local JAVA_name_desktop[6]='Счетчик_клеток_JAVA.desktop'
  local JAVA_name_arm[6]='Счетчик_клеток_JAVA'
  local JAVA_name_ico[6]='ArmCellCounter.ico'
  local JAVA_name_file[6]='ArmCellCounter.sh'

  local JAVA_name_desktop[7]='Контент_JAVA.desktop'
  local JAVA_name_arm[7]='Контент_JAVA'
  local JAVA_name_ico[7]='ArmContent.ico'
  local JAVA_name_file[7]='ArmContent.sh'

  local JAVA_name_desktop[8]='Экономист_JAVA.desktop'
  local JAVA_name_arm[8]='Экономист_JAVA'
  local JAVA_name_ico[8]='ArmEconom.ico'
  local JAVA_name_file[8]='ArmEconom.sh'

  local JAVA_name_desktop[9]='Справки_JAVA.desktop'
  local JAVA_name_arm[9]='Справки_JAVA'
  local JAVA_name_ico[9]='ArmSpravka.ico'
  local JAVA_name_file[9]='ArmSpravka.sh'

  local JAVA_name_desktop[10]='Сортер_JAVA.desktop'
  local JAVA_name_arm[10]='Сортер_JAVA'
  local JAVA_name_ico[10]='ArmSorter.ico'
  local JAVA_name_file[10]='ArmSorter.sh'

  local JAVA_name_desktop[11]='Стоматолог_JAVA.desktop'
  local JAVA_name_arm[11]='Стоматолог_JAVA'
  local JAVA_name_ico[11]='ArmStomatology.ico'
  local JAVA_name_file[11]='ArmStomatology.sh'

  local JAVA_name_desktop[12]='Финансы_JAVA.desktop'
  local JAVA_name_arm[12]='Финансы_JAVA'
  local JAVA_name_ico[12]='ArmFinance.ico'
  local JAVA_name_file[12]='ArmFinance.sh'

  local JAVA_name_desktop[13]='Лаборатория_JAVA.desktop'
  local JAVA_name_arm[13]='Лаборатория_JAVA'
  local JAVA_name_ico[13]='ArmLab.ico'
  local JAVA_name_file[13]='ArmLab.sh'

  local JAVA_name_desktop[14]='ОперБлок_JAVA.desktop'
  local JAVA_name_arm[14]='ОперБлок_JAVA'
  local JAVA_name_ico[14]='ArmOpers.ico'
  local JAVA_name_file[14]='ArmOpers.sh'

  local JAVA_name_desktop[15]='Контроль_качества_JAVA.desktop'
  local JAVA_name_arm[15]='Контроль_качества_JAVA'
  local JAVA_name_ico[15]='ArmQC.ico'
  local JAVA_name_file[15]='ArmQC.sh'

  local JAVA_name_desktop[16]='Расписание_JAVA.desktop'
  local JAVA_name_arm[16]='Расписание_JAVA'
  local JAVA_name_ico[16]='ArmSchedule.ico'
  local JAVA_name_file[16]='ArmSchedule.sh'

  local JAVA_name_desktop[17]='Субподряд_JAVA.desktop'
  local JAVA_name_arm[17]='Субподряд_JAVA'
  local JAVA_name_ico[17]='ArmSubcontract.ico'
  local JAVA_name_file[17]='ArmSubcontract.sh'

  local JAVA_name_desktop[18]='Вакцинация_JAVA.desktop'
  local JAVA_name_arm[18]='Вакцинация_JAVA'
  local JAVA_name_ico[18]='ArmVaccination.ico'
  local JAVA_name_file[18]='ArmVaccination.sh'

  	echo 'Создание JAVA ярлыков' >> /home/$username/linux_installer/install_log.log
  	for i in ${JAVA_index[@]}
  		do
  			if [ -f $JAVA_catalog_arm''${JAVA_name_ico[$i]} ]; then
  				sleep 0.1
  				touch ${JAVA_name_desktop[$i]}
  				chmod +x ${JAVA_name_desktop[$i]}
  				{
  				 echo '[Desktop Entry]'
  				 echo 'Name='${JAVA_name_arm[$i]}
  				 echo 'Comment='
  				 echo 'GenericName='
  				 echo 'Keywords='
  				 echo 'Exec=sh ' $JAVA_catalog_arm''${JAVA_name_file[$i]}
  				 echo 'Terminal=false'
  				 echo 'Type=Application'
  				 echo 'Icon='$JAVA_catalog_img_ico''${JAVA_name_ico[$i]}
  				 echo 'Path='$JAVA_catalog_arm
  				 echo 'Categories='
  				 echo 'NoDisplay=false'
  				} > ${JAVA_name_desktop[$i]}
  				echo 'Ярлык '${JAVA_name_arm[$i]}' создан' >> /home/$username/linux_installer/install_log.log
  			fi
  		done
  	echo 'Создание sh сценариев для JAVA АРМов' >> /home/$username/linux_installer/install_log.log
  	for i in ${JAVA_index[@]}
  		do
  			if [ -f $JAVA_catalog_arm''${JAVA_name_ico[$i]} ]; then
  				sleep 0.1
  				touch $JAVA_catalog_arm''${JAVA_name_file[$i]}
  				chmod +x $JAVA_catalog_arm''${JAVA_name_file[$i]}
  			fi
  		done

  	if [ -f $JAVA_catalog_arm'ArmConverter.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmConverter.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmConverter.sh'
  		echo 'ArmConverter.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmAdministrator.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmAdministrator.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar:../lib/javac2.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmAdministrator.sh'
  		echo 'ArmAdministrator.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmAdminSys.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmAdminSys.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar:../lib/javac2.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmAdminSys.sh'
  		echo 'ArmAdminSys.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmAmbDoctor.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/slf4j-api-1.7.22.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmAmbDoctor.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo 'export CLASSPATH=$CLASSPATH:/lib/MDateSelector.jar:../lib/balloontip.jar:../lib/mail.jar:../lib/jortho.jar:../lib/jtidy-8.0.jar:../lib/novaworx-syntax-0.0.7.jar:../lib/sam.jar:../lib/javac2.jar:../lib/jasper/*:../lib/pdf/*'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH ambdoctor.app.Application'
  		} > $JAVA_catalog_arm'ArmAmbDoctor.sh'
  		echo 'ArmAmbDoctor.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmArchive.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmArchive.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmArchive.sh'
  		echo 'ArmArchive.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmCellCounter.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmCellCounter.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmCellCounter.sh'
  		echo 'ArmCellCounter.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmContent.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmContent.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmContent.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/commons-collections-3.2.1.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.3.jar:../lib/javac2.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmContent.sh'
  		echo 'ArmContent.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmEconom.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmEconom.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/MDateSelector.jar:../lib/balloontip.jar:../lib/mail.jar:../lib/iText-2.0.8.jar:../lib/core-renderer.jar:../lib/joda-time-2.3.jar:../lib/javac2.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmEconom.sh'
  		echo 'ArmEconom.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmSpravka.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSpravka.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSpravka.jar:../lib/iText-2.0.8.jar:../lib/mail.jar:../lib/balloontip.jar:../lib/ojdbc14.jar:../lib/DbfReader.jar:../lib/zxing-2.2.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmSpravka.sh'
  		echo 'ArmSpravka.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmSorter.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSorter.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmSorter.sh'
  		echo 'ArmSorter.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmStomatology.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmStomatology.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/MDateSelector.jar:../lib/balloontip.jar:../lib/jortho.jar:../lib/mail.jar:../lib/javac2.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmStomatology.sh'
  		echo 'ArmStomatology.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmFinance.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmFinance.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmFinance.sh'
  		echo 'ArmFinance.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmLab.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmLab.jar:../lib/gson-2.8.2.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmLab.sh'
  		echo 'ArmLab.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmOpers.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmOpers.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmOpers.sh'
  		echo 'ArmOpers.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmQC.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmQC.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmQC.sh'
  		echo 'ArmQC.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmSalary.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSalary.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmSalary.sh'
  		echo 'ArmSalary.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmSchedule.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSchedule.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmSchedule.sh'
  		echo 'ArmSchedule.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmSubcontract.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmSubcontract.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmSubcontract.sh'
  		echo 'ArmSubcontract.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
  	sleep 0.1
  	if [ -f $JAVA_catalog_arm'ArmVaccination.ico' ]; then
  		{
  		echo 'cd /home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
  		echo 'export PATH=$PATH:'$java_home'/bin/'
  		echo 'export JAVA_HOME='$java_home''
  		echo 'export LIBPATH=java.library.path=../lib/'
  		echo 'export CLASSPATH=../lib/ojdbc14.jar:../lib/balloontip.jar:../lib/MDateSelector.jar:../lib/jortho.jar:../lib/log4j-1.2.12.jar:../lib/xmlsec-1.5.0.jar:../lib/xalan-2.7.0.jar:../lib/wss4j-1.6.19.jar:../lib/pdfbox-2.0.8.jar:../lib/jna-4.5.1.jar:../lib/jna-platform-4.5.1.jar:../lib/jcl-over-slf4j-1.7.22.jar:../lib/logback-classic-1.1.10.jar:../lib/slf4j-api-1.7.22.jar:../lib/logback-core-1.1.10.jar:../lib/commons-lang-2.6.jar:../lib/commons-io-1.3.2.jar:../lib/pdf/itextpdf-5.5.13.1.jar:../lib/pdf/xmlworker-5.4.4.jar:../lib/commons-collections-3.2.1.jar:../lib/commons-codec-1.9.jar:../lib/postgresql-42.2.19.jar'
  		echo 'export ENCODING=-Dfile.encoding=cp866'
  		echo 'export CLASSPATH=$CLASSPATH:'$libre_office_home'juh.jar:'$libre_office_home'jurt.jar:'$libre_office_home'ridl.jar:'$libre_office_home'unoil.jar'
  		echo 'export CLASSPATH=$CLASSPATH:../lib/ArmVaccination.jar:../lib/xBaseSolution.jar:../lib/commons-beanutils-1.9.2.jar:../lib/guava-18.0.jar:../lib/jsr305-3.0.0.jar:../lib/commons-logging-1.2.jar:../lib/joda-time-2.4.jar:../lib/javac2.jar:../lib/jgraphx-0.14.0.1.1.jar'
  		echo '$JAVA_HOME/bin/java -Xmx256M -classpath $CLASSPATH app.Application %*'
  		} > $JAVA_catalog_arm'ArmVaccination.sh'
  		echo 'ArmVaccination.sh создан' >> /home/$username/linux_installer/install_log.log
  	fi
}

function Create_java_ico_wine(){
local JAVA_index[0]=0
local JAVA_index[1]=1
local JAVA_index[2]=2
local JAVA_index[3]=3
local JAVA_index[4]=4
local JAVA_index[5]=5
local JAVA_index[6]=6
local JAVA_index[7]=7
local JAVA_index[8]=8
local JAVA_index[9]=9
local JAVA_index[10]=10
local JAVA_index[11]=11
local JAVA_index[12]=12
local JAVA_index[13]=13
local JAVA_index[14]=14
local JAVA_index[15]=15
local JAVA_index[16]=16
local JAVA_index[17]=17
local JAVA_index[18]=18

local JAVA_name_desktop[0]='Ковертер(JAVA).desktop'
local JAVA_name_arm[0]='Конвертер(JAVA)'
local JAVA_name_ico[0]='AriadnaConverter.ico'
local JAVA_name_file[0]='ArmConverter.bat'

local JAVA_name_desktop[1]='Зарплата(JAVA).desktop'
local JAVA_name_arm[1]='Зарплата(JAVA)'
local JAVA_name_ico[1]='ArmSalary.ico'
local JAVA_name_file[1]='ArmSalary.bat'

local JAVA_name_desktop[2]='Администратор(JAVA).desktop'
local JAVA_name_arm[2]='Администратор(JAVA)'
local JAVA_name_ico[2]='ArmAdministrator.ico'
local JAVA_name_file[2]='ArmAdministrator.bat'

local JAVA_name_desktop[3]='Системный_Администратор(JAVA).desktop'
local JAVA_name_arm[3]='Системный_Администратор(JAVA)'
local JAVA_name_ico[3]='ArmAdminSys.ico'
local JAVA_name_file[3]='ArmAdminSys.bat'

local JAVA_name_desktop[4]='Врач_поликлиники(JAVA).desktop'
local JAVA_name_arm[4]='Врач_поликлиники(JAVA)'
local JAVA_name_ico[4]='ArmAmbDoctor.ico'
local JAVA_name_file[4]='ArmAmbDoctor.bat'

local JAVA_name_desktop[5]='Архив(JAVA).desktop'
local JAVA_name_arm[5]='Архив(JAVA)'
local JAVA_name_ico[5]='ArmArchive.ico'
local JAVA_name_file[5]='ArmArchive.bat'

local JAVA_name_desktop[6]='Счетчик_клеток(JAVA).desktop'
local JAVA_name_arm[6]='Счетчик_клеток(JAVA)'
local JAVA_name_ico[6]='ArmCellCounter.ico'
local JAVA_name_file[6]='ArmCellCounter.bat'

local JAVA_name_desktop[7]='Контент(JAVA).desktop'
local JAVA_name_arm[7]='Контент(JAVA)'
local JAVA_name_ico[7]='ArmContent.ico'
local JAVA_name_file[7]='ArmContent.bat'

local JAVA_name_desktop[8]='Экономист(JAVA).desktop'
local JAVA_name_arm[8]='Экономист(JAVA)'
local JAVA_name_ico[8]='ArmEconom.ico'
local JAVA_name_file[8]='ArmEconom.bat'

local JAVA_name_desktop[9]='Справки(JAVA).desktop'
local JAVA_name_arm[9]='Справки(JAVA)'
local JAVA_name_ico[9]='ArmSpravka.ico'
local JAVA_name_file[9]='ArmSpravka.bat'

local JAVA_name_desktop[10]='Сортер(JAVA).desktop'
local JAVA_name_arm[10]='Сортер(JAVA)'
local JAVA_name_ico[10]='ArmSorter.ico'
local JAVA_name_file[10]='ArmSorter.bat'

local JAVA_name_desktop[11]='Стоматолог(JAVA).desktop'
local JAVA_name_arm[11]='Стоматолог(JAVA)'
local JAVA_name_ico[11]='ArmStomatology.ico'
local JAVA_name_file[11]='ArmStomatology.bat'

local JAVA_name_desktop[12]='Финансы(JAVA).desktop'
local JAVA_name_arm[12]='Финансы(JAVA)'
local JAVA_name_ico[12]='ArmFinance.ico'
local JAVA_name_file[12]='ArmFinance.bat'

local JAVA_name_desktop[13]='Лаборатория(JAVA).desktop'
local JAVA_name_arm[13]='Лаборатория(JAVA)'
local JAVA_name_ico[13]='ArmLab.ico'
local JAVA_name_file[13]='ArmLab.bat'

local JAVA_name_desktop[14]='ОперБлок(JAVA).desktop'
local JAVA_name_arm[14]='ОперБлок(JAVA)'
local JAVA_name_ico[14]='ArmOpers.ico'
local JAVA_name_file[14]='ArmOpers.bat'

local JAVA_name_desktop[15]='Контроль_качества(JAVA).desktop'
local JAVA_name_arm[15]='Контроль_качества(JAVA)'
local JAVA_name_ico[15]='ArmQC.ico'
local JAVA_name_file[15]='ArmQC.bat'

local JAVA_name_desktop[16]='Расписание(JAVA).desktop'
local JAVA_name_arm[16]='Расписание(JAVA)'
local JAVA_name_ico[16]='ArmSchedule.ico'
local JAVA_name_file[16]='ArmSchedule.bat'

local JAVA_name_desktop[17]='Субподряд(JAVA).desktop'
local JAVA_name_arm[17]='Субподряд(JAVA)'
local JAVA_name_ico[17]='ArmSubcontract.ico'
local JAVA_name_file[17]='ArmSubcontract.bat'

local JAVA_name_desktop[18]='Вакцинация(JAVA).desktop'
local JAVA_name_arm[18]='Вакцинация(JAVA)'
local JAVA_name_ico[18]='ArmVaccination.ico'
local JAVA_name_file[18]='ArmVaccination.bat'

	echo 'Создание JAVA ярлыков'
	for i in ${JAVA_index[@]}
		do
			if [ -f $JAVA_catalog_arm''${JAVA_name_ico[$i]} ]; then
				sleep 0.1
				touch ${JAVA_name_desktop[$i]}
				chmod +x ${JAVA_name_desktop[$i]}
				{
				 echo '[Desktop Entry]'
				 echo 'Name='${JAVA_name_arm[$i]}
				 echo 'Comment='
				 echo 'GenericName='
				 echo 'Keywords='
				 echo 'Exec=''''env WINEPREFIX="/home/'$username'/.wine" /usr/bin/wine C:\\\\windows\\\\command\\\\start.exe /Unix /home/'$username'/.wine/dosdevices/c:/ARIADNA/APP/JAVA/bin/'${JAVA_name_file[$i]}''''''
				 echo 'Terminal=false'
				 echo 'Type=Application'
				 echo 'Icon='$JAVA_catalog_img_ico''${JAVA_name_ico[$i]}
				 echo 'Path='$JAVA_catalog_arm

				 echo 'Categories='
				 echo 'NoDisplay=false'
				} > ${JAVA_name_desktop[$i]}
				echo 'Ярлык '${JAVA_name_arm[$i]}' создан'
			fi
		done
}

function Create_Oracle_Connect(){

if [ $oracle_version = '11' ]; then
echo 'Регистрация TNSNAME и SQLNET Oracle 11' >> /home/$username/linux_installer/install_log.log
	touch /home/$username/.wine/drive_c/oracle/product/11.1.0/client_1/network/admin/tnsnames.ora
		{
		echo ''$name_db' ='
		echo '  (DESCRIPTION ='
		echo '    (ADDRESS_LIST ='
		echo '      (ADDRESS = (PROTOCOL = TCP)(HOST = '$ip_base')(PORT = 1521))'
		echo '    )'
		echo '    (CONNECT_DATA ='
		echo '      (SERVICE_NAME = '$name_db')'
		echo '    )'
		echo '  )'
		} > /home/$username/.wine/drive_c/oracle/product/11.1.0/client_1/network/admin/tnsnames.ora
	touch /home/$username/.wine/drive_c/oracle/product/11.1.0/client_1/network/admin/sqlnet.ora
		{
		echo '#SQLNET.AUTHENTICATION_SERVICES= (NTS)'
		echo 'NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT)'
		} > /home/$username/.wine/drive_c/oracle/product/11.1.0/client_1/network/admin/sqlnet.ora
fi

if [ $oracle_version = '12' ]; then
	echo 'Регистрация TNSNAME и SQLNET Oracle 12' >> /home/$username/linux_installer/install_log.log
	touch /home/$username/.wine/drive_c/oracle/product/12.2.0/client_1/network/admin/tnsnames.ora
		{
		echo ''$name_db' ='
		echo '  (DESCRIPTION ='
		echo '    (ADDRESS_LIST ='
		echo '      (ADDRESS = (PROTOCOL = TCP)(HOST = '$ip_base')(PORT = 1521))'
		echo '    )'
		echo '    (CONNECT_DATA ='
		echo '      (SERVICE_NAME = '$name_db')'
		echo '    )'
		echo '  )'
		} > /home/$username/.wine/drive_c/oracle/product/12.2.0/client_1/network/admin/tnsnames.ora
	touch /home/$username/.wine/drive_c/oracle/product/12.2.0/client_1/network/admin/sqlnet.ora
		{
		echo '#SQLNET.AUTHENTICATION_SERVICES= (NTS)'
		echo 'NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT)'
		} > /home/$username/.wine/drive_c/oracle/product/12.2.0/client_1/network/admin/sqlnet.ora
fi

if [ $oracle_version = 'InstantClient' ]; then
	echo 'Регистрация TNSNAME и SQLNET InstantClient 19' >> /home/$username/linux_installer/install_log.log
	touch /home/$username/.wine/drive_c/oracle/tnsnames.ora
		{
		echo ''$name_db' ='
		echo '  (DESCRIPTION ='
		echo '    (ADDRESS_LIST ='
		echo '      (ADDRESS = (PROTOCOL = TCP)(HOST = '$ip_base')(PORT = 1521))'
		echo '    )'
		echo '    (CONNECT_DATA ='
		echo '      (SERVICE_NAME = '$name_db')'
		echo '    )'
		echo '  )'
		} > /home/$username/.wine/drive_c/oracle/tnsnames.ora
	touch /home/$username/.wine/drive_c/oracle/sqlnet.ora
		{
		echo '#SQLNET.AUTHENTICATION_SERVICES= (NTS)'
		echo 'NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT)'
		} > /home/$username/.wine/drive_c/oracle/sqlnet.ora
		cd /home/$username/.wine/drive_c/oracle
		wine regedit reg_instantclient
fi
}


function Config_print(){
	if [ -d $JAVA_catalog_arm ]; then
	echo 'OpenOfficeInstallLocation='$libre_office_install_location'' > $JAVA_catalog_arm'OpenOfficeProps.properties'
	fi
}


#Запуск функций

Select_Wine
Install_Winetricks
Install_Oracle_12
Install_Oracle_11
Install_Oracle_Instant
Install_Postgre_Sql
Cp_Arm
Create_Oracle_Connect

if [[ $icon_version -eq 6 ]];
then

    tar -xf /home/$username/linux_installer/java6_icons.tar

    Create_C_ico_legacy
    Create_java_ico_sh_legacy

elif [[ $icon_version -eq 8 ]];
then

    tar -xf /home/$username/linux_installer/java8_icons.tar -C /home/$username --strip-components=1

    libpath='java.library.path=../lib/'
    catalog_ico='/home/'$username'/ico/'
    C_catalog_arm='/home/'$username'/.wine/drive_c/ARIADNA/APP/'
    C_catalog_img_ico='/home/'$username'/cpp_ico/'
    JAVA_catalog_arm='/home/'$username'/.wine/drive_c/ARIADNA/APP/JAVA/bin/'
    JAVA_catalog_img_ico='/home/'$username'/java_ico/'

    Create_C_ico

    if [[ $msoffice -eq 1 ]];
    then
        Create_java_ico_sh
    else
        Create_java_ico_wine
    fi

fi

Config_print

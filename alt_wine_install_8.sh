#!/bin/bash

wine_log=/tmp/wine_install.log

case $EUID in
   0) ;;
   *) echo "Требуется повышение привилегий - введите пароль root:"
      su root -c $0 "$@" ;;
esac
LAST_DIR=$PWD

if [ $EUID == 0 ];
then

  mkdir /tmp/winebuild
  cd /tmp/winebuild
  apt-get -y install git > $wine_log
  git clone https://gitlab.winehq.org/wine/wine.git
  cd *

  echo "[ Устанавливаем библиотеки сборки WINE64 ]"
  apt-get -y install \
  libSDL2-devel \
  libxslt-devel \
  libxml2-devel \
  libjpeg-devel \
  liblcms2-devel \
  libpng-devel \
  libtiff-devel \
  libgphoto2-devel \
  libsane-devel \
  libcups-devel \
  libalsa-devel \
  libgsm-devel \
  libmpg123-devel \
  libpulseaudio-devel \
  libopenal-devel \
  libGLU-devel \
  libusb-devel \
  libieee1284-devel  \
  libkrb5-devel \
  libv4l-devel \
  libunixODBC-devel \
  libnetapi-devel  \
  libpcap-devel \
  libgtk+3-devel \
  libcairo-devel \
  libva-devel \
  libudev-devel \
  udev  \
  libdbus-devel \
  libICE-devel  \
  libSM-devel \
  libxcb-devel \
  libX11-devel \
  libXau-devel \
  libXaw-devel \
  libXrandr-devel \
  gstreamer-devel \
  gst-plugins-devel \
  libXext-devel \
  libXfixes-devel \
  libXfont-devel \
  libXft-devel \
  libXi-devel \
  libXmu-devel \
  libXpm-devel \
  libXrender-devel \
  libXres-devel  \
  libXScrnSaver-devel \
  libXinerama-devel \
  libXt-devel \
  libXxf86dga-devel  \
  libXxf86misc-devel \
  libXcomposite-devel \
  libXxf86vm-devel \
  libfontenc-devel \
  libXdamage-devel \
  libXvMC-devel \
  libXcursor-devel \
  libXevie-devel \
  libldap-devel \
  libgnutlsxx-devel \
  libEGL-devel \
  libGL-devel \
  xorg-dri-swrast \
  glsl-optimizer \
  libGLU-devel \
  libGLw-devel \
  libXv-devel >> $wine_log

  #all
  echo "[ Нужные утилиты ]"
  apt-get -y install \
  desktop-file-utils \
  perl-XML-Simple >> $wine_log

  #32
  echo "[ Устанавливаем библиотеки сборки WINE32 ]"
  apt-get -y install \
  glibc-pthread  \
  glibc-nss \
  i586-libSDL2-devel \
  i586-libxslt-devel  \
  i586-libxml2-devel \
  i586-libjpeg-devel \
  i586-liblcms2-devel \
  i586-libpng-devel \
  i586-libtiff-devel \
  i586-libgphoto2-devel \
  i586-libsane-devel  \
  i586-libcups-devel \
  i586-libalsa-devel \
  i586-libgsm-devel \
  i586-libmpg123-devel \
  i586-libpulseaudio-devel \
  i586-libopenal-devel  \
  i586-libGLU-devel \
  i586-libusb-devel \
  i586-libieee1284-devel  \
  i586-libkrb5-devel \
  i586-libv4l-devel \
  i586-libunixODBC-devel \
  i586-libpcap-devel \
  i586-libfaudio-devel \
  i586-libgtk+3-devel  \
  i586-libcairo-devel \
  i586-libva-devel \
  i586-libudev-devel  \
  i586-libdbus-devel \
  i586-libICE-devel  \
  i586-libSM-devel \
  i586-libxcb-devel \
  i586-libX11-devel \
  i586-libXau-devel \
  i586-libXaw-devel \
  i586-libXrandr-devel \
  i586-libXext-devel  \
  i586-libXfixes-devel \
  i586-libXfont-devel  \
  i586-libXft-devel \
  i586-libXi-devel \
  i586-libXmu-devel \
  i586-libXpm-devel \
  i586-libXrender-devel \
  i586-libXres-devel  \
  i586-libXScrnSaver-devel \
  i586-libXinerama-devel \
  i586-libXt-devel \
  i586-libXxf86dga-devel  \
  i586-libXxf86misc-devel \
  i586-libXcomposite-devel \
  i586-libXxf86vm-devel \
  i586-libfontenc-devel \
  i586-libXdamage-devel \
  i586-libXvMC-devel \
  i586-libXcursor-devel  \
  i586-libXevie-devel \
  i586-libldap-devel \
  i586-libgnutlsxx-devel \
  i586-libEGL-devel \
  i586-libGL-devel \
  i586-libGLU-devel \
  i586-libGLw-devel \
  i586-xorg-dri-swrast \
  i586-libXv-devel >> $wine_log

  echo "[ Устанавливаем среду разработки ]"
  apt-get -y install i586-gcc8 i586-gcc8-c++ i586-gcc8-fortran i586-glibc-core >> $wine_log
  apt-get -y install gcc8 gcc8-c++ gcc8-fortran glibc-core cmake >> $wine_log
  apt-get -y install m4 bison flex build-environment >> $wine_log
  mkdir -p build-win64 build-win32
  cd build-win64
  echo "[ Собираем Win64 окружение ]"
  PKG_CONFIG_PATH=/usr/lib64 ../configure --enable-win64 --prefix=/usr >> $wine_log
  make -j2 >> $wine_log
  cd ../build-win32
  echo "[ Собираем Win32 окружение ]"
  PKG_CONFIG_PATH=/usr/lib ../configure --with-wine64=../build-win64 --prefix=/usr >> $wine_log
  make -j2 >> $wine_log
  echo "[ Устанавливаем WINE ]"
  make install >> $wine_log
  cd ../build-win64
  echo "[ Устанавливаем WINE64 ]"
  make install >> $wine_log
  echo "[ Good luck with that ]"
  read -n 1 -s -r -p "Нажмите любую кнопку для выхода из скрипта"
  #Компиляция win64, потом win32. После устанавливаем сначала второй, потом первый

fi

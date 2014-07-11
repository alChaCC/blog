---
layout: post
title: "[Installation Guide] RobotFramework 2.7.4 + Sikuli + DatabaseLibrary +SSHLibrary + Seleniumlibrary (jybot and pybot)in Ubuntu 12.04"
date: 2012-10-16 11:39
comments: true
categories: [RobotFramework]
---

##Prepare

1. ubuntu-12.04.1-desktop-i386
2. VirtualBox


##Installation Ubuntu in VirtualBox

流程請參考

[VirtualBox - Install Ubuntu 12.4](http://www.deltalounge.net/wpress/2012/06/virtualbox-install-ubuntu-12-04/)

[VirtualBox 4.1安裝Ubuntu 12.04](http://blog.xuite.net/yh96301/blog/60374490-VirtualBox+4.1%E5%AE%89%E8%A3%9DUbuntu+12.04)
<!--more-->
## Update / Upgrade apt-get
	
	$ sudo apt-get update
	$ sudo apt-get -f upgrade


## Install VIM

	$ sudo apt-get install vim

## Install Python

	$ python --version
Ubuntu 已經幫你安裝好了

<!--more--> 
## Install Java

（http://maketecheasier.com/install-java-runtime-in-ubuntu/2012/05/14）

	$ sudo apt-get install openjdk-7-jre
	$ java -version
	

## Install Jython

	$ sudo apt-get install jython  
 
## Install Robotframework

Download _robotframework-2.7.4.tar.gz_

	$ cd Downloads
	$ tar -zxv -f robotframework-2.7.4.tar.gz
	$ cd robotframework-2.7.4
	$ sudo python setup.py install
	$ sudo jython setup.py install
	$ pybot --version
	$ jybot --version
	
####2012/10/16補充

	if you get "jybot: command not found"
	
	$ ln -s  /usr/local/bin/jybot /usr/share/jython/bin/jybot 

## Intall ez_install
	
	$ wget http://peak.telecommunity.com/dist/ez_setup.py
	$ python ez_setup.py

## Install Database Library (pybot only)
	
	$ easy_install robotframework-databaselibrary
	$ sudo apt-get install python-mysqldb
	
## Install paramiko

	$ sudo apt-get install python-paramiko
	
## Install SSH Library

	$ tar -zxv -f robotframework-sshlibrary-1.1.tar.gz 
	$ cd robotframework-sshlibrary-1.1
	$ sudo python setup.py install
	$ sudo jython setup.py install
	
## Install Seleniumlibrary
	
	$ tar -zxv -f robotframework-sshlibrary-1.1.tar.gz 
	$ cd robotframework-sshlibrary-1.1
	$ sudo python setup.py install
	$ sudo jython setup.py install

## Install SVN

	$ sudo apt-get install subversion

## Install Sikuli related package
	
	$ sudo apt-get install wmctrl
	$ sudo apt-get install libopencv-*
	$ sudo apt-get isntall python-opencv
	$ sudo apt-get install build-essential libgtk2.0-dev libjpeg-dev libtiff4-dev libjasper-dev libopenexr-dev cmake python-dev python-numpy python-tk libtbb-dev libeigen2-dev yasm libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev libqt4-dev libqt4-opengl-dev sphinx-common texlive-latex-extra libv4l-dev libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev
	
上面是參考[Installing OpenCV 2.4.1 in Ubuntu 12.04 LTS](http://www.samontab.com/web/2012/06/installing-opencv-2-4-1-ubuntu-12-04-lts/)


####2012/10/16補充

	$ echo "deb http://us.archive.ubuntu.com/ubuntu/ oneiric universe"  >> /etc/apt/sources.list
	$ echo "deb http://us.archive.ubuntu.com/ubuntu/ oneiric-updates universe" >> /etc/apt/sources.list
    $ sudo apt-get update
    $ sudo apt-get install libcv2.1 libcvaux2.1 libhighgui2.1
		
## Install Rdesktop for Windows Login (Sikuli Used)

	# sudo apt-get install rdesktop
	
## Prepare Related jar for Jybot
	
你必須要下載，我是把它放在我的test folder裡面 ex: resource/keyword/LinuxEnvirement
	
	sikuli-script.jar
	trilead-ssh2-build213.jar
	dblibrary-2.0.jar
	mysql-connector-java-5.1.18-bin.jar
	
		
## Ubuntu Run Script Sample

> PATH is very IMPORTANT

	#!/bin/bash
	
	if [ $# -lt 4 ]; then
	        echo "usage : sh run_tests.sh "Test_IP" "Database_IP" "BriefTest/FullTest" "Revison"
	        exit 1
	fi
	
	#===========================================================
	# 這一段是把我的Sikuli所要使用的圖片路徑加進AddImagePath.py裡面
	# Absolute path to this script
	SCRIPT=`readlink -f $0`
	# Absolute path this script is in
	SCRIPTPATH=`dirname $SCRIPT`
	CONFIG_FILE=$SCRIPTPATH/resource/keyword/AddImagePath.py
	echo $SCRIPTPATH
	#sed -i 's/Winbasic=.*/Winbasic=""/g' $CONFIG_FILE
	sed -i -e "s@Winbasic=.*@Winbasic=\"$SCRIPTPATH/..\/Lib\/keyword\/Others\/Sikuli\/Windows_Operating.sikuli\/ImagesOfWindowsBasicOperation\"@g" $CONFIG_FILE
	sed -i -e "s@Shutdown=.*@Shutdown=\"$SCRIPTPATH/..\/Lib\/keyword\/Others\/Sikuli\/Windows_Operating.sikuli\/ImagesOfShutdown\"@g" $CONFIG_FILE
	sed -i -e "s@CreateFile=.*@CreateFile=\"$SCRIPTPATH/..\/Lib\/keyword\/Others\/Sikuli\/Windows_Operating.sikuli\/ImagesOfCreateFile\"@g" $CONFIG_FILE
	sed -i -e "s@Format=.*@Format=\"$SCRIPTPATH/..\/Lib\/keyword\/Others\/Sikuli\/Windows_Operating.sikuli\/ImagesOfFormat\"@g" $CONFIG_FILE
	sed -i -e "s@WinRDP=.*@WinRDP=\"$SCRIPTPATH/..\/Lib\/keyword\/Others\/Sikuli\/Windows_Operating.sikuli\/ImagesOfWinRDP\"@g" $CONFIG_FILE
	#===========================================================
	
	MYDIRPATH=../Lib/keyword/Others/Sikuli/Windows_Operating.sikuli:resource/keyword
	LOCALPATH=resource/keyword/LinuxEnvirement
	
	VERSION=$4
	TESTSCALE=$3
	Test_IP=$1
	Database_IP=$2
		
	export CLASSPATH=$LOCALPATH/sikuli-script.jar:$LOCALPATH/trilead-ssh2-build213.jar:$LOCALPATH/dblibrary-2.0.jar:$LOCALPATH/mysql-connector-java-5.1.18-bin.jar
	export JYTHONPATH=/usr/share/jython/Lib:$LOCALPATH/sikuli-script.jar/Lib 
	
	
	jybot --pythonpath $MYDIRPATH  --outputdir test --exclude no_run --include $TESTSCALE --loglevel TRACE -l Windows_log_$TESTSCALE\_$VERSION -r Windows_report_$TESTSCALE\_$VERSION -o Windows_output_$TESTSCALE\_$VERSION --variable Database_IP:$Database_IP --variable Test_IP:$Test_IP Windows_TestCase.txt


最重要就是要告訴JYTHONPATH


大概是這樣！

有些lib是為了可以跑sikuli裝的 沒有時間一一去驗證是否真的需要....


> 特別感謝 EJ 和 林旺 提供強大支援！

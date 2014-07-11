---
layout: post
title: "10分鐘安裝RobotFramework/Database Library/SSH Library/Selenium Library on CentOS"
date: 2012-02-24 21:30
comments: true
categories: RobotFramework
---

10分鐘安裝RobotFramework on CentOS 5.5


今天為了趕下班 快速建立的RobotFramework 在乾淨的CentOS 5.5上！

真的是快速！ 要謝謝 __Mac大大__ 強力快手支援

##安裝python 2.6
  	yum install python26
##安裝easy_install
  	wget http://peak.telecommunity.com/dist/ez_setup.py
  	python26 ez_setup.py 
  	
<!--more-->

##安裝Robotframework 2.6.3
  	easy_install robotframework==2.6.3
##安裝Database Library python 版
  	easy_install robotframework-databaselibrary
##安裝MySQLDB for DatabaseLibrary  
  	yum install  python26-mysqldb
##安裝paramiko for SSH Library
  	yum install  python26-paramiko.noarch
##安裝gcc for SSH Library
	yum install gcc
##安裝SSH Library
  	wget http://robotframework-sshlibrary.googlecode.com/files/SSHLibrary-1.0.tar.gz
  	tar -zxv -f SSHLibrary-1.0.tar.gz 
  	cd SSHLibrary-1.0
  	python2.6 setup.py install
  	
##安裝SeleniumLibrary
	wget http://robotframework-seleniumlibrary.googlecode.com/files/robotframework-seleniumlibrary-2.8.tar.gz
	tar -zxv -f robotframework-seleniumlibrary-2.8.tar.gz
	cd robotframework-seleniumlibrary-2.8
	python2.6 setup.py install
##安裝SVN (額外)
  	yum install subversion


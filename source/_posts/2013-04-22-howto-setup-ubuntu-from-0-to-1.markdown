---
layout: post
title: "HOWTO-Setup-Ubuntu-from-0-to-1"
date: 2013-04-22 15:11
comments: true
categories: Linux 
---


### 先升級

	sudo apt-get update
	sudo apt-get upgrade
	
ps. 如果update失敗的話，請到

Ubuntu Software Center -> Edit -> Software Sources

把Download from 改成其他國家(我是把它改成Server for United States)

在試一次

### 安裝vim

	sudo apt-get install vim

### 安裝Chrome

	連到google 網址點選下載再安裝

<!--more--> 

### 安裝virtualbox

	到Ubuntu Software Center 搜尋並安裝
	
### 安裝vmplayer


	sudo apt-get install build-essential linux-headers-$(uname -r)

	Download the latest VMware player e.g. VMware-Player-3.1.4-385536.i386.bundle 
	
	gksudo bash ./Downloads/VMware-Player-3.1.4-385536.i386.bundle

	*如果需要解除安裝* vmware-installer -u vmware-player
	
### 安裝顯示卡驅動程式

	sudo apt-get install nvidia-current
	
ps. 之後，我螢幕就變得很漂亮了XD 我沒有做任設定

### 安裝svn
	
	sudo apt-get intsall subversion

### 安裝pidgin

聊天室功能 要有oc功能

	sido apt-get install pidgin	 pidgin-sipe

ps. 因為現在lync 有bug , 所以在執行pidgin時，要先執行

	export NSS_SSL_CBC_RANDOM_IV=0

### 安裝vnc server

	sudo apt-get install vnc4server

### 安裝vsftp

	sudo apt-get install vsftp
	
### 安裝retext

	sudo apt-get install retext

### 安裝foxitReader
	
	請參考[How to Make Foxit Reader Work in Ubuntu 12.04 & 11.10 Oneiric Ocelot?](http://www.hecticgeek.com/2012/02/foxit-reader-work-ubuntu-linux/)

	PS.注意你是不是跟我一樣 用64 Bit
	
### 安裝RoR

[How to Install Ruby on Rails on Ubuntu 12.04 LTS (Precise Pangolin) with RVM](https://www.digitalocean.com/community/articles/how-to-install-ruby-on-rails-on-ubuntu-12-04-lts-precise-pangolin-with-rvm)

	echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc 

ps. 之後可能用到[How to Install Rails, Apache, and MySQL on Ubuntu with Passenger](https://www.digitalocean.com/community/articles/how-to-install-rails-apache-and-mysql-on-ubuntu-with-passenger)

如果bundle install時,遇到An error occured while installing pg (0.12.2)

	sudo apt-get install libpq-dev

### 安裝TextMate-liked 

[TextMate for Ubuntu Linux](http://blog.sudobits.com/2011/04/02/textmate-for-ubuntu-linux/)

[Top 10 gedit plugins for Programmers](http://blog.sudobits.com/2012/03/06/top-10-gedit-plugins-for-programmers/)

	
### 如果突然網路不通

	sudo ifup -a




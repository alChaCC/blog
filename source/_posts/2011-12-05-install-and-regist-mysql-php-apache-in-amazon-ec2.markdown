---
layout: post
title: "申請安裝Apache,PHP,MySQL在Amazon Web Service-EC2 - 筆記"
date: 2011-12-05 23:11
comments: true
categories: [Linux , AWS ]  
---


###請到amazon web service 申請 EC2 ，申請太多教學了，請參考

   [什麼是雲端服務？阿正老師教你免費玩Amazon EC2雲端主機！(上篇)](http://blog.soft.idv.tw/?p=823)

   [阿正老師教你免費玩Amazon EC2雲端主機(下篇)：主機實戰篇](http://blog.soft.idv.tw/?p=824)

不過，我是手賤點了SuSE的image，另外我有先開了

	22的port  (ssh用)
   
    80的port  (http用)

	443的port (https用)
<!--more--> 

ps. 不過…我不習慣用SuSE，之前都是看鳥哥 所以比較會用的是CentOS，所以如果你是想要用CentOS請直接選前兩個image

Basic 32-bit Amazon Linux AMI 2011.09

Basic 64-bit Amazon Linux AMI 2011.09

即可～ 另外他會有key讓你下載 請務必下載啊～～～～

###登入和阿正老師不同的地方是 我是用Mac OSX的terminal登入，不過也很簡單，

	cd 到你剛剛放.pem檔的資料夾 

	ssh -v -i try_try_see.pem root@ec2-XX-XX-XX-XX.us-west-2.compute.amazonaws.com

恭喜你登入成功的啦～

###更新

	zypper update

###安裝gcc/gcc-c++
	
	zypper install gcc 

	zypper install gcc-c++
	

###安裝mysql
	
	zypper install -y mysql

	/etc/init.d/mysql start
	
	chown root /etc/my.cnf 
	chgrp root /etc/my.cnf 
	chmod 644 /etc/my.cnf 
	vim /etc/my.cnf
	把user = mysql 加到[mysqld]底下

###安裝php 和 apache2
	
	 zypper install -y apache2 apache2-mod_perl apache2-mod_php5 php5 php5-mbstring php5-pear
 	
	ln -s /usr/bin/perl /usr/local/bin/perl

接著就按照[server-world](http://www.server-world.info/en/note?os=SUSE_Linux_Enterprise_Server_11&p=httpd&f=1)
的教學去修改裡頭的設定吧…

我發現這個server-world已經把我需要的東東都放教學上去了！

不推不行啊！

TODO : 
	
  Ftp server 和 設定固定IP






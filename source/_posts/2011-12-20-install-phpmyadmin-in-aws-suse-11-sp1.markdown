---
layout: post
title: "安裝phpMyAdmin in AWS(SUSE 11 sp1)"
date: 2011-12-20 22:34
comments: true
categories: [AWS,Linux]
---

以下真的是用倒推的方式去灌出來的…科科

不知道為甚麼 平台就是一堆有的沒的都沒有…囧

	zypper install phpMyAdmin


找不到phpMyAdmin的package！

於是乎 

	zypper addrepo http://download.opensuse.org/repositories/server:/php:/applications/SLE_11/server:php:applications.repo

在執行一次

	zypper install phpMyAdmin

<!--more--> 

出現

	問題： 無法提供 php-mysql (phpMyAdmin-3.4.8-27.1.noarch 需要此項目)

所以…

	zypper addrepo http://download.opensuse.org/repositories/server:/php/SLE_11/server:php.repo

然後再試看看

	zypper install php5-mysql

咦～看起來好像都ＯＫ，所以就繼續安裝phpMyAdmin吧…結果…

	zypper install phpMyAdmin

	問題： phpMyAdmin-3.4.8-27.1.noarch 需要 php-mcrypt，但無法提供此需求

囧......所以我就又安裝了

	zypper install php5-mcrypt

結果…

	問題： 無法提供 libltdl.so.7 (php5-mcrypt-5.3.8-120.1.i586 需要此項目)

挖哩勒，所以我又

	zypper addrepo http://download.opensuse.org/repositories/Base:/System/SLE_11_SP1/Base:System.repo
	
	zypper update libltdl7

但是他建議我安裝，所以我又改成了下面那行

	zypper install libltdl7-2.4.2-45.1.x86_64

ＯＫ～繼續Go吧…剛剛裝到php5-mcrypt

	zypper install php5-mcrypt

又來了…

	問題： 無法提供 libmcrypt.so.4 (php5-mcrypt-5.3.8-120.1.i586 需要此項目)

所以我又裝了

	zypper addrepo http://download.opensuse.org/repositories/security:/privacy/SLE_11_SP1/security:privacy.repo

	zypper install libmcrypt

之後再回來裝

	zypper install php5-mcrypt

耶！成功了～

ＯＫ～繼續來

	zypper install phpMyAdmin

幹

	問題： phpMyAdmin-3.4.8-27.1.noarch 需要 php-gd，但無法提供此需求

於是我裝了

	zypper install php5-gd

結果…

	問題： 無法提供 libt1.so.5 (php5-gd-5.3.8-120.1.i586 需要此項目)

於是我又

	zypper addrepo http://download.opensuse.org/repositories/devel:/libraries:/c_c++/SLE_11/devel:libraries:c_c++.repo

	zypper install t1lib

再來回到剛剛的安裝

	zypper install php5-gd

最後

	zypper install phpMyAdmin

終於！大功告成了…科科


>Sum up : 

	zypper addrepo http://download.opensuse.org/repositories/server:/php:/applications/SLE_11/server:php:applications.repo

	zypper addrepo http://download.opensuse.org/repositories/server:/php/SLE_11/server:php.repo

	zypper addrepo http://download.opensuse.org/repositories/devel:/libraries:/c_c++/SLE_11/devel:libraries:c_c++.repo

	zypper addrepo http://download.opensuse.org/repositories/security:/privacy/SLE_11_SP1/security:privacy.repo

	zypper addrepo http://download.opensuse.org/repositories/Base:/System/SLE_11_SP1/Base:System.repo

	zypper install php5-mysql

	zypper install libltdl7-2.4.2-45.1.x86_64	

	zypper install libmcrypt

	zypper install t1lib

	zypper install php5-mcrypt

	zypper install php5-gd

	zypper install phpMyAdmin


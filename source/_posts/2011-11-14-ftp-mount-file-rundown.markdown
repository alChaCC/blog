---
layout: post
title: "[超簡單]FTP 掛NTFS硬碟檔給別人抓-CentOS"
date: 2011-11-14 00:46
comments: true
categories: Linux 
---

這有兩個issue

一個是NTFS格式如何掛到CentOS

一個是把掛上去的資料夾，可以讓FTP抓到

#NTFS格式如何掛到CentOS

a. 先[安裝ntfs-3g](http://www.tuxera.com/community/ntfs-3g-download/) 

b. 先fdisk -l 找到你剛剛放上去的硬碟

c. 把那個硬碟掛上去吧
{%codeblock lang:ruby%}
mount -t ntfs-3g /dev/XXX /aloha/coolfolder
{% endcodeblock %}
<!--more--> 
不過這邊，我想要改使用權限是沒辦法改的

我的操作是 
{%codeblock lang:ruby%}
chown -R aloha:aloha /aloha/coolfolder
{%endcodeblock%}

不過....是無法改掉權限的....目前尚未解決

那我還是要將那個硬碟的檔案給人家抓阿阿阿阿阿～

所以....只好使用下面那個笨方法

#把掛上去的資料夾，可以讓FTP抓到

真的是笨方法....不過先暫時給我擋著用

所以我的"暫時"解決方法....就是在多開一個資料夾 不過改他的資料夾的權限, 改成是該user的權限

*建立資料夾2號*
	
{%codeblock lang:ruby%}
mkdir /aloha/資料夾2號
{% endcodeblock %}

*把硬碟檔案複製到資料夾2號*
	
{%codeblock lang:ruby%}
cp -r /aloha/coolfolder /aloha/資料夾二號/
{% endcodeblock %}

還是要再次的強調喔！ -r 是可以複製目錄，但是，檔案與目錄的權限可能會被改變 # 所以，也可以利用『 cp -a /etc /tmp 』來下達指令喔！尤其是在備份的情況下！
-from鳥哥

*改變資料夾2號權限，把資料夾2號改成“不是root”，這樣就可以被ftp使用*
	
{%codeblock lang:ruby%}
chown -R 你要改變的帳號  資料夾2號
chgrp  -R 你要改變的帳號  資料夾2號
{% endcodeblock %}


完成！ 夠笨了吧....有沒有高手有其他solution歡迎提供啊～～


=========================給自己的附記=============================

#掛FAT USB

把檔案格式FAT32的usb準備好 插到電腦

* 掛載隨身碟[參閱自鳥哥]，你要有root權限啊，以下指令我都是當自己是root

請拿出你的隨身碟並插入 Linux 主機的 USB 槽中！注意，你的這個隨身碟不能夠是 NTFS 的檔案系統

* 找出你的隨身碟裝置檔名

{% codeblock lang:ruby %}
	df -h 
{% endcodeblock %}
* 建立掛載點
{% codeblock lang:ruby %}
	 mkdir /mnt/flash
{% endcodeblock %}
* 挂上去吧	
{% codeblock lang:ruby %}
	mount -t vfat -o iocharset=cp950 /dev/XXX /mnt/flash
{% endcodeblock %}

如果帶有中文檔名的資料，那麼可以在掛載時指定一下掛載檔案系統所使用的語系資料。 在 man mount 找到 vfat 檔案格式當中可以使用 iocharset 來指定語系，而中文語系是 cp950 ， 所以也就有了上述的掛載指令項目囉。


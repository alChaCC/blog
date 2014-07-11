---
layout: post
title: "在AWS的SUSE 11安裝與設定FTP Server-使用AWS command line tool"
date: 2011-12-17 19:16
comments: true
categories: [AWS , Linux] 
---

前陣子AWS EC2好像怪怪的

本來用好好的zypper install 指令居然出了問題！

yast2和zypper都沒辦法抓東西 出現Download failed: Download (curl) error !!!

今天又莫名其妙的好了～

<!--more--> 

不過那個repo url卻不見了 所以在開始之前

我先把repo url 加進去，因為我的EC2是使用suse 11 sp1

所以我的指令是
	
	zypper addrepo http://download.opensuse.org/repositories/server:/ftp/SLE_11_SP1/server:ftp.repo


之後就可以安裝FTP了！

	zypper install -y vsftpd 

先加個可以使用ftp的user進來，並設定密碼給他

	useradd User_FTP
	passwd  User_FTP

做個家目錄給他,別忘了改權限（因為我現在是用root）	
	
	mkdir /home/User_FTP
	chown User_FTP User_FTP

設定就參考這篇[Install VSFTPD](http://www.server-world.info/en/note?os=SUSE_Linux_Enterprise_Server_11&p=ftp&f=1)
	
另外參考[鳥哥](http://linux.vbird.org/linux_server/0410vsftpd.php#server_pkg) 我還有改

	pasv_enable=YES
	idle_session_timeout=300
	listen=YES
	max_clients=2
	max_per_ip=1

我還有改(加User_FTP進去)
	
	vim /etc/ftpusers 

之後下 
	
	/etc/init.d/vsftpd start

居然出現error

	Starting vsftpd startproc:  exit status of parent of /usr/sbin/vsftpd: 1              failed


結果居然是我要block掉listen_ipv6=YES 

	＃listen_ipv6=YES

這樣就可以啟動了…

	/etc/init.d/vsftpd start

之後我嘗試用filezilla來開…結果居然連不到！科科

我想應該是port沒開的關係

網頁上我不知道要怎麼直接開一個21的port (打完網誌時，我已經會開了囧…沒關係當作一個學習～有指令集以後也可以自動化管理！科科～)

我就用指令集來做

> 注意！我現在是在自己電腦的console

所以首先你必須要下載[Amazon EC2 API Tools](http://aws.amazon.com/developertools/351?_encoding=UTF8&jiveRedirect=1)

	unzip 你剛剛下載到的路徑
	ex: unzip ~/Destop/ec2-api-tools-1.5.0.1-2011.11.30

抓完之後 還要一些設定可以參考[Setting Up the Tools](http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/setting-up-your-tools.html) 

首先你要先下載private key 和  X.509  ,參考下面步驟

>To create a certificate

>1. Go to the AWS Web Site.

>2. Point to Your Account and select Security Credentials.

>3. If you are not already logged in, you are prompted to do so.

>4. Click the X.509 Certificates tab

>5. Click Create a New Certificate and follow the on-screen prompts.

>6. The new Certificate is created and appears in the X.509 Certificate list. You are prompted to download the certificate and private key files.


抓好CERT-XXXXX.PEM和private key之後，

我的做法如下

	cd ~
	mkdir .ec2
	cd .ec2
	cp 你剛剛下載的路徑/cert-XXXXX.pem  .
	cp  你剛剛下載的路徑/pk-XXXXXX.pem  .
	cp -a ~/Desktop/ec2-api-tools-1.5.0.1-2011.11.30/bin .
	cp -a ~/Desktop/ec2-api-tools-1.5.0.1-2011.11.30/lib .
	echo "export EC2_HOME=~/.ec2" >> ~/.bash_profile
	echo "export PATH=\$PATH:\$EC2_HOME/bin" >> ~/.bash_profile
	echo "export EC2_PRIVATE_KEY=\`ls \$EC2_HOME/pk-*.pem\`" >> ~/.bash_profile
	echo "export EC2_CERT=\`ls \$EC2_HOME/cert-*.pem\`" >> ~/.bash_profile
	echo "export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home/" >> ~/.bash_profile
	source ~/.bash_profile

開始來開20~21的port八, 因為鳥哥有說

>FTP 在建立連線以及資料傳輸時，會建立兩種連線，分別是命令通道與資料傳輸通道。在主動式連線上為 port 21(ftp) 與 port 20(ftp-data)。
	
	ec2-authorize 你的SecurityGroup名稱 -p 20-21
  	#ex: ec2-authorize open_ftp -p 20-21

在還有  因為鳥哥也有說

>用戶端隨機取用大於 1024 的埠口進行連接：
然後你的用戶端會隨機取用一個大於 1024 的埠號來對主機的 port PASV 連線。 如果一切都順利的話，那麼你的 FTP 資料就可以透過 port BB 及 port PASV 來傳送了。
	
	ec2-authorize 你的SecurityGroup名稱 -p 30000-30100
										（這個範圍我參考conf檔）
開心地點開FileZilla

幹，奇怪！為啥我還是無法連線到我的server,這時候打開瀏覽器，連結到你的AWS console 畫面，點到Security Group 

你發現…奇怪default好像沒有被加打開這兩個port的指令…囧

卡關超久，東看西看…終於知道為甚麼了！

>需要加上--region指令
>因為Command line的default是us-east! 囧…

所以當你把指令改成

	ec2-authorize 你的SecurityGroup名稱 -p 30000-30100  --region us-west-2
	ec2-authorize 你的SecurityGroup名稱 -p 20-21	--region us-west-2

就成功啦！！！

ps. 另外你也可以使用下面的指令，看你現在有哪些Security Group
	
	ec2-describe-group --region us-west-2 
 
看現在instance狀況

	ec2-describe-instances --region us-west-1
	
這時你就可以用ftp了！

但是會發現…好像哪裡怪怪的

在filezilla會出現一個很怪的訊息

	狀態:	伺服器以無法路由的 IP Address 送出了被動式回應. 改為使用伺服器 IP Address.

這時你要先加個東西在/etc/vsftpd.conf,參考自[Install and Configure FTP Server in Amazon EC2 instance](http://linuxadminzone.com/install-and-configure-ftp-server-in-amazon-ec2-instance/)

	pasv_address=<Public IP of your instance>

這樣應該就沒有問題了！

===============================================================

另外，我也申請好固定IP

	在navigation那邊，點選
	Elastic IPs

申請一個之後，點選哪個IP然後再點上面的

	Associate Address

連結到你的Instance

> 另外我發現，若VM重開的話，你還是必需要重新連結一次你的elastic IP

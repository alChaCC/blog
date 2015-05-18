---
layout: post
title: "機器監控不求人 - 猴子都會用的 Monit(Monitoring your ubuntu machine for dummies)"
date: 2015-05-18 18:21:20 +0800
comments: true
categories: ["MIS"] 
keywords: "Monitor, Monit, Ubuntu, mysql restart automatically, apache2 restart automatically"
description: "this article show you how to monitor your Ubuntu machine using Monit. 機器監控不求人 - 猴子都會用的 Monit"
---

你是個前端工程師，但是，老闆賦予你**MIS**的神聖任務

還是，你是個後端工程師，無時無刻，要去看一下**mysql**是否還活著，**apache2**是否快掛了

還有，你是個**全端工程師**，雖然你已經強的跟神一樣，但是你就是不想要寫的script自動去重啟的service


這時候，你需要的是**[Monit](https://mmonit.com/monit/)**

他可以幫你監控你的daemon processes、檔案系統、Network、Space

如果想要看完整的設定文件請點 **[Monit Documentation](https://mmonit.com/monit/documentation/monit.html)**

整理一下，我的使用的感覺

1. 使用DSL，所以用起來很直覺
2. 使用 # 當作註解
3. [不同的監控，可以有不同的動作(ex: alert, restart, stop, UNMONITOR)](https://mmonit.com/monit/documentation/monit.html#ACTION)
4. [彈性設定時間來監控](https://mmonit.com/monit/documentation/monit.html#SERVICE-POLL-TIME)
5. [彈性設定幾次重啟後，就不要再重啟了](https://mmonit.com/monit/documentation/monit.html#SERVICE-RESTART-LIMIT)
6. [可以用if, else ...等來做動作判斷！](https://mmonit.com/monit/documentation/monit.html#GENERAL-SYNTAX)
7. 簡單來說，超多客製化應用！網路上也滿多資源可以參考！


但是，如果你跟我一樣是個懶人，這時候，你就需要看這篇文章 

<!-- more -->

ps. 這是我剛設定好的樣子，等我有發現哪裡有問題，會再上來更新XD

## Step 1. 安裝Monit

	sudo apt-get install monit
	
## Step 2. 設定他

ps. 我一開始看文件，傻傻的以為設定在 *~/.monitrc*，一切都會work，但是...經過我約莫半小時的測試...我放棄了～ 我還是把它寫在

	sudo vim /etc/monit/monitrc
	
我改了哪些東西

	# 設定Monit多久監控一次
	set daemon 60
	
	#設定log放在哪裡
	set logfile /var/log/monit.log
	
	#設定 mail server 
	set mailserver 你的.postfix.伺服器 port 25
	
	# ps. 如果你的mail server是在其他地方，譬如AWS SES
	# set mailserver email-smtp.us-east-1.amazonaws.com port 587
   	#	username "amazon_username" password "amazon_password"
   	#	using TLSV1
   	#	with timeout 30 seconds
   	
   	# Email格式
	set mail-format {
      	  from: monit@alohacc.cc
  	  reply-to: y.alohac@gmail.com
          subject: [Aloha系統通知] $SERVICE $EVENT at $DATE
          message: Monit $ACTION $SERVICE at $DATE on $HOST: $DESCRIPTION.
             Hi, system now is waiting your attention~~~ come on baby~~
             By Aloooooooooooooooooooooha
        }
    
    	#設定收到所有異常通知的人，貌似目前不支援一次設定很多....所以要key很多遍
	set alert aloha.chen@itrue.com.tw
	set alert y.alohac@gmail.com
	
	# 監控主機CPU、Memory、Swap以及Uptime的數值
	check system ccaloha.cc
    	if loadavg (1min) > 4 then alert
    	if loadavg (5min) > 2 then alert
    	if memory usage > 75% then alert
    	if swap usage > 25% then alert
    	if cpu usage (user) > 70% then alert
    	if cpu usage (system) > 30% then alert
    	if cpu usage (wait) > 20% then alert
    
    
    	# 起Web服務
	 set httpd port 2812 and
   	 	use address 0.0.0.0      # 我要讓他可以對外連線
    	allow localhost			  # 開放localhost可以連
    	#allow 0.0.0.0/0.0.0.0   # 開放所有IP都可以連得到
    	allow 你的.ip.位置        # 只開放你的ip可以連  
    	allow 可登入帳號:他的密碼 
    
    	# 監控Apache2
	check process apache with pidfile /var/run/apache2/apache2.pid
   	 	start program = "/etc/init.d/apache2 start" with timeout 60 seconds
    	stop program  = "/etc/init.d/apache2 stop"
    	if cpu > 50% for 2 cycles then alert
    	#if TOTAL CPU is greater than 80% for 5 cycles then restart
    	if mem > 100 MB for 5 cycles then stop # 網路上參考下來的寫法，但是，monit -t 會報錯
    	if failed port 80 for 2 cycles then restart
    	#if failed port 443 for 2 cycles with timeout 15 seconds then restart # 網路上參考下來的寫法，但是，monit -t 會報錯
    	if failed port 443 for 2 cycles then restart

	# 監控mysql
	check process mysqld with pidfile /var/run/mysqld/mysqld.pid
    	start program = "/etc/init.d/mysql start"
    	stop program = "/etc/init.d/mysql stop"
    	if failed host 127.0.0.1 port 3306 protocol mysql then alert
    	if failed host 127.0.0.1 port 3306 protocol mysql then restart
    	if 7 restarts within 10 cycles then unmonitor

	# 監控硬碟空間使用
	check filesystem root-filesystem with path /dev/xvda1
   	    if space usage > 80% for 5 times within 15 cycles then alert
   	    
   	    
## 啟動它

	1. 檢查config 檔是否正確
		
		sudo monit -t 
		
	2. 啟動
	
		sudo monit 
		
	3. 如果你改了設定檔，你可以這樣重啟

		sudo monit reload
		

 	

---
layout: post
title: "HOWTO:Integrate SSH / Database / Selenium Library and Sikuli in RobotFramework using Jybot"
date: 2012-02-24 22:21
comments: true
categories: RobotFramework 
---

>閱讀此篇之前，我已假設您具備使用RF的經驗，譬如使用SSH / Database / Selenium 撰寫test case 
>另外我的平台是Linux

##準備jar檔
	dblibrary-1.0.jar 
	trilead-ssh2-build213.jar
	mysql-connector-java-5.1.18-bin.jar
	sikuli-script.jar
	
<!--more-->
##準備好你自己寫好的Sikuli函式庫
請參考[HOW-TO: Using Sikuli and RobotFramework in Linux Platform](http://ccaloha.cc/blog/2012/01/05/how-to-using-sikuli-and-robotframework-in-linux-platform/)
	
	假設路徑在/home/aloha/RobotSikuli/Lib/RDPFormatLib
	
##準備好你的Test Case
	假設路徑在/home/aloha/RobotSikuli/test_case.txt
	
##寫script把上面那些東東放進去！<--重要
	#!/bin/bash
	MYLIBDIR=/home/aloha/RobotSikuli/Lib/RDPFormatLib
	export JYTHONPATH="/home/aloha/RobotSikuli/JavaLib/sikuli-script.jar/Lib"
	export CLASSPATH=/home/aloha/RobotSikuli/JavaLib/sikuli-script.jar:/home/aloha/RobotSikuli/JavaLib/trilead-ssh2-build213.jar:/home/aloha/RobotSikuli/JavaLib/dblibrary-1.0.jar:/home/aloha/RobotSikuli/JavaLib/mysql-connector-java-5.1.18-bin.jar  

	jybot --pythonpath $MYLIBDIR  --outputdir test --loglevel TRACE -l log -r report -o output $* test_case.txt
	
##是否要改原先用pybot寫的keyword?
**SSH Library不用改**

**Selenium Library不用改**

**Database Library要改**

1. Library         org.robot.database.keywords.DatabaseLibrary
2. 其他keyword並沒有對應～所以要修改


以上為目前開發經驗，後續會再補充

特別要感謝**Derek**強力支援

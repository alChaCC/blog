---
layout: post
title: "Run RobotFramework-sshlibrary on Ubuntu11.10"
date: 2011-11-03 16:53
comments: true
categories: RobotFramework 
---

a. 先安裝paramiko
  {%codeblock%}
  wget http://www.lag.net/paramiko/download/paramiko-1.7.7.1.tar.gz
 {%endcodeblock%}

b. 安裝easy_install在ubuntu
   {%codeblock%}
  sudo apt-get python-setuptools
{%endcodeblock%}
<!--more--> 
c. tar解壓縮到資料夾下，並進入裡面
   {%codeblock%}
  easy_install ./
{%endcodeblock%}

d. 下載sshlibrary 
 {%codeblock%}
  wget http://robotframework-sshlibrary.googlecode.com/files/SSHLibrary-1.0.tar.gz
{%endcodeblock%}

e. tar解壓縮後，進到該資料夾，安裝sshLibrary
 {%codeblock%}
  python setup.py install
{%endcodeblock%}

f. 建立一個資料夾，把robotframework-sshlibrary的src抓下來(為了要測試他提供的case)
 {%codeblock%}
  svn checkout https://robotframework-sshlibrary.googlecode.com/svn/trunk/
{%endcodeblock%}

g. setup 環境來做他提供的測試
  
  #1  安裝openSSH server
   {%codeblock%}
  sudo apt-get install ssh
  sudo service ssh start
{%endcodeblock%}
   
  #2  建立使用者 test 和並設定密碼為 test
   {%codeblock%}
sudo useradd test
  sudo passwd test
  sudo mkdir /home/test
{%endcodeblock%}
  
  #3  Create user testkey and login as testkey
  {%codeblock%}
 su - test
  ssh-keygen -t rsa 
  cp ~/.ssh/id_rsa ~/.ssh/authorized_keys2
{%endcodeblock%}

  #4  複製id_rsa of testkey user 到 atest/resources/keyfiles
{%codeblock%}
請自行剪下貼上的拉
{%endcodeblock%}

h.  安裝JRE環境 (如果你是用pybot就可以忽略下面兩個步驟)

  {%codeblock%}
 sudo add-apt-repository ppa:ferramroberto/java
  sudo apt-get update
  sudo apt-get install sun-java6-jre sun-java6-plugin sun-java6-fonts
{%endcodeblock%}

i. 下載jython 並安裝, 請自己抓好之後,到那個資料夾下

  {%codeblock%}
 sudo java -jar jython_installer-2.5.2.jar
{%endcodeblock%}

j. 連結 jython 這個指令
  
  {%codeblock%}
 sudo ln -s /你安裝jython的路徑/bin/jython /usr/local/bin/
{%endcodeblock%}
 
k. 在你剛剛下載的robotframework-sshlibrary的src資料夾下(不用進到atest裡面歐)
 
  {%codeblock%}
 sh atest/run_tests.sh
{%endcodeblock%}

恭喜！ 就會開始測試啦

不過我測試時有發現一些錯誤....

我想應該是步驟g的#3那邊有錯誤....囧

不過，大致上流程是這樣摟

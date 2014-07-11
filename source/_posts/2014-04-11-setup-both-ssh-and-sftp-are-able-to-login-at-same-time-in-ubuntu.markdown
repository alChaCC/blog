---
layout: post
title: "Setup both SSH and SFTP are able to login at same time in Ubuntu"
date: 2014-04-11 12:24:15 +0800
comments: true
categories: ["Ubuntu"]
keywords: "Ubuntu, SSH, SFTP"
description: "Setup both SSH and SFTP are able to login at same time in Ubuntu"
---

這篇文章主要是參考自
<http://blog.srmklive.com/2013/04/24/how-to-setup-sftp-server-ftp-over-ssh-in-ubuntu/>
但是，我沒辦法同時使用ssh和sftp
<!--more-->

# Edit ssh config
    sudo vim /etc/ssh/sshd_config

#將底下那行貼上

    PasswordAuthentication no
    Subsystem sftp internal-sftp -f AUTH -1 VERBOSE
    AllowGroups newuser 
    AllowTCPForwarding no
    X11Forwarding no

# Configure IPtable(讓ssh可以通過)

    sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    
## 新增User
 
    sudo adduser newuser
 
## 將你要用來ssh或SFTP的電腦public key輸入到...

In local machine(我是用Mac)

    scp ~/.ssh/id_rsa.pub newuser@ip:~/

In server 

    mkdir .ssh
    cat ~/id_rsa.pub >> ~/.ssh/authorized_keys

這樣就可以了！

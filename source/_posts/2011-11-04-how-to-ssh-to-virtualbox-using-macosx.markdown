---
layout: post
title: "[超簡單]如何不改任何設定，用SSH 登入本機端的VirtualBox(作業系統為MacOSX)"
date: 2011-11-04 15:21
comments: true
categories: Linux
---

a. 你的Mac必須要有VirtualBox -> 這不是廢話..

b. 假設你安裝的是Ubuntu , 並取名為"我最帥的VM" （這個名稱在下個步驟會用到）

{% codeblock lang:ruby %}
sudo apt-get install openssh-server
sudo service ssh restart
{% endcodeblock %} 

<!--more--> 

c. 打開你Mac裡頭的terminal，然後下指令
 
{% blockquote %}
 注意歐！你的虛擬機要先關掉歐！！！
{% endblockquote %}

{% codeblock lang:ruby %}
VBoxManage modifyvm "我最帥的VM" --natpf1 "guestssh,tcp,,2222,,22"
{% endcodeblock %}

d. 恭喜完成～現在你在打開虛擬機，登入即可

{% codeblock %}
ssh  -p 2222 ubuntu使用者帳號@localhost
{% endcodeblock %}



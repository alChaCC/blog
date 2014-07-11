---
layout: post
title: "Installing Robot Framework on Ubuntu11.10"
date: 2011-10-28 15:43
comments: true
categories: RobotFramework 
---

As Title

a. 有ubuntu ->廢話

b. 先確保你的python是新版
{% codeblock %}
sudo apt-get install python
{% endcodeblock %}
<!--more--> 
c.因為我下sudo apt-get install python-setuptools時會出現error
  無法取得這個package,所以我改採自己安裝 
{% codeblock %}
wget http://peak.telecommunity.com/dist/ez_setup.py
{% endcodeblock %}
d.下指令 他就幫你安裝好easy_install了～ 
{% codeblock %}
sudo python ez_setup.py 
{% endcodeblock %}
e.下指令安裝RobotFramework 
{% codeblock %}
sudo easy_install robotframework
{% endcodeblock %}
f. 安裝RIDE
{% codeblock %}
sudo easy_install robotframework-ride
{% endcodeblock %}
g. 安裝wxPython

{% codeblock %}
sudo apt-get install python-wxgtk2.8
{% endcodeblock%}

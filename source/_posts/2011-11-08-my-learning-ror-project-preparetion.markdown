---
layout: post
title: "我的RoR學習專案-準備"
date: 2011-11-08 22:46
comments: true
categories: ["Ruby on Rails"] 
---
 
安裝好開發環境 我有

Ruby 1.8.7 (2010-01-10 patchlevel 249)

Rails 3.1.1

TextMate
 
Mysql  5.1.58 

*到github.com註冊 按照他的[說明文件][1]建立自己的repo吧～

*[安裝git][2] 
<!--more--> 

其他請參考ihower或xdite 文章 

a. 建立git空檔案
	{% codeblock lang:ruby%}
	git init ccaloha
{% endcodeblock %}
b. 建立專案
{% codeblock lang:ruby%}
	rails new ccaloha -d mysql
{% endcodeblock %}
c. 安裝必要元件
{% codeblock lang:ruby%}
	cd ccaloha
	bundle install
{% endcodeblock %}
e. 登入mysql建立資料庫並牽連起來
{% codeblock lang:ruby%}
	mysql -u  root  -p
	CREATE DATABASE ccaloha_development;
	GRANT ALL  PRIVILEGES ON ccaloha_development.* TO 'aloha_admin' @'localhost' IDENTIFIED BY '123456';
	exit
{% endcodeblock %}

f. 用textmate指令 開啓專案
{% codeblock lang:ruby%}
	mate ccaloha 
{% endcodeblock %}


 g. 到config/database.yml改成
{% codeblock lang:ruby%}
	development:
  	adapter: mysql2
  	encoding: utf8
  	reconnect: false
  	database: ccaloha_development
  	pool: 5
  	username: aloha_admin
  	password: "123456"
  	socket: /tmp/mysql.sock
{% endcodeblock %}
	
h. 下指令
{% codeblock lang:ruby%}
	rake db:schema:dump
{% endcodeblock %}

i. 把初始檔案備份到github
	{% codeblock lang:ruby%}
	git add .
	git remote add origin git@github.com:alChaCC/ccaloha.git
	git push origin master
{% endcodeblock %}


[1]: http://help.github.com/mac-set-up-git "說明文件"
[2]: http://git-scm.com	 "git"

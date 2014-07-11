---
layout: post
title: "MacOS-Mysql中文化-latin1 轉 utf8"
date: 2011-10-26 11:14
comments: true
categories: MySQL 
---


之前一直沒有試中文輸入...

結果昨天在試的時候，遇到問題了...無法輸入中文

主要參考了兩篇文章一個是PTT的Ruby版文章1215和這篇[文章][1]
<!--more--> 

a. 下指令
{% codeblock lang:ruby %}
cp /usr/local/mysql/support-files/my-large.cnf /etc/my.cnf
{% endcodeblock %}

b. 編輯/etc/my.cnf檔
{% codeblock lang:ruby %}
vim /etc/my.cnf
{% endcodeblock %}

c. [client]底下加
{% codeblock lang:ruby %}
default-character-set=utf8
{% endcodeblock %}

[mysqld]底下多加
{% codeblock lang:ruby %}
init-connect = 'SET NAMES utf8'
character-set-server = utf8
collation-server = utf8_general_ci
default-character-set = utf8
{% endcodeblock %}

d. 進到mysql
{% codeblock lang:ruby %}
mysql -u root -p
{% endcodeblock %}
 
e. 改每個database
{% codeblock lang:ruby %}
SHOW DATABASES;
ALTER DATABASE DB名稱 charset=utf8;
{% endcodeblock %}

f. 進到這個DB，改每個table
{% codeblock lang:ruby %}
USE DB名稱;
SHOW TABLES;
ALTER TABLE 資料表名稱 charset=utf8;
{% endcodeblock %}

g. 再來改這張資料表的欄位 （這邊和文章不一樣）
{% codeblock lang:ruby %}
DECRIBE 資料表名稱;
＃如果你的欄位type為varchar(xx)
ALTER TABLE 資料表名稱 MODIFY 欄位名稱 VARCHAR(xx) CHARACTER SET utf8;
# 如果你的欄位type為text
ALTER TABLE 資料表名稱 MODIFY 欄位名稱 TEXT CHARACTER SET utf8;
{% endcodeblock %}

h. 重開MYSQL！

i. 在mysql下檢查
{% codeblock lang:ruby %}
mysql> show variables like 'character%';
{% endcodeblock %}

[1]: http://yoonkit.blogspot.com/2006/03/mysql-charset-from-latin1-to-utf8.html "文章"

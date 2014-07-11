---
layout: post
title: "新增留言功能in Octopress"
date: 2011-10-25 12:10
comments: true
categories: [Octopress]
---
a.申請一個帳號in [Discus] [1] 取得short name

b.把nick name 放到_config.yml檔裡面
{% codeblock %}
vim _config.yml
{% endcodeblock %}

c.找到
{% codeblock %}
#disqus Comments
disqus_short_name: 請輸入你剛剛申請的名字
disqus_show_comment_count: true
{% endcodeblock %}

d.下指令
{% codeblock %}
rake generate
{% endcodeblock %}
 


[1]: http://disqus.com/

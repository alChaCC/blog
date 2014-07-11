---
layout: post
title: "Octopress 把關於我加到navibar"
date: 2011-10-25 11:15
comments: true
categories: [Octopress] 
---

首先,你必須在octopress的資料夾位置下
在console(終端機)下指令
{% codeblock  lang:ruby %}
rake new_page[About]
{% endcodeblock %}

然後修改一下你的about me 
<!--more--> 

之後請輸入
{% codeblock  lang:ruby %}
vim source/_includes/custom/navigation.html
{% endcodeblock %}

加入
{% codeblock  %}
<li><a href="{{ root_url }}/About">關於我</a></li>
{% endcodeblock %}
到底下那些咚咚裡面，就像
{% codeblock  lang:ruby %}
<ul class="main-navigation">
  <li><a href="{{ root_url }}/">Blog</a></li>
  <li><a href="{{ root_url }}/blog/archives">Archives</a></li>
  <li><a href="{{ root_url }}/About">關於我</a></li>
</ul>
{% endcodeblock %}

之後在console下指令
{% codeblock  %}
rake generate 
{% endcodeblock %}
即可～～

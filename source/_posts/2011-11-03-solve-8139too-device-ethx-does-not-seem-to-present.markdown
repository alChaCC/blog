---
layout: post
title: "Solve:8139too device ethX does not seem to present"
date: 2011-11-03 23:47
comments: true
categories: Linux 
---

用root權限輸入

{% codeblock  lang:ruby %}
  rmmod 8139too
  modprobe 8139too
  service network restart
{% endcodeblock %}

歐耶～～

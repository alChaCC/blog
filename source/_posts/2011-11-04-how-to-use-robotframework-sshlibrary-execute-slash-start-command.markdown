---
layout: post
title: "How to Use RobotFramework-sshlibrary-Execute/Start Command"
date: 2011-11-04 19:34
comments: true
categories: RobotFramework 
---

甲、主要的差別在於取得輸出

Excute Command 取得輸出的方式： 
{% codeblock lang:ruby %}
${stdout} =  Execute Command  sh /home/${USERNAME}/${ALOHA RBT FILE}/${TEST SCRIPT NAME}
{% endcodeblock %}

Start Command取得輸出的方式：
{% codeblock lang:ruby %}
Start Command  sh /home/${USERNAME}/${ALOHA RBT FILE}/${TEST SCRIPT NAME}
${stdout} =  Read Command Output  
{% endcodeblock %}

<!--more--> 

乙、輸出又可以分成三種：

a. stdout ，這個也是default值 

b. stderr

c. both


丙、輸出要怎麼設定呢？

以Excute Command為例

a. stdout 就跟上面一樣

b. stderr 
{% codeblock lang:ruby %}
${stderr} =  Execute Command  sh /home/${USERNAME}/${ALOHA RBT FILE}/${TEST SCRIPT NAME}  stderr
{% endcodeblock %}

c. both
{% codeblock lang:ruby %}
${stdout}  ${stderr} =  Execute Command  sh /home/${USERNAME}/${ALOHA RBT FILE}/${TEST SCRIPT NAME}  Both
{% endcodeblock %}



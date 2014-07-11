---
layout: post
title: "RF-SSHLibrary 大突破！"
date: 2011-11-23 00:20
comments: true
categories: RobotFramework
---

話說這幾天克服了很多問題！

趕快趁記憶還沒退化筆記筆記

*a. 改變輸出檔案位置和檔名*

這邊我是寫成一個run.sh檔

目的是希望可以簡單的一行指令就可以按造我的設定設定檔名和存放位置
{% codeblock %}
OUTDIR=Aloha/TestCases
COMMON_FLAGS="-d $OUTDIR"
pybot $COMMON_FLAGS -l Aloha_log -r Aloha_report -o Aloha_output $* TestCases
{% endcodeblock %}
<!--more--> 
附上官方文件的說明

-o, --output <file>

 	Sets the path to the generated output file.

-l, --log <file>

 	Sets the path to the generated log file.

-r, --report <file>

 	Sets the path to the generated report file.

*b.把Variables和keywords和Setting分開來放*

total放在__init__.txt檔內
{% codeblock %}
*** Settings ***
Variables       resource/variable/user_information.py
Variables	resource/variable/Aloha_variable.py
Resource 	resource/keyword/main_keyword.txt
Resource        resource/keyword/Aloha_special_keyword.txt
Library         OperatingSystem  WITH NAME  OS
Library         SSHLibrary  ${EMPTY}   ${EMPTY}   ${PROMPT}
{% endcodeblock %}
這樣我每個test case的setting除了要特別加的Test Setup或Suite Setup..等之外，都只要加上
{% codeblock %}
Resource 	__init__.txt
{% endcodeblock %}
就讓你包含所有會用到的東東

*c.正則運算式(Regexp)找我要的文字*

這邊是我卡關的地方

建議可以先到[線上python正則測試工具](http://www.pythonregex.com/) 

參考[官方文件](http://docs.python.org/library/re.html)試試先～

把測試出來的好像可以work的表示式，放到RF-SSH時，請注意是否需要加上\

這邊我要做的事情是找出"句子行首是數字"的字串

在網站上只要用\n(\d+) 就ＯＫ～不過拿到這邊就要改成像下面那樣～ \\n\\d+

{% codeblock %}
*** Test Case ***
To Get Height By Name
    Write  sh getHeightByName.sh ${ALOHA}
    ${output} =  Read Until  getHeightByName is finished
    ${original_txt} =  Should Match Regexp  ${output}  \\n\\d+ 
    ${HEIGHT} =  Should Match Regexp  ${original_txt}  \\d+
    Set Global Variable  ${NOW_USER_HEIGHT}  ${HEIGHT}
{% endcodeblock  %}

*d.設global或suite範圍的參數*

可先參考官方文件-[built-in-library](http://robotframework.googlecode.com/hg/doc/libraries/BuiltIn.html)

這邊可以看到我上面的test case

沒錯！global就是用
{% codeblock %}
Set Global Variable  ${NOW_USER_HEIGHT}  ${HEIGHT}
{% endcodeblock %}

那suite呢？

就是用 Set Suite Variable 摟

那這個參數就是只能使用在自己test suite內的test cases中～

*e.抓時間，並計算*

請參考～抓時間(Get time)和計算(Evaluate)的方法

{% codeblock %}
Get Server Time and Calculate it 
    ${yyyy}	${mm}	${dd} =	Get Time	year,month,day
    ${hour} =	Get Time  hour
    ${count}=  Evaluate  ${hour}+${1}
{% endcodeblock %}

*f. 讓使用案例按照你的流程跑*

非常簡單～

就在你的檔案前面加上數字編號後面再加上兩個_ 也就是__

舉例來說上中下三個檔案那個會先run?

01__last_test_case_02.txt

03__first_test_case.txt

02__last_test_case_01.txt

Answer:

上->下->中



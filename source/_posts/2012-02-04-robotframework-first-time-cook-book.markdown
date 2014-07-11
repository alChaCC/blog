---
layout: post
title: "RobotFramework for dummies"
date: 2012-02-04 22:16
comments: true
categories:  [Linux, RobotFramework] 
---

## 1. 總體注意事項！
a.  每個變化！都要空兩格！ 不然都屬於一個變化

b.	如果keyword的輸入變數要設成有default值的話，要寫在最後面！(後面的範例有)
 
 <!--more--> 
 
## 2. 跑RF的執行檔 -  run.sh檔
指令要跑的檔案為 **my_TestCase.txt**

指定跑的log放在哪裡  還有可以設定輸出的檔名 

以及指定這次跑的test case 是那些 (可以用關鍵字[Tags]來分,用include是代表"要跑"的tag,exclude是代表"不要跑"哪些)

	
	OUTDIR=test_result
	COMMON_FLAGS="-d $OUTDIR"
	pybot $COMMON_FLAGS -l my_log -r my_report -o my_output  --exclude=no_run $* my_TestCase.txt

**使用方式**
	
在放test case的資料夾底下執行！

	

## 3. 善用\_\_init\_\_.txt檔

將所有你會用到的資源！通通寫在這邊～以便管理

而且test case只要include這個檔案即可！其他keyword的txt檔都不需要在寫Setting

	*** Settings ***
	Variables       resource/variable/my_variables.py
	Library         OperatingSystem
	Library         SSHLibrary   ${EMPTY}   ${EMPTY}   ${PROMPT}
	Library         DatabaseLibrary
	Library			StringLibrary
	Resource		resource/variable/constant_var.txt
	Resource 		resource/keyword/keyword_local.txt
	
## 4. Variable 寫法
TXT檔(通常我會取名variable_XXX.txt)的寫法如下：  
	
	*** Variables ***
	${hello}			hahaha
	#如果你要空格的話呢？
	${hello_have_space}	\ hahaha

PY檔(通常我會取名variable_XXX.py)的寫法如下：
	
	HOST =  "xx.xx.xx.xx"
	SQL_SERVER = "xx.xx.xx.xx"
	USERNAME =  "aloha"
	PASSWORD =  "XXXXX"
	PROMPT   =  "#"


## 5. Keyword 寫法 
####a. 如果你的keyword需要帶參數,請服用 [Arguments]  參數名稱  …   … 
####b. 如果你的keyword需要回傳參數,請服用 [Return]  參數名稱  …   … 
####c. 如果你的keyword需要說明,請服用 [Documentation]  你的說明 
####d. 你會發現,keyword 裡頭也可以包其他keyword 

	*** Keywords ***
	Login As Valid User
    	Open Connection To Test Host
    	Login  ${USERNAME}  ${PASSWORD}

	Open Connection To Test Host
    	Open Connection  ${HOST}

	Set Test Case Keyword	[Arguments]	${keyword_name}
    	Set Suite Variable	${test_case_keyword}	${keyword_name} 

	Connect to Database
    [Documentation]  連接到Database Server
    Connect To Database  MySQLdb  要用的資料庫名稱  登入帳號  登入密碼  ${SQL_SERVER}  埠口 
		
	Get ID from Database by element Name and table name
    	[Arguments]  ${element_Name}  ${table_name}  ${limit script}=null
    	Connect to Database
    	${queryResult_no_script} =  Run Keyword If  "${limit script}" == "null"  Query  select ${table_name}_id from ${table_name} where name='${element_Name}'
    	${queryResult_have_script} =  Run Keyword Unless  "${limit script}" == "null"  Query  select ${table_name}_id from ${table_name} where name='${element_Name}' ${limit script}
    	${queryResults} =  Set Variable If  "${limit script}" == "null"   ${queryResult_no_script}   ${queryResult_have_script} 
    	Log  ${queryResults[0][0]}
    	Disconnect From Database
    	[Return]  ${queryResults[0][0]} 

	To interact to HOST 
		[Arguments]  ${USERNAME}
    	Login As Valid User 
    	Write  cd /tmp
		Write  ls 
    	Write  rm -f XXX
    	Witre  sh what_is_your_name.sh
    	Read Until  Input username :
    	Write  ${USERNAME}
    	SSHLibrary.Get File  /tmp/你的檔案位置  ${CURDIR}/你要放的位置  

	To Get Time now and Using Operating_System_Library Modify file
		[Arguments]   ${txt_name}  ${cur_day}  ${next_hour}  ${input_user_id}  
    	${yyyy}	${mm}	${dd} =	Get Time  year,month,day
		${cur_day} =  Run Keyword If  '${cur_day}' == 'today'  Get Time  day
		${cur_hour} =  Get Time  hour
		${tmp_hour} =  Convert To Integer  ${cur_hour}
		${next_hour}=  Run Keyword If  '${next_hour}' == 'next_hour' Evaluate  ${tmp_hour}+${1}
		${tmp_day}=   Convert To Integer  ${cur_day}
		${next_day}=  Evaluate  ${tmp_day}+${1} 
    	Run  sed -i \'s/Time = /Time = ${tmp_day} ${next_day} ${input_user_id}/g\' ${CURDIR}/${txt_name}
    	
	Using Selenium_Library Get Key
    	[Setup]  Start Selenium Server
    	Open Browser  ${login address}
    	Maximize Browser Window
    	call selenium api  click  //div[contains(@class,'XXXX')][text()='Show Key']
        ${Key}=  Get Text  //div[contains(@id,'Key')]
    	Close Browser
    	[Teardown]  Stop Selenium Server

	Using String_Library replace escape char
		[Arguments]  ${KEY}
    	${after_reg}=  Replace String Using Regexp  ${KEY}  \/  \\/
    	Log  ${after_reg}



###常用的keyword

1. Built-in Library
	
		Run Keyword If  /  Run Keyword Unless
		Set Variable If	
		Set Suite Variable
		Evaluate
		Get Time
		Convert To Integer

2. SSH Library
		
		Login
		Open Connection
		Write 
		Read Until
		Get File

3. Selenium Library

		Start Selenium Server  /  Stop Selenium Server
		Open Browser  /  Close Browser
		call selenium api 

4. String Library
		
		Replace String Using Regexp

5. Operating_System_Library

		Run 
		
##6. TestCase寫法

**盡量把test case 寫成可讀性高的描述！這也意味著可能你的keyword會變多～XD** 

	
	Combine All Keywords in One Test Case 
		[Tags]  critical_test
		[Documentation]  使用DatabaseLibrary找尋我的username在user這個table，然後搜尋條件之一就是is_appear='1'
		${MyUserNameID} =  Get ID from Database by element Name and table name  ${username}  user  and is_appear='1'
		[Documentation]  取得時間，使用OS Library調整我的test.txt檔  
		To Get Time now and Using Operating_System_Library Modify file  test.txt  today  next_hour  ${MyUserNameID}
		[Documentation]  用SSH Library 登入到Host 然後輸入文字my name is aloha
		To interact to HOST  my name is aloha
		[Documentation]  使用Selenium Library 取得網站的key
		Using Selenium_Library Get Key
		[Documentation]  使用String Library找出字串jadfksal;fed;lfsjfljsa\fdsa的跳脫字元
		Using String_Library replace escape char  jadfksal;fed;lfsjfljsa\fdsa



##最後的資料夾結構規劃

	My_test_case_folder
		-> my_TestCase.txt
		-> __init__.txt
		-> resource
			->keyword
				->keyword_local.txt
			->variable
				->variable_local.py
				->variable_constant.txt
		->test_result
				



後續會一直加....


	
		 

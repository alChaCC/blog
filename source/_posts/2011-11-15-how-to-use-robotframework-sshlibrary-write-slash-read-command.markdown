---
layout: post
title: "How to Use RobotFramework-SSHLibrary-Write/Read Command"
date: 2011-11-15 19:37
comments: true
categories: RobotFramework 
---

之前，在Start和Excute command 那邊～發現一個問題

那就是他不會去記錄你現在到底做了甚麼事情

例如我cd 到一個資料夾底下

然後在那個資料夾底下執行一個.sh檔案

那兩個指令的工作，比較像“單純做指令” 做完指令就登出的感覺 所以兩個指令是無法連續的

他不是屬於互動的！

<!--more--> 
請看其官方文件有這樣的敘述.....

================================================================================

Currently, there are two modes of operation:

When keyword **Execute Command** or **Start Command** is used to execute something, a new channel is opened over the SSH connection. In practice it means that no session information is stored.

Keywords **Write** and **Read XXX** operate in an interactive shell, which means that changes to state are visible to next keywords. Note that in interactive mode, a prompt must be set before using any of the Write-keywords. Prompt can be set either on library importing or when a new connection is opened using Open Connection, or using keyword **Set Prompt**.

================================================================================

原來如果我們需要有所互動的話～也就是說你可以cd進去 然後就在裡頭作指令

就是需要用WRITE和READ 這兩個指令

那就開始八～我的小小心得

在用Write之前，一定要有Set Prompt的動作

所以我在一開始的Suite Setup是設定

	Suite Setup     Login and Move Test Files

其中  Login and Move Test Files 這個keyword包含了Cd To File Path這個keyword又這個keyword是這樣定義的

	Cd To File Path
    		Write   cd /home/${USERNAME}
    		Set Prompt  #
		   上面是假設你用root登入，若是用一般使用者可以使用
		   Set Prompt  $

那甚麼是prompt勒？

google查到的就是提示基本上就是你在terminal key指令的前面的那些東東,

我是設定為#或$是因為我想要抓到完整的前面那串

[root@localhost root]#

[aloha@localhost aloha]$

#Write系列#

=================================**Write**=================================

我覺得最簡單的描述是：他就是把你的key的東西 寫到你要測試的ssh server上

他都會自動幫你加上\n 這就好像輸入enter的感覺！

所以當你寫了

        ${output} =  Write  ./${INTERACTIVE TEST SCRIPT NAME}

在server端看到的就是
        
        ./test_interactive.sh 然後按enter

例如：

        ${output} =  Write  Juha

它就等於輸入Juha然後按下enter


=======================**Write Until Expected Output**====================

一直寫一直寫，直到停止條件的發生


        Write Until Expected Output  放你要write的東東  放停止條件  timeout時間(後>面要加s)  重試的時間間隔（後面要加s）

這邊要注意歐～**text is written without appending newline.**

也就是說和Write Bare一樣！所以你在後面沒有加\n會有錯誤

舉例：

       
        Write Until Expected Output  ./counter.sh\n  3  15 seconds  0.5 seconds
        [Teardown]  Remove Counter and Read All Data

這邊他就真的會開始數上去～因為你有下\n也就是enter的意思

和下面不同的地方請看

        Write Until Expected Output  ./counter.sh  3  15 seconds  0.5 seconds
        [Teardown]  Remove Counter and Read All Data

這邊他就不會數上去，對程式來說，就是下了./counter.sh 然後沒有按enter!


=================================**Write Bare**=================================

Write Bare  不像write他後面會自己加\n 這個必須要自己加\n


#Read系列#

=================================**Read**=================================

這個指令會回覆目前的output，他的log level是INFO

用法：

	Write  rm ${COUNTER NAME}
    	Read

我得到的結果是:

        INFO 	Writing 'rm counter.txt\n'
	INFO    rm counter.txt
	INFO 	[test@localhost test]#

=========================**Read Command Output**==========================

這邊我沒有用不過，我想看官方文件，這個應該是必須跟Start Command一起用

用法:
	Start Command	你要執行的指令			
	${out}=	Read Command Output			
	${err}=	Read Command Output	stderr		#stderr is returned	
	${out}	${err}=	Read Command Output	both	#stdout and stderr are returned


==============================**Read Until**==============================

他會等到“你輸入的關鍵字”出現，他才會停止讀輸出，或是一直等不到關鍵字然後timeout

他會跳出If no match is found, the keyword fails.

用法：

        ${output} =  Write  ./${INTERACTIVE TEST SCRIPT NAME}
	${output} =  Read Until  Give your name?

結果：  

	INFO  	Writring './test_interactive.sh\n'
	INFO  	${output} = [root@localhost root]#./test_interactive.sh   
	INFO	Give your name ?
	INFO    ${output} =  Give your name ?


===========================**Read Until Prompt**===========================

和之前那個一樣的意思 不過他是讀到我們設定的Prompt

這邊我感覺他的用法可以是這樣的，當你要run一個的指令，他會跑很多echo給你

你想要知道這些執行結束前的資訊，就可以用這個指令

用法：
	${output} =  Read Until Prompt

===========================**Read Until Regexp**===========================

讀到符合你設定的正則運算時停止

	${output} =  Read Until Regexp  Give.*\\?
		     #Read Until Regexp  正則運算運算式


============================**Set Timeout**================================  

	Set Timeout  秒數

顧名思義摟，設定等待時間

用法：

	Write  Foo Bar And Some Other
    	Set Timeout  1
    	${status}  ${error} =  Run Keyword And Ignore Error  Read Until  This is not found
    	Should Be Equal  ${error}  No match found for 'This is not found' in 1 second







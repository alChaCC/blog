---
layout: post
title: "HOWTO:AWS EC2 + AWS SES 迸出 Mail Server"
date: 2011-12-30 10:07
comments: true
categories: [AWS , Linux]
---

主要參考兩篇文章

 
1. [Simple Email Service](http://www.orderingdisorder.com/was/ses/) 
> 注意別忘了下載，上面文章中的PHP檔

2. [Simple PHP mail script](http://www.buildwebsite4u.com/advanced/php.shtml)
> 這邊我有改一個小地方

<!--more--> 
我的步驟如下

>在這之前 我已經申請好了EC2以及取得Access Key和Secret Key

1. 申請SES服務

2. 點選verify a New Sender

3. 到你剛剛輸入的信箱 認證一下！

3. 登入到你的EC2，然後到htdocs底下 (因為我是用SUSE)

		cd /src/www/htdocs/ 

4. 開始先寫個index.html   -> vim index.html

		<!DOCTYPE html>
		<html>
		<head><title>Send Mail to YOURSELF</title></head>
		<body>
		<form action="mail.php" method="POST">
		<b>Mail</b><br>
		<input type="text" name="email" size=40>
		<p><b>Subject</b><br>
		<input type="text" name="subject" size=40>
		<p><b>Message</b><br>
		<textarea cols=40 rows=10 name="message"></textarea>
		<p><input type="submit" value=" Send ">
		</form>
		</body>
		</html>

5. 在寫個mail.php  -> vim mail.php
		
		<html>
		<head><title>PHP Mail Sender Test</title></head>
		<body>
		<?php
		require_once('ses.php');
		$ses = new SimpleEmailService('你在AWS使用的Access Key', '你在AWS使用的Secret Key');

		$m = new SimpleEmailServiceMessage();

		/* All form fields are automatically passed to the PHP script through the array $HTTP_POST_VARS. */
		
		$email = $_REQUEST['email'];
		$subject = $_REQUEST['subject'];
		$message = $_REQUEST['message'];

		/* PHP form validation: the script checks that the Email field contains a valid email address and the Subject field isn't empty. preg_match performs a regular expression match. It's a very powerful PHP function to validate form fields and other strings - see PHP manual for details. */
		
		if (!preg_match("/\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/", $email)) {
  		echo "<h4>Invalid email address</h4>";
  		echo "<a href='javascript:history.back(1);'>Back</a>";}
		elseif ($subject == "") {
  		echo "<h4>No subject</h4>";
  		echo "<a href='javascript:history.back(1);'>Back</a>";}
		/* Sends the mail and outputs the "Thank you" string if the mail is successfully sent, or the error string otherwise. */
		
		$m->addTo($email);
		$m->setFrom('helpitree@gmail.com');
		$m->setSubject($subject);
		$m->setMessageFromString($message);
		print_r($ses->sendEmail($m));

		?>
		</body>
		</html>


6. 在把剛剛下載下來的PHP檔放上去
		
	你可以用scp 或是 直接複製貼上 …等

7. 小功告成！
		
		
ps. 因為我有出現curl.init() error的問題

我發現可能是因為我沒有安裝 php5-curl 所以中間我有灌了點東西

	zypper ref
	zypper install php5-crul  

灌完之後就把apache server重開
	
	/etc/init.d/apache2 restart



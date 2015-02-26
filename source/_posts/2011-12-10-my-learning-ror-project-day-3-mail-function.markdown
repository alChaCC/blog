---
layout: post
title: "我的RoR學習專案-Day 3-註冊並加上mail註冊信的功能"
date: 2011-12-10 15:46
comments: true
categories: ["Ruby on Rails"]
---

##註冊並加上mail註冊信的功能
開始上工～別忘了上工第一件事 開
	git flow feature start user_register_and_manager
這句話就代表我現在在feature/user_register_and_manager的版本開發中

開工啦～

<!--more--> 
設定好devise gem～接著就是把一些帳號認證的東西放進去～

現在在需要登入的controller加上登入的before_filter

因為我要的功能是使用者必須能夠註冊/登入，登入後才可以發表 Post，不然只能瀏覽。

另外，只有自己的 Post 才能進行修改與刪除。所以我在想應該是在new和編輯時要驗證！


首先，我們要讓使用者在發表文章時或是編輯文章時，能夠先證明他有登入

我們必須在post 這個controller內判斷使用者有無登入～～那devise提供的方法就叫做authenticate_user! <-注意那個驚歎號

所以我就在/app/controllers/posts_controller那邊加入了這句話
 
	before_filter :authenticate_user! , :only => {:new,:edit}

結果…科科，照理說不是我在按發表新文章～要先驗證我有沒有登入！

阿怎麼沒有....囧.....

結果發現...應該要這樣寫滴
 
	before_filter :authenticate_user! , :only => [:new,:edit] 
	        別懷疑～要用[]才對
結果ＯＫ了～我發表文章還有要修改文章時，必須先登入！

另外因為我的網站是有其他分類的，所以登入後，不應該是回到root的位址（這是devise的設定）

所以我在route.rb改了點東西！
	
	namespace :user do
     	 root :to => "forums#index"
  	end

結果...不work

最後，我參考[這篇](https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-in)
改成這樣，在controllers/application_controller.rb加上

	def after_sign_in_path_for(resource)
    	stored_location_for(resource) || forums_path
	end


最後我無聊，加上必須收到認證信，有認證的人～這個帳號才可以啓動

不過這要怎麼寄信阿......

但好運的我，莫名其妙寄信成功！

我做的事情是在config/environment.rb加了 然後我把他server重開rails server～就ＯＫ了～

	ActionMailer::Base.delivery_method = :smtp
	ActionMailer::Base.smtp_settings = {
    	:address => "smtp.gmail.com",
    	:port => "587",
    	:domain => "gmail.com",
    	:authentication => "plain",
    	:user_name => "你的gmail帳號",
    	:password => "你的密碼",
    	:enable_starttls_auto => true
 	}

在找上寄信的方法時我找到這篇，我把他記下來，因為我發現當我啓動帳號成功時，我都會收到恭喜信，How can I send a welcome e-mail when a user registers to my service? 這篇純學習，看看就好啦～
把下面的檔案～放在models/user.rb那邊
         # devise confirm! method overriden
        def confirm!
           confirm_message
        super
        end
        private
          def confirm_message
            UserMailer.confirm(self).deliver
          end 
老實說～我不知道他再幹麻～可能是這樣的～當帳號認證成功～透過我自己的mail程式寄信～大概是這個意思～ 不過那個self可能要改成某個email變數~
因為我看到的log檔是長這樣的
	Sent mail to email (2409ms)
	Date: Sat, 10 Sep 2011 23:29:29 +0800
	From: aloha.innovate@gmail.com
	To: email
	Message-ID: <4e6b825999a88_34a81b1bef44864@Alohas-	MBP.local.mail>
	Subject: Registered
	Mime-Version: 1.0
	Content-Type: text/plain;
 	charset=UTF-8
	Content-Transfer-Encoding: 7bit

	UserMailer#confirm

	Hi, find me in app/views/app/views/user_mailer/confirm.text.erb

至於～寄信程式～我是參考這篇http://ihower.tw/rails3/actionmailer.html

附上我的程式在app/mailer/user_mailer

	class UserMailer < ActionMailer::Base
  		default :from => "aloha.innovate@gmail.com"

  		def confirm(email)
    		@greeting = "Hi"
    	mail (:to => "email", :subject =>"Registered") 
  		end
	end


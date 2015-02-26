---
layout: post
title: "Using Google Analytics for Email Click Tracking And Open Rate Tracking in Ruby on Rails"
date: 2015-02-27 23:34:39 +0800
comments: true
categories: ["Ruby on Rails", "Google Analytics"]
keywords: "Google Analytics, Ruby on Rails, email tracking,Email追蹤, 點擊率, 開信率,中文"
description: "Using Google Analytics for Email Click Tracking And Open Rate Tracking in Ruby on Rails"
---

## Requirement 

1. 每個連結的點擊數

2. 開信率


## Google Analytics

這是一個電子報，基本上屬於一種廣告！

那GA怎麼那麼厲害知道誰點了什麼？ 

該不會Google 大神，連Email也滲透？！

ps. 我猜他應該也差不多都知道我們在Email上的一舉一動，只要你用Gmail...

### 那GA要怎麼紀錄？

> 基本上就是將**連結網址**帶上一些"參數"，當使用者點了這個連結之後，就你就會被帶到那個**連結網址**，這時候那個網站一定有埋GA的javascript
> ，這就是他的Key~ GA透過js爬到你的網址，當他發現你有帶某些參數，他就知道你是從哪裡來的！

<!-- more -->

我剛剛提到了好幾次**參數**

沒錯！這就是關鍵！

讓我們來看一下 有哪些參數

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/utm%E8%A8%AD%E8%A8%88.png">


GA在有文件說明[網址要如何使用](https://support.google.com/analytics/answer/1033863)

而且，GA還很貼心的幫大家準備了 [網址產生器](https://support.google.com/analytics/answer/1033867?hl=zh-Hant)


來看一下，實際上會產生什麼樣的連結：

假設我們追蹤
	
	透過Email點擊，來到首頁的人
	
Url 原本是長這樣

	www.urcosme.com

ps. urcosme.com小弟目前待的公司 XDDDDD廣告一下！ 

經過~~我的~~GA的巧手，它會長這樣


	www.urcosme.com/?utm_source=%E9%9B%BB%E5%AD%90%E5%A0%B1&utm_medium=%E9%9B%BB%E5%AD%90%E9%83%B5%E4%BB%B6&utm_content=%E6%B8%AC%E8%A9%A6%E6%B8%AC%E8%A9%A6&utm_campaign=%E6%88%91%E5%A5%BD%E5%B8%A5
	
案....這是....!？

讓我幫你翻譯一下

	www.urcosme.com/?utm_source=電子報&utm_medium=電子郵件&utm_content=測試測試&utm_campaign=我好帥

當我把連結改成這樣後，基本上使用者也是會點到你的首頁，但是對於GA而言，他就知道你是從電子郵件過來


但! 身為一個有責任感又假掰的IT，

我們當然希望讓系統自動幫行銷的同仁帶入這些參數，讓正妹同事覺得沒有你不行～

## 1. Rails 要如何實作“點擊追蹤”

其實很簡單，我們要寫一個 小小小爬蟲，把內容爬過一次

把有 \<a> 的找出來，然後把資訊加進去就好了！


那...爬蟲要怎麼寫？


各位，既然是來到 Rails ，Rails什麼不多，鐵路最多，歐不～ 是輪子最多！

跟大家介紹個 Gem : **[Nokogiri](http://www.nokogiri.org/)** 
 
 
我們就直接用實作，來說明他可以幹麻


直接來看的程式碼：

這是我寫在 **app/models/edm.rb** 的code

這個model資訊是這樣

	# == Schema Information
	#
	# Table name: edms
	#
	#  id                 :integer          not null, primary key
	#  name               :string
	#  send_at            :datetime
	#  title              :string(255)
	#  state              :string(255)
	#  content            :text
	#  created_at         :datetime
	#  updated_at         :datetime
	#


	def parse_link_in_email(user_id)
	    # 讀進email html
	    html =  Nokogiri::HTML(self.content)
	    # 找出所有 a 
	    a_nodes = html.css('a')
	    a_nodes.each do |a|
	      # 抓出href 並且加上GA 追蹤
	      tracking_a = a['href'] +  "?utm_source=#{self.name}-#{CGI.escape(a['href'])}" + 
	                                "&utm_medium=email" +
	                                "&utm_content=#{self.id}-#{user_id}" + 
	                                "&utm_campaign=#{self.title}"
	      a['href'] = tracking_a
	    end
	    return html.to_html
	 end
	
幾個重點：

1. 使用**Nokogiri::HTML(self.content)**  => 讀HTML進來
2. **html.css('a')** => 抓出所有\<a>
3. **a['href']**     => 抓出這個\<a>，裡頭的屬性href
4. **html.to_html**  => 轉回HTML


Done ! 


所以當使用者點擊信件的link時，GA就會看到.....

**攬客 >> 廣告活動 >> 所有廣告活動**

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/GA_email_click_tracking.png" alt="GA email click tracking demo">



## 2. Rails 要如何實作“開信率”


開信率我是參考這篇[Blog](http://dyn.com/blog/tracking-email-opens-via-google-analytics/)來實作

簡單來說，我們需要埋一個image tag，然而那個tag 

會帶上一些**參數**，讓GA知道這幹嘛的！

為什麼要使用這種標籤的方式紀錄呢？

假設使用者打開信之後，並且點了一個連結，

因為這個點了連結的動作，我們知道他一定有開信，歐噎～ 做完了～ 

But...........

那如果他只有打開信，沒有點擊勒？ 如果他打開信，點了N個連結，那開信不就也被多紀錄了很多次？(ps.點擊紀錄是每點一次就紀錄一次)

> 所以我們必須透過從 Google Analytics **"GET"** 一個標記(就是圖片啦)，當我們跟GA要圖的時候，可以告訴GA一些**參數**，嘿嘿，這樣就有辦法紀錄了！



各位，又看到**參數**兩個字

那又有哪些可以用勒？ (這邊我只列我目前有在用的，詳細可以參考[GA collections parameters](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#events))


| 參數                                                                                 | 說明                                                                   | 舉例                                                                                 
|----------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| tid | 要放GA的ID| UA-1234567-8 |
| uid |Unique的ID(因為我們要寄信給User我是使用該User的ID)| 1 |
| t   | 告訴GA這是個什麼類型的紀錄(基本上我查到都使用event) | event |
| ec  | 告訴GA這個Event的Category | email-測試 |
| ea  | 告訴GA這個Event的Action | Open |
| el  | 告訴GA這個Event的Label | user_id-1 |
| cs  | 廣告活動的來源 | Email標題 |
| cm  | 廣告活動的媒介 | edm |
| cn  | 廣告活動名稱   | 電子報第0期 | 


那我們就不看sample，直接來看實作code

	def parse_link_in_email(user_id)
	  	
	  	... 
	  	
	    body = html.at_css("body")
	    img_node = Nokogiri::XML::Node.new("img",body)
	    img_node['src'] = "https://www.google-analytics.com/collect?v=1" + 
	                      "&tid=#{Settings.google_analytics_key}" + 
	                      "&uid=#{user_id}"+
	                      "&t=event" +
	                      "&ec=email-#{self.name}-#{self.title}" + 
	                      "&ea=open" + 
	                      "&el=user_id-#{user_id}" + 
	                      "&cs=#{self.name}" + 
	                      "&cm=email" + 
	                      "&cn=#{self.title}"
	    body << img_node
	    
	    ...
	end

幾個重點：

1. 使用**Nokogiri::XML::Node.new("img",body)**  => 新增一個\<img>標籤
2. **img_node['src']**     => 設定這個\<img>，裡頭的屬性src
3. **body << img_node**  => 將code埋到body裡面


那在GA你會看到什麼勒？

<img src="https://dl.dropboxusercontent.com/u/22307926/GA_email_open_tracking.png" alt="GA email open rate tracking demo">



## 3. Rails Mailer、its View and model 

 剩下我沒提到的部份，不過這些就是基本寄信的功能，我就不贅述了
 
 **app/models/edm.rb**
 
 	has_many :edm_user_ships  # 假設你有要寄信的清單
 	has_many :users, :through => :edm_user_ships
 	def send_mail
    	self.users.each do |user|
       		EdmMailer.delay.send_edm(self, user.email, user.id)
    	end
  	end

**app/mailers/edm_mailer.rb**

	class EdmMailer < ActionMailer::Base
	  default from: "service@urcosme.com"
	  
	  def send_edm(e_notify, email, user_id = nil)
	    @e_notify = e_notify
	    @user_id = user_id
		    
	    mail to: email, subject: e_notify.title
	  end
	end


**app/views/edm_mailer/send_edm.html.slim**

	= raw @e_notify.parse_link_in_email(@user_id)


## Done

---
layout: post
title: "我的RoR學習專案-Day 5 使用wep-app-theme功能"
date: 2011-12-11 21:11
comments: true
categories: Ruby_on_Rails
---

突然覺得我的網站，好醜....	
現在我想要開發我的view！！！
首先我要先開新的branch

	git flow feature start add_web_app_theme_feature

OK 開始try and error吧～

<!--more--> 

先在Gemfile放
	
	gem 'web-app-theme', '>= 0.6.2'

然後在console下
	
	bundle install

安裝好之後要怎麼用.....囧，讓我看看github的說明吧～

先試看看從網頁上看到他說

>If you need a layout for login and signup pages, you can use the --type option with sign as value. Ìf not specified, the default value is administration

	rails g web_app_theme:theme sign --layout-type=sign

然後他就幫我產生了這些file

	  create  app/views/layouts/sign.html.erb
      create  public/stylesheets/web-app-theme/base.css
      create  public/stylesheets/web-app-theme/override.css
      create  public/stylesheets/web-app-theme/themes/default
      create  public/stylesheets/web-app-theme/themes/default/fonts/museo700-regular-webfont.eot
      create  public/stylesheets/web-app-theme/themes/default/fonts/museo700-regular-webfont.svg
      create  public/stylesheets/web-app-theme/themes/default/fonts/museo700-regular-webfont.ttf
      create  public/stylesheets/web-app-theme/themes/default/fonts/museo700-regular-webfont.woff
      create  public/stylesheets/web-app-theme/themes/default/fonts/museosans_500-webfont.eot
      create  public/stylesheets/web-app-theme/themes/default/fonts/museosans_500-webfont.svg
      create  public/stylesheets/web-app-theme/themes/default/fonts/museosans_500-webfont.ttf
      create  public/stylesheets/web-app-theme/themes/default/fonts/museosans_500-webfont.woff
      create  public/stylesheets/web-app-theme/themes/default/fonts/museosans_500_italic-webfont.eot
      create  public/stylesheets/web-app-theme/themes/default/fonts/museosans_500_italic-webfont.svg
      create  public/stylesheets/web-app-theme/themes/default/fonts/museosans_500_italic-webfont.ttf
      create  public/stylesheets/web-app-theme/themes/default/fonts/museosans_500_italic-webfont.woff
      create  public/stylesheets/web-app-theme/themes/default/images/arrow.png
      create  public/stylesheets/web-app-theme/themes/default/images/bgd.jpg
      create  public/stylesheets/web-app-theme/themes/default/images/boxbar-background.png
      create  public/stylesheets/web-app-theme/themes/default/images/button-background-active.png
      create  public/stylesheets/web-app-theme/themes/default/images/button-background.png
      create  public/stylesheets/web-app-theme/themes/default/images/messages/error.png
      create  public/stylesheets/web-app-theme/themes/default/images/messages/notice.png
      create  public/stylesheets/web-app-theme/themes/default/images/messages/warning.png
      create  public/stylesheets/web-app-theme/themes/default/style.css
      create  public/images/web-app-theme
      create  public/images/web-app-theme/gradient.jpg

之後我看到這句話

>Themed Generator
Start creating your controllers manually or with a scaffold, and then use the themed generator to overwrite the previously generated views.

簡單來說他會產生theme去取代掉我們之前所建的那些view!

但是我怎麼可能讓他清掉我辛辛苦苦建的theme!!!
於是乎～我就先下

	rails g web_app_theme:themed posts

他就會問要不要一一換掉

但是我就是先按d，先看看他要刪掉哪些和增加哪些

我就把cosole畫面放在左邊，然後手刻到我自己的view

幹～可是奇怪....怎麼好像都沒甚麼改變....到底是哪裡有問題?

之後我發現在layout/application.html.erb
	
	<%= stylesheet_link_tag  %>

應該要有他們他們裡頭預設的版面！！！！
於是我下了這個指令

	rails g web_app_theme:theme

耶～終於出現不一樣的版面了！

ＯＫ～～那我繼續完成其他view的整合吧～

我想我們還是得搞懂css的東西～～～

換到forum，這邊比較單純

	rails g web_app_theme:themed forums

只有一個要臨摹（因為我發現...其實不需要show這個view)


之後到admin裡頭的post和forum 這邊我希望可以改變外觀～讓管理者知道他現在是在管理頁面! 參考

>If the controller has a name different to the model used, specify the controller path in the first parameter and the model name in the second one:

所以要有不同的頁面必須加指令--theme=”XXX”

	rails g web_app_theme:themed admin/posts post --theme="drastic-dark"

還有

	rails g web_app_theme:themed admin/forums forum --theme="drastic-dark"
	rails g web_app_theme:theme admin --theme="drastic-dark"
	rails g web_app_theme:theme welcomes
	rails g web_app_theme:theme aboutmes

我就不一一把我的view放上來了～

請看我的[github-add web app theme feature](https://github.com/alChaCC/ccaloha/tree/feature/add_web_app_theme_feature)

其實很多用法我實在不知道為甚麼，改天要來研究一下css

還有一個很怪的東西是這個

	<%= link_to "#{t("web-app-theme.list", :default => "論壇首頁")}", forums_path  %>

誰可以告訴我那個
	#{t("web-app-theme.list", :default => "論壇首頁")}是殺小

最後 完成merge 回develop八

	git add .
	git commit -a 
	git push origin feature/add_web_app_theme_feature
	git flow feature finish  add_web_app_theme_feature

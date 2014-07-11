---
layout: post
title: "Learning on RoR Tutorial - CH1 - Basic operation"
date: 2012-05-29 10:41
comments: true
categories: Ruby_on_Rails  
---

這個也是我學習ror的source之一！

英文內容在[Ruby on Rails Tutorial Learn Rails by Example](http://ruby.railstutorial.org/chapters/beginning?version=3.2#top)

> Thanks For Michael Hartl

歡迎大家購買原版支持一下

首先第一章主要就是講基本操作，大概會用到哪些基本指令

**使用不同的gemset**

	rvm use 1.9.3@rails3tutorial2ndEd --create --default
 
<!--more-->

因為我們都是在網路上找資料，所以不需要一些ri或rdoc檔案

所以我們要先建立一個檔案

	$vim ~/.gemrc
	
並加上
	
	gem: --no-ri --no-rdoc
	

因為我現在使用不同的gemset了！

所以現在並沒有rails 所以必須在安裝一次

	$ gem install rails -v 3.2.2
	
建立第一個專案

	$ mkdir rails_projects
	$ cd rails_projects
	$ rails new first_app

使用mate打開新專案

	mate first_app

把Gemfile改成乾淨一點,並把一些版本指定的清楚一點

	source 'https://rubygems.org'
	gem 'rails', '3.2.2'
	group :development do 
 		gem 'sqlite3' , '1.3.5'
	end

	# Gems used only for assets and not required
	# in production environments by default.
	group :assets do
  		gem 'sass-rails',   '3.2.4'
  		gem 'coffee-rails', '3.2.2'
  		gem 'uglifier', '1.2.3'
	end
	gem 'jquery-rails' , '2.0.0'


別忘了每當你改完Gemfile

	$ cd /Users/aloha/rails_projects/first_app
	$ bundle install


因為我已經有設定過git了如果第一次沒用過的話，請直接參考[First-time system setup](http://ruby.railstutorial.org/chapters/beginning?version=3.2#sec:1.3.1.1)

設定編輯git檔案的指令為mate

	$git config --global core.editor "mate -w"

在要做git管理的程式碼資料夾，作初始化的動作！

	$git init
	
編輯不要放在git管理追蹤的東西

	$vim .gitignore 
	
加入所有要管理的東西

	$git add .

如果你希望你保存你這次的變動，使用commit這個指令

	$git commit -m "你想要說的話"
	
PS.如果你不小心，動到什麼檔案！ 但是你還沒有做commit的動作！

你可以這樣回復(注意歐！他會回到你上一次commit的版本歐！)

	$git checkout -f 
	
因為我這個code只為單純練習的專案！我就不把它放到github了！

如果要放的話，請參考[GitHub](http://ruby.railstutorial.org/chapters/beginning?version=3.2#sec:github)

現在我想要開一個branch 來當做修改Readme的分支

	$git checkout -b modify-README

來看一下現在在哪一個branch

	$git branch

OK~先來改README，把它改成.md檔(Mou可以開的格式)

PS.我有製作一個script指令叫做Mou，其實很簡單…

	$vim Mou

加上

	#!/bin/sh
	~/你的Mou安裝路徑/Mou.app/Contents/MacOS/Mou $1 &

之後用terminal指定

	$chmod +x Mou
	
接著繼續八～

	$git mv README.rdoc README.md
	$Mou README.md

改完之後！ 就可以來commit了！ 注意歐！ 對git來說，已經有了一個新的檔案(README.md)，所以我們要使用-a來加入新的檔案

	$ git commit -a -m "改了README檔案"
	
接下來，我們來切換到master然後把剛剛的改版**merge**回來吧！

	$  git checkout master
	
	$  git merge modify-README
	

之後我們把這個branch delete掉

	$ git branch -d modify-README
	
注意歐！如果你的branch還沒有merge回來！基本上他會不讓你用-d刪除！

如果真的要硬刪除 要用 -D


現在要來學如何Deploy ！ 如果要把它放到Heroku上！請先安裝！

	$gem install heroku
	
把你的public key交給Heroku

	$heroku keys:add
	#我是選擇github的key

新增新的應用程式到Heroku上！

	 $heroku create --stack cedar

第一步:把你的專案先push 到heroku上

	$git push heroku master
	
之後，我們就可以在網路上看到我們的程式了！！！酷歐！！

	$heroku open 


改一下你的網址名稱

	$heroku rename firstprojectaloha
	
耶！！！我看到我的網站了
	
	http://firstprojectaloha.herokuapp.com

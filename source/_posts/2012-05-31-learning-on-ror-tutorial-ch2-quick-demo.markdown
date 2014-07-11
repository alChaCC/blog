---
layout: post
title: "Learning on RoR Tutorial - CH2 - Quick Demo"
date: 2012-05-31 15:18
comments: true
categories: 
---
新增專案二demo_app

	$ cd ~/rails_projects
	$ rails new demo_app
	$ mate demo_app

<!--more-->
	
編輯Gemfile

	source 'https://rubygems.org'

	gem 'rails', '3.2.2'

	group :development do
  		gem 'sqlite3', '1.3.5'
	end

	# Gems used only for assets and not required
	# in production environments by default.
	group :assets do
  		gem 'sass-rails',   '3.2.4'
  		gem 'coffee-rails', '3.2.2'
  		gem 'uglifier', '1.2.3'
	end

	gem 'jquery-rails', '2.0.0'

	group :production do
  		gem 'pg', '0.12.2'
	end
	
這次新增了一個gem 叫做pg 因為這是因為在Heroku要變成production 才需要的！

但是在這次bundle install時，先不需要安裝production的部份

	$bundle install --without production

一樣，先做版本控制

	$ git init
	$ git add .
	$ git commit -m "Initial commit"
	
當你你也可以放到github上，不過記得在申請一個專案

	$git remote add origin git@github.com:<username>/demo_app.git
	$git push origin master

OK! 開始來玩玩，因為希望可以建立使用者發佈消息的功能！先來建立user的部份

	$rails generate scaffold User name:string email:string
	
因為我們是用scaffold建置的！ 所以他已經幫我們在controller/model/helper/model/view建好了和user相關的東東了！

這時候我們要來做資料庫的遷移！ 將你在db/migrate底下的[timestamp]_create_uusers.rb 的設定，寫到資料庫裡面！

	$bundle exec rake db:migrate
	#為了確保指令會使用Rake的版本對應到我們的Gemfile所以我們使用bundle exec 這個指令

剛剛建出來的東西就不特別說明了～我慢慢回復了XD	

再來建訊息的部分，因為每個訊息都會depend on 一個user!
所以我們需要帶有user id的欄位

	 $rails generate scaffold Micropost content:string user_id:integer

	$bundle exec rake db:migrate
	
OK! 現在可以跑起來了

	rails s 
	
輸入http:localhost:3000/users 或 http://localhost:3000/microposts 就可以開始建東西了！

不過目前什麼都沒有！例如一些防護機制，layout…etc

所以…

先來加個字數限制，既然是micropost所以字數當然不能多拉！

所以我們在寫進資料庫的時候做檢查！加在app/models/micropost.rb

	class Micropost < ActiveRecord::Base
  		validates :content, :length => { :maximum => 140 }
	end
	
接下來，寫關聯性在app/models/user.rb
	
	class User < ActiveRecord::Base
  		has_many :microposts
	end

同樣也要寫關聯性到app/models/micropost.rb
	
	class Micropost < ActiveRecord::Base
  		belongs_to :user
  		validates :content, :length => { :maximum => 140 }
	end

OK!大致完成！ 最後作版本控制以及放到heroku上吧

	$ heroku create --stack cedar
	$ git push heroku master
	$ heroku rename dempappaloha
還有一個很重要的！

	$ heroku run rake db:migrate
	

---
layout: post
title: "我的RoR學習專案-Part8 產生假資料"
date: 2012-05-12 11:04
comments: true
categories: ["Ruby on Rails"] 
---

Sorry脫稿有點久～最近有點忙，沒時間整理出之前的學習筆記～不過讓我一口氣補個兩篇吧！

終於到了最後～～用 Rake 撰寫的產生假資料的步驟。執行 rake dev:fake 即會產生假文章與假論壇

一樣先開branch

	$ git flow feature start use_rake_and_populator_feature

<!--more-->

這邊我是看學xduite書學的
新增**lib/tasks/dev.rake**

輸入
	namespace :dev do
	  desc "Rebuild System"
	  task :build => ["tmp:clear", "log:clear", "db:drop", "db:create","db:migrate"]
	  task :rebuild => ["dev:build", "db:seed"]
	end

之後下指令

	rake dev:build 

你會發線他把資料庫都給他殺掉了！！！

ok～work!

在**db/seed.rb **建立種子資料～也就是在專案開始時丟一些東西給他～

我打得是
	 admin = User.new(:email => "admin@alohacc.cc", :password => "123456", :password_confirmation => "123456")
	admin.is_admin = true 
	admin.save!
	
	normal_user = User.new(:email => "user@alohacc.cc", :password => "123456", :password_confirmation => "123456")
	normal_user.save! 
	
	forum = Forum.create!(:forum_name => "System Announcement")
	post = forum.posts.build(:post_title => "First Post", :poster_name => "aloha",:content => "This is a demo post") 
	post.user_id = admin.id 
	post.save!

	
一樣 我輸入指令
	

		rake db:seed

就這樣我新增了用戶以及admin!
不過～～因為我之前在使用devise時～是有選用要回覆認證信～你的帳號才會開啓～～

所以你必須去看一下了 rails server時的監控console 他會有寄信的log

就把那一串驗證的連結～copy到瀏覽器！這個帳戶才會開通！

之後～ 我想要用rake來作假資料
我使用了這個工具 **populator**
老樣子先在Gemfile加入


	gem 'populator'

下指令

	$ bundle install

之後在**lib/tasks/dev.rake**
加入

	require "populator"
	namespace :dev do
	  desc "Make fake data"
	   task :fake  => :environment do 
	     Forum.populate(20) do |forum_test|
	       forum_test.forum_name = "Cool"
	       forum_test.admin_forum_user ="admin"
	       forum_test.description = "test"
	       Post.populate(30) do |post|
	           post.forum_id = forum_test.id
	           post.content = Populator.words(10..20)
	         end
	     end
	   end

老實說我不知道 task :fake  => :environment 這句話的涵義....不過這樣做就work了～

我之前是在db底下建立fake.rb

然後:fake  => :environment 是寫成:fake  => “db:fake”

不過看來不是這麼一回事 不過是有work了！

其他關於populator的用法請看[這邊](https://github.com/ryanb/populator)

ya!!!!!!!!!!!!!
終於完成～ihower大的功課！！！

不過還有我想加的一個小東東～那就是google map XD請看[Part 9](http://ccaloha.cc/blog/2012/05/12/my-learning-ror-project-day-9-add-google-map/)
	

	git add .
	git commit -a
	git push origin feature use_rake_and_populator_feature
	git flow feature finish  use_rake_and_populator_feature

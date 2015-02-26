---
layout: post
title: "我的RoR學習專案-Part 7 新增附加檔案上傳功能"
date: 2012-02-19 23:15
comments: true
categories: ["Ruby on Rails"]
---

快要完成啦～～～再來我想要做的功能是
>每篇文章可以上傳附件。
>請使用 paperclip gem。

當然再開始之前～請先建立你要開發的git

	git flow feature start  add_paperclip_and_kaminari_feature
	git add .
	git commit -a 
	git push origin feature/add_paperclip_and_kaminari_feature

首先我按照他的步驟run 請直接參考https://github.com/thoughtbot/paperclip
<!--more-->
>#Requirements
If you're on Mac OSX, you'll want to run the following with Homebrew:
     brew install imagemagick
If you are dealing with pdf uploads or running the test suite, also run:
	 brew install gs


先下指令

	which convert

然後我得到
	
	/usr/local/bin/convert

代表我有安裝imagemagick

不過沒有gs 所以

就按造上面安裝吧！

之後…繼續

> 
For example, it might return /usr/local/bin/convert.
Then, in your environment config file, let Paperclip know to look there by adding that directory to its path.
In development mode, you might add this line to config/environments/development.rb):
Paperclip.options[:command_path] = "/usr/local/bin/"…….

ＯＫ～準備充裕後～那就來使用吧

在你的gemfile加入

	gem "paperclip", "~> 2.4"

之後在terminal下指令吧

	bundle install

找到你的model只要加上

	class User < ActiveRecord::Base
  		has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }
	end

另外還須加個migrate

	rails g migration add_attached_file_to_post

OK~去改你的migration

	class AddAttachedFileToPost < ActiveRecord::Migration
  		def self.up
      		add_column("posts", "attached_file_name",    :string)
      		add_column("posts", "attached_content_type", :string)
      		add_column("posts", "attached_file_size",    :integer)
      		add_column("posts", "attached_updated_at",   :datetime)
  		end
    	def self.down
      		remove_column ("posts", "attached_file_name")
      		remove_column ("posts", "attached_content_type")
      		remove_column ("posts", "avatar_file_size")
      		remove_column ("posts", "attached_updated_at")
    	end
	end

改完要幹嘛～～～～～該不會忘記了吧

	rake db:migrate

再來按造網頁上的東東(也就是下面那些依樣畫葫蘆改一改摟)

In your edit and new views:

	<%= form_for :user, @user, :url => user_path, :html => { :multipart => true } do |form| %>
  	<%= form.file_field :avatar %>
	<% end %>

In your controller:

	def create
  		@user = User.create( params[:user] )
	end

In your show view:

	<%= image_tag @user.avatar.url %>
	<%= image_tag @user.avatar.url(:medium) %>
	<%= image_tag @user.avatar.url(:thumb) %>

執行之後，幹....有問題，問題如下：

	NoMethodError in Posts#show
	Showing /Users/aloha/Sites/ccaloha/app/views/posts/show.html.erb where line #28 raised:
	undefined method `attached_file_file_name' for #<Post:0x1030aa6f0>
	Extracted source (around line #28):
	25: 		<% if @post.attached_file %>  
	26: 		<p>
	27:           <b><%= t("activerecord.attributes.post.attached_file", :default => 	t("activerecord.labels.attached_file", :default => "???")) %>: </b>
	28:           <%= image_tag(@post.attached_file.url(:medium)) %> 
	29:         </p>
	30: 		<% end %>
	31:  
       
我東看西看～我發現只有在migration那邊有問題！我的檔案和範例不太一致

我在想可能是因為 attached_file.url這個的預設欄位就是attached_file_file_name

也就是xxx_file_name 所以我必須按照樣去設定我的欄位！

不然就會找不到那個欄位！

所以我執行

	rake db:rollback STEP=1

回到上一步驟的migration!

然後再去改我的migration表
 
	def self.up
      add_column("posts", "attached_file_file_name",    :string)
      add_column("posts", "attached_file_content_type", :string)
      add_column("posts", "attached_file_file_size",    :integer)
      add_column("posts", "attached_file_updated_at",   :datetime)
  	end

    def self.down
      remove_column ("posts", "attached_file_file_name")
      remove_column ("posts", "attached_file_content_type")
      remove_column ("posts", "attached_file_file_size")
      remove_column ("posts", "attached_file_updated_at")
    end

果然一改就對了.....囧

OK~暫時完成～

	git add . 
	git commit -a 
	git push
	git flow feature finish add_paperclip_and_kaminari_feature


---
layout: post
title: "我的RoR學習專案-終篇-Part 9 加上Google map"
date: 2012-05-12 11:07
comments: true
categories: ["Ruby on Rails"] 
---

[Google Map for Rails](https://github.com/apneadiving/Google-Maps-for-Rails)

在開發之前一定要！

	git flow feature start  add_google_map

加入 **gem 'gmaps4rails' 到Gemfile**

	$ bundle install

	$ rails generate gmaps4rails:install

<!--more-->

另外我希望能夠讓使用者發佈訊息時，是可以設定地點
所以我想要在post這邊加入地點的資訊！
所以我在**app/modal/post.rb** 加上

	acts_as_gmappable

	def gmaps4rails_address
	 "#{self.street}, #{self.city}, #{self.country}" 
	end

之後 要在post加入東西～

	$ rails g migration add_map_info_to_posts

加了這些
	

	class AddMapInfoToPosts < ActiveRecord::Migration
	  def self.up
	    add_column ("posts", "latitude", :float) 	    
	    add_column ("posts", "longitude", :float) 
	  end
	
	  def self.down
	    remove_column ("posts", "latitude")
	    remove_column ("posts", "longitude")
	    
	  end
	end


在終端機：

	$ rake db:migrate

在**view/posts/_form.html.erb**加入

	<div class="group">
		<%= f.label :latitude,t("activerecord.attributes.post.latitude", :default => "緯度"), :class => :label%>
		<%= f.text_field :latitude %>
		</div>
		<div class="group">
	<%= f.label :longitude,t("activerecord.attributes.post.longitude", :default => "經度"), :class => :label%>
			<%= f.text_field :longitude %>
			</div>

在**controller/posts**加入

	def show
      @post = Post.find(params[:id])
      @json = Post.find(params[:id]).to_gmaps4rails
    end


好像少加到一個屬性!!!

所以要在終端機下

	$ rake db:rollback STEP=1

在剛剛那個migration檔案 加上

	class AddMapInfoToPosts < ActiveRecord::Migration
	  def self.up
	    add_column ("posts", "latitude", :float)     
	    add_column ("posts", "longitude", :float)     
	    add_column ("posts", "gmaps", :boolean)
	  end
	
	  def self.down
	    remove_column ("posts", "latitude")
	    remove_column ("posts", "longitude")
	    remove_column ("posts","gmaps")
	  end
	end



真的ＯＫ了～～酷耶～～

	git add . 
	git commit -a
	git push origin feature/add_google_map
	git flow feature finish  add_google_map

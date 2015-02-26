---
layout: post
title: "我的RoR學習專案-Day 2"
date: 2011-11-13 23:26
comments: true
categories: ["Ruby on Rails"] 
---

幹.....問題是....我要怎麼到一個forum然後秀出裡頭的post勒？

然後又要像要求 http://forum.local/forums/1/posts/2這樣的格式的網頁，

我們必須到/config/routes.rb 加東西～不過在這之前我必須先產生post的controller
	
    rails g controller posts

<!--more--> 

之後我們回到 /config/routes.rb 加入

    resources :forums do
        resources :posts
    end

OK~我們先hold住 先回到剛剛卡住的地方，剛剛在app/views/forums/show.html.erb卡住的原因是....

我希望可以show出所有在這個文章分區內包含的文章有哪些～那這樣的話在show.html.erb就必須要有post的資料，

所以我想我必須在forum的controller內的show加讀取Post資料庫的指令~

	 @posts = Post.where(:forum_id => @forum.id).order("created_at DESC")

加了之後～那我就來改/app/views/forums/show.html.erb加上
	
	<ul>
		<%@posts.each do |post|%>
		<%= post.post_title%>
		<%= post.poster_name%>
		<%= link_to '看三小', post_path(post) %>		
		<%end%>
	</ul>
 
 Yes! 我們現在終於到了post的部份，不過今天我想先來玩玩git和github，因為我想要備份一下我的檔案，

	cd ~/Sites/ccalohacc
	git add .
	git commit -a
	（編輯你要說明的變動）
	git push

大功告成，我把這幾天打得都給他放到github上了！

下次來試試 branch!!!	

ＯＫ～讓我們回到post,先來改post的controller吧，應該會跟forum很像吧....

正要cpoy forums的controller時才發現，我forums_controller還沒寫完....靠背～

先來改edit好了

    def edit
      @forum = Forum.find(params[:id])
    end

我想edit的重點是知道使用者點了哪個論壇～然後在到view提供表單給他修改～～
 
沒錯就來到/app/views/forums/ 建立一個edit.html.erb吧

內容基本上和new一樣，不過......url要導向哪裡！！！ 沒錯controller要有更新的動作

    	<%= form_for @forum, :url =>  do |f| %>
    		<%= f.label :forum_name, "版名" %>
    		<%= f.text_field :forum_name %>
		<%= f.label :admin_forum_user, " 管理者 " %>
    		<%= f.text_field :admin_forum_user %>
    		<%= f.label :description, "介紹" %>
    		<%= f.text_area :description %>
    		<%= f.submit "更新" %>
	<% end %>

 在forums_controller.rb加入 
	
	def update
      		@forum = Forum.find(params[:id])
      		@forum.update_attributes(params[:forum])
      		redirect_to forum_url(@forum)
    	end
    
在update Action裡，Rails一樣透過params[:id]參數找到要編輯的資料。

接著update_attributes方法會根據表單傳進來的參數修改到資料上。完成後，會被導向到的show那邊去。

幫edit.html.erb的url補上forum_path(@forum)吧，我想你可能會問那個update_attributes是三小～請參考[這篇](http://ihower.tw/rails3/activerecord.html)

ok~改完edit最後來改destroy吧～非常簡單就加個

	def destroy
      		@forum = Forum.find(params[:id])
      		@forum.destroy
      		redirect_to forums_url
    	end

因為要導向forum 的index 的動作～所以forum那邊要用複數->forums_usl

forum全部改完之後，我們來把他全部copy然後past到post的controller吧～因為幾乎都差不多

	class PostsController < ApplicationController
   		# show all posts
    		def index
      			@posts = Post.all
      			@forum = Forum.find(params[:forum_id])
      			redirect_to forum_path(@forum)
    		end
    
    		# new a post
    		def new
      			@post = Post.new
      			@forum = Forum.find(params[:forum_id])
      			@post = @forum.posts.build
    		end
    
   		 # when you click new , ROR will give you form to fill up.
    		 # when user click submit, it will direct to here
    		def create
      			@post = Post.new(params[:post])
      			@forum = Forum.find(params[:forum_id])
      			@post = @forum.posts.build(params[:post])
      			@post.save
      			redirect_to posts_url
    		end  
    
    		# show this post have what post
    		def show
      			@post = Post.find(params[:id])
      			@forum = Forum.find(params[:forum_id])
      			@post = @forum.posts.find(params[:id])
    		end
    
    		# edit this post's name , manager...etc 
    		def edit
      			@post = Post.find(params[:id])
      			@forum = Forum.find(params[:forum_id])
      			@post = @forum.posts.find(params[:id])
    		end
    
   		 # kill this post
    		def destroy
      			@post = Post.find(params[:id])
      			@forum = Forum.find(params[:forum_id])
      			@post = @forum.posts.find(params[:id])
      			@post.destroy
      			redirect_to posts_url
    		end
    
		def update
      			@post = Post.find(params[:id])
      			@forum = Forum.find(params[:forum_id])
      			@post = @forum.posts.find(params[:id]) 
      			@post.update_attributes(params[:post])
      			redirect_to post_url(@post)
    		end
  
	end

這邊我加了一些東東

我的解釋是因為post會和forum有關，所以在controller這邊要先跟model要forum的資訊～

這樣到時候view時，才可以秀資料

今天看了一下影片赫然發現！如果用戶在create時！如果發現錯誤....那....怎麼辦....

靠邀～都沒有想到如果用戶發現錯誤的話，要有一些error handle，沒錯～所以我們得加一些東西

 		def create
      			@forum = Forum.new(params[:forum])
      			if @forum.save
        			redirect_to forums_url
      			else
        		render('new')
      			end
    		end  

當然post也要加

		if @post.save
      			redirect_to posts_url
      		else
        		render('new')
      		end
 
不過，你不覺得在post那邊一直出現@forum = Forum.find(params[:id])嗎？！

你不覺得很靠邀～～

ＯＫ～根據教學影片～我們可以這樣解 

加一個private function就專門找forum_id
		
		private 
  		def find_forum
    			if params[:forum_id]
     			@forum = Forum.find_by_id(params[:forum_id])
   			end
  		end

不過好好想想，posts這邊應該改成這樣

		class PostsController < ApplicationController

		# 使用這個先抓到屬於這個post得form_id   
		before_filter :find_forum
   
		#展現出Post table裡面forum_id為我們所要得id並依照創立時間遞減排序
    		def index
       			@posts = Post.where(:forum_id => @forum.id).order("created_at DESC")
    		end
 		＃新增一篇文章，先new給他，並指派給他forum_id
    		
    		def new
     		 	@post = Post.new(:forum_id => @forum.id)
    		end
    
    		# when you click new , ROR will give you form to fill up.
    		# when user click submit, it will direct to here
    		def create
      			@post = Post.new(params[:post])
      			if @post.save
        			flash[:notice] = "文章發表成功"
      				redirect_to posts_url
      			else
        			render('new')
      			end
    		end  
    
    		# show this post have what post
    		def show
      			@post = Post.find(params[:id])
    		end
    
    		# edit this post's name , manager...etc 
    		def edit
      			@post = Post.find(params[:id])
    		end
    
    		# kill this post
    		def destroy
      			@post = Post.find(params[:id]).destroy
      			flash[:notice] = "文章刪除完成"
      			redirect_to posts_url
    		end
    
    		def update
      			@post = Post.find(params[:id]) 
      			if @post.update_attributes(params[:post])
        		flash[:notice] = "文章修改完成"
      			redirect_to post_url(@post)
    		end
  
  		private 
  			def find_forum
    				if params[:forum_id]
     				@forum = Forum.find_by_id(params[:forum_id])
   			end
  		end
	end

開始來建view吧～～

首先先來建index~就是會秀出這個論壇分類區內的文章

	<ul>
		<% @posts.each do |post| %>
  	    <li>
  		<%= post.post_title %>
  		<%= post.poster_name%>
  		<%= post.content%>
  		<%= post.position%>
  		<%= link_to '觀看文章', post_path(post) %>
  		<%= link_to '編輯文章', edit_post_path(post) %>
  		<%= button_to '刪除文章', post_path(post) , :method => :delete %>
  	    </li>
		<% end %>
	</ul>
	
	<%= link_to '新增文章', new_post_path %>

在這邊有個issue以後別忘記去瞭解他～

就是Post有個欄位是is_public，我是想如果是true的話～那所有人都看得到～如果是false的話～那就是必須要登入才可以看到，在看看要怎麼寫

再來增加new.html.erb
	
	<%= form_for @post, :url => posts_path  do |f| %>
    		<%= f.label :post_title, "文章標題" %>
    		<%= f.text_field :post_title %>
		<%= f.label :poster_name, " 撰寫人 " %>
    		<%= f.text_field :poster_name %>
    		<%= f.label :content, "內容" %>
    		<%= f.text_area :content %>
    		<%= f.submit "新增文章" %>
	<% end %>
		<%= link_to '取消新增', posts_path %>

再來是edit.html.erb

	<%= form_for @post, :url => post_path(@post)  do |f| %>
    		<%= f.label :post_title, "文章標題" %>
   		<%= f.text_field :post_title %>
		<%= f.label :poster_name, " 撰寫人 " %>
    		<%= f.text_field :poster_name %>
    		<%= f.label :content, "內容" %>
    		<%= f.text_area :content %>
    		<%= f.submit "更新文章" %>
	<% end %>

		<%= link_to '取消更新', post_path(@post) %>
 再來是show.html.erb
	
	<%= @forum.forum_name %>
	<ul>
		<%@posts.each do |post|%>
		<%= post.post_title%>
		<%= post.poster_name%>
		<%= link_to '看三小', post_path(post) %>		
		<%end%>
	</ul>
	<p><%= link_to '回到主論壇', forums_path %></p>
 
應該可以run了歐～～試一下吧！回到terminal~
	
	cd Sites/ccaloha/
	rails server
 
打開firefox....輸入 localhost:3000
....囧....怎麼沒有論壇的導覽列，應該這樣說...這個論壇是我的project裡頭一個～～所以應該要create projects的controller可連結到各個project!!!
	
	rails g controller projects 

這個projects我想可以不用使用resource的導向，因為我也不知道怎麼用ＸＤ，直接加導引就好了，不過....因為他有index所以我想我還是在route.rb加上
	
	resources :projects

我在projects_controller只放了
	
	def index
	end

 之後來編輯index.html.erb
	
	<!DOCTYPE html>
	<html>
	<head>
  	<title>CCALOHA-Projects</title>
	</head>
	<body>
	<h1>Projects</h1>
	
	<colgroup class="nav_bar">
		<nav>
			 <%= link_to "Ruby on Rails - 論壇練習" , forums_path %>
		</nav>
		<nav>
			 Action Script 3
		</nav>
		<nav>
			 Android
		</nav>
		<nav>
			 Linux
		</nav>
		<nav>
			HTML 5
		</nav>
		
		<nav>
			<%= link_to "Github" , "https://github.com/alChaCC" %>
		</nav>
	</hgroup>

	</body>
	</html>

重新更新頁面～～看來都ＯＫ歐～

連到論壇，建立新論壇～看來是ＯＫ歐～～再來建立post~

靠邀跳出error

	/Users/aloha/Sites/ccaloha/app/models/post.rb:2: syntax error, unexpected ':', expecting kEND
  	belongs_to : forum
              	    ^
幹～應該是我多一個空格...靠背 自己去改黑

ＯＫ～work了！不過....幹....沒有增加文章的連結

於是我到了views/forums/show.html.erb去增加了一行

	<p><%= link_to '新增文章', new_post_path %></p>

結果.....ＯＫ歐～～不過～點下新增文章的連結～幹

出現error~~他無法解析這段話～
	
所以我必須到route.rb去新增 resources :posts

就ＯＫ了 

結果我點新增文章....幹....又有bug

	/Users/aloha/Sites/ccaloha/app/controllers/posts_controller.rb:56: syntax error, unexpected $end, expecting kEND

應該是我多了還是少了一個end

幹....

def updates那邊少了一個end

應該是長這樣子的
	
	def update
      		@post = Post.find(params[:id])
      		if @post.update_attributes(params[:post])
        		flash[:notice] = "文章修改完成"
      			redirect_to post_url(@post)
      		end
    	end

  ＯＫ～改完了 refrash一下

囧....

Called id for nil, which would mistakenly be 4 -- if you really wanted the id of nil, use object_id

靠.....

	def find_forum
    		if params[:forum_id]
     			@forum = Forum.find(params[:forum_id])
    		else
      			flash.now[:notice] = "no id"
   		end
  end

這個 params[:forum_id]是nil！！！

各位～sorry~ 其實 params[:forum_id]的意思從書上看來是

http://forum_demo.dev/board/1 params[:id] 是1

http://forum_demo.dev/board/1/post/2 params[:id] 是2 param[:board_id] 是 1

意思就是.....其實照理說網址應該就要帶有這些資訊，那因為我現在寫的這一行

在views/forums/show.html.erb增加的那一行

	<p><%= link_to '新增文章', new_post_path %></p>

所以當我們按新增文章時，因為我右手賤把到route.rb去新增 resources :posts 

所以他是直接導入controller=> post 的new 這個動作～所以基本上他的網址是http:localhost:3000/posts/new

那他當然找不到，這時候我需要的是兩層的resourse～不知道還記不記得我n百年之前在config.rb加了一個

	resourecs :forums do
	 	resources :posts 

沒錯！！！所以只要和restfull有關的都要改～～不過也因為這樣讓我學到Nested Resource

我們可以參考[這篇](http://guides.rubyonrails.org/routing.html) 知道有這幾種寫法

若像下面那樣寫法呢
	
	resources :magazines do
  		resources :ads
	end

你要怎麼使用呢？ 請看文章敘述

When using magazine_ad_path, you can pass in instances of Magazine and Ad instead of the numeric IDs.

	<%= link_to "Ad details", magazine_ad_path(@magazine, @ad) %>

You can also use url_for with a set of objects, and Rails will automatically determine which route you want:

	<%= link_to "Ad details", url_for([@magazine, @ad]) %>


所以我改了很多地方～包括forum的show也有地方要改～～～一個一個來看吧

首先先來看～forums_controller

我的show 動作有改～～改成
	
	@posts = Post.where(:forum_id => @forum.id)  

之前是@posts = Post.where(:forum_id => @forum.id) .order(“create_at DESC”)

為甚麼要改是因為～我發現整個都完成之後～在forum 底下show出所有post時～～id和forum_id會顛倒.....囧，好怪～不過我把他刪掉之後～就ＯＫ了～～這個要在好好想想

再來改show.html.erb改成下面這樣

	<%= @forum.forum_name %>

	<ul>
		<%@posts.each do |post|%>
		<%= post.post_title%>
		<%= post.poster_name%>
		<%= link_to '看三小', forum_post_path(@forum,post) %>		
		<%end%>
	</ul>
	
		<p><%= link_to '新增文章', new_forum_post_path(@forum) %></p>
		<p><%= link_to '回到主論壇', forums_path %></p>

new_forum_post_path(@forum)會連到http://localhost:3000/forums/1/posts/new

forum_post_path(@forum,post)會連到http://localhost:3000/forums/1/posts/1

再來大改～posts_controller那邊吧，改成下面這樣～

	class PostsController < ApplicationController
   		before_filter :find_forum
   
    		def index
      			 @posts = Post.where(:forum_id => @forum.id).order("created_at DESC")
    		end
    		
    		def new
      			@post = @forum.posts.build
    		end
    
    		def create
      			@post = @forum.posts.build(params[:post])
      			if @post.save
        			flash[:notice] = "文章發表成功"
      				redirect_to forum_posts_url
     		 	else
        			render('new')
      			end
   		end  
    
    		def show
      			@post = Post.find(params[:id])
    		end
    
    		def edit
      			@post = Post.find(params[:id])
    		end
    
    		def destroy
      			@post = Post.find(params[:id]).destroy
      			flash[:notice] = "文章刪除完成"
      			redirect_to forum_posts_path
    		end
   
    		def update
      			@post = Post.find(params[:id]) 
      			if @post.update_attributes(params[:post])
        			flash[:notice] = "文章修改完成"
      				redirect_to forum_post_url(@forum,@post)
      			end
    		end
  
 	 private 
  
 	 	def find_forum
      		 	@forum = Forum.find(params[:forum_id])
  		end
	end

一個一個來說～為甚麼new改成

	@post = @forum.posts.build

是因為如果不改寫成這樣～我們必須寫成這樣
	
	@post = Post.new
	@post.forum_id = @forum.id

同理～create也是，另外只要有restful全部都要改～

再來改view吧～～

edit.html.erb :
	
	<%= form_for @post, :url => forum_post_path(@forum,@post)  do |f| %>
    		<%= f.label :post_title, "文章標題" %>
    		<%= f.text_field :post_title %>
		<%= f.label :poster_name, " 撰寫人 " %>
   	 	<%= f.text_field :poster_name %>
    		<%= f.label :content, "內容" %>
   	 	<%= f.text_area :content %>
    		<%= f.submit "更新文章" %>
	<% end %>

	<%= link_to '取消更新', forum_post_path(@forum,@post) %>

index.html.erb:

	<%= @forum.forum_name %>
		<ul>
		<% @posts.each do |post| %>
  		  <li>
  			<%= post.post_title %>
			<%= post.poster_name%>
	  		<%= post.content%>
	  		<%= post.position%>
	  		<%= link_to '觀看文章', forum_post_path(@forum,post) %>
	  		<%= link_to '編輯文章', edit_forum_post_path(@forum,post) %>
		  	<%= button_to '刪除文章', forum_post_path(@forum,post) , :method => :delete %>
		  </li>
		<% end %>
		</ul>
		<p><%= link_to '新增文章', new_forum_post_path(@forum) %></p>
		<%= link_to '回到論壇首頁' , forums_path %>

show.html.erb:

		<%= @post.post_title %>
		<%= @post.poster_name%>
		<%= @post.content %>		
		<p><%= link_to '回到主論壇分類', forum_posts_path %></p>

new.html.erb:

		<%= form_for @post, :url => forum_posts_path(@forum)  do |f| %>
	    		<%= f.label :post_title, "文章標題" %>
    			<%= f.text_field :post_title %>  
			<%= f.label :poster_name, " 撰寫人 " %>
   			<%= f.text_field :poster_name %>
    			<%= f.label :content, "內容" %>
    			<%= f.text_area :content %>
    			<%= f.submit "新增文章" %>
		<% end %>
		<%= link_to '取消新增', forum_posts_path(@forum) %>

OK~讓我們先save，先儲存版本吧～之後就要開branch～～因為要增加功能啦～～

這邊我使用一個工具叫做 git-flow

首先在我的專案底下～

	cd Sites/ccaloha/
	git flow init
	git flow feature start user_register_and_manager

然後就可以開始寫～～～～

寫完之後在用
 
	git flow feature finish user_register_and_manager

之後再用
	
	git flow feature publish user_register_and_manager

把他給放到github~~~


那我們先來做些事情～等一下在試看看新加功能，在放上去～branch

follow up ihower的[教學](http://ihower.tw/rails3/auth.html)

首先在file 加上

	gem ‘devise’

各位～只要想要用一些套件～就要用這個方式先把人家寫好的東西套來用！

在terminal輸入
	
	bundle install

輸入
	rails g devise:install

建立設定檔，之後再輸入
	
	rails g devise user

建立user model 和migration 還有route加上了devise_for :users

因為我希望有email認證～ 

所以我要編輯app/models/user.rb 把devise 多增加一個模組～～：confirmable

	class User < ActiveRecord::Base
  		# Include default devise modules. Others available are:
  		# :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  
		devise :database_authenticatable, :registerable,:confirmable,
         	:recoverable, :rememberable, :trackable, :validatable

 		 # Setup accessible (or protected) attributes for your model
  		attr_accessible :email, :password, :password_confirmation, :remember_me
	end

還有要編輯migration 檔

	class DeviseCreateUsers < ActiveRecord::Migration
  		def self.up
    			create_table(:users) do |t|
      			t.database_authenticatable :null => false
     			t.recoverable
      			t.rememberable
      			t.trackable
      			t.confirmable
      			t.timestamps
    			end
    		add_index :users, :email,                :unique => true
    		add_index :users, :reset_password_token, :unique => true
  		end

  		def self.down
    			drop_table :users
  		end
	end

把confirmable的table打開

之後再建立樣板
	
	rails g devise:views

最後建立資料表
	
	rake db:migrate
 
OK~該睡覺了～～把檔案做個備份吧～
	
	git add .
	git commit -a
	git flow feature finish user_register_and_manager
	git push origin develop

(因為 git flow feature start 他是開feature這個branch)

但是當你把他做finish時～他就會把他merge回develope這個branch~

所以我在push時～要改成develop



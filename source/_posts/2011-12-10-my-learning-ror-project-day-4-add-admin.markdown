---
layout: post
title: "我的RoR學習專案-Day 4 增加 admin功能"
date: 2011-12-10 16:34
comments: true
categories: ["Ruby on Rails"] 
---

我們要如何讓使用者只能編輯或刪除自己的文章而不是別人的文章～

首先我想應該先增加post的一個欄位～乃發佈文章人的id

	rails g migration add_user_id_to_post

<!--more--> 

再來編輯這個migration檔案吧～
	class AddUserIdToPost < ActiveRecord::Migration
  		def self.up
    		add_column("posts" , "user_id" , :integer )
  		end

  		def self.down
    		remove_column("posts" , "user_id")
  		end
	end

然後我在執行

	rake db:migrate

在app/model/user.rb加入

	has_many :posts

在app/model/post.rb加入
	
	belongs_to :user

在app/comtrollers/post的create

把@post = Post.new(params[:post])換成下面那個樣子
      
	@post = @forum.posts.build(params[:post])
    @post.user_id = current_user.id

還有在app/comtrollers/post的show、update、destroy把
@post = Post.new(params[:post])換成 
	
	@post = @forum.posts.build(params[:post])


在app/view/post/index.html.erb加上判別式

	<% if current_user && post.user_id == current_user.id%>
  	<%= link_to '編輯文章', edit_forum_post_path(@forum,post) %>
  	<%= button_to '刪除文章', forum_post_path(@forum,post) , :method => :delete %>
	<%end%>

在app/view/post/show.html.erb加上判別式

	<% if current_user && @post.user_id == current_user.id%>
 	<%= link_to "編輯文章" , edit_forum_post_path(@forum,@post)%>
	<%end%>

大概搞定之後我們來加入admin user吧～

首先先來個
	
	rails generate devise Admin

編輯admin model

	class Admin < ActiveRecord::Base
  	devise :database_authenticatable, :trackable, :timeoutable, :lockable  
  	attr_accessible :email, :password, :password_confirmation
	end

修改migration的檔案

	class DeviseCreateAdmins < ActiveRecord::Migration
  	def self.up
    	create_table(:admins) do |t|
      	t.database_authenticatable :null => false
      	t.trackable
      	t.lockable
      	t.timestamps
    	end
  	end
  	def self.down
    	drop_table :admins
  		end
	end

完成！！

在看一次我們的需求

>建立一個後台，讓管理員可以刪改所有文章，網址是 http://forum.local/admin/。只有身分是 admin 的人可以進後台。admin 的判別方是 column 裡加一個 boolean，判斷是否 admin。這個 attribute 必須用 attr_accessible 或 attr_protected 保護。


所以我想我必須加個admin的頁面

>================以下參考就好====================

一開始我按照這篇[How To: Add an Admin Role](https://github.com/plataformatec/devise/wiki/How-To:-Add-an-Admin-Role)

其實她有兩個option，我照著第一個寫，我發現....我幹嘛多create一個admin的table
使用者登入之後還要在跟admin table的表～比對他是不是管理員～有點多餘...

不過我還是按照上面把這些都給他打完了....但是我可能就先不用了...先擱著吧...以後會用在說
>================以上參考=======================

第二種方法

	rails g migration add_is_admin_to_user

然後在migration檔案編輯

	class AddIsAdminToUser < ActiveRecord::Migration
  		def self.up
    		add_column("users" , "is_admin" , :boolean , :default => false )
  		end

  		def self.down
    		remove_column("users" , "is_admin")
  		end
	end

然後下
	
	rake db:migrate

我們在app/model/user.rb加入判斷式
 
	def is_admin?
    	is_admin
  	end

到時候如果使用User.is_admin時～他就會回覆這個is_admin欄位的值

接著我幫第一個使用者加上admin的權限

 	rails console
 	user = User.first
	user.is_admin = true
	user.save!

ＯＫ～ 我們還要加上屬性的保護！

讓hacker無法在browser端假造一個屬性自己送is_admin = true進來～所以要在user model 宣告is_admin欄位要protected

	attr_protected : is_admin

接著就是一堆東西要改拉

首先要在app/controllers底下建立先的資料夾叫做admin

要想一下～誰要在admin底下被管！
當然就是post和forum對八

所以我就先把app/controller底下的forum直接複製到app/controller/admin底下，posts也是

另外，別忘了修改app/controller/forums_controllers和app/controller/posts兩個檔案原本的設定！

一個一個來看～

首先來看app/controllers/admin/forums_controller

	class Admin::ForumsController < ApplicationController
   	layout'admin'
   	before_filter :require_is_admin 
    # show all forums
    def index
      @forums = Forum.all
    end
    
    # new a forum
    def new
      @forum = Forum.new
    end
    
    # when you click new , ROR will give you form to fill up.
    # when user click submit, it will direct to here
    
    def create
      @forum = Forum.new(params[:forum])
      if @forum.save
        redirect_to admin_forums_path(@forum)
      else
        render('new')
      end
    end  
    
    # show this forum have what post
    def show
      @forum = Forum.find(params[:id])
      @posts = Post.where(:forum_id => @forum.id)
    end
    
    # edit this forum's name , manager...etc 
    def edit
      @forum = Forum.find(params[:id])
    end
    
    # kill this forum
    def destroy
      @forum = Forum.find(params[:id]).destroy
      
      redirect_to admin_forums_url
    end
    
    def update
      @forum = Forum.find(params[:id])
      if @forum.update_attributes(params[:forum])
      redirect_to admin_forums_url
      else
      render ('edit')
      end
    end
    
	end

再來app/controllers/admin/posts_controller

	class Admin::PostsController < ApplicationController
   	layout 'admin'
   	before_filter :require_is_admin
   	before_filter :authenticate_user! , :except => [:index]
   	before_filter :find_forum
    
    def index
      @post = Post.where(:forum_id => @forum.id).order("created_at DESC")
    end
    
    # edit this post's name , manager...etc 
    def edit
      @post = Post.find(params[:id])
    end
    
    # kill this post
    def destroy
      @post = Post.find(params[:id]).destroy
      flash[:notice] = "文章刪除完成"
      redirect_to admin_forum_path(@forum)
    end
    
    def update
      @post = Post.find(params[:id])
      
      if @post.update_attributes(params[:post])
        flash[:notice] = "文章修改完成"
      redirect_to admin_forum_post_url(@forum,@post)
      end
    end
    
    def show
      @post = Post.find(params[:id])
    end
  
 	private 

  	def find_forum
    #if params[:forum_id]
      @forum = Forum.find(params[:forum_id])
    #else
     # flash.now[:notice] = "no id"
    #end
  	end
	end

這邊你應該會覺得很奇怪！那個layout ‘admin’是殺小～

before_filter :require_is_admin 又是寫在哪裡！？

class Admin::PostsController 又是哪招.....

那個連續兩個admin_forum_post_url(@forum,@post) 搞誰啊～

**首先layout ‘admin’ 是寫在views/layout那邊**

我們要在views/layout新建一個admin.html.erb的檔案

他是長這樣低

	<!DOCTYPE html>
	<html>
	<head>
  	<title>CCaloha</title>
  	<%= stylesheet_link_tag :all %>
  	<%= javascript_include_tag :defaults %>
  	<%= csrf_meta_tag %>
	</head>
	<body>
	<h1> 管理者界面 </h1>
	<p class="notice"><%= notice %> </p>
	<p class="alert"><%= alert%> </p>
	<%= yield %>
	</body>
	</html>
參考ihower的文章[ActionView版型](http://ihower.tw/rails3/actionview.html)

>Layout可以用來包裹Template樣板，讓不同View可以共用Layout作為文件的頭尾。因此我們可以為全站的頁面建立共用的版型。這個檔案預設是app/views/layouts/application.html.erb。如果在app/views/layouts目錄下有跟某Controller同名的Layout檔案，那這個Controller下的所有Views就會使用這個同名的Layout。
….



**before_filter :require_is_admin 又是寫在哪裡！？**

不知道有沒有注意到class XXXController < ApplicationController

也就是說～controller的class是繼承於ApplicaitonController 

所以我們是在app/controller/application_controller裡頭加了

	def require_is_admin
    	unless (current_user && current_user.is_admin?)
      	flash[:alert] = "你是管理者"
      	redirect_to forums_path
    	end
  	end

*那個current_user是devise 提供的function**
 
**那個class Admin::PostsController 又是殺小.....**

目前尚未找到相關訊息....不過我的感覺...他是一種namespace的感覺～～

宣告這個PostsController是屬於admin這個namespace裡頭的controller

我剛好在網路上用namespace找到的網誌[Ruby on Rails API version design](http://blog.hellolucky.info/articles/ruby-on-rails-api-version-design/)，看來我的解釋沒有錯

也是因為上面網誌那樣的說法

利用namespace來處理不同資料夾的controller

所以我們config/routes.rb必需要加點東西
	 namespace :admin do
        resources :forums do
          resources :posts
        end
      end


**那個連續兩個admin_forum_post_url(@forum,@post)是殺小**

那個也是跟上面那個議題有關

請直接參考ihower大大[Restful](http://ihower.tw/rails3/restful-practices.html)
>Namespace Resources
案例：新增 event 的管理後台
原有的 events_controller 會作為前台一般使用者之用。為了後台管理用途，我們會另外再新增一個 controller 來操作 Event 這個 model
….

ＯＫ！改完controllers/admin 底下的controller

現在要著手在他們的view!

首先先來看views/admin/forums底下

我只留edit, index, show , new，為甚麼呢

因為我希望版名只有管理員可以管理！

其他使用者只能看板明然後進入而已～～其實都根原本的差不多只不過導向的位址要改

那我們一個一個來看～主要的issue就是連到的位址，我在debug主要都是因為找不到連結！

編輯/views/admin/forums/edit.html.erb
	<h1>編輯版名</h1>
	<%= form_for @forum, :url => admin_forum_path(@forum)  do |f| %>
    <%= f.label :forum_name, "版名" %>
    <%= f.text_field :forum_name %>
    
	<%= f.label :admin_forum_user, " 管理者 " %>
    <%= f.text_field :admin_forum_user %>

    <%= f.label :description, "介紹" %>
    <%= f.text_area :description %>
    
    <%= f.submit "更新" %>
	<% end %>
	<p><%= link_to '回到主論壇', admin_forums_path %></p>
編輯/views/admin/forums/index.html.erb
	<ul>
	<% @forums.each do |forum| %>
  	<li>
  	<%= forum.forum_name %>
  	<%= forum.admin_forum_user%>
  	<%= forum.description%>
  	<%= forum.post_num%>
  	<%= link_to '進入', admin_forum_path(forum) %>
  	<%= link_to '編輯', edit_admin_forum_path(forum) %>
  	<%= button_to '刪除', admin_forum_path(forum) , :method => :delete %>
  	</li>
	<% end %>
	</ul>
	<%= link_to '新增論壇分類', new_admin_forum_path %>
	<% if current_user %>
     <%= link_to('登出', destroy_user_session_path) %> |
     <%= link_to('修改密碼', edit_registration_path(:user)) %>
	<% else %>
   	 <%= link_to('註冊', new_registration_path(:user)) %> |
     <%= link_to('登入', new_session_path(:user)) %>
	<% end %>

編輯/views/admin/forums/new.html.erb
	<h1>新增看版</h1>
	<%= form_for @forum, :url => admin_forums_path do |f| %>
    <%= f.label :forum_name, "版名" %>
    <%= f.text_field :forum_name %>
    
	<%= f.label :admin_forum_user, " 管理者 " %>
    <%= f.text_field :admin_forum_user %>

    <%= f.label :description, "介紹" %>
    <%= f.text_area :description %>
    
    <%= f.submit "新增" %>
	<% end %>
	<%= link_to "回到論壇首頁" , admin_forums_path%>


編輯/views/admin/forums/show.html.erb

	<%= @forum.forum_name %>

	<ul>
		
		<%@posts.each do |post|%>
		<%= post.post_title%>
		<%= post.poster_name%>
		<%= link_to '看三小', admin_forum_post_path(@forum,post) %>
		<%= link_to '刪除此文章', admin_forum_post_path(@forum,post) , :confirm => '你確定要刪除嗎？', :method => 'delete' %>
			
		<%end%>
		
	</ul>
	<p><%= link_to '回到主論壇', admin_forums_path %></p>

在/views/admin/posts/ 這邊比較特別！

我是覺得管理者如果是在管理頁面的話！

他是不能新增文章的！他只能刪修查

所以我只留edit,show這幾個view,也許你會問怎麼沒有index！

因為我把index的秀文章列表的功能移到forum去做！

首先先來看 /views/admin/posts/edit.html.erb

	<%= form_for @post, :url => admin_forum_post_path(@forum,@post)  do |f| %>
    <%= f.label :post_title, "文章標題" %>
    <%= f.text_field :post_title %>
    
	<%= f.label :poster_name, " 撰寫人 " %>
    <%= f.text_field :poster_name %>

    <%= f.label :content, "內容" %>
    <%= f.text_area :content %>
    
    <%= f.submit "更新文章" %>
	<% end %>
	<%= link_to '取消更新', admin_forum_post_path(@forum,@post) %>

show文章的話就是透過這個 /views/admin/posts/show.html.erb

	<%= @forum.forum_name %>
	<%= @post.post_title %>
	<%= @post.poster_name%>
	<%= @post.content %>		
	<%= link_to "編輯文章" , edit_admin_forum_post_path(@forum,@post)%>
	<p><%= link_to '回到主論壇分類', admin_forum_path(@forum) %></p>

主要兩個admin的controller和view都完成了！

再來就是把app/controllers底下的forums_controller改掉

只剩index和show

	class ForumsController < ApplicationController
    
    # show all forums
    def index
      @forums = Forum.all
    end
    
    # show this forum have what post
    def show
      @forum = Forum.find(params[:id])
      @posts = Post.where(:forum_id => @forum.id)
    end
	end

另外posts_controller比較雷同，因為只要是有登入的人都可以發表文章～編輯文章～不一定局限於管理者！


	class PostsController < ApplicationController
   
   	before_filter :authenticate_user! , :except => [:index, :show] 
   	before_filter :find_forum
   
    def index
       @posts = Post.where(:forum_id => @forum.id).order("created_at DESC")
    end
    
    # new a post
    def new
      
      @post = @forum.posts.build
    end
    
    # when you click new , ROR will give you form to fill up.
    # when user click submit, it will direct to here
    def create
      #@post = Post.new(params[:post])
      @post = @forum.posts.build(params[:post])
      @post.user_id = current_user.id
      if @post.save
        flash[:notice] = "文章發表成功"
      redirect_to forum_posts_url
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
      #@post = Post.find(params[:id])
      @post = current_user.posts.find(params[:id])
    end
    
    # kill this post
    def destroy
     # @post = Post.find(params[:id]).destroy
      @post = current_user.posts.find(params[:id]).destroy
      flash[:notice] = "文章刪除完成"
      redirect_to forum_posts_path
    end
    
    def update
      #@post = Post.find(params[:id])
      
       @post = current_user.posts.find(params[:id])
      
      if @post.update_attributes(params[:post])
        flash[:notice] = "文章修改完成"
      redirect_to forum_post_url(@forum,@post)
      end
    end
  
 	private 
  
  	def find_forum
    	#if params[:forum_id]
      	@forum = Forum.find(params[:forum_id])
    	#else
     	# flash.now[:notice] = "no id"
    	#end
  		end
	end

當然改了controller一定要改view我就不贅述了～直接放檔案

/views/forums/index.html.erb

	<ul>
	<% @forums.each do |forum| %>
  	<li>
  	<%= forum.forum_name %>
  	<%= forum.admin_forum_user%>
  	<%= forum.description%>
  	<%= forum.post_num%>
  	<%= link_to ('進入論壇',forum_posts_path(forum))%>
  	</li>
	<% end %>
	</ul>
	<% if current_user %>
     <%= link_to('登出', destroy_user_session_path) %> |
     <%= link_to('修改密碼', edit_registration_path(:user)) %>
	<%if current_user.is_admin?%>
		<%= link_to ('管理者頁面' , admin_forums_path)%>
	 <%end%>
	<% else %>
   	 <%= link_to('註冊', new_registration_path(:user)) %> |
     <%= link_to('登入', new_session_path(:user)) %>
	<% end %>


/views/forums/show.html.erb

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

post的部份～我就沒動了

這部份功能大概就是這樣了！
所以我先把這個開發關掉了
並merge回去develope
	
	git add .
	git commit -a
	git flow feature finish user_register_and_manager


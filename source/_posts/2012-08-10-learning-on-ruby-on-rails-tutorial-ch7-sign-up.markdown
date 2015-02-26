---
layout: post
title: "Learning on Ruby on Rails Tutorial-CH7 Sign Up"
date: 2012-08-10 11:02
comments: true
categories: [Reading , Ruby on Rails] 
---
在開始之前，先來

	$ git checkout master
	$ git checkout -b sign-up


### Debug and Rail 環境

等一下我們要加入動態網頁！ 所以我們先來加一些debug mode 在網頁上
<!--more--> 
**app/views/layouts/application.html.erb** 

	<!DOCTYPE html>
	<html>
	  <head>
	    <title><%= full_title(yield(:title)) %></title>
	    <%= stylesheet_link_tag    "application", media: "all" %>
	    <%= javascript_include_tag "application" %>
	    <%= csrf_meta_tags %>
	    <%= render 'layouts/shim' %>    
	  </head>
	  <body>
	    <%= render 'layouts/header' %>
	    <div class="container">
	      <%= yield %>
	      <%= render 'layouts/footer' %>
	      #加入下面那句
		  <%= debug(params) if Rails.env.development? %>
	    </div>
	  </body>
	</html>

<!--more--> 

甚麼是Rails.env.development?

讓我們來開一下 concole

	$ rails console
	$ Rials.env
	$ Rails.env.development?
    $ Rails.env.test?

你會發現 default就是
development

如果想要改成其他mode你可以這樣做

* 改console的mode

	$ rails console test
	
* 改local rails server

	$ rails server --enviroment production

*  如果app跑在production之下時，db也要改

	$ bundle exec rake db:migrate RAILS_ENV=production
	
然後再來改一下
**app/assets/stylesheets/custom.css.scss**

加上

	@mixin box_sizing {
	  -moz-box-sizing: border-box; 
	  -webkit-box-sizing: border-box; 
	  box-sizing: border-box;
	}
	
	/* miscellaneous */
	
	.debug_dump {
	  clear: both;
	  float: left;
	  width: 100%;
	  margin-top: 45px;
	  @include box_sizing;
	}


注意看一下那個

**@include box_sizing;**

他是Sass的mixin facility , 它可以讓一大堆的CSS 規則打包在一起 然後透過@include 來用！！！ 真是酷斃了！


### A User resource 
When following REST principles, resources are typically referenced using the resource name and a unique identifier. What this means in the context of users—which we’re now thinking of as a Users resource—is that we should view the user with id 1 by issuing a GET request to the URL /users/1

Unfortunately, the URL /users/1 doesn’t work quite yet 
due to a routing error (Figure 6.9). We can get the REST-style Users URL to work by adding users as a resource to 


所以我們在這邊**config/routes.rb** 必須加上

	resources :users
	
	
我們再來看一下user的route表

Named route &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Path

==========================

* users_path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;
/users

* user_path(@user)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;
/users/1

* new_user_path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp; 
/users/new

* edit_user_path(@user)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
/users/1/edit

* users_url  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; http://localhost:3000/users
* user_url(@user) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;	http://localhost:3000/users/1
* new_user_url &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;	http://localhost:3000/users/new
* edit_user_url(@user)	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;http://localhost:3000/users/1/edit


然後那個

*<%= link_to user_path(@user), @user %>*
等於
*<%= link_to user_path(@user), user_path(@user) %>*

因為Rails converts @user to the appropriate URL

	
OK~讓我們來加一些東西在controller上吧！

**app/controllers/users_controller.rb**

	class UsersController < ApplicationController
	
	  def show
	    @user = User.find(params[:id])
	  end
	
	  def new
	    @title = "Sign up"
	  end
	end

我們使用Rails的**params**物件擷取user的id

還有View的部份 先加個

**app/views/users/show.html.erb**

	<%= @user.name %>, <%= @user.email %>

###測試 User 的show page

請寫在**spec/requests/user_pages_spec.rb**

	require 'spec_helper'
	
	describe "User pages" do
	  subject {page}
	  describe "profile page"" do
	    before {visit signup_path}
	      
	      it {should have_selector('h1', text: 'Sign up')}
	      it {should have_selector('title', text: full_title('Sign up'))}
	  end
	end

通常會用**User.create**來做檔案，不過在測試時，通常都會用工廠女孩來簡化操作

再開始之前，我們要來使用工廠女孩XD , 一個Ruby 的gem 由thoughtbot 製作 

OK~請到**Gemfile**我們來加這個Gem但是因為我們只需要在測試時用到，所以....請在group :test do這個block加上

	 gem 'factory_girl_rails', '1.4.0'
	 
存檔之後 別忘了....

	bundle install 

OK 來寫檔案吧

**spec/factories.rb**

	Factory.define :user do |user|
	  user.name                  "Aloha CC"
	  user.email                 "aloha@example.com"
	  user.password              "foobar"
	  user.password_confirmation "foobar"
	end

之後，**我們就可以在測試裡面這樣用**
	
	let(:user) { FactoryGirl.create(:user) }
	
let的意思是

RSpec’s let method provides a convenient way to create local variables inside tests. The syntax might look a little strange, but its effect is similar to variable assignment. The argument of let is a symbol, and it takes a block whose return value is assigned to a local variable with the symbol’s name. In other words,

	let(:found_user) { User.find_by_email(@user.email) }
creates a found_user variable whose value is equal to the result of find_by_email. We can then use this variable in any of the before or it blocks throughout the rest of the test. One advantage of let is that it memoizes its value, which means that it remembers the value from one invocation to the next. (Note that memoize is a technical term; in particular, it’s not a misspelling of “memorize”.) In the present case, because let memoizes the found_user variable, the find_by_email method will only be called once whenever the User model specs are run.

那來改一下

**spec/requests/user_pages_spec.rb**

	require 'spec_helper'
	
	describe "User pages" do
	  subject {page}
	  describe "profile page" do
	    let(:user) { FactoryGirl.create(:user) }
	    before {visit signup_path}
	      
	      it {should have_selector('h1', text: 'Sign up')}
	      it {should have_selector('title', text: full_title('Sign up'))}
	  end
	end


現在執行測試一定一堆錯誤！

讓我們繼續改**app/views/users/show.html.erb**

加上

	<% provide(:title, @user.name) %>
	<h1><%= @user.name %></h1>

OK~當你執行

	$ bundle exec rspec spec/
	
One thing you will quickly notice when running tests with Factory Girl is that they are slow. The reason is not Factory Girl’s fault, and in fact it is a feature, not a bug. The issue is that the BCrypt algorithm used in Section 6.3.1 to create a secure password hash is slow by design: BCrypt’s slow speed is part of what makes it so hard to attack. Unfortunately, this means that creating users can bog down the test suite; happily, there is an easy fix. BCrypt uses a cost factor to control how computationally costly it is to create the secure hash. The default value is designed for security, not for speed, which is perfect for production applications, but in tests our needs are reversed: we want fast tests, and don’t care at all about the security of the test users’ password hashes. The solution is to add a few lines to the test configuration file, config/environments/test.rb, redefining the cost factor from its secure default value to its fast minimum value, as shown in Listing 7.11. Even for a small test suite, the gains in speed from this step can be considerable, and I strongly recommend including Listing 7.11 in your test.rb.


所以我們要來改一下環境變數
**config/environments/test.rb**
加上

	# Speed up tests by lowering BCrypt's cost function.
	  require 'bcrypt'
	  silence_warnings do
	    BCrypt::Engine::DEFAULT_COST = BCrypt::Engine::MIN_COST
	  end

補充一下～

別忘了確認一下有沒有在**Gemfile**加上

	gem 'bcrypt-ruby', '3.0.1'

###A Gravatar image and a sidebar

Gravatar就是一個免費可以讓使用者上傳圖片，然後這張圖片會和他的email做連結！

你只要這樣改一下
**app/views/users/show.html.erb**

	<% provide(:title, @user.name) %>
	<h1>
	  <%= gravatar_for @user %>
	  <%= @user.name %>
	</h1>

如果現在跑測試的話你會得到錯誤！

因為 **gravatar_for**這個方法尚未定義！

一般來說，方法定義在任何的helper裡面，都會自動可以被所有view使用，但是為了方便，我們會把 **gravatar_for**這個方法，放到和User controller有關聯的helper上！

由gravatar官方文件指出，Garavatar的URI是基於使用者email的MD5 Hash. 
在Rails裡面MD5是由Digest這個library裡頭的hexdigest方法負責

我們可以這樣用
	
		$ rails console
		>> email = "MHARTL@example.COM"
		>> Digest::MD5::hexdigest(email.downcase)
		=> "1fda4469bcbec3badf5418269ffc5968" 
	
然後來寫一下
**gravatar_for**

我們寫在**app/helpers/users_helper.rb**

	module UsersHelper
	
	  # Returns the Gravatar (http://gravatar.com/) for the given user.
	  def gravatar_for(user)
	    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
	    gravatar_url = "http://www.gravatar.com/avatar/#{gravatar_id}.png"
	    image_tag(gravatar_url, alt: user.name, class: "gravatar")
	  end
	end

接下來我們來編輯

**app/views/users/show.html.erb**

我們使用row和span4這兩個class(都有在bootstrap被定義)

	<% provide(:title, @user.name) %>
	<div class="row">
	  <aside class="span4">
	    <section>
	      <h1>
	        <%= gravatar_for @user %>
	        <%= @user.name %>
	      </h1>
	    </section>
	  </aside>
	</div>
	
OK~再來編輯**app/assets/stylesheets/custom.css.scss** 加上

	/* sidebar */
	
	aside {
	  section {
	    padding: 10px 0;
	    border-top: 1px solid $grayLighter;
	    &:first-child {
	      border: 0;
	      padding-top: 0;
	    }
	    span {
	      display: block;
	      margin-bottom: 3px;
	      line-height: 1;
	    }
	    h1 {
	      font-size: 1.6em;
	      text-align: left;
	      letter-spacing: -1px;
	      margin-bottom: 3px;
	    }
	  }
	}
	
	.gravatar {
	  float: left;
	  margin-right: 10px;
	}


# Sign up 表格

因為這邊我們要開始用表格，讓user註冊！

所以我們必須先

	$ bundle exec rake db:reset
	$ bundle exec rake db:test:prepare
	
再來寫測試吧！

在****加到describe "User pages" block裡面

	describe "signup" do
	
	    before { visit signup_path }
	
	    let(:submit) { "Create my account" }
	
	    describe "with invalid information" do
	      it "should not create a user" do
	        expect { click_button submit }.not_to change(User, :count)
	      end
	    end
	
	    describe "with valid information" do
	      before do
	        fill_in "Name",         with: "Example User"
	        fill_in "Email",        with: "user@example.com"
	        fill_in "Password",     with: "foobar"
	        fill_in "Confirmation", with: "foobar"
	      end
	
	      it "should create a user" do
	        expect { click_button submit }.to change(User, :count).by(1)
	      end
	    end
	  end

**expect { click_button submit }.not_to change(User, :count)**這句話是因為當目前沒有user註冊的時候，理論上User.count的結果不會變！

因為let的關係，所以submit等同於"Create my account"

在執行**click_button "Create my account"**的前後，都會執行User.count

那個**not_to**等於 == 

所以上面那句話就等同於

	initial = User.count
	click_button "Create my account"
	final = User.count
	initial.should == final
	
現在執行測試應該就會pass了！

### Using form_for 

來編輯**app/views/users/new.html.erb**

	<%= provide(:title, 'Sign up') %>
	<h1>Sign up</h1>
	
	<div class="row">
	  <div class="span6 offset3">
	    <%= form_for(@user) do |f| %>
	
	      <%= f.label :name %>
	      <%= f.text_field :name %>
	
	      <%= f.label :email %>
	      <%= f.text_field :email %>
	
	      <%= f.label :password %>
	      <%= f.password_field :password %>
	
	      <%= f.label :password_confirmation, "Confirmation" %>
	      <%= f.password_field :password_confirmation %>
	
	      <%= f.submit "Create my account", class: "btn btn-large btn-primary" %>
	    <% end %>
	  </div>
	</div>
	
那個f是 一般都稱作是form

他是Rails內建的helper，他有很多關於html 表格元件好用的東東

例如：
	
	<%= f.label :name %>
	<%= f.text_field :name %>

會產生

	<label for="user_name">Name</label>
	<input id="user_name" name="user[name]" size="30" type="text" />
	
又例如：

	<%= f.password_field :password %>
	
會產生

	<input id="user_password" name="user[password]" size="30" type="password" />
	
再來重要的是**form_for**，Rails製作form標籤，利用@user物件，因為每個Ruby物件知道自己的class，Rails就會知道@user是屬於user class，又因為@user 是要新增使用者，Rails知道要使用"post"這個方法


讓我們來跑個測試吧！

	$ bundle exec rspec spec/requests/user_pages_spec.rb -e "signup page"
	
加上-e是規定跑的example就是 描述符合"signup page"的

這會有Fail因為@user目前是空的！

所以我們在
**app/controllers/users_controller.rb**
的 def new 這個block加上

	@user = User.new
	

來美觀一下吧！
加到**app/assets/stylesheets/custom.css.scss**

	/* forms */
	
	input, textarea, select, .uneditable-input {
	  border: 1px solid #bbb;
	  width: 100%;
	  padding: 10px;
	  height: auto;
	  margin-bottom: 15px;
	  @include box_sizing;
	}

## 註冊失敗

希望當user點下submit時，會觸發create的動作，他會使用**User.new**新增使用者，並嘗試儲存，如果註冊失敗，還會render一次註冊網頁給你

所以我們可以這樣寫在**app/controllers/users_controller.rb**

	
	  def create
	      @user = User.new(params[:user])
	      if @user.save
	        # Handle a successful save.
	      else
	        render 'new'
	      end
	    end
    

你一定好奇，到底param裡面有啥

先隨意create一個錯誤的user來看看 log

	user:
	  name: Foo Bar
	  password_confirmation: foo
	  password: bar
	  email: foo@invalid
	commit: Create my account
	action: create
	controller: users

在這個post到signup 表格的case，params事實上包含了 許多hash，從上面那個就知道了！

這些值關鍵都是從view那邊拿來的，例如

email就是從

	<input id="user_email" name="user[email]" size="30" type="text" />
	
name那個屬性的值，雖然我們在log上看到的是string，實際上，在rails上

他是使用symbol！所以

param[:user] 就是user屬性的hash表，

所以**@user = User.new(params[:user])**等於

	@user = User.new(name: "Foo Bar", email: "foo@invalid",
	                 password: "foo", password_confirmation: "bar")
	                 
那個
	
	<%= form_for(@user) do |f| %>
  	<%= f.label :name %>
  	<%= f.text_field :name %>
  	.
  	.
  	.
  	
 form_for 他會自動把使用者輸入的值，丟給@user物件！ 酷吧！
 
 
 OK~再來執行
 
 	$ bundle exec rspec spec/requests/user_pages_spec.rb -e "signup with invalid information"
 
就會pass了！！！

### Signup error messages

事實上，如果你輸入錯誤的值，在**errors.full_message**是擁有所有錯誤訊息的！那我們要怎麼把它加到view勒

很簡單，我們加到**app/views/users/new.html.erb**

	<% provide(:title, 'Sign up') %>
	<h1>Sign up</h1>
	
	<%= form_for(@user) do |f| %>
	  <%= render 'shared/error_messages' %>
	  .
	  .
	  .
	<% end %>		              
	
注意這邊！ render 一個partial，叫做是
**shared/error_messages** 意思就是我們要自己寫一個！

請新增一個檔案
**app/views/shared/_error_messages.html.erb**

	<% if @user.errors.any? %>
	  <div id="error_explanation">
	    <div class="alert alert-error">
	      The form contains <%= pluralize(@user.errors.count, "error") %>.
	    </div>
	    <ul>
	    <% @user.errors.full_messages.each do |msg| %>
	      <li>* <%= msg %></li>
	    <% end %>
	    </ul>
	  </div>
	<% end %>


那個any?是甚麼意思 請看

	>> [].empty?
	=> true
	>> [].any?
	=> false
	>> a.empty?
	=> false
	>> a.any?
	=> true

那個**pluralize**是一個text helper他的功能就是 請看！


	>> include ActionView::Helpers::TextHelper
	>> pluralize(1, "error")
	=> "1 error" 
	>> pluralize(5, "error")
	=> "5 errors"
	>> pluralize(2, "woman")
	=> "2 women"
	>> pluralize(3, "erratum")
	=> "3 errata"
	
酷吧！


來美觀一下吧

在 **app/assets/stylesheets/custom.css.scss** 裡頭的/\* forms */


	#error_explanation {
	  color:#f00;
	  ul {
	    list-style: none;
	    margin: 0 0 18px 0;
	  }
	}
	
	.field_with_errors {
	  @extend .control-group;
	  @extend .error;
	 }
	 
這邊有個很怪的地方.field_with_errors是打哪來的?

請看這句話， In addition, on error pages Rails automatically wraps the fields with errors in divs with the CSS class field_with_errors. 

## Signup success

換到如果註冊成功的部分,

先跑一下測試～照理說會失敗～

	$ bundle exec rspec spec/requests/user_pages_spec.rb -e "signup with valid information"
	
事實上，這邊我們少了一些東西，來改**app/controllers/users_controller.rb**吧～

	def create
	    @user = User.new(params[:user])
	    if @user.save
	      redirect_to @user
	    else
	      render 'new'
	    end
	  end
	
## Flash

在發佈code之前，我們來看一下flash的功能

	$ rails console
	>> flash = { success: "It worked!", error: "It failed." }
	=> {:success=>"It worked!", error: "It failed."}
	>> flash.each do |key, value|
	?>   puts "#{key}"
	?>   puts "#{value}"
	>> end
	success
	It worked!
	error
	It failed.

沒錯flash他有個key(就是success和error)和value的對應！我們來試著把它用到 **app/views/layouts/application.html.erb** 裡面

	<!DOCTYPE html>
	<html>
	  <head>
	    <title><%= full_title(yield(:title)) %></title>
	    <%= stylesheet_link_tag    "application", media: "all" %>
	    <%= javascript_include_tag "application" %>
	    <%= csrf_meta_tags %>
	    <%= render 'layouts/shim' %>    
	  </head>
	  <body>
	    <%= render 'layouts/header' %>
	    <div class="container">
		 <% flash.each do |key, value| %>
		 <div class="alert alert-<%= key %>"><%= value %></div>
		  <% end %>
	      <%= yield %>
	      <%= render 'layouts/footer' %>
		  <%= debug(params) if Rails.env.development? %>
	    </div>
	  </body>
	</html>
	
yap~~所以我們在create就可以加點東東

如果儲存成功就跟她說歡迎之類的～

	def create
	      @user = User.new(params[:user])
	      if @user.save
	         flash[:success] = "Welcome to the Sample App!"
	        refirect_to @user
	      else
	        render 'new'
	      end
	    end
	 
耶～
別忘了
更新一下資料庫！開始測試吧


	＄ bundle exec rake db:reset
	＄ bundle exec rake db:test:prepare
	
耶～～～可以deploy了！

## Deploying to production with SSL

	$ git add .
	$ git commit -m "Finish user signup"
	$ git checkout master
	$ git merge sign-up
	
因為我們希望deploy成product版本時，要用ssl 保護！

所以我們要在
**config/environments/production.rb**

加上一句(其實就是把#號拿掉就好)

	config.force_ssl = true
之後執行

	$ git commit -am "Add SSL in production"
	$ git push heroku
	$ heroku run rake db:migrate


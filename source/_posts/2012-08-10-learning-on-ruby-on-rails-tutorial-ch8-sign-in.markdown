---
layout: post
title: "Learning on Ruby on Rails Tutorial-CH8 Sign in"
date: 2012-08-10 11:05
comments: true
categories: ["Reading" , "Ruby on Rails"] 
---
上一章已經可以成功註冊使用者，接下來就是要到登入登出的部分！

一樣在開始之前，我們先開Branch

	$ git checkout -b sign-in-out
	
## Session 和登入錯誤

Session 就是半永久存在於兩台電腦，就像用戶端跑browser和伺服器端跑rails

我們會使用session來實作"Sign in"還有"forgetting"(當你關掉瀏覽器)，"remember me"這個check box保存session，"forever"（除非使用者自己清，不然會一直保存）

我們可以把session看成RESTful resource的觀念，我們有一個登入的頁面，登入成功時他會有新的session，當他登出時， session會被清掉。不像User那樣，他會利用後端資料庫保存資料，然而session是使用**cookie**(是user瀏覽器那邊一小塊文字)。Sign in會用到的動作，大多都是基於**cookie**的認證機制！

<!--more--> 

### Session Controller 

Sign in 是由new動作來處理，事實上送出"POST"這個要求給create 動作

Sign out 是送出"DELETE"這個要求給destroy動作

所以先來gen一些東東出來吧

	$ rails generate controller Sessions --no-test-framework
	$ rails generate integration_test authentication_pages
	

先想一下，我們需要什麼樣的頁面在Sign in的頁面

首先，我們要有一個叫做**signin_path**的鏈結，可以連到認證的頁面，我們還希望有個h1的標簽，他的文字是Sing in ，還有一個標簽叫做title，文字也是Sign in

所以測試程式是

**spec/requests/authentication_pages_spec.rb**

	require 'spec_helper'
	
	describe "Authentication" do
	
	  subject { page }
	
	  describe "signin page" do
	    before { visit signin_path }
	
	    it { should have_selector('h1',    text: 'Sign in') }
	    it { should have_selector('title', text: 'Sign in') }
	  end
	end
	
執行一下確保"有"錯誤

	$ bundle exec rspec spec/
	
先寫route的部份，因為剛剛有提到只有在create , new 和 destryo有使用到session,所以加上下面的東東在**config/routes.rb**

	resources :sessions, only: [:new, :create, :destroy]
	
	match '/signup', to: 'users#new'
  	match '/signin',  to: 'sessions#new'
  	match '/signout', to: 'sessions#destroy', via: :delete
  	
 
注意那個**via: :delete**這句話就是表示當使用HTTP Delete的要求時，他會被呼叫！

上面那些所得到的URIs就是

HTTP request
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
URI	
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Named route	
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Action	
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Purpose

*===============================*

GET	
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
/signin
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
signin_path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
new	page for a new session (signin)

POST
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
/sessions
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
sessions_path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
create
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
create a new session

DELETE
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
/signout
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
signout_path
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
destroy	delete a session (sign out)
	
加了route之後，再來加上controller的部份
**app/controllers/sessions_controller.rb**

	class SessionsController < ApplicationController
	
	  def new
	  end
	
	  def create
	  end
	
	  def destroy
	  end
	end

先來新增並寫**app/views/sessions/new.html.erb**

	<% provide(:title, "Sign in") %>
	<h1>Sign in</h1>
	
再來執行看看測試程式

	$ bundle exec rspec spec/
	
## 登入測試

先講需求，我們希望當使用者輸入錯誤帳號密碼時，會跳出error message也會跳回Sign in 的頁面(底下可以有一個連結，連到**create new user**)

我們需要這句測試～ 

	it { should have_selector('div.alert.alert-error', text: 'Invalid') }
	
上面那句話 **div.alert.alert-error**代表了

	<div class="alert alert-error">Invalid….</div>

這樣就可以達成我們要的規格

OK~把下面那一段加到 **describe "Authentication" do**這個區塊內

	describe "sign in" do 
	    before { visit signin_path }
	    
	    describe "with invalid information" do 
	      before { click_button  "Sign in" }
	      
	      it { should have_selector('title',text: 'Sign in' ) }
	      it { should have_selector('div.alert.alert-error' , text: 'Invalid') }
	    end
	  end

接下來，我們來看一下如果登入成功的話，希望可以看到的頁面

* 出現，一個鏈結到profile頁面
* 出現，登出的連結
* 登入的連結消失

所以寫測試！把下面的加到**describe "sign in" do**這個區塊內

	describe "with valid information" do
	      let(:user) { FactoryGirl.create(:user) }
	      before do
	        fill_in "Email",    with: user.email
	        fill_in "Password", with: user.password
	        click_button "Sign in"
	      end
	
	      it { should have_selector('title', text: user.name) }
	      it { should have_link('Profile', href: user_path(user)) }
	      it { should have_link('Sign out', href: signout_path) }
	      it { should_not have_link('Sign in', href: signin_path) }
	    end
	    

這邊使用到一個新的方法 叫做是**have_link**,然後有個屬性叫做是 :href

應該懂吧～XD，這是要確保我的標籤**a**會有正確的鏈結

## 登入表格

還記不記得先前寫的**app/views/users/new.html.erb**

其實登入表格就像那樣～

但是不同的地方在於，create user時表格的結果是給**@user**的，但是這個登入表格是要給**session**的

OK我們來寫吧

**app/views/sessions/new.html.erb**

	<% provide(:title, "Sign in") %>
	<h1>Sign in</h1>
	
	<div class="row">
	  <div class="span6 offset3">
	    <%= form_for(:session, url: sessions_path) do |f| %>
	
	      <%= f.label :email %>
	      <%= f.text_field :email %>
	
	      <%= f.label :password %>
	      <%= f.password_field :password %>
	
	      <%= f.submit "Sign in", class: "btn btn-large btn-primary" %>
	    <% end %>
	
	    <p>New user? <%= link_to "Sign up now!", signup_path %></p>
	  </div>
	</div>
	
我們可以得知**params**這個hash，大概就有這些內容**params[:session][:email]**和**params[:session][:password]**

## 重新看一下提交表格的部分

先在**app/controllers/sessions_controller.rb**加上

	def create
		render 'new'
	end

奇怪…怎麼點Sign in並沒有跳出…原來是因為我還沒有改一個東西

**app/views/layouts/_header.html** 其中Sign in 要改成這樣

	<li><%= link_to "Sign in", signin_path %></li>

接著我們來看controller的create動作！

當使用者登入時，就會create 一個session，然後如果登入成功的話，我們要把他轉到他的show page下面

如果登入失敗的話，我們要重新render登入畫面給他！並告訴他訊息！

所以....

	def create
	  user = User.find_by_email(params[:session][:email])
	  if user && user.authenticate(params[:session][:password])
	    # Sign the user in and redirect to the user's show page.
	  else
	    # Create an error message and re-render the signin form.
	  end
	end
	
用**&&**的原因是只要有一個失敗 就是Fail一個是找不到User一個是密碼錯誤！

## Rendering with flash message

之前在第七章，有看到flash的用法，這邊不在贅述

加到**app/controllers/sessions_controller.rb**裡面

	def create
	    user = User.find_by_email(params[:session][:email])
	    if user && user.authenticate(params[:session][:password])
	      # Sign the user in and redirect to the user's show page.
	    else
	      flash[:error] = 'Invalid email/password combination' # Not quite right!
	      render 'new'
	    end
	  end
	 
OK~這時候可以玩玩網頁～隨便輸入錯誤的賬號密碼，他果然有跳出錯誤訊息....但是…見鬼了！當你點其他頁面時，錯誤訊息並不會消失～

不過當你執行

	$ bundle exec rspec spec/requests/authentication_pages_spec.rb -e "sign in with invalid information"
	
他會pass歐！！

但是實際上這是有bug的....所以我們必須要加上測試的東東，確保他沒有問題

加在**spec/requests/authentication_pages_spec.rb**的**describe "with invalid information" do**區塊裡面
	
	describe "after visiting another page" do
	  before { click_link "Home" }
	  it { should_not have_selector('div.alert.alert-error') }
	end
 

在執行一次，發現有錯誤了！

	$ bundle exec rspec spec/requests/authentication_pages_spec.rb -e "sign in with invalid information"
	
OK~ 那我們怎麼樣改掉這個bug，很簡單....只要在**flash[:error]**多加一個now即可阿！

	 def create
	    user = User.find_by_email(params[:session][:email])
	    if user && user.authenticate(params[:session][:password])
	      # Sign the user in and redirect to the user's show page.
	    else
	      flash.now[:error] = 'Invalid email/password combination'
	      render 'new'
	    end
	  end



## 登入成功！

接下來就是一連串困難的開始！

一開始是比較簡單的部分，當使用者登入成功時，我們要將它導到**user**頁面

所以在**app/controllers/sessions_controller.rb**加入

	def create
	    user = User.find_by_email(params[:session][:email])
	    if user && user.authenticate(params[:session][:password])
	      sign_in user
	      redirect_to user
	    else
	      flash.now[:error] = 'Invalid email/password combination'
	      render 'new'
	    end
	  end
	  
### 記住我

現在開始開發signin的model部分，因為Sing 這個動作是屬於跨MVC會被用到的東西(譬如controller和view)，所以我們建了一個**SessionsHelper**，這個會自動被include到Rails的view，如果希望在所有controller被使用的話，那就是在**app/controllers/application_controller.rb**加上

	include SessionsHelper

在開始寫之前，先來看一些現象

因為HTTP 是一個stateless的協定，網頁應用需要使用者登入，必須實作追蹤每個使用者的動態，一個簡單方法是使用傳統Rails的session，儲存**remember token**讓它等於使用者id

	session[:remember_token] = user.id
	
所以我們可以在每個頁面用下面那句話，很簡單的找到user

	User.find(session[:remember_token])
	
對於我們的網頁的規劃是，我們可以讓user永久保留session，所以我們需要使用一個*permanent*的標籤，所以要gen一個獨特、機密的記錄token並且記錄他當成永久cookie(除非browser被清掉)，這個記錄需要和user相關，而且還要留存到之後，所以....我們需要在model上加點東西！再加之前我們來來寫測試吧！

**spec/models/user_spec.rb**加上

	it { should respond_to(:remember_token) }
	
為了通過測試！ 我們要下

	$ rails generate migration add_remember_token_to_users
	
在**db/migrate/[timestamp]_add_remember_token_to_users.rb**寫下

	class AddRememberTokenToUsers < ActiveRecord::Migration
	  def change
	    add_column :users, :remember_token, :string
	    add_index  :users, :remember_token
	  end
	end

別忘了

	$ bundle exec rake db:migrate
	$ bundle exec rake db:test:prepare
	
加完這些後，測試應該是可以通過的～

	$ bundle exec rspec spec/models/user_spec.rb
	
現在我們要來決定要拿什麼東西當作是remember token , 基本上就要用很多亂數的字串組成，當然也可以使用密碼(**password_hash**)，但是這會讓使用者暴露在外，造成不必要的困擾，所以！！！小心起見，我們都會製作客制化的token，利用！！！**urlsafe_base64**方法（來自**SecureRandom**這個module），他會製作url使用的Base64字串

再來，我們會使用callback(before_save)來作token（藉由email的獨特性！），在使用者存檔前，做create **remember_token**這個動作

OK來寫測試！

**spec/models/user_spec.rb** 加到**describe User do**區塊內

	describe "remember token" do
	    before { @user.save }
	    its(:remember_token) { should_not be_blank }
	  end 
	  
這邊要說一下那個**its**就像是**it**但他有的特殊的含義！

舉例一下

	its(:remember_token) { should_not be_blank }
	
就等於

	it { @user.remember_token.should_not be_blank }


OK來寫callback在**app/models/user.rb**

	before_save :create_remember_token

	private
	  def create_remember_token
	    self.remember_token = SecureRandom.urlsafe_base64
	  end

這邊我們使用**self**是因為我們希望User物件本身的remember_token被設定為值

OK~因為在before_save時已經有塞值給他了，所以現在跑測試應該可以通過

	$ bundle exec rspec spec/models/user_spec.rb
	
## Sing_in 這個在Helper的方法

就之前的設計概念，希望可以將紀錄的token當成cookie放在使用者的瀏覽器！

然後透過這個token找到這個使用者在我們網站上的紀錄！ 所以我們sign_in就是要做這件事情

所以接下來要講個很酷的東東 請先看code

**app/helpers/sessions_helper.rb**

	module SessionsHelper
	
	  def sign_in(user)
	    cookies.permanent[:remember_token] = user.remember_token
	    current_user = user
	  end
	end

我們可以來看一下cookie內容長什麼樣子

	cookies[:remember_token] = { value:   user.remember_token,
                             expires: 20.years.from_now.utc }
                          
其實是因為我們使用**cookies.permanent**所以預設失效時間是二十年後！

所以我們在使用上就可以這樣找User

	User.find_by_remember_token(cookies[:remember_token])
	
也許你會注意到，如果在使用者的瀏覽器記錄登入cookie，並且傳輸透明在應用上，可能會被使用

**session hijacking**攻擊，那其實解決方法就是使用ssl

## 目前的使用者

來看一下剛剛那個檔案

	module SessionsHelper

	  def sign_in(user)
	    cookies.permanent[:remember_token] = user.remember_token
	    current_user = user
	  end
	end

我們來看這句

	current_user = user
	
這個我們希望他可以在controller和view都可以被存取

就像
		
	<%= current_user.name %> 和 redirect_to current_user
	
所以....我們在**app/helpers/sessions_helper.rb**加上


	def current_user=(user)
    	@current_user = user
  	end	
  	

這邊有點奇特，就是那個**current_user=(...)**其實等同於 **current_user = …**

接下來，我們來寫一個funcion使可以取得current_user的，你會發現長的跟上面好像

	def current_user
    	@current_user     # Useless! Don't use this line.
  	end
  	
 但是一般來說我們不會這樣用～
 
 因為這樣做，我們乾脆就用**attr_accessor**就好～ 不過…其實這完全沒有解決問題，使用者的登入狀態，會被忘記～～所以當他從一個頁面跳到另一個頁面，session就會失效～～
 
 所以我們會這樣做！
 
 	 def current_user
    	@current_user ||= user_from_remember_token
  	 end
  	 
 	 private 
 	 
 	 	def user_from_remember_token
      		remember_token = cookies[:remember_token]
      		User.find_by_remember_token(remember_token) unless remember_token.nil?
    	end
    	

那個 **@current_user ||= user_from_remember_token** 等同於

@current_user = @current_user || user_from_remember_token 

### 改變layout的連結

我們需要一個類似 **signed_in?** 

可以讓我們用在 view那邊 

	<% if signed_in? %>
	  # Links for signed-in users
	<% else %>
	  # Links for non-signed-in-users
	<% end %>
	
所以我們在**app/helpers/sessions_helper.rb**加上

	def signed_in?
	    !current_user.nil?
	end

這句話的意思是，當現在使用者是空的嗎？如果是的話，singed_in?就是true , 反之

有了這個之後～我們view就有很多要改的

**app/views/layouts/_header.html.erb**

	<header class="navbar navbar-fixed-top">
	  <div class="navbar-inner">
	    <div class="container">
	      <%= link_to "sample app", root_path, id: "logo" %>
	      <nav>
	        <ul class="nav pull-right">
	          <li><%= link_to "Home", root_path %></li>
	          <li><%= link_to "Help", help_path %></li>
	          <% if signed_in? %>
	            <li><%= link_to "Users", '#' %></li>
	            <li id="fat-menu" class="dropdown">
	              <a href="#" class="dropdown-toggle" data-toggle="dropdown">
	                Account <b class="caret"></b>
	              </a>
	              <ul class="dropdown-menu">
	                <li><%= link_to "Profile", current_user %></li>
	                <li><%= link_to "Settings", '#' %></li>
	                <li class="divider"></li>
	                <li>
	                  <%= link_to "Sign out", signout_path, method: "delete" %>
	                </li>
	              </ul>
	            </li>
	          <% else %>
	            <li><%= link_to "Sign in", signin_path %></li>
	          <% end %>
	        </ul>
	      </nav>
	    </div>
	  </div>
	</header>
	
這邊有幾個酷炫的地方

1. <%= link_to "Sign out", signout_path, method: "delete" %>

	這個會pass一個hash參數，告訴提交一個HTTP DELETE 要求 

2. <%= link_to "Profile", current_user %>
	
	因為Rails會讓你自動幫你用成user_path(current_user)
	

然後那個裡頭**<li id="fat-menu" class="dropdown">** 是由Bootstrap's Javascript Library提供～

所以我們要在 **app/assets/javascripts/application.js** 加上

	//= require bootstrap
	
### Sign up 之後就是Sign in 

先寫測試，把這個加到**spec/requests/user_pages_spec.rb**的**describe "after saving the user" do**裡

	it { should have_link('Sign out') }

還有在**app/controllers/users_controller.rb**加上一句話**sign_in @user**
	
	def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  	end
	
這樣 就完成了～～


### Sign out

一樣先寫測試～不過這次要換成destroy 在**spec/requests/authentication_pages_spec.rb**

的**describe "with valid information" do**的區塊加上

	describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
      
在**app/controllers/sessions_controller.rb**寫上

	def destroy
	    sign_out
	    redirect_to root_path
	  end
	  
因為我們還沒有sign_out所以…要在helper寫～主要就是要讓current_user變成空的～然後把cookie刪掉

所以在**app/helpers/sessions_helper.rb**寫下

	def sign_out
    	current_user = nil
    	cookies.delete(:remember_token)
  	end

我發現一個怪怪的地方～那就是**/spec/requests/user_pages_spec.rb** 裡頭有個**describe "after saving the user" do**

我居然找不到！ 結果在CH7底下練習找到

所以我補充一下剛剛那個**spec/requests/user_pages_spec.rb**

describe "after saving the user" do
                before { click_button submit }
                let(:user) { User.find_by_email('user@example.com') }
                it { should have_selector('title', text: user.name) }
                it { should have_selector('div.alert.alert-success', text: 'Welcome') }
                it { should have_link('Sign out') }
        end

OK~大功告成！

ps. 我跳過[Introduction to Cucumber](http://ruby.railstutorial.org/chapters/sign-in-sign-out?version=3.2#sec:cucumber)

	$ git add .
	$ git commit -m "Finish sign in"
	$ git checkout master
	$ git merge sign-in-out

---
layout: post
title: "Learning on Ruby on Rails Tutorial-CH9 Updating , Showing , and deleting users"
date: 2012-08-10 11:07
comments: true
categories: [ "Reading" , "Ruby on Rails" ]
---
 這章會完成Users的REST動作，**edit**、**update**、**index**、**destroy**
 
 廢話不多說，從做中學！
 
 	$ git checkout -b updating-users
 	
 
##修改使用者

修改其實很像新增，和新增不同的地方在於

new是對server提出POST的要求，但是update這個動作是提出PUT這個要求

還有一個最大的差別，就是所有人都可以註冊，但是update動作，只能給已經登入的user使用！

<!--more--> 

## Edit 表格

直接來看測試！把它加到**describe "User pages" do**區塊內

**spec/requests/user_pages_spec.rb**

	describe "edit" do
	    let(:user) { FactoryGirl.create(:user) }
	    before { visit edit_user_path(user) }
	
	    describe "page" do
	      it { should have_selector('h1',    text: "Update your profile") }
	      it { should have_selector('title', text: "Edit user") }
	      it { should have_link('change', href: 'http://gravatar.com/emails') }
	    end
	
	    describe "with invalid information" do
	      before { click_button "Save changes" }
	
	      it { should have_content('error') }
	    end
	  end

要編輯使用者之前一定要知道誰是使用者

別忘了可以使用params[:id]

所以我們在controller的地方可以加上這句話，**app/controller/users_controller.rb**

	def edit
		@user = User.find(params[:id])
	end


再來新增view 

**app/views/users/edit.html.erb**

	<% provide(:title, "Edit user") %> 
	<h1>Update your profile</h1>
	
	<div class="row">
	  <div class="span6 offset3">
	  <%= form_for(@user) do |f| %>
	      <%= render 'shared/error_messages', object: f.object %>
	
	      <%= f.label :name %>
	      <%= f.text_field :name %>
	
	      <%= f.label :email %>
	      <%= f.text_field :email %>
	
	      <%= f.label :password %>
	      <%= f.password_field :password %>
	
	      <%= f.label :password_confirmation, "Confirm Password" %>
	      <%= f.password_field :password_confirmation %>
	
	      <%= f.submit "Save changes", class: "btn btn-large btn-primary" %>
	    <% end %>
	
	    <%= gravatar_for @user %>
	    <a href="http://gravatar.com/emails">change</a>
	  </div>
	</div>


跑看看測試吧～

	$ bundle exec rspec spec/requests/user_pages_spec.rb -e "edit page"
	

嘿嘿～ 你一定會好奇…奇怪....他跟new幾乎長得一模一樣

那Rails怎麼知道他是要用**POST**還是**PUT**?

其實他是用Active Record的一個方法：**new_record?** 

很簡單的驗證方法

	$ rails console
	>> User.new.new_record?
	=> true
	>> User.first.new_record?
	=> false
	
	
接著我們來新加另外一個測試的東西，在**spec/requests/authentication_pages_spec.rb**

加上使用者用正確資料登入時，會有一個新的**Setting**的鏈結可以選

	it { should have_link('Settings', href: edit_user_path(user)) }
	
在下面那些底下

	 it { should have_selector('title', text: user.name) }
	 it { should have_link('Profile', href: user_path(user)) }
	 it { should have_link('Sign out', href: signout_path) }
	 it { should_not have_link('Sign in', href: signin_path) }	
還有一個地方要改～請把

	before do
      fill_in "Email",    with: user.email
      fill_in "Password", with: user.password
      click_button "Sign in"
    end
 
改成一句話！

	before { sign_in user }


用一個helper來取代！把這個helper寫在**spec/support/utilities.rb**

	def sign_in(user)
	  visit signin_path
	  fill_in "Email",    with: user.email
	  fill_in "Password", with: user.password
	  click_button "Sign in"
	  # Sign in when not using Capybara as well.
	  cookies[:remember_token] = user.remember_token
	end

為了要確保Capybara有work

所以才加上

	cookies[:remember_token] = user.remember_token

還要把**Setting**的連結加到**header**上面

也就是要改**app/views/layouts/_header.html.erb**

把
	
	<li><%= link_to "Settings", '#' %></li>
	
改成

	<li><%= link_to "Settings", edit_user_path(current_user) %></li>
	

##不成功的編輯

當使用者編輯好，按下submit，會到controller的**update**動作執行，

所以User會使用他的update_attributes方法更新內容！

所以我們就用這個特性！

如果使用者編輯不成功的話，我們要在重新render給他**edit**頁面

所以來改**app/controllers/users_controller.rb**

	def update
	    @user = User.find(params[:id])
	    if @user.update_attributes(params[:user])
	      # Handle a successful update.
	    else
	      render 'edit'
	    end
	  end
 
## 成功的編輯

接著我們要來寫編輯的測試！

在**spec/requests/user_pages_spec.rb**的**describe "edit" do**區塊內加上

	 describe "with valid information" do
	      let(:new_name)  { "New Name" }
	      let(:new_email) { "new@example.com" }
	      before do
	        fill_in "Name",             with: new_name
	        fill_in "Email",            with: new_email
	        fill_in "Password",         with: user.password
	        fill_in "Confirm Password", with: user.password
	        click_button "Save changes"
	      end
	
	      it { should have_selector('title', text: new_name) }
	      it { should have_selector('div.alert.alert-success') }
	      it { should have_link('Sign out', href: signout_path) }
	      specify { user.reload.name.should  == new_name }
	      specify { user.reload.email.should == new_email }
	    end
	    
那個比較特別的就是

	specify { user.reload.name.should  == new_name }
	specify { user.reload.email.should == new_email }
	
利用**user.reload**去重新讀取user的資料

OK 來寫其他東東

先來補上**app/controllers/users_controller.rb**

	if @user.update_attributes(params[:user])
	        flash[:success] = "Profile updated"
	        sign_in @user
	        redirect_to @user
	        
sign_in再一次是因為當使用者儲存時，紀錄的token被重新設定，(**before_save :create_remember_token**)

所以我們要在重啓一次sesion！這是很好的安全設計～

跑一次測試～確保都有pass!

## 授權 (注意！不是認證歐XD)

我們在CH8已經寫過認證了！現在來實作授權，認證(*authentication*)是讓我們驗證使用者是可以使用網站的！授權(*authorization*)是讓我們控制使用者可以做什麼事情！

### 要求使用者必須登入

編輯測試先，主要是edit和update動作，必須要在登入時才可以用！測試寫在認證那邊就ＯＫ了，直接加到**describe "Authentication do"**裡面

**spec/requests/authentication_pages_spec.rb**

	describe "authorization" do
	
	    describe "for non-signed-in users" do
	      let(:user) { FactoryGirl.create(:user) }
	
	      describe "in the Users controller" do
	
	        describe "visiting the edit page" do
	          before { visit edit_user_path(user) }
	          it { should have_selector('title', text: 'Sign in') }
	        end
	
	        describe "submitting to the update action" do
	          before { put user_path(user) }
	          specify { response.should redirect_to(signin_path) }
	        end
	      end
	    end
	    
	    
這邊比較特別的就是，不使用**Capybara**的visit方法存取controller！ 而是直接使用HTTP 要求！ 所以這邊是使用**put**

put會要求直接到**/users/1**並且是update的動作，這是必要的因為沒有方法讓瀏覽器，直接visit **update**動作！只能透過提交edit 表格(Capybara也無法做到)，但是這樣是為了測edit的動作！並沒有針對update來測！所以才需要使用**put**

所以～因為我們使用**put**這個動作！所以底下那個

	specify { response.should redirect_to(signin_path) }
	
也是特別的！是使用response物件！不像Capybara的page物件！response讓我們測試伺服器的回應！

那所以要授權的程式碼，我們會使用**before_filter**這個callback，就是當使用者操作時，會讓某些特定的方法被呼叫

**app/controllers/users_controller.rb**

	class UsersController < ApplicationController
	  before_filter :signed_in_user, only: [:edit, :update]
	  .
	  .
	  .
	  private
	
	    def signed_in_user
	      redirect_to signin_path, notice: "Please sign in." unless signed_in?
	    end
	end
	
預設before_filter 是會用在所有動作的！但是我們可以用**only**這個來限制！

另外那個**notice: "Please sign in."** 他相當於會丟一個hash給**redirect_to**這個函式

相當於
	
	flash[:notice] = "Please sign in."
	redirect_to signin_path
	
注意歐！ 這邊用的是**:notice**，所以我們總共有**:success**和**:error**以及**:notice**

這些Bootstrap CSS都支援！

這邊跑一下測試！

	bundle exec rspec spec/
	
囧....怎麼錯誤變多，有9個錯誤！

原來是因為我們加了限制

在**spec/requests/user_pages_spec.rb**的

	describe "edit" do
	  let(:user) { FactoryGirl.create(:user) }
	  before { visit edit_user_path(user) }

我們還沒有登入 就開始visit編輯畫面....所以會有問題！

所以我們可以使用helper裡面的**sign_in**，改成這樣！

	let(:user) { FactoryGirl.create(:user) }
	    before do
	      sign_in user
	      visit edit_user_path(user)
	    end
	  
再執行一下 測試！ 恭喜！完成！

###要求正確的使用者

當然我們只要求使用者登入這樣是不夠的！我們還需要是正當的使用者，所以來設計測試，當使用者用錯誤email登入時，然後點**edit**或是**update**，因為這個使用者也不行嘗試去編輯別人的頁面，使用者若嘗試去編輯別人的頁面，我們就將它導到root URL

**spec/requests/authentication_pages_spec.rb**

寫在**describe "authorization" do**區塊裡面

	describe "as wrong user" do
	      let(:user) { FactoryGirl.create(:user) }
	      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
	      before { sign_in user }
	
	      describe "visiting Users#edit page" do
	        before { visit edit_user_path(wrong_user) }
	        it { should_not have_selector('title', text: full_title('Edit user')) }
	      end
	
	      describe "submitting a PUT request to the Users#update action" do
	        before { put user_path(wrong_user) }
	        specify { response.should redirect_to(root_path) }
	      end
	    end
	    
所以我先來修改**/app/controllers/users_controller.rb**

	before_filter :correct_user, only: [:edit , :update]
	
	private

    def signed_in_user
      redirect_to signin_path, notice: "Please sign in." unless signed_in?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
那個**current_user?**是寫在**app/helpers/session_helper.rb**

記得補上歐！

	def current_user?(user)
      user == current_user
  	end
  	
### 友善的轉址

雖然一切看是完美～但是，其實有一個問題，那就是當user每次要使用保護的頁面時，他完成登入後，他都會被導向他的個人頁面～而且不是他想要去的頁面！所以我們要來改善這問題

所以先來寫測試！我一開始會先到user的編輯頁面，然後理論上他會幫我導向登入畫面，當我完成登入之後，必須幫我導到編輯的頁面

**spec/requests/authentication_pages_spec.rb**

加在**describe "for non-signed-in users" do**裡面！

	describe "when attempting to visit a protected page" do
	                before do
	                  visit edit_user_path(user)
	                  fill_in "Email",    with: user.email
	                  fill_in "Password", with: user.password
	                  click_button "Sign in"
	                end
	
	                describe "after signing in" do
	
	                  it "should render the desired protected page" do
	                    page.should have_selector('title', text: 'Edit user')
	                  end
	                end
	        end
	        
	        

為了要完成這件事情！ 我們要使用兩個function！

把它寫在session helper裡面

**app/helpers/sessions_helper.rb**


	def redirect_back_or(default)
	    redirect_to(session[:return_to] || default)
	    session.delete(:return_to)
	end
	
	def store_location
	    session[:return_to] = request.fullpath
	end
	
Rails有提供**session**儲存的機制，(你就把它想成cookie物件)，另外我們也使用**request**物件，取得完整連結路徑(URI)，**store_location**就是把要求的完整路徑傳給**session**變數，他的key就是**:return_to**

所以要把**store_location**加到**signed_in_user**裡面，因為加在函式裡面，如果使用者不是登入狀態時，就要先把他想去的路徑先存起來，然後再把它導到登入畫面

那就來修改

**app/controllers/users_controller.rb**

	def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_path, notice: "Please sign in."
      end
    end
    
最後再來加個**app/controllers/sessions_controller.rb**

	def create
	    user = User.find_by_email(params[:session][:email])
	    if user && user.authenticate(params[:session][:password])
	      sign_in user
	      redirect_back_or user
	    else
	      flash.now[:error] = 'Invalid email/password combination'
	      render 'new'
	    end
  	end

就是當使用者按下登入，並且也登入成功時，就會在**session**這邊create一個token

所以我們在create這邊加上剛剛寫的**redirect_back_or**所以如果有記錄之前要去的url，他

就會前往那邊～不然的話，就是連到user的頁面

跑一下測試確認可以work

	$  bundle exec rspec spec/
	
## Show出所有使用者

簡單來說，希望可以看到每個user的資料(還附上連結)，最後還要加上換頁的東西！

### User Index

可以看到所有使用者這功能，必須限定是登入使用者，另外，要可以使用**users_path**這個連結看到所有使用者！

So…開始寫測試吧！

**spec/requests/authentication_pages_spec.rb** 寫在 **describe "in the Users controller" do**裡面

	describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
    end
    
因為我們要限定登入成功使用者才可以用！所以在**app/controllers/users_controller.rb**請補上

	before_filter :signed_in_user, only: [:index, :edit, :update]
	
	def index
	end
	
既然寫到了user controller當然要寫一下**spec/requests/user_pages_spec.rb**

加在 **describe "User pages" do**底下

	describe "index" do
	    before do
	      sign_in FactoryGirl.create(:user) 
	      FactoryGirl.create(:user, name: "Derek" , email: "Derek@example.com")
	      FactoryGirl.create(:user, name: "Edison" , email: "Edison@example.com")
	      visit users_path
	    end
	    
	    it { should have_selector('title',text: 'All users') }
	    it "should list each user" do 
	      User.all.each do |user|
	        page.should have_selector('li', text: user.name)
	      end
	    end
  	end
  	
 
為了要通過測試！讓我們開始補程式碼吧！

**app/controllers/users_controller.rb**的**index**請補上

	def index
    	@users = User.all
  	end


換到view的地方，先新增**app/views/users/index.html.erb**

	<%= provide(:title, 'All users') %>
	<h1>All users</h1>
	
	<ul class="users">
	  <% @users.each do |user| %>
	    <li>
	      <%= gravatar_for user, size: 52 %>
	      <%= link_to user.name, user %>
	    </li>
	  <% end %>
	</ul>
	
	
再來為user index加上一些CSS效果

**app/assets/stylesheets/custom.css.scss**

	/* users index */
	
	.users {
	  list-style: none;
	  margin: 0;
	  li {
	    overflow: auto;
	    padding: 10px 0;
	    border-top: 1px solid $grayLighter;
	    &:last-child {
	      border-bottom: 1px solid $grayLighter;
	    }
	  }
	}
	
那我們在認證的地方也要加上一個測試！確保Users這個link可以用

**spec/requests/authentication_pages_spec.rb**的**describe "with valid information" do**底下

	it { should have_link('Users',    href: users_path) }
	
補上URI到**app/views/layouts/_header.html.erb**

	<li><%= link_to "Users", '#' %></li>
	
改成
	
	<li><%= link_to "Users", users_path %></li>


耶～測試吧

	$ bundle exec rspec spec/
	
囧…有錯…奇怪..他說…gravatar_for 預設輸入參數只有一個，結果我給她兩個....

原來…是因為我沒有做CH7的練習，補上

讓我們可以改變顯圖的大小！

**app/helpers/users_helper.rb**

	def gravatar_for(user, options = { size: 50 })
    	gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    	size = options[:size]
    	gravatar_url = "http://gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    	image_tag(gravatar_url, alt: user.name, class: "gravatar")
  	end
	
再跑一次！恭喜～通過～
	
其實可以開網頁來看！ 你會發現....東西好少....好乾歐！

所以....


### User 樣本

我們要安裝並使用一個叫做是**faker**的gem

所以先在**Gemfile**加上

	gem 'faker', '1.0.1'
	
別忘了

	$ bundle install

要如何使用呢？ 

我們必須要加一個**Rake task**的東東去建樣本使用者！

Rake task通常被放在**lib/tasks**資料夾下

所以我們新增一個檔案吧！**lib/tasks/sample_data.rake**

	namespace :db do
	  desc "Fill database with sample data"
	  task populate: :environment do
	    User.create!(name: "Example User",
	                 email: "example@railstutorial.org",
	                 password: "foobar",
	                 password_confirmation: "foobar")
	    99.times do |n|
	      name  = Faker::Name.name
	      email = "example-#{n+1}@railstutorial.org"
	      password  = "password"
	      User.create!(name: name,
	                   email: email,
	                   password: password,
	                   password_confirmation: password)
	    end
	  end
	end



所以定義了一個任務 **db:populate**，透過**db:reset**會重設development資料庫！

然後會建置99個資料

這一行
	
	task populate: :environment do
	
確保Rake task 會被本地端的Rails環境存取(包含User model)，另外那個**create!**和**create**差在他會丟出例外原因，而不是只告訴你False

所以我們可以透過什麼方式調用(invoke)這個Rake task呢？

	$ bundle exec rake db:reset
	$ bundle exec rake db:populate
	$ bundle exec rake db:test:prepare
	
OK~我們就可以看到一堆user了！

### 分頁功能


看到那麼多user當然我們要加上分頁功能，這個之前在我另外的自我學習已經有練過了～所以我就快速帶過～

在**Gemfile**加上

	gem 'will_paginate', '3.0.3'
	gem 'bootstrap-will_paginate', '0.0.5'
	
別忘了

	$ bundle install
	
OK! 當然我們也要寫測試！

但是寫測試之前....有個問題，因為要測翻頁功能有work!

所以....是必我要寫像下面那樣一百遍嗎～歐不～～

	FactoryGirl.define do
	  factory :user do
	    name     "Michael Hartl"
	    email    "michael@example.com"
	    password "foobar"
	    password_confirmation "foobar"
	  end
	end
	
好佳在！

FactoryGirl有提供**sequence**的功能！

我們可以這樣用！

	factory :user do
  		sequence(:name)  { |n| "Person #{n}" }
  		sequence(:email) { |n| "person_#{n}@example.com"}   
	
它就會建出這樣的東東

	“Person 1”  “person_1@example.com”
	“Person 2”  “person_2@example.com”
	“Person 3”  “person_3@example.com”
	….等
	
	
所以我們可以定義FactoryGirl為**sequence**版本，把它改在

**spec/factories.rb**

	FactoryGirl.define do
	  factory :user do
	    sequence(:name)  { |n| "Person #{n}" }
	    sequence(:email) { |n| "person_#{n}@example.com"}   
	    password "foobar"
	    password_confirmation "foobar"
	  end
	end

然後開始寫測試摟～

**spec/requests/user_pages_spec.rb**

把

	describe "index" do
	    before do
	      sign_in FactoryGirl.create(:user) 
	      FactoryGirl.create(:user, name: "Derek" , email: "Derek@example.com")
	      FactoryGirl.create(:user, name: "Edison" , email: "Edison@example.com")
	      visit users_path
	    end
	    
	    it { should have_selector('title',text: 'All users') }
	    it "should list each user" do 
	      User.all.each do |user|
	        page.should have_selector('li', text: user.name)
	      end
	    end
	  end
	  
改成

	describe "index" do
	
	    let(:user) { FactoryGirl.create(:user) }
	
	    before do
	      sign_in user
	      visit users_path
	    end
	
	    it { should have_selector('title', text: 'All users') }
	
	    describe "pagination" do
	      before(:all) { 30.times { FactoryGirl.create(:user) } }
	      after(:all)  { User.delete_all }
	
	      it { should have_link('Next') }
	      its(:html) { should match('>2</a>') }
	
	      it "should list each user" do
	        User.all[0..2].each do |user|
	          page.should have_selector('li', text: user.name)
	        end
	      end
	    end
	  end
	  
	  
這裡面有些相當特別的code！

	its(:html) { should match('>2</a>') }

他的意思是 測試頁面有包含2…就這樣

ok要讓**pagination**可以用，我們來改**app/views/users/index.html.erb**

	<%= provide(:title, 'All users') %>
	<h1>All users</h1>
	
	<%= will_paginate %>
	
	<ul class="users">
	  <% @users.each do |user| %>
	    <li>
	      <%= gravatar_for user, size: 52 %>
	      <%= link_to user.name, user %>
	    </li>
	  <% end %>
	</ul>
	
	<%= will_paginate %>
	
	
主要是因為加上**will_paginate**

他會自動找尋@users這個物件，然後秀出換頁的連結

但是目前這個view是不work的！

因為**@users**是來自**User.all**，它是一個Array類別，但是**will_paginate**是預期物件是一個**ActiveRecord::Relation**

但是好佳在，我們可以使用**will_paginate**提供的**paginate**方法轉成**ActiveRecord::Relation**

	$ rails console
	>> User.all.class
	=> Array
	>> User.paginate(page: 1).class
	=> ActiveRecord::Relation
	
注意！那個paginate使用**:page**當成其hash的key，所以**User.paginate**從資料庫撈出的筆數就是依據**:page**這個值！

所以我們可以來改寫一下我controller

把 **@users = User.all**改成

	def index
      @users = User.paginate(page: params[:page])
  	end
  	
yap!執行一下測試！
 
	$ bundle exec rspec spec/
 
### Partial refactoring

因為我們測試已經完成～我們可以來改寫一下程式碼

善用Rails的一些特性！

先來改寫**app/views/users/index.html.erb**

	<% provide(:title, 'All users') %>
	<h1>All users</h1>
	
	<%= will_paginate %>
	
	<ul class="users">
	  <% @users.each do |user| %>
	    <%= render user %>
	  <% end %>
	</ul>
	
	<%= will_paginate %>

因為把它改寫成**render**

Rails會自動去搜尋**_user.html.erb**

所以要新建這個檔案**app/views/users/_user.html.erb**(注意歐！不是在layout底下歐)並加上

	<li>
	  <%= gravatar_for user, size: 52 %>
	  <%= link_to user.name, user %>
	</li>
	
但是更酷的是！ 你以為這樣就結束了？

其實可以再改寫**app/views/users/index.html.erb**

把這一句

	<% @users.each do |user| %>
	    <%= render user %>
	<% end %>

改成這一句就好！

	<%= render @users %>
	
因為Rails它會發現**@users**是**User**物件的list，當呼叫出users的collection時，Rails會自動幫你做迭代！當你每個值都丟到**_user.html.erb**裡面酷吧！

改完code，當然要跑測試～看有沒有改錯！

	$ bundle exec rspec spec/

## 刪除使用者

必須要是Administrator才可以刪除使用者

當然測試要驗證一下！

**spec/models/user_spec.rb**

在最前面補上

	it { should respond_to(:admin) }
	
	it { should_not be_admin }
	
	describe "with admin attribute set to 'true'" do
	    before { @user.toggle!(:admin) }
	
	    it { should be_admin }
	  end
	

這邊有個很酷的東西！

使用**toggle!**方法切換**admin**的屬性，不是true就是false，還有一個要注意！

	it { should be_admin }
	
這代表了我們必須有**admin?**這個回傳True或是False的函式！

如同往常！

我們必須先加上**admin**這個屬性！然後他是boolean類型

	$ rails generate migration add_admin_to_users admin:boolean
	
跑完之後~ 補上一些東西！

	class AddAdminToUsers < ActiveRecord::Migration
	  def change
	    add_column :users, :admin, :boolean, default: false
	  end
	end
	
加完要記得

	$ bundle exec rake db:migrate
	$ bundle exec rake db:test:prepare
	
然後我們用console把其中一個user改成admin來看看我們剛剛寫的那些東東work不work～

	$ rails console --sandbox
	>> user = User.first
	>> user.admin?
	=> false
	>> user.toggle!(:admin)
	=> true
	>> user.admin?
	=> true
	
最後一步驟，我們要改一下我們自動產生user的

**lib/tasks/sample_data.rake**

	namespace :db do
	  desc "Fill database with sample data"
	  task populate: :environment do
	    admin = User.create!(name: "Example User",
	                         email: "example@railstutorial.org",
	                         password: "foobar",
	                         password_confirmation: "foobar")
	    admin.toggle!(:admin)
	    .
	    .
	    .
	  end
	end
	
改了這個之後，我們要重跑一下資料庫！還記得哪些步驟嗎？


	$ bundle exec rake db:reset
	$ bundle exec rake db:populate
	$ bundle exec rake db:test:prepare

### 重新看attr_accessible

你可能有注意到，利用**toggle!(:admin)**，把使用者改成admin，那為甚麼我們不直接使用**admin: true**來初始化hash?

答案是這是不對的！ 

只有**attr_accessible**屬性可以被大量指派值(丟一個hash，Rails會自動幫你把值對應進去)，然而**admin**屬性，並非accessible 

(我們在app/models/user.rb並沒有在attr_accessible加入:admin)

明確的定義accessible對網站資安相當有助益！

假設我們使用**attr_accessible**把admin加進去的話，駭客就可使用這樣的方式來改你的資料庫！

	put /users/17?admin=1

所以…可以嘗試測試，把所有model的屬性，就像**:admin**，測試並沒有被加到accessible

### 刪除動作

為了要寫刪除函數的測試，我們可以使用factorygirl建立管理者，請看下面

**spec/factories.rb**

	FactoryGirl.define do
	  factory :user do
	    sequence(:name)  { |n| "Person #{n}" }
	    sequence(:email) { |n| "person_#{n}@example.com"}   
	    password "foobar"
	    password_confirmation "foobar"
	    
	    factory :admin do
	      admin true 
	    end
	    
	  end
	end


沒錯！就是加上

	factory :admin do
	   admin true 
	end

OK~先來寫測試！ 等一下再說為什麼要這樣寫

**spec/requests/user_pages_spec.rb**

在**describe "index" do**區塊加上

	describe "delete links" do

              it { should_not have_link('delete') }

              describe "as an admin user" do
                let(:admin) { FactoryGirl.create(:admin) }
                before do
                  sign_in admin
                  visit users_path
                end

                it { should have_link('delete', href: user_path(User.first)) }
                it "should be able to delete another user" do
                  expect { click_link('delete') }.to change(User, :count).by(-1)
                end
                it { should_not have_link('delete', href: user_path(admin)) }
              end
     end
     
  

為什麼要這樣寫，一般使用者是看不到delete這個選項的！

	it { should_not have_link('delete') }
	
再來，Admin是可以刪除的！所以才有那面那些行

	it { should have_link('delete', href: user_path(User.first)) }
	it "should be able to delete another user" do
	  expect { click_link('delete') }.to change(User, :count).by(-1)
	end
	it { should_not have_link('delete', href: user_path(admin)) }


再來寫code通過測試吧！

**app/views/users/_user.html.erb**

	<li>
	  <%= gravatar_for user, size: 52 %>
	  <%= link_to user.name, user %>
	  <% if current_user.admin? && !current_user?(user) %>
		| <%= link_to "delete" , user , method: :delete , confirm: "Are you sure?" %>
	<% end %>
	</li>

因為瀏覽器無法送出DELETE的要求，所以Rails是利用javaScript來假

再來，為了要讓Delele連結work! 來寫

**app/controllers/users_controller.rb**

	def destroy
    	User.find(params[:id]).destroy
    	flash[:success] = "User destroyed."
    	redirect_to users_path
  	end
  	
這邊有個資安的漏洞，經驗豐富的駭客～可以簡單的使用CLI來送出DELETE要求，來刪除使用者！所以我們必須對detroy作存取控制！

先來寫測試！

**spec/requests/authentication_pages_spec.rb**

在**describe "authorization" do**加上

	describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }        
      end
    end
    
 
這邊還是有些小的資安漏洞，那就是管理者可以刪除自己XD，可以寫看看摟～不過就先跳過，繼續下去啦！


改**app/controllers/users_controller.rb**

在前頭加上

	before_filter :admin_user,     only: :destroy
	
在**private**後面加上

	def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
	
跑測試！

	$ bundle exec rspec spec/
	
yap~~All pass!

耶～終於完成CH9


	$ git add .
	$ git commit -m "Finish user edit, update, index, and destroy actions"
	$ git checkout master
	$ git merge updating-users

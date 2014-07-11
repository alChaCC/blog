---
layout: post
title: "Learning on Ruby on Rails Tutorial-CH10 User microposts"
date: 2012-08-10 11:09
comments: true
categories: [Reading , Ruby_on_Rails] 
---
這一章節，我們會完成User的微網誌！使用**has_many**和**belongs_to**的資料庫關聯性，來看每個user的po文

一開始，我都會先這樣

    $ cd /你的路徑/
    
    # 先用mate指令打開專案
    $ mate sample_app   
    
    $ cd sample_app
    
    # 看看目前有哪些gemset
    $ rvm gemset list 
    $ rvm gemset use rails3tutorial2ndEd

OK來開始第十章吧！

<!--more--> 
    $ git checkout -b user-microposts
    

##A Micropost model

### The basic model

先到model的部份，這個model很簡單，先把需要用的東東(發文內容和是哪個user)建起來，

    $ rails generate model Micropost content:string user_id:integer

看一下剛剛gem出來的檔案，並且加上我們需要的功能

**db/migrate/[timestamp]_create_microposts.rb**

    class CreateMicroposts < ActiveRecord::Migration
      def change
        create_table :microposts do |t|
          t.string :content
          t.integer :user_id
    
          t.timestamps
        end
        add_index :microposts, [:user_id, :created_at]
      end
    end

因為我們希望可以透過user_id取得所有microposts，並且可以依照時間排序，所以才多加一個**add_index :microposts, [:user_id, :created_at]**

寫測試摟

**spec/models/micropost_spec.rb**

    require 'spec_helper'
    
    describe Micropost do
      let(:user) { FactoryGirl.create(:user) }
       before do
         # This code is wrong!
         @micropost = Micropost.new(content: "Lorem ipsum", user_id: user.id)
       end
    
       subject { @micropost }
    
       it { should respond_to(:content) }
       it { should respond_to(:user_id) }
       
    end

跑指令，這樣應該是可以work的！

    $ bundle exec rake db:migrate
    $ bundle exec rake db:test:prepare
    $ bundle exec rspec spec/models/micropost_spec.rb
    
雖然會pass不過有段程式 有問題！ 會在下章解答why 

### Accessible attributes and the first validation

為了要知道為甚麼這些有錯

我們來繼續寫測試！

**spec/models/micropost_spec.rb**

補上

    it { should be_valid }
    
      describe "when user_id is not present" do
        before { @micropost.user_id = nil }
        it { should_not be_valid }
      end

這段程式碼，要求micropost必須有效，而且**user_id**也必須要存在！

我們可以在**app/models/micropost.rb**加上一些話就可以確保測試會通過

    class Micropost < ActiveRecord::Base
      attr_accessible :content, :user_id  
      validates :user_id, presence: true
    end

現在我們來看為什麼這句話是錯的！

    @micropost = Micropost.new(content: "Lorem ipsum", user_id: user.id)

其實是因為預設所有的Micropost的屬性都是accessible

也就是說所有人都可以使用CLI發出不合法的要求，去改值，所以如果我故意改了文章的user_id他就會指錯使用者！ 也就是說，如果當我們把**attr_accessible :user_id**拿掉，剛剛的測試就會出現錯誤！！ 我們會在下一章解決這問題！


### User/Micropost associations

先來說一下狀況，基本上 micropost **belongs_to** user

另外，user **has_many** microposts

因為這個關聯性，我們可以整理出一張表格！

Method
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
Purpose

===========================================================

micropost.user
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
Return the User object associated with the micropost.

user.microposts
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
Return an array of the user’s microposts.

user.microposts.create(arg)    
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
Create a micropost (user_id = user.id).

user.microposts.create!(arg)    
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
Create a micropost (exception on failure).

user.microposts.build(arg)
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
&nbsp;
Return a new Micropost object (user_id = user.id).

注意歐！這邊我們沒有

	Micropost.create
	Micropost.create!
	Micropost.new

而是

	user.microposts.create
	user.microposts.create!
	user.microposts.build

這個才是合法的寫法，因為關聯性，所以我們在建立micropost時，是會自動幫你把user_id帶入！所以測試可以改成這樣

	let(:user) { FactoryGirl.create(:user) }
	before { @micropost = user.microposts.build(content: "Lorem ipsum") }
	
透過關聯性建立micropost，並沒有解決user_id可以被accessible的安全性問題！

所以…我們先來寫個測試！加到**describe Micropost do**區塊內

	 describe "accessible attributes" do
	       it "should not allow access to user_id" do
	         expect do
	           Micropost.new(user_id: user.id)
	         end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
	       end    
	  end

這個測試可以發出error訊息！

但是在Rails 3.2.3預設是有開啓的！但是其它舊版本並沒有，所以為了確保這是可用的！

**config/application.rb**把下面那串un-mark掉

	 config.active_record.whitelist_attributes = true

在網頁上，實際能編輯的只有**content**屬性而已！所以我們應該要把**attr_accessible :user_id**拿掉！

變成

	class Micropost < ActiveRecord::Base
  		attr_accessible :content
		validates :user_id, presence: true
	end

再來我們來寫測試micropost的關聯性的測試！

整體來說是這樣

**spec/models/micropost_spec.rb**

	require 'spec_helper'
	
	describe Micropost do
	
	  let(:user) { FactoryGirl.create(:user) }
	  before { @micropost = user.microposts.build(content: "Lorem ipsum") }
	
	  subject { @micropost }
	
	  it { should respond_to(:content) }
	  it { should respond_to(:user_id) }
	  it { should respond_to(:user) }
	  its(:user) { should == user }
	
	  it { should be_valid }
	
	  describe "accessible attributes" do
	    it "should not allow access to user_id" do
	      expect do
	        Micropost.new(user_id: user.id)
	      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
	    end    
	  end
	
	  describe "when user_id is not present" do
	    before { @micropost.user_id = nil }
	    it { should_not be_valid }
	  end
	end

別忘了我們user這邊也要測試！

首先user必須要有**microposts**

**spec/models/user_spec.rb** 加上一句話

	it { should respond_to(:microposts) }

完成後！ 剩下最後一步驟！在兩個model加上關聯性！

**app/models/micropost.rb**
	
	class Micropost < ActiveRecord::Base
	  attr_accessible :content
	  belongs_to :user
	
	  validates :user_id, presence: true  
	end
	

**app/models/user.rb**
	
	class User < ActiveRecord::Base
	  attr_accessible :name, :email, :password, :password_confirmation
	  has_secure_password
	  has_many :microposts
	  .
	  .
	  .
	end

執行測試吧

	$ bundle exec rspec spec/models

### Micropost refinements

此章節，我們必須要驗證到microposts的排序以及相依性

在這之前要先產生一堆資料

先定義好在**spec/factories.rb**，然後再呼叫…

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
	
	  factory :micropost do
	    content "Aloha is so handsome"
	    user
	  end
	end

有一個地方要注意，因為那個**user**所以FactoryGirl知道這個micropost是屬於user的！

所以等一下要用可以這樣用

	FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
	
為了要讓資料有先後順序，我們打算以create時間來做排序，但是大多是資料庫，取資料時，都是以id為排序依據，所以在測試時，我們會改**let**變成**lets**

let!: 	讓變數立即產生

let:    只有在refecence時，才會使變數存在

**spec/models/user_spec.rb** 加在**describe User do**區塊內

	describe "micropost associations" do
	
	    before { @user.save }
	    let!(:older_micropost) do 
	      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
	    end
	    let!(:newer_micropost) do
	      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
	    end
	
	    it "should have the right microposts in the right order" do
	      @user.microposts.should == [newer_micropost, older_micropost]
	    end
	end

最關鍵的一行就是

	@user.microposts.should == [newer_micropost, older_micropost]

為了讓測試通過其實很簡單，只要在**app/models/micropost.rb**加上一個東東！

	default_scope order: 'microposts.created_at DESC'

DESC在SQL就是"descending"

接著來看相依性的問題：**刪除**

admin有權限可以刪除使用者，照理說使用者被刪除後，他的micropost應該都要被刪除才是，我們可以這樣寫測試來驗證，當我們刪除文章的user時，相對應的文章都應該不會在資料庫內

**spec/models/user_spec.rb**在**describe "micropost associations" do**區塊加入

	it "should destroy associated microposts" do
	   microposts = @user.microposts
	   @user.destroy
	   microposts.each do |micropost|
	   Micropost.find_by_id(micropost.id).should be_nil
	 end
	end

要認這測試通過很簡單，只要告訴他的相依性有哪些

**app/models/user.rb**

	has_many :microposts, dependent: :destroy
	
測試一下吧～應該要可以通過
	
	$ bundle exec rspec spec/	

在跳到下一節之前，我們來看看內容驗證的部分！

廢話不多說，看一下要驗證哪些東西

**spec/models/micropost_spec.rb**

	describe "when user_id is not present" do
	    before { @micropost.user_id = nil }
	    it { should_not be_valid }
	  end
	
	  describe "with blank content" do
	    before { @micropost.content = " " }
	    it { should_not be_valid }
	  end
	
	  describe "with content that is too long" do
	    before { @micropost.content = "a" * 141 }
	    it { should_not be_valid }
	  end
  
 為了要限制字數，還記得要加什麼嗎? 
 
 沒錯，就是
 
 	validates :content, presence: true, length: { maximum: 140 }
 
 
 
## Showing microposts
	
依照Twitter的設計，我們可以在個人頁面看到他發的post，而不需要到micropost的index頁面，所以來開始吧！
	
### Augmenting the user show page

我們希望能夠建立兩個文章在一個user上，然後驗證show 頁面，包含文章的內容 ，因為我們希望文章和人可以馬上出現連結一起，所以我們不是用let而是使用let!

**spec/requests/user_pages_spec.rb** 加在**describe "User pages" do**程式區塊內

	describe "profile page" do
	        let(:user) { FactoryGirl.create(:user) }
	        let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Aloha ") }
	        let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Cool") }
	
	        before { visit user_path(user) }
	
	        it { should have_selector('h1',    text: user.name) }
	        it { should have_selector('title', text: user.name) }
	
	        describe "microposts" do
	          it { should have_content(m1.content) }
	          it { should have_content(m2.content) }
	          it { should have_content(user.microposts.count) }
	        end
	  end


OK~來看一下 **app/views/users/show.html.erb** 在 **<aside></aside>**之後加入

	<div class="span8">
	    <% if @user.microposts.any? %>
	      <h3>Microposts (<%= @user.microposts.count %>)</h3>
	      <ol class="microposts">
	        <%= render @microposts %>
	      </ol>
	      <%= will_paginate @microposts %>
	    <% end %>
	  </div>

注意一些細節，我們加了 換頁的東東， 這邊其實可以只用

	<%= will_paginate %>
	
為什麼要加上@microposts是因為在User controller底下，**will_paginate**是假設呼叫的值是@users，但是因為我們雖然在user controller之下，

但是我們是要show 文章！所以才要丟參數給他

還有一個特別的地方

	<ol class="microposts">
	   <%= render @microposts %>
	</ol>

這是使用經排序的list標籤**ol**，另外那個render他會去找.....找什麼？

如果是之前使用**render @users**他會去找**_user.html.erb**

So ?

這邊他就會去找**_micropost.html.erb**，當然我們沒有要建立一個給他

**app/views/microposts/_micropost.html.erb**

	<li>
	  <span class="content"><%= micropost.content %></span>
	  <span class="timestamp">
	    Posted <%= time_ago_in_words(micropost.created_at) %> ago.
	  </span>
	</li>

這邊使用到一個很酷的方法**time_ago_in_words**，我們等一下會介紹這個helper

接著我們趕緊來編輯，**app/controllers/users_controller.rb**

因為那些View都需要@microposts這個東東

把show改成

	 def show
    	@user = User.find(params[:id])
    	$title = @user.name
    	@microposts = @user.microposts.paginate(page: params[:page])
  	 end
  
yap~~不過到了這階段，目前還是沒有辦法看到一些東西～所以我們到下一小節，新增micropost吧！
  
### Sample microposts

使用**lib/tasks/sample_data.rake**來建置大量使用者micropost吧！

加到**task populate: :environment do**裡面

	users = User.all(limit: 6)
    50.times do
      content = Faker::Lorem.sentence(5)
      users.each { |user| user.microposts.create!(content: content) }
    end

這邊我們只選擇前六個使用者，然後用**Faker::Lorem.sentence**這個方法隨機建立文字

OK 建到資料庫吧！

	$ bundle exec rake db:reset
	$ bundle exec rake db:populate
	$ bundle exec rake db:test:prepare
	
但是看起來好醜....所以我們來加一些css

**app/assets/stylesheets/custom.css.scss**
	
	/* microposts */
	
	.microposts {
	  list-style: none;
	  margin: 10px 0 0 0;
	
	  li {
	    padding: 10px 0;
	    border-top: 1px solid #e8e8e8;
	  }
	}
	.content {
	  display: block;
	}
	.timestamp {
	  color: $grayLight;
	}
	.gravatar {
	  float: left;
	  margin-right: 10px;
	}
	aside {
	  textarea {
	    height: 100px;
	    margin-bottom: 5px;
	  }
	}


yap~好看多了！

##Manipulating microposts

完成data	的model和micropost的view，現在把重點放在micropost操作上，這個Micropost的操作會密集在User和static頁面controller之間，

也就是說…這不簡單....OK！要操作Micropost之前，我們要先讓他有RestFul

REST有主要有兩個核心精神：1. 使用Resource來當做識別的資源，也就是使用一個URL網址來代表一個Resource 2. 同一個Resource則可以有不同的Representations格式變化。

所以我們要在**config/routes.rb**加上

	resources :microposts, only: [:create, :destroy]
	
這也代表了他會有兩個url可以用！

HTTP request
&nbsp;
&nbsp;
&nbsp;
&nbsp;URI
&nbsp;
&nbsp;
&nbsp;
&nbsp;Action
&nbsp;
&nbsp;
&nbsp;
&nbsp;Purpose

POST
&nbsp;
&nbsp;
&nbsp;
&nbsp;
/microposts
&nbsp;
&nbsp;
&nbsp;
&nbsp;
create
&nbsp;
&nbsp;
&nbsp;
&nbsp;
create a new micropost

DELETE
&nbsp;
&nbsp;
&nbsp;
&nbsp;
/microposts/1
&nbsp;
&nbsp;
&nbsp;
&nbsp;
destroy	
&nbsp;
&nbsp;
&nbsp;
&nbsp;
delete micropost with id

### Access control

當然要有登入的使用者才可以創建或刪除文章，所以我們的測試可以這樣寫

**spec/requests/authentication_pages_spec.rb**在**describe "for non-signed-in users" do**區塊加入

	describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { response.should redirect_to(signin_path) }
        end
      end

注意歐～這邊**post microposts_path**就是使用**create**動作; **delete micropost_path(micropost)**就會使用**destroy**動作！

為了要讓測試通過，我們必須要小小的重構程式碼，我們在User controller的地方，使用了**signed_in_user**判斷使用者是否登入

我們發現說原來在micropost也需要用到！所以我們把這段程式碼搬到**app/helpers/sessions_helper.rb**

加上
		
	def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_path, notice: "Please sign in." 
      end
    end

耶～所以現在就可以在**app/controllers/microposts_controller.rb**使用啦～

	class MicropostsController < ApplicationController
	  before_filter :signed_in_user , only: [:create , :destroy]
	
	  def create
	  end
	
	  def destroy
	  end
	  
	  def index
	  end
	  
	end

跑測試吧～

	$ bundle exec rspec spec/requests/authentication_pages_spec.rb

### Creating microposts

這邊有一個地方很不一樣，因為在發文的時候一定會是已登入的使用者，所以要建一個新的頁面專門給micropost使用的！

在這之前，我們先來建立測試吧！

	$ rails generate integration_test micropost_pages

編輯測試程式

**spec/requests/micropost_pages_spec.rb**

	require 'spec_helper'
	
	describe "Micropost pages" do
	
	  subject { page }
	
	  let(:user) { FactoryGirl.create(:user) }
	  before { sign_in user }
	
	  describe "micropost creation" do
	    before { visit root_path }
	
	    describe "with invalid information" do
	
	      it "should not create a micropost" do
	        expect { click_button "Post" }.should_not change(Micropost, :count)
	      end
	
	      describe "error messages" do
	        before { click_button "Post" }
	        it { should have_content('error') } 
	      end
	    end
	
	    describe "with valid information" do
	
	      before { fill_in 'micropost_content', with: "Lorem ipsum" }
	      it "should create a micropost" do
	        expect { click_button "Post" }.should change(Micropost, :count).by(1)
	      end
	    end
	  end
	end

在來編輯
**app/controllers/microposts_controller.rb**

	class MicropostsController < ApplicationController
	  before_filter :signed_in_user
	
	  def create
	    @micropost = current_user.microposts.build(params[:micropost])
	    if @micropost.save
	      flash[:success] = "Micropost created!"
	      redirect_to root_path
	    else
	      render 'static_pages/home'
	    end
	  end
	
	  def destroy
	  end
	end

Control 完 換View

**app/views/static_pages/home.html.erb**

其實就是多加了判斷user是不是登入！

	<% if signed_in? %>
	  <div class="row">
	    <aside class="span4">
	      <section>
	        <%= render 'shared/user_info' %>
	      </section>
	      <section>
	        <%= render 'shared/micropost_form' %>
	      </section>
	    </aside>
	  </div>  
	<% else %>
	  <div class="center hero-unit">
	    <h1>Welcome to the Sample App</h1>
	
	    <h2>
	      This is the home page for the
	      <a href="http://railstutorial.org/">Ruby on Rails Tutorial</a>
	      sample application.
	    </h2>
	
	    <%= link_to "Sign up now!", signup_path, 
	                                class: "btn btn-large btn-primary" %>
	  </div>
	
	  <%= link_to image_tag("rails.png", alt: "Rails"), 'http://rubyonrails.org/' %>
	<% end %> 

注意歐！因為有些東西是可以拉出來寫的例如**<%= render 'shared/user_info' %>**

就是

**app/views/shared/_user_info.html.erb**

	<a href="<%= user_path(current_user) %>">
	  <%= gravatar_for current_user, size: 52 %>
	</a>
	<h1>
	  <%= current_user.name %>
	</h1>
	<span>
	  <%= link_to "view my profile", current_user %>
	</span>
	<span>
	  <%= pluralize(current_user.microposts.count, "micropost") %>
	</span>

這些之前都有講過了～所以就不再提了～

因為還有一個也是被拉出來寫**<%= render 'shared/micropost_form' %>**

	<%= form_for(@micropost) do |f| %>
	  <%= render 'shared/error_messages', object: f.object %>
	  <div class="field">
	    <%= f.text_area :content, placeholder: "Compose new micropost..." %>
	  </div>
	  <%= f.submit "Post", class: "btn btn-large btn-primary" %>
	<% end %>

那個@micropost是我們在controller用**current_user.microposts.build**建出來的

另外還要加上micropost的變數實例在**app/controllers/static_pages_controller.rb**

	def home
    	@micropost = current_user.microposts.build if signed_in?
  	end
  	
還有一個很詭異的東東那就是

	<%= render 'shared/error_messages', object: f.object %>

舉個例來說明，form_for(@user) do |f|

那個f.object 就是 @user,

同理可得form_for(@micropost) do |f|

他的f.object 就是 @micropost

換句話說， 那個object: f.object 會在**error_messsages**建立一個變數叫做**object**

因為這樣，所以要update一下**app/views/shared/_error_messages.html.erb**

	<% if object.errors.any? %>
	  <div id="error_explanation">
	    <div class="alert alert-error">
	      The form contains <%= pluralize(object.errors.count, "error") %>.
	    </div>
	    <ul>
	    <% object.errors.full_messages.each do |msg| %>
	      <li>* <%= msg %></li>
	    <% end %>
	    </ul>
	  </div>
	<% end %>
	
執行測試看有沒有哪裡改錯

	$  bundle exec rspec spec/requests/micropost_pages_spec.rb

注意看上面範例～ yap~沒錯！

接著我們來更新**app/views/users/new.html.erb**

只有一個地方要改**object: f.object**

變成這樣

	<%= render 'shared/error_messages' , object: f.object %>
    
當然那個**app/views/users/edit.html.erb**也要改

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

### A proto-feed

因為每個人都有feed，所以勢必要加一個**feed**的函式在User model裡面，先寫測試**feed**函式包含了現在使用者的micropost，
但是沒有其他user的程式

**spec/models/user_spec.rb**

	require 'spec_helper'
	
	describe User do
	  .
	  .
	  .
	  it { should respond_to(:microposts) }
	  it { should respond_to(:feed) }
	  .
	  .
	  .
	  describe "micropost associations" do
	
	    before { @user.save }
	    let!(:older_micropost) do 
	      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
	    end
	    let!(:newer_micropost) do
	      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
	    end
	    .
	    .
	    .
	    describe "status" do
	      let(:unfollowed_post) do
	        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
	      end
	
	      its(:feed) { should include(newer_micropost) }
	      its(:feed) { should include(older_micropost) }
	      its(:feed) { should_not include(unfollowed_post) }
	    end
	  end
	end

這次的測試多了一個新的夥伴！**include?** 他主要的工作就是檢查array裡面，有沒有包含我們要找的值

RSpec很聰明得知道我們要測試是否元素在陣列裡

來到**app/models/user.rb**

	 def feed
	    # This is preliminary. See "Following users" for the full implementation.
	    Micropost.where("user_id = ?", id)
	  end

這邊我有個問題，那就是那個**Micropost.where("user_id = ?", id)**是怎麼一回事

文章是說**id**最好不要在SQL指令出現，這是因為會有**SQL injection**攻擊，但是對於我們這個
例子，這個id是整數，所以沒有危險～  這一行其實等於下面

	def feed
	 microposts
	end

再寫一個測試

**spec/requests/static_pages_spec.rb**

	describe "for signed-in users" do
	      let(:user) { FactoryGirl.create(:user) }
	      before do
	        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
	        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
	        sign_in user
	        visit root_path
	      end
	
	      it "should render the user's feed" do
	        user.feed.each do |item|
	          page.should have_selector("li##{item.id}", text: item.content)
	        end
	      end
	    end

注意一下 

	 page.should have_selector("li##{item.id}", text: item.content)

有兩個#其中一個是要給CSS看得ID，另外一個#{}是一起的～是Ruby的字串包含程式碼

為了要在程式使用到**feed**，我們會加上一個**@feed_items**實例變數(instance variable：宣告在 class 內，method 之外，且未使用 static 修飾的變數)，

給現在使用者的feed.

**app/controllers/static_pages_controller.rb**

	def home
	    if signed_in?
	      @micropost  = current_user.microposts.build
	      @feed_items = current_user.feed.paginate(page: params[:page])
	    end
	  end
	  
另外要作partial view 給feed 和 feed_item本身

**app/views/shared/_feed.html.erb**

	<% if @feed_items.any? %>
	  <ol class="microposts">
	    <%= render partial: 'shared/feed_item', collection: @feed_items %>
	  </ol>
	  <%= will_paginate @feed_items %>
	<% end %>

**app/views/shared/_feed_item.html.erb**

	<li id="<%= feed_item.id %>">
	  <%= link_to gravatar_for(feed_item.user), feed_item.user %>
	  <span class="user">
	    <%= link_to feed_item.user.name, feed_item.user %>
	  </span>
	  <span class="content"><%= feed_item.content %></span>
	  <span class="timestamp">
	    Posted <%= time_ago_in_words(feed_item.created_at) %> ago.
	  </span>
	</li>

yap~現在來看user登入後的view

**app/views/static_pages/home.html.erb**

	<% if signed_in? %>
	  <div class="row">
	    <aside class="span4">
	      <section>
	        <%= render 'shared/user_info' %>
	      </section>
	      <section>
	        <%= render 'shared/micropost_form' %>
	      </section>
	    </aside>
	
		<div class="span8">
		      <h3>Micropost Feed</h3>
		      <%= render 'shared/feed' %>
		</div>
	  </div>  
	<% else %>
	  <div class="center hero-unit">
	    <h1>Welcome to the Sample App</h1>
	
	    <h2>
	      This is the home page for the
	      <a href="http://railstutorial.org/">Ruby on Rails Tutorial</a>
	      sample application.
	    </h2>
	
	    <%= link_to "Sign up now!", signup_path, 
	                                class: "btn btn-large btn-primary" %>
	  </div>
	
	  <%= link_to image_tag("rails.png", alt: "Rails"), 'http://rubyonrails.org/' %>
	<% end %>


耶～可以看一下網頁！看起來不錯歐！也可以發表成功！

咦....不過如果我不打字串按發表的話，要跳出error

解法暫時如下：

**app/controllers/microposts_controller.rb**

當使用者沒有輸入值時，先給他空的array

	def create
	    @micropost = current_user.microposts.build(params[:micropost])
	    if @micropost.save
	      flash[:success] = "Micropost created!"
	      redirect_to root_path
	    else
	      @feed_items = []
	      render 'static_pages/home'
	    end
	  end

來跑測試吧！

	$ bundle exec rspec spec/

### Destroying microposts

最後，加上一個可以刪除micropost的東東～

大概就是加上

	<% if current_user?(micropost.user) %>
		    <%= link_to "delete", micropost, method:  :delete,
		                                     confirm: "You sure?",
		                                     title:   micropost.content %>
	<% end %>

**app/views/microposts/_micropost.html.erb**

	<li>
	  <span class="content"><%= micropost.content %></span>
	  <span class="timestamp">
	    Posted <%= time_ago_in_words(micropost.created_at) %> ago.
	  </span>
	  <% if current_user?(micropost.user) %>
	    <%= link_to "delete", micropost, method:  :delete,
	                                     confirm: "You sure?",
	                                     title:   micropost.content %>
	  <% end %>
	</li>

**app/views/shared/_feed_item.html.erb**

	<li id="<%= feed_item.id %>">
	  <%= link_to gravatar_for(feed_item.user), feed_item.user %>
	    <span class="user">
	      <%= link_to feed_item.user.name, feed_item.user %>
	    </span>
	    <span class="content"><%= feed_item.content %></span>
	    <span class="timestamp">
	      Posted <%= time_ago_in_words(feed_item.created_at) %> ago.
	    </span>
	  <% if current_user?(feed_item.user) %>
	    <%= link_to "delete", feed_item, method:  :delete,
	                                     confirm: "You sure?",
	                                     title:   feed_item.content %>
	  <% end %>
	</li>

在寫controller刪除功能之前，先來寫測試

**spec/requests/micropost_pages_spec.rb**

在**describe "Micropost pages" do**區塊加上

	describe "micropost destruction" do
	    before { FactoryGirl.create(:micropost, user: user) }
	
	    describe "as correct user" do
	      before { visit root_path }
	
	      it "should delete a micropost" do
	        expect { click_link "delete" }.should change(Micropost, :count).by(-1)
	      end
	    end
	  end

刪除的地方在之前user的地方有做過！主要差別在於只要是user本人即可刪除訊息，所以我們用

**correct_user**來檢查

**app/controllers/microposts_controller.rb**

	before_filter :correct_user,   only: :destroy
	
	def destroy
    	@micropost.destroy
    	redirect_to root_path
  	end

  	private

    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_path if @micropost.nil?
    end


這個寫法主要是可以確保現在的user 他的文章裡頭可以找到這個id的文章！

其實也是可以這樣寫！

	@micropost = Micropost.find_by_id(params[:id])
	redirect_to root_path unless current_user?(@micropost.user)

不過根據高手的文章表示，
> for security purposes it is a good practice always to run lookups through the association.


ＯＫ～確保一下程式都沒問題

 	$ bundle exec rspec spec/


## Conclusion

	$ git add .
	$ git commit -m "Add user microposts"
	$ git checkout master
	$ git merge user-microposts
	$ git push
	
	
	
You can also push the app up to Heroku at this point. Because the data model has changed through the addition of the microposts table, you will also need to migrate the production database:

$ git push heroku
$ heroku pg:reset SHARED_DATABASE --confirm <name-heroku-gave-to-your-app>
$ heroku run rake db:migrate
$ heroku run rake db:populate

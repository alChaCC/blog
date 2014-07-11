---
layout: post
title: "Learning on Ruby on Rails Tutorial- CH5 - Filling in the layout"
date: 2012-06-30 20:15
comments: true
categories: [Reading, Ruby_on_Rails]
---
來開發layout部分

	git checkout -b filling-in-layout

先來刻一下app/views/layouts/application.html.erb

<!--more--> 
	
	<!DOCTYPE html>
	<html>
	  <head>
	    <title> full_title(yield(:title))%></title>
	    <%= stylesheet_link_tag    "application", media: "all" %>
	    <%= javascript_include_tag "application" %>
	    <%= csrf_meta_tags %>
	  </head>
	  <body>
		<header class="navbar navbar-fixed-top">
			<div class="navbar-inner">
				<div class ="container">
					<% link_to "sample app" , '#' , id:"logo"%>
					<nav>
						<ul class="nav pull-right">
							<li><%link_to "home" , '#' %></li>
							<li><%link_to "help" , '#' %></li>
							<li><%link_to "sign in" , '#' %></li>
						</ul>
					</nav>
				</div>
			</div>
		</header>
		<div class="container">
	    <%= yield %>
		</div>
	  </body>
	</html>


修改app/views/static_pages/home.html.erb
	
	<div class="center hero-unit">
	  <h1>Welcome to the Sample App</h1>
	
	  <h2>
	    This is the home page for the
	    <a href="http://railstutorial.org/">Ruby on Rails Tutorial</a>
	    sample application.
	  </h2>
	
	  <%= link_to "Sign up now!", '#', class: "btn btn-large btn-primary" %>
	</div>
	
	<%= link_to image_tag("rails.png", alt: "Rails"), 'http://rubyonrails.org/' %>
	

上面那些class其實都是和等一下我們要做的事情有關-**Bootstrap**

首先先來改Gemfile

	gem 'bootstrap-sass' , '2.0.0'
	
別忘了

	$bundle install 
	
在app/assets/stylesheets新增 custom.css.scss檔

並寫下一句很酷的話

	@import "bootstrap"
	
你就可以看到一個很酷的東東了！

接下來，讓我們來加一些東東

	@import "bootstrap";
	
	/* universal */
	
	html {
	  overflow-y: scroll;
	}
	
	body {
	  padding-top: 60px;
	}
	
	section {
	  overflow: auto;
	}
	
	textarea {
	  resize: vertical;
	}
	
	.center {
	  text-align: center;
	}
	
	.center h1 {
	  margin-bottom: 10px;
	}
	
	h1, h2, h3, h4, h5, h6 {
	  line-height: 1;
	}
	
	h1 {
	  font-size: 3em;
	  letter-spacing: -2px;
	  margin-bottom: 30px;
	  text-align: center;
	}
	
	h2 {
	  font-size: 1.7em;
	  letter-spacing: -1px;
	  margin-bottom: 30px;
	  text-align: center;
	  font-weight: normal;
	  color: #999;
	}
	
	p {
	  font-size: 1.1em;
	  line-height: 1.7em;
	}
		
	/* header */
	
	#logo {
	  float: left;
	  margin-right: 10px;
	  font-size: 1.7em;
	  color: #fff;
	  text-transform: uppercase;
	  letter-spacing: -1px;
	  padding-top: 9px;
	  font-weight: bold;
	  line-height: 1;
	  decoration: none;
	}
	
	#logo:hover {
	  color: #fff;
	  text-decoration: none;
	}
	
	/* footer */
	
	footer {
	  margin-top: 45px;
	  padding-top: 5px;
	  border-top: 1px solid #eaeaea;
	  color: #999;
	}
	
	footer a {
	  color: #555;
	}  
	
	footer a:hover { 
	  color: #222;
	}
	
	footer small {
	  float: left;
	}
	
	footer ul {
	  float: right;
	  list-style: none;
	}
	
	footer ul li {
	  float: left;
	  margin-left: 10px;
	}
			

接下來！ 我們要建一些layout ! 

_footer.html.erb

	<footer class="footer">
	  <small>
	    <a href="http://railstutorial.org/">Rails Tutorial</a>
	    by Michael Hartl
	  </small>
	  <nav>
	    <ul>
	      <li><%= link_to "About",   '#' %></li>
	      <li><%= link_to "Contact", '#' %></li>
	      <li><a href="http://news.railstutorial.org/">News</a></li>
	    </ul>
	  </nav>
	</footer>

_header.html.erb

	<header class="navbar navbar-fixed-top">
	  <div class="navbar-inner">
	    <div class="container">
	      <%= link_to "sample app", '#', id: "logo" %>
	      <nav>
	        <ul class="nav pull-right">
	          <li><%= link_to "Home",    '#' %></li>
	          <li><%= link_to "Help",    '#' %></li>
	          <li><%= link_to "Sign in", '#' %></li>
	        </ul>
	      </nav>
	    </div>
	  </div>
	</header>
	
_shim.html.erb

	<!--[if lt IE 9]>
	<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->

最後再改application.html.erb
	
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
	    </div>
	  </body>
	</html>
	
接著說明Asset Pipeline

有三種不同的assets

1. app/assets		=> assets specific to the present application
2. lib/assets 		=> assets for libraries written by your dev team
3. vendor/assets  	=> assets from third-party vendor

一旦你放了你的asset在位置上，可以使用 **manifest**檔案告訴Rails 如何組合他們！

所以我們來看看app/assets/stylesheets/application.css

有這兩個比較特別！

	*=require_tree .
	以及
	*=require_self
	
第一句 __*=require_tree .__

確保！所有在/app/assets/stylesheets資料夾內的東東被include到application css裡

第二句 __*=require_self __

確保 在application.css的CSS檔被include進來 

這個Asset Popeline 主要優點是
 With the asset pipeline, in production all the application stylesheets get rolled into one CSS file (application.css), all the application JavaScript code gets rolled into one JavaScript file (javascripts.js)
可以減少slow page-load time.

## Saas

Saas是一個改善css的新的stylesheet的language.也相容css(所以基本上你把檔名xxx.css改成xxx.css.scss是要可以work的)
在這個地方我們主要琢磨在兩個主要的改善！

**nesting**和 **variable**

###Nesting
在app/assets/stylesheets/custom.css.scss裡面

首先，在之前有個例子是

	.center{
		text-align:center;
		}
	.center h1{
		margin-bottom:10px;
		}

我們可以把它改寫成 sass格式
	
	.center {
		text-align : center;
		h1 {
			margin-bottom:10px;
		}
	}
	
	
另外一個例子是

	#logo{
		float:left;
		margin-right:10px;
		font-size:1.7em;
		color:#fff;
		text-transform:uppercase;
		letter-spacing:-1px;
		padding-top:9px;
		font-weight:bold;line-height:1;
		}
	
	#logo:hover{
		color:#fff;
		text-decoration:none;
		}

這個例子logo這個id 出現了兩次，一次是他自己，另外一次是帶有hover這個屬性

我們可以使用 & 來把它串起來

	#logo{
		float:left;
		margin-right:10px;
		font-size:1.7em;
		color:#fff;
		text-transform:uppercase;
		letter-spacing:-1px;
		padding-top:9px;
		font-weight:bold;line-height:1;
		&:hover{
			color:#fff;
			text-decoration:none;
			}
		}
		
OK~那我們在再來把  footer的部份改一下

	footer{
		margin-top:45px;
		padding-top:5px;
		border-top 1pxsolid#eaeaea;
		color:#999;
		a{
			color:#555;
			&:hover{color:#222;}
		 }
		small {
			float:left;
			}
		ul { 
			float:right;
			list-style:none;
			li { 
				float:left;
				margin-left:10px;
				}
			}
	}

###Variables 

Sass 允許我們可以定義變數，減少重複以及撰寫可讀性更高的code

舉例來說， 我們剛剛的 

	h2 {
		.
		.
		.
		color: #999;
	}
	
	…
	
	footer {
		.
		.
		.
		color: #999;
	}
	

所以我們可以定義變數 $lightGray: #999; 讓程式更DRY

	$lightGray: #999;
	…
	h2 {
		.
		.
		.
		color: $lightGray;
	}
	
	…
	
	footer {
		.
		.
		.
		color: $lightGray;
	}
像這種 #999就是可讀性不高的東東
	
Bootstrap framework有提供非常多的顏色變數，請參考

[Bootstrap page of LESS variable](http://twitter.github.com/bootstrap/less.html#variables)

That page defines variables using LESS, not Sass, but the bootstrap-sass gem provides the Sass equivalents

我們可以看到有一個變數叫做@grayLight:#999;

LESS 用＠

Sass 用$ ，但是bootstrap-sass 這個gem會幫我們自動轉換

所以我們可以把剛剛的$lightGray刪除！
改寫如下

	
	h2 {
		.
		.
		.
		color: $grayLight;
	}
	
	…
	
	footer {
		.
		.
		.
		color: $grayLight;
	}
	
	
把這兩個原則套在我們的

app/assets/stylesheets/custom.css.scss

 即可改寫成
 	
 	@import"bootstrap";
	/* mixins, variables, etc. */
	$grayMediumLight: #eaeaea;

	/* universal*/
	html{
		overflow-y:scroll;
	}

	body{
		padding-top:60px;
	}

	section{
		overflow:auto;
	}

	textarea{
		resize:vertical;
	}

	.center{
		text-align:center;
		h1{
			margin-bottom:10px;
		}
	}
	
	/* typography*/

	h1,h2,h3,h4,h5,h6{
		line-height:1;
	}
	
	h1{
		font-size:3em;
		letter-spacing:-2px;
		margin-bottom:30px;
		text-align:center;
	}

	h2{
		font-size:1.7em;
		letter-spacing:-1px;
		margin-bottom:30px;
		text-align:center;
		font-weight:normal;
		color: $grayLight;
	}

	p{
		font-size:1.1em;
		line-height:1.7em;
	}

	/* header*/

	#logo{
		float:left;
		margin-right:10px;
		font-size:1.7em;
		color:white;
		text-transform:uppercase;
		letter-spacing:-1px;
		padding-top:9px;
		font-weight:bold;
		line-height:1;
		&:hover{
			color:white;
			text-decoration:none;
		}
	}
	
	/* footer*/
	
	footer{
		margin-top:45px;
		padding-top:5px;
		border-top:1px solid $grayMediumLight;
		color: $grayLight;
		a{
			color:$gray;
			&:hover{
				color:$grayDarker;
				}
			}
		small{
				float:left;
				}
	ul{
		float:right;
		list-style:none;
		li{
			float:left;
			margin-left:10px;
			}
		}
	}
	
接著我們將連結補上！

Page	URI			Named route

Home	/			root_path
About	/about		about_path
Help	/help		help_path
Contact	/contact	contact_path
Sign up	/signup		signup_path
Sign in	/signin		signin_path

##接下來，我們來寫Route，但是要先寫測試程式 


OK~ 我們只要把 visit '/static_pages/about'

改成

visit about_path

所以全部改完是變成

	require 'spec_helper'

	describe "Static Pages" do
  		describe "Home page" do
    		it "should have h1 'Sample App'" do
        		visit root_path
         		page.should have_selector('h1', :text => 'Sample App')
    		end
    
    	it "should have the base title" do
          	visit root_path
          	page.should have_selector('title',
                            :text => "Ruby on Rails Tutorial Sample App")
    end
    
    it "should not have a custom page title" do 
      visit root_path
      page.should_not have_selector('title', text:'| Home')
      end
    
  end
  
  describe "Help page" do
      it "should have the h1 'Help'" do
            visit help_path
            page.should have_selector('h1', :text => 'Help')
          end

          it "should have the title 'Help'" do
            visit help_path
            page.should have_selector('title',
                              :text => "Ruby on Rails Tutorial Sample App | Help")
          end
    end
  
  	describe "About page" do
    	it "should have the h1 'About'" do
           visit about_path
           page.should have_selector('h1', :text => 'About Us')
         end

         it "should have the title 'About Us'" do
           visit '/static_pages/about'
           page.should have_selector('title',
                         :text => "Ruby on Rails Tutorial Sample App | About Us")
         end
      end
      
    describe "Contact page" do
     	it "should have the h1 'Contact'" do
          visit contact_path
          page.should have_selector('h1', :text => 'Contact')
        end

        it "should have the title 'Contact'" do
          visit contact_path
          page.should have_selector('title',
                        :text => "Ruby on Rails Tutorial Sample App | Contact")
        end
     	end

	end



OK~跑一下測試指令！ 照理說會看到一堆紅色～～XD

	# bundle exec rspec spec/requests/static_pages_spec.rb


要定義routes 我們必須先取代 get 'static_pages/help'

把它改成

	match '/help', to:'static_pages#help'
	
事實上 match '/help' 會自動產生route給control和view使用
	
	about_path => '/about'
	about_url=>'http://localhost:3000/about'
	
那root要怎麼改

	match '/' , to:'static_pages#home'
	
你也可以這樣寫
	
	root to:'static_pages#home'
	
這時候我們可以把public/index.html刪除！

或是把他從git管理中刪除

	git rm public/index.html

之後我們可以用-a 這個指令 commit 有改變的code

	git commit -a -m "remove index.html" change.

這個時候執行

	# bundle exec rspec spec/requests/static_pages_spec.rb
	
應該就會pass了！

OK~再來把那些app/views/layouts/_XXX.html.erb

裡頭有的東東都改寫八～～

之後～我們來把我們的測試程式改寫得漂亮一點

首先，我們先來看

	describe "Home page" do
    it "should have h1 'Sample App'" do
        visit root_path
         page.should have_selector('h1', :text => 'Sample App')
    end
    
    it "should have the base title" do
          visit root_path
          page.should have_selector('title',
                            :text => "Ruby on Rails Tutorial Sample App")
    end
    
    it "should not have a custom page title" do 
      visit root_path
      page.should_not have_selector('title', text:'| Home')
      end
    end
 
 有沒有發現甚麼東西很sucks~ 沒錯！
 
 就是很多重復的東東
 
 就是那個！！！ visit root_path!!!
 
 我們可以用 **before**來改寫 

	describe "Home page" do
    before {visit root_path}
    
    it "should have h1 'Sample App'" do
         page.should have_selector('h1', :text => 'Sample App')
    end
    
    it "should have the base title" do
         page.should have_selector('title',
                            :text => "Ruby on Rails Tutorial Sample App")
    end
    
    it "should not have a custom page title" do 
         page.should_not have_selector('title', text:'| Home')
      end
    end

還有一個不好的地方

那就是 

	it "should have the h1 'Sample App'"do
	
和
	
	page.shouldhave_selector('h1',text:'Sample App')

他們兩個其實再說同一件事

另外還有都是用page.XXX

我們可以使用

	subject{page}
	
然後再用 it 來取代

	it {should have_selector('h1',text:'Sample App')}
	
(Because of subject { page }, the call to should automatically uses the page variable supplied by Capybara (Section 3.2.1).)

這樣就水了！

請看新版的testing code 

	subject{page}
	describe "Home page" do
	before { visitroot_path }
	it { should have_selector('h1',text:'Sample App') }       
	it { should have_selector 'title',
								text: "Ruby on Rails Tutorial Sample App"
								}
	it { should_not have_selector 'title'
								,text:'| Home'
								}
	end
	
還有一個地方看起來冗長～

就是那一串txt，"Ruby on Rails Tutorial Sample App ｜ Ａbout"

我們可以為他寫一個utilities.rb

在 spec/support/utilities.rb

	def full_title(page_title)
  		base_title = "Ruby on Rails Tutorial Sample App"
  
  		if page_title.empty?
    		base_title
  		else
    		"#{base_title} | #{page_title}"
  		end
	end

這時候 你一定想問那這個要怎麼用？

其實spec/support資料夾底下的東東

已經自動被RSpect 載入了～

所以我們可以直接用

來改spec/requests/static_pages_spec.rb

	require 'spec_helper'

	describe "Static Pages" do
	  subject {page}
	  
	  describe "Home page" do
	      before {visit root_path}
	           it { should have_selector('h1', text: 'Sample App') }
	           it { should have_selector('title',text: full_title(''))}
	           it { should_not have_selector('title', text: '| Home') }
	       
	      end
	  
	  
	  describe "Help page" do
	     before {visit help_path}
	          it {page.should have_selector('h1', text: 'Help')}
	          it {should have_selector('title',text:full_title('Help'))}
	    end
	  
	  describe "About page" do
	    	 before {visit about_path}
	           it {should have_selector('h1', text: 'About')}
	           it {should have_selector('title',text: full_title('About Us'))} 
	    end
	      
	  describe"Contact page" do 
	      before{ visit contact_path }
	      it { should have_selector('h1',text:'Contact')}
	      it { should have_selector('title', text:full_title('Contact'))}
	    end
	
	end
	

##來玩玩使用者登入吧！

先建立 user的controller

	rails generate controller Users new --no-test-framework

產生了一些東西後

再來先寫測試吧

	rails generate integration_test user_pages
	
完成測試程式

	require 'spec_helper'

	describe "User pages" do
  		subject {page}
  		describe "signup page" do
    	before {visit signup_path}
     	it {should have_selector('h1', text: 'Sign up')}
      	it {should have_selector('title', text: full_title('Sign up'))}
  		end
	end

跑測試

	 bundle exec rspec spec/requests/user_pages_spec.rb
	 
	#你也可以這樣跑
	
	bundle exec rspec spec/requests/
	
	#你也可以這樣跑
	
	bundle exec rspec spec/
	
	#你也可以這樣跑
	
	bundle exec rake spec
	
OK~跑完結果應該是有兩個錯誤

rspec ./spec/requests/user_pages_spec.rb:8 # User pages signup page 
rspec ./spec/requests/user_pages_spec.rb:9 # User pages signup page 

讓我們來開始動手改吧！ 先來改**config/routes.rb**


新增這一行即可

	match '/signup', to: 'users#new'
	
注意一下！
那個 **get "users/new"** 

他是剛剛自動gen出來的～ 我們先暫時保留這句，因為 match '/signup', to: 'users#new'

需要這句話，但是這並不符合我們要的REST原則，我們之後會把他取代掉！

再來改 **app/views/users/new.html.erb**

	<% provide(:title, 'Sign up') %>
	<h1>Sign up</h1>
	<p>Find me in app/views/users/new.html.erb</p>


OK~我們再來執行

 	bundle exec rspec spec/requests/user_pages_spec.rb
 
 這樣會all pass
 
 
最後，我們來將Sign up的路徑 加到homepage底下

改**app/views/static_pages/home.html.erb** 一句話即可

	 <%= link_to "Sign up now!", signup_path, class: "btn btn-large btn-primary" %>

來試一下吧～

	rails server
	
	
耶～成功拉！

OK~最後拉回版本控制巴


	$ git add .
	$ git commit -m "Finish layout and routes"
	$ git checkout master
	$ git merge filling-in-layout
	

##練習

1. 由於那個spec/requests/static_pages_spec.rb

還是太多重覆的東西！

我們可以用**shared_examples_for**和**let**和**it_should_behave_like**來改寫！


	require 'spec_helper'
	
	describe "Static Pages" do
	  subject {page}
	  
	  shared_examples_for "all static pages" do
	      it { should have_selector('h1',    text: heading) }
	      it { should have_selector('title', text: full_title(page_title)) }
	    end
	  
	  describe "Home page" do
	      before {visit root_path}
	           #it { should have_selector('h1', text: 'Sample App') }
	           #it { should have_selector('title',text: full_title(''))}
	           let(:heading)    { 'Sample App' }
	           let(:page_title) { '' }
	           it { should_not have_selector('title', text: '| Home') }
	       
	      end
	  
	  
	  describe "Help page" do
	     before {visit help_path}
	          #it {page.should have_selector('h1', text: 'Help')}
	          #it {should have_selector('title',text:full_title('Help'))}
	          let(:heading)    { 'Help' }
	          let(:page_title) { 'Help' }
	    end
	  
	  describe "About page" do
	    	 before {visit about_path}
	           #it {should have_selector('h1', text: 'About')}
	           #it {should have_selector('title',text: full_title('About Us'))} 
	           let(:heading)    { 'About' }
	           let(:page_title) { 'About Us' }
	    end
	      
	  describe"Contact page" do 
	      before{ visit contact_path }
	      #it { should have_selector('h1',text:'Contact')}
	      #it { should have_selector('title', text:full_title('Contact'))}
	       let(:heading)    { 'Contact' }
	       let(:page_title) { 'Contact' }
	    end
	
	end
	
	
2. 我們並未去檢查頁面操作後的內容是否正確，所以我們來改一下
	spec/requests/static_pages_spec.rb 
	
		describe "Static Pages" do
			#加到這邊的底下
		end
	
	加上
	
		it "should have the right links on the layout" do
			visit root_path
	    	click_link "About"
	    	page.should have_selector 'title', text: full_title('About Us')
	    	click_link "Help"
	    	page.should have_selector 'title', text: full_title('Help')
	    	click_link "Contact"
	    	page.should have_selector 'title', text: full_title('Contact')
	    	click_link "Home"
	    	page.should_not have_selector('title', text: '| Home') 
	    	click_link "Sign up now!"
	    	page.should have_selector('title', text: full_title('Sign up'))
		end

3. 最後還有一個功課....這個我就覺得還滿酷的～

首先 要先建一個資料夾

spec/helpers

然後再建一個檔案

spec/helpers/application_helper_spec.rb
並改寫成

	require 'spec_helper'
	
	describe ApplicationHelper do
	
	  describe "full_title" do
	    it "should include the page name" do
	      full_title("foo").should =~ /foo/
	    end
	
	    it "should include the base name" do
	      full_title("foo").should =~ /^Ruby on Rails Tutorial Sample App/
	    end
	
	    it "should not include a bar for the home page" do
	      full_title("").should_not =~ /\|/
	    end
	  end
	end
	
然後把

spec/support/utilties.rb改成這樣！

	include ApplicationHelper

沒錯！你沒看錯！ 只剩一行


這邊我就不太懂了～

那個

full_title("").should_not =~ /\|/	

或是

full_title("foo").should =~ /foo/

他的意思是....那個full_title

這個function的輸入"foo" <-感覺被當成是變數

如果輸入是foo 

regexp它必須找的到foo

regexp他也必須找到前面是Ruby on Rails Tutorial Sample App開頭的

如果輸入是空的

regexp 不能找到 | 這個東東


---
layout: post
title: "Learning on RoR Tutorial - CH3 - Static Page and Add Testing"
date: 2012-06-03 12:48
comments: true
categories: ["Ruby on Rails" , "Reading"]
---

原文請參考[Ruby on Rails Tutorial Learn Rails by Example - Michael Hartl](http://ruby.railstutorial.org/chapters/static-pages?version=3.2#top)

新增專案三

	$ cd ~/rails_projects
	$ rails new sample_app --skip-test-unit
	$ mate sample_app

<!--more-->

在做sample_app時，使用--skip-test-unit是因為不用Rails的Test::Unit這個framework
要改用RSpec，來寫測試！

<!--more--> 
當然先來改一下Gemfile

	source 'https://rubygems.org'

	gem 'rails', '3.2.2'

	group :development, :test do
  		gem 'sqlite3', '1.3.5'
  		gem 'rspec-rails', '2.8.1'
	end

	# Gems used only for assets and not required
	# in production environments by default.
	group :assets do
  		gem 'sass-rails',   '3.2.4'
  		gem 'coffee-rails', '3.2.2'
  		gem 'uglifier', '1.2.3'
	end

	gem 'jquery-rails', '2.0.0'

	group :test do
  		gem 'capybara', '1.1.2'
	end

	group :production do
  		gem 'pg', '0.12.2'
	end
	
多了兩個gem :gem 'rspec-rails', '2.8.1' 和  gem 'capybara', '1.1.2'

為甚麼呢？請看：

1. This includes rspec-rails in development mode so that we have access to RSpec-specific generators, and it includes it in test mode in order to run the tests.

2.	We also include the Capybara gem, which allows us to simulate a user’s interaction with the sample application using a natural English-like syntax.
	
3.	we also must include the PostgreSQL gem in production for deployment to Heroku

OK~

	 $bundle install --without production
	 
接下來，我們必須告訴Rails使用RSpec 取代Test::Unit 

	$rails generate rspec:install

之後把code家到版本控制

	$ cp ~/rails_projects/first_app/.gitignore ~/rails_projects/sample_app/
	$ git init
	$ git add .
	$ git commit -m "Initial commit"

改README

	$ git mv README.rdoc README.md
	$ git commit -a -m "Improve the README"
	
	
現在來加一些靜態頁面進來！加上關於我、help、首頁

首先我們先checkout到新的branch

	$git checkout -b static-pages 
	
先來產生首頁和Help頁,並用Static Pages controller來控制！
	
	$rails generate controller StaticPages home help --no-test-framework


OK~

	$git add .
	$git commit -m "Add a Static Pages controller"


接下來重頭戲了！ 這也是我完全不會的東東

**寫測試！**

主要的測試有兩種

test-driven development (TDD) 也可以叫做 behavior-driven development (BDD).
	
和

unit test

TDD的意涵是：

先寫測試在寫程式，但是TDD並不完全適用在某些開發上，例如你並不確定如何解決程式問題！
it’s often useful to skip the tests and write only application code, just to get a sense of what the solution will look like. Once you see the general shape of the solution, you can then use TDD to implement a more polished version.


OK! 讓我們來測試驅動開發八！

	$rails generate integration_test static_pages
	
編輯測試文件spec/requests/static_pages_spec.rb，就好像在寫敘述一樣(這是因為RSpec uses the general malleability of Ruby to define a domain-specific language (DSL) built just for testing.) (就好像RobotFramework?!)
	
	require 'spec_helper'

	describe "Static Pages" do
  		describe "Home page" do
    		it "should have the content 'Sample App'" do
        		visit '/static_pages/home'
        		page.should have_content('Sample App')
    		end
  		end
	end
	

跑測試(別忘了要先rails s)
	
	$bundle exec rspec spec/requests/static_pages_spec.rb

咦！測試結果是錯的耶！

	Alohas-MBP:sample_app aloha$ bundle exec rspec spec/requests/static_pages_spec.rb
	F

	Failures:

  	1) Static Pages Home page should have the content 'Sample App'
     Failure/Error: page.should have_content('Sample App')
       expected there to be content "Sample App" in "SampleApp\n\nStaticPages#home\nFind me in app/views/static_pages/home.html.erb\n\n\n"
     # ./spec/requests/static_pages_spec.rb:7:in `block (3 levels) in <top (required)>'

	Finished in 0.41231 seconds
	1 example, 1 failure

	Failed examples:

	rspec ./spec/requests/static_pages_spec.rb:5 # Static Pages Home page should have the content 'Sample App'
	

OK來改一下Home Page八！

	<h1>Sample App</h1>
	<p>
  		This is the home page for the
  		<a href="http://railstutorial.org/">Ruby on Rails Tutorial</a>
  		sample application.
	</p>
	
在繼續寫測試 在剛剛那個spec/requests/static_pages_spec.rb

加上

	describe "Help page" do

    	it "should have the content 'Help'" do
      		visit '/static_pages/help'
      		page.should have_content('Help')
    	end
 	end
 
 在執行一次！發現有錯～ 這時候再去改Help.erb
 
 OK~那繼續在寫測試吧！ 請加上
 
 	 describe "About page" do
		it "should have the content 'About Us'" do
      		visit '/static_pages/about'
      		page.should have_content('About Us')
    	end
  	end
  	
 再來執行測試！
 
 靠么
 
 	Failure/Error: visit '/static_pages/about'
     ActionController::RoutingError:
       No route matches [GET] "/static_pages/about"
 
 那我就去config/routes.rb加上
 
 	get "static_pages/about"

在測試一次！

囧…

	The action 'about' could not be found for StaticPagesController
	
那我再去app/controllers/static_pages_controller.rb 加上

	def about
	end
	
再測試.....囧.....

	 Failure/Error: visit '/static_pages/about'
     ActionView::MissingTemplate:
       Missing template static_pages/about, application/about with {:locale=>[:en], :formats=>[:html], :handlers=>[:erb, :builder, :coffee]}. Searched in:
         * "/Users/aloha/rails_projects/sample_app/app/views"

再測試！

終於過了！！！

現在我們來寫標題的測試在spec/requests/static_pages_spec.rb

	 it "should have the right title" do
      visit '/static_pages/home'
      page.should have_selector('title',
                        :text => "Ruby on Rails Tutorial Sample App | Home")
    end
 	
 
 This uses the have_selector method, which checks for an HTML element (the “selector”) with the given content. In other words, the code
 
 checks to see that the content inside the <title></title> tags is "Ruby on Rails Tutorial Sample App | Home". 
 
所以我們將改寫所有測試

改成

	require 'spec_helper'

	describe "Static pages" do

  	describe "Home page" do

    it "should have the h1 'Sample App'" do
      visit '/static_pages/home'
      page.should have_selector('h1', :text => 'Sample App')
    end

    it "should have the title 'Home'" do
      visit '/static_pages/home'
      page.should have_selector('title',
                        :text => "Ruby on Rails Tutorial Sample App | Home")
    end
  	end

  	describe "Help page" do

    it "should have the h1 'Help'" do
      visit '/static_pages/help'
      page.should have_selector('h1', :text => 'Help')
    end

    it "should have the title 'Help'" do
      visit '/static_pages/help'
      page.should have_selector('title',
                        :text => "Ruby on Rails Tutorial Sample App | Help")
    end
  	end

  	describe "About page" do

    it "should have the h1 'About'" do
      visit '/static_pages/about'
      page.should have_selector('h1', :text => 'About Us')
    end

    it "should have the title 'About Us'" do
      visit '/static_pages/about'
      page.should have_selector('title',
                    :text => "Ruby on Rails Tutorial Sample App | About Us")
    end
 	end
 	
 	it "should have the h1 'Contact'" do
      visit '/static_pages/contact'
      page.should have_selector('h1', :text => 'Contact')
    end

    it "should have the title 'Contact'" do
      visit '/static_pages/Contact'
      page.should have_selector('title',
                    :text => "Ruby on Rails Tutorial Sample App | Contact")
    end
 	end
 	
 	
	end
 	
 因為希望每個頁面的長的很類似！
 
 所以直接改application.html.erb比較快！
 
 改成
 	
 	<!DOCTYPE html>
	<html>
  		<head>
    	<title>Ruby on Rails Tutorial Sample App | <%= yield(:title) %></title>
    	<%= stylesheet_link_tag    "application", :media => "all" %>
    	<%= javascript_include_tag "application" %>
    	<%= csrf_meta_tags %>
  		</head>
  		<body>
    		<%= yield %>
  		</body>
	</html>
	
因為你可以把它想成，StaticPage是繼承至Application

所以每個View分別可以改成

**Home Page** app/views/static_pages/home.html.erb

	<% provide(:title, 'Home') %>
	<h1>Sample App</h1>
	<p>
	  This is the home page for the
	  <a href="http://railstutorial.org/">Ruby on Rails Tutorial</a>
	  sample application.
	</p>

**Help Page** app/views/static_pages/help.html.erb

	<% provide(:title, 'Help') %>
	<h1>Help</h1>
	<p>
		Get help on the Ruby on Rails Tutorial at the
		<a href="http://railstutorial.org/help">Rails Tutorial help page</a>.
		To get help on this sample app, see the
		<a href="http://railstutorial.org/book">Rails Tutorial book</a>.
	</p>
**About Us Page** app/views/static_pages/about.html.erb

	<% provide(:title, 'About Us') %>
	<h1>About Us</h1>
	<p>
  		The <a href="http://railstutorial.org/">Ruby on Rails Tutorial</a>
  		is a project to make a book and screencasts to teach web development
  		with <a href="http://rubyonrails.org/">Ruby on Rails</a>. This
  		is the sample application for the tutorial.
	</p>
 
 
 這樣我就會將title這個屬性的值丟到繼承至application.html.erb的裡面！
 
 免去我改一堆一模一樣的code~
 
 耶！ 來測試吧！
 
 	$bundle exec rspec spec/requests/static_pages_spec.rb
 
 耶～成功！ OK~可以版本控制一下並merge回來了！
 
 	$ git add .
	$ git commit -m "Finish static pages"
	$ git checkout master
	$ git merge static-pages



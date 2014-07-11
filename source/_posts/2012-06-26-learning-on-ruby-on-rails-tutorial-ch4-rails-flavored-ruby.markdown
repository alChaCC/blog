---
layout: post
title: "Learning on Ruby on Rails Tutorial - CH4 - Rails-flavored Ruby"
date: 2012-06-26 10:28
comments: true
categories: [Reading,Ruby_on_Rails] 
---

修改app/helpers/application_helper.rb

	module ApplicationHelper

  	# Returns the full title on a per-page basis.       # Documentation comment
  	def full_title(page_title)                          # Method definition
    	base_title = "Ruby on Rails Tutorial Sample App"  # Variable assignment
    	if page_title.empty?                              # Boolean test
      		base_title                                      # Implicit return
    	else
      		"#{base_title} | #{page_title}"                 # String interpolation
    		end
  		end
	end
	
	
<!--more--> 
所以在**app/views/layouts/application.html.erb**就可以改成

	<!DOCTYPE html>
	<html>
	  <head>
	    <title><%= full_title(yield(:title)) %></title>
	    <%= stylesheet_link_tag    "application", :media => "all" %>
	    <%= javascript_include_tag "application" %>
	    <%= csrf_meta_tags %>
	  </head>
	  <body>
	    <%= yield %>
	  </body>
	</html>


一樣寫個測試吧！**spec/requests/static_pages_spec.rb**

	require 'spec_helper'
	
	describe "Static pages" do
	
	  describe "Home page" do
	
	    it "should have the h1 'Sample App'" do
	      visit '/static_pages/home'
	      page.should have_selector('h1', :text => 'Sample App')
	    end
	
	    it "should have the base title" do
	      visit '/static_pages/home'
	      page.should have_selector('title',
	                        :text => "Ruby on Rails Tutorial Sample App")
	    end
	
	    it "should not have a custom page title" do
	      visit '/static_pages/home'
	      page.should_not have_selector('title', :text => '| Home')
	    end
	  end
	  

執行測試！

	$ bundle exec rspec spec/requests/static_pages_spec.rb

Commit 到 git裡面

	git commit -am "Add a title helper"
	


之後都是講一些Ruby的語法！

內容請看[Rails-flavored Ruby](http://ruby.railstutorial.org/chapters/rails-flavored-ruby?version=3.2#top)

因為我K過Ruby for rails 

大概喵過文章，應該都還知道～

這章好短，爽～



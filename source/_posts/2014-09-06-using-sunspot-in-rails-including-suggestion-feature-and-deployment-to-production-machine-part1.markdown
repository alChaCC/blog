---
layout: post
title: "[HOWTO] Using Sunspot(Solr) in Rails including easy suggestion feature and deployment to production environment - Part1"
date: 2014-09-06 00:06:35 +0800
comments: true
categories: ["Ruby on Rails","Search"]
keywords: "Ruby on Rails, Solr-powered search, full text search, sunspot, deploy, suggestion, auto complete,中文, 推薦"
description: "Using Sunspot in Rails including suggestion feature(using solmate) and deployment in production environment"  
---
 
這系列文章，你可以學到：

	1. 如何使用sunspot，作為你的全站全文搜尋
	2. 如何使用work around的方式達成sunspot搜尋的推薦字詞 - 利用solmate
	3. 如何將sunspot deploy到production 機器，並且自動做index
	4. 簡單調整sunspot
	
<!-- more -->

首先，當然是要感謝這些文章：

1. Jimmy 高手：	[在 Rails 中使用 Solr 做全文搜尋](http://gogojimmy.net/2012/01/25/full-text-search-in-rails-with-solr)

2. [FAST AUTOCOMPLETE SEARCH TERMS - RAILS](http://josephndungu.com/tutorials/fast-autocomplete-search-terms-rails)

3. [Capistrano Tasks to setup and interact with SolR and SunSpot](https://gist.github.com/cec/5508303)


# Part 1. 如何使用sunspot，作為你的全站全文搜尋


## Step1. 使用gem 

[手做] 修改 **Gemfile**

	gem 'sunspot_rails'
	gem 'sunspot_solr'

做完後，別忘了

	bundle install

## Step2. 建立sunspot 設定檔

	rails generate sunspot_rails:install
	
他會幫你建立 **config/sunspot.yml**

	production:
	 solr:
	   hostname: localhost
	   port: 8983
	   log_level: WARNING
	   path: /solr/production
	   # read_timeout: 2
	   # open_timeout: 0.5
	
	development:
	 solr:
	   hostname: localhost
	   port: 8982
	   log_level: INFO
	   path: /solr/development
	
	test:
	 solr:
	   hostname: localhost
	   port: 8981
	   log_level: WARNING
	   path: /solr/test
	   

## Step3. 在model 建立搜尋功能

假設我們現在有個 產品的model叫做： **Product** ，我們希望它的產品名稱、描述、價錢、建立時間、是否上架列為我們要搜尋的項目(也是要建index的部分)

所以我們需要在model加上

	searchable do
		....
	end

就像：**app/models/product.rb**

	# == Schema Information
	#
	# Table name: products
	#
	#  id                 :integer          not null, primary key
	#  name               :string(20)
	#  description        :text             not null
	#  price              :integer
	#  is_on_the_shelf    :boolean
	#  created_at                 :datetime
	#  updated_at                 :datetime
	#
	
	class Product < ActiveRecord::Base	
	  searchable do
	    text :description,
	    string :name
	    integer :price
	    time :created_at
	    boolean :is_on_the_shelf
	  end
	end


## Step 4. 在controller建立搜尋動作

接下來，我們會透過controller來取得view的搜尋字，然後把搜尋結果印出

假設我們希望在每一頁上方都有 搜尋bar給使用者做搜尋，在這邊我是假設用product本身的controller來做

在 **app/controllers/products_controller.rb**

	class ProductsController < ApplicationController
		def search
			@search = Product.search do
				fulltext params[:keyword] do 
				  fields(:description, :name => 2.0)
				  query_phrase_slop 1
				end
				with(:is_on_the_shelf, true)
				with(:created_at).less_than(Time.zone.now)
			end
			@products = @search.results
		end
	end
	
上面是什麼意思呢？

首先，起手式 - 使用搜尋引擎來做等一下的搜尋

	@search = Product.search do
				....
			end
再來，
	
	fulltext params[:keyword] do 
		fields(:description, :name => 2.0) 
		# => 全文搜尋 描述 和 名稱這兩個欄位，而且，名稱的欄位重要度比較高
		query_phrase_slop 1
		# => 中間有空一個字也成立，所以 “great big pizza” 也會符合 "great pizza這個字"
	end

最後，條件部分：

	with(:is_on_the_shelf, true)  
	# => 我要找所有上架的商品
	with(:created_at).less_than(Time.zone.now)
	# => 我要找所有建立時間，小於現在時間的商品

還有一件事：

	@products = @search.results 
	# => 這樣會拿到Array 裡頭有預設 30 個 選出的Product

## Step 5. 在route建立搜尋link

**config/routes.rb**

	get '/search', to: 'products#search'
	
## Step 6. 建立View

	= form_tag search_path, :method => :get, class: 'search' do
    .input-box
      = text_field_tag :keyword, params[:keyword], class: 'input-search'
      = button_tag "搜尋", class: 'icon-search btn btn-primary'

## Step 7. 恭喜本機端大致完成，只剩跑起來

注意歐！這邊要做index歐～ 不然不會生效！

	rake sunspot:solr:start
	rake sunspot:reindex 
	
ps. 當你跑完 **rake sunspot:solr:start**後，你會發現產生很多檔案，基本上我只有追蹤

**solr/conf/***底下的設定檔而已

## Step 7-1. 如果在做index時，你有遇到 “illegal character”

請加上：

**config/initializers/sunspot_fix_illegal_chars.rb**

	module Sunspot
	  # 
	  # DataExtractors present an internal API for the indexer to use to extract
	  # field values from models for indexing. They must implement the #value_for
	  # method, which takes an object and returns the value extracted from it.
	  #
	  module DataExtractor #:nodoc: all
	    # 
	    # AttributeExtractors extract data by simply calling a method on the block.
	    #
	    class AttributeExtractor
	      def initialize(attribute_name)
	        @attribute_name = attribute_name
	      end
	
	      def value_for(object)
	        Filter.new( object.send(@attribute_name) ).value
	      end
	    end
	
	    # 
	    # BlockExtractors extract data by evaluating a block in the context of the
	    # object instance, or if the block takes an argument, by passing the object
	    # as the argument to the block. Either way, the return value of the block is
	    # the value returned by the extractor.
	    #
	    class BlockExtractor
	      def initialize(&block)
	        @block = block
	      end
	
	      def value_for(object)
	        Filter.new( Util.instance_eval_or_call(object, &@block) ).value
	      end
	    end
	
	    # 
	    # Constant data extractors simply return the same value for every object.
	    #
	    class Constant
	      def initialize(value)
	        @value = value
	      end
	
	      def value_for(object)
	        Filter.new(@value).value
	      end
	    end
	
	    # 
	    # A Filter to allow easy value cleaning
	    #
	    class Filter
	      def initialize(value)
	        @value = value
	      end
	      def value
	        strip_control_characters @value
	      end
	      def strip_control_characters(value)
	        return value unless value.is_a? String
	
	        value.chars.inject("") do |str, char|
	          unless char.ascii_only? and (char.ord < 32 or char.ord == 127)
	            str << char
	          end
	          str
	        end
	
	      end
	    end
	
	  end
	end


# Part 2. 如何利用solmate使用達成sunspot搜尋的推薦字詞

因為我實在找不太到 sunspot的設定方法，所以我只好用work around的方式做到這件事情

我是使用 solmate這個 gem 來達成自動推薦。

由於solmate是使用redis當作臨時儲存的空間

若是redis 重啟.....那就gg了，你之前建的推薦資料都會不見。

所以，我有另外新建一個model: **Keyword** 去記錄使用者搜尋過的關鍵字


那就開始吧


## Step 1. 加上Gem

首先，要先加入gem到 **Gemfile**


	gem 'rack-contrib'
	gem 'soulmate', :require => 'soulmate/server'

別忘了

	bundle install
	
再來你要確保你啟用**redis-server**

	redis-server

## Step 2. 建立 Keyword model

	rails g model keyword
	
然後 migration檔案：(這邊的結構單純就是為了soulmate設計)

	class CreateKeywords < ActiveRecord::Migration
	  def change
	    create_table :keywords do |t|
	    	t.string :name
	    	t.integer :score
	    	t.string :url
	    	t.string :subtitle
	    	t.string :keyword_type
	      t.timestamps
	    end
	  end
	end

別忘了

	rake db:migrate

## Step 3. 將使用者輸入的關鍵字，記錄到solmate和keyword model [重要！]

還記得，剛剛part 1的 Step 4，基本上我們是將下面的code加進去
	
	# 如果有搜尋結果我們在記錄關鍵字 
	if @products.present?	
		@keyword = Keyword.find_or_create_by(name: "#{params[:keyword]}") do |k|
			k.score = 0
			k.url = "/search?keyword=#{params[:keyword]}"
			k.keyword_type = "Keyword"
		end
		@keyword.update_attribute(:score, @keyword.score+=1) #代表多搜尋了一次
		remove_from_soulmate(@keyword) #先移除soulmate裡面的記錄
		load_into_soulmate(@keyword) 	#更新新的紀錄
	end
	
	private

	def load_into_soulmate(keyword)
    	loader = Soulmate::Loader.new("#{keyword.keyword_type}")
    	loader.add("term" => keyword.name, "id" => keyword.id, "score" => keyword.score, "data" => {
      "link" => "#{keyword.url}"
      })
	end
	
	def remove_from_soulmate(keyword)
		loader = Soulmate::Loader.new("#{keyword.keyword_type}")
		loader.remove("id" => keyword.id)
	end

所以在 **app/controllers/products_controller.rb**，變成了

	class ProductsController < ApplicationController
		def search
			@search = Product.search do
				fulltext params[:keyword] do 
				  fields(:description, :name => 2.0)
				  query_phrase_slop 1
				end
				with(:is_on_the_shelf, true)
				with(:created_at).less_than(Time.zone.now)
			end
			@products = @search.results
			
			# 如果有搜尋結果我們在記錄關鍵字 
			if @products.present?	
				@keyword = Keyword.find_or_create_by(name: "#{params[:keyword]}") do |k|
					k.score = 0
					k.url = "/search?keyword=#{params[:keyword]}"
					k.keyword_type = "Keyword"
				end
				@keyword.update_attribute(:score, @keyword.score+=1) #代表多搜尋了一次
				remove_from_soulmate(@keyword) #先移除soulmate裡面的記錄
				load_into_soulmate(@keyword) 	#更新新的紀錄
			end
			
			private
		
			def load_into_soulmate(keyword)
		    	loader = Soulmate::Loader.new("#{keyword.keyword_type}")
		    	loader.add("term" => keyword.name, "id" => keyword.id, "score" => keyword.score, "data" => {
		      "link" => "#{keyword.url}"
		      })
			end
			
			def remove_from_soulmate(keyword)
				loader = Soulmate::Loader.new("#{keyword.keyword_type}")
				loader.remove("id" => keyword.id)
			end
			return @products
		end
	end

## Step 4. 當使用者在輸入關鍵字時，進行推薦

這邊我們需要借助 js了，這邊我就直接copy上面的參考資料了

	var ready = function(){
	  var render, select;
	 
	  render = function(term, data, type) {
	    return term;
	  }
	 
	  select = function(term, data, type){
	    // populate our search form with the autocomplete result
	    $('#keyword').val(term);
	   
	    // hide our autocomplete results
	    $('ul#soulmate').hide();
	 
	    // then redirect to the result's link 
	    // remember we have the link in the 'data' metadata
	    return window.location.href = data.link
	  }
	 
	  $('#keyword').soulmate({
	    url: '/autocomplete/search',
	    types: ['keyword'],
	    renderCallback : render,
	    selectCallback : select,
	    minQueryLength : 2,
	    maxResults     : 10
	  })
	 
	 
	}
	// when our document is ready, call our ready function
	$(document).ready(ready);
	 
	// if using turbolinks, listen to the page:load event and fire our ready function
	$(document).on('page:load', ready);
	
## Step 5. 別忘了，補上 JQUERY 和 SOULMATE.JS

請參考： https://github.com/mcrowe/soulmate.js

下載：https://github.com/mcrowe/soulmate.js/blob/master/src/compiled/jquery.soulmate.js

因為它屬於第三方資源，所以我是把它放在

**vender/assets/javascripts/jquery.soulmate.js**

另外別忘了在你global的 **app/assets/javascripts/application.js**確保有

	//= require jquery
	//= require jquery_ujs
	//= require jquery.soulmate
	
## Step 6. 還有route

**config/routes.rb**

	mount Soulmate::Server, :at => "/autocomplete"
	
## Step 7. CSS的部分，就請參考

[FAST AUTOCOMPLETE SEARCH TERMS - RAILS](http://josephndungu.com/tutorials/fast-autocomplete-search-terms-rails)


待續......


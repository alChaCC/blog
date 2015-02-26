---
layout: post
title: "[HowTo] - Implement autocomplete feature in elasticsearch using soulmate.js in Ruby on Rails application"
date: 2014-12-03 07:50:57 +0800
comments: true
categories: ["Elasticsearch", "Ruby on Rails","Search"]
keywords: "suggest, elasticsearch, autocomplete, ruby on rails, search, 中文"
description: “this ariticle will show you how to build up autocomplete feature with elasticsearch using soulmate 這篇文章，你可以知道如何透過elasticsearch 達成自動化推薦的功能以及如何將此功能與 soulmate.js結合”
---

先說明一下需求，你希望使用者在搜尋框框打字的時，希望可以給他推薦就像....

<img alt="elasticsearch autocomple sample" src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/%5BHowTo%5D%20-%20Implement%20autocomplete%20feature%20in%20elasticsearch%20using%20soulmate.js%20in%20Ruby%20on%20Rails%20application/f1.png">

故這篇文章，你可以知道，如何透過elasticsearch 達成 自動化推薦的功能！

以及 如何將此功能與 soulmate.js結合 (因為我之前是用soulmate來實作，但是會推薦的詞，一定是user有打過有搜尋過的字)

<!-- more -->

## Step0. 你可以先玩看看 soulmate.js

[FAST AUTOCOMPLETE SEARCH TERMS - RAILS](http://josephndungu.com/tutorials/fast-autocomplete-search-terms-rails)

另外這篇主要是參考

[Adding search and autocomplete to a Rails app with Elasticsearch](https://shellycloud.com/blog/2013/10/adding-search-and-autocomplete-to-a-rails-app-with-elasticsearch)

## Step1. Searchkick

下面加入到 **_Gemfile_**:

	gem 'searchkick'
	

## Step2. Routing

因為我是要在產品搜尋時做自動推薦，所以在product的routing 加上 autocomplete

下面加入到 **_config/routes.rb_**
	
	  #下面那行之前沒有elasticsearch幫忙，直接用soulmate實作時的做法
	  #mount Soulmate::Server, :at => "/autocomplete" 
	  
	  resources :products do
	    collection do
	      get :autocomplete
	      get :search
	    end
	  end 

## Step3. Model

為了要吐給soulmate json (你可以參考：https://github.com/seatgeek/soulmate#loading-items)

下面加上在**_app/models/product.rb_** 

	# 讓elasticsearch知道這兩個欄位要做autocomplete功能(他會針對這兩個欄位做不一樣的index)
	searchkick autocomplete: ['name', 'description']
	
	
	# 到時候要吐給soulmate的json格式，你可以參考：https://github.com/seatgeek/soulmate#loading-items)

	def to_soulmate
	    {
	      "term" => "#{brand.name}-#{name}",
	      "id" => "#{product_id}",
	      "score" => "",
	      "data" => {
	        "link" => "/product_searchs/product?keyword=#{name}"
	      }
	    }
  	end


另外我有create 一個**keyword**的model這邊就不特別說了～controller會用到

## Step4. Controller

關鍵！

加在 **_app/controllers/products_controller.rb_**

	def autocomplete
		# searchkick做autocomplete
		@products = Product.search params[:term], limit: 10, fields: [{"description" => :word},{"name" => :word}]
		
		# 為了拼出讓soulmate知道的url
		callback_str = params[:callback]
		return_data = {
			"term" =>  "#{params[:term]}", 
			"results" => {
				"keyword" =>  @products.map(&:to_soulmate)
			}
		}
		# 以下是為了拼出給soulmate的callback
		render json: callback_str + "(" + "#{return_data.to_json}" + ")"
	end
	
	def search
		if params[:keyword].present?
			@products = Product.searchkick(params[:keyword],sort,search_page)

			if @products.present?
				@keyword = Keyword.find_or_create_by(name: "#{params[:keyword]}") do |k|
					k.score = 0
					k.url = "/products/search?keyword=#{params[:keyword]}"
					k.keyword_type = "Keyword"
				end
				@keyword.update_attribute(:score, @keyword.score+=1) #代表多搜尋了一次
				# remove_from_soulmate(@keyword) #已用不到
				# load_into_soulmate(@keyword) 	#已用不到
			end
		end
	end
	
	def load_into_soulmate(keyword)
    	loader = Soulmate::Loader.new("#{keyword.keyword_type}")
    	loader.add("term" => keyword.name, "id" => keyword.id, "score" => keyword.score, "data" => { "link" => "#{keyword.url}"})
  	end

  	def remove_from_soulmate(keyword)
		loader = Soulmate::Loader.new("#{keyword.keyword_type}")
	  loader.remove("id" => keyword.id)
	end

	
這邊很重要的是，你使用soulmate.js去做autocomplete時，他會丟出一串callback給server，基本上你的response也要包含這個callback，我覺得很像jsonp

[注意！] 我把load_into_soulmate還有remove_from_soulmate留著只是單純給你看之前的做法，

但是我還是有保留keyword的model這樣我才知道哪些關鍵字被打了最多次！(當然你可以用GA但是由於隱私權設定，你很多會看到not provided....囧)

## Step5. View

加上你想要搜尋的頁面，我們希望使用者可以在所有網頁都看到，所以是放在

**_app/views/layouts/application.html.slim_**

	= text_field_tag 'keyword', '輸入產品關鍵字', class: "form-control"
	= button_tag "搜尋", id: "product_search", class: "btn btn-default"

## Step6. javascript

	# 這是要給product_search點擊後使用
	$("#product_search").click(function(){
		window.location = '<%= search_products_path %>?keyword=' + $("#keyword").val();
	})
	
	#這是soulmate用法：注意我把url改掉了！
	$('#keyword').soulmate({
    	url: '/products/autocomplete',
    	types: ['product','review','keyword'],
    	renderCallback : render,
    	selectCallback : select,
    	minQueryLength : 1,
    	maxResults     : 10,
    	timeout:    5000
  	})
  	
  	
	
## 完成！！！


	
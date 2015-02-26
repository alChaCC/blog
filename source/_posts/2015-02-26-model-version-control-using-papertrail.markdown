---
layout: post
title: "[Ruby on Rails] Model Version control using papertrail"
date: 2015-02-26 16:30:53 +0800
comments: true
categories: ["Ruby on Rails"]
keywords: "papertrail, Ruby on Rails, 中文"
description: "Rails加入Model版本控制 - 使用papertrail"
---
## Why use papertrail ?

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Rails%E5%8A%A0%E5%85%A5Model%E7%89%88%E6%9C%AC%E6%8E%A7%E5%88%B6/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202015-01-06%20%E4%B8%8A%E5%8D%8811.57.23.png" alt="ruby toolbox - active record versioning">

## Step1. Add lib

**Gemfile**

	gem 'paper_trail', '~> 3.0.6'
	

## Step2. create a migration 

**On Terminal**

	bundle exec rails generate paper_trail:install
	
他會建立，一個叫做**versions**的表

## Step3. migrate

	bundle exec rake db:migrate
	
## Step4. Done

把 **has_paper_trail** 加上你想要追蹤的model


## 應用部分

### 若是想要不同model使用不同追蹤table?  

假設我想要**product**有自己的versions表

* Step1. 

		rails g model product_version 
	
* 貼上

		class CreateProductVersions < ActiveRecord::Migration
		  def change
		    create_table :product_versions do |t|
		      t.string   :item_type, :null => false
		      t.integer  :item_id,   :null => false
		      t.string   :event,     :null => false
		      t.string   :whodunnit
		      t.text     :object
		      t.datetime :created_at
		      # t.string   :author_username 如果你需要自訂一些欄位讓他記錄，也可以在migration這邊加
		    end
		    add_index :product_versions, [:item_type, :item_id]
		    end
		  end
		end


ps. 這就是他本身內建會產生的欄位，只是我們手動把它copy一份出來

* 別忘了

		bundle exec rake db:migrate

* 改model **ProductVersion**

		class ProductVersion < PaperTrail::Version
		  self.table_name = :product_versions
		end


* 改model **Product**

		class Product < ActiveRecord::Base
			...
  			has_paper_trail class_name: 'ProductVersion'
			...
		end


### 若是想要知道誰動了資料?

 假設你有使用**devise**，然後是寫在後台

請加在 **controller/admin/admin_controller.rb**

	def user_for_paper_trail
    	admin_signed_in? ? current_admin.email : 'System'
  	end
  	
假使你在前台，你可能需要這樣寫

	def user_for_paper_trail
    	user_signed_in? ? current_user.email : 'Public User'
  	end

### 若某個動作不想被追蹤

	@product.without_versioning do
	  @product.update_attributes :created_at => Time.now
	end

### 若要刪除某個versions從哪天到某天

方法一：**下SQL**

	delete from versions where created_at < 2014-01-01;
	
方法二：**在rails c底下**

	PaperTrail::Version.delete_all ["created_at < ?", 1.year.ago]
	


---
layout: post
title: "Integrate Ruby on Rails with Google Analytics API"
date: 2015-04-09 22:32:24 +0800
comments: true
categories: ["Google Analytics", "Ruby on Rails", "API", "MongoDB"] 
keywords: "Google Analytics, API, 中文, Ruby on Rails, google-api-client, MongoDB"
description: "this article show you how to integrate google analytics api with Ruby on Rails application"
---

In this article, I try to get some Google Analytics data via Google API. Then, I saved data into MongoDB waiting for further calculation.

And you are able to learn 

1. How I do Google API pagination
2. How I use module to build flexible function
3. How I use Google Query Explorer to speed up development
4. How to apply for google API access

Let's check it out.   

<!-- more -->

## Step 1. Apply Google Analytics API access authorization

### 1-1 go to [Google API console](https://code.google.com/apis/console/)
 
### 1-2 Find Google Analytics API
 
 <img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Integrate%20Ruby%20on%20Rails%20with%20Google%20Analytics%20API/find_google_api.png" alt="find google api">
 

### 1-3 Enable Google Analytics API
 <img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Integrate%20Ruby%20on%20Rails%20with%20Google%20Analytics%20API/Enable%20Google%20Analytic%20API.png" alt="enable google analytics API">
 
 
### 1-4 Create New Client ID

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Integrate%20Ruby%20on%20Rails%20with%20Google%20Analytics%20API/Create%20New%20Client%20ID.png" alt="Create New Client ID">

### 1-5 Choose client type 

Since this is for server-to-server usage, I choose this 

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Integrate%20Ruby%20on%20Rails%20with%20Google%20Analytics%20API/Choose%20client%20type.png" alt="Choose client type">


### 1-6 Download key

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Integrate%20Ruby%20on%20Rails%20with%20Google%20Analytics%20API/download%20key.png" alt="download key">

ps. Since I use Ruby on Rails, so I put it in **config/ga_api_key_20150408.p12**

### 1-7 Add API user into your GA user group

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Integrate%20Ruby%20on%20Rails%20with%20Google%20Analytics%20API/Add%20API%20user%20into%20your%20GA%20user%20group.png">


## 2. [TIPS] Use Google Query Explorer to speed up development

### 1. Go to [Google Query Explorer](https://ga-dev-tools.appspot.com/query-explorer/)

### 2. Get your view id

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Integrate%20Ruby%20on%20Rails%20with%20Google%20Analytics%20API/Get%20your%20view%20id.png">

### 3. Try your query parameter first and know how your data look like

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Integrate%20Ruby%20on%20Rails%20with%20Google%20Analytics%20API/Try%20your%20query%20parameter%20first.png"> 

And it provides a easy tool that you don't need to remember any parameters.

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Integrate%20Ruby%20on%20Rails%20with%20Google%20Analytics%20API/parameter%20tool.png">  


## 3. Let's write a sample code

### 3-1 Add gem to Gemfile

	gem 'google-api-client'
	
### 3-2 create a rb file 

I update some codes copied from this page.[https://gist.github.com/joost/5344705](https://gist.github.com/joost/5344705)

	  require 'google/api_client'
	  require 'date'
	  
	  client = Google::APIClient.new(:application_name => 'Urcosme-GA-sync', :application_version => '1')
	  
	  key_file = File.join("#{Rails.root}/config", 'ga_api_key_20150408.p12')
	  key = Google::APIClient::PKCS12.load_key(key_file, 'notasecret')
	  service_account = Google::APIClient::JWTAsserter.new(
	      'hello@developer.gserviceaccount.com',
	      ['https://www.googleapis.com/auth/analytics.readonly', 'https://www.googleapis.com/auth/prediction'],
	      key)
	  client.authorization = service_account.authorize
	
	  analytics = client.discovered_api('analytics', 'v3')
	
	  parameters = {
	        'ids'         => "ga:12345",
	        'start-date'  => (Date.today - 30).strftime("%Y-%m-%d"),
	        'end-date'    => Time.now.strftime("%Y-%m-%d"),
	        'metrics'     => "ga:avgTimeOnPage",
	        'filters'     => "ga:pagePath=~/"
	      }
	  result = client.execute(:api_method => analytics.data.ga.get, :parameters => parameters)


This sample code demonstrates how **google-api-client** work.
However, I need to fetch different kinds of data such as specific pageviews, event, and campaign. I have to refactor it.

## 4. Let's build a flexible code

## 4-1 create a module file: "ga.rb" in /lib/

In above code, it can be seperated to 2 parts. One is uniform part, the other is variable part.


Unchange part

	@client = Google::APIClient.new(:application_name => 'Urcosme-GA-sync', :application_version => '1')
	key_file = File.join("#{Rails.root}/config", 'ga_api_key_20150408.p12')
	key = Google::APIClient::PKCS12.load_key(key_file, 'notasecret')
	service_account = Google::APIClient::JWTAsserter.new(
		      'hello@developer.gserviceaccount.com',
		      ['https://www.googleapis.com/auth/analytics.readonly', 'https://www.googleapis.com/auth/prediction'],
		      key)
	@client.authorization = service_account.authorize
	@analytics = @client.discovered_api('analytics', 'v3')
		    

Change part. In this code, I already write some default parameters. 
But, it can be rewrite in other place. 

	@data_date = Date.today - 1
	@parameters = {
		'ids'         => "ga:12345",
		'start-date'  => @data_date.strftime("%Y-%m-%d"),
		'end-date'    => @data_date.strftime("%Y-%m-%d"),
		'metrics'     => "",
		'dimensions'  => "",
		'max-results' => "10000"
	}


And the whole code show as below. 

**lib/ga.rb**


	require 'google/api_client'
	require 'date'
	module GoogleAnalytic
	 
	  # 每一個GA API執行前，需要初始化
	  def initialize_ga
	    @client = Google::APIClient.new(:application_name => 'Urcosme-GA-sync', :application_version => '1')
	    key_file = File.join("#{Rails.root}/config", 'ga_api_key_20150408.p12')
	    key = Google::APIClient::PKCS12.load_key(key_file, 'notasecret')
	    service_account = Google::APIClient::JWTAsserter.new(
	      'hello@developer.gserviceaccount.com',
	      ['https://www.googleapis.com/auth/analytics.readonly', 'https://www.googleapis.com/auth/prediction'],
	      key)
	    @client.authorization = service_account.authorize
	    @analytics = @client.discovered_api('analytics', 'v3')
	    @data_date = Date.today - 1
	    @parameters = {
	        'ids'         => "ga:12345",
	        'start-date'  => @data_date.strftime("%Y-%m-%d"),
	        'end-date'    => @data_date.strftime("%Y-%m-%d"),
	        'metrics'     => "",
	        'dimensions'  => "",
	        'max-results' => "10000"
	      }
	  end
	
	  # 將資料儲存到MongoDB，請複寫我
	  def sync_to_db(result)
	  end
	end
	
	
## 4-2 let's Rails application know our lib

**config/application.rb**

	module MyAwesomeApp
	  class Application < Rails::Application
	    config.autoload_paths += %W(#{config.root}/lib)	  end
	end
	
## 4-3 create a model to save API data

Now I want to get all our campaign data. So I create ...

ps. I use MongoDB as database. 

**app/models/ga_campaign.rb**

	class GACampaign
	  include GoogleAnalytic
	  include Mongoid::Document
	  include Mongoid::Timestamps
	  field :campaign_name, type: String      # 廣告活動名稱
	  field :campaign_source, type: String    # 廣告活動來源	  
	  field :campaign_medium, type: String    # 廣告活動媒介
	  field :campaign_content, type: String   # 廣告活動內容
	  field :session, type: Integer
	  field :pageview, type: Integer
	  field :data_date, type: Date            # 原始資料的時間
	
	  def get_campaign_from_ga_api
	  	initialize_ga
	    @parameters['metrics'] = "ga:pageviews,ga:sessions"
	    @parameters['dimensions'] = "ga:campaign,ga:source,ga:medium,ga:adContent"
	    @parameters['filters'] = "ga:campaign!=(not set)"
	    sync_to_db(@parameters)
	  end
	
	  def sync_to_db(parameters)
	  	 request = {
      		:api_method => @analytics.data.ga.get,
      		:parameters => parameters
    	 }
    	result = @client.execute(request)
	    result.data.rows.each do |array_data|
	        GACampaign.create(campaign_name:    array_data[0], 
	                          campaign_source:  array_data[1], 
                              campaign_medium:  array_data[2],
                              campaign_content: array_data[3],
                              session:          array_data[4],
                              pageview:         array_data[5],
                              data_date:        @data_date)
	    end
	  end
	end


But.... if result is more than max-result (according to google, maximun is 10000 [see google doc](https://developers.google.com/analytics/devguides/reporting/core/v3/reference#maxResults))

How can I do paginate?

## 4-4 Google API pagination

Since, this method will be used in every "GA model" so I put it in **lib/ga.rb**

according to GA document

> If not supplied, the starting index is 1. (Result indexes are 1-based. That is, the first row is row 1, not row 0.) Use this parameter as a pagination mechanism along with the max-results parameter for situations when totalResults exceeds 10,000 and you want to retrieve rows indexed at 10,001 and beyond.

here is my method. Not quiet good, but it's working. 

	def query_paginate(parameters)
	     request = {
	      :api_method => @analytics.data.ga.get,
	      :parameters => parameters
	    }
	    count = 0
	    loop do
	      result = @client.execute(request)
	      sync_to_db(result)
	      max_count = result.data.total_results / parameters["max-results"].to_i
	      break if count == max_count
	      count += 1
	      request[:parameters]["start-index"] = parameters["max-results"].to_i * count + 1
	    end
	  end


let's see full code.

	require 'google/api_client'
	require 'date'
	module GoogleAnalytic
	 
	def initialize_ga
	    @client = Google::APIClient.new(:application_name => 'Urcosme-GA-sync', :application_version => '1')
	    key_file = File.join("#{Rails.root}/config", 'ga_api_key_20150408.p12')
	    key = Google::APIClient::PKCS12.load_key(key_file, 'notasecret')
	    service_account = Google::APIClient::JWTAsserter.new(
	      'hello@developer.gserviceaccount.com',
	      ['https://www.googleapis.com/auth/analytics.readonly', 'https://www.googleapis.com/auth/prediction'],
	      key)
	    @client.authorization = service_account.authorize
	    @analytics = @client.discovered_api('analytics', 'v3')
	    @data_date = Date.today - 1
	    @parameters = {
	        'ids'         => "ga:12345",
	        'start-date'  => @data_date.strftime("%Y-%m-%d"),
	        'end-date'    => @data_date.strftime("%Y-%m-%d"),
	        'metrics'     => "",
	        'dimensions'  => "",
	        'max-results' => "10000"
	      }
	  end
	
	  # 將資料儲存到MongoDB，請複寫我
	  def sync_to_db(result)
	  end
	
	  # 如果API存取，外加換頁功能，因為GA一次request最多一萬筆資料
	  def query_paginate(parameters)
	     request = {
	      :api_method => @analytics.data.ga.get,
	      :parameters => parameters
	    }
	    count = 0
	    loop do
	      result = @client.execute(request)
	      sync_to_db(result)
	      max_count = result.data.total_results / parameters["max-results"].to_i
	      break if count == max_count
	      count += 1
	      request[:parameters]["start-index"] = parameters["max-results"].to_i * count + 1
	    end
	  end
	end


### 4-5 refactor **app/models/ga_campaign.rb**

	class GACampaign
	  include GoogleAnalytic
	  include Mongoid::Document
	  include Mongoid::Timestamps
	  field :campaign_name, type: String      # 廣告活動名稱
	  field :campaign_source, type: String    # 廣告活動來源
	  field :campaign_medium, type: String    # 廣告活動媒介
	  field :campaign_content, type: String   # 廣告活動內容
	  field :session, type: Integer
	  field :pageview, type: Integer
	  field :data_date, type: Date            # 原始資料的時間
	
	  def get_campaign_from_ga_api
	  	initialize_ga
	    @parameters['metrics'] = "ga:pageviews,ga:sessions"
	    @parameters['dimensions'] = "ga:campaign,ga:source,ga:medium,ga:adContent"
	    @parameters['filters'] = "ga:campaign!=(not set)"
	    sync_to_db(@parameters)
	  end
	
	  def sync_to_db(result)
	  	    result.data.rows.each do |array_data|
	        GACampaign.create(campaign_name:    array_data[0], 
	                          campaign_source:  array_data[1], 
                              campaign_medium:  array_data[2],
                              campaign_content: array_data[3],
                              session:          array_data[4],
                              pageview:         array_data[5],
                              data_date:        @data_date)
	    end
	  end
	end


### 4-6 how to use

	ga_campaign = GACampaign.new
	ga_campaign.get_campaign_from_ga_api
	
### 4-7 other example: fetch GA Event data

The things I have to change are **@parameters** and **sync\_to\_db**

It's easy, right~

**app/models/ga_event.rb**

	class GAEvent
	  include GoogleAnalytic
	  include Mongoid::Document
	  include Mongoid::Timestamps
	  field :event_category, type: String      # 事件類別
	  field :event_label, type: String         # 事件標籤
	  field :event_action, type: String        # 事件動作
	  field :total_events, type: Integer       
	  field :unique_events, type: Integer
	  field :data_date, type: Date            # 原始資料的時間
	
	  def get_event_from_ga_api
	  	initialize_ga
	    @parameters['metrics'] = "ga:totalEvents,ga:uniqueEvents"
	    @parameters['dimensions'] = "ga:eventCategory,ga:eventLabel,ga:eventAction"
	    @parameters['filters'] = "ga:eventCategory==test"
	    query_paginate(@parameters)
	  end
	
	  def sync_to_db(result)
	    result.data.rows.each do |array_data|
	      GAEvent.create(event_category:      array_data[0], 
	                     event_label:        array_data[1], 
                         event_action:       array_data[2],
                         total_events:       array_data[3],
                         unique_events:      array_data[4],
                         data_date:        @data_date)
	      
	    end
	  end
	
	end

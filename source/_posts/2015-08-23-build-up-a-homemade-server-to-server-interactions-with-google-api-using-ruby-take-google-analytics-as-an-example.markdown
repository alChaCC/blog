---
layout: post
title: "Build up a homemade server-to-server interactions with Google API using Ruby - Take Google Analytics As An Example"
date: 2015-08-23 15:10:37 +0800
comments: true
categories: ["Ruby on Rails", "Google Analytics"]
keywords:  "Google Analytics, API, 中文, Ruby on Rails, homemade"
description: "this article show you how to make google analytics api with Ruby on Rails application by yourself"
---

Since 'google-api-ruby-client' make a big change from [0.8 to 0.9](https://github.com/google/google-api-ruby-client/blob/master/MIGRATING.md) when my project is running out of time, and also I met this [issue](https://github.com/google/google-api-ruby-client/issues/253), So, I make a this decision, let's build a API client.

This implementation refer to Google [guideline](https://developers.google.com/identity/protocols/OAuth2ServiceAccount)

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/build%20up%20server-to-server%20interactions%20with%20Google%20API/Google%20API%20server-to-server.png">

<!--more-->

## Step1. Preparation

###1. Create a Service Account

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/build%20up%20server-to-server%20interactions%20with%20Google%20API/Add%20Credentials.png" alt="add credential">

###2. Download JSON file
 
<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/build%20up%20server-to-server%20interactions%20with%20Google%20API/Download%20JSON.png" alt="Download JSON File">

And I put JSON file into **config** folder.
 
###3. Copy a Email and Add to Google Analytics 

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/build%20up%20server-to-server%20interactions%20with%20Google%20API/Remember%20your%20Email%20.png">

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/build%20up%20server-to-server%20interactions%20with%20Google%20API/Add%20email%20to%20Google%20Analytics%20by%20User%20Management.png" alt="Add generated email to Google analytics user">

## Step2. Get Access Token

Add to **Gemfile**

```
gem "typhoeus"
gem 'jwt'
```

Create a file named **lib/google_anallytics.rb**

```
require 'typhoeus'
require "jwt"
require 'date'
module GoogleAnalytic
 
  def get_token
    json_file = File.join("#{Rails.root}/config", 'YOUR-JSON-FILE-NAME.json')
    file = File.read(json_file)
    key_hash = JSON.parse(file)
    aud     = "https://www.googleapis.com/oauth2/v3/token"
    now     = Time.new
    iat     = (now - 60).to_i
    @exp    = (now + 50.minutes).to_i
    scopes  = 'https://www.googleapis.com/auth/analytics.readonly'
    sub     = key_hash["client_email"]
    iss     = key_hash["client_email"]
    jwt_claim_set    = {
      'iss' => iss, 
      'sub' => sub, 
      'scope' => scopes,
      'aud' => aud, 
      'exp' => @exp,
      'iat' => iat
      }
    token            = JWT.encode(jwt_claim_set,  OpenSSL::PKey::RSA.new(key_hash["private_key"]), 'RS256')
    
    res = Typhoeus::Request.post('https://www.googleapis.com/oauth2/v3/token', 
      body: 
        { 
          grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
          assertion: token
        }
    )
    
    res_hash = MultiJson.load(res.body)

    token = res_hash["access_token"]
    return token
  end
end
```

## Step3. Fetch Data

In my case, I create a model for saving Google Analytics data. So, I'll show you how I fetch data.

```
class GoogleAnalyticEvent
  include GoogleAnalytic
  include Mongoid::Document
  include Mongoid::Timestamps
  field :category, type: String        
  field :label, type: String        
  field :action, type: String
  field :total_events, type: Integer       
  field :unique_events, type: Integer
  field :data_date, type: Date
  index({category: 1, label: 1, data_date: 1, action:1 })
  
  def get_event_from_ga_api(params={})
    @data_date = Date.today - 1
    @parameters = {
        'ids'         => "ga:12345678",
        'start-date'  => @data_date.strftime("%Y-%m-%d"),
        'end-date'    => @data_date.strftime("%Y-%m-%d"),
        'metrics'     => "ga:totalEvents,ga:uniqueEvents",
        'dimensions'  => "ga:eventCategory,ga:eventLabel,ga:eventAction",
        'max-results' => "10000"
      }
    query_paginate(@parameters)
  end
  
  def query_paginate(parameters)
    parameters['access_token'] = get_token
    count = 0
    loop do
        if Time.new.to_i > @exp
          parameters['access_token'] = get_token
        end
       res = Typhoeus::Request.get('https://www.googleapis.com/analytics/v3/data/ga', 
        params: parameters
       )
      result = MultiJson.load(res.body)
      if result["error"].nil?
        sync_to_db(result)  if result["totalResults"] > 0
        max_count = result["totalResults"] / parameters["max-results"].to_i
      end
      break if count == max_count || result["error"].present?
      count += 1
      parameters["start-index"] = parameters["max-results"].to_i * count + 1
    end
  end

  def sync_to_db(result)
    result["columnHeaders"].each_with_index do |h,i|
      case h["name"].to_s
      when "ga:eventCategory"
        @category= i 
      when "ga:eventLabel"
        @label   = i
      when "ga:eventAction"
        @action  = i
      when "ga:totalEvents" 
        @total_events  = i
      when "ga:uniqueEvents"
        @unique_events = i
      end
    end 
    result["rows"].each do |array_data|
        GoogleAnalyticEvent.create(category:      array_data[@category], 
                                    label:        array_data[@label], 
                                    action:       array_data[@action],
                                    total_events:       array_data[@total_events],
                                    unique_events:      array_data[@unique_events],
                                    data_date:          @data_date)
    end
  end
end
```

Let's me explain each code snapshots.

### 3-1: First of all, I initialize query parameters such as ids, start-date, ...etc in instance variable @parameters.

PS. you can easily understand which parameters you need by using [Google Analytics Query Explorer](https://ga-dev-tools.appspot.com/query-explorer/). Once, you find out which parameters you need, just copy to here like I do.

```
def get_event_from_ga_api(params={})
    @data_date = Date.today - 1
    @parameters = {
        'ids'         => "ga:12345678",
        'start-date'  => @data_date.strftime("%Y-%m-%d"),
        'end-date'    => @data_date.strftime("%Y-%m-%d"),
        'metrics'     => "ga:totalEvents,ga:uniqueEvents",
        'dimensions'  => "ga:eventCategory,ga:eventLabel,ga:eventAction",
        'max-results' => "10000"
      }
    query_paginate(@parameters)
  end
```

### 3-2: Second, let's see sync_to_db first. 

After I got Google API's response, I will save to database.

let's see what do we get from google analytics first.

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/build%20up%20server-to-server%20interactions%20with%20Google%20API/Google%20Analytics%20Return%20Result.png" alt="Google Analytics Return Data">  

Google show you the return data's column header name by "columnHeaders". And "rows" data is given as an array. And each array elements refer to "columnHeaders" respectively. For exameple, in above picture, you can see "ga:eventCategory" is in first of columnHeaders. So, in rows, each array's first element is value of "ga:eventCategory". Then I save data to model GoogleAnalyticEvent. 
   
That's all fuction "sync_to_db" job.
 
```
def sync_to_db(result)
    result["columnHeaders"].each_with_index do |h,i|
      case h["name"].to_s
      when "ga:eventCategory"
        @category= i 
      when "ga:eventLabel"
        @label   = i
      when "ga:eventAction"
        @action  = i
      when "ga:totalEvents" 
        @total_events  = i
      when "ga:uniqueEvents"
        @unique_events = i
      end
    end 
    result["rows"].each do |array_data|
        GoogleAnalyticEvent.create(category:      array_data[@category], 
                                    label:        array_data[@label], 
                                    action:       array_data[@action],
                                    total_events:       array_data[@total_events],
                                    unique_events:      array_data[@unique_events],
                                    data_date:          @data_date)
    end
  end
```

### 3-3: Finally, let's see function query_paginate.

```
def query_paginate(parameters)
    parameters['access_token'] = get_token
    count = 0
    loop do
        if Time.new.to_i > @exp
          parameters['access_token'] = get_token
        end
       res = Typhoeus::Request.get('https://www.googleapis.com/analytics/v3/data/ga', 
        params: parameters
       )
      result = MultiJson.load(res.body)
      if result["error"].nil?
        sync_to_db(result)  if result["totalResults"] > 0
        max_count = result["totalResults"] / parameters["max-results"].to_i
      end
      break if count == max_count || result["error"].present?
      count += 1
      parameters["start-index"] = parameters["max-results"].to_i * count + 1
    end
  end
```
I have to get access token by "get_token", And this function all assign expire time to @exp. 

```
parameters['access_token'] = get_token

```

Then I write a loop for pagination. At first, I check token is expired or not, if is expired, I have to get token again. 

```
if Time.new.to_i > @exp
  parameters['access_token'] = get_token
end

```

Now, I use Typhoeus::Request.get method with params fetching data from Google Analytics. 

```
res = Typhoeus::Request.get('https://www.googleapis.com/analytics/v3/data/ga', 
        params: parameters
       )
result = MultiJson.load(res.body)
```

And if there are no any errors, I will save data to database.

```
if result["error"].nil?
  sync_to_db(result)  if result["totalResults"] > 0
  max_count = result["totalResults"] / parameters["max-results"].to_i
end
``` 

Finally, break or continue to get next batch data.

```
break if count == max_count || result["error"].present?
count += 1
parameters["start-index"] = parameters["max-results"].to_i * count + 1
```

## That's it.

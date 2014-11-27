---
layout: post
title: "[HOWTO] Using ElasticSearch in Ruby on Rails and setup remote ES server via Vagrant"
date: 2014-11-27 07:45:20 +0800
comments: true
categories: ["Elasticsearch", "Ruby_on_Rails","Search", "Ubuntu", "Vagrant"]
keywords: "Elasticsearch, remote Elasticsearch , vagrant, deploy, ubuntu 14.04, Ruby on Rails, 中文, 遠端, 安裝"
description: "This post will teach you how to setup elasticsearch in Mac OSX, and used in Ruby on Rails. Also, I will show you how to implement remote elasticsearch instance" 
---

首先，要先感謝 "老王"，和 "Marz"哥，給我參考他們的Elasticsearch的文件！

安裝部分，就是參考他們的操作！

這邊最主要的不一樣，是設定遠端的Elasticsearch機器！

改天我會補上 如何實作 "搜尋字詞推薦"，而且是整合soulmate歐！！

<!-- more -->

## Mac本機開發

### 安裝 elastic search 

    brew install elasticsearch

### 連結

    ln -sfv /usr/local/opt/elasticsearch/*.plist ~/Library/LaunchAgents
  
### 啟動

    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist
  
### 關閉

    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist
  

### Run ElasticSearch 

    export JAVA_HOME="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home"
    elasticsearch
  
    (或是)

    elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml  
  
### 測試是否安裝成功

  
    curl -X GET http://localhost:9200
  
你應該會看到

    {
      "status" : 200,
      "name" : "Rage",
      "version" : {
        "number" : "1.3.2",
        "build_hash" : "dee175dbe2f254f3f26992f5d7591939aaefd12f",
        "build_timestamp" : "2014-08-13T14:29:30Z",
        "build_snapshot" : false,
        "lucene_version" : "4.9"
      },
      "tagline" : "You Know, for Search"
    }

### Code 要加入

新增一個檔案

**lib/tasks/elasticsearch.rake**

寫入

    require 'elasticsearch/rails/tasks/import'


修改**Gemfile**，加入

    gem 'elasticsearch-rails'
    gem 'elasticsearch-model' 
  
### 跑index 

詳情請參考：**Gem: **[elasticsearch-rail](https://github.com/elasticsearch/elasticsearch-rails/tree/master/elasticsearch-rails)

    bundle exec rake environment elasticsearch:import:all
  
如果只需要import一個model

    bundle exec rake environment elasticsearch:import:model CLASS='Article'
  
如果只需要import某些特定的scope

    bundle exec rake environment elasticsearch:import:model CLASS='Article' SCOPE='published'
  
### 清除index

    Article.__elasticsearch__.client.indices.delete index: Article.index_name rescue nil
  
  
## 安裝elasticsearch 在Ubuntu 裡面

### 使用vagrant 起三檯機器(用來模擬正式環境)

請查看前半部

[HOWTO - Using Sunspot to Access Remote Solr instance(Ubuntu 14.04) in Ruby on Rails Using Vagrant](http://ccaloha.cc/blog/2014/09/19/howto-using-sunspot-access-remote-solr-instance-ubuntu-14-dot-04-in-ruby-on-rails-using-vagrant/)

### 安裝 elascticsearch 

    vagrant ssh search 
    sudo apt-get install openjdk-7-jre-headless -y
    sudo wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -


### 編輯source list
  
    sudo vim /etc/apt/sources.list

把下面的code放進去
  
      deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main
  
繼續安裝

      sudo apt-get update
      sudo apt-get install elasticsearch
      sudo update-rc.d elasticsearch defaults 95 10
      sudo /etc/init.d/elasticsearch start
  

## Ruby on Rails 部分

### 更改producion deploy的東東

**config/deploy/production.rb**

      role :app, %w{apps@33.33.13.10}
      role :web, %w{apps@33.33.13.10}
      role :db,  %w{apps@33.33.13.11}
      role :crontaber, %w{apps@33.33.13.10}
      set :rails_env, :production
      set :unicorn_rack_env, :production
      set :branch, 'feature/update_search_engine_to_elasticsearch'

我故意把ip改成 vagrant的ip

另外，branch也用成我自己測試的branch: **feature/update_search_engine_to_elasticsearch**

## 如何設定將elasticsearch 連到別台機器

1. 新增一個 **config/elasticsearch.yml**

  
        default: &default
          host: 127.0.0.1:9200
        
        development:
          <<: *default
          host: 127.0.0.1:9200
        
        test:
          <<: *default
        
        production:
          <<: *default
          host: 33.33.13.12:9200

2. 在application.rb加入

  
        es = YAML.load(File.open("#{Rails.root}/config/elasticsearch.yml"))[Rails.env]

          elasticsearch_config = {
              host: es["host"],
              transport_options: {
              request: { timeout: 5 }
              },
          }
          Elasticsearch::Model.client = Elasticsearch::Client.new(elasticsearch_config)


3. 因為我的product需要做搜尋，所以在Product model 我這樣寫

  (ps. elasticsearch 真的是博大精深，我沒有時間去深入專研，以下的指令是我try出最符合我需要的搜尋結果，所以大家可參考參考)


    def self.essearch(query,sort,page)
      if sort == 'relevance'

        results = __elasticsearch__.search(
          {
            query: {
              filtered: {
                filter: {
                  range: { product_price_min: { "gt" => 0} }
                 }, 
                query: {
                  bool: {
                    must: [
                      multi_match: {
                        query: query,
                        type:  "phrase",
                        fields: ["product_cname^10", "product_ename^10",'product_description', 'product_keyword']
                      }
                    ]
                  }
                }
              }
            },
            "sort" => [
              "_score",
              {"product_urcosme_exp" => {"order" => "desc"} } 
            ],
            "from" => (page.to_i-1)*5,
            "size" => 5          
          }
        )
      else
        # 因為不是精準搜尋，所以這邊的排序就真的會依照我們給他的sort，
        # 但是你總不希望，搜尋面膜，結果第一個結果是：淨膚儀，就因為他的上市時間最晚....囧～
        # 所以，我還是希望第一個看到的結果是以關鍵字有出現的為佳，所以我多使用了filter的功能
        results = __elasticsearch__.search(
          {
            query: {
              filtered: {
                filter: {
                  range: { product_price_min: { "gt" => 0} }
                 },
                filter: {
                   exists: { field: "product_keyword" }
                 },
                query: {
                  bool: {
                    must: [
                      multi_match: {
                        query: query,
                        type:  "cross_fields",
                        fields: ['product_cname', 'product_ename'],
                        operator:   "and", 
                        #minimum_should_match: '30%'
                      }
                    ],
                    should: [
                      { match: { "product_description" =>  query}},
                      { match: { "product_keyword" => query }}
                    ],
                  }
                }
              }
            },
            "sort" => [
              {"#{sort}" => {"order" => "#{sort == "product_price_min"? 'asc' : 'desc'}"} } , 
               "_score",
              { "product_cname" => "desc" }
            ],
            "from" => (page.to_i-1)*5,
            "size" => 5        
          }
        )
      # 這邊目的是為了如果上面都沒有搜尋結果才做的比較rough的搜尋
      if results.results.size == 0
        results = __elasticsearch__.search(
          {
            query: {
              filtered: {
                filter: {
                  range: { product_price_min: { "gt" => 0} }
                 },
                query: {
                  bool: {
                    must: [
                      multi_match: {
                        query: query,
                        type:  "cross_fields",
                        fields: ['product_cname', 'product_ename','product_description','product_keyword'],
                        operator:   "and"
                      }
                    ]
                  }
                }
              }
            },
            "sort" => [
              {"#{sort}" => {"order" => "#{sort == "product_price_min"? 'asc' : 'desc'}"} } , 
               "_score",
              { "product_cname" => "desc" }
            ],
            "from" => (page.to_i-1)*5,
            "size" => 5          
          }
        )
      end
      end
      return results
    end


4. 在product的controller

      
      @products = Product.essearch(params[:keyword],params[:sort],params[:page])
      
      @products =  search.results.results

    接下來就是丟給view顯示了～我就不提了～

### 接下來就是deploy加上看看有沒有成功摟

    cap production deploy #因為"config/deploy/production.rb"有改成vagrant設定，所以請放心～
    vagrant ssh search    # 登入你的搜尋機器
    elasticsearch         # 把elasticsearch 服務跑起來
    vagrant ssh app       # 登入跑服務的機器
    cd 你的專案            
    bundle exec rake environment elasticsearch:import:all  #跑index，這邊如果有成功，代表你已經連過去遠端了！

### 完成！



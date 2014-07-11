---
layout: post
title: "[HowTo] Setup Sunspot in Rails 4 and Deploy to Ubuntu12.04 using Capistrano 3"
date: 2014-04-30 10:26:44 +0800
comments: true
categories: ["Ruby_on_Rails,Capistrano,Ubuntu"]
keywords: "Ubuntu, Ruby on Rails, sunspot, capistrano, setup, deploy"
description: "Setup sunspot in rails 4 and deploy to Ubuntu using Capistrano"
---

#[HOWTO] Setup Sunspot in Rails 4 and Deploy to Ubuntu 12.04 using
Capistrano3.

最近利用空閒時間，練習自己架設一個購物網站，其中，我想說一般網站都會有搜尋的功能，

如果在後台，可以使用Ransack來實作，但是那是給管理者搜尋某些表相關欄位所使用，

換句話說，在訂單的table中，你可以使用Ransack搜尋，建立每一個獨立欄位搜尋input，或是建立和這訂單table相關的每個獨立欄位的搜尋input

但是，如果想要在網站建立一個搜尋引擎，該要怎麼做？

搜尋引擎是只要輸入一個資料，你就可以搜尋到搜尋不同欄位，

我查了The Ruby toolbox，第一名被使用的就是Sunspot:
<https://github.com/outoftime/sunspot> !

於是乎，就來try and error吧

<!--more-->

## Part1 - Local Machine testing 

###1. In your Gemfile 

    gem 'sunspot_rails'
   
###2. Bundle it.

    bundle install
      
###3. Generate a default configuration file

    rails g sunspot_rails:fileinstall


###4. Model where you want to be searched 

假設是你的Product 要給大家搜尋

請在 *app/models/product.rb*

假設你有欄位, name, content, html_block, slug(產品好看的url用) ,is_added(上架與否)加入

    searchable do 
      text :name, :content, :html_block, :slug
      time :commentsreated_at
      boolean :is_added
    end

###5. Routing

到*route.rb*上，這樣你的localhost:3000/search就是搜尋在用的link

    get '/search', to: 'pages#search'


###6. View (search bar)

因為我想要把搜尋bar一直放在網頁右上角，和使用者基本操作放在一起(例如登入...等)

所以我在我的*_user_nav.html.slim* 加上

    = form_tag search_path, :method => :get , class: 'search-bar' do
      = toext_field_tag :search, params[:search]
      = submit_tag "Search", :namee => nil

###7. Controller

最後，當form 做get動作後，就交給 pages_controller.rb 

    def search
      @search = Product.solr_search do
      fulltext Part1arams[:search]
      with(:is_added, true)
      with(:created_at).less_than(searchTime.zone.now)
      end
      @related_products = @search.results
    end
 
 ps.這邊有個小關卡，那就是如果你和我一樣有使用ransack 
 
 如果**Product.solr_search** 這邊你是寫Product.search會報錯 
 
 solution，也就是我上面寫的那種，是參考自：
<https://github.com/sunspot/sunspot/blob/master/sunspot_rails/lib/sunspot/rails/searchable.rb#L124>
 

###8. View
 
 controller完之後，當然要有一個view去接，*serach.html.slim*


    .home-block
      h2 class="home-block-heading"
        span 搜尋結果
      .row.clearfix
        - @related_products.each do |product|
          .col-sm-4 style="padding-bottom:0"
            figure
              figcaption
                strong #{product.name}
                span   #{product.content}
                em   #{product.selling_price}figure 

###9. Using commend line run Sunspot service 

在Local machine測試

    rake sunspot:solr:start
    rake sunspot:reindex

這樣基本上，就是搜尋在用的可以開始搜尋了！ (中文也會通歐～～)

ps. 在code commit上，

I didn't add folder *solr/**  into code tracking.

I only add *sunspot.yml* into my github. 

## Part2 - Deployment

###1. Make sure that your server installed JAVA.

if not do this

    sudo apt-get install openjdk-7-jre

or you will got ...

    You need a Java Runtime Environment to run the Solr server
    Sunspot:the:Solr::Server::JavaMissing


###2. Cap

thanks to <https://gist.github.com/muscardinus/8884801>

create sunspot.cap under *lib/capistrano/tasks/sunspot.cap*

<script src="https://gist.github.com/muscardinus/8884801.js"></script>

  
###3. Config sunspot.yml

    production:
      solr:
        hostname: loca    port: 8983
        log_level: WARNING
        path: /solr/default
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
        path: /solr/thisest

####IMPORTANT: 

*path: /solr/default* instead of path: */solr/productionon*      

### 3. Done 

    cap production deploy

### Part3- Troubleshotting

if you got error message like I did, 

    F, [2014-04-29T23:47:44.848055 #23803] FATAL -- : 
    RSolr::Error::Http (RSolr::Error::Http - 4404 Not Found
    Error:     Not Found

    Request Data:
    "fq=type%3AProduct&fqfq=is_added_b%3Atrue&fq=created_at_d%3A%7B%2A+TO+2014%5C-04%5C-29T15%5C%3A47%5C%3A44Z%7D&q=%E4%B8%8A%E8%A1%A3&fl=%2A+score&qf=name_text+content_text+html_block_text+slug_text&defType=edismax&start=0&rows=30"

    Backtrace:
    /home/Deploymenty/ectest/shared/bundle/ruby/2.0.0/gems/rsolr-1.0.10/lib/rsolr/client.rb:283:in
    `adapt_response'
    /home/deploy/ectest/shared/bundle/ruby/2.0.0/gems/rsolr-1.0.10/lib/rsolr/client.rb:190:in
    `execute'
    /home/deploy/ectest/shared/bundlee/ruby/2.0.0/gems/rsolr-1.0.10/lib/rsolr/client.rb:176:in
    `send_and_receive'
    /home/deploy/ectest/shared/bundle/ruby/2.0.0/gems/sunspot_rails-2.1.0/lib/sunspot_railsot/rails/solr_instrumentation.rb:16:in
    `block in send_and_receive_with_as_instrumentation'
    /home/deploy/ectest/shared/bundle/ruby/2.0.0/gems/activesupport-4.0.2/lib/active_support/notifications.rb:159:in
    `block in instrument'
    /home/deploy/ectestest/shared/bundle/ruby/2.0.0/gems/activesupport-4.0.2/lib/active_support/notifications/instrumenter.rb:20:in
    `instrument'
    /home/deploy/ectest/shared/bundlendle/ruby/2.0.0/gems/activesupport-4.0.2/lib/active_support/notifications.rb:159:in
    `instrument'

Solution: 


    1. ps aux | grep solr to get solr process ID
    2. sudo kill <ID>, <ID> is the ID you found from 1
    3. rm -r <path/to/solr>, remove the solr directory inside your
       project to remove all of previous indexes
    4. RAILS_ENV=production bundle exec rake sunspot:solr:start
    5. Change the path to /solr/default inside config/sunspot.yml
    6. RAILS_ENV=production bundle exec rake sunspot:solr:reindex


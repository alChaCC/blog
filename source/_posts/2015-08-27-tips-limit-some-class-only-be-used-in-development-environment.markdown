---
layout: post
title: "[Tips] Limit Class Only be used in Development Environment"
date: 2015-08-27 17:22:50 +0800
comments: true
categories: ["Ruby on Rails"]
keywords:  "Ruby on Rails, auto loading, eager loading, disable"
description: "this article show you how to disallow some classes in production environments"
---

In my project, I have to dump data from Mysql to MongoDB. And, this feature only used in development. However, Rails will load any classes under folder "app/" automatically . So, how can I avoid "Development-Only Class" loading in production environment?

let's check it out~ 

If you have a class named: **DumpDataFromOldServer** and it located at  folder **'/app/development_only'**. like this: 

```
# app/development_only/dump_data_from_old_server.rb

class DumpDataFromOldServer < ActiveRecord::Base
    ....
end
```


## Step1. Application.rb

you still need to let Rails know which folders should be loaded by using **config.eager_load_paths**.

ps. what's difference between eager_load and auto_load? 

please check this [http://stackoverflow.com/questions/19773266/confusing-about-autoload-paths-vs-eager-load-paths-in-rails-4](http://stackoverflow.com/questions/19773266/confusing-about-autoload-paths-vs-eager-load-paths-in-rails-4)

```
 config.eager_load_paths += %W(#{Rails.root}/app/development_only)
```

It will be: 

```
# config/application.rb

require File.expand_path('../boot', __FILE__)

Bundler.require(*Rails.groups)

module MyAwesomeProject
  class Application < Rails::Application
   ...
   
   config.eager_load_paths += %W(#{Rails.root}/app/development_only)
   
   ...
   end 
end

```


## Step2. Update your environment file

ref: [http://stackoverflow.com/questions/13756986/how-to-blacklist-directory-loading-in-rails](http://stackoverflow.com/questions/13756986/how-to-blacklist-directory-loading-in-rails)

Add these lines 

```
  path_rejector = lambda { |s| s.include?("app/development_only") }

  # Remove the path from being loaded when Rails starts:
  config.eager_load_paths = config.eager_load_paths.reject(&path_rejector)

  # Remove the path from being lazily loaded
  ActiveSupport::Dependencies.autoload_paths.reject!(&path_rejector)
```

It will be: 

```
# config/environments/production.rb
Rails.application.configure do
  
  ...

  path_rejector = lambda { |s| s.include?("app/development_only") }

  config.eager_load_paths = config.eager_load_paths.reject(&path_rejector)

  ActiveSupport::Dependencies.autoload_paths.reject!(&path_rejector)
end

```

## Step3. Test

```
# In Development console: rails c 

> DumpDataFromOldServer.all.first 

DumpDataFromOldServer Load (0.6ms)  SELECT  `dump_data_from_old_server`.* FROM `dump_data_from_old_server `  LIMIT 1
=> #<DumpDataFromOldServer id: 1, created_at: "2014-05-09 16:59:55">


# In Production console: rails c -e production
> DumpDataFromOldServer.all.first
NameError: uninitialized constant DumpDataFromOldServer

```

---
layout: post
title: "HowTo Performance Test in Rails 4"
date: 2015-07-14 19:35:26 +0800
comments: true
categories: ["Ruby on Rails", "Test"] 
keywords: "rails-perftest,ruby-prof,request_profiler,rack-mini-profiler ,Profile ,Ruby on Rails, how to"
description: "This tutorial show you how to do performance test"
---

Inspired by 

1. [PERFORMANCE TESTING RAILS AGAINST REAL DATA](http://tekin.co.uk/2014/09/performance-test-rails-against-real-data/)

2. [Performance Testing](http://railscasts.com/episodes/411-performance-testing)
3. [http://railscasts.com/episodes/368-miniprofiler](http://railscasts.com/episodes/368-miniprofiler)

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Rails%20performance%20test/rails-perftest%20and%20ruby-prof.png">

<!-- more -->

## First thing you should know 

In Rails 4, performance test functionality was extracted out ! So, you need to add 

    # Gemfile
    gem 'rails-perftest' ,group: :benchmark
  

And if you want your **rails-perftest** show memory usage. You also need to add 

    # Gemfile
    gem 'ruby-prof' ,group: :benchmark
  
**[! Important !]** In my environment, 

    rails-4.1.6, ruby-2.2.2.133, x86_64-darwin14


After doing lots of efforts, I finally can get memory usage info.

But I fount this issue. please check: [https://github.com/ruby-prof/ruby-prof/issues/165](https://github.com/ruby-prof/ruby-prof/issues/165). 

And I'm not sure that my memory usage is correct or not.

But I'll still show you how I do these jobs. Maybe after fixing the issue, we can get correct informantion.

## Create a new environment for performance test

### create a new file:  **config/environments/benchmark.rb**

In fact, all contents are copied from config/environments/production.rb since we need to know performance in real world.
  
    Rails.application.configure do
      # Settings specified here will take precedence over those in config/application.rb.

      # Code is not reloaded between requests.
      config.cache_classes = true

      # Eager load code on boot. This eager loads most of Rails and
      # your application in memory, allowing both threaded web servers
      # and those relying on copy on write to perform better.
      # Rake tasks automatically ignore this option for performance.
      config.eager_load = true

      # Full error reports are disabled and caching is turned on.
      config.consider_all_requests_local       = false
      config.action_controller.perform_caching = true

      # Enable Rack::Cache to put a simple HTTP cache in front of your application
      # Add `rack-cache` to your Gemfile before enabling this.
      # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
      # config.action_dispatch.rack_cache = true

      # Disable Rails's static asset server (Apache or nginx will already do this).
      config.serve_static_assets = false

      # Compress JavaScripts and CSS.
      config.assets.js_compressor = :uglifier
      # config.assets.css_compressor = :sass

      # Do not fallback to assets pipeline if a precompiled asset is missed.
      config.assets.compile = false

      # Generate digests for assets URLs.
      config.assets.digest = true

      # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

      # Specifies the header that your server uses for sending files.
      # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
      # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

      # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
      config.force_ssl = true

      # Set to :debug to see everything in the log.
      config.log_level = :info

      # Prepend all log lines with the following tags.
      # config.log_tags = [ :subdomain, :uuid ]

      # Use a different logger for distributed setups.
      # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

      # Use a different cache store in production.
      # config.cache_store = :mem_cache_store
      config.cache_store = :dalli_store

      # Enable serving of images, stylesheets, and JavaScripts from an asset server.
      # config.action_controller.asset_host = "http://assets.example.com"

      # Ignore bad email addresses and do not raise email delivery errors.
      # Set this to true and configure the email server for immediate delivery to raise delivery errors.
      # config.action_mailer.raise_delivery_errors = false

      # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
      # the I18n.default_locale when a translation cannot be found).
      config.i18n.fallbacks = true

      # Send deprecation notices to registered listeners.
      config.active_support.deprecation = :notify

      # Disable automatic flushing of the log to improve performance.
      # config.autoflush_log = false

      # Use default logging formatter so that PID and timestamp are not suppressed.
      config.log_formatter = ::Logger::Formatter.new

      # Do not dump schema after migrations.
      config.active_record.dump_schema_after_migration = false
      
    end
  
### add configuration:  **config/database.yml**

    default: &default
      adapter: mysql2
      encoding: utf8
      host: 127.0.0.1
      username: root
      password: your_password

    staging:
      <<: *default
      database: your_project_development

    development:
      <<: *default
      database: your_project_development

    test:
      <<: *default
      database: your_project_test

    production:
      <<: *default
      database: your_project_production

    benchmark:
      <<: *default
      database: your_project_production 

## Create a test helper file to setup your benchmark tests:

create a new file: **test/benchmark_helper.rb**

    ENV["RAILS_ENV"] = "benchmark"
    require File.expand_path('../../config/environment', __FILE__)
    require 'rails/test_help'
    require 'rails/performance_test_help'
     
    class ActionDispatch::PerformanceTest
       self.profile_options = { runs: 5, metrics: [:wall_time, :memory,:objects, :gc_runs, :gc_time],
                                output: 'tmp/performance', formats: [:flat, :graph_html, :call_tree, :call_stack] }
    end


## Create a test file 

    rails generate performance_test page

and it will create a file named **page.rb** under **test/performance/**

    require 'benchmark_helper'

    class PageTest < ActionDispatch::PerformanceTest
      test "homepage" do
        get '/'
      end
    end


## Add a rake task for running your real-world benchmarks (optional) 

lib/tasks/test_benchmark.rake

    Rake::TestTask.new(:real_world_benchmark => ['test:benchmark_mode']) do |t|
        t.libs << 'test'
        t.pattern = 'test/performance/**/*_test.rb'
      end
    end

## Update your Rakefile

Rails 4 no longer defines db:test:prepare, however, **rails-perftest** still use **test:prepare**. So, we need to workaround.

    require File.expand_path('../config/application', __FILE__)

    Rails.application.load_tasks

    Rake.application.instance_eval do
      # Remove test:prepare
      @tasks['test:benchmark'].prerequisites.shift if @tasks['test:benchmark']
      @tasks['test:profile'].prerequisites.shift if @tasks['test:profile']
    end
  

## For memory measurement, we need the railsexpress patches. 

[https://github.com/skaes/rvm-patchsets](https://github.com/skaes/rvm-patchsets)

    rvm get stable

But my rvm isn't update to date correctly, So I use

    cd /tmp
    git clone https://github.com/skaes/rvm-patchsets.git
    cd rvm-patchsets
    ./install.sh
    
Then I run 

    rvm reinstall 2.2.2 --patch railsexpress

After reinstall Ruby, we need to recreate our gemset

    cd your_project
    rvm gemset create your_project
    gem install bundler
    bundle install
  
  
## Finally  

These command should work~

    RAILS_ENV=benchmark bundle exec rake test:real_world_benchmark
    RAILS_ENV=benchmark bundle exec rake test:benchmark
    RAILS_ENV=benchmark bundle exec rake test:profile
  
Then these command will create some files under **your_project/tmp/performance**

PS. Please notice that before performance test, you should make sure that there are no any errors while visit the page.

 
## Without using "rails-perftest", you might use..

###if You need detailed information, you can use "request_profiler"

inspired by [https://www.coffeepowered.net/2013/08/02/ruby-prof-for-rails/](https://www.coffeepowered.net/2013/08/02/ruby-prof-for-rails/)

we can use **request_profiler**, which allows you to profile rack requests using ruby-prof.

    gem 'request_profiler'

And you might need to add this line into **config/enviornments/benchmark.rb**

    config.middleware.use "Rack::RequestProfiler"
  
On every page you want to profile, just add **?profile_request=true**

for example, we want to profile "/" , just key

    https://localhost:3000/?profile_request=true

then you wiil see file named  **2015-07-14-16-49-19---profile_request=true.html** under **tmp/performance/**

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Rails%20performance%20test/profile_request.png">

### if You need to quickly and easily find out what is bottleneck,  "rack-mini-profiler" is best choice.

**Gemfile**

    gem 'rack-mini-profiler', require: false  


Create a new file **config/initializers/rack_profiler.rb**

    if Rails.env == 'development' || Rails.env == 'benchmark'
      require 'rack-mini-profiler'

      # initialization is skipped so trigger it
      Rack::MiniProfilerRails.initialize!(Rails.application)
    end

Add to **app/controllers/application_controller.rb**

    before_action :authorize_for_miniprofiler
    def authorize_for_miniprofiler
      if Rails.env == 'development' || Rails.env == 'benchmark'
        Rack::MiniProfiler.authorize_request
      end
    end
 
now you can see this under development and benchmark environments

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Rails%20performance%20test/rack-mini-profiler.png">
 

## You might want to read

1. [http://code.oneapm.com/ruby/2015/04/08/ruby-profilers/](http://code.oneapm.com/ruby/2015/04/08/ruby-profilers/)
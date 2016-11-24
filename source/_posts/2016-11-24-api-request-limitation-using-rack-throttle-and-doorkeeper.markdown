---
layout: post
title: "API Request Limitation Using Rack-Throttle and Doorkeeper"
date: 2016-11-24 12:52:06 +0800
comments: true
categories: ['Ruby on Rails', 'API']
keywords: "rack-throttle, doorkeeper, rack, ruby, request, limitation"
description: 'The article show you how to implement API request limitation in Rack application.'
---

When it comes to open API to external users, we need to consider the number of requests we allowed. Most of API-as-a-service platforms have different payment plans. Due to different levels of payment, it turns out that the service resource can be used fairly - advanced plan users can make more requests than normal users. 

In order to achieve this goal, we need to find a way recording the number of requests. Intuitively, we can creata a `request_record` table, before controller process the request, by comparing the number in database and client's request limitation, we can either allow or deny the requests.   

Thanks to Ruby gems, you are able to find some libraries can do the trick. In this article, 
I choose `rack-throttle` to help me count the requests. The reasons I prefer 
`rack-throttle` are: 

1. To limit by defining a maximum number of allowed HTTP requests per a given time period
2. Compatible with any Rack application and any Rack-based framework.
3. Compatible with the memcached, memcache-client, memcache and redis gems.
4. Well documented and the most important thing is that codes are easy to read!

Different from recording, we still need to identify which client makes this request for deciding to allow or not. Here I use `Doorkeeper` to tell me which user is.     
 
In this article, I will not show you how to setup `Doorkeeper`, but you are about to see how to customize your own limiter. 

So, That's go!

## Requirements

My targets show as below: 

1. Different clients has its limitation. 
2. Should limit by second, minute, hour, day and month.
3. Support whitelist 

## Gemfile

At first, we need to add libraries, the most important gem is `rack-throttle`. Depend on which places you want to store your counting data, you might need to add other gems. For me, I prefer `redis`. So, I added as below.

```
# Api limit
gem 'rack-throttle'
gem 'redis'
```

## Customize your throttler

Wait wait, before we start implementing, we should understand some mechnisms and terms. 

### First, `rack`! 

you might notice that the gem we use called `rack-throttle`. Yes! this lib is built as a `Rack middleware` that provides logic for rate-limiting incoming HTTP requests to Rack applications. 

Ok, so what's `Rack` ? 

according to [rack official website](http://rack.github.io/), 

> Rack provides a minimal interface between webservers that support Ruby and Ruby frameworks.

> To use Rack, provide an `app`: an object that responds to the `call` method, taking the environment hash as a parameter, and returning an Array with three elements:

> The HTTP response code

> A Hash of headers

> The response body, which must respond to each

So, `Rack` can help you handle the HTTP request. And due to `Rack` take `the environment hash` and also can "return" fix format: `array with code, headers and body`. It's very easy for you to add `middleware` which can help you do cacheing, authencation, ...etc. In our case, gem `rack-throttle` will help you adding middleware easily.  

After we briefly understand how `Rack` works, now let's take a look how `rack-throttle`'s core class: [`limiter`](https://github.com/dryruby/rack-throttle/blob/master/lib/rack/throttle/limiter.rb). 

Why it work as `Rack middilewate`? 

The key point is:

```
def initialize(app, options = {})
  @app, @options = app, options
end

def call(env)
  request = Rack::Request.new(env)
  allowed?(request) ? app.call(env) : rate_limit_exceeded(request)
end
```

So, after we add this middleware into our Rack, every time we receive the requests it will be invoked by `call` method. Then we check is allowed or not, if is allowed, we pass to next Rack middleware, otherwise we stop in this middleware. 

### Since I need to customize the throttler, I can inherit from `Rack::Throttle::Limiter`. 

Let's check the final code first. 

```ruby
# lib/api_limitation/application_throttler.rb

require 'rack/throttle'
module ApiLimitation
  class ApplicationThrottler < Rack::Throttle::Limiter
    attr_accessor :client, :ip

    def initialize(app, options = {})
      super
    end

    def client_identifier(request)
      if request.env['HTTP_AUTHORIZATION'] || request.params['access_token']
        token        = request.env['HTTP_AUTHORIZATION'].present? ? request.env['HTTP_AUTHORIZATION'].split(' ')[-1] : request.params['access_token']
        access_token = Doorkeeper::AccessToken.where(token: token).first
        @client = access_token ? User.find(access_token.resource_owner_id) : nil
      end
      @ip = request.ip.to_s
    end

    def max_per_second
      @client.try(:limitation).try(:second) || 1
    end

    def max_per_minute
      @client.try(:limitation).try(:minute) || 60
    end

    def max_per_hourly
      @client.try(:limitation).try(:hourly) || 3_600
    end

    def max_per_daily
      @client.try(:limitation).try(:daily) || 86_400
    end

    def max_per_monthly
      @client.try(:limitation).try(:monthly) || 2_592_000
    end

    def allowed?(request)
      client_identifier(request)
      return true if whitelisted?(request)

      ['second', 'minute', 'hourly', 'daily', 'monthly'].all? { |timeslot| send("#{timeslot}_check".to_sym) }
    end

    def whitelisted?(request)
      @client.try(:email).in? ['YOUR_WHITE_LIST']
    end

    protected

    ['second', 'minute', 'hourly', 'daily', 'monthly'].each do |timeslot|
      define_method("#{timeslot}_check".to_sym) do
        count = cache_get(key = send("#{timeslot}_cache_key".to_sym)).to_i + 1 rescue 1
        allowed = count <= send("max_per_#{timeslot}".to_sym).to_i
        begin
          cache_set(key, count)
          allowed
        rescue => e
          allowed = true
        end
      end
    end

    def second_cache_key
      [@client.try(:id) || @ip, Time.now.strftime('%Y-%m-%dT%H:%M:%S')].join(':')
    end

    def minute_cache_key
      [@client.try(:id) || @ip, Time.now.strftime('%Y-%m-%dT%H:%M')].join(':')
    end

    def hourly_cache_key
      [@client.try(:id) || @ip, Time.now.strftime('%Y-%m-%dT%H')].join(':')
    end

    def daily_cache_key
      [@client.try(:id) || @ip, Time.now.strftime('%Y-%m-%d')].join(':')
    end

    def monthly_cache_key
      [@client.try(:id) || @ip, Time.now.strftime('%Y-%m')].join(':')
    end

  end
end

```

The most important function is `allowed?(request)`.

```ruby
def allowed?(request)
    client_identifier(request)
    return true if whitelisted?(request)

    ['second', 'minute', 'hourly', 'daily', 'monthly'].all? { |timeslot| send("#{timeslot}_check".to_sym) }
end
```
Let's check each functions. 

#### First, `client_identifier(request)`.

```ruby
def client_identifier(request)
    if request.env['HTTP_AUTHORIZATION'] || request.params['access_token']
   token        = request.env['HTTP_AUTHORIZATION'].present? ? request.env['HTTP_AUTHORIZATION'].split(' ')[-1] : request.params['access_token']
   access_token = Doorkeeper::AccessToken.where(token: token).first
   @client = access_token ? User.find(access_token.resource_owner_id) : nil
      end
   @ip = request.ip.to_s
 end
```

We used `doorkeeper` for Oauth2 authentication.

So, each requests might have `HTTP_AUTHORIZATION` in header or `access_token` in url. Then we need to use the `access_token` to find who he is. 

#### Second, `whitelisted?(request)`

```ruby
def whitelisted?(request)
  @client.try(:email).in? ['YOUR_WHITE_LIST']
end
```

Simple! Right?, because we already have @client from `client_identifier(request)`. I just try to find its email in list or not. 

#### Finall part, `['second', 'minute', 'hourly', 'daily', 'monthly'].all? { |timeslot| send("#{timeslot}_check".to_sym) }`

here I use [`metaprogramming`](https://www.toptal.com/ruby/ruby-metaprogramming-cooler-than-it-sounds) to avoid writing too many duplicate codes which call these functions: `second_check`, `minute_check`, ...etc.

And you can't find these functions in codes, which is because I also use metaprogramming method to implement class's instance methods.

```ruby
['second', 'minute', 'hourly', 'daily', 'monthly'].each do |timeslot|
  define_method("#{timeslot}_check".to_sym) do
    count = cache_get(key = send("#{timeslot}_cache_key".to_sym)).to_i + 1 rescue 1
    allowed = count <= send("max_per_#{timeslot}".to_sym).to_i
    begin
      cache_set(key, count)
      allowed
    rescue => e
      allowed = true
    end
  end
end
```

Ok, so here I try to get count number from cache(for me, I used Redis) by `cache_get` which is in base class: `Rack::Throttle::Limiter`. And the cache keys are either client's id or ip with timestamp. for example: `12345:2016-11-24` or `127.0.0.1:2016-11-24`. 

```ruby
def second_cache_key
  [@client.try(:id) || @ip, Time.now.strftime('%Y-%m-%dT%H:%M:%S')].join(':')
end
...
```

After we get the number of count we can compare it  to client's limitation and add counting number as well. 

And how do we get client's limitation?

In our database design, user has one `limitation` which include these columns: `second`, `minute`...etc. 
So, I can easily get it by `@client.limitation.XXX`  

```
def max_per_second
  @client.try(:limitation).try(:second) || 1
end
....
```

That's it. it's not too hard right?

## Add your throttler into Rack.

This part is super easy, just follow [`rack-throttle`'s README](https://github.com/dryruby/rack-throttle). 

because I built it for Rails application. 

I need to add this line into `config/application.rb`

```ruby
module YOUR_AWESOME_APPLICATION
  class Application < Rails::Application
   ...
    config.middleware.use ::ApiLimitation::ApplicationThrottler, cache: Redis.new(host: YOUR_REDIS_HOST), key_prefix: :awesome_throttle, message: 'Rate Limit Exceeded, please upgrade your plan to get more requests'
  end
end
```

Do you remember that I mentioned I use `Redis` for caching count? Here is the magic. 

I initialize `@cache` in here. So that it can be accessed in class.

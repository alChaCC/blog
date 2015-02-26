---
layout: post
title: "[HOWTO] Transfer Capistrano 2 to Capistrano 3 using Ruby on Rails"
date: 2014-03-27 11:13:09 +0800
comments: true
categories: ["capistrano", "Ruby on Rails"]
keywords: "capistrano, deploy, rails, sidekiq, whenever, upgrade"
description: "Learning how to transfer Capistrano 2 to Capistrano 3"
---

At First, Why I want to transfer from Capistrano2 to Capistrano3?

1. Stability
2. Performance 

In Capistrano2, 

First, I often stuck at precompile... 

and sometimes I get **[deploy:update_code] exception while rolling back:
Net::SSH::Disconnect, connection closed by remote host"**

Third, every deployments take about 10~15 minuates.

So.... that's why I want to change to capistrano 3. 

<!--more-->

this post is inspired by
<https://semaphoreapp.com/blog/2013/11/26/capistrano-3-upgrade-guide.html>

But I still have some problems. Here I demo source code from my project
and show how I fix these problems.



## Just move your old "cap" files to a folder

    cd YOUR_PROJECT
    mkdir old_cap
    mv Capfile old_cap
    mv config/deploy.rb old_cap
    mv config/deploy/mv old_cap    

## 1. Gemfile

### Original 

<script src="https://gist.github.com/alChaCC/9799086.js"></script>


### New
<script src="https://gist.github.com/alChaCC/9799076.js"></script>

**gem "capistrano-rails"**  = *gem 'capistrano'* + *gem
'capistrano-ext'* + *gem 'capistrano_colors'*


## 2. Capfilee

### Original

<script src="https://gist.github.com/alChaCC/9799039.js"></script>

### New 
If you want to know what is the deploy flow if you require these files

check this <http://capistranorb.com/documentation/getting-started/flow/>

<script src="https://gist.github.com/alChaCC/9799057.js"></script>

## 3. config/deploy.rb

### Original
<script src="https://gist.github.com/alChaCC/9799134.js"></script>

### New
<script src="https://gist.github.com/alChaCC/9799113.js"></script>

## 4. config/deploy/staging.rb
### Original
<script src="https://gist.github.com/alChaCC/9799148.js"></script>
### New
<script src="https://gist.github.com/alChaCC/9799161.js"></script>
## 5. lib/capistrano/tasks/restart.cap
<script src="https://gist.github.com/alChaCC/9799192.js"></script>

## 6. lib/capistrano/tasks/sync_to_S3.cap
I use **asset_sync** to sync assets to S3.

<https://github.com/rumblelabs/asset_sync>

**Notice:** within must inside roles or you will get no method problem.

more details <https://github.com/capistrano/sshkit>



<script src="https://gist.github.com/alChaCC/9799214.js"></script>

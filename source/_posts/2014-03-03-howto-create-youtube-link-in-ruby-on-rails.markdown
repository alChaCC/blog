---
layout: post
title: "[HowTo]- Create youtube link in Ruby on Rails(using slim)"
date: 2014-03-03 23:52:08 +0800
comments: true
categories: Ruby_on_Rails
---

## In your view where you want to show youtube link 
ex: app/views/products/show.html.slim

    - if @product.youtube_url.present?
      = video_iframe @product.youtube_url


## Create a helper 
ex: I created in application_helper.rb

    def video_iframeideo_iframe(src)
      content_tag("iframe","", {:width => 'XXX', :height =XXX> 'YYY', :src =>"#{src}"} )
    end

 <!--more-->

 That's it ~

 Good Luck

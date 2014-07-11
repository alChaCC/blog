---
layout: post
title: "[HOWTO]- Build a Step-By-Step Website Introduction using crumble.js instead of intro.js"
date: 2014-03-06 22:16:01 +0800
comments: true
categories: [Ruby_on_Rails, crumble.js, grumble.js]
keywords: "Ruby_on_Rails, crumble.js, grumble.js, how to, Deploy, EC2,
step-by-step"
description: "how to build a Step-By-Step Website Introduction using crumble.js instead of intro.js then deploy to EC2"
---

## Intro

Crumble.js is a interactive step-by-step tour based on grumble.js 

you might want to check the demo site. 

Please check this out => <http://blog.tommoor.com/crumble>

You can learn from this tutorial how to use crumble.js in your Ruby on
Rails project.

In advance, I will show you how to deploy to AWS EC2 without pain~~~

<!--more-->

## Step1. Download resource file from Github 

You can download file from 

    git clone https://github.com/tommoor/crumble.git 

    git clone https://github.com/jamescryer/grumble.js.git

Or.....

Download it via Github GUI.

## Step2. Put all required files in vender

Below is how I vendor folder looks like

    vender
    |
    |-- images
    |   |
    |   |-- crumble
    |       |
    |       |-- bubble-sprite.png
    |
    |-- javascripts
    |   |
    |   |-- crumble
    |       |
    |       |-- Bubble.js
    |       |-- jquery.crumble.min.js
    |       |-- jquery.grumble.js
    |
    |-- stylesheets
        |
        |-- crumble
            |
            |-- crumble.css
            |-- grumble.min.css


## Step3. Add require to you application

app/assets/javascripts/application.coffee

    #= require crumble/Bubble
    #= require crumble/jquery.grumble
    #= require crumble/jquery.crumble.min

ps. grumble must be above the crumble 


app/assets/stylesheets/application.css.scss

    *= require crumble/grumble.min
    *= require crumble/crumble

## Step4. Add Step-By-Step tour using html code 

app/views/shared/_guide.html.slim

    ol id = "tour"
      li  data-target= '.root-1' data-angle= '0' data-options= 'distance: 0'
        | Step1
      li data-target= '.root-2' data-angle= '30' data-options= 'distance: 50'
        | Step2
      li data-target= '.root-3' data-angle= '0' data-options= 'distance: 0'
        | Step3

ps. .root-1, .root-2, .root-3  are html tag class which you can change
to your own 

app/views/pages/home.html.slim

    /! Add where you want
    = render 'shared/guide'


## Step5. Add another custom setting in javascript and css file

app/assets/javascripts/application.coffee

    $('#tour').crumble()

or you can customize your setting such as 

    $('#tour').crumble grumble: {showAfter: 1000, hideAfter: 2000}

app/assets/stylesheets/application.css.scss

    #tour {
      display: none;
    }


After you finish step5, You are able to see the awesome introduction
tour.

Now, you might want to deploy to your VPS. In my case, I will deploy to
AWS EC2.

## Step6. Deploy to AWS EC2

Here I want to mention the problem I met, please check
<http://stackoverflow.com/questions/22222516/rake-aborted-no-such-file-or-directory-after-write-admin-css>

The solution is that you have to make sure that your project have **gem
"non-stupid-digest-assets, '1.0.3'"** in your gemfile

and 

    bundle install

Secondly, the problem is I can't see the bubble image in my staging
machine. 

Since my assets will be uploaded to S3, my solution is 

change **grumble.min.css** to **grumble.min.css.scss**

and update the image part in the code 

    .grumble{
    ....
    background-image: image-url('crumble/bubble-sprite.png') 
    ....
    }

In my opinion, since our images are uploaded to AWS S3 after
assets:precompile. 

And procompile action will generate url automatically refer to S3 link. 

However, using "background-image: url('XXXX')" in your css, the compiler
will not convert the link to S3, therefore, server will looking for the
image in local http folder.

So, I use **image-url** method in scss to fix this problem. 

## Congratulation ! 


In a nutshell, in order to lower the effort, I try to build my first
gem. If finish, I will update in my blog.

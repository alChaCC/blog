---
layout: post
title: "Google Analytics - Cross Device tracking in Ruby on Rails"
date: 2014-12-12 08:13:38 +0800
comments: true
categories:  ["Ruby on Rails","Google Analytics"]
keywords: "Ruby on Rails, Google Analytics, 中文"
description: "this article show you how to implement user id for google analytic cross device"
---

首先，先來看一下google 的說明

<iframe width="560" height="315" src="//www.youtube.com/embed/RsrAcxIsQHU" frameborder="0" allowfullscreen></iframe>


<!-- more -->

> 簡單來說，GA 在不同裝置瀏覽時，會依照每個裝置製作特別的ID, 但是，當user清掉Cookie或是重新安裝機器，就會把那個特別的ID重設，這樣他就會變成新訪客，而不是回流訪客。

當然，如果要跨Devise追蹤，既然是不同的Devise當然它的ID一定不一樣，所以一個使用者如果用電腦先在Urcosme網頁看一下等一下想要購買的商品，之後，他出發到康是美，要買產品之前拿出手機，再看一次商品確認，基本上他就會被列為兩個不同的來源

所以要跨Device追蹤，很重要的關鍵是：

> 那個特別的ID

然而，Universal(新版)的GA有提供修改 user id的功能！

[Understanding Cross Device Measurement and the User-ID](http://cutroni.com/blog/2014/04/10/understanding-cross-device-measurement-and-the-user-id/)

## 那要怎麼加上user id 呢？

### Step1. 第一步，打開User ID的功能

<img alt="GA User ID" src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/GA/user%20id%20%E5%95%9F%E7%94%A8.png"></img>

### Step2. 改網站上的Code

<img alt="GA User ID code" src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/GA/%E8%A8%AD%E5%AE%9AUser_id%20.png">


### Step3. 設定View名稱！

恭喜你 就有新的View !


### Step4. Rails 要怎麼加入 User ID呢？

如果你跟我一樣是使用Devise gem作為登入的lib，

#### Step 1. 在 app/views/layouts/application.html.slim 加上

    = render 'shared/google_analytics', user_id: current_user.try(:id) 

ps. 若是使用 partial

    = render :partial => "partials/google_analytics" , :locals => { user_id: current_user.try(:id)}

*重點就是那user_id，如果不用try的話，若是current_user是nil，就會報錯！*


#### Step 2. 編輯 app/views/shared/_google_analytics.html.erb

    <script>
    
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
    
      <%- if user_id.present? %>
        ga('create', 'UA-XXXX-YYYY', {'userId': '<%= user_id %>'})
      <%- else %>
        ga('create', 'UA-XXXX-Y', 'urbox.cc');
      <% end %>
      ga('send', 'pageview');
    
    </script>


### 那假設user沒有登入，你沒有辦法給他user id 

Google 有推出(工作階段整合) Session Unification的功能，當你啟動了這個功能後，基本上有User ID的就會被放在一個群組，沒有User ID的就會在另外一個群組！

但是厲害的是，Google在同一個session內，若發現這個ID(隨機產生)被重新assign過(系統assign)，他會把之前的action記錄給後來的ID

## 那套上User ID後，會有什麼差別呢？

  1. 你的指標(metrics)計算方式不同，但是更精確了！

  2. 你擁有了跨裝置的報告. 

  3. Limited date range.

  你的Data範圍是90天。
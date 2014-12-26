---
layout: post
title: "[HowTo] Get Google Analytics Engagement Using R"
date: 2014-12-26 08:17:04 +0800
comments: true
categories: ["Google Analytics", "R"]
keywords: "Google Analytics, engagement, 中文, R, RGoogleAnalytics"
description: "this article show you how to get ga engagement from R，利用R取得GA網站參與度"
---


<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/2014%E5%B9%B4engagement-pageviews%E5%9C%96.png" alt="every months google analytic engagement(pageviews X session Duration) in 2014 using R">

**使用者在網站上的參與程度**，是我一直滿好奇的指標！

在GA裡，網站參與度，如下圖

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-22%20%E4%B8%8A%E5%8D%883.13.48.png" alt=“google analytics engagement”>


這系列的文章，我的target是 我想知道今年(2014)整體使用者參與度的變化與趨勢

此篇文章是focus 在如何透過R抓取資料並分析成和 GA view一樣的資料！

之後，再看看可以看到什麼樣比較有意義的資料～

let's go !

<!-- more -->


## Google Analytic API 申請 

在做GA之前，別忘記要申請**[GA API權限](http://ccaloha.herokuapp.com/blog/2014/12/24/howto-get-google-analytics-using-r-rgoogleanalytics-using-users-pageviews-time-as-an-example/)**


## Google Query Explorer [link](https://ga-dev-tools.appspot.com/explorer/) 

Google 提供的工具，我覺得還滿好用的！

在使用API之前，使用 explorer 可以讓你先有Fu大概知道會拿到什麼樣的資料！

大概看一下怎麼用吧

### Step1. 先登入Google Analytics的帳號

### Step2. 回到Google Query Explorer，重新refresh

點選認證

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-25%20%E4%B8%8A%E5%8D%888.16.31.png" alt="點選 Click Here to authorize">

你就可以看到

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-25%20%E4%B8%8A%E5%8D%888.20.28.png" alt="Google Query Explorer 取得GA權限後頁面">

其中，**account** /  **Property** / **View(Profile)** 就是

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-25%20%E4%B8%8A%E5%8D%888.24.24.png" alt="對應GA">


### Step3. 看一下哪些GA View 對應到API的名稱

請到 [Google Analytics Dimensions & Metrics Reference](https://developers.google.com/analytics/devguides/reporting/core/dimsmets)

我們要找的就是

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-26%20%E4%B8%8A%E5%8D%887.46.24.png" alt="Sessions">

點進去**"ga:sessionDurationBucket"**

你會看到 **“web view name: Session Duration”** 沒錯！ 那個就是對應到GA View的名稱！

耶～～找到了～～ 

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-26%20%E4%B8%8A%E5%8D%887.48.45.png" alt="ga:sessionDurationBucket definition">


### Step4. 找到之後，趕緊來Google Query Explorer試試抓數據的感覺

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-22%20%E4%B8%8A%E5%8D%883.20.14.png" alt="fetch data from google query explorer">

ya~~~拿到資料了！

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-26%20%E4%B8%8A%E5%8D%887.54.52.png" alt="get ga:sessionDurationBucket , ga:sessions and ga:sessionDuration from Google Query Explorer">

咦！那個**ga:sessionDurationBucket**好像有點怪怪的～

各位人客，請不要緊張～

那是因為他吐回來的資料是**String**，所以他的排序才是這樣～

### Step5. R

說明都寫在裡面！

ps. 由於小弟我還是R新手，寫的鳥鳥的地方，還請見諒，如果可以的話，可以留言告訴我，哪裡怎麼寫會比較好～ 感謝！ 

<script src="https://gist.github.com/alChaCC/4fee2a25a422dceb40f5.js"></script>


### Done

先來看 2014年每月 pageview 與 使用者平均在線時間 的 bar chart

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/2014%E5%B9%B4engagement-pageviews%E5%9C%96.png" alt="every months google analytic engagement(pageviews X session Duration) in 2014 using R">


再來看 2014年每月 sessions 與 使用者平均在線時間 的 bar chart

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/2014%E5%B9%B4engagement-sessions%E5%9C%96.png" alt="every months google analytic engagement(sessions X session Duration) in 2014 using R"> 
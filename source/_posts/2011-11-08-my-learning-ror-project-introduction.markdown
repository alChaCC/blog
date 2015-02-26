---
layout: post
title: "我的RoR學習專案-起步"
date: 2011-11-08 08:14
comments: true
categories: ["Ruby on Rails"]
---
我想學習最快的方式就是
{% blockquote %}
Do Something by myself !
{% endblockquote %}

所以我想，不然就來做個人網站！

開始之前，必須先規劃一下

我的需求是：

我的首頁有三個連結分別是：關於我，部落格，專案

關於我 -> 先有一些簡單的連結就好

部落格 -> 利用 octopress 架設到本機端，用超連結連過去

專案   -> 放AS3小遊戲, github, Ruby on Rails論壇,C/C++-MonteCarlo程式, Linux
<!--more--> 
{% blockquote %}
特別著重在開發Ruby on Rails的論壇
{% endblockquote %}

論壇的部份，我就以ihower大的作業來實作
{% blockquote ihower  http://ihower.tw/rails3/example.html 簡易論壇系統 %}

   * 開發一個簡易論壇系統。系統要有 Forum 與 Post 兩個 model，寫出 CRUD 介面，並且文章網址是使用 http://forum.local/forums/1/posts/2 這種表示。
  
   * 使用 web-app-theme 套版
  
   * 使用者必須能夠 註冊 / 登入，登入後才可以發表 Post，不然只能瀏覽。只有自己的 Post 才能進行修改與刪除。請使用 devise gem。
  
   * 論壇的文章要能夠分頁，每一頁 20 筆，每一個論壇要秀出現在論壇裡有多少文章數量。請使用 kaminari gem。
  
   * 可依照文章時間排序，請使用 Model 的 scope 功能。
  
   * 每篇文章可以上傳附件。請使用 paperclip gem。
  
   * 建立一個後台，讓管理員可以刪改所有文章，網址是 http://forum.local/admin/。只有身分是 admin 的人可以進後台。admin 的判別方是 column 裡加一個 boolean，判斷是否 admin。這個 attribute 必須用 attr_accessible 或 attr_protected 保護。
  
   * 用 Rake 撰寫的產生假資料的步驟。執行 rake dev:fake 即會產生假文章與假論壇。
{% endblockquote  %}

另外我自己加的
   
   * 文章可以使用google map 標地點 -> 就像地圖日記


實作過程中我參考了網路許多強者的文章，特別是ihower和xdite ，在這邊要特別謝謝他們阿～～

目標這次專案我可以學到
{% blockquote %}
RoR開發經驗尤其是使用RESTful的概念

透過分散式版本控制來控管程式碼->git/github和bitBucket

如何將ror建立在自己架設的server

如何管理伺服器，特別是寫出一些管理的script

如何整合ror和as3以及各種api（facebook,twitter,plurk,youtube,google map）

{% endblockquote%}






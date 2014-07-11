---
layout: post
title: "我的RoR學習專案-Day 6 -依照文章時間排序+論壇的文章要能夠分頁"
date: 2012-01-14 22:30
comments: true
categories: Ruby_on_Rails
---

ＯＫ！！！！看看還有哪些功能尚未完成！！！

>可依照文章時間排序，請使用 Model 的 scope 功能。

先來看看ihower大大怎麼說

>[Scopes 作用域](http://ihower.tw/rails3/activerecord.html)
>Model Scopes是一項非常酷的功能，它可以將常用的查詢條件宣告起來，讓程式變得乾淨易讀，更厲害的是可以串接使用。....
<!--more--> 

所以我只加了一句話再model裡
	default_scope order('created_at DESC')
然後把controller裡頭的@post.where(:id=>XXX)變成
@post.where(:id=>XXX).order('created_at DESC')
這樣就ＯＫ了

再來我們來看還有甚麼工作！

>論壇的文章要能夠分頁，每一頁 20 筆，每一個論壇要秀出現在論壇裡有多少文章數量。請使用 kaminari gem。


我第一步
	gem 'kaminari'
第二步在console下
	bundle install
	rails g kaminari:views default
	rails g kaminari:config

雖然有分頁出來，不過選單好醜！！！

於是我去改css檔的這個
	.pagination a, .pagination span {
  		border: 0px solid #c3c4ba;
  		-moz-border-radius: 2px;
  		-webkit-border-radius: 2px;
  		border-radius: 2px;
  		margin-right: 5px;
  		padding: 2px;
  		width: 50px;
  		text-align: center;
  		background: #dddddd;
  		background-image: url("images/button-background.png");
  		color: #111111;
	}
	.pagination a:hover {
  		border: 1px solid #818171;
  		-webkit-box-shadow: 0 0 4px rgba(0, 0, 0, 0.3);
  		-moz-box-shadow: 0 0 4px rgba(0, 0, 0, 0.3);
  		box-shadow: 0 0 4px rgba(0, 0, 0, 0.3);
	}
	.pagination span.current {
  		background: #261f1f;
  		color: white;
  		border: 2px solid #261f1f;
	}


OK~之後我們來增加可以算頁面功能 我參考xdite大大的 [Rails 101](http://rails-101.logdown.com/)來寫

> 支持正版！ 這就是愛台灣啦！

然後在下
	rails g migration add_posts_count_to_forum
編輯新的migration檔
	class AddPostsCountToForum < ActiveRecord::Migration
  		def self.up
    		add_column("forums", "posts_count" , :integer, :default => 0)
  		end

  		def self.down
    		remove_column("forums","posts_count")
  		end
	end

之後再下
	rake db:migrate
	rails console

因為一開始是從0開始

由於第一次使用！所以必須把已經有的文章數量先設給posts_count這個欄位

做法如下：先找出post裡頭forum_id為1的數量
	post_1 = Post.find_all_by_forum_id(1)
	post_1.size
	forum_1 = Forum.find_by_id(1)
	forum_1.posts_count=請輸入post_1.size看到的值
	forum_1.save

請把1改成2,3,4（因為之前我手賤建了四個）

在model/post加入
	belongs_to :forum , :counter_cache => true

然後在改view 只要是forum index有關的東東 ，都要改！

admin的forums/index

好看閱讀版
[ccaloha / app / views / admin / forums / index.html.erb](https://github.com/alChaCC/ccaloha/blob/feature/add_web_app_theme_feature/app/views/admin/forums/index.html.erb)
	<div class="block">
  	<div class="secondary-navigation">
    	<ul class="wat-cf">
      	<li class="first active"><%= link_to "#{t("web-app-theme.list", :default => "論壇首頁")}", admin_forums_path  %></li>
     	<li><%= link_to "#{t("web-app-theme.new", :default => "新增論壇")}", new_admin_forum_path %></li>
    	</ul>
  	</div>          
  	<div class="content">          
    	<h2 class="title"><%= t("web-app-theme.all", :default => "All")  %> 論壇</h2>
    	<div class="inner">
      		<table class="table">
        		<tr>             
          		<th class="first">ID</th>
          		<th>
            <%= t("activerecord.attributes.admin_forum.forum_name", :default => t("activerecord.labels.forum_name", :default => "版名")) %>
          </th>
                    <th><%= t("web-app-theme.created_at", :default => "Created at")  %></th>
					<th><%= t("web-app-theme.created_at", :default => "文章數")  %></th>
          <th class="last">&nbsp;</th>
        </tr>
        <% @forums.each do |forum| -%>
        <tr class="<%= cycle("odd", "even") %>">
          <td>
            <%= forum.id %>
          </td>
          <td>
            <%= link_to forum.forum_name, admin_forum_path(forum) %>
          </td>
          <td>
            <%= forum.created_at %>
          </td>
		  <td>
            <%= forum.posts_count %>       
          </td>
          <td class="last">
            <%= link_to "#{t("web-app-theme.show", :default => "進入論壇")}", admin_forum_path(forum) %> |
            <%= link_to "#{t("web-app-theme.edit", :default => "編輯論壇")}", edit_admin_forum_path(forum) %> |
            <%= link_to "#{t("web-app-theme.delete", :default => "刪除論壇")}", admin_forum_path(forum), :method => :delete, :confirm => "#{t("web-app-theme.confirm", :default => "確定要刪除?")}" %>
          </td>
        </tr>          
        <% end -%>
      </table>
      <div class="actions-bar wat-cf">
        <div class="actions">
        			</div> 
      			</div>
    		</div>
  		</div>
	</div>
	<% content_for :sidebar, render(:partial => 'sidebar') -%>

一般user可以看到的forums/index

[ccaloha / app / views / forums / index.html.erb](https://github.com/alChaCC/ccaloha/blob/feature/add_web_app_theme_feature/app/views/forums/index.html.erb)

	<div class="block">
  	<div class="secondary-navigation">
    <ul class="wat-cf">
    <li class="first active"><%= link_to "#{t("web-app-theme.list", :default => "論壇首頁")}", forums_path  %></li>
    </ul>
  	</div>          
  	<div class="content">          
    <h2 class="title"><%= t("web-app-theme.all", :default => "所有")  %> 看板</h2>
    <div class="inner">
      <table class="table">
        <tr>             
          <th>
            <%= t("activerecord.attributes.forum.forum_name", :default => t("activerecord.labels.forum_name", :default => "版名")) %>
          </th>
                    <th><%= t("web-app-theme.created_at", :default => "建立時間")  %></th>
						<th><%= t("web-app-theme.created_at", :default => "文章數")  %></th>
          <th class="last">&nbsp;</th>
        </tr>
        <% @forums.each do |forum| -%>
        <tr class="<%= cycle("odd", "even") %>">
          <td>
            <%= link_to forum.forum_name, forum_posts_path(forum) %>
          </td>
          <td>
            <%= forum.created_at %>
          </td>
			<td>
	            <%= forum.posts_count %>
	          </td>
          <td class="last">
            <%= link_to "#{t("web-app-theme.show", :default => "進入論壇")}", forum_posts_path(forum) %> |
          </td>
        </tr>          
        <% end -%>
      </table>
      <div class="actions-bar wat-cf">
        <div class="actions">
        </div> 
      </div>
    </div>
  	</div>
	</div>
	<% content_for :sidebar, render(:partial => 'sidebar') -%>

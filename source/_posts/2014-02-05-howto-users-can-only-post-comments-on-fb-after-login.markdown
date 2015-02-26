---
layout: post
title: "[HowTo] 讓使用者登入網站後，才允許Facebook留言 - ROR + Coffeescript + CSS + Devise"
date: 2014-02-05 21:49:45 +0800
comments: true
categories: ["Ruby on Rails"]
---

### 1.在Html page加上
	
		<div class="fb_comment_container">
		<div class="event_fb_blur">
			<p><a href="javascript:;" onclick="App.check_login_status();">請登入會員先</a></p>
		</div>
		<div class="fb-comments" data-colorscheme="light" data-href="http://XXX.OOO" data-numposts="50" data-width="600"></div>
		</div>
App.check_login_status() => *寫在application.coffee裏*
		
### 2.加上CSS 

目的：加上遮罩讓使用者無法點入留言

		.fb_comment_container {
		  text-align: center;
		  -webkit-border-radius: 10px;
		  -moz-border-radius: 10px;
		  border-radius: 10px;
		}
		
		.event_fb_blur {
		  width: 800px;
		  height: 95px;
		  background: rgba(0, 0, 0, 0.8);
		  margin: 0 auto;
		  position: absolute;
		  z-index: 100;
		  left: 230px;
		  padding: 0 14px;
		  }
		
		.event_fb_blur p{
		position: relative;
		margin: 0 auto;
		color: white;
		font-size: 30px;
		cursor:pointer;
		line-height: 104px;
		text-decoration: underline
		}

### 3.在config/initializers/devise.rb 加上
目的：使得devise在登入成功或登出時，寫出session讓javascript可以知道是否有登入成功

		  Warden::Manager.after_set_user do |user,auth,opts|
		    auth.cookies[:signed_in] = 1
		  end
		
		  Warden::Manager.before_logout do |user,auth,opts|
		    auth.cookies.delete :signed_in
		  end

### 4.在app/controllers/application_controller.rb加上

目的：儲存之前瀏覽的位置，並且在登入成功後，導向回去
			
		  after_filter :store_location

		  def store_location 
		    if (
		      request.fullpath != "/account/sign_in" &&
		      request.fullpath != "/account/sign_up" &&
		      request.fullpath != "/account/password" &&
		      request.fullpath != "/account/sign_out" &&
		      !request.xhr?) # don't store ajax calls
		    session[:previous_url] = request.fullpath 
		    end
		
		    if request.fullpath == "/admin_users/sign_in"
		      session[:previous_url] = "/admin"
		    end
		
		  end
		
		def after_sign_in_path_for(resource)
		   session[:previous_url] || root_path
		end
		
### 5.在app/assets/javascripts/application.coffee加上

目的：使用js來達成功能

		getCookie: (match) ->
			key = match + "="
		    for c in document.cookie.split(';')
		      c.substring(1, c.length) while c.charAt(0) is ''
		      return c.substring(key.length, c.length) if c.indexOf(key) >= 0 
		    return null
		
		check_login_status: () ->
			window.open('/account/sign_in','_self',width=600,height=300,
			toolbar=0,menubar=0,location=1,status=1,scrollbars=1,
			resizable=1,left=0,top=0)
		
		init: () ->
    		is_signed = window.App.getCookie("signed_in")
    		if is_signed is '=1' or  is_signed is '1' #剛登入成功時，is_signed的值是1，但是之後就會變成=1，顆顆～
      			$(".event_fb_blur").css({"display":"none"})

		$(document).ready ->
	  		App.init()

### 完成!

Bug: 

1. 當頁面縮放時，遮罩不會隨著變動
2. 尚未整合使用者留言後，可以直接記錄到user model


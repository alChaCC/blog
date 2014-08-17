---
layout: post
title: "[HOWTO] 5 steps let your EC website applying GA E-commerce using Ruby on Rails"
date: 2014-08-17 21:25:55 +0800
comments: true
categories: ["Ruby_on_Rails,Google_Analytics"]
keywords: "Ruby on Rails, Google analytic, Ecommerce Tracking, 中文, multi-select, modal"
description: "5 steps let your EC website applying GA E-commerce using Ruby on Rails"
---

這篇你會知道如何在 Rails 加上 GA E-commerce的 code

基本上就是參考[GA- Ecommerce Tracking - Web Tracking (analytics.js)](https://developers.google.com/analytics/devguides/collection/analyticsjs/ecommerce)

google 是建議 GATC(google analytic tracking code)可以埋在當使用者完成交易後的感謝頁面

所以，我也是加上訂單created 後的動作，

就讓我們開始吧!

<!-- more --> 

## Step 1. Order Controller

在 **app/controllers/orders_controller.rb** 

因為需要多一個步驟，所以我是新增一個新的 action，**send_data_to_ga_ec**

	def send_data_to_ga_ec
		@order = Order.find_by_order_no(params[:id]) 
	end

## Step 2. Route and Controller 

在 **config/routes.rb**

因為加了一個action, 所以我補上一條新的routing規則

	  get '/orders/send_data_to_ga_ec', :to => 'orders#send_data_to_ga_ec' 
	  
*ps. 注意！一定要放在resource :orders前面，不然會無效*
	  	  
回到 **app/controllers/orders_controller.rb**

把當訂單完成後，要導向的動作，補上去

	def create
		@order = current_user.orders.build(permitted_params.order)
		  if @order 
			@order.add_line_items_from_cart(@cart)
				respond_to do |format|
					if @order.save
						format.html { 
						   redirect_to orders_send_data_to_ga_ec_path(:id => @order.order_no), notice: "感謝您的訂購，您可以點選[我的訂單]查看訂單資訊，或於幾分鐘後，檢查是否收到訂單確認信"
						}
					else
						format.html { render action: 'new' }
					end
				end
			end
	end
	
	
## Step 3. View 

這邊就是單純把他購買的東西show出來而已！重點在下兩步！

	.home-block 
	  h2.home-block-heading
	    span  這是您本次的購買資訊
	    
	  table.table.cart-table.table-striped.table-bordered.table-hover.span12
	        thead
	          tr
	            th 產品名稱
	            th 購買數量
	            th 購買顏色
	            th 購買尺寸
	            th 購買時優惠方案
	        tbody
	          - @order.line_items.each do |line_item|
	              tr
	                td= link_to line_item.product.name, product_path(line_item.product.id)
	                td= line_item.count
	                td= line_item.color
	                td= line_item.size
	                td= line_item.discount_name
	                

## Step 4. Application Layout

因為一般的GATC，我們都是裝在header，所以以Rails來說，就是寫在

**app/views/layouts/application.html.slim**

      - if controller_name == 'orders' && action_name == 'send_data_to_ga_ec'
        = render 'shared/google_analytics_ec' , user_id: current_user.try(:id), order: @order
      - else
        = render 'shared/google_analytics' , user_id: current_user.try(:id) 
 
 有沒有看到那個 **if controller_name == 'orders' && action_name == 'send_data_to_ga_ec'** 
 
 就是那個讓我判斷說，當這個action時，要load不同的GATC
 
 
## Step 5. Partial View - for google_analytics_ec

要填的參數，我就不再贅述了～ 請看GA 的官方 document

**app/views/shared/_google_analytics_ec.html.erb**

	<script>
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	
	  ga('create', 'UA-XXXX-XXX', 'auto');
	  <%- if user_id.present? %>
	    ga('set', '&uid', <%= user_id %>);
	  <% end %>
	  ga('require', 'displayfeatures');
	  
	  // =========================== GA-Ecommerce Start==========================
	  ga('require', 'ecommerce');
	  ga('ecommerce:addTransaction', {
	    'id': '<%= order.order_no %>',                        // Transaction ID. Required.
	    'affiliation': 'Heartbeat',                           // Affiliation or store name.
	    'revenue': '<%= order.total_price %>',                // Grand Total.
	    'shipping': '<%= order.transaction.ship_fee %>',      // Shipping.
	    'tax': '' ,                                           // Tax.
	    'currency': 'TWD'                                     // local currency code.
	  });
	
	  <% order.line_items.each do |line_item| %>
	  ga('ecommerce:addItem', {
	    'id': '<%= order.order_no %>',                        // Transaction ID. Required.
	    'name': '<%= line_item.product.name %>',              // Product name. Required.
	    'sku': '<%= line_item.product.product_no %>',         // SKU/code.
	    'category': '<%= line_item.product.tag_list%>',       // Category or variation.
	    'price': '<%= line_item.product.selling_price%>',     // Unit price.
	    'quantity': '<%= line_item.count%>',                  // Quantity.
	    'currency': 'TWD' 
	  });
	  <% end %>
	  ga('ecommerce:send');
	  // =========================== GA-Ecommerce End==========================
	  ga('send', 'pageview');
	</script>
 
 
 
 
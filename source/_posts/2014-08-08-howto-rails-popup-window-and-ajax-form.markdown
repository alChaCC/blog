---
layout: post
title: "[HOWTO] 跳出視窗，內含動態選單"
date: 2014-08-08 12:40:10 +0800
comments: true
categories: ["Ruby_on_Rails,ajax,modal"]
keywords: "Ruby on Rails, ajax, form, jquery, multi-select, modal"
description: "Ajax pop up box using Ruby on Rails"
---

屁話區：

最近要準備開發比較user friendly的後台，於是乎，想到這樣的功能，

於是，我拿了之前開發過的專案來試玩看看～～ 快來看一下中間的眉角～(ps.其實也沒有什麼眉角...都是g來的XDDDD) 

## 需求描述：

使用者希望點選"編輯"後，直接popup編輯視窗，裡頭還包含了動態表格

More specific, 來個簡單使用者情境：

> 後台管理人員，需要幫其中一張訂單，加購商品

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/%5Bhowto%5D%20%E8%B7%B3%E5%87%BA%E8%A6%96%E7%AA%97%EF%BC%8C%E5%85%A7%E5%90%AB%E5%8B%95%E6%85%8B%E9%81%B8%E5%96%AE/popup%E8%A6%96%E7%AA%97.png" alt="加購商品跳出視窗">


就讓我們繼續看下去....這崮中有什麼訣竅～～～～

<!-- more -->


在文章的開始，當然要先感謝前人的知識、還有一堆Open Source

##REF 

[Rails 4 submit modal form via AJAX and render JS response as table row](http://ericlondon.com/2014/03/13/rails-4-submit-modal-form-via-ajax-and-render-js-response-as-table-row.html)

[Rails 3, jQuery and multi-select dependencies](http://www.petermac.com/rails-3-jquery-and-multi-select-dependencies/)


[Bootstrap- modal.js](http://getbootstrap.com/javascript/#modals) => 用來做popup視窗

[Selec2 js](http://ivaynberg.github.io/select2/) => 用來做動態選資料


# 流程

1. 管理人員在後台，訂單的list頁，有一個加購的button 
2. 點選這個button後，會跳出一個視窗
3. 視窗裡面有一個表格，上面會預先帶入這個訂單的ID，還有一個產品編號的select功能
4. 當管理人員慢慢打字輸入了產品編號，系統會自動搜尋可能的結果
5. 選擇了一個產品編號，底下會自動跳出這個加購的資訊，例如：顏色、尺寸、數量

ps. 我的View是使用slim

# 流程一：管理人員在後台，訂單的list頁，有一個加購的button 

你可能會有一個訂單清單

在 *app/views/orders/index.html.slim* 你只要加上

	= link_to '加購', '#add_product_modal', 'data-toggle' => 'modal', class: 'btn 
	btn-mini', 'data-order' => order.id

**重點是那個'data-toggle' => 'modal'** => 加了就有modal的功效歐～～

還有另外一個伏筆，那個 'data-order' => order.id 

慢慢讀下去你就會知道那個要幹嘛了！

大概可能會長這樣	

	- @orders.each do |order|
		= ...
		= link_to '加購', '#add_product_modal', 'data-toggle' => 'modal', class: 'btn btn-mini', 'data-order' => order.id


ps. 這邊你可能會有個疑惑，囧～這個link_to 怎麼沒有 link to 的位置?! 人客啊～不要急～讓我們繼續看下去

###成果：

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/%5Bhowto%5D%20%E8%B7%B3%E5%87%BA%E8%A6%96%E7%AA%97%EF%BC%8C%E5%85%A7%E5%90%AB%E5%8B%95%E6%85%8B%E9%81%B8%E5%96%AE/%E8%A8%82%E5%96%AElist.png" alt="訂單list">

# 流程二：點選這個button後，會跳出一個視窗

在 *app/views/orders/index.html.slim* 繼續加上，我是把它加在最底下，不過你也可以考慮拉出一個partial view，depend on you摟～

不要覺得好像很厲害(但是寫這個套件很厲害!)～這一串是從Modal官網看到的sample，只是把它拿出來用而已

	.modal.fade#add_product_modal tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true"
	  .modal-dialog
	    .modal-content
	      .modal-header
	        button.close type="button" data-dismiss="modal" aria-hidden="true"
	          | &times;
	        h4.modal-title#myModalLabel
	          | 加購產品
	      .modal-body
	        = render 'extra_buy_form' 
	      .modal-footer
	        button type="button" class="btn btn-default" data-dismiss="modal"
	          | 關閉


這裡頭有ㄧ個關鍵，就是那個跳出來視窗，裡頭的內容(在我們的例子，也就是表格)

我把它寫成 partial view: **extra_buy_form**

其他的東東，我想看那個class name就知道了吧～

## 流程二 - 1 既然都已經寫好modal，那當然要記得要有他的js歐～不然不會有效果

加入在*app/assets/javascripts/admin.js* (這是因為我的admin有自己的版，裡頭會抓admin.js)

	//= require bootstrap.min 
	
# 流程三：視窗裡面有一個表格，上面會預先帶入這個訂單的ID，還有一個產品編號的select功能

這邊就進到了，**extra_buy_form**的部分，

由於是在order底下，所以我的檔案是建立在 *app/views/admin/orders/_extra_buy_form.html.slim*

	= simple_form_for :line_item,:url => update_extra_buy_admin_orders_path, defaults: { input_html: { remote: true, 'data-model' => 'product'}}do |f|
	  = f.input :order_id,  label: '加入訂單編號：'
	  = f.input :product_id, input_html: {class: 'form-control', data: {product_selector: 'true'} }
	  #buying_detail
	  .text-center.small-padding
	    = submit_tag '送出', disabled_with: '送出中', class: 'btn block-btn'
	    
這邊有幾個點要講：

1. 由於我們這個不屬於orde model的屬性，也沒有任何 instance variable (例如：@line_item)被帶入，所以simple_form 我是使用 symbol (:) 來表示
2. 再來，那個url，就代表著等一下這張表格會被 post到哪裡，等下會說明 order controller的部分和route
3. 第三行，就是要用select2 來實作的動態select內容的寫法，最重要的是那個：data: {product_selector}
4. 第四行非常重要的！ 當你選完產品id後，這邊就會render出這個產品的相關資訊，等一下會介紹到！！！
5. 那個order_id，嘿嘿～～ 等一下流程五會提到！

## 流程四：當管理人員慢慢打字輸入了產品編號，系統會自動搜尋可能的結果

這邊就是select2的實作！

首先，先建立一個js吧～ *app/assets/javascripts/admin/proudct_selector.js.coffee*
	
	jQuery ($) ->
	  $(document).on 'ready page:load', ->
	    $('[data-product-selector]').each ->
	      $this = $(this)
	      $this.select2(
	        placeholder: "輸入產品編號"
	        minimumInputLength: 0
	        allowClear: true
	
	        ajax:
	          url: '/admin/products/get_product_list.json'
	          data: (term, page) -> q: term
	          results: (data, page) -> results: data
	
	        initSelection: (element, callback) ->
	          if $this.val() isnt ''
	            $.ajax(
	              url: "/admin/products/#{$this.val()}.json"
	              success: (data) -> callback(data)
	            )
	      )

這邊有幾個點要講：

1.  **$('[data-product-selector]')** 就是找到 這個 => **data: {product_selector}**
2.  **url: '/admin/products/get_product_list.json'** => 這邊要去跟controller要資料
3.  **url: "/admin/products/#{$this.val()}.json"** => 這邊其實用不太到，不過，如果你可能會有預設值的話，譬如說，你是某個form 可以給人家編輯


###成果：

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/%5Bhowto%5D%20%E8%B7%B3%E5%87%BA%E8%A6%96%E7%AA%97%EF%BC%8C%E5%85%A7%E5%90%AB%E5%8B%95%E6%85%8B%E9%81%B8%E5%96%AE/select2%20serarch%E5%8A%9F%E8%83%BD.png" alt="select2 search">

## 流程四 - 1：既然這邊用到了select2、還有你自己寫的js，別忘了....

加入在*app/assets/javascripts/admin.js* (這是因為我的admin有自己的版，裡頭會抓admin.js)

	//= require select2
	//= require admin/product_selector

## 流程四 - 2：剛剛提到說兩個 admin/products/XXX.json 就是要跟controller拿資料，所以當然我們要新增action給他摟

請加在： *app/controllers/admin/products_controller.rb*

首先

	def serial_products(products)
		products.map { |p| {id: p.id, text: p.product_no}}
	end

	def show 
		@product = Product.find(params[:id])

		respond_to do |f|
			f.html
      		f.json { render json: serial_products(@product) } #要給ajax使用
    	end
    end
    
    
再來

	def get_product_list
		@products = if params[:q]
                  		Product.on_sale.filter_by(params[:q])
                	else
						Product.on_sale
					end
		respond_to do |f|
			f.json { render json: serial_products(@products)} #只給ajax使用
		end
	end


重要的眉角：

	if params[:q]
    	Product.on_sale.filter_by(params[:q])
	...
	
為甚麼要有這個呢？

那是因為*app/assets/javascripts/admin/proudct_selector.js.coffee*這個js不是有一個

	url: '/admin/products/get_product_list.json'
	data: (term, page) -> q: term

有沒有看到那個 “q“ 

沒錯！ 就是那個q，他會丟一個param[:q]的值給get_product_list，

也就是這個，我們就可以達成 **慢慢打字輸入了產品編號，系統會自動搜尋可能的結果**

## 流程四 - 3： 從上一個步驟(四-3)裡頭有"Product.on_sale.filter_by"，這邊是model的方法


我們來看一下model，並加在 *app/models/product.rb*

	scope :on_sale, -> {where(is_added: true)}
	scope :filter_by, lambda { |q| where('product_no LIKE :qurey', qurey: "%#{q}%") }

這邊小眉角：

	where('product_no LIKE :qurey', qurey: "%#{q}%")
	
這個就是rails用來做 like搜尋(我把它稱作模糊搜尋，不知道有沒有錯)

## 流程四 - 4： 既然controller都寫完了，別忘記route歐！

要改：*config/routes.rb*

	namespace :admin do
	  
	  ...
	  
	  resources :products do
	  	...
	    
	    collection { get :get_product_list}
	  end
	  
	  resources :orders do
	   	...
	   	collection { post :update_extra_buy }
	  end
	  
	  ....
	  
	end


# 流程五：選擇了一個產品編號，底下會自動跳出這個加購的資訊，例如：顏色、尺寸、數量

這邊我們要來看，*app/views/admin/orders/_extra_buy_form.html.slim*

裡面的

	  #buying_detail
	  
怪怪....為甚麼這一行，就可以讓它自動跳出加購的資訊？！
	 
接下來厲害了！！

## 流程五-1：表格上面select 也已經動態可以選了，那底下的動態表格，怎麼沒有render出來？！ 

這邊 我們必須使用一個javascript來監控那個select2的行為， 不過貌似可以寫在select2裡面，但是...我是覺得怪怪的～應該要猜開才是(ps. 其實是我不太會寫XDDDD)

沒錯！ 我們需要新增 *app/assets/admin/order.js*


	jQuery(function($) {
	  // when the #data-product-selector field changes
	  $("[data-product-selector]").change(function() {
	    var product_id = $('[data-product-selector]').val();
	    if(product_id == "") product_id="0";
	    var product = 'product_id='+ product_id;
	    jQuery.get("/admin/products/update_product_atts",product, function(data){
	        $("#buying_detail").html(data);
	    })
	    return false;
	  });
	
	  $(document).on('click', '[data-toggle=modal]', function(e) {
	    $('#line_item_order_id').val(e.target.getAttribute('data-order'));
	  });
	
	})
	
重點：

1.jQuery.get("/admin/products/update_product_atts",product, function(data){
	        $("#buying_detail").html(data);
	    })
我覺得 可以算是本日最精彩！

第一次知道原來partial view可以這樣用！！！！

等一下在講那個update_product_atts

2.**$('#line_item_order_id').val(e.target.getAttribute('data-order'));**

這個是為了那個pop視窗 *app/views/admin/orders/_extra_buy_form.html.slim* 的裡頭預設的order id值

	= simple_form_for :line_item,:url => update_extra_buy_admin_orders_path, defaults: { input_html: { remote: true, 'data-model' => 'product'}}do |f|
	  = f.input :order_id,  label: '加入訂單編號：'
	
為甚麼會有 **e.target.getAttribute('data-order')**

那是因為，我希望直接知道 使用者點的是那張訂單，所以.... 還記得....

在 *app/views/orders/index.html.slim* 你只要加上

	= link_to '加購', '#add_product_modal', 'data-toggle' => 'modal', class: 'btn 
	btn-mini', 'data-order' => order.id
	
有沒有看到'data-order' => order.id 

所以那段js只是把 值抓出來而已，然後再餵給 **f.input :order_id**



## 流程五-2：/admin/products/update_product_atts 、$("#buying_detail").html(data) 在搞什麼鬼？

其實從js來看，就會知道他就是要跟 products controller拿東東

所以，繼續來編輯我們的 *app/controllers/admin/products_controller.rb*

 
	 def update_product_atts
			product = Product.find(params[:product_id]) unless params[:product_id].blank?
			render :partial => "admin/orders/product_attrs", :locals => { :product => product} #這邊還挺酷的，只會render那個partial頁面
	 end

還有view歐  *app/views/admin/order/_product_attrs.html.slim*

	- if product.present?
	  = simple_form_for :line_item_attr, defaults: { input_html: { remote: true, url: '#'}} do |f|
	    = f.input :color, label: '顏色：' , collection: "#{product.color}".split(",").map(&:to_s)
	    = f.input :size, label: '尺寸：', collection: "#{product.size}".split(",").map(&:to_s)
	    = f.input :count, label: '數量：' , collection: (1..50), selected: '1'
	 
有沒有看到～ 那個

**jQuery.get("/admin/products/update_product_atts",product**

就是會丟出一個 params[:product_id] 給 product controller

當controller 抓到 id 後，就把那個product 資料，依照  admin/orders/product_attrs 樣子render給data，然後讓

	$("#buying_detail").html(data); 
	
把資料畫出來

傑克！這實在太神奇了！！！！！！！！！！！！

###成果：

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/%5Bhowto%5D%20%E8%B7%B3%E5%87%BA%E8%A6%96%E7%AA%97%EF%BC%8C%E5%85%A7%E5%90%AB%E5%8B%95%E6%85%8B%E9%81%B8%E5%96%AE/%E8%87%AA%E5%8B%95%E5%B8%B6%E5%87%BAform.png" alt="select2 search">

## 流程五-3：既然你自己寫的js，別忘了....

加入在*app/assets/javascripts/admin.js* (這是因為我的admin有自己的版，裡頭會抓admin.js)
	
	//= require admin/orders
	

## 打完收工！
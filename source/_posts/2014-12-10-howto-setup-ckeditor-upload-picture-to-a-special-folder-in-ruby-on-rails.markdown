---
layout: post
title: "[HOWTO]- 在Ruby on Rails 實作Ckeditor上傳圖片到各個獨立的資料夾"
date: 2014-12-10 08:04:05 +0800
comments: true
categories: ["Ruby_on_Rails"]
keywords: "ckeditor, 上傳, upload, ruby on rails, picture, 圖片, 中文"
description: “This article show you how to implement ckeditor upload picture to specific folder depended on Model. 這篇文章你可以學到實作Ckeditor上傳圖片到各個獨立的資料夾，這個資料夾會隨model和instance而變更！”
---


首先，要先感謝 **_Ayaya_**，主要是參考他的code而改編出來的功能！

一樣講一下需求

我希望使用者上傳檔案到不同特定的資料夾，譬如：A新聞的照片，只會被上傳到A新聞的資料夾

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/%5BHOWTO%5D-%20%E5%9C%A8Ruby%20on%20Rails%20%E5%AF%A6%E4%BD%9CCkeditor%E4%B8%8A%E5%82%B3%E5%9C%96%E7%89%87%E5%88%B0%E5%90%84%E5%80%8B%E7%8D%A8%E7%AB%8B%E7%9A%84%E8%B3%87%E6%96%99%E5%A4%BE/Ckeditor_upload_image_to_specific_folder.png" alt='ckeditor 上傳圖片到特定資料夾'>

之後你還可以實作 照片只能被特定使用者看到，這篇文章就不在這邊琢磨


<!--more-->

另外這篇文章，我不會提到 **Ckedior** 的基本安裝的東西，有興趣的話，請看 **[Github](https://github.com/galetahub/ckeditor)**

上傳的部分我是使用 **[ActiveRecord + Carrierwave](https://github.com/galetahub/ckeditor#activerecord--carrierwave)**


## Step1. Migration

首先，我們先從model開始，當你跑完

  rails generate ckeditor:install --orm=active_record --backend=carrierwave
  
會幫你建立model，以我的case來說，會建立**_db/migrate/20141204171531_create_ckeditor_assets.rb_**

在這邊，我要先另外加入

      t.integer :owner_id 
      t.string  :owner_type, :limit => 30  

其中**owner_type**是要記錄哪個model

**owner_id**是要記錄model的ID

舉例來說，如果你的建立產品上稿，會被記錄到 model 的就是：**Product**，另外ID可能是：**999**

所以記錄到 owner_type 就會是 "Product" ，另外owner_id 就是："999"

最後別忘記，

  rake db:migrate

## Step2. [Important] Controller 

接下來步驟，會有點麻煩

因為我不想要用ckeditor 預設的 **pictures_controller.rb** 來處理上傳的動作，所以....

來看一下，麻煩點在於

我們是後台需要實作 ckeditor，所以controller要放在 **/cooladmin/** 裡面

這個...搞了我超久，不過也是因為這樣，讓我比較了解這個機制

好吧！ 那就開始吧！！！

  rails g controller cooladmin/ckeditor_pictures

### 首先這個controller 必需繼承 **Ckeditor::PicturesController**

所以...

  class Cooladmin::CkeditorPicturesController < Ckeditor::PicturesController

那這個**[Ckeditor::PicturesController](https://github.com/galetahub/ckeditor/blob/master/app/controllers/ckeditor/pictures_controller.rb)**原本怎麼寫，就請看他們官網

由於我們不希望使用ckeditor 的before_action，所以，我們這邊都把它skip掉
  
  skip_before_filter :find_asset
  skip_before_filter :ckeditor_authorize!
  skip_before_filter :authorize_resource

### 第一個action : **index**

這個是給當使用者點選"瀏覽伺服器"時呼叫的

<img src='https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/%5BHOWTO%5D-%20%E5%9C%A8Ruby%20on%20Rails%20%E5%AF%A6%E4%BD%9CCkeditor%E4%B8%8A%E5%82%B3%E5%9C%96%E7%89%87%E5%88%B0%E5%90%84%E5%80%8B%E7%8D%A8%E7%AB%8B%E7%9A%84%E8%B3%87%E6%96%99%E5%A4%BE/ckeditor_controller_index_target_1.png'>

我的寫法是：

  def index
    @pictures = Ckeditor::Paginatable.new(pictures).page(params[:page])
    respond_with(@pictures,layout: @pictures.first_page?)
  end 


那 **pictures** 這個從那裡來？

  private
  
    def pictures
      @pictures ||= if owner
                  Ckeditor::CkeditorPicture.by_owner(owner)
                      else
                      Ckeditor::CkeditorPicture.orphan
                      end
    end
    
    def owner
      @owner ||=  case 
                  when params[:owner_type].present? && params[:owner_id].present? 
                    params[:owner_type].singularize.classify.constantize.find(params[:owner_id])
                  else
                    nil
                  end
    end

ps. **Ckeditor::CkeditorPicture.by_owner(owner)** 這個model是我改裝model，下個章節會介紹，by_owner就是去拿到屬於這個owner的image，那owner怎麼來呢？

主要透過 url 取得目前是在哪個model的哪個ID被啟動ckeditor，這樣的話，就只會去抓屬於這個modal和他所屬的id，以下面那個url為例，他會去找ckeditor_assets裡頭的屬於**owner_type**為**Product**以及**owner_id**為**1**的所有照片

** https://XXX.XXX.XXX/cooladmin/ckeditor_pictures?owner_id=2&owner_type=Product&CKEditor=product_content&CKEditorFuncNum=1&langCode=zh **

### 第二個action : **create**

照片上傳上來後，透過這個action去接

    def create
      if owner.present?
        @picture = Ckeditor::CkeditorPicture.new(owner: @owner) 
      else
        @picture = Ckeditor::CkeditorPicture.new(owner_type: params[:owner_type]) 
      end
      respond_with_asset(@picture)
    end

判斷如果 有owner存在的話，就把這個照片new進去，並設定owner進去

不然的話，就在建立照片時，就只設定**owner_type** (這邊有個問題，我還不知道怎麼解決，所以只好先丟個owner_type給他)

### 第三個action : **destroy**

很明顯就是去刪除照片～但是.....基本上這個方法不會被呼叫到....因為ckeditor會default去找

因為我們儲存到 **ckeditor_assets** table時，有一個欄位是 **type**，因為我們在new還有create時用的是 **Ckeditor::CkeditorPicture.new(owner: @owner)** 所以他的type就會是....**Ckeditor::CkeditorPicture**，所以在刪除的時候，
他default會去找有沒有這個controller => **app/controllers/ckeditor_pictures_controller.rb**

這樣當然是沒有，因為我們是寫在 /cooladmin/底下啊～～～

所以...小弟我很弱，還不知道怎麼解....所以只好copy一份出來....


  def destroy
      @picture ||= Ckeditor::CkeditorPicture.find(params[:id])
      @picture.destroy
      respond_with(@picture,location: pictures_path)
    end


完整版：**app/controllers/cooladmin/ckeditor_pictures_controller.rb**

基本上這個contoller，我是直接copy一份到**app/controllers/ckeditor_pictures_controller.rb**


  class Cooladmin::CkeditorPicturesController < Ckeditor::PicturesController
    skip_before_filter :find_asset
    skip_before_filter :ckeditor_authorize!
    skip_before_filter :authorize_resource
  
    def index
      @pictures = Ckeditor::Paginatable.new(pictures).page(params[:page])
      respond_with(@pictures,layout: @pictures.first_page?)
    end
  
    def create
      if owner.present?
        @picture = Ckeditor::CkeditorPicture.new(owner: @owner) 
      else
        @picture = Ckeditor::CkeditorPicture.new(owner_type: params[:owner_type]) 
      end
      respond_with_asset(@picture)
    end
  
    def destroy
      @picture ||= Ckeditor::CkeditorPicture.find(params[:id])
      @picture.destroy
      respond_with(@picture,location: pictures_path)
    end
  
    private
  
    def pictures
      @pictures ||= if owner
                      Ckeditor::CkeditorPicture.by_owner(owner)
                    else
                      Ckeditor::CkeditorPicture.myupload_orphan(current_employee)
                    end
    end
  
  
    def owner
      @owner ||=  case 
                  when params[:owner_type].present? && params[:owner_id].present? 
                    params[:owner_type].singularize.classify.constantize.find(params[:owner_id])
                  else
                    nil
                  end
    end
  
  end
  

## Step3. [Important] Model

這邊我是直接改ckeditor幫我產生的model **models/ckeditor/picture.rb**

我把它改成 **models/ckeditor/ckeditor_picture.rb**

  mv models/ckeditor/picture.rb models/ckeditor/ckeditor_picture.rb

幾個重點：

* 因為這個picture基本上會隸屬於不同的model 然後他們之間都是透過 owner來做type

所以

  belongs_to :owner, polymorphic: true
  
* 幾個簡單scope

在看這個scope我們來看一下，db裡面存的主要欄位內容

| assetable_id | assetable_type | type                      | owner_id | owner_type |
|--------------|----------------|---------------------------|----------|------------|
| 1            | Employee       | Ckeditor::CkeditorPicture | 2        | Product    |

assetable_type => 這個資料的上傳者class

type      => 這張照片是哪個model new進來的

owner_type    => 這張照片被用在哪個class下

看完表格就知道我的scope在幹嘛了～

    scope :myupload_orphan, -> (employee_id) {where(assetable_id: employee_id, owner_id: nil)}
      scope :by_owner_type, -> (owner,employee_id) {where(owner_type: owner.class.name, owner_id: nil, assetable_id: employee_id)}
      scope :by_owner, -> (owner) { where(owner_id: owner.id)}



完整程式：
  
  class Ckeditor::CkeditorPicture < Ckeditor::Asset
    belongs_to :owner, polymorphic: true
    mount_uploader :data, CkeditorPictureUploader, :mount_on => :data_file_name
  
    scope :myupload_orphan, -> (employee_id) {where(assetable_id: employee_id, owner_id: nil)}
    scope :by_owner_type, -> (owner,employee_id) {where(owner_type: owner.class.name, owner_id: nil, assetable_id: employee_id)}
    scope :by_owner, -> (owner) { where(owner_id: owner.id)}
  
    def url_content
      url(:content)
    end
  end


## Step4. 修改ckeitor 設定

我是使用coffeescript

  $(document).on 'ready page:load', ->
      $('[data-content-editor]').each ->
        $this = $(this)
        CKEDITOR.replace(
          this
          allowedContent: true
  
      # 設定要處理image處理
          filebrowserImageBrowseUrl: $this.data('upload-url')
  
          filebrowserImageUploadUrl: $this.data('upload-url')
        )
      
      
## Step5. 修改用到ckeditor的View

我是使用simple_form

  = f.input :content, label: '內容', input_html: { class: 'form-control', data: {content_editor: true, upload_url: upload_url_for(@product)} } 

upload_url_for請看下面

## Step6. helper 

寫這個helper的原因是因為我希望不同的model都可以使用

**app/helpers/cooladmin/admin_helper.rb**   
  
  module Cooladmin::AdminHelper
    def upload_url_for(resource)
      if resource.new_record?
        cooladmin_ckeditor_pictures_path(:owner_type => resource.class.name)
      else
        cooladmin_ckeditor_pictures_path(:owner_type => resource.class.name, :owner_id => resource.id)
      end
    end
  end

  
## Step7. Route

  Rails.application.routes.draw do
    # mount Ckeditor::Engine => '/uradmin/ckeditor'
    
    resources :ckeditor_pictures, only: [:index, :create, :destroy]
  
    namespace :cooladmin do
      # ....略
      # ckeditor使用
      resources :ckeditor_pictures, only: [:index, :create, :destroy]
    end
    
  end


## 完成！！！！！！！！！！！
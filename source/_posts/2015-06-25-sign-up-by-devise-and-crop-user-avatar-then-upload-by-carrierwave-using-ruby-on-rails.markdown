---
layout: post
title: "Sign up by Devise and Crop User Avatar then Upload by Carrierwave using Ruby on Rails"
date: 2015-06-25 01:15:45 +0800
comments: true
categories: ["Ruby on Rails"] 
keywords: "Jcrop, Carrierwave, Devise, registration ,Ruby on Rails, javascript, how to"
description: "This tutorial show you how to crop image and upload to AWS S3 after sign up"
---

ref: 

  1. http://railscasts.com/episodes/182-cropping-images-revised
  2. http://stackoverflow.com/questions/12762728/how-to-crop-image-on-upload-with-rails-carrierwave-and-minimagick
  3. https://coderwall.com/p/e9d_ja/using-carrierwave-uploader-for-tableless-model-in-rails
  4. http://stackoverflow.com/questions/24262388/carrierwave-processing-only-after-the-model-has-been-saved-model-id-is-nil

# What I done in this article 

##1. Click Upload Image

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Crop%20User%20Avatar%20and%20Upload%20via%20Carrierwave%20while%20creating%20user%20using%20Ruby%20on%20Rails/Step1%20click_upload_image.png" alt="Step 1. click_upload_image">

##2. Choose Image And Preview 

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Crop%20User%20Avatar%20and%20Upload%20via%20Carrierwave%20while%20creating%20user%20using%20Ruby%20on%20Rails/Step2%20choose%20image%20and%20preview.png" alt="Step 2. choose image and preview">


##3. Edit Avatar And Preview Image Synchronously

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Crop%20User%20Avatar%20and%20Upload%20via%20Carrierwave%20while%20creating%20user%20using%20Ruby%20on%20Rails/Step3%20edit%20avatar%20and%20preview%20sync.png" alt="Step 3. Edit Avatar And Preview Image Synchronously">


##4. Upload to AWS S3

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Crop%20User%20Avatar%20and%20Upload%20via%20Carrierwave%20while%20creating%20user%20using%20Ruby%20on%20Rails/Step4%20upload%20to%20AWS%20S3.png" alt="Step 4. Upload to AWS S3">


##5. Image Cropped And Uploaded

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Crop%20User%20Avatar%20and%20Upload%20via%20Carrierwave%20while%20creating%20user%20using%20Ruby%20on%20Rails/Step5%20image%20cropped%20and%20uploaded.png" alt="Step 5. Image Cropped And Uploaded">

<!-- more -->

# Steps

##0. Description

I use Devise for sign up, Carrierwave for upload image and Jcrop for image selection. There is an User model and user has one UserImage model. Carrierwave uploader is mounted on UserImage. In this tutorial, I'll not go through upload things. You can find lots of resources such as [carrierwave-file-uploads](http://railscasts.com/episodes/253-carrierwave-file-uploads). Also, I'll not show all devise registration and popup(modal) things. Still, there are many resources on the Internet. Ok, let's go. 

##1. Gemfile

I use jcrop for cropping image. So, add jcrop library to *Gemfile*.

    gem 'jcrop-rails-v2'

ps. don't forgot **bundle install**

##2. Model 

In User model, I only need to tell that User has a main image and it refer to UserImage model, and user signup form contains UserImage's attributes, therefore, User model should accept these nested attributes. And I create a method for building image used in upload form(you can see usage in view)

**app/models/user.rb**

    class User < ActiveRecord::Base
      ...
      has_one :main_image, :class_name => "::UserImage"
        accepts_nested_attributes_for :main_image, reject_if: :all_blank, allow_destroy: true
        
        
        def input_main_image
          self.main_image ||= self.build_main_image
          end
      ...
      end
    
UserImage model has "file" attribute which is used for upload, and we use carrierwave as our uploader, we need to mount this uploader to "file" attribute. **[!! Important !!] I guess due to Rails work flow, when UserImageUploader upload image, the UserImage custom attributes: crop_x, crop_y, crop_w and crop_h will not available to UserImageUploader that we can't crop image as we want. So we need to skip upload callback first, and we will upload after user is saved.** 

Ps. if your attribute used for mount uploader named "hello", 
  
    mount_uploader :file, UserImagesUploader
    skip_callback :save, :after, :store_file!

will be 

    mount_uploader :hello, UserImagesUploader
    skip_callback :save, :after, :store_hello!
    
**app/models/user_image.rb**

    # == Schema Information
    #
    # Table name: user_images
    #
    #  id                 :integer          not null, primary key
    #  user_id            :integer
    #  file               :string(255)
    #  created_at         :datetime
    #  updated_at         :datetime
    #
    
    class UserImage < ActiveRecord::Base
      belongs_to :user
      
        # Used for user avatar image edit
        attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
            
        mount_uploader :file, UserImagesUploader
        
        # We need to upload after all attributes assigned，so we skip upload callback first
        skip_callback :save, :after, :store_file!  
    end


##3. View 

In first picture, we have a form for sign up. Due to I have to upload an user image, we need to build it first. Then, UserImage's attributes need to be filled. And I will use some javascript methods for editing so I write some div elements such as "fake-button-upload", "fake-button-edit". Also, I need to popup a image for user editing. Below ".uploaded" codes are used for popup. Finally, you can see I setup some ids, yap~ for javascript. 

**app/views/users/registrations/new.html.slim**

    .upload_personal_image
      = f.fields_for :main_image, resource.input_main_image do |build|
        = build.file_field :file, class: "personal-image-upload-file"
        .preview-outer
          = image_tag(resource.main_image.file, id: "preview") if resource.main_image
        .personal-image-upload.icon-default-photo-150x150
        .fake-button-upload 上傳個人照
        .fake-button-edit 編輯大頭照
        
        .uploaded
          .edit-title 編輯個人照
          = image_tag(resource.main_image.file, id: "preview-edit") if resource.main_image
          .uploaded-image-edit-attr
            - for attribute in [:crop_x, :crop_y, :crop_w, :crop_h]
              = build.text_field attribute, :id => attribute
          .edit-desc 請將想要顯示的範圍拖曳至中心圓圈處！
          .fake-button-edit-ok 設為個人照

##4. CSS

**app/assets/stylesheets/front/users/registrations.css.coffee**

First we need to require jquery.Jcrop. And, I hope that our crop selector is a circle so I add.... 

    .jcrop-holder div
    {
        -webkit-border-radius: 50% !important;
        -moz-border-radius: 50% !important;
        border-radius: 50% !important;
        margin: 0 auto;
        // opacity: 0.6 !important;
    }

You can ignore them but you should notice that some classes are display none such as .personal-image-upload-file,  .preview-outer and .uploaded. These classed will show by javascript control. 

    //=require jquery.Jcrop
    
    ...
    
    .jcrop-holder div
    {
        -webkit-border-radius: 50% !important;
        -moz-border-radius: 50% !important;
        border-radius: 50% !important;
        margin: 0 auto;
    }
    
    .personal-image-upload-file {
        display: none;
      }
      
      .preview-outer {
        overflow: hidden;
          display: none;
          width: 150px;
          height: 150px;
          position: absolute;
          left: 0px;
          top: 0px;
          #preview{
            width: 150px;
            height: 150px;
          }
       }
       .uploaded {
      background-color: #FFFFFF;
      text-align: center;
      display: none;
      .edit-title {
        font-size: 20px;
        margin: 0px auto 20px auto;
        padding-top: 30px;
      }
      img {
        border: 1px dashed #dd406f;
        z-index: 2;
      }
      .edit-desc{
        margin-top: 10px;
        margin-bottom: 10px;
        font-size: 14px;
      }
      
      .uploaded-image-edit-attr{
        display: none;
      }
      .fake-button-edit-ok{
        width: 100px;
        height: 30px;
        font-size: 16px;
        display: inline-block;
        line-height: 30px;
        cursor: pointer;
        background-color: #DD406F;
        border-radius: 3px;
        color: #FFFFFF;
        text-decoration: none;
        margin-bottom: 30px;
      }
    }

##5. Javascript -> most important part for cropping image and previewing image.

First, we need to require **jquery.Jcrop** 

    #= require jquery.Jcrop

If user click .personal-image-upload icon or .fake-button-upload button, I'll trigger real upload file click. 

    $('.personal-image-upload').click -> 
      $('.personal-image-upload-file').trigger('click')
     
    $('.fake-button-upload').click ->
      $('.personal-image-upload-file').trigger('click')


How to preview image? 
 
First, I have to know original image size since if user don't resize image, I still need to send crop_x, crop_y, crop_w and crop_h to carrierwave crop function. Second, after FileReader read an image, I'll set file path to element #preview and #preview-edit src attribute. Then, I'll hide upload icon and show edit button.  

    initPreviewImage = ->    
        readURL = (input) ->
          if input.files and input.files[0]
            reader = new FileReader

            reader.onload = (e) ->
              img = new Image
              img.onload = ->
                $('#crop_x').val(0);
                $('#crop_y').val(0);
                $('#crop_w').val(img.width);
                $('#crop_h').val(img.height);
              img.src = e.target.result

              $('.preview-outer').css("display": "inline-block")
              $('#preview').attr 'src', e.target.result
              $('#preview-edit').attr 'src', e.target.result
              $('.personal-image-upload').hide()
              $('.fake-button-edit').css("display": "block")
              $('.fake-button-edit').css("right": "0px")
              $('.fake-button-upload').css("left": "0px")

            reader.readAsDataURL input.files[0]

        $('#user_main_image_attributes_file').change ->
          readURL this
     initPreviewImage();

At last, the cropping part. I setup three global variables for jcrop_api and image size(boundx, boundy). When the element .fake-button-edit button is clicked, I will call showUserImageEdit() and call my modal method for popup function. In showUserImageEdit function, if jcrop_api already existed(user choose a file already), I have to use jcrop_api to reset new image. And #preview-edit is used for binding jcrop, when user select new area or move selection, it will  call update_crop function to update crop_x, crop_y, crop_w and crop_h(don't forgot these attributes will send to carrierwave uploaded for cropping) and I will update #preview image as well.  

Ps. you might ask why rx = 150 / coords.w and ry = 150 / coords.h ? The answer is, I give preview size 150x150px in CSS.  

    jcrop_api = undefined
      boundx = undefined
      boundy = undefined

      showUserImageEdit = ->
        if jcrop_api
          jcrop_api.setImage($('#preview').attr('src'));
      
        update_crop = (coords) ->
          rx = 150 / coords.w
          ry = 150 / coords.h
          $('#preview').css
            width: Math.round(rx * boundx) + 'px'
            height: Math.round(ry * boundy) + 'px'
            marginLeft: '-' + Math.round(rx * coords.x) + 'px'
            marginTop: '-' + Math.round(ry * coords.y) + 'px'
          $('#crop_x').val(Math.floor(coords.x));
          $('#crop_y').val(Math.floor(coords.y));
          $('#crop_w').val(Math.floor(coords.w));
          $('#crop_h').val(Math.floor(coords.h));
          

        $('#preview-edit').Jcrop({
            bgOpacity: 0.4, 
            bgColor: 'black',
            onChange: update_crop,
            onSelect: update_crop,
            allowSelect: true,
            allowResize: true,
            setSelect: [50, 0, 150, 150],
            aspectRatio: 1
          }, -> 
            bounds = this.getBounds();
            boundx = bounds[0];
            boundy = bounds[1];
            jcrop_api = this);
        $('.uploaded').show()
        $('.fake-button-edit-ok').click -> 
          myModal().setTarget($('.uploaded')).close()
          jcrop_api.release()

      initPreviewImageEdit = ->
        $('.fake-button-edit').click -> 
          showUserImageEdit();
          myModal().setTarget($('.uploaded')).open()
      initPreviewImageEdit();


whole code **app/assets/javascripts/users/registrations.js.coffee**

    #= require jquery.Jcrop
    jQuery ->
      $(document).on 'ready page:load', -> 
    
        $('.personal-image-upload').click -> 
          $('.personal-image-upload-file').trigger('click')
        
        $('.fake-button-upload').click ->
          $('.personal-image-upload-file').trigger('click')
    
        initPreviewImage = ->    
          readURL = (input) ->
            if input.files and input.files[0]
              reader = new FileReader
    
              reader.onload = (e) ->
                img = new Image
                img.onload = ->
                  $('#crop_x').val(0);
                  $('#crop_y').val(0);
                  $('#crop_w').val(img.width);
                  $('#crop_h').val(img.height);
                img.src = e.target.result
    
                $('.preview-outer').css("display": "inline-block")
                $('#preview').attr 'src', e.target.result
                $('#preview-edit').attr 'src', e.target.result
                $('.personal-image-upload').hide()
                $('.fake-button-edit').css("display": "block")
                $('.fake-button-edit').css("right": "0px")
                $('.fake-button-upload').css("left": "0px")
    
              reader.readAsDataURL input.files[0]
    
          $('#user_main_image_attributes_file').change ->
            readURL this
        initPreviewImage();
    
        jcrop_api = undefined
        boundx = undefined
        boundy = undefined
    
        showUserImageEdit = ->
          if jcrop_api
            jcrop_api.setImage($('#preview').attr('src'));
            
          update_crop = (coords) ->
            rx = 150 / coords.w
            ry = 150 / coords.h
            $('#preview').css
              width: Math.round(rx * boundx) + 'px'
              height: Math.round(ry * boundy) + 'px'
              marginLeft: '-' + Math.round(rx * coords.x) + 'px'
              marginTop: '-' + Math.round(ry * coords.y) + 'px'
            
            $('#crop_x').val(Math.floor(coords.x));
            $('#crop_y').val(Math.floor(coords.y));
            $('#crop_w').val(Math.floor(coords.w));
            $('#crop_h').val(Math.floor(coords.h));
            
    
          $('#preview-edit').Jcrop({
              bgOpacity: 0.4, 
              bgColor: 'black',
              onChange: update_crop,
              onSelect: update_crop,
              allowSelect: true,
              allowResize: true,
              setSelect: [50, 0, 150, 150],
              aspectRatio: 1
            }, -> 
              bounds = this.getBounds();
              boundx = bounds[0];
              boundy = bounds[1];
              jcrop_api = this);
              
          $('.uploaded').show();
          
          $('.fake-button-edit-ok').click -> 
            myModal().setTarget($('.uploaded')).close()
            jcrop_api.release()
    
        initPreviewImageEdit = ->
          $('.fake-button-edit').click -> 
            showUserImageEdit();
            myModal().setTarget($('.uploaded')).open()
        initPreviewImageEdit();
  
  
##6. Carrierwave uploader 

As you can see I create a new version named _customize and it only do its job when model(UserImage model) has crop_x, crop_y, crop_w and crop_h attributes. And I use minimagick crop method to crop image before upload.


    class UserImagesUploader < CarrierWave::Uploader::Base
    
      include CarrierWave::MiniMagick
    
      storage :fog
      
      ...
    
      version :_customize, :if => :customize? do 
        process :crop_img
        resize_to_fill(150, 150)
      end
    
      def customize? picture
        !model.crop_x.blank? && !model.crop_y.blank? && !model.crop_w.blank? && !model.crop_h.blank?
      end
    
      def crop_img
        if !model.crop_x.blank? && !model.crop_y.blank? && !model.crop_w.blank? && !model.crop_h.blank?
          manipulate! do |img|
            x = model.crop_x.to_i
            y = model.crop_y.to_i
            w = model.crop_w.to_i
            h = model.crop_h.to_i
            img.crop("#{w}x#{h}+#{x}+#{y}")
            img
          end
        end
      end
    
      ...
    
    end
    

##7. Final step: Upload Image

Do you remember that I skip upload callback in **app/models/user_image.rb** ? 

    skip_callback :save, :after, :store_file!  

So, when should we do upload job?

Answer is after user save ! 

    class Users::RegistrationsController < Devise::RegistrationsController
      after_filter :upload_avatar, :only => :create
        
      ... 
    
      protected
    
      def upload_avatar
        if resource.persisted? && resource.main_image # user is created successfuly
          resource.main_image.store_file! 
          resource.main_image.file.recreate_versions!
        end
      end
    
      ... 
    end
  
##8. Don't forgot ...


Since we use Devise for sign up, and we use nested attributes, we need to tell Devise permitted parameters.

**app/controllers/applicatio.rb**

    class ApplicationController < ActionController::Base
      ...
      before_action :configure_permitted_parameters, if: :devise_controller?

      private
    
      def configure_permitted_parameters
        devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, main_image_attributes: ['id', '_destroy', 'file', 'crop_x', 'crop_y', 'crop_w', 'crop_h'])}
      end 
      ... 
    end
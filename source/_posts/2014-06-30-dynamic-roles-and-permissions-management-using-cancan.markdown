---
layout: post
title: "如何動態管理權限-使用cancan"
date: 2014-06-30 15:27:55 +0800
comments: true
categories: ["Ruby_on_Rails","cancan"] 
keywords: "Ruby on Rails, cancan, dynamic, permission, roles, 權限, 動態"
description: "Dynamic roles and permissions using cancan"
---

這篇是參考自[Dynamic roles and permissions using cancan](http://blog.joshsoftware.com/2012/10/23/dynamic-roles-and-permissions-using-cancan/)

大概分成幾個流程：

0. 建立Gemfile
1. 建立需要的Model
2. 寫rake爬controller的action(懶惰專用，不想要資料庫一個一個建權限)
3. 設定Ability => 這邊是關鍵，他會去抓user的role底下的權限
4. 設定Controller => 用來擋權限,設定權限
5. 設定route
6. 建立View



# 前言

網站後台往往可能有多個員工進去作業，但是有些功能並不希望開放給低層級的員工使用，

所以後台也需要做權限管理～

但是人員進進出出，陞遷、轉職相對應的職務也會調整，總不能每次都要去改hard code吧～～

所以才有動態權限設定的需求！

# Step 1. Gemfile

因為我們要使用Railscast網站開發者兼Boss Ryanb寫的[cancan](https://github.com/ryanb/cancan)，提供權限管理的服務

**[手做]** 所以，要在Gemfile寫入

    gem 'cancan'

**[手做]** 在terminal執行

    bundle install

<!-- more -->

# Step 2. 建立Model 

由於後台的管理員，

在建立model之前，先來看一下Model的架構，

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/%28Blog%E4%BD%BF%E7%94%A8%29%E5%8B%95%E6%85%8B%E6%AC%8A%E9%99%90%E7%AE%A1%E7%90%86%20%E8%B3%87%E6%96%99%E5%BA%AB%E8%A8%AD%E8%A8%88.jpg" alt="cancan dynamic database design">

讓我們開始動手吧

### Step 2-1. 建立Model: Role 

Role 的資料表要有：

    # == Schema Information
    #
    # Table name: roles
    #
    #  id         :integer          not null, primary key
    #  name       :string(255)
    #  created_at :datetime
    #  updated_at :datetime
    #

**[手做]** 在terminal 

    rails g model role

**[手做]** 在檔案db/migrate/時間戳記_create_roles.rb

    class CreateRoles < ActiveRecord::Migration
      def change
        create_table :roles do |t|
          t.string :name
          t.timestamps
        end
      end
    end

**[手做]** 在檔案app/models/role.rb

    class Role < ActiveRecord::Base
      has_many :admin_users         
      has_many :role_permissionships
      has_many :permissions , :through => :role_permissionships
    
      def set_permissions(permissions)
        permissions.each do |id|
          permission = Permission.find(id)
          self.permissions << permission
        end
      end
    
    end

其中set_permissions就是設定這個role底下的權限

### Step 2-2. 建立Model: Permission 

Permission 的資料表要有：

    # == Schema Information
    #
    # Table name: permissions
    #
    #  id            :integer          not null, primary key
    #  name          :string(255)
    #  subject_class :string(255)
    #  action        :string(255)
    #  created_at    :datetime
    #  updated_at    :datetime
    #

**[手做]** 在terminal 

    rails g model permission

**[手做]** 在檔案db/migrate/時間戳記_create_permissions.rb

    class CreatePermissions < ActiveRecord::Migration
      def change
        create_table :permissions do |t|
          t.string :name
          t.string :subject_class
          t.string :action
          t.timestamps
        end
      end
    end


**[手做]** 在檔案app/models/permission.rb

ps. 其實，permision好像不需要知道role有哪些，不過我還是保留這個關聯

    class Permission < ActiveRecord::Base
      has_many :role_permissionships
      has_many :roles , :through => :role_permissionships
    end

### Step 2-3. 建立Model: Role Permissionship

主要是想要連結Role和Permission

RolePermissionship 的資料表要有：

    # == Schema Information
    #
    # Table name: role_permissionships
    #
    #  id            :integer          not null, primary key
    #  role_id       :integer
    #  permission_id :integer
    #  created_at    :datetime
    #  updated_at    :datetime
    #

**[手做]** 在terminal 

    rails g model role_permissionship

**[手做]** 在檔案db/migrate/時間戳記_create_role_permissionships.rb

    class CreateRolePermissionships < ActiveRecord::Migration
      def change
        create_table :role_permissionships do |t|
          t.belongs_to :role
          t.belongs_to :permission
          t.timestamps
        end
      end
    end



**[手做]** 在檔案app/models/role_permissionship.rb

    class RolePermissionship < ActiveRecord::Base
      belongs_to :role
      belongs_to :permission
    end
  
### Step 2-4. 補上role_id: AdminUser

Adminuser資料表要有：

    # == Schema Information
    #
    # Table name: admin_users
    #
    #  id                     :integer          not null, primary key
    #  email                  :string(255)      default(""), not null
    #  encrypted_password     :string(255)      default(""), not null
    #  reset_password_token   :string(255)
    #  reset_password_sent_at :datetime
    #  remember_created_at    :datetime
    #  sign_in_count          :integer          default(0)
    #  current_sign_in_at     :datetime
    #  last_sign_in_at        :datetime
    #  current_sign_in_ip     :string(255)
    #  last_sign_in_ip        :string(255)
    #  old_data               :text
    #  created_at             :datetime
    #  updated_at             :datetime
    #  role_id                :integer
    #

ps. 這是本來的admin_user (透過devise建立的)，這邊我就跳過了，主要是要加入**role_id**

**[手做]** 在terminal 

    rails g migration add_role_id_to_admin_user

**[手做]** 在檔案db/migrate/時間戳記_add_role_id_to_admin_user.rb

    class AddRoleIdToAdminUser < ActiveRecord::Migration
      def change
        add_column :admin_users, :role_id , :integer
      end
    end


**[手做]** 在檔案app/models/admin_user.rb

    class AdminUser < ActiveRecord::Base
      devise :database_authenticatable, :rememberable, :trackable, :validatable,
             :recoverable
      serialize :old_data, Hash
      belongs_to :role
    
      def super_admin?
        self.role.name == "Super Admin"
      end
    end
  
# Step 3 寫rake 去爬 所有controller資料

原始程式可參考：[Dynamic roles and permissions using cancan](http://blog.joshsoftware.com/2012/10/23/dynamic-roles-and-permissions-using-cancan/)

**[手做]** 新增檔案permissions.rake在 lib/tasks/底下


**[手做]** 在檔案lib/tasks/permissions.rake

簡單來說，就是去爬controllers/admin底下的controller的所有action然後把它建立到permission 資料表

    namespace 'permissions' do 
    
      desc "Loading all models and their related controller methods inpermissions table."
      task(:permissions => :environment) do 
        arr = []
        # Load all the admin controllers
        controllers = Dir.new("#{Rails.root}/app/controllers/admin").entries
        controllers.each do |entry|
          if entry =~ /_controller/
            arr << "Admin::#{entry.camelize.gsub('.rb','')}".constantize #namescoped controllers
          end
        end
    
        arr.each do |controller|
          # only that controller which represents a model
          if controller.permission
            # create a universal permission for that model. eg: "manage User" will allow all actions on User model.
            write_permission(controller.permission,"manage","manage") # add permission to do CRUD for every model.
            controller.action_methods.each do |method|
              if method =~ /^([A-Za-z\d*]+)+([\w]*)+([A-Za-z\d*]+)$/ #add_user , add_user_info, Add_user, add_User
                name, cancan_action = eval_cancan_action(method)
                write_permission(controller.permission,cancan_action,name)
              end
            end
          end
        end
      end
    end
    
    # this method returns the cancan action for the action passed.
    def eval_cancan_action(action)
      case action.to_s
      when "index"
        name = 'list'
        cancan_action = "index" #let the cancan action be the actual method name
        action_desc = I18n.t :list
      when "new", "create"
        name = 'create and update'
        cancan_action = "create"
        action_desc = I18n.t :create
      when "show"
        name = "view"
        cancan_action = "view"
        action_desc = I18n.t :view
      when "edit","update"
        name = "create and update"
        cancan_action = "update"
        action_desc = I18n.t :update
      when "delete", "destroy"
        name = 'delete'
        cancan_action = 'destroy'
        action_desc = I18n.t :destroy
      else
        name = action.to_s
        cancan_action = action.to_s
        action_desc = "Other: " < cancan_action
      end
      return name, cancan_action 
    end
    
    # check if the permission is present else add a new one.
    def write_permission(model, cancan_action, name)
      permission = Permission.find(:first, :conditions => ["subject_class = ? and action = ? ", model, cancan_action])
      unless permission
        permission = Permission.new
        permission.name = name
        permission.subject_class = model
        permission.action = cancan_action
        permission.save    
      end
    end
  
**[手做]** 在terminal 

    rake -T #查看所有可執行的rake
    rake permissions:permissions #做剛剛那個rake file的事
  


# Step 4. 設定Ability

**[手做]** 在terminal 

    rails g cancan:ability

**[手做]** 在檔案app/models/ability.rb

    class Ability
      include CanCan::Ability
    
      def initialize(user)
        user.role.permissions.each do |permission|
            if permission.subject_class == 'all'
                can permission.action.to_sym, permission.subject_class.to_sym
            else
                can permission.action.to_sym, permission.subject_class.constantize
            end
        end
      end
    end

**這邊就是關鍵**

他會動態去load使用者，然後看他權限

    user.role.permissions.each do |permission|
          if permission.subject_class == 'all'
              can permission.action.to_sym, permission.subject_class.to_sym
          else
              can permission.action.to_sym, permission.subject_class.constantize
          end
      end


# Step 5. 建立管理者、員工並給權限

**[手做]** 在檔案db/seeds.rb

    # the highest role with all the permissions.
    Role.create!(:name => "Super Admin")
    
    # other role
    Role.create!(:name => "Staff")
    
    #create universal permission
    Permission.create!(:subject_class => "all", :action => "manage")
    
    #assign super admin the permission to manage all the models and controllers
    role = Role.find_by_name('Super Admin')
    role.permissions << Permission.find_by(:subject_class => 'all', :action => "manage")
    
    user = AdminUser.new(email: 'aloha@aloha.aloha', password: '12345678')
    user.role = role
    user.save
    
    AdminUser.create(email: 'staff@staff.staff', password: '12345678', :role_id => Role.find_by_name('Staff').id)

**[手做]** 在terminal 

    rake db:seed


所以等一下你可以使用aloha@aloha.aloha登入最高權限，使用staff@staff.staff登入測試


# Step 6. 設定Controller 

因為我是希望後台有權限管理，所以這邊我是使用admin_controller

**[手做]** 在檔案app/controllers/admin_controller.rb

    class AdminController < ApplicationController
      rescue_from CanCan::AccessDenied do |exception|
        flash[:alert] = "存取失敗，你沒有權限做這個動作"
        redirect_to admin_root_path 
      end
      # 下面不做的話，會有CanCan ActiveModel::ForbiddenAttributesError 的問題
      # As load_resource will only load if resource is not there. 
      # 下面那個步驟就是要用，就是這邊resource_params 貌似要使用 send(params.require(:role).permit(:name)) 才會work
      # def build_resource
      #       resource = resource_base.new(resource_params || {})
      #         .....
      # end
      before_filter do
        resource = controller_path.singularize.gsub('admin/', '').to_sym
        method = "#{resource}_params"
        params[resource] &&= send(method) if respond_to?(method, true)
      end
      before_action :authenticate_admin_user!
      load_and_authorize_resource
      before_filter :load_permissions # call this after load_and_authorize else it gives a cancan error.
      layout 'admin'
    
      protected
    
      # Derive the model name from the controller. EX: UsersController will return User
      def self.permission
        return name = self.name.gsub('Controller','').singularize.split('::').last.constantize.name rescue nil
      end
    
      def current_ability
        @current_ability ||= Ability.new(current_admin_user)
      end
    
      # load the permissions for the current admin user so that UI can be manipulated.
      def load_permissions 
        @current_permissions = current_admin_user.role.permissions.collect{|i| [i.subject_class, i.action]}
      end
    
    end

如果需要在後台可以編輯的話，我們當然需要role controller

**[手做]** 在檔案app/controllers/admin/roles_controller.rb

    class Admin::RolesController < AdminController
     
      #only user with super admin role can access
      before_filter :is_super_admin?
     
      def index
        #you dont want to set the permissions for Super Admin.
        @roles = Role.all.keep_if{|i| i.name != "Super Admin"}
      end
     
      def show
        @role = Role.find(params[:id])
        @permissions = @role.permissions
      end
     
      def edit
        @role = Role.find(params[:id])
        @permissions = Permission.all
        @role_permissions = @role.permissions.collect{|p| p.id}
      end
     
      def update
        @role = Role.find(params[:id])
        @role.permissions = []
        @role.set_permissions(params[:permissions]) if params[:permissions]
        if @role.save
          redirect_to admin_roles_path and return
        end
        @permissions = Permission.all
        render 'edit'
      end
     
      def new
        @role = Role.new
      end
    
      def create
        @role = Role.new(permitted_params.role)
        if @role.save
          redirect_to admin_roles_path, flash: { notice: "成功建立角色#{@role.name}" }
        else
          render :new
        end
      end
    
      def role_params
        params.require(:role).permit(:name)
      end
     
      private
     
      def is_super_admin?
        redirect_to admin_root_path and return unless current_admin_user.super_admin?
      end
    end


# Step 7. 建立routes

**[手做]** config/routes.rb

在admin裏面新增

     namespace :admin do
      ...
      resources :roles
      ...
     end

# Step 8. 建立View

首先，當然是要new，但是這邊我很單純，我就是讓他先建立角色，之後再編輯權限

所以"建立"的地方很簡單

**[手做]** app/views/admin/roles/new.html.slim

    = simple_form_for [:admin, @role], wrapper: :admin, html: { class: 'form-horizontal' } do |f|
      = f.input :name, label: '角色名稱'
      .form-actions
        = f.submit '送出', disabled_with: '送出中', class: 'btn btn-primary'

**[手做]** app/views/admin/roles/edit.html.slim

"編輯"的部分，可以用打勾的方式選取權限

    .span12
      = form_for @role , :url => admin_role_path, :method => :put do |f|
        .fieldset
          legend 
            | Role： 
            = @role.name
          br 權限管理
          br
          table.table.table-bordered.table-striped.table-hover
            thead 
              tr 
                th Class
                th Action
                th 是否有權限
                - @permissions.each do |permission|
                  tr 
                    td= permission.subject_class
                    td= permission.action
                    td= check_box_tag 'permissions[]', permission.id, @role_permissions.include?(permission.id), {array: true, class: "check_box"}
          .span16.offset2
            .clearfix
              = f.submit "更新", :class => 'btn btn-primary'
              = link_to '取消', admin_roles_path  

大概會像這樣

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Role_edit_sample.png" alt="cancan dynamic database design">

**[手做]** app/views/admin/roles/index.html.slim


    h1 角色清單
    - content_for :btns do
      = link_to '新增角色', new_admin_role_path, class: 'btn btn-primary'
    table.table.table-bordered.table-striped.table-hover
      thead
        tr
          th Name
          th
          th
      tbody
        - @roles.each do |role|
          tr
            td= role.name
            td= link_to 'Show', admin_role_path(role)
            td= link_to 'Edit', edit_admin_role_path(role)
    br
  
大概會像這樣

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Role_index_sample.png" alt="cancan dynamic database design">

ps 若是你像我一樣，有一個後台的管理頁面

你可能需要加上，在你的menu裏面

    li
      = link_to "權限管理", admin_roles_path


以上！大功告成

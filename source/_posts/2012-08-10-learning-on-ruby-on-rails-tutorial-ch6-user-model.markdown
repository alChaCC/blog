---
layout: post
title: "Learning on Ruby on Rails Tutorial-CH6 User model"
date: 2012-08-10 10:59
comments: true
categories: [ "Reading" , "Ruby on Rails"] 
---

Sorry 最近有點忙碌 一口氣補完全部好了～

當然一開始

我們來開一個Branch吧

	git checkout -b modeling-users
	
讓我們來gen出user model吧

	rails generate model User name:string email:string
	
耶～ 建出了db/migrate/[時間註記]_create_users.rb

<!--more--> 

長這樣

	class CreateUsers < ActiveRecord::Migration
	  def change
	    create_table :users do |t|
	      t.string :name
	      t.string :email
	
	      t.timestamps
	    end
	  end
	end

其中migration本身有change這個方法，決定資料庫的改變！

而這個change方法，又呼叫了create_table 建立資料表再資料庫內

之後，我們就可以執行

	 bundle exec rake db:migrate
	 
如果要rollback的話執行

	bundle exec rake db:rollback

接下來我們要改Gemfile新增 

	gem 'annotate', '~> 2.4.1.beta'
	
在
group :development, :test do

end
裡面放

之後別忘了

	bundle install 

這樣我們就可以看資料庫的變化

	bundle exec annotate --position before

於是乎在app/models/user.rb 就出現了

	# == Schema Information
	#
	# Table name: users
	#
	#  id         :integer         not null, primary key
	#  name       :string(255)
	#  email      :string(255)
	#  created_at :datetime        not null
	#  updated_at :datetime        not null
	#
	
	class User < ActiveRecord::Base
	   attr_accessible :name, :email
	end

之後 你想要看資料庫最新狀況都可以再輸入一次

讓我們來重新看app/models/user.rb

using attr_accessible is important for preventing a mass assignment vulnerability, a distressingly common and often serious security hole in many Rails applications.

所以這很重要！

接著我們來看Model上的操作

先來開個console來

	rails console --sandbox

##增

新增

	User.new
	＃When called with no arguments, User.new returns an object with all nil attributes.

	user = User.new(name: "Michael Hartl", email: "mhartl@example.com")
	
儲存

	user.save


更方便的新增


	User.create(name: "A Nother", email: "another@example.org")

##刪
	
刪除

	foo.destroy
	

##修
	
	user
	user.email = "mhartl@example.net"
	user.save	
	
使用reload回到先前未儲存狀況

	user.email
	user.email = "foo@bar.com"
	user.reload.email
	
使用update_attributes修改

	user.update_attributes(name: "The Dude", email: "dude@abides.org") 
	
	
##查
	
找尋 - by ID

	User.find(1)
	
找尋 - by XXX 

這個方法是從Active Recoed內建的東西(depend on 你的table)

	User.find_by_email("mhartl@example.com")
	
找尋 - 找第一個

	User.first
	
	
找尋 - 找所有

	User.all


某筆資料的看詳細資訊

	user.name
	
	user.email
	
	user.updated_at


##使用者驗證

OK~~讓我們來開始測試驅動開發八～

我們剛剛在gen user時，因為我們沒有帶--no-test-framework

所以她有自動幫我們建了測試的code在

/spec/models/user_spec.rb

如果你執行

	bundle exec rspec spec/models/user_spec.rb 
	
會得到pending的結果

因為它裡頭寫了

	pending "add some examples to (or delete) #{__FILE__}"
	
OK~

那我們來改寫吧
	
	require 'spec_helper'
	
	describe User do
	
	  before { @user = User.new(name: "Example User", email: "user@example.com") }
	
	  subject { @user }
	
	  it { should respond_to(:name) }
	  it { should respond_to(:email) }
	end
	

首先那個before就是在做測試之前我們會先create一個instace varibale @user

並透過subject{@user} 定義@user為default的test的subject

然後那個respond_to(:name)

代表的是裡頭是否有這個屬性！

(Recall from Section 4.2.3 that Ruby uses a question mark to indicate such true/false boolean methods.) The tests themselves rely on the boolean convention used by RSpec: the code

	@user.respond_to?(:name)

can be tested using the RSpec code

	@user.should respond_to(:name)

Because of subject { @user }, we can leave off @user in the test, yielding

	it { should respond_to(:name) }


這時候～我就高興的執行了

	bundle exec rspec spec/
	
但是....囧  怎麼有錯～


原來是因為 即使我們用**rake db:migrate**建立開發用的資料庫，但是測試時，測試資料庫並不會知道資料的模型(事實上，根本還不存在)

所以我們要建立正確結構的test db，讓測試通過，我們必須使用**db:test:prepare**

所以

	 bundle exec rake db:test:prepare
	 
然後在執行

	bundle exec rspec spec/
	
過了耶！！


###驗證資料是否有存在

當然要來寫一下測試拉！ 加上下面那些


	 it { should be_valid }
	
	  describe "when name is not present" do
	    before { @user.name = " " }
	    it { should_not be_valid }
	  end

為甚麼可以寫成should be_valid

原因是一個物件若有定應到boolean的方法例如foo?的話

就會自動對應到測試方法"be_foo"

所以be_valid就是從

@user.valid？來的

然後變成

	@user.should be_valid

因為我們有用subject所以…可以改寫成

	it { should be_valid }

也完驗證～在來寫validates吧～

只要在**app/models/user.rb**加入

	validates :name, presence: true

看起來很酷～但是事實上就是使用一個function
就像下面那樣

	class User < ActiveRecord::Base 
	  attr_accessible(:name, :email)
	
	  validates(:name, presence: true)
	end
	
ＯＫ～pass了！

之後我們再補上下面的東東到**spec/models/user_spec.rb**

	describe "when email is not present" do
	    before { @user.email = " " }
	    it { should_not be_valid }
	  end
	  
還有在 **app/models/user.rb
**

加上

	validates :email, presence: true
	
	
### 驗證資料長度是否有存在

先來寫名字長度驗證的測試**spec/models/user_spec.rb**

	describe "when name is too long" do
	    before { @user.name = "a" * 51 }
	    it { should_not be_valid }
	  end
	 
在補寫程式

	 validates :name, presence: true , length: { maximum: 50}
	 

### 驗證資料格式是否有正確

先寫測試

	 describe "when email format is invalid" do
	    it "should be invalid" do
	      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
	      addresses.each do |invalid_address|
	        @user.email = invalid_address
	        @user.should_not be_valid
	      end      
	    end
	  end
	
	  describe "when email format is valid" do
	    it "should be valid" do
	      addresses = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]
	      addresses.each do |valid_address|
	        @user.email = valid_address
	        @user.should be_valid
	      end      
	    end

那個%w[] 可以做字串的array

再來寫 比對的正則表示式


	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  	
 全部的意思是：
 
	 Expression	Meaning
full regex

	/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i	
	
start of regex
	
	/										
match start of a string
	
	\A										
	
at least one word character, plus, hyphen, or dot

	[\w+\-.]+	
	
literal “at sign”

	@	
	
at least one letter, digit, hyphen, or dot

	[a-z\d\-.]+	

literal dot

	\.	

at least one letter

	[a-z]+	

match end of a string

	\z	

end of regex

	/	
	
case insensitive
	
	i	


如果不知道怎麼寫 可以參考

http://www.rubular.com/


  
### 驗證獨特性

 A test for the rejection of duplicate email addresses. 
**spec/models/user_spec.rb**

新增

	describe "when email address is already taken" do
           before do
             user_with_same_email = @user.dup
             user_with_same_email.save
           end
           it { should_not be_valid }
        end
        
 然後**app/models/user.rb**
 
 加上
 
 	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true


但是我們尚未完成！

因為....如果email只有在大小寫上有所不同 這樣就會有問題

先寫test case

	describe "when email address is already taken" do
           before do
             user_with_same_email = @user.dup
             user_with_same_email.save
           end
           it { should_not be_valid }
        end

好佳在～ :uniqueness accepts an option, :case_sensitive, for just this purpose



所以我們可加上

	uniqueness: { case_sensitive: false }
  

但是.....實際上…這個uniqueness並不是完成 可以達成獨特性的驗證

詳細為啥請看網站舉例


we just need to enforce uniqueness at the database level as well. Our method is to create a database index on the email column, and then require that the index be unique.

所以我們來加上一些index來確保這個問題不會發生


	 rails generate migration add_index_to_users_email
	 
加上一句話
	
	class AddIndexToUsersEmail < ActiveRecord::Migration
	  def change
	    add_index :users, :email, unique: true
	  end
	end

他會加上一個index在users資料表的email欄位上

別忘了執行

	bundle exec rake db:migrate
	
最後還有一個特別的地方就是

在儲存email之前 必須把它全部轉成小寫！

原因是

The reason is that not all database adapters use case-sensitive indices.

所以我們可以使用一個callback的方法，which is a method that gets invoked at a particular point in the lifetime of an Active Record object 

在**app/models/user.rb**加上

	before_save { |user| user.email = email.downcase }



## 增加密碼的保密

加密的密碼！

為了要讓密碼加密，我們會使用state-of-the-art hash 函式，又稱作bcrypt,他會將密碼不可逆做雜湊加密

所以加上下面到**Gemfile**

	gem 'bcrypt-ruby', '3.0.1'
	
寫測試！我們要確保User物件有**encrypted_password**這個欄位

**spec/models/user_spec.rb**

	#在it { should respond_to(:name) }和it { should respond_to(:email) }底下加上
	  it { should respond_to(:password_digest) }


要通過測試，我們必須要加資料庫東西了！

	＄rails generate migration add_password_digest_to_users password_digest:string
	
	#加完別忘了
	$ bundle exec rake db:migrate
	$ bundle exec rake db:test:prepare
	
	#還有測試
	$ bundle exec rspec spec/
	

### 密碼與確認

要讓使用者確認密碼，所以必需要在User這邊，加上兩個屬性！password和password_confirmation

一樣先加到測試裡面！**spec/models/user_spec.rb**

	 it { should respond_to(:password) }
  	 it { should respond_to(:password_confirmation) }
 
 因為加了上面兩行！所以..... before do這個block要加點東西
 
 	before do
    @user = User.new(name: "Example User", email: "user@example.com", 
                     password: "foobar", password_confirmation: "foobar")
  	end
  	
 
另外，也不希望使用者輸入空的密碼，所以測試再加上

	describe "when password is not present" do
	  before { @user.password = @user.password_confirmation = " " }
	  it { should_not be_valid }
	end

也不希望使用者沒有輸入confirmation

	describe "when password confirmation is nil" do
	  before { @user.password_confirmation = nil }
	  it { should_not be_valid }
	end

不希望使用者密碼太短(實作寫在下面)

	describe "with a password that's too short" do
	  before { @user.password = @user.password_confirmation = "a" * 5 }
	  it { should be_invalid }
	end


### 使用者認證機制

要認證的話，預計flow是這樣做

	user = User.find_by_email(email)
	current_user = user.authenticate(password)

那個authenticate是判斷使用者輸入的密碼，如果true的話就會return user不是的話，就會return false，所以User必須要用這個function，所以來寫測試吧**spec/models/user_spec.rb**

	#在前面加上這句
	it { should respond_to(:authenticate) }
	
	#在底下加上
	describe "return value of authenticate method" do
	  before { @user.save }
	  let(:found_user) { User.find_by_email(@user.email) }
	
	  describe "with valid password" do
	    it { should == found_user.authenticate(@user.password) }
	  end
	
	  describe "with invalid password" do
	    let(:user_for_invalid_password) { found_user.authenticate("invalid") }
	
	    it { should_not == user_for_invalid_password }
	    specify { user_for_invalid_password.should be_false }
	  end
	end


let 就是讓found_user 等同於 User.find_by_email(@user.email) 

specify就是it的代名詞(用在當it念起來怪怪的時候XD)

舉例來說：

it(別忘了就是@user) should not equal wrong user  => 順！

user: user with invalid password should be false => 怪....

所以才用specify

變成

“specify: user with invalid password should be false =>順！


### User has secure password

先看一下觀念

我們希望讓password和password_confirmation欄位變成accessible，讓我們可以實例化新的用戶一個初始雜湊

**網路上查的資訊**
attr_accessor :password

表示在user model中加入一個virtual attribute稱為password，virtual attribute的意思是password不對應於資料庫裡的欄位，只用在程式類似變數的角色。

attr_accessible :name, :email, :password, :password_confirmation
表示將password與password_confirmation加入到attr_accessible的list中，加到list中的變數意味著這個變數可以從外部去修改它，例如可以做一個頁面來重設password等。加到list的另一個好處是可以防止不當的hacker行為(mass assignment)。

所以我們在 **app/models/user.rb**需要這句

	attr_accessible :name, :email, :password, :password_confirmation

再來我們希望密碼不要太短(還記得上面～寫的測試媽)

	validates :password, length: { minimum: 6 }
	
**password_confirmation**要有

	validates :password_confirmation, presence: true

最後我們需要新加password和password_confirmation屬性，也需要加authenticate方法去比較加密的密碼是否和密碼一致，所以我們要整合到一個function裡面 就叫他為

	has_secure_password
	
他其實是Rails內建的funciton，請看下面

	module ActiveModel
	  module SecurePassword
	    extend ActiveSupport::Concern
	
	    module ClassMethods
	    	def has_secure_password
	        # Load bcrypt-ruby only when has_secure_password is used.
	        # This is to avoid ActiveModel (and by extension the entire framework) being dependent on a binary library.
	        gem 'bcrypt-ruby', '~> 3.0.0'
	        require 'bcrypt'
	
	        attr_reader :password
	
	        validates_confirmation_of :password
	        validates_presence_of     :password_digest
	
	        include InstanceMethodsOnActivation
	
	        if respond_to?(:attributes_protected_by_default)
	          def self.attributes_protected_by_default
	            super + ['password_digest']
	          end
	        end
	      end
	    end
	  
	  module InstanceMethodsOnActivation
      # Returns self if the password is correct, otherwise false.
      def authenticate(unencrypted_password)
        BCrypt::Password.new(password_digest) == unencrypted_password && self
      end

      # Encrypts the password into the password_digest attribute, only if the
      # new password is not blank.
      def password=(unencrypted_password)
        unless unencrypted_password.blank?
          @password = unencrypted_password
          self.password_digest = BCrypt::Password.create(unencrypted_password)
        			end
      			end
    		end
  		end
	end	    

傑克！這真的是太神奇了！！！！！

	$ git add .
	$ git commit -m "Make a basic User model (including secure passwords)"
	Then merge back into the master branch:
	
	$ git checkout master
	$ git merge modeling-users

＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝底下是之前版本的....你就知道為甚麼我說這太神奇了！！！＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
### 驗證密碼

首先我們先來寫測試程式

要先修改內容 ，把
	
	before { @user = User.new(name: "Example User", email: "user@example.com") }

改成這樣

	before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  	end

  	it "should create a new instance given valid attributes" do
    	User.create!(@attr)
  	end
  	
 然後後面加上
 
	 describe "password validations" do
	
	    it "should require a password" do
	      User.new(@attr.merge(:password => "", :password_confirmation => "")).
	        should_not be_valid
	    end
	
	    it "should require a matching password confirmation" do
	      User.new(@attr.merge(:password_confirmation => "invalid")).
	        should_not be_valid
	    end
	
	    it "should reject short passwords" do
	      short = "a" * 5
	      hash = @attr.merge(:password => short, :password_confirmation => short)
	      User.new(hash).should_not be_valid
	    end
	
	    it "should reject long passwords" do
	      long = "a" * 41
	      hash = @attr.merge(:password => long, :password_confirmation => long)
	      User.new(hash).should_not be_valid
	    end
	  end

OK寫好測試後，來讓我們的程式通過測試吧～

先到**app/models/user.rb**

	#改這些，這是因為流程上我們會接受密碼還有密碼的確認，所以我們必須加上這個
	attr_accessor :password
	attr_accessible :name, :email, :password, :password_confirmation
	 #還有下面那些，這個還會自動幫你產生虛擬的屬性"password_confirmation"
	validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }
  
現在讓我們計畫 使用encrypted_password這個屬性來儲存有加密的密碼

首先我們先用console來先試玩一下

	$rails console --sandbox 
	$ user = User.new
	$ user.respond_to?(:password)   =>你會得到true
	$ user.respond_to?(:encrypted_password)  =>你會得到False!
	
科科....

所以我們加個測試**spec/models/user_spec.rb**好了！確保程式會respond_to  “encrypted_password”

	describe "password encryption" do
	
	    before(:each) do
	      @user = User.create!(@attr)
	    end
	
	    it "should have an encrypted password attribute" do
	      @user.should respond_to(:encrypted_password)
	    end
	  end

上面我們會什麼不用User.new (其實用User.new也可以)，但是因為要設定加密的密碼，是必須在使用者資料寫到資料庫時，在做的動作，所以使用create! 還有把它放在 before(:each) 裡面可以確保所有的加密的密碼都會在這個describe區塊內work

所以要通過測試，我們必須要加資料庫東西了！

	＄rails generate migration add_password_to_users encrypted_password:string


改**db/migrate/<timestamp>_add_password_to_users.rb**

	class AddPasswordToUsers < ActiveRecord::Migration
	  def self.up
	    add_column :users, :encrypted_password, :string
	  end
	
	  def self.down
	    remove_column :users, :encrypted_password
	  end
	end


接下來，執行

	$bundle exec rake db:migrate
	$bundle exec rake db:test:prepare
	#rake db:test:prepare - 建立一個資料庫給測試環境使用(當新增或修改migrate檔案時，要重新下這個指令)
	
ＯＫ來跑測試吧

	$ bundle exec rspec spec/models/user_spec.rb -e "should have an encrypted password attribute"





接下來，我們還必須要加入測試，因為不希望再加入密碼時，是空的

所以先加入測試**spec/models/user_spec.rb**

在**describe "password encryption" do**這個block裡面

加入

	it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

為了讓測試可以通過，我們寫一個callback function叫做是**encrypt_password**用在before_save方法，他的工作就是加密

寫在**app/models/user.rb**

	private
    def encrypt_password
        self.encrypted_password = encrypt(password)
        #加個self是確保寫到User類別的self.encrypted_password
    end

    def encrypt(string)
        string # Only a temporary implementation!
    end
    
在Ruby類別內，**private**這個keyword之後的function，都只能用在本身的class內

## 機密的密碼

我們在**app/models/user.rb**加一個public 的方法，
has_password?，他的功能就是比對user輸入的密碼和資料庫的密碼是否一致，對於這個方法，我們可以寫一個測試for that，測試他會return 正確的true 或 false

請看測試程式，我們把它寫在describe "password encryption" do這個block 裡頭**spec/models/user_spec.rb**

	 describe "has_password? method" do
	
	      it "should be true if the passwords match" do
	        @user.has_password?(@attr[:password]).should be_true
	      end    
	
	      it "should be false if the passwords don't match" do
	        @user.has_password?("invalid").should be_false
	      end 
	    end

在寫程式之前，我們來看下console

	$rails console
	>> require 'digest'
	>> def secure_hash(string)
	>>   Digest::SHA2.hexdigest(string)
	>> end
	>> require 'digest'
	=> false
	>> def secure_hash(string)
	>>   Digest::SHA2.hexdigest(string)
	>> end
	=> nil
	>> password = "secret"
	=> "secret"
	>> encrypted_password = secure_hash(password)
	=> "2bb80d537b1da3e38bd30361aa855686bde0eacd7162fef6a25fe97bf527a25b"
	>> submitted_password = "secret"
	=> "secret"
	>> encrypted_password == secure_hash(submitted_password)
	=> true
	
我們使用Ruby的digest library的SHA2來作加密，但是如果攻擊者去try密碼，可能會給他猜到密碼，所以為了讓密碼更加保密，我們會使用salt這個方法，最簡單的方法就是把現在的時間加到密碼內，所以只有當使用者在同一時間製作同一密碼，才有可能得到一樣的加密

我們一樣在console試試

	Time.now.utc
	 => 2012-05-06 09:45:08 UTC 
	  salt = secure_hash("#{Time.now.utc}--#{password}")
	 => "1c63c82c6d9795c3c81762082392df1f238bb929d7fefaab4ea14779ec71e15a" 
	 
	 encrypted_password =secure_hash("#{salt}--#{password}")
	 => "2ffa2d908d96bd8b94b53d5a8ee1e3632fc1d16dbd0cdb05860c1b053759b631" 
	 
為了要記錄salt我們必須在資料表上增加一個欄位

	 $ rails generate migration add_salt_to_users salt:string

編輯**db/migrate/<timestamp>_add_salt_to_users.rb**

	  def self.up
	    add_column :users, :salt, :string
	  end
	
	  def self.down
	    remove_column :users, :salt
	  end

執行

	$ bundle exec rake db:migrate
	$ bundle exec rake db:test:prepare
	
再來寫**app/models/user.rb**吧

	require 'digest'
	class User < ActiveRecord::Base
	  .
	  .
	  .
	  before_save :encrypt_password
	
	  def has_password?(submitted_password)
	    encrypted_password == encrypt(submitted_password)
	  end
	
	  private
	
	    def encrypt_password
	      self.salt = make_salt unless has_password?(password)
	      self.encrypted_password = encrypt(password)
	    end
	
	    def encrypt(string)
	      secure_hash("#{salt}--#{string}")
	    end
	
	    def make_salt
	      secure_hash("#{Time.now.utc}--#{password}")
	    end
	
	    def secure_hash(string)
	      Digest::SHA2.hexdigest(string)
	    end
	end
	
OK~來執行測試程式吧

	$ bundle exec rspec spec/models/user_spec.rb  -e "should be false if the passwords don't match"
	
	$  bundle exec rspec spec/models/user_spec.rb -e "should be true if the passwords match"
	
	＃當然你也可以run所有在某個**describe**裡面的examples
	＃但是別忘了加上跳脫字元
	
	$ bundle exec rspec spec/models/user_spec.rb -e "has_password\? method"
	
	
### 認證方法

對於每個使用者使用**has_password?** 看起來還不錯，但是它本身並不是那個有用，在第九章，當使用者登入時，會使用"**authenticate**"這個方法

我們希望可以有一個方法，會return 登入使用者密碼是否正確，希望可以用一個**類別方法**，像這樣

	User.authenticate(email, submitted_password)

希望有這個方法的話，我們先來寫測試吧～～

在**spec/models/user_spec.rb** 寫在 describe "password encryption" do這個block裡面


	 describe "authenticate method" do
	
	      it "should return nil on email/password mismatch" do
	        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
	        wrong_password_user.should be_nil
	      end
	
	      it "should return nil for an email address with no user" do
	        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
	        nonexistent_user.should be_nil
	      end
	
	      it "should return the user on email/password match" do
	        matching_user = User.authenticate(@attr[:email], @attr[:password])
	        matching_user.should == @user
	      end
	    end
 
要如何寫一個類別方法呢？(類別方法就是直接透過類別名稱呼叫到的函式，不用說一定要new出來，或是找到物件之類的)

很簡單....請參考 寫在**app/models/user.rb**

	def self.authenticate(email, submitted_password)
	    user = find_by_email(email)
	    return nil  if user.nil?
	    return user if user.has_password?(submitted_password)
	end



這樣，我們就來改一下

**spec/controllers/users_controller_spec.rb**

新增在describe UsersController do這個block底下
	
	describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
     end
    end

幾個問題
 assigns(:user) 是啥！？
 
就文章指出，這是RSpec的Function
The assigns method takes in a symbol argument and returns the value of the corresponding instance variable in the controller action 

所以assigns(:user)這句話，會return **@user**

接下來，有一個issue，就是要不要用RSpec的stub方法，(Stub回傳設定好的回傳值)

	before(:each)
	    @user = Factory(:user)
	    User.stub!(:find, @user.id).and_return(@user)
	  end
	
這個程式確保任何呼叫User.find(用id找） 找到之後會return @user，Many Rails programmers, especially RSpec users, prefer this stubbing approach because it separates the controller tests from the model layer.

Figuring out exactly when to stub things out is difficult, and message expectations are incredibly subtle and error-prone (see, e.g., Box 8.1 in the Rails 2.3 Tutorial book). To the common objection, “But now the controller tests hit the test database!”, I now find myself saying: “So what?” In my experience it has never mattered. I see no compelling reason not to hit the model layer in the controller tests, especially when it leads to much simpler tests. If you are interested in learning stubbing and message expectation techniques, I recommend reading the Ruby on Rails 2.3 Tutorial book. Otherwise, I suggest not worrying about enforcing a full separation of the model and controller layers in Rails tests. Although the controller tests in the rest of this book will hit the test database, at a conceptual level it will always be clear which part of MVC is being tested.

By the way, in principle the tests should run faster when the controllers don’t hit the database, and for the full Rails Tutorial sample application test suite they do—by around two-tenths of a second.

總之就是本來考量會cover到其他的測試，作者是認為so what ?

再來繼續看其他issue，

get :show 和 get 'show'

其實這兩個做的是同一件事情 ，只不過用get :show 看起來比較爽，另外，get :show, :id => @user 其實就等於 get :show, :id => @user.id

因為Rails會自動轉換物件去對應@id

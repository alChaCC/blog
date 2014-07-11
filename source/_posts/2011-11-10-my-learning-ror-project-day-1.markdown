---
layout: post
title: "我的RoR學習專案-Day 1"
date: 2011-11-10 01:13
comments: true
categories: Ruby_on_Rails
---

*建立可以連到各個頁面的首頁*

	{% codeblock lang:ruby %}
	rails g controller welcomes
	{% endcodeblock %}	

*在config/routes.rb把＃號拿掉變成root :to => "welcomes#index"*

<!--more--> 

*在controllers/welcomes_controller.rb加上*
	
	{% codeblock lang:ruby %}	
	def index
  	end
	{% endcodeblock %}

*移除public/index.html*

*在app/views/welcomes新建index.html.erb*

*在config/route.rb，把＃拿掉並改成 

	{% codeblock lang:ruby %}
	resources :welcomes *
	{% endcodeblock %}

*建立about me controller頁面*

	{% codeblock lang:ruby %}	
	rails g controller aboutmes
	{% endcodeblock %}

在config/route.rb加上

	{% codeblock lang:ruby %}
	resources :aboutmes
	{% endcodeblock %}

在app/view/welcomes/index.html.erb加上 

	{% codeblock lang:ruby %}
	<%= link_to "About Me" , aboutmes_path %>
	{% endcodeblock %}

在app/view/aboutmes新增index.html.erb

*建立blog controller 頁面*

	{% codeblock lang:ruby %}
	rails g controller blogs
	{% endcodeblock %}

*在config/route.rb加上*

	{% codeblock lang:ruby %}
	resources :blogs
	{% endcodeblock %}
	
**開始建立論壇專案**

建立model
	{% codeblock lang:ruby %}
	rails g model Forum
	rails g model Post
	{% endcodeblock %}

智障的我 沒有加入欄位資訊...等，所以必須使用migrate這個功能去新增欄位，先加forums好了	

	{% codeblock lang:ruby %}
	rails g migration add_basic_column_to_forums
	{% endcodeblock %}

修改db/migrate/20110831030156_add_basic_column_to_forums.rb，論壇的table要有哪些？論壇分類名稱,管理者,論壇簡介,文章數，注意～self.down是反向的

	{% codeblock lang:ruby %}
	def self.up
    		add_column("forums" , "forum_name"       , :string , {:null=>false, :limit=>100} )
    		add_column("forums" , "admin_forum_user" , :string , {:limit => 25})
    		add_column("forums" , "description"      , :string )
    		add_column("forums" , "post_num"         , :integer)
    		add_index("forums"  , "forum_name")
  	end
  	def self.down
    		remove_index("forums"  , "forum_name")
    		remove_column("forums","post_num")
    		remove_column("forums","description")
    		remove_column("forums","admin_forum_user")
    		remove_column("forums","forum_name") 
  	end
	{% endcodeblock %}


別忘記，做完資料表更改都要做migrate*

	{% codeblock lang:ruby %}
	rake db:migrate
	{% endcodeblock %}

那Post勒？

	{% codeblock lang:ruby %}
	def self.up
    		add_column("posts" , "post_title"       , :string , :limit => 100 , :null => false )
    		add_column("posts" , "poster_name"      , :string , :limit => 25  , :null => false )
    		add_column("posts" , "content"          , :text )
		=>這邊是因為內容我不希望是有字數限制的所以我的type選擇text
    		add_column("posts" , "position"         , :integer)
    		add_colume("posts" , "is_public"        , :boolean)
  	end

  	def self.down
    		remove_column("posts"   , "is_public")
    		remove_column("posts"   , "position")
    		remove_column("posts"   , "content")
    		remove_column("posts"   , "poster_name")
    		remove_column("posts"   , "post_title")
    
  	end
	{% endcodeblock %}

下指令

	{% codeblock lang:ruby %}
	rake db:migrate
	{% endcodeblock %}


囧.....剛剛打錯字，現在要怎麼辦？！

因為我migrate的次數不多所以我使用的是

	{% codeblock lang:ruby %}
	rake db:migrate VERSION=0
	{% endcodeblock %}

然後

	{% codeblock lang:ruby %}
	rake db:migrate
	{% endcodeblock %}

歐耶～～ 
	

開始來手刻crud吧(Create/Read/Update/Destroy)
	
 論壇必須由主頁面導引過去，管理論壇必須要有一個controller

	{% codeblock lang:ruby %}	
	rails g controller forums
	{% endcodeblock %}

	*別忘了加 resources :forums在config/routes.rb*

開始修改裡頭的檔案
	
因為需要ＣＲＵＤ所以要建立

	{% codeblock lang:ruby %}
	# show all forums
    	def index
    	end
    
    	# new a forum
    	def new
    	end
    
   	 # show this forum have what post
    	def show
    	end
    
    	# edit this forum's name , manager...etc 
    	def edit
    	end
    
    	# kill this forum
    	def destroy
    	end
	{% endcodeblock %}
    
因為要列出所有板名，所以要和資料庫要資料，因為rb檔都是一個class～那裡頭的資料呢？
所有的物件變數(@開頭)、類別變數(@@開頭)，都是封裝在類別內部的，類別外無法存取,
Forum是一個類別，繼承ActiveRecord這個類別就是專門操作資料庫的，
所以他有一個已經內建的方法譬如all就是列出全部資料，所以我們就使用這個，他回去得到是一個陣列

	{% codeblock lang:ruby %}
	def index
		@forums = Forum.all
	end 
	{% endcodeblock %}

再來如果要新增版名勒？當然就是要用繼承於ActiveRecord這個類別內建的方法new       

	{% codeblock lang:ruby %}
	def new
		@forum = Forum.new 
	end
	{% endcodeblock %}
	
不過,既然要新增～那應該要有表格之類的東西～讓我輸入新增資料吧～

是低～沒錯～所以我們必須讓view出來啦！！！

到app/views/forums裡頭新增一個new.html.erb吧

不過....這三小。 請參考[ihower的解釋](http://ihower.tw/rails3/actionview.html)



這時候你可以使用他們ror內建的程式碼區塊建立表單請看～～

	{% codeblock lang:ruby %}
        <%= form_for @forum, :url => forums_path do |f| %>
    	<%= f.label :forum_name, "版名" %>
   	<%= f.text_field :forum_name %>
    
	<%= f.label :admin_forum_user, " 管理者 " %>
    	<%= f.text_field :admin_forum_user %>

   	 <%= f.label :description, "介紹" %>
    	<%= f.text_area :description %>
    
    	<%= f.submit "新增" %>
	<% end %>
	{% endcodeblock %}

這時候你一定跟我一樣想罵Ｘ...

這又是啥！？

先問一個問題～你有沒有無聊看過網頁的程式碼～ 幹！沒錯～網頁就是這樣寫出來的～

請問你要一個一個慢慢打嗎？！ 如果是的話...你....你....瘋的厲害！

請看這段說明[節錄]自ihower (http://ihower.tw/rails3/basic.html)

這個form_for的程式碼區塊(Code block)被用來建立HTML表單。在區塊中，你可以使用各種函式來建構表單。例如f.text_field :name建立出一個文字輸入框，並填入@event的name屬性資料。但這個表單只能基於這個Model有的屬性(在這個例子是name跟description)。Rails偏好使用form_for而不是讓你手寫表單HTML，這是因為程式碼可以更加簡潔，而且可以明確地連結在Model物件上。
form_for區塊也很聰明，New event的表單跟Edit event的表單，其中的送出網址跟按鈕文字會不同的(根據@event的不同，前者是新建的，後者是已經建立過的)。
如果你需要建立任意欄位的HTML表單，而不綁在某一個Model上，你可以使用form_tag函式。它也提供了建構表單的函式而不需要綁在Model實例上。
所以我們要用這個函式就對了啦～他是ActionView::Helpers::FromHelper裡頭的一個method

至於，為甚麼:url => forums_path 

請看http://ihower.tw/rails3/restful.html

url是form_for函數一個optinal的參數另外還有一個:html

看一下國外的說明：
The rightmost argument to form_for is an optional hash of options:

:url - The URL the form is submitted to. It takes the same fields you pass to url_for or link_to. In particular you may pass here a named route directly as well. Defaults to the current action.

:html - Optional HTML attributes for the form tag.

我個人的理解是你按下new這個動作時，你是需要到伺服器post 一個東西然後把他紀錄到資料庫裡頭，

對應到的是controller的create的動作，所以要使用forums_path，rail會自己判斷是index動作還是create動作。

當一個使用者點擊表單的Create按鈕時，瀏覽器就會送出資料到Controller的create Action


回到controller/forums吧～突然想到....我們的index動作沒有搭配到view~~

所以我們來建立app/views/events/index.html.erb

在Rails會讓Action裡的實例變數(也就是有@開頭的變數)通通傳到View樣板裡面可以使用。

	{% codeblock lang:ruby %}
	<ul>
		<% @forums.each do |forum| %>
  		<li>
 	 	<%= forum.forum_name %>
  		<%= forum.admin_forum_user%>
  		<%= forum.description%>
  		<%= forum.post_num%>
  		<%= link_to '進入', forum_path(forum) %>
  		<%= link_to '編輯', edit_forum_path(forum) %>
  		<%= button_to '刪除', forum_path(forum) , :method => :delete %>
  		</li>
		<% end %>
	</ul>
	<%= link_to '新增論壇分類', new_forum_path %>
	{% endcodeblock %}

參考自ihower - [Restful](http://ihower.tw/rails3/restful.html)
注意到刪除的地方，我們多一個參數:method => :delete。非GET的操作，顧及網頁親和力可以把link_to改成用button_to。

link_to如果瀏覽器的JavaScript沒開，就會無法送出GET之外的操作。button_to就無此困擾，因為Rails是產生form標籤夾帶_method參數。

建好了秀資料的view之後～我們在回到剛剛那個new表格～使用者按下 <%= f.submit "新增" %> 之後 表格的url設定是導到動作create所以我們來編輯/app/controllers/forums

	{% codeblock lang:ruby %}
	def create
      	  @forum = Forum.new(params[:forum])
      	  @forum.save
      	  redirect_to forums_url
    	end  
	{% endcodeblock %}

create Action會透過從表單傳進來的資料，也就是Rails提供的params參數(這是一個Hash)，來實例化一個新的@event物件。

成功儲存之後，便將使用者重導(redirect)至show Action顯示活動內容。那為甚麼要使用redirect_to forums_url 幹，這個跟forums_path有啥差別！！！！

這邊就可以參考ihower大提供的圖片

寫法如下阿～

[custom route]_event[s]_[path/url]( event ), :method => GET | POST | PUT | DELETE

_path結尾是相對網址，而_url結尾則會加上完整Domain網址。



如果user要在論壇點進去ＸＸＸ區看有哪些文章時，就要用到show這個動作，這邊很簡單，你只要做，那個:id我在想應該是你點那個連結時～就會有帶入一個參數讓Forum找到這筆資料

	{% codeblock lang:ruby %}
	def show
      		@forum = Forum.find(params[:id])
    	end
	{% endcodeblock %}

當然～你改了show的動作之後，就要有view與之對應是吧～ 不然找到的資料要怎麼給人家看？那就新增一個show.html.erb吧

	{% codeblock lang:ruby %}
		<%= @forum.forum_name %> 
		<p><%= link_to '回到主論壇', forums_path %></p>
	{% endcodeblock %}
	
靠邀....我進到ＸＸ區，我想要知道這區有哪些文章....怎麼辦？
	
首先我們必須先回到資料庫的部份，forum資料庫會跟post資料庫有關，那有關是怎麼樣個有關法

Rails 的 ActiveRecord 實作了db的正規化設計， 原則有四種 

	has_one

	has_many  

	belongs_to 

	has_many :through

要怎麼用勒？我們知道forums有許多post對八～～

所以要在app/model/forum裡頭我要加一句

	{% codeblock lang:ruby %}
	has_many :posts
	{% endcodeblock %}

而post（文章）必定屬於一個forum（文章分區）對八～～

所以要在app/model/post加一句

	{% codeblock lang:ruby %}
	belongs_to : forum
	{% endcodeblock %}

加了上面有什麼意義～幹～意義是殺小 林爸只知道義氣

不好意思離題了....

當然你必須要在資料表中，那就是透過primary key和foreign keys將資料表互相關連起來

所以～我要先加入

	{% codeblock lang:ruby %}
	rails g migration add_forum_id_to_post
	{% endcodeblock %}

再來編輯這個產生的rb檔（會在db/migrate)

	{% codeblock lang:ruby %}
	class AddForumIdToPost < ActiveRecord::Migration
  		def self.up
    		add_column("posts" , "forum_id" , :integer )   
  		end

  		def self.down
    		remove_column("posts" , "forum_id")
  		end
	end
	{% endcodeblock %}

key 完之後別忘了.....

	{% codeblock lang:ruby %}
	rake db:migrate
	{% endcodeblock %}


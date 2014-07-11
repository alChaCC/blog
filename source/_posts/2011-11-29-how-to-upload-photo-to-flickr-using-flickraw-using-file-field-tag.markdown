---
layout: post
title: "How to Upload Photo to Flickr using Flickraw - Using file_field_tag"
date: 2011-11-29 23:22
comments: true
categories: Ruby_on_Rails
---

##真是太感動啦！！！

這個問題，卡了我超久，至少三個禮拜跑不掉....就像卡到陰一樣

問過PTT也問過Stackoverflow，不過還是沒有solution阿！

為了解這個問題，把程式碼改寫了一遍

也因此搞懂了一些似懂非懂的東西（但是不知道是不是觀念正確ＸＤ）

###沒錯~就是剛剛!!!

<!--more--> 

我終於解出來了～～

簡單講一下我的狀況

我想要將照片直接上傳自Flickr上～然後透過file_field_tag這個helper

我使用的lib是[flickraw](https://github.com/hanklords/flickraw)

他有個上傳的sample code 
{% codeblock lang:ruby%}
require 'flickraw'

# This is how to upload photos on flickr.
# You need to be authentified to do that.

API_KEY=''
SHARED_SECRET=''
ACCESS_TOKEN=''
ACCESS _SECRET=''
PHOTO_PATH='photo.jpg'

FlickRaw.api_key = API_KEY
FlickRaw.shared_secret = SHARED_SECRET
flickr.access_token = ACCESS_TOKEN
flickr.access_secret = ACCESS_SECRET

flickr.upload_photo PHOTO_PATH, :title => 'Title', :description => 'This is the description'
{% endcodeblock %}
沒錯！他要傳入的就是檔案的位置！

我試過直接丟照片的絕對位置給他，上傳是可以成功的！

但是，怎麼可能讓user自己輸入位址!?

所以當然要使用file的helper

但是要怎麼從file_field_tag來取得檔案位址

上網東看西看 

放一下我試過的笨方法...囧

{% codeblock lang:ruby %}
@upload = flickr.upload_photo(params[:image])
@upload = flickr.upload_photo(@tempfile.path)
@upload = flickr.upload_photo(@tempfile)
flickr.upload_photo(@original_filename)
@fileinmemory = params[:image].read
flickr.upload_photo(@fileinmemory.path)
flickr.upload_photo(params[:image].original_filename)
{% endcodeblock %}

大概看了下來發現主要的點，其實是不需要知道絕對路徑的！

>First though, I don't think you want the user's path, because that's relative to his local machine,  in fact I'd ignore the original file's path altogether.  You just need to extract the content and stash it away.

其實也是這句話給我靈感，感覺上會有個類似buffer的東東，處理上傳的事情

察看了一下自己的params

發現有個tempfile這個東東

所以我在想“應該”在裡面有一些路徑的參數，不管是絕對路徑還是暫存的路徑，應該就是會有這個屬性！

所以…終於試出來了

##flickr.upload_photo(params[:image].tempfile.path)

就是這句話而已！ 恭喜你～就可以使用flickraw的upload function上傳

不然，我可能真的要想辦法改他的lib…囧～

不過功力不夠....那要花的時間可就長了....

詳細程式碼，等我完整寫完之後～在分享出來

太感動了～




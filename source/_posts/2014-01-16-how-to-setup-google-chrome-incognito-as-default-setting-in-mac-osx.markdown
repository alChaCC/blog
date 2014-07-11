---
layout: post
title: "[HowTo] 在Mac 設定Chrome Default 打開為無痕模式"
date: 2014-01-16 20:37:43 +0800
comments: true
categories: 
---

主要是參考至 [Launch Google Chrome Incognito from the terminal or a shortcut in OSX](http://myquickfix.co.uk/2011/10/launch-google-chrome-in-incognito-from-terminal-or-a-shortcut-in-os-x/)

###首先，到Launchpad 
<iframe src="https://www.flickr.com/photos/alohacc/11979759324/player/c3cd572418" height="166" width="129"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>
### 找到**"AppleScript編寫程式"**
<iframe src="https://www.flickr.com/photos/alohacc/11979650303/player/b026cc0b9b" height="106" width="141"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>
### 貼上 
	
		tell application "Terminal"
			activate
			do script "open -a /Applications/Google\\ Chrome.app --args --incognito;"
			delay 1
			quit
		end tell

 
### 點選**"編譯"** 
<iframe src="https://www.flickr.com/photos/alohacc/11979353075/player/a02a18cd9d" height="206" width="504"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>
### 選取**"檔案"**, 選取**"輸出"**
<iframe src="https://www.flickr.com/photos/alohacc/11979650263/player/513656276c" height="334" width="275"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>
### 檔名**"Google Incognito"**, 檔案格式選擇**"應用程式"**
<iframe src="https://www.flickr.com/photos/alohacc/11979759234/player/9c1fc81b96" height="438" width="450"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>
### 下載[圖片](http://myquickfix.co.uk/wp-content/uploads/2011/10/chrome-incog-icon-512-150x150.png)

### 把圖片點開，點選顯示編輯工具列
<iframe src="https://www.flickr.com/photos/alohacc/11979759064/player/b667a73f60" height="361" width="595"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>

### 找到**"選取工具"**，把圖片框起來
<iframe src="https://www.flickr.com/photos/alohacc/11979758984/player/389afc6a6c" height="71" width="90"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>
並用鍵盤按"command+c"(複製)
<iframe src="https://www.flickr.com/photos/alohacc/11979650083/player/23d67e566f" height="187" width="223"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>
### 找到**Google Incognito**儲存位置
<iframe src="https://www.flickr.com/photos/alohacc/11979352755/player/a4182b1fb2" height="32" width="269"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>
點選右鍵，選擇**"簡介"**
<iframe src="https://www.flickr.com/photos/alohacc/11979352735/player/48bfde3138" height="200" width="287"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>
### 點選**左上角**的圖，鍵盤按"command+v"(貼上)
<iframe src="https://www.flickr.com/photos/alohacc/11979649923/player/8f1336be25" height="75" width="103"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>
### 完成！
<iframe src="https://www.flickr.com/photos/alohacc/11979649853/player/94ee9748ba" height="78" width="83"  frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen oallowfullscreen msallowfullscreen></iframe>

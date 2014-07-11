---
layout: post
title: "HOWTO: Setup your NAS server and connect to internet using PPPoE"
date: 2012-03-01 13:15
comments: true
categories: NAS 
---
裝備：

1. Synology DiskStation DS411slim  (之後簡稱d4s)
2. 中華電信撥接
3. Linux server
4. WD 1TB 2.5吋SATAII 硬碟(WD10JPVT) *2 


##  把硬碟裝進去d4s<-這不是廢話

<!--more-->

##  將d4s開機後，將網路線先連到linux server的其中一個孔
ps. 為啥我這樣做?

是因為我linux server抓不到d4s server，
明明就一個插在中華電信的機器port1，一個插在port2

所以只好先把d4s的網路線，先接在我linux server的其中一個孔，這樣他們就會在同一個區網了！

## 放入光碟，安裝Synology Assistant
{%codeblock%}
mkdir NAS_sever
mkdir /mnt/tmp_cdRom
mount /dev/你剛剛掛上去抓到的位址  /mnt/tmp_cdRom
cp /mnt/tmp_cdRom/Linux/* NAS_server
cd NAS_server
sh install.sh 
{%endcodeblock%}
> 不知道為啥…我遇到GLIBCXX_3.4.9' not found
> ，我抓了libstdc++ so 6.0 10然後重新鏈結，就OK了！

## 使用Synology Assistant連線到d4s

因為是新的機器，所以要先安裝DSM

一進去畫面，會問你安裝檔在哪裡

>它就放在光碟內的DSM資料夾內

之後就等他跑完摟～

##連進去之後，就看你要幹嘛，然後設定！

1. 硬碟格式化 ->超久....
2. 開服務(注意先不要設定網路！)
3. …etc



##重要的來了！ 使用有網路的電腦，先上網申請no-ip的帳號密碼

請參考[浮動ip轉固定ip no-ip教學](http://www.wretch.cc/blog/lovebcat/23350295)


## 設定d4s網路連線！

1. 登入d4s
2. 點選左上角"向下的箭頭"
3. 點選 "EZ-Internet"
4. 下一步
5. 選擇寬頻網路PPPoE
6. 輸入帳號密碼
7. 選擇你要開啓的服務
8. 選擇"使用DDNS服務供應商提供的現有伺服器名稱"
9. 輸入你剛剛在no-ip.com設定的hostname(也就是你的網址)，還有你的登入"no-ip"的帳號/密碼  <-這步我覺得最重要！
10. 完成！

##這時候，只要將本來插在server的線，轉插到中華電信的機器就大功告成啦！

只要輸入你剛剛寫的網址在browser

ex: alohaXDXD.no-ip.biz

恭喜你～你的NAS 完成對外連線了！

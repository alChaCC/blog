---
layout: post
title: "String handling between JavaScript and Ruby"
date: 2015-06-10 00:14:49 +0800
comments: true
categories: ["Ruby on Rails"] 
keywords: "Ruby on Rails, iconv, escape, javascript, string, big5, unescape, pack, unpack"
description: "this article show you how to convert string between big5(or others) and utf8. Ruby UTF-8, Big轉碼"
---

javascript 在做 **escape** 時，編碼出來的字，和Ruby的 **CGI.escape**、**URI.escape** 是不同的！

舉例來說：

在**browser console下**

    escape("台中市")
    > "%u53F0%u4E2D%u5E02"

但是在**rails c** 下
  
    CGI.escape("台中市")
    > "%E5%8F%B0%E4%B8%AD%E5%B8%82"
  
 Why? 
 
<!-- more -->

 查了一下Google，發現是因為在 js 在escape中文時，是將他編成 unicode 
 
 
 所以，
 
## javascript 如果要送中文字給Ruby 請使用
 
    encodeURIComponent("台中市")
    > "%E5%8F%B0%E4%B8%AD%E5%B8%82"
 
 
## 但是，往往沒辦法你不能去改人家的javascript，你只好.... javascripts escape string to UTF-8

查到的作法如下：

在**rails c** 下

    unicode_str = "%u53F0%u4E2D%u5E02"
  
    unicode_str.gsub(/\%u([\da-fA-F]{4})/) {|m|  [$1].pack('H*').unpack('n*').pack('U*')}

    => "台中市"
  

 參數解釋：
 
 因為 unicode 的字串都是由 %u 開頭，外加上 4個可能是數字可能是 小寫a~f 或是 大寫A~F，所以我們先透過 **gsub** 這個function將符合的字抓出來處理
 
 抓出來字之後，我們要使用 **pack** 和 **unpack** 方法，來將字進行解碼、編碼
 
 我們先抓一個字來看，就以 "台" 為例， (ps. **pack 只能用在array, unpack可以用在string**)
 
 gsub 會將 "53F0" 丟進去處理
 
    ["53F0"].pack('H*')
      
      => "S\xF0"
    
  # H: 代表了將他pack組成16進位字(hex string (high nibble first))
  
    "S\xF0".unpack('n*')
    
    => [21488]
  
  # n: 他會return一個 Integer，他代表了16-bit unsigned, network (big-endian) byte order
  
    [21488].pack('U*')
   
    => "台"
  
  # U: 將16位元NBO組成UTF-8
  
    
 REF:   
 [UNESCAPE編碼錯誤](http://www.cnphp6.com/archives/4967)
 
 
## 那反過來呢，要如何將UTF-8的字，做成像 javascript escape 後的結果

在**rails c**下
  
    return_str = ""
    "台中市".each_char { |c| return_str += "%u#{c.unpack("U*").pack("n*").unpack("H*").first}" }
    
    
    return_str 
    > "%u53f0%u4e2d%u5e02"
  
## 假設，你現在要串接的使用Big5寫的API，你發現他接收的parameters 居然是%A5%78%A4%A4%A5%AB

因為他default是接受，用 javascript escape Big5編碼的字

所以你要將你UTF-8的字，轉成符合他格式的字

這時候你要這樣做：

      return_str = ""
      Iconv.conv("BIG5", "UTF8", str).unpack("H*").first.scan(/../).each do |s|
        return_str += "%#{s}"
      end
      
一樣來看說明：

    Iconv.conv("BIG5", "UTF8", "台中市")
    
    => "\x{A578}\x{A4A4}\x{A5AB}"
    
    
    Iconv.conv("BIG5", "UTF8", "台中市").unpack("H*")
    
    => ["a578a4a4a5ab"]
    
    Iconv.conv("BIG5", "UTF8", "台中市").unpack("H*").first.scan(/../)
    
    => ["a5", "78", "a4", "a4", "a5", "ab"]
    


## 打完收工！
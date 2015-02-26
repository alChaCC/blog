---
layout: post
title: "CSV匯入中文編碼問題"
date: 2014-05-14 11:17:11 +0800
comments: true
categories: ["Ruby on Rails","CSV"]
keywords: "UTF-8, invalid byte, Ruby on Rails, CSV, import, 中文, 字元轉碼"
description: "Fight invalid UTF-8 bytes when CSV importing"
---

> 情境ㄧ：若是使用者(window平台)先從自己系統download資料，之後要再匯入

對於CSV檔案本身解決方法.... 

### =>  請他先用google drive 上傳他的CSV檔，再從google抓下來 

程式端醜陋的解法

    def import(file)
      csv_text = File.read(file.csv_textpath)
      begin  
        csv_text_new = Iconv.conv('utf-8','big5',csv_text) #若是使用者使用自己excel轉csv匯入
      rescue  
        #do nothing just keep going
        csv_text_new = csv_text #使用者使用google線上轉換下來的csv
      end 
      csv = CSV.parse(csv_text_new, headers: false, quote_char: "\x00", col_sep: "\t")
      header = csv.first.first.split(',')
      counter = 0
      csv.each do |row|
        unless counter == 0
          row = Hash[[header,row.first.split(',',header.count)].transpose]
          order = where(order_no: row["order_no"]).first
          if order.present?
            order.attributes = row.to_hash
            order.save!
          else
            Order.create!(row.to_hash)
          end
        end
          counter+=1
      end
    end
 

> 情境二 若是使用者直接拿外部產生的csv要匯入的話

    def importingrt(file)
      CSV.foreach(file.path, :headers => true, :col_sep => ',',encoding:'Big5:utf-8') do |row|
          order = where(order_no: rescueow["系統訂單編號"]).first
          if order.present?
                   if row["訂單狀態"] == '已出貨'
              order.ship!
                end
          else
            #do what you want
          end
        end
        
附錄：Ruby 的編碼清單

    Encoding.list.map {|a| a.name}

=> ["ASCII-8BIT", "UTF-8", "US-ASCII", "Big5", "Big5-HKSCS", "Big5-UAO",
 "CP949", "Emacs-Mule", "EUC-JP", "EUC-KR", "EUC-TW", "GB18030",
 "GBK", "ISO-8859-1", "ISO-8859-2", "ISO-8859-3", "ISO-8859-4",
 "ISO-8859-5", "ISO-8859-6", "ISO-8859-7", "ISO-8859-8", "ISO-8859-9",
 "ISO-8859-10", "ISO-8859-11",
 "ISO-8859-13",
 "ISO-8859-14",
 "ISO-8859-15",
 "ISO-8859-16",
 "KOI8-R",
 "KOI8-U",
 "Shift_JIS",
 "UTF-16BE",
 "UTF-16LE",
 "UTF-32BE",
 "UTF-32LE",
 "Windows-31J",
 "Windows-1251",
 "IBM437",
 "IBM737",
 "IBM775",
 "CP850",
 "IBM852",
 "CP852",
 "IBM855",
 "CP855",
 "IBM857",
 "IBM860",
 "IBM861",
 "IBM862",
 "IBM863",
 "IBM864",
 "IBM865",
 "IBM866",
 "IBM869",
 "Windows-1258",
 "GB1988",
 "macCentEuro",
 "macCroatian",
 "macCyrillic",
 "macGreek",
 "macIceland",
 "macRoman",
 "macRomania",
 "macThai",
 "macTurkish",
 "macUkraine",
 "CP950",
 "CP951",
 "stateless-ISO-2022-JP",
 "eucJP-ms",
 "CP51932",
 "EUC-JP-2004",
 "GB2312",
 "GB12345",
 "ISO-2022-JP",
 "ISO-2022-JP-2",
 "CP50220",
 "CP50221",
 "Windows-1252",
 "Windows-1250",
 "Windows-1256",
 "Windows-1253",
 "Windows-1255",
 "Windows-1254",
 "TIS-620",
 "Windows-874",
 "Windows-1257",
 "MacJapanese",
 "UTF-7",
 "UTF8-MAC",
 "UTF-16",
 "UTF-32",
 "UTF8-DoCoMo",
 "SJIS-DoCoMo",
 "UTF8-KDDI",
 "SJIS-KDDI",
 "ISO-2022-JP-KDDI",
 "stateless-ISO-2022-JP-KDDI",
 "UTF8-SoftBank",
 "SJIS-SoftBank"

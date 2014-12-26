---
layout: post
title: "[HowTo] Get Google Analytics Engagement Using R"
date: 2014-12-26 08:17:04 +0800
comments: true
categories: ["Google Analytics", "R"]
keywords: "Google Analytics, engagement, 中文, R, RGoogleAnalytics"
description: "this article show you how to get ga engagement from R，利用R取得GA網站參與度"
---


<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/2014%E5%B9%B4engagement-pageviews%E5%9C%96.png" alt="every months google analytic engagement(pageviews X session Duration) in 2014 using R">

**使用者在網站上的參與程度**，是我一直滿好奇的指標！

在GA裡，網站參與度，如下圖

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-22%20%E4%B8%8A%E5%8D%883.13.48.png" alt=“google analytics engagement”>


這系列的文章，我的target是 我想知道今年(2014)整體使用者參與度的變化與趨勢

此篇文章是focus 在如何透過R抓取資料並分析成和 GA view一樣的資料！

之後，再看看可以看到什麼樣比較有意義的資料～

let's go !

<!-- more -->


## Google Analytic API 申請 

在做GA之前，別忘記要申請**[GA API權限](http://ccaloha.herokuapp.com/blog/2014/12/24/howto-get-google-analytics-using-r-rgoogleanalytics-using-users-pageviews-time-as-an-example/)**


## Google Query Explorer [link](https://ga-dev-tools.appspot.com/explorer/) 

Google 提供的工具，我覺得還滿好用的！

在使用API之前，使用 explorer 可以讓你先有Fu大概知道會拿到什麼樣的資料！

大概看一下怎麼用吧

### Step1. 先登入Google Analytics的帳號

### Step2. 回到Google Query Explorer，重新refresh

點選認證

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-25%20%E4%B8%8A%E5%8D%888.16.31.png" alt="點選 Click Here to authorize">

你就可以看到

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-25%20%E4%B8%8A%E5%8D%888.20.28.png" alt="Google Query Explorer 取得GA權限後頁面">

其中，**account** /  **Property** / **View(Profile)** 就是

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-25%20%E4%B8%8A%E5%8D%888.24.24.png" alt="對應GA">


### Step3. 看一下哪些GA View 對應到API的名稱

請到 [Google Analytics Dimensions & Metrics Reference](https://developers.google.com/analytics/devguides/reporting/core/dimsmets)

我們要找的就是

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-26%20%E4%B8%8A%E5%8D%887.46.24.png" alt="Sessions">

點進去**"ga:sessionDurationBucket"**

你會看到 **“web view name: Session Duration”** 沒錯！ 那個就是對應到GA View的名稱！

耶～～找到了～～ 

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-26%20%E4%B8%8A%E5%8D%887.48.45.png" alt="ga:sessionDurationBucket definition">


### Step4. 找到之後，趕緊來Google Query Explorer試試抓數據的感覺

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-22%20%E4%B8%8A%E5%8D%883.20.14.png" alt="fetch data from google query explorer">

ya~~~拿到資料了！

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-26%20%E4%B8%8A%E5%8D%887.54.52.png" alt="get ga:sessionDurationBucket , ga:sessions and ga:sessionDuration from Google Query Explorer">

咦！那個**ga:sessionDurationBucket**好像有點怪怪的～

各位人客，請不要緊張～

那是因為他吐回來的資料是**String**，所以他的排序才是這樣～

### Step5. R

說明都寫在裡面！

ps. 由於小弟我還是R新手，寫的鳥鳥的地方，還請見諒，如果可以的話，可以留言告訴我，哪裡怎麼寫會比較好～ 感謝！ 

[點我看比較漂亮的gist](https://gist.github.com/alChaCC/4fee2a25a422dceb40f5)

    setwd("r-playground/R/ga_engagement") #設定你要的操作順序
    list.of.packages <- c("rjson", "RCurl","RGoogleAnalytics")
    new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)
    require(rjson)
    require(RCurl)
    require(RGoogleAnalytics)
    require(ggplot2)
    token <- Auth('YOUR API USER ID','YOUR API USER PASSWORD')
    save(token,file="./token_file")
    profile <- GetProfiles(token) # show all your profile 
    #          id                               name
    #    XXXXXX                      HELLO (All)
    #  YYYYYYYY                      COOL
    #   ....

    # Your profile number (not the GA ID number)
    my_profile    <- profile[profile$name == 'HELLO (All)',1] 

    time_start_seq <- as.Date(ISOdate(2014,seq(1,12),1))
    #[1] "2014-01-01" "2014-02-01" "2014-03-01" "2014-04-01" "2014-05-01" "2014-06-01"
    #[7] "2014-07-01" "2014-08-01" "2014-09-01" "2014-10-01" "2014-11-01" "2014-12-01"
    time_end_seq <- seq(as.Date("2014-02-01"), length=12, by="1 month") - 1
    # [1] "2014-01-31" "2014-02-28" "2014-03-31" "2014-04-30" "2014-05-31" "2014-06-30"
    # [7] "2014-07-31" "2014-08-31" "2014-09-30" "2014-10-31" "2014-11-30" "2014-12-31"

    # 為了做資料紀錄
    every_month_2014 <- list()
    all_data <- data.frame()

    for ( i in 1:length(time_start_seq)) {

      query.list <- Init(start.date = as.character(time_start_seq[i]),
                         end.date = as.character(time_end_seq[i]),
                         dimensions = "ga:sessionDurationBucket",
                         metrics = "ga:sessions,ga:pageviews",
                         sort = "ga:sessionDurationBucket",
                         max.results = 10000,
                         table.id = paste("ga:",my_profile,sep="",collapse=",")
                         )
      
      # 建立一個query等一下就是透過這個query與token拿資料！
      ga.query <- QueryBuilder(query.list)
      
      # 向GA抓取資料，存成data frame
      ga.data <- GetReportData(ga.query, token) 
      # ga.data <- GetReportData(ga.query, token,split_daywise = T,paginate_query = TRUE)  另外一種拿法也work


      # 資料處理部分，由於抓回來的 “data$sessionDurationBucket” 是個string，所要把它轉成 數字
      less_than_10_seconds <- ga.data[as.numeric(ga.data$sessionDurationBucket) <= 10,]
      between_11_to_30     <- ga.data[as.numeric(ga.data$sessionDurationBucket) > 10 & as.numeric(ga.data$sessionDurationBucket) <= 30,]
      between_31_to_60     <- ga.data[as.numeric(ga.data$sessionDurationBucket) > 30 & as.numeric(ga.data$sessionDurationBucket) <= 60,]
      between_61_to_180    <- ga.data[as.numeric(ga.data$sessionDurationBucket) > 60 & as.numeric(ga.data$sessionDurationBucket) <= 180,]
      between_181_to_600   <- ga.data[as.numeric(ga.data$sessionDurationBucket) > 180 & as.numeric(ga.data$sessionDurationBucket) <= 600,]
      between_601_to_1800  <- ga.data[as.numeric(ga.data$sessionDurationBucket) > 600 & as.numeric(ga.data$sessionDurationBucket) <= 1800,]
      more_than_1801       <- ga.data[as.numeric(ga.data$sessionDurationBucket) > 1800,]
      
      # 處理後資料長這樣
      #     sessionDurationBucket sessions pageviews
      #                        0   342840    341561
      #                        1     1445      1906
      #                       10     2567      4392
      #                        2     2210      2704
      #                        3     2283      2934
      #                        4     2309      3133
      #                        5     2368      3384

      
      # 資料整併
      every_month_2014[[i]] <- rbind(colSums(less_than_10_seconds[,-1]),colSums(between_11_to_30[,-1]),
                                     colSums(between_31_to_60[,-1]),colSums(between_61_to_180[,-1]),
                                     colSums(between_181_to_600[,-1]),colSums(between_601_to_1800[,-1]),
                                     colSums(more_than_1801[,-1]))
      #       sessions pageviews
      #[1,]   365814    375361
      #[2,]    44857     92466
      #[3,]    48003    133645
      #[4,]    96890    423865
      #[5,]   107373    872529
      #[6,]    78404   1057353
      #[7,]    28183    812783

      
      # 補上一欄時間區間
      month_all_data <- cbind(c(as.character(i)),c("< 10s","11 ~ 30","31~60","61~180","181~600","601~1800",">1801"),every_month_2014[[i]])
      #                     sessions pageviews
      #[1,] "12" "< 10s"    "365814" "375361" 
      #[2,] "12" "11 ~ 30"  "44857"  "92466"  
      #[3,] "12" "31~60"    "48003"  "133645" 
      #[4,] "12" "61~180"   "96890"  "423865" 
      #[5,] "12" "181~600"  "107373" "872529" 
      #[6,] "12" "601~1800" "78404"  "1057353"
      #[7,] "12" ">1801"    "28183"  "812783" 

      # 將每一年的統整資料放在一起，作圖需要
      all_data <- rbind(all_data,month_all_data)
    }


    # 補上欄位名稱
    colnames(all_data) <- c("month","time_interval","sessions","pageviews")


    # 先畫pageviews
    # 將資料的型態改正，因為上面建立的時候，會將每個欄位的屬性變成"factor"，這會對畫圖趙成莫大影響！
    all_data <- transform(all_data, 
        time_interval = factor(time_interval, levels = 
            c('< 10s','11 ~ 30','31~60', '61~180','181~600', '601~1800','>1801')),
        pageviews = as.numeric(as.character(pageviews)))

    # 作圖
    plot <- ggplot(data = all_data, aes(x = month, y = pageviews, fill = time_interval)) +  
        geom_bar(stat = "identity", position = "dodge", colour = "black")

    # 將圖存出
    ggsave(plot,file=paste("2014年engagement-pageviews圖.png",sep=""),width=15, height=10)


    # 再畫sessions
    all_data <- transform(all_data, 
        time_interval = factor(time_interval, levels = 
            c('< 10s','11 ~ 30','31~60', '61~180','181~600', '601~1800','>1801')),
        sessions = as.numeric(as.character(sessions)))

    plot <- ggplot(data = all_data, aes(x = month, y = sessions, fill = time_interval)) +  
        geom_bar(stat = "identity", position = "dodge", colour = "black")

    ggsave(plot,file=paste("2014年engagement-sessions圖.png",sep=""),width=15, height=10)


### Done

先來看 2014年每月 pageview 與 使用者平均在線時間 的 bar chart

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/2014%E5%B9%B4engagement-pageviews%E5%9C%96.png" alt="every months google analytic engagement(pageviews X session Duration) in 2014 using R">


再來看 2014年每月 sessions 與 使用者平均在線時間 的 bar chart

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/get%20google%20analytics%20engagement%20using%20R/2014%E5%B9%B4engagement-sessions%E5%9C%96.png" alt="every months google analytic engagement(sessions X session Duration) in 2014 using R"> 
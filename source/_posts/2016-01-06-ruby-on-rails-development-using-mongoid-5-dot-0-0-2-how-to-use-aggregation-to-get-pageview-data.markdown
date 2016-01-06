---
layout: post
title: "Ruby on Rails Development Using Mongoid 5.0.0 - 2. How to use Aggregation to get pageview data"
date: 2016-01-06 13:57:37 +0800
comments: true
categories: ["Ruby on Rails", "Mongoid"]
keywords: "Aggregation, Mongoid 5.0.0, MongoDB, Ruby on Rails, match, limit, group, project, sort"
description: "this article show you how to use aggregation with Mongoid 5.0.0 in Ruby on Rails such as match, limit, group, project and sort operations."
---

What is Aggregation ?

> Aggregations are operations that process data records and return computed results.

In my opinion, it just like queries but it can do some operations step by step when processing the query just like a pipeline.  

<img src='https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Ruby%20on%20Rails%20Development%20Using%20Mongoid%20-%202%20How%20to%20use%20Aggregation%20to%20get%20pageview%20data/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202016-01-05%2017.31.06.png' alt='MongoDB Aggregation'>

if you want more details, please check [official documents](https://docs.mongodb.org/manual/core/aggregation-introduction/)

<!--more-->

Here are my models, 

<img src='https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Ruby%20on%20Rails%20Development%20Using%20Mongoid%20-%202%20How%20to%20use%20Aggregation%20to%20get%20pageview%20data/model.png' alt='aggregation model example'>

## Get Data using "match"

If I want to find pageview from 2016/1/1 to 2016/1/5

```
sort_stage = {
        '$sort' => { 'created_at' => 1 }
    }
    
match_stage = {
          '$match' => {
            "created_at" => {
              "$gte" => Time.parse('2016-01-01').beginning_of_day, 
              "$lte" => Time.parse('2016-01-05').end_of_day
            }
          }
        }

result = PageTracking.collection.aggregate([sort_stage,match_stage])
result.each do |page|
  puts page
end
```
Here is my result: 

```
{"_id"=>BSON::ObjectId('568a1ef77db99bc968000002'), "pathname"=>"/", "daily_total_count"=>2, "created_at"=>2016-01-03 16:00:00 UTC, "user_id"=>BSON::ObjectId('568a1ef77db99bc968000000'), "updated_at"=>2016-01-04 07:27:51 UTC }
{"_id"=>BSON::ObjectId('568b28ad7db99b1ae8000002'), "pathname"=>"/", "daily_total_count"=>1, "created_at"=>2016-01-04 16:00:00 UTC, "user_id"=>BSON::ObjectId('568b28ad7db99b1ae8000000'), "updated_at"=>2016-01-05 02:21:33 UTC}
{"_id"=>BSON::ObjectId('568b28e67db99b1ae8000005'), "pathname"=>"/", "daily_total_count"=>3, "created_at"=>2016-01-04 16:00:00 UTC, "user_id"=>BSON::ObjectId('568b28e67db99b1ae8000003'), "updated_at"=>2016-01-05 02:22:30 UTC}
{"_id"=>BSON::ObjectId('568b7d307db99b9a30000011'), "pathname"=>"/activities", "daily_total_count"=>1, "created_at"=>2016-01-04 16:00:00 UTC, "user_id"=>BSON::ObjectId('568b28e67db99b1ae8000003'), "updated_at"=>2016-01-05 08:22:08 UTC}
{"_id"=>BSON::ObjectId('568b7d8e7db99b9a30000013'), "pathname"=>"/activities/hadalabo01", "daily_total_count"=>1, "created_at"=>2016-01-04 16:00:00 UTC, "user_id"=>BSON::ObjectId('568b28e67db99b1ae8000003'), "updated_at"=>2016-01-05 08:23:42 UTC}
{"_id"=>BSON::ObjectId('568b7e5e7db99b9a30000017'), "pathname"=>"/beautybuzz", "daily_total_count"=>1, "created_at"=>2016-01-04 16:00:00 UTC, "user_id"=>BSON::ObjectId('568b28e67db99b1ae8000003'), "updated_at"=>2016-01-05 08:27:10 UTC}
{"_id"=>BSON::ObjectId('568b78c07db99b9a30000001'), "pathname"=>"/beautynews", "daily_total_count"=>1, "created_at"=>2016-01-04 16:00:00 UTC, "user_id"=>BSON::ObjectId('568b28e67db99b1ae8000003'), "updated_at"=>2016-01-05 08:03:12 UTC}
```

ps. I add a sort stage in front of match stage due to the official suggestion.[Aggregation Pipeline Optimization](https://docs.mongodb.org/manual/core/aggregation-pipeline-optimization/#sort-match-sequence-optimization)

## Group Data using "group"

Oops, in fact, I want all records with **pathname => '/'** should be summed up to one record just like **group_by** in MySQL

So, we can add a new stage

```
group_stage = {
          "$group" => {
            "_id" => {
              "pathname" => "$pathname"
            },
            "page_count" => { "$sum" => "$daily_total_count" }
          }
         }
result = PageTracking.collection.aggregate([sort_stage,match_stage,group_stage])

result.each do |page|
  puts page
end

```

which mean we can group by "pathname" and when we do grouping we can sum all daily_total_count into "page_count" 

Here is my result

```
{"_id"=>{"pathname"=>"/beautybuzz"}, "page_count"=>1}
{"_id"=>{"pathname"=>"/activities/hadalabo01"}, "page_count"=>1}
{"_id"=>{"pathname"=>"/activities"}, "page_count"=>1}
{"_id"=>{"pathname"=>"/beautynews"}, "page_count"=>1}
{"_id"=>{"pathname"=>"/"}, "page_count"=>6}
```

## Add more information while grouping Data using "push"

Ok, great! But, I got an another requirement, Hi, Aloha, Can you tell me that who see each pages? 

Easy, let's add some codes in group_stage

```
group_stage = {
          "$group" => {
            "_id" => {
              "pathname" => "$pathname"
            },
            "page_count" => { "$sum" => "$daily_total_count" },
            "users" => {
              "$push" => {
                "user" => "$user_id"
              }
            }
          }
         }
result = PageTracking.collection.aggregate([sort_stage,match_stage,group_stage])

result.each do |page|
  puts page
end

```

Here is my result

```
{"_id"=>{"pathname"=>"/beautybuzz"}, "page_count"=>1, "users"=>[{"user"=>BSON::ObjectId('568b28e67db99b1ae8000003')}]}
{"_id"=>{"pathname"=>"/activities/hadalabo01"}, "page_count"=>1, "users"=>[{"user"=>BSON::ObjectId('568b28e67db99b1ae8000003')}]}
{"_id"=>{"pathname"=>"/activities"}, "page_count"=>1, "users"=>[{"user"=>BSON::ObjectId('568b28e67db99b1ae8000003')}]}
{"_id"=>{"pathname"=>"/beautynews"}, "page_count"=>1, "users"=>[{"user"=>BSON::ObjectId('568b28e67db99b1ae8000003')}]}
{"_id"=>{"pathname"=>"/"}, "page_count"=>6, "users"=>[{"user"=>BSON::ObjectId('568a1ef77db99bc968000000')}, {"user"=>BSON::ObjectId('568b28ad7db99b1ae8000000')}, {"user"=>BSON::ObjectId('568b28e67db99b1ae8000003')}]}
```

Cool, our aggregation run smoothly.

## Aggregate Big Data 

After 3 months, we found that some fetch pageview operations will fail. 

Oops, since these fetch operations use big time range (ex: get pageview data from 2015/9/1 ~ 2016/1/1)

```
match_stage = {
          '$match' => {
            "created_at" => {
              "$gte" => Time.parse('2015-09-01').beginning_of_day, 
              "$lte" => Time.parse('2016-01-01').end_of_day
            }
          }
        }

result = PageTracking.collection.aggregate([sort_stage,match_stage,group_stage])

result.each do |page|
  puts page
end

```

I got this error message: 

```
aggregate | FAILED | exception: Exceeded memory limit for $group, but didn't allow external sort. Pass allowDiskUse:true to opt in. (16945) | 9.955263s
Mongo::Error::OperationFailure: exception: Exceeded memory limit for $group, but didn't allow external sort. Pass allowDiskUse:true to opt in. (16945)
```

How can we solve this problem?

Just like message says, add **allowDiskUse:true** to it.

```
result = PageTracking.collection.aggregate(
            [sort_stage,match_stage,group_stage],
            :allow_disk_use => true
          )
result.each do |page|
  puts page
end
```

Yay, bug fixed.

```
...
you will got a lots of data ....
...
```

## Limit data using "limit"

if you just want 1000 data pass to next stage

```
sort_stage = {
        '$sort' => { 'created_at' => -1 }
    }

limit_stage = {
      '$limit' => 1000
    }
    
result = UserPageTracking.collection.aggregate(
      [sort_stage, limit_stage , match_stage, group_stage],
      :allow_disk_use => true
    )
result.each do |page|
  puts page
end
```

## Only want some specific data using "project"

If fact, we don't need created_at, updated_at attributes in group stage, so we can ... 

```
project_stage = 
      { 
        "$project" => { user_id: 1, pathname: 1, daily_total_count: 1}
      }

result = PageTracking.collection.aggregate(
            [sort_stage,match_stage, project_stage, group_stage]
          )
result.each do |page|
  puts page
end

```





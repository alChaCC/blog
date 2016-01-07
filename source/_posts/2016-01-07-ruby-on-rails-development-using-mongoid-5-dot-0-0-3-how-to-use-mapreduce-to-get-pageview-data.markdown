---
layout: post
title: "Ruby on Rails Development Using Mongoid 5.0.0 - 3. How to use MapReduce to get pageview data"
date: 2016-01-07 16:38:55 +0800
comments: true
categories: ["Ruby on Rails", "Mongoid"]
keywords: "MapReduce, Mongoid 5.0.0, MongoDB, Ruby on Rails,map, reduce, finialize, out"
description: "this article show you how to use MapReduce with Mongoid 5.0.0 in Ruby on Rails such as map, reduce and finalize operations."
---

What is MapReduce? 

> Map-reduce is a data processing paradigm for condensing large volumes of data into useful aggregated results.

**MapReduce** is a popular big data term in recent years proposed by Google. It is a method for manipulate large data sets parallelly and distributedly on   many machines. In my words, I usually said that Map-Reduce, "Map" is to assign match function to many machines for cutting a huge data into small data sets(group matched data), and then use "Reduce" to aggregate these calculated data.

> In this map-reduce operation, MongoDB applies the map phase to each input document (i.e. the documents in the collection that match the query condition). The map function emits key-value pairs. For those keys that have multiple values, MongoDB applies the reduce phase, which collects and condenses the aggregated data. MongoDB then stores the results in a collection. Optionally, the output of the reduce function may pass through a finalize function to further condense or process the results of the aggregation.

<img src='https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Ruby%20on%20Rails%20Development%20Using%20Mongoid%205.0.0%20-%203.%20How%20to%20use%20MapReduce%20to%20get%20pageview%20data/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7%202016-01-06%2016.12.54.png' alt='MongoDB MapReduce'>

if you want more details, please check [official documents](https://docs.mongodb.org/manual/core/map-reduce/)

Let's go check how to use **map reduce** in Mongoid.

<!--more-->

I also write an article for aggregation method. Please check: [Ruby on Rails Development Using Mongoid 5.0.0 - 2. How to Use Aggregation to Get Pageview Data](http://ccaloha.cc/blog/2016/01/06/ruby-on-rails-development-using-mongoid-5-dot-0-0-2-how-to-use-aggregation-to-get-pageview-data/)

Again, Here are my models, 

<img src='https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Ruby%20on%20Rails%20Development%20Using%20Mongoid%20-%202%20How%20to%20use%20Aggregation%20to%20get%20pageview%20data/model.png' alt='Mongoid map-reduce model example'> 

## Calculate Unique Pageviews from 2016/1/1 to 2016/1/5

First, MongoDB use custom Javascript functions to do map and reduce operations. So, we need to write JS code as a string and pass to MongoDB. 

In this example, I hope that the same page a user watched in the same day should be calculated just one time(eg. If I watch path '/' 3 times a day, the pageview should be 1 not 3). So, I call it unique pageviews. 

### Let's Check Map Function

I use "pathname" as an identifier(key) and use {"total": 1} as a value. In my opinion, value is the result that you want to obtain.

> In the map function, reference the current document as **this** within the function.

```
map = %q{ 
              function() {
                emit(
                  this.pathname,
                  {
                    total: 1
                  } 
                );
              } 
          }

```


### How About Reduce Function?
 
Reduce function will get the key and value from map function.

```
reduce = %q{
              function(key, values){
                print("=====================");
                print("Key is:" + key);
                print("Value is:" + JSON.stringify(values));
                var r = { total: 0};
                for (var idx  = 0; idx < values.length; idx++) {
                  var tt = values[idx].total;
                  r.total += tt
                }
                return r;
              }
            }
```

> Tips: we can use "print" for debugging.

### Using MapReduce in Mongoid

Now, we can put map and reduce function together. 

```
res = PageTracking.where(:created_at.gte => Time.parse('2016-01-01').beginning_of_day , 
:created_at.lte => Time.parse('2016-01-05').end_of_day)
.order_by(:created_at => 'desc')
.map_reduce(map,reduce)
.out(inline: true)
```

console will show like below

```
=> #<Mongoid::Contextual::MapReduce
  selector: {"created_at"=>{"$gte"=>2015-12-31 16:00:00 UTC, "$lte"=>2016-01-05 15:59:59 UTC}}
  class:    PageTracking
  map:
              function() {
                emit(
                  this.pathname,
                  {
                    total: 1
                  }
);
}

  reduce:
              function(key, values){
                print("=====================");
                print("Key is:" + key);
                print("Value is:" + JSON.stringify(values));
                var r = { total: 0};
                for (var idx  = 0; idx < values.length; idx++) {
                  var tt = values[idx].total;
                  r.total += tt
                }
return r;
}

  finalize:
  out:      {:inline=>true}>

```

Let's get all results.

```
res.to_a
```
Here is my result.

```
[{"_id"=>"/", "value"=>{"total"=>3.0}},
 {"_id"=>"/activities", "value"=>{"total"=>1.0}},
 {"_id"=>"/activities/hadalabo01", "value"=>{"total"=>1.0}},
 {"_id"=>"/beautybuzz", "value"=>{"total"=>1.0}},
 {"_id"=>"/beautynews", "value"=>{"total"=>1.0}}]
```

ps. If you want to check the debugging message, you can 

```
# check the location of MongoDB system log
cat /usr/local/etc/mongod.conf

# In my case, it will be located in /usr/local/var/log/mongodb/mongo.log
tail -1000f /usr/local/var/log/mongodb/mongo.log
``` 

And I see

```
2016-01-07T11:49:24.460+0800 I -        [conn3] =====================
2016-01-07T11:49:24.460+0800 I -        [conn3] Key is:/
2016-01-07T11:49:24.460+0800 I -        [conn3] Value is:[{"total":1},{"total":1},{"total":1}]
```

It's weird, in result, I have many different "_id" such as '/', '/activities', '/beautybuzz'. But, in MongoDB system log, I just see '/'. Why? 

According to [Requirements for the reduce Function](https://docs.mongodb.org/manual/reference/command/mapReduce/#requirements-for-the-reduce-function).

> MongoDB will not call the reduce function for a key that has only a single value. The values argument is an array whose elements are the value objects that are “mapped” to the key.

Let's check the data in my MongoDB, 

```
PageTracking.where(:created_at.gte => Time.parse('2016-01-01').beginning_of_day , :created_at.lte => Time.parse('2016-01-05').end_of_day).order_by(:created_at => 'desc').to_a
```

As you can see, pathname except '/' are just have one record. So, it will not be handled by reduce function. 

```
[#<PageTracking _id: 568b78c07db99b9a30000001, created_at: 2016-01-04 16:00:00 UTC, updated_at: 2016-01-05 08:03:12 UTC, pathname: "/beautynews", daily_total_count: 1, user_id: BSON::ObjectId('568b28e67db99b1ae8000003')>,
 #<PageTracking _id: 568b7e5e7db99b9a30000017, created_at: 2016-01-04 16:00:00 UTC, updated_at: 2016-01-05 08:27:10 UTC, pathname: "/beautybuzz", daily_total_count: 1, user_id: BSON::ObjectId('568b28e67db99b1ae8000003')>,
 #<PageTracking _id: 568b7d8e7db99b9a30000013, created_at: 2016-01-04 16:00:00 UTC, updated_at: 2016-01-05 08:23:42 UTC, pathname: "/activities/hadalabo01", daily_total_count: 1, user_id: BSON::ObjectId('568b28e67db99b1ae8000003')>,
 #<PageTracking _id: 568b7d307db99b9a30000011, created_at: 2016-01-04 16:00:00 UTC, updated_at: 2016-01-05 08:22:08 UTC, pathname: "/activities", daily_total_count: 1, user_id: BSON::ObjectId('568b28e67db99b1ae8000003')>,
 #<PageTracking _id: 568b28e67db99b1ae8000005, created_at: 2016-01-04 16:00:00 UTC, updated_at: 2016-01-05 02:22:30 UTC, pathname: "/", daily_total_count: 3, user_id: BSON::ObjectId('568b28e67db99b1ae8000003')>,
 #<PageTracking _id: 568b28ad7db99b1ae8000002, created_at: 2016-01-04 16:00:00 UTC, updated_at: 2016-01-05 02:21:33 UTC, pathname: "/", daily_total_count: 1, user_id: BSON::ObjectId('568b28ad7db99b1ae8000000')>,
 #<PageTracking _id: 568a1ef77db99bc968000002, created_at: 2016-01-03 16:00:00 UTC, updated_at: 2016-01-04 07:27:51 UTC, pathname: "/", daily_total_count: 2, user_id: BSON::ObjectId('568a1ef77db99bc968000000')>]
```

If I watch '/activities' again, and run MapReduce again.

yay, I can see /activities in system log.

```
2016-01-07T14:42:23.349+0800 I -        [conn3] =====================
2016-01-07T14:42:23.349+0800 I -        [conn3] Key is:/
2016-01-07T14:42:23.350+0800 I -        [conn3] Value is:[{"total":1},{"total":1},{"total":1}]
2016-01-07T14:42:23.350+0800 I -        [conn3] =====================
2016-01-07T14:42:23.350+0800 I -        [conn3] Key is:/activities
2016-01-07T14:42:23.350+0800 I -        [conn3] Value is:[{"total":1},{"total":1}]
```

## Calculate Non-Unique Pageviews

In this example, I don't care a user watched same page in the same day. I want all pageviews. (eg. If I watch path '/' 3 times a day, the pageview should be 3). So, I call it non-unique pageviews. 


The only thing I have to update is map function. Change **total: 1** to **total: this.daily\_total\_count**

```
total_map = %q{ 
              function() {
                emit(
                  this.pathname,
                  {
                    total: this.daily_total_count
                  } 
                );
              } 
          }

```

yay!

```
[{"_id"=>"/", "value"=>{"total"=>6.0}},
 {"_id"=>"/activities", "value"=>{"total"=>2.0}},
 {"_id"=>"/activities/hadalabo01", "value"=>{"total"=>1.0}},
 {"_id"=>"/beautybuzz", "value"=>{"total"=>1.0}},
 {"_id"=>"/beautynews", "value"=>{"total"=>1.0}}]
```


## Calculate Pageviews and Get Who Watch The Page

In this example, beside calculate pageviews, I want to get user who watch the page as well. 

```
map_with_user = %q{ 
              function() {
                var key = {
                  pathname: this.pathname
                };
                emit(
                  key,
                  {
                    total:  this.daily_total_count,
                    user_id:   this.user_id
                  } 
                );
              } 
          }

reduce_with_user = %q{
              function(key, values){
                print("=====================");
                print("Key is:" + JSON.stringify(key));
                print("Value is:" +  JSON.stringify(values));
                var r = { 
                    total: 0,
                    users: []
                };
                for (var idx  = 0; idx < values.length; idx++) {
                    r.total += values[idx].total;
                    r.users.push(values[idx].user_id);
                }
                return r;
              }
            }

PageTracking.where(:created_at.gte => Time.parse('2016-01-01').beginning_of_day , 
:created_at.lte => Time.parse('2016-01-07').end_of_day)
.order_by(:created_at => 'desc')
.map_reduce(map_with_user,reduce_with_user)
.out(inline: true).to_a

```

> Tips: key can also be a hash.

Since we want to get all users so I add **users: []**, then I just push user_id in it.

The result is...

```
[
{  
  "_id"  =>  {  
    "pathname"    =>"/"
  },
  "value"  =>  {  
    "total"    =>6.0,
    "users"    =>    [  
      BSON::ObjectId('568b28e67db99b1ae8000003'),
      BSON::ObjectId('568b28ad7db99b1ae8000000'),
      BSON::ObjectId('568a1ef77db99bc968000000')
    ]
  }
},
{  
  "_id"  =>  {  
    "pathname"    =>"/activities"
  },
  "value"  =>  {  
    "total"    =>3.0,
    "users"    =>    [  
      BSON::ObjectId('568e08937db99b12c1000000'),
      BSON::ObjectId('568b28e67db99b1ae8000003')
    ]
  }
},
{  
  "_id"  =>  {  
    "pathname"    =>"/activities/hadalabo01"
  },
  "value"  =>  {  
    "total"    =>1.0,
    "user_id"    =>BSON::ObjectId('568b28e67db99b1ae8000003')
  }
},
{  
  "_id"  =>  {  
    "pathname"    =>"/beautybuzz"
  },
  "value"  =>  {  
    "total"    =>1.0,
    "user_id"    =>BSON::ObjectId('568b28e67db99b1ae8000003')
  }
},
{  
  "_id"  =>  {  
    "pathname"    =>"/beautynews"
  },
  "value"  =>  {  
    "total"    =>1.0,
    "user_id"    =>BSON::ObjectId('568b28e67db99b1ae8000003')
  }
}
]
```

Take a look of system log, to see what's key and values pass to reduce function.

```
2016-01-07T15:43:24.520+0800 I -        [conn3] =====================
2016-01-07T15:43:24.520+0800 I -        [conn3] Key is:{"pathname":"/"}
2016-01-07T15:43:24.521+0800 I -        [conn3] Value is:[{"total":3,"user_id":{"str":"568b28e67db99b1ae8000003"}},{"total":1,"user_id":{"str":"568b28ad7db99b1ae8000000"}},{"total":2,"user_id":{"str":"568a1ef77db99bc968000000"}}]
2016-01-07T15:43:24.521+0800 I -        [conn3] =====================
2016-01-07T15:43:24.521+0800 I -        [conn3] Key is:{"pathname":"/activities"}
2016-01-07T15:43:24.521+0800 I -        [conn3] Value is:[{"total":2,"user_id":{"str":"568e08937db99b12c1000000"}},{"total":1,"user_id":{"str":"568b28e67db99b1ae8000003"}}]
```

Here, you will notice that there are some values has **user_id** and some has **users**. Again, since some keys only has single value, it will not be processed by reduce function.  

## Use "finalize" function to beautify the result

It's annoying, if data format is not consistent. So, I use finalize function to solve this problem. 

```
finalize = %q{
  function(key, reducedValue){
    print("=====================");
    print("Key is:" + JSON.stringify(key));
    print("reducedValue is:" + JSON.stringify(reducedValue));
    var result = {
      user_data: []
    }
    if(reducedValue.users){
      reducedValue.users.forEach(function(u){
        result.user_data.push(u);
       });
    } else {
      result.user_data.push(reducedValue.user_id);
    }
    return result
  }
}

PageTracking.where(:created_at.gte => Time.parse('2016-01-01').beginning_of_day , 
:created_at.lte => Time.parse('2016-01-07').end_of_day)
.order_by(:created_at => 'desc')
.map_reduce(map_with_user,reduce_with_user)
.finalize(finalize)
.out(inline: true).to_a
```

Yay, every results looks same~~

```
[
{  
  "_id"  =>  {  
    "pathname"    =>"/"
  },
  "value"  =>  {  
    "user_data"    =>    [  
      BSON::ObjectId('568b28e67db99b1ae8000003'),
      BSON::ObjectId('568b28ad7db99b1ae8000000'),
      BSON::ObjectId('568a1ef77db99bc968000000')
    ]
  }
},
{  
  "_id"  =>  {  
    "pathname"    =>"/activities"
  },
  "value"  =>  {  
    "user_data"    =>    [  
      BSON::ObjectId('568e08937db99b12c1000000'),
      BSON::ObjectId('568b28e67db99b1ae8000003')
    ]
  }
},
{  
  "_id"  =>  {  
    "pathname"    =>"/activities/hadalabo01"
  },
  "value"  =>  {  
    "user_data"    =>    [  
      BSON::ObjectId('568b28e67db99b1ae8000003')
    ]
  }
},
{  
  "_id"  =>  {  
    "pathname"    =>"/beautybuzz"
  },
  "value"  =>  {  
    "user_data"    =>    [  
      BSON::ObjectId('568b28e67db99b1ae8000003')
    ]
  }
},
{  
  "_id"  =>  {  
    "pathname"    =>"/beautynews"
  },
  "value"  =>  {  
    "user_data"    =>    [  
      BSON::ObjectId('568b28e67db99b1ae8000003')
    ]
  }
}]
```
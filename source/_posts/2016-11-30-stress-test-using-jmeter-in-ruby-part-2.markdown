---
layout: post
title: "Stress Test Using JMeter in Ruby - Part 2"
date: 2016-11-30 15:46:46 +0800
comments: true
categories: ["Ruby on Rails", "Test"] 
keywords: "JMeter, dynamic variable, BeanShell, stress test, ruby-jmeter, ruby"
description: "This tutorial show you how to do stress test with dynamic variable using ruby-jmeter in Ruby"
---

![JMeter](https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/jmeter/intro.png)

> Due to update-to-date JMeter 3.0 require jave 7, but for current offical java support in Mac OSX is 6. So, before running new JMeter you might need to upgrade your java. Please check my [gist](https://gist.github.com/alChaCC/ddb11542c9e6b6683bad80d9ca858bc5) for installation java 7.

This article just show you code example of how to use loop number and thread number in gem `'ruby-jmeter'`.

<!--more-->

Currently, we need to do stress test on your API service. 

That's see how to write codes in different scenarios.

Reference: [http://jmeter.apache.org/usermanual/functions.html](http://jmeter.apache.org/usermanual/functions.html)

[Scenario 1] You want to change request data based on `thread number` 
----

```
test do
  defaults domain: 'YOUR.API.ENDPOINT', portocal: 'https' , port: '443'
  
  header [
    { name: 'Authorization', value: "Bearer 123456789" },
    { name: 'Content-Type', value: 'application/json' }
  ]

  post_body = {
    "order_number": "thread-${__threadNum}"
  }
 
  threads count: 1000, rampup: 1 ,loops: 10, scheduler: false do
      transaction "Shipments" do
        post name: 'Create',
             url: 'https://YOUR.API.ENDPOINT/v1/orders',
             raw_body: post_body.to_json do
               with_xhr
        end
      end
    view_results_tree
  end

  view_results_in_table
  graph_results
  aggregate_graph
  view_results_tree
  summary_report
end.run(
  gui: true,
  file: 'jmeter-order-api.jmx',
  log:  'jmeter-order-api.log',
  jtl:  'results-order-api.jtl'
)
```

[Scenario 2] You want to change request data based on `thread number` and `iteration number` 
----

```
test do
  ...
  
  post_body = {
    "order_number": "thread-${__threadNum}-loop-${__BeanShell(vars.getIteration();,)}"
  }
  
  ...
```

[Scenario 3] You already have data array and you want to use the array element as request data and use `iteration number` as index to get data
----

> use `variables` to set variable array 

> variables accept `[{name: XXX, value: XXX}, {name: XXX, value: XXX}...]`

```
require 'pg'

test do
  ...
  
  conn = PG.connect(dbname:   'DATABASE_STAGING_DBNAME',
                    host:     'DATABASE_STAGING_HOST',
                    user:     'DATABASE_STAGING_USER',
                    password: 'DATABASE_STAGING_PWD'
                   )
  orders = []
  conn.exec( "SELECT * FROM orders where order_state = 'ready'" ) do |result|
    result.each do |row|
      orders << row
    end
  end

  order_index = 0
  post_body_array = orders.inject([]) do |arr, order|
    arr << {
      name: order_index.to_s,
      value: {
        orders: [
          {
            id: order['id'],
            order_state: 'shipped'
          }
        ]
      }.to_json
    }
    order_index += 1
    arr
  end

  variables post_body_array

  threads count: 1, rampup: 1, loops: order_index do
    transaction "Update Order" do
        post name: 'Update',
             url: 'https://YOUR.API.ENDPOINT/v1/orders/update_url',
             raw_body: '${__BeanShell(vars.get("${__BeanShell(vars.getIteration();,)}"))}' do
               with_xhr
             end
    end
    view_results_tree
    debug_sampler
  end
  
  ...
```


[Scenario 4] You already have data array and you want to use the array element as request data and use `thread number` as index to get data
----

```
...

  threads count: order_index, rampup: 1 ,loops: 1 do
    transaction "Update Order" do
        post name: 'Update',
             url: 'https://YOUR.API.ENDPOINT/v1/orders/update_url',
             raw_body: '${__BeanShell(vars.get("${__threadNum}"))}' do
               with_xhr
             end
    end
    view_results_tree
    debug_sampler
  end
  
  ...
```

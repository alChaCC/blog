---
layout: post
title: "Ruby on Rails Development using Mongoid 5.0.0 - 1. Setup MongoDB"
date: 2015-10-03 22:33:34 +0800
comments: true
categories: ["Ruby on Rails", "Mongoid"]
keywords: "Mongoid 5.0.0, MongoDB, Ruby on Rails, Mac OSX, Ubuntu, setup, create user"
description: "this article show you how to setup MongoDB for Ruby on Rails Development such as create users, dump data"
---

<img src="https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/Ruby%20on%20Rails%20Development%20using%20Mongoid%205.0.0%20-%20Setup%20MongoDB/MongoDB-Logo.png" alt="MongoDB">

This tutorial series will help you start your Rails project with MongoDB.

And I use Mongoid 5.0.0 as an example.

In this tutorial, you will be able to see how to 

1. Install MongoDB in Mac OSX

2. Create Some Database Users in MongoDB

3. Setup Rails Projects

(Tips)

4. Dump Data 

5. Restore Data

Let's go !

<!--more-->

## Install MongoDB in Mac OSX

```
# Intall Homebrew (Mac OSX package manager)

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Update the Hombrew packages first

brew update

# Install MongoDB

brew install MongoDB
```

If you want to see where MongoDB is installed

```
brew ls mongodb
```


## Create Some Database Users in MongoDB

Since I want to enable access control on a MongoDB instance, just like Mysql, I have to use username and password to access MongoDB. 

First, you must to know where you can setup MongoDB.

```
# In MacOSX

vim /usr/local/etc/mongod.conf

# In Ubuntu 

vim /etc/mongod.conf
``` 

Second, you have to make sure that authorization is disable.


In MacOSX

```
# /usr/local/etc/mongod.conf

systemLog:
  destination: file
  path: /usr/local/var/log/mongodb/mongo.log
  logAppend: true
storage:
  dbPath: /usr/local/var/mongodb
net:
  bindIp: 127.0.0.1
security:
  authorization: disabled 
```

In Ubuntu 

```
# /etc/mongod.conf

...

noauth = true
...

```

Then (re)start MongoDB 

```
# In Ubuntu
sudo service mongod restart

# In Mac OSX
mongod --config /usr/local/etc/mongod.conf
```

Ok, now you are a super user, you can access any database and perform any action. let's create an administrator named 'siteUserAdmin' and he has "userAdminAnyDatabase" role first.  

```
$ mongo
$ use admin
$ db.createUser(
 {
  user: 'siteUserAdmin',
  pwd: '1234567890',
  roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
 }
)
```

Ok, now we can enable authorization mode.

In MacOSX

```
# vim /usr/local/etc/mongod.conf

systemLog:
  destination: file
  path: /usr/local/var/log/mongodb/mongo.log
  logAppend: true
storage:
  dbPath: /usr/local/var/mongodb
net:
  bindIp: 127.0.0.1
security:
  authorization: enabled 
```

In Ubuntu 

```
# /etc/mongod.conf

...

auth = true
...

```

And don't forgot restart MongoDB.

Then we now have to use user name and password to access database.

```
mongo --host localhost --port 27017 --username siteUserAdmin --password  --authenticationDatabase admin
```

Now, we will create an user  named 'dbadmin' who has 'dbOwner' role.

```
# assume your project will use database: 'your_awesome_project_development'

use your_awesome_project_development

db.createUser(
  {
    user: 'dbadmin',
    pwd: '1234567890',
    roles: [ { role: "dbOwner", db: "your_awesome_project_development" } ]
  }
)
```

if you want to update user's setting.

```
db.updateUser(
  "dbadmin",
  {
    pwd: 'aloha',
    roles: 
    [
      {role: "read", db: "your_awesome_project_development"}
    ]
  }
)
```

if you want to know which roles can perform which  actions, you can find anwser here: 

[http://docs.mongodb.org/master/reference/built-in-roles/#userAdmin](http://docs.mongodb.org/master/reference/built-in-roles/#userAdmin)


## Setup Rails Projects

1. create a project without active-record 

```
rails new your_awesome_project_development --skip-active-record
```
2. add Mongoid to Gemfile

```
# Gemfile

gem 'mongoid', '~> 5.0.0'
```

3. Create a mongoid.yml

```
bundle install
rails g mongoid:config
```

4. Update yout mongoid.yml

```
development:
  clients:
    default:
      database: your_awesome_project_development
      hosts:
        - localhost:27017
      options:
        user: 'dbadmin'
        password: '1234567890'
        roles:
          - 'dbOwner'
test:
  clients:
    default:
      database: your_awesome_project_test
      hosts:
        - localhost:27017
      options:
        max_retries: 1
        retry_interval: 0
        user: 'dbadmin_tester'
        password: '1234567890'
        roles:
          - 'dbOwner'
```

## Dump Data 

Please make sure that you have backup role in production MongoDB.

I use 'readWriteAnyDatabase' role.

Assume that you need to dump data from production data and restore to local mongo server.

```
mongodump --host your.production.mongo.server.ip --port 37017 --username user --password --out /Users/AlohaCC/Desktop/production-mongodump-2015-10-04
```

## Restore Data

Please make sure that you have backup role in local MongoDB.

```
mongorestore --host localhost --port 3017 --username user --password  /Users/AlohaCC/Desktop/production-mongodump-2015-10-04
```
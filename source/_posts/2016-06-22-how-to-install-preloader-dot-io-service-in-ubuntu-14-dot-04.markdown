---
layout: post
title: "How to install Preloader.io service in Ubuntu 14.04"
date: 2016-06-22 17:58:14 +0800
comments: true
categories: ["Preloader.io", "Server"]
keywords: "Preloader, Augular, SEO, Ubuntu, setup, install"
description: "this article show you how to install and setup Preloader server for SEO purpose"
---

If you're finding a solution for SEO especially for AngularJS, BackboneJS, EmberJS and other javascript frameworks. `Preloader` will be one of your options.

> `Preloader` is a node server that uses phantomjs to create static HTML out of a javascript page.

you are able to use their [solutions](https://prerender.io/) instead of installing in your own machine.

But, what if you just like me, want to try their service first and want to customize your own Preloader?

here are flows that show how I install Preloader in Ubuntu 14.04.

<!--more-->

## 1. Create an instance in Amazon Web Service

hmmm, just go to AWS and create an instance using Ubuntu 14.04 image.

make sure you allow port `3000` can be access

## 2. Create a user

```
sudo adduser deploy
sudo adduser deploy sudo
su deploy
```

## 3. Make sure you can login using new user without pem key

```
cd ~
mkdir .ssh
cd .ssh
vim authorized_keys
```
then put the content in `~/.ssh/id_rsa.pub` in your **local machine** into it.

## 4. Install all services

```
sudo locale-gen UTF-8
sudo apt-get update

# Install git
sudo apt-get install git

# Install phantomjs
sudo apt-get install phantomjs

# Install Node.js v6
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone the project
git clone https://github.com/prerender/prerender.git
cd prerender
npm install

# Fix: Fontconfig warning: ignoring UTF-8: not a valid region tag
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8

# Run Node server
node server.js
```

## 5. Now you can try in browser

http://your.ip:3000/https://www.google.com

## 6. Run your Preloader service after restart Machine

```
cd ~/prerender
vim startup.sh
```

Put these lines to the file

```
#!/usr/bin/env bash
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
node /home/deploy/prerender/server.js
```

Allow the script can be excuted

```
chmod +x startup.sh
```

Setup `/etc/init/prerender.conf`

```
sudo vim /etc/init/prerender.conf
```

Put these lines to the file

```
#!upstart
description "A job that runs the prerender service"
author "Deploy"

start on filesystem or runlevel [2345]
script
    export HOME="/home/deploy/prerender"
    cd /home/deploy/prerender
    exec su -c ' /home/deploy/prerender/startup.sh'
end script

pre-start script
    echo "['date'] Prerender Service Starting" >> /var/log/prerender/prerender.log
end script

pre-stop script
    echo "['date'] Prerender Service Stopping" >> /var/log/prerender/prerender.log
end script

respawn
respawn limit 10 90
```

Before start you need to create this folder

```
sudo mkdir /var/log/prerender
```

Now you can

```
sudo service prerender start
```


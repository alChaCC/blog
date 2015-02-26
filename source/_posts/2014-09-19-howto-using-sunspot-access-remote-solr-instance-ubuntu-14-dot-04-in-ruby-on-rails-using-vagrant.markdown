---
layout: post
title: "[HOWTO] Using Sunspot to access remote Solr instance(Ubuntu 14.04) in Ruby on Rails using Vagrant"
date: 2014-09-19 20:16:23 +0800
comments: true
categories: ["Ruby on Rails","Search", "Ubuntu", "Solr", "Vagrant"]
keywords: "solr, sunspot, remote sunspot, remote, vagrant, deploy, ubuntu 14.04, Ruby on Rails, sunspot, 中文, 遠端, 安裝"
description: "Using Sunspot to access remote Solr instance(Ubuntu 14.04) in Ruby on Rails using Vagrant"  
---
 
 首先，當然要感謝網路上一堆大神的資源
 
 特別是：
 
 [Setup Ruby On Rails on
Ubuntu 14.04 Trusty Tahr](https://gorails.com/setup/ubuntu/14.04)

[Deploy Ruby On Rails on
Ubuntu 14.04 Trusty Tahr](https://gorails.com/deploy/ubuntu/14.04)

[How to Install Solr on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-install-solr-on-ubuntu-14-04)

[How To Install and Use Redis](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-redis)

[[教學]使用Vagrant練習環境佈署](http://gogojimmy.net/2013/05/26/vagrant-tutorial/)

[How To Install and Use Memcache on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-memcache-on-ubuntu-14-04)

一開始之前，來說一下，我的目標：


起一台 WEB server 和 Solr server(search engine)，Database則是使用 Mac裡面的 mysql(因為我開發時把DB資料都建在那邊了)，讓這三方彼此co work !


## 心得分享

> 其實本機端的Sunspot他其實也是透過把指令丟給localhost:8983的搜尋引擎做搜尋，現在只是要把丟到localhost:8983換成另外一個遠端的IP。所以，對於Sunspot來說，就是改個config檔。至於做Index的話，我本來以為要讓遠端的搜尋引擎可以access到DB，然後登入到搜尋引擎的機器去設定？。但....根本就不用，一樣，Sunspot已經幫你做掉了，所以基本上，只要你的Rail專案設定的database.yml可以access，Sunspot會自動幫你對應 DB和 遠端的搜尋引擎做index，所以沒有想像中的困難！

了解大概流程概念後，那就來實作吧


## 使用Vagrant，模擬多機器的環境


當然要起很多機器，當然是要使用  **[Vagrant](https://www.vagrantup.com/) + [VirtualBox](https://www.virtualbox.org/)**

那Vagrant的部分，步驟說明就交給Jimmy大大了 [[教學]使用Vagrant練習環境佈署](http://gogojimmy.net/2013/05/26/vagrant-tutorial/)！

和Jimmy大大，不一樣的地方大概就是一些有部分調整的lib和script

這邊直接打我的操作流程：

1. 下載Vagrant，[點我到官網下載連結](http://www.vagrantup.com/downloads)
2. 下載Virtual Box，[點我到官網下載](https://www.virtualbox.org/wiki/Downloads)
3. 抓image

		vagrant box add Ubuntu-14-04-64bit https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box
		
2. 初始化
	
		vagrant init Ubuntu-14-04-64bit
	
3. 	把機器Run起來

		vagrant up 

4. 	登入機器

		vagrant ssh 
	
5. 	安裝Ruby 環境(這邊我有小修一點東西，讓指令跑起來ok)

		 curl -L https://gist.githubusercontent.com/alChaCC/f1295f5024eb4de71008/raw/bee55fd048b274b40095c6e645aa5ca38721fcc2/bootstrap-chef-solo.sh | sh
     

6. 	登出 機器
		
		exit 	

7. 打包這個Box
	
		vagrant package
		
8. 開一個mobile的box

		vagrant box add ubuntu-14_04 package.box

9. 設定Vagrantfile 讓你可一次起N檯機器(2014/9/17這是目前最新的設定)

		vim Vagrantfile
	
加入：

	config.vm.define :app do |app_config|
	      app_config.vm.provider :virtualbox do |vb|
	        vb.customize ["modifyvm", :id, "--name", "app", "--memory", "1024"]
	      end
	      app_config.vm.box = "Ubuntu-14-04-64bit"
	      app_config.vm.host_name = "app"
	      app_config.vm.network "private_network", ip: "33.33.13.10"
	  end
	  
	  config.vm.define :search do |search_config|
	    search_config.vm.provider :virtualbox do |vb|
	        vb.customize ["modifyvm", :id, "--name", "search", "--memory", "1024"]
	    end
	    search_config.vm.box = "Ubuntu-14-04-64bit"
	    search_config.vm.host_name = "search"
	    search_config.vm.network "private_network", ip: "33.33.13.12"
	  end
 

## 安裝機器.....using Chef ....But

照理說這邊應該跟得上時代，使用 chef_solo, knife 來安裝才是....

但...由於時間的關係，實在沒時間玩，你懂得～專案還是要Go啊～ 何況是，我必須在兩天之內試出東西

Anyway, 傻人只好用傻方法



## 安裝 Rails 環境 在app機器上

Ruby 2.1.2  + rvm 

1. 登入
	
		vagrant ssh app
	
2. 加上 user 

		sudo adduser deploy
		sudo adduser deploy sudo
		su deploy
	
3. 
	
2. 安裝基本lib

		sudo apt-get update
		sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties

3. 安裝rvm

		sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
		curl -L https://get.rvm.io | bash -s stable
		source ~/.rvm/scripts/rvm
		echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
		rvm install 2.1.2
		rvm use 2.1.2 --default
		ruby -v
		echo "gem: --no-ri --no-rdoc" > ~/.gemrc

4. 安裝Rails 

		sudo add-apt-repository ppa:chris-lea/node.js
		sudo apt-get update
		sudo apt-get install nodejs
		gem install rails

5. 安裝  nginx + Passenger

		sudo apt-get install apt-transport-https
		sudo sh -c "echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' >> /etc/apt/sources.list.d/passenger.list"
		sudo chown root: /etc/apt/sources.list.d/passenger.list
		sudo chmod 600 /etc/apt/sources.list.d/passenger.list
		sudo apt-get update
		sudo apt-get install nginx-full passenger
	
6. 修改 nginx 檔案

		sudo vim /etc/nginx/nginx.conf
	
	加上
	
		passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
        passenger_ruby /home/deploy/.rvm/wrappers/ruby-2.1.2/ruby;

7. 修改 Nginx Host

		sudo vim /etc/nginx/sites-enabled/default
	
	改上
	
		server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        root /home/deploy/我的資料夾名稱/current/public;
        # index index.html index.htm;
        rails_env production;
        passenger_enabled on;
        # Make site accessible from http://localhost/
        server_name 33.33.13.10; # 這邊我讓他跟vagrant機器ip一樣

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

8. 安裝Redis

		sudo apt-get install tcl8.5
		wget http://download.redis.io/releases/redis-2.8.9.tar.gz
		tar xzf redis-2.8.9.tar.gz
		cd redis-2.8.9
		make
		make test
		sudo make install
		cd utils
		sudo ./install_server.sh
		
		
9. Install memcached
	
		sudo apt-get install mysql-server php5-mysql php5 php5-memcached memcached
		sudo service memcached start
	
10. 安裝mysql


		sudo apt-get install mysql-server mysql-client libmysqlclient-dev



## 安裝 Solr 環境 在search機器上

我使用tomcat 安裝會有問題(**missing core name in path**)....所以我最後手動安裝


1. 安裝 java

		sudo apt-get -y install openjdk-7-jdk
		mkdir /usr/java
		ln -s /usr/lib/jvm/java-7-openjdk-amd64 /usr/java/default

2. 安裝Solr

		cd /opt
		wget http://archive.apache.org/dist/lucene/solr/4.7.2/solr-4.7.2.tgz
		tar -xvf solr-4.7.2.tgz
		cp -R solr-4.7.2/example /opt/solr
		cd /opt/solr
		java -jar start.jar

3. 編輯 jetty

		sudo vim /etc/default/jetty 

	加入
		
		NO_START=0 # Start on boot
		JAVA_OPTIONS="-Dsolr.solr.home=/opt/solr/solr $JAVA_OPTIONS"
		JAVA_HOME=/usr/java/default
		JETTY_HOME=/opt/solr
		JETTY_USER=solr
		JETTY_LOGS=/opt/solr/logs

	下指令
	
		vim /opt/solr/etc/jetty-logging.xml
	
	加入
	
		<?xml version="1.0"?>
		  <!DOCTYPE Configure PUBLIC "-//Mort Bay Consulting//DTD Configure//EN" "http://jetty.mortbay.org/configure.dtd">
		  <!-- =============================================================== -->
		  <!-- Configure stderr and stdout to a Jetty rollover log file -->
		  <!-- this configuration file should be used in combination with -->
		  <!-- other configuration files.  e.g. -->
		  <!--    java -jar start.jar etc/jetty-logging.xml etc/jetty.xml -->
		  <!-- =============================================================== -->
		  <Configure id="Server" class="org.mortbay.jetty.Server">
		
		      <New id="ServerLog" class="java.io.PrintStream">
		        <Arg>
		          <New class="org.mortbay.util.RolloverFileOutputStream">
		            <Arg><SystemProperty name="jetty.logs" default="."/>/yyyy_mm_dd.stderrout.log</Arg>
		            <Arg type="boolean">false</Arg>
		            <Arg type="int">90</Arg>
		            <Arg><Call class="java.util.TimeZone" name="getTimeZone"><Arg>GMT</Arg></Call></Arg>
		            <Get id="ServerLogName" name="datedFilename"/>
		          </New>
		        </Arg>
		      </New>
		
		      <Call class="org.mortbay.log.Log" name="info"><Arg>Redirecting stderr/stdout to <Ref id="ServerLogName"/></Arg></Call>
		      <Call class="java.lang.System" name="setErr"><Arg><Ref id="ServerLog"/></Arg></Call>
		      <Call class="java.lang.System" name="setOut"><Arg><Ref id="ServerLog"/></Arg></Call></Configure>

4. 加上 User: solr

		sudo useradd -d /opt/solr -s /sbin/false solr
		sudo chown solr:solr -R /opt/solr

5. 安裝 jetty

		sudo wget -O /etc/init.d/jetty http://dev.eclipse.org/svnroot/rt/org.eclipse.jetty/jetty/trunk/jetty-distribution/src/main/resources/bin/jetty.sh
		sudo chmod a+x /etc/init.d/jetty
		sudo update-rc.d jetty defaults

6. 跑起來

		sudo /etc/init.d/jetty start

7. 設定檔

		cd /opt/solr/solr

8. 把在sunspot改好的schema.xml 寫到這邊


		vim /opt/solr/solr/collection1/conf/schema.xml
		

	寫上下面那些，因為我要支援中文字詞，所以我有改過一些
	
	下面這個很重要，如果不改的話，會有連線內容錯誤之類的訊息
	
		<?xml version="1.0" encoding="UTF-8"?>
		<!--
		 Licensed to the Apache Software Foundation (ASF) under one or more
		 contributor license agreements.  See the NOTICE file distributed with
		 this work for additional information regarding copyright ownership.
		 The ASF licenses this file to You under the Apache License, Version 2.0
		 (the "License"); you may not use this file except in compliance with
		 the License.  You may obtain a copy of the License at
		
		     http://www.apache.org/licenses/LICENSE-2.0
		
		 Unless required by applicable law or agreed to in writing, software
		 distributed under the License is distributed on an "AS IS" BASIS,
		 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		 See the License for the specific language governing permissions and
		 limitations under the License.
		-->
		<!--  
		 This is the Solr schema file. This file should be named "schema.xml" and
		 should be in the conf directory under the solr home
		 (i.e. ./solr/conf/schema.xml by default) 
		 or located where the classloader for the Solr webapp can find it.
		
		 This example schema is the recommended starting point for users.
		 It should be kept correct and concise, usable out-of-the-box.
		
		 For more information, on how to customize this file, please see
		 http://wiki.apache.org/solr/SchemaXml
		
		 PERFORMANCE NOTE: this schema includes many optional features and should not
		 be used for benchmarking.  To improve performance one could
		  - set stored="false" for all fields possible (esp large fields) when you
		    only need to search on the field but don't need to return the original
		    value.
		  - set indexed="false" if you don't need to search on the field, but only
		    return the field as a result of searching on other indexed fields.
		  - remove all unneeded copyField statements
		  - for best index size and searching performance, set "index" to false
		    for all general text fields, use copyField to copy them to the
		    catchall "text" field, and use that for searching.
		  - For maximum indexing performance, use the StreamingUpdateSolrServer
		    java client.
		  - Remember to run the JVM in server mode, and use a higher logging level
		    that avoids logging every request
		-->
		<schema name="sunspot" version="1.0">
		  <types>
		    <!-- field type definitions. The "name" attribute is
		       just a label to be used by field definitions.  The "class"
		       attribute and any other attributes determine the real
		       behavior of the fieldType.
		         Class names starting with "solr" refer to java classes in the
		       org.apache.solr.analysis package.
		    -->
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="string" class="solr.StrField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="tdouble" class="solr.TrieDoubleField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="rand" class="solr.RandomSortField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="text" class="solr.TextField" omitNorms="false">
		      <analyzer>
		        <tokenizer class="solr.CJKTokenizerFactory"/>
		        <filter class="solr.StandardFilterFactory"/>
		        <filter class="solr.LowerCaseFilterFactory"/>
		        <filter class="solr.PorterStemFilterFactory"/>
		        <filter class="solr.NGramFilterFactory" minGramSize="2" maxGramSize="15"/>
		      </analyzer>
		
		      <analyzer type="query">
		        <tokenizer class="solr.CJKTokenizerFactory"/>
		        <filter class="solr.StandardFilterFactory"/>
		        <filter class="solr.LowerCaseFilterFactory"/>
		      </analyzer>
		
		    </fieldType>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="boolean" class="solr.BoolField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="date" class="solr.DateField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="sdouble" class="solr.SortableDoubleField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="sfloat" class="solr.SortableFloatField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="sint" class="solr.SortableIntField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="slong" class="solr.SortableLongField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="tint" class="solr.TrieIntField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="tfloat" class="solr.TrieFloatField" omitNorms="true"/>
		    <!-- *** This fieldType is used by Sunspot! *** -->
		    <fieldType name="tdate" class="solr.TrieDateField" omitNorms="true"/>
		
		    <!-- A specialized field for geospatial search. If indexed, this fieldType must not be multivalued. -->
		    <fieldType name="location" class="solr.LatLonType" subFieldSuffix="_coordinate"/>
		  </types>
		  <fields>
		    <!-- Valid attributes for fields:
		     name: mandatory - the name for the field
		     type: mandatory - the name of a previously defined type from the
		       <types> section
		     indexed: true if this field should be indexed (searchable or sortable)
		     stored: true if this field should be retrievable
		     compressed: [false] if this field should be stored using gzip compression
		       (this will only apply if the field type is compressable; among
		       the standard field types, only TextField and StrField are)
		     multiValued: true if this field may contain multiple values per document
		     omitNorms: (expert) set to true to omit the norms associated with
		       this field (this disables length normalization and index-time
		       boosting for the field, and saves some memory).  Only full-text
		       fields or fields that need an index-time boost need norms.
		     termVectors: [false] set to true to store the term vector for a
		       given field.
		       When using MoreLikeThis, fields used for similarity should be
		       stored for best performance.
		     termPositions: Store position information with the term vector.  
		       This will increase storage costs.
		     termOffsets: Store offset information with the term vector. This 
		       will increase storage costs.
		     default: a value that should be used if no value is specified
		       when adding a document.
		   -->
		    <!-- *** This field is used by Sunspot! *** -->
		    <field name="id" stored="true" type="string" multiValued="false" indexed="true"/>
		    <!-- *** This field is used by Sunspot! *** -->
		    <field name="type" stored="false" type="string" multiValued="true" indexed="true"/>
		    <!-- *** This field is used by Sunspot! *** -->
		    <field name="class_name" stored="false" type="string" multiValued="false" indexed="true"/>
		    <!-- *** This field is used by Sunspot! *** -->
		    <field name="text" stored="false" type="string" multiValued="true" indexed="true"/>
		    <!-- *** This field is used by Sunspot! *** -->
		    <field name="lat" stored="true" type="tdouble" multiValued="false" indexed="true"/>
		    <!-- *** This field is used by Sunspot! *** -->
		    <field name="lng" stored="true" type="tdouble" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="random_*" stored="false" type="rand" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="_local*" stored="false" type="tdouble" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_text" stored="false" type="text" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_texts" stored="true" type="text" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_b" stored="false" type="boolean" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_bm" stored="false" type="boolean" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_bs" stored="true" type="boolean" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_bms" stored="true" type="boolean" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_d" stored="false" type="date" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_dm" stored="false" type="date" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_ds" stored="true" type="date" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_dms" stored="true" type="date" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_e" stored="false" type="sdouble" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_em" stored="false" type="sdouble" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_es" stored="true" type="sdouble" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_ems" stored="true" type="sdouble" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_f" stored="false" type="sfloat" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_fm" stored="false" type="sfloat" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_fs" stored="true" type="sfloat" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_fms" stored="true" type="sfloat" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_i" stored="false" type="sint" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_im" stored="false" type="sint" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_is" stored="true" type="sint" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_ims" stored="true" type="sint" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_l" stored="false" type="slong" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_lm" stored="false" type="slong" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_ls" stored="true" type="slong" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_lms" stored="true" type="slong" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_s" stored="false" type="string" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_sm" stored="false" type="string" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_ss" stored="true" type="string" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_sms" stored="true" type="string" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_it" stored="false" type="tint" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_itm" stored="false" type="tint" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_its" stored="true" type="tint" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_itms" stored="true" type="tint" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_ft" stored="false" type="tfloat" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_ftm" stored="false" type="tfloat" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_fts" stored="true" type="tfloat" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_ftms" stored="true" type="tfloat" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_dt" stored="false" type="tdate" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_dtm" stored="false" type="tdate" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_dts" stored="true" type="tdate" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_dtms" stored="true" type="tdate" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_textv" stored="false" termVectors="true" type="text" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_textsv" stored="true" termVectors="true" type="text" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_et" stored="false" termVectors="true" type="tdouble" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_etm" stored="false" termVectors="true" type="tdouble" multiValued="true" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_ets" stored="true" termVectors="true" type="tdouble" multiValued="false" indexed="true"/>
		    <!-- *** This dynamicField is used by Sunspot! *** -->
		    <dynamicField name="*_etms" stored="true" termVectors="true" type="tdouble" multiValued="true" indexed="true"/>
		
		    <!-- Type used to index the lat and lon components for the "location" FieldType -->
		    <dynamicField name="*_coordinate"  type="tdouble" indexed="true"  stored="false" multiValued="false"/>
		    <dynamicField name="*_p" type="location" indexed="true" stored="true" multiValued="false"/>
		
		    <dynamicField name="*_ll" stored="false" type="location" multiValued="false" indexed="true"/>
		    <dynamicField name="*_llm" stored="false" type="location" multiValued="true" indexed="true"/>
		    <dynamicField name="*_lls" stored="true" type="location" multiValued="false" indexed="true"/>
		    <dynamicField name="*_llms" stored="true" type="location" multiValued="true" indexed="true"/>
		    
		    <!-- required by Solr 4 -->
		    <field name="_version_" type="string" indexed="true" stored="true" multiValued="false" />
		  </fields>
		  
		  <!-- Field to use to determine and enforce document uniqueness.
		      Unless this field is marked with required="false", it will be a required field
		   -->
		  <uniqueKey>id</uniqueKey>
		  <!-- field for the QueryParser to use when an explicit fieldname is absent -->
		  <defaultSearchField>text</defaultSearchField>
		  <!-- SolrQueryParser configuration: defaultOperator="AND|OR" -->
		  <solrQueryParser defaultOperator="AND"/>
		  <!-- copyField commands copy one field to another at the time a document
		        is added to the index.  It's used either to index the same field differently,
		        or to add multiple fields to the same field for easier/faster searching.  -->
		</schema>

	
			

9. 改好別忘重啟

		sudo /etc/init.d/jetty restart

10. 但是....目前不是用Chef安裝環境....所以如果要改config檔，就是要到這個地方去修改

	**/opt/solr/solr/collection1/conf**
	


##  專案上的程式碼

1. 基本上，專案什麼都不用動，因為Sunspot都幫你做掉了

你只需要改 **config/sunspot.yml**

原先的設定：

	production:
	  solr:
	    hostname: localhost
	    port: 8983
	    log_level: INFO
	    path: /solr/production
	    # read_timeout: 2
	    # open_timeout: 0.5
	
	development:
	  solr:
	    hostname: localhost
	    port: 8982
	    log_level: INFO
	    path: /solr/development
	    
	
	test:
	  solr:
	    hostname: localhost
	    port: 8981
	    log_level: WARNING
	    path: /solr/test
    
    
 把它改成：
 
 
	 production:
	  solr:
	    hostname: 33.33.13.12
	    port: 8983
	    log_level: INFO
	    path: /solr
	    # read_timeout: 2
	    # open_timeout: 0.5
	
	development:
	  solr:
	    hostname: localhost
	    port: 8982
	    log_level: INFO
	    path: /solr/development
	    
	
	test:
	  solr:
	    hostname: localhost
	    port: 8981
	    log_level: WARNING
	    path: /solr/test
	    
恭喜完成！


## Capistrano Deployment 


如果你參考我的 Sunspot本機端 Deploy的話，

我試過幾種方法，試著讓app機器，可以去search機器 開關solr....(
	
	sudo /etc/init.d/jetty start

但是小弟對於Capistrano才疏學淺，實在無法達成

所以我的Deploy Code就先把 solr:start 和 solr:stop 先拿掉

所以原先，我是這樣寫的

**/lib/capistrano/taks/sunspot.cap**

	namespace :deploy do
	  before :updated, :setup_solr_data_dir do
	    on roles(:app) do
	      unless test "[ -d #{shared_path}/solr/data ]"
	        execute :mkdir, "-p #{shared_path}/solr/data"
	      end
	    end
	  end
	end
	 
	namespace :solr do
	  
	  %w[start stop].each do |command|
	    desc "#{command} solr"
	    task command do
	      on roles(:app) do
	        solr_pid = "#{shared_path}/pids/sunspot-solr.pid"
	        if command == "start" or (test "[ -f #{solr_pid} ]" and test "kill -0 $( cat #{solr_pid} )")
	          within current_path do
	            with rails_env: fetch(:rails_env, 'production') do
	              execute :bundle, 'exec', 'sunspot-solr', command, "--port=8983 --data-directory=#{shared_path}/solr/data --pid-dir=#{shared_path}/pids --solr-home=#{release_path}/solr"
	            end
	          end
	        end
	      end
	    end
	  end
	  
	  desc "reindex solr"
	  task :restart do
	    invoke 'solr:reindex'
	  end
	  
	  after 'deploy:finished', 'solr:restart'
	  
	  desc "reindex the whole solr database"
	  
	  task :reindex do
	    invoke 'solr:stop' 
	    on roles(:app) do
	      execute :rm, "-rf #{shared_path}/solr/data"
	    end
	    invoke 'solr:start'
	    sleep 10
	    on roles(:app) do
	      within current_path do
	        with rails_env: fetch(:rails_env, 'production') do
	          info "Reindexing Solr database"
	          execute :bundle, 'exec', :rake, 'sunspot:solr:reindex[,,true]'
	        end
	      end
	    end
	  end
	  
	end


現在變成：

	namespace :deploy do
	  before :updated, :setup_solr_data_dir do
	    on roles(:app) do
	      unless test "[ -d #{shared_path}/solr/data ]"
	        execute :mkdir, "-p #{shared_path}/solr/data"
	      end
	    end
	  end
	end
	 
	namespace :solr do
	  
	  %w[start stop].each do |command|
	    desc "#{command} solr"
	    task command do
	      on roles(:app) do
	        solr_pid = "#{shared_path}/pids/sunspot-solr.pid"
	        if command == "start" or (test "[ -f #{solr_pid} ]" and test "kill -0 $( cat #{solr_pid} )")
	          within current_path do
	            with rails_env: fetch(:rails_env, 'production') do
	              execute :bundle, 'exec', 'sunspot-solr', command, "--port=8983 --data-directory=#{shared_path}/solr/data --pid-dir=#{shared_path}/pids --solr-home=#{release_path}/solr" # 就算加上 --bind-address=33.33.13.12  也在在本機端跑
	            end
	          end
	        end
	      end
	
	      #  嘗試直接從本機去重開 search機器，但是都不work，找解答ing
	      #on %w{apps@33.33.13.12} do |host|
	      #    as 'apps' do
	      #      execute "sudo /etc/init.d/jetty #{command}"
	      #    end
	      #end
	    end
	  end
	  
	  desc "reindex solr"
	  task :restart do
	    invoke 'solr:reindex'
	  end
	  
	  after 'deploy:finished', 'solr:restart'
	  
	  desc "reindex the whole solr database"
	  
	  task :reindex do
	    #invoke 'solr:stop' #這指令是操控本機的solr
	    on roles(:app) do
	      execute :rm, "-rf #{shared_path}/solr/data"
	    end
	    #invoke 'solr:start' #這指令是操控本機的solr
	    sleep 10
	    on roles(:app) do
	      within current_path do
	        with rails_env: fetch(:rails_env, 'production') do
	          info "Reindexing Solr database"
	          execute :bundle, 'exec', :rake, 'sunspot:solr:reindex[,,true]'
	        end
	      end
	    end
	  end
	  
	end

## 恭喜完成！



###ps. 如果你想要讓在vagrant裡頭app可以存取Mac裡頭的DB

請把把 host改成 10.0.2.2

	host: 10.0.2.2

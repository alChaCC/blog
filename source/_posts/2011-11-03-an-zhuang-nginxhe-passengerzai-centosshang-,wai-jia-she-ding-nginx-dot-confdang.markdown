---
layout: post
title: "安裝nginx和passenger在CentOS上，外加設定nginx.conf檔，讓你掛上Octopress和php"
date: 2011-11-03 23:56
comments: true
categories: [Linux, Nginx, Octopress, SSH]
---

a. 首先安裝流程就參考[xdite這篇rails-nginx-passenger-centos][1]

幾乎都是一樣的只不過

我有兩個需求

  a. 我想要把首頁連到Octopress

因為我也有使用[網中人netman大大的ssh安全技巧][2]

來設定我自己server的ssh安全控管

  b. 我必須要讓nginx可以執行php

<!--more--> 

我想最主要會遇到的問題，就是為甚麼我本機端連的到但是外面就是連不到

我遇到的狀況其實都是Selinux權限的問題！

最後我怎麼解決呢....可以看到我的conf檔

我最後就是用比較笨的方法就是把octopress安裝在nginx這個user的家目錄下

以下這是我醜陋的/opt/nginx/conf/nginx.conf檔，不過看起來是可行～大家可以參考看看

{% codeblock lang:ruby %}

user  nginx nginx;
worker_processes  1;

events {
    worker_connections  1024;
       }


http {
    passenger_root /usr/local/lib/ruby/gems/1.8/gems/passenger-3.0.9;
    passenger_ruby /usr/local/bin/ruby;

    include       mime.types;
    default_type  application/octet-stream;


    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;
    server {
        listen       80;
        server_name  ccaloha.cc;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;
        # 這邊是因為我ccaloha.cc的網站是架於octopress的blog，所以我的root直接設在octopress的位置下
        location / {
            root   /home/nginx/octopress/public;
            index  index.html index.htm index.php;
        }
	

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

	#這邊是因為我有設定php檔 讓使用者ssh取得進來的權限
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        location ~ \.php$ {
            root           放php檔的絕對路徑例如：/html/sshlogin;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            include        fastcgi_params;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        }
    }
}

{% endcodeblock %}

[1]: https://github.com/xdite/rails-nginx-passenger-centos 	"xdite"
[2]: http://www.study-area.org/tips/ssh_tips.htm    		"netman"

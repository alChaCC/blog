---
layout: post
title: "HOWTO- 公司需要CEO, Blog也需要SEO！- using octopress"
date: 2014-03-07 10:32:20 +0800
comments: true
categories: SEO
keywords:  "SEO, octopress, Taiwan, Chinese, 中文"
description: "SEO for Octopress"
---

這篇其實是學習(翻譯)自
<http://xit0.org/2013/05/seo-for-octopress-websites>

## 第一步- 文章SEO: 更改你Octopress產生文章引擎的 Rakefile

    desc "Begin a new post in #{source_dir}/#{posts_dir}"
    task :new_post, :title do |t, args|
      if args.title
        title = args.title
      else
        title = get_stdin("Enter a title for your post: ")
      end
      raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
      mkdir_p "#{source_dir}/#{posts_dir}"
      filename = "#{source_dir}/#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
      if File.exist?(filename)
        abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end
      puts "Creating new post: #{filename}"
      open(filename, 'w') do |post|
        post.puts "---"
        post.puts "layout: post"
        post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
        post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
        post.puts "comments: true"
        post.puts "categories: "
        post.puts "keywords: "      # 加在這邊
        post.puts "description: "   # 加在這邊
        post.puts "---"
      end
    end

<!-- more -->

所以每篇文章那邊，你就可以這樣寫

    ---
    layout: post
    title: "SEO for Octopress Websites"
    date: 2014-03-07 12:00
    comments: true
    categories: ["octopress", "seo"]
    keywords: "keyword, for, this, post"
    description: "Description for this post"
    ---


## 第二步 - 網站SEO:  編輯你的_config.yml檔 

    url: http://yoursite.com
    title: My Octopress Blog
    subtitle: A blogging framework for hackers.
    author: Your Name
    simple_search: http://google.com/search

    description: "Description for the website"   #加在這邊
    keywords: "keywords, for, the, website"      #加在這邊




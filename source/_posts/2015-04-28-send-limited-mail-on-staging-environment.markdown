---
layout: post
title: "[Ruby on Rails] Send limited mail on staging environment"
date: 2015-04-28 17:16:33 +0800
comments: true
categories: ["Ruby on Rails"] 
keywords: "staging, Ruby on Rails, howto, mail, interceptor, actionmailer, settingslogic"
description: "this article show you how to avoid sending mail to real user on staging server"
---

For simulating production environment, we will build up a stage machine.

Plus, we usually use the copy of production database in stage server. 

In some applications, we will send email to users for some purposes such as confirmation mail after user 

register, reset password mail...etc. 

And, in staging environment, we have to avoid our operators accidentally send email to real users.

Therefore, we have to implement some codes for filtering.

Let's go 

<!-- more -->


According to [Action Mailer Basics](http://edgeguides.rubyonrails.org/action_mailer_basics.html#intercepting-emails), we can register an interceptor to avoid some unexpected actions.

And my requirement is I want staging server can send mail to our employees. In our case, our company mail address is **xxx@itrue.com.tw**. So, we have to implement code that only allow email server send to users like: **XXX@itrue.com.tw**. 

## Step1. *Gemfile*

    gem 'settingslogic'

## Step2. Add a lib on *app/lib/settings.rb*


    class Settings < Settingslogic
        source "#{Rails.root}/config/application.yml"
        namespace Rails.env
    end
  

## Step3. Add your white list on *application.yml*

    defaults: &defaults
      allowed_send_mail_domain: '@itrue.com.tw'
     
    development:
      <<: *defaults

    test:
      <<: *defaults

    production:
      <<: *defaults

## Step4. Write a interceptor on *app/interceptor/staging_mail_interceptor.rb*

ref: [Filtering emails on staging](http://renderedtext.com/blog/2012/04/27/filtering-emails-on-staging/)

    class StagingMailInterceptor

      def self.delivering_email(message)
        message.to = extract_allowed_recepients(message)
        message.perform_deliveries = false if message.to.empty?
      end

      private

      def self.extract_allowed_recepients(message)
        message.to.select { |address| allowed_address?(address) }
      end

      def self.allowed_address?(address)
        allowed_domains = Settings.allowed_send_mail_domain.split(',')

        matches_allowed = allowed_domains.count { |domain| address.include?(domain) }

        matches_allowed != 0
      end

    end
  

## Step5. Register interceptor to ActionMailer on *app/config/initializers/sandbox_email_interceptor.rb*


    require 'staging_mail_interceptor'

    if Rails.env.staging?
      ActionMailer::Base.register_interceptor(StagingMailInterceptor)
    end

## Done

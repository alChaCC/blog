---
layout: post
title: "HOWTO:Install CoffeeScirpt in MacOSX(and use textmate)"
date: 2012-04-22 23:08
comments: true
categories: CoffeeScript
---

#安裝CoffeesSript in Your Mac OSX

1.Install Node.js

GO TO [Node.js](http://nodejs.org/)

Click **"Download"**  

Install it . 

<!--more-->

2.Install npm
	
		curl http://npmjs.org/install.sh | sudo sh
	

3.Install CoffeeScript

		sudo npm install -g coffee-script

4.If You use Textmate , you can install textmate bundle. Using "command+B" preview your code.
	
	which node
	/usr/bin/node

	which coffee
	/usr/bin/coffee

	cd /usr/bin
	sudo ln -s /usr/bin/node
	sudo ln -s /usr/bin/coffee

	mkdir -p ~/Library/Application\ Support/TextMate/Bundles
	
	cd ~/Library/Application\ Support/TextMate/Bundles
	git clone git://github.com/jashkenas/coffee-script-tmbundle CoffeeScript.tmbundle
	

 



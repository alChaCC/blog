---
layout: post
title: "搞搞 Sikuli 在你的 Ubuntu"
date: 2011-12-17 19:41
comments: true
categories: [Linux , Sikuli]
---

**安裝**
一開始我看官網，我以為只要一行指令碼就ＯＫ了～

誰知道…試了超久，問題還是沒有解決，例如要灌openCV啦、python版本太舊啦…等等

但是我想如果之後有更新的話，下面那行應該就灌好了～(所以我還是保留一下)

	apt-get install sikuli-ide  

另外一個方法，也是我現在在用的方法！

<!--more--> 

其實只要先安裝
	
	sudo apt-get wmctrl
	
	sudo apt-get xdotool

**直接來操作**

之後下載source code (Sikuli X-1.0rc3(r905))來用

	wget http://launchpad.net/sikuli/sikuli-x/x1.0-rc3/+download/Sikuli-X-1.0rc3%20%28r905%29-linux-x86_64.zip

	unzip XXX.zip

可以先用下面的指令開啓ide來編寫程式

	PATH-TO-SIKULI-FOLDER/sikuli-ide.sh 

要執行的話，指令這樣下
	
	PATH-TO-SIKULI-FOLDER/sikuli-ide.sh -r 你的sikuli程式資料夾


恭喜你～踏出自動化的一步～

TODO: Link to RobotFrameWork

>=================參考，說不定有用================

我因為參考下面的東東 我在東試西試時，下過這些指令

	apt-get install build-essential

	apt-get install cmake

	apt-get install pkg-config

	apt-get install libpng12-0 libpng12-dev libpng++-dev libpng3

	apt-get install libpnglite-dev libpngwriter0-dev libpngwriter0c2

	apt-get install zlib1g-dbg zlib1g zlib1g-dev

	apt-get install libjasper-dev libjasper-runtime libjasper1

	apt-get install pngtools libtiff4-dev libtiff4 libtiffxx0c2 libtiff-tools

	apt-get install libjpeg8 libjpeg8-dev libjpeg8-dbg libjpeg-prog

	apt-get install ffmpeg libavcodec-dev libavcodec52 libavformat52 libavformat-dev

	apt-get install libgstreamer0.10-0-dbg libgstreamer0.10-0  libgstreamer0.10-dev

	apt-get install libxine1-ffmpeg  libxine-dev libxine1-bin

	apt-get install libunicap2 libunicap2-dev

	apt-get install libdc1394-22-dev libdc1394-22 libdc1394-utils

	apt-get install swig

	apt-get install libv4l-0 libv4l-dev

	apt-get install python-numpy
	
	apt-get install libcvaux-dev

>＝＝＝＝＝＝＝＝＝＝＝＝以下就是我參考的東東＝＝＝＝＝＝＝＝＝＝＝＝

[How to run Sikuli from Command Line](http://sikuli.org/docx/faq/010-command-line.html)
     
[install OpenCV 2.1 in Ubuntu](http://www.samontab.com/web/2010/04/installing-opencv-2-1-in-ubuntu/)


[Building Large-scale Testing framework Using Sikuli](https://answers.launchpad.net/sikuli/+faq/1110)

[OpenCV Installation Guide on Debian and Ubuntu](http://opencv.willowgarage.com/wiki/InstallGuide%20%3A%20Debian)

[Sikuli+RobotFramework集成](http://www.51testing.com/?uid-49689-action-spacelist-type-blog-itemtypeid-19557)

[HOW TO INSTALL OPENCV 2.3.1 IN UBUNTU 11.10 ONEIRIC OCELOT WITH PYTHON SUPPORT](http://thebitbangtheory.wordpress.com/2011/10/23/how-to-install-opencv-2-3-1-in-ubuntu-11-10-oneiric-ocelot-with-python-support/)

[之前遇到的問題1](https://answers.launchpad.net/sikuli/+question/139540)

[之前遇到問題2](https://bugs.launchpad.net/ubuntu/+source/sikuli/+bug/829757)

---
layout: post
title: "HOW-TO: Using Sikuli and RobotFramework in Linux Platform "
date: 2012-01-05 13:38
comments: true
categories: [Linux , Sikuli , RobotFramework] 
---


>首先，你必須先看過這篇文章 抓好 Sikuli [搞搞 Sikuli 在你的 Ubuntu](http://ccaloha.cc/blog/2011/12/17/install-sikuli-in-ubuntu/) 


**我會使用 windows RDP, 作為一個範例,在這之前,請先確保你的linux可以使用 # rdesktop**


>以下為我的簡單感想 , 在robot framework底下使用sikuli , 就是使用一個擴充的library
<!--more--> 

##目標 使用Sikuli，遠端登入到window桌面，進行format volume的動作

1. 使用sikuli ide 把要點選的照片拍下來 (我個人覺得這個很費工....囧)

		sh /你的sikuli路徑/sikuli-ide.ti

2. 建立個資料夾吧
	
		mkdir RobotSikuli

2.  把剛剛拍的照片放到winFormatImage裡
	
		cd RobotSikuli
		mkdir winFormatImage
		mv 你剛剛用sikuli拍的照片檔路徑 winFormatImage	
3. 開始撰寫你的library (因為要run在不同的三種window版本，所以寫得比較麻煩…科科)
		
		cd ..
		cd RobotSikuli
		mkdir WindowRDPFormatLibrary
		vim Format.py

**python程式碼如下(這是小弟第一次寫python,請見諒)**

		#coding=utf-8
		from __future__ import with_statement
		from sikuli.Sikuli import *

		addImagePath("winFormatImage")

	"""
	1. 在python2.6中，with正式成為了關鍵字所以在python2.5以前,要利用with的話,需要使用:Python代碼from __future__ import with_statement 
	from __future__ import with_statement 它的原理如下:所有實現上下文協議的對像都包含以下三種方法:__context__()它返回一個自我管理的上下文對象
	或者一個真正意義的上下文管理器__enter()__進入上下文管理器,開始迭代當with語句結束的時候,無論是正常結束還是拋出異常,都會執行__exit__(),該方法用於關閉資源連接
	2. Your project is created. Add at least one you-name-it.py file to the source folder and put from sikuli.Sikuli import * as the first line.

	"""
	__version__ = '0.1'

	class VolumeFormat(object):
		ROBOT_LIBRARY_SCOPE = 'GLOBAL'
		ROBOT_LIBRARY_VERSION = __version__

	def __init__(self, platform):
		
		self.start_pictures = {'win2003' : "start2003.png" , 'winxp' : "startxp.png" , 'win2008' : "start2008.png"}
		self.start_picture = self.start_pictures[platform]
		
		self.control_panels = {'win2003' : "control_panel_2003.png" , "winxp" : "control_panel_xp.png" , 'win2008' : "control_panel_2008.png"}
		self.control_panel  = self.control_panels[platform]
		
		self.administrator_tools = {'win2003' : "administrator_tool2003.png" , 'winxp' : "administrator_toolxp.png" , 'win2008' : "administrator_tool2008.png"}
		self.administrator_tool = self.administrator_tools[platform]
		
		self.computer_managements = {'win2003' : "computer_management2003.png" , 'winxp' : "computer_managementxp.png" , 'win2008' : "computer_management2008.png"}
		self.computer_management = self.computer_managements[platform]
		
		self.disk_management =  {'win2003' : "disk_management2003.png" , 'winxp' : "disk_managementxp.png" , 'win2008' : "disk_management2008.png"} 
		self.disk_management = self.disk_management[platform]
		
		self.full_screens = {'win2003' : "full_screen2003.png" , 'winxp' : "full_screenxp.png" , 'win2008' : "full_screen2008.png"}
		self.full_screen = self.full_screens[platform]
		
		self.disk_unknowns = {'win2003' : "disk_unknown2003.png" , 'winxp' : "disk_unknownxp.png" , 'win2008' : "disk_unknown2008.png"}
		self.disk_unknown = self.disk_unknowns[platform]
		
		self.initial_disks = {'win2003' : "initial_disk2003.png" , 'winxp' : "initial_diskxp.png" , 'win2008' : "initial_disk2008.png"}
		self.initial_disk = self.initial_disks[platform]
		
		self.oks = {'win2003' : "ok2003.png" , 'winxp' : "okxp.png" , 'win2008' : "ok2008.png"}
		self.ok	= self.oks[platform]
		
		self.link_volumes = {'win2003' : "link_vol2003.png" , 'winxp' : "link_volxp.png" , 'win2008' : "link_vol2008.png"}
		self.link_volume = self.link_volumes[platform]

		self.unformat_infos = {'win2003' : "unformat_info2003.png" , 'winxp' : "unformat_infoxp.png" , 'win2008' : "unformat_info2008.png"}
		self.unformat_info = self.unformat_infos[platform]
		
		self.new_partitions = {'win2003' : "new_partition2003.png" , 'winxp' : "new_partitionxp.png" , 'win2008' : "new_partition2008.png"}
		self.new_partition = self.new_partitions[platform]

		self.cancel_auto_partitions = {'win2003' : "cancel_auto_partition2003.png" , 'winxp' : "cancel_auto_partitionxp.png" , 'win2008' : "cancel_auto_partition2008.png"}
                self.cancel_auto_partition = self.cancel_auto_partitions[platform]
		
		self.next_bottoms = {'win2003' : "next2003.png" , 'winxp' : "nextxp.png" , 'win2008' : "next2008.png"}
		self.next_bottom = self.next_bottoms[platform]
		
		self.finishs = {'win2003' : "finish2003.png" , 'winxp' : "finishxp.png" , 'win2008' : "finish2008.png"}
		self.finish = self.finishs[platform]
		
		self.closes = {'win2003' : "close2003.png" , 'winxp' : "closexp.png" , 'win2008' : "close2008.png"}
		self.close = self.closes[platform]

	def click_start(self):
		self._click(self.start_picture)
		
	def click_control_panel(self):
		self._click(self.control_panel)
	
	def click_administrator_tool(self, how_to_click = "click"):
		self._click(self.administrator_tool, how_to_click)
		 
	def click_computer_manager(self):
		self._click(self.computer_management)

	def click_disk_management(self):
		self._click(self.disk_management)

	def click_cancel_initial(self):
		self._click(self.cancel_auto_partition)

	def click_full_screen(self):
		self._click(self.full_screen)

	def click_link_vol(self):
		self._click(self.link_volume)

	def click_right_for_initail_info(self):
		self._click(self.disk_unknown, how_to_click = "rightClick") 

	def click_initial_Disk(self):
		self._click(self.initial_disk)

	def click_ok(self):
		self._click(self.ok)
	
	def click_right_for_new_partition(self):
		self._click(self.unformat_info, how_to_click = "rightClick")

	def click_new_partion(self):
		self._click(self.new_partition)
	
	def click_next(self):
		self._click(self.next_bottom)
		

	def click_finish(self):
		self._click(self.finish)	

	def click_close(self):
		self._click(self.close)
	
    def click_what(self , image_name):
		self._click(image_name)

	def _click(self,icon,icon_2 = None ,how_to_click="click"):
		
		findAll(Pattern(icon).similar(0.9))       
        allmatchs = getLastMatches()
		sort_allmatchs = sorted(allmatchs,key=lambda allmatchs:allmatchs.getScore())
		sort_allmatchs.reverse()
		match = sort_allmatchs[0]
		self.appCoordinates = (match.getX(), match.getY(), match.getW(), match.getH())
                appRegion = Region(*self.appCoordinates)		

		if how_to_click == "click":
			appRegion.click(icon)
                elif how_to_click == "doubleclick":
                        appRegion.doubleClick(icon)
		elif how_to_click == "rightClick": 
			appRegion.rightClick(icon)
		elif how_to_click == "hover":
			appRegion.hover(icon)
		elif how_to_click == "dragDrop":
			appRegion.doubleClick(icon_start,icon_stop)

4. 建立robotframework的測試碼

		cd ..
		mkdir robotCode
		cd robotCode
		vim format_win2008.txt
 
	
程式碼如下：

因為我在python檔有寫\__int__ 所以我在一開始就先丟個初始值給他(請看下句)

Library  Format.VolumeFormat  win2008



		***Settings***
		Library  Format.VolumeFormat  win2008
		Library  OperatingSystem

		***Test Cases***
		Format Win2008 Volume
        	Start Process  rdesktop -u 遠端VM的名字 -p 你的密碼 遠端的IP位置
        	sleep  30
        	click_start
        	click_administrator_tool
        	click_computer_manager
        	sleep  10
        	click_disk_management
        	sleep  10
        	[Documentation]  click_cancel_initial
        	click_cancel_initial
        	click_right_for_initail_info
        	click_link_vol
        	click_right_for_initail_info
        	click_initial_Disk
        	click_ok
        	click_right_for_new_partition
        	click_new_partion
        	click_next
        	click_next
        	click_next
        	click_next
        	click_finish
        	click_close
        	[Teardown]      Stop All Processes

**重要的來了**

5. 寫執行檔！！！！這邊就是要告訴robot我還有其他lib要用～還有sikuli的jar檔要include進來

		vim run.sh

程式碼如下：

		#!/bin/bash
		export CLASSPATH="/home/alohacc/Sikuli-X-1.0rc3-r905-linux-i686/Sikuli-IDE/sikuli-script.jar"  

		export JYTHONPATH="$CLASSPATH/Lib"

		jybot --pythonpath WindowRDPFormatLibrary --outputdir results --loglevel TRACE -l Format_log -r Format_report -o Format_output $* robotCode

6. 我run.sh的程式碼 有一個輸出的dir位置，我先建一個給他

		mkdir results


To sum up :

資料夾結構如下：

	RobotSikuli
	  ->results
	  ->WindowRDPFormatLibrary
			-> Format.py
	  ->robotCode
			-> format_win2008.txt
			-> run.sh
	  ->winFormatImage
			-> administrator_tool2003.png 
			   change_to_original_view.png  
			   control_panel_xp.png     			  			
				……etc 

執行的話，就是下

	sh robotCode/run.sh

恭喜完成！！！


主要參考為

[How-To: Sikuli and Robot Framework Integration](http://blog.mykhailo.com/2011/02/how-to-sikuli-and-robot-framework.html)

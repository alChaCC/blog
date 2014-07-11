---
layout: post
title: "How to Setup Jenkins Slave VM(WinXP) which support Sikuli Testing"
date: 2012-11-07 18:28
comments: true
categories: [Sikuli , Jenkins] 
---

Reference Topics:

[Setting up a Jenkins slave for Sikuli based tests](http://technicaltesting.wordpress.com/2012/05/07/setting-up-a-jenkins-slave-for-sikuli-based-tests/)


作者環境是win7，我按造上面的設定修改
	
###1.設定User 永遠不會被logout

**點選執行**
<a href="http://www.flickr.com/photos/alohacc/8163442105/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step1"><img src="http://farm8.staticflickr.com/7129/8163442105_a1dabc5168.jpg" width="374" height="500" alt="sikuli_vm_setup_step1"></a>

**輸入regedit**

<a href="http://www.flickr.com/photos/alohacc/8163442169/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step2"><img src="http://farm9.staticflickr.com/8061/8163442169_ea1e39d3c4.jpg" width="337" height="167" alt="sikuli_vm_setup_step2"></a>

<!--more--> 

**點到HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System**


<a href="http://www.flickr.com/photos/alohacc/8163475730/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step3"><img src="http://farm8.staticflickr.com/7106/8163475730_07772dc6b9_m.jpg" width="204" height="189" alt="sikuli_vm_setup_step3"></a>

<a href="http://www.flickr.com/photos/alohacc/8163475788/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step4"><img src="http://farm9.staticflickr.com/8479/8163475788_7b21b7497b.jpg" width="500" height="275" alt="sikuli_vm_setup_step4"></a>

**新增DWORD值**

<a href="http://www.flickr.com/photos/alohacc/8163442301/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step5"><img src="http://farm9.staticflickr.com/8484/8163442301_7d7ce36f38.jpg" width="345" height="209" alt="sikuli_vm_setup_step5"></a>

**新增DisableLockWorkstation，設定為1**

<a href="http://www.flickr.com/photos/alohacc/8163475866/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step6"><img src="http://farm8.staticflickr.com/7111/8163475866_f210b0fba8.jpg" width="322" height="184" alt="sikuli_vm_setup_step6"></a>

因為有查到這篇文章[Disabling Lock Workstation in Windows XP](http://superuser.com/questions/96228/disabling-lock-workstation-in-windows-xp),所以還要在設定一個參數

**用尋找功能**

<a href="http://www.flickr.com/photos/alohacc/8163442715/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step13"><img src="http://farm9.staticflickr.com/8479/8163442715_7693c918ba_m.jpg" width="211" height="210" alt="sikuli_vm_setup_step13"></a>

**尋找AllowMultipleTSSessions，並修改成0**

ps.他在HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon裡面

<a href="http://www.flickr.com/photos/alohacc/8163476260/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step14"><img src="http://farm8.staticflickr.com/7246/8163476260_266a58d497_m.jpg" width="240" height="104" alt="sikuli_vm_setup_step14"></a>


### 2.設定使用者，重開機時，可以自行登入

**點到HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon**

<a href="http://www.flickr.com/photos/alohacc/8163475918/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step7"><img src="http://farm9.staticflickr.com/8066/8163475918_009161e433.jpg" 
width="500" height="261" alt="sikuli_vm_setup_step7"></a>


**新增字串**

<a href="http://www.flickr.com/photos/alohacc/8163475960/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step7-5"><img src="http://farm8.staticflickr.com/7272/8163475960_74bdb0b74a.jpg" width="342" height="234" alt="sikuli_vm_setup_step7-5"></a>


**新增DefaultPassword，輸入你的密碼**


<a href="http://www.flickr.com/photos/alohacc/8163475998/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step8"><img src="http://farm8.staticflickr.com/7274/8163475998_c98a8c4c0f.jpg" width="379" height="146" alt="sikuli_vm_setup_step8"></a>

**修改DefaultUsername**

<a href="http://www.flickr.com/photos/alohacc/8163476034/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step9"><img src="http://farm9.staticflickr.com/8487/8163476034_736554f892.jpg" width="383" height="154" alt="sikuli_vm_setup_step9"></a>

**修改AutoAdminLogon，設定為1**

<a href="http://www.flickr.com/photos/alohacc/8163476080/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step10"><img src="http://farm9.staticflickr.com/8204/8163476080_fc059350a4.jpg" width="378" height="154" alt="sikuli_vm_setup_step10"></a>

### 3.取消螢幕保護

**點到HKEY_CURRENT_USER\Control Panel\Desktop**

<a href="http://www.flickr.com/photos/alohacc/8163476112/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step11"><img src="http://farm9.staticflickr.com/8489/8163476112_121e07519d.jpg" width="355" height="499" alt="sikuli_vm_setup_step11"></a>

**修改ScreenSaveActive為0**

<a href="http://www.flickr.com/photos/alohacc/8163476166/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step12"><img src="http://farm8.staticflickr.com/7271/8163476166_021f20ef99.jpg" width="381" height="159" alt="sikuli_vm_setup_step12"></a>



### 4. 重開機

### 5. 最後也是最重要的一步！！清掉上次RDP所鎖定的畫面，在Jenkins Script加上 
	
		tscon.exe 0 /dest:console
		
**thanks to Mac support**
	
<a href="http://www.flickr.com/photos/alohacc/8163451817/" title="Flickr 上 aloooooooooooha 的 sikuli_vm_setup_step15"><img src="http://farm8.staticflickr.com/7260/8163451817_16141e0d28_b.jpg" width="1024" height="86" alt="sikuli_vm_setup_step15"></a>




Reference

[參數: AllowMultipleTSSessions](http://www.pctools.com/guides/registry/detail/973/)

[參數: DisableLockWorkstation](http://www.pctools.com/guides/registry/detail/264/)

[參數: ScreenSaveActive](http://www.pctools.com/guides/registry/detail/1190/)



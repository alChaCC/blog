---
layout: post
title: "[閱讀筆記系列] 23 + 1 設計模式 - Part3. Adapter"
date: 2012-06-18 11:12
comments: true
categories:  [Design_Pattern, Reading]
---

這個好像還滿常用的 

概念大概是這樣的

把**本來的內容** 透過 **轉換的東西**
變成**你要的結果**

主要有兩種方式來實作，一個是繼承，另外一個是委讓(交給誰做)

下面是講**繼承**的寫法

<!--more--> 

**本來的內容**舉例來說就是

## Blackboard類別

	public class Blackboard {
		private String string;
		
		public Blackboard(String string) {
			this.string = string;
		}
		
		public void showIsHandsome()
		{
			System.out.println(string + "is so handsome");
		}
		
		public void showIsUgly()
		{
			System.out.println(string + "is so ugly");
		}
	}


**你要的結果**就是

## Print 介面

	public interface Print{
		
		public abstract void printCool();
		public abstract void printBad();
	
	}

**轉換的東西**就是

##PrintBlackboard類別


	public class PrintBlackboard extends Blackboard implements Print{
		public PrintBlackboard(String string)
		{
			super(string);
		}
		
		pubic void printCool()
		{
			showIsHandsome();
		}
		
		public voild printBad()
		{
			showIsUgly();
		}
	}
	
用法：

## Main類別

	public class Main{
		public static void main(String[] args){
			Print p = new PrintBlackboard("Aloha");
			p.printBad();
			p.printCool();
		}
	}
	
就會得到
	
	Aloha is so ugly

	Aloha is so handsome
	
這個程式碼

你會發現你只有用到介面在寫程式～根本不需要知道裡頭是如何實做的，也就是說之後要改code你不需要去修改main，就修改PrintBlackboard類別就好

如果是**委讓**的寫法是這樣寫的

主要差在Print由原本的interface改成class

	public abstract class Print{
		
		public abstract void printCool();
		public abstract void printBad();
	
	}
	
PrintBlackboard 直接繼承Print在委讓Blackboard類別幫你做事情

	public class PrintBlackboard extends Print{
		private Blackboard blackboard;
		
		public PrintBlackboard (String string){
			this.blackboard = new Blackboard(string);
		}
		
		public void printCool(){
			blackboard.showIsHandsome();
		}
		
		public void printBad(){
			blackboard.showIsUgly();
		}
	}

<iframe id='xmindshare_embedviewer' src='http://www.xmind.net/share/_embed/alohaC/adapter-model-adapter/' width='900px' height='600px' frameborder='0' scrolling='no'></iframe>



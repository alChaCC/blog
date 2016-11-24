---
layout: post
title: "Split Single Lossless Audio(.ape, .flac) Files into mp3 in MacOSX"
date: 2016-06-25 17:33:14 +0800
comments: true
categories: ['Others']
keywords: "ape, mp3, Mac, split, lossless audio, free"
description: 'this article show you how to split single lossless audio files into mp3'
---

I got a lossless audio from my friend which included Taiwan famous folk songs in 1970~1979.

So, I want to split this audio into seperate mp3. Spending few hours, I found this library!

I have to thank @ftrvxmtrx - the author of [https://github.com/ftrvxmtrx/split2flac](https://github.com/ftrvxmtrx/split2flac).

In this post, I just show to how to setup the environment to use ftrvxmtrx's libarary in MacOSX.

## 1. Make sure you have homebrew

## 2. Install required/optional libs

```
brew install cuetools
brew install shntool
brew install id3lib
brew install flac
brew install homebrew/dupes/libiconv
brew install enca
# for install mac to split APE
brew tap fernandotcl/homebrew-fernandotcl
brew install monkeys-audio
```

## 3. Clone project

```
git clone https://github.com/ftrvxmtrx/split2flac.git
```

## 4. Convert files

```
cd split2flac
```

Check commands

```
./split2flac -h
```

Convert the file

```
./split2flac -f mp3 -o ~/Desktop/ -cue path/to/your/cue-file.cue path/to/your/ape-file.ape
```

**-f**: using mp3 as output format

**-o**: where to put the output files

**cue**: file location to your .cue

yay!


<img src='https://dl.dropboxusercontent.com/u/22307926/Blog%20Image/split_lossless_audio/demo-%20split%20ape%20file%20into%20mp3.png' alt='demo: split ape file into mp3'>



---
title: "如何从零开始开发iOS App到上架赚钱-附完整源码"
date: 2018-10-05T10:30:57+08:00
draft: false
---

## 前言

有不少人问我怎么业余学习写代码开发一些东西玩玩。我虽然是职业开发工程师，业余开发App也仅仅只是自己的兴趣而已。我想不是所有的职业开发者都有兴趣或者时间去做此类玩具小App。我这里分享一个简单的App从开发到上架的基本知识，让感兴趣的朋友有一个感性的认识。希望对于想学习开发的朋友在方向上面有所帮助。

这个App是设置壁纸的，你可以从网上搜索壁纸然后下载到本地。麻雀虽小五脏俱全，具备了一个App所有的必备要素。本文尽量以通俗易懂的方式让即使没有任何技术背景的人都能够理解，所以不会讲太深的技术细节。

对于职业软件工程师，对于App的开发上架我也给出了完整的源码，以便深入研究。

我这里附上App链接，你们可以自己体验一下：[壁纸美图](https://itunes.apple.com/us/app/%E5%A3%81%E7%BA%B8%E7%BE%8E%E5%9B%BE10000-%E5%A3%81%E7%BA%B8-%E7%BE%8E%E5%9B%BE-%E5%A3%81%E7%BA%B8%E5%A4%A7%E5%85%A8-%E7%BE%8E%E5%9B%BE%E5%A4%A7%E5%85%A8-%E9%AB%98%E6%B8%85%E5%A3%81%E7%BA%B8/id978533517?l=zh&ls=1&mt=8)

主要界面：

![新建项目](/image/lesson1/s1.jpg)

![新建项目](/image/lesson1/s2.jpg)

![新建项目](/image/lesson1/s3.jpg)


## 通过本文你将获得

> - 关于移动开发学习的基本方向。
- iOS App从开发到上架的基本流程和知识。
- 基本代码示例，我个人开发已上架App完整源码。

## 关于技术平台

很多的朋友在开始学习开发，或者说开始开发应用的时候会纠结于具体的平台技术。我简单谈谈自己的看法，就编程而言有数不尽的种类，但是它们都具有类似的结构化语言，更重要的是编程的思想是大同小异的。

我在选择平台的时候基本首先看重市场和发展前景，因为技术本身的价值是要通过业务发展来体现的。再者看其学习成本以及我们需要做的具体项目，效率和可靠性是应当考虑的。

移动端我们的选择还是挺多的，iOS，Android都是比价好的平台。在当前大前端的趋势下，前段技术，例如微信小程序都是不错的选择。顺带提一下最近比较火的Flutter，此项跨平台的技术可以同时为iOS，Android开发也是值得一试的。

这里给出的例子是iOS，Objective-c开发。其它平台，在大的思路上应该是差不多的。

## iOS开发的前置条件
知识

> - 具备普通编程能力。
> - 具备iOS平台基本开发知识。
> - 具备一定图片编辑能力，如果不在意App外观不是必须项目。


硬件：

> 
> - Mac设备只要是安装了苹果系统都可以。
> - iPhone测试设备（此项大多数情况下，非必须用模拟器也是可以的）。
>


软件：

>
> - Xcode 苹果系统免费的开发工具。
> - 图片编辑器，用于制作图片资源，简单能用即可。
> - Apple Developer 如果需要将App上架到App Store此项才需要，一年99美金。
>

## 关于编程
本文无法教你学会如何去编程，编程是需要一个较长时间的训练才能巨具备的能力。对于大多数没有完全基础的人来说，马上去编程的确是一个比较困难的事情，不排除天才的存在。

不过，任何学习都是从模仿开始的。不妨拿着代码照葫芦画瓢先感受一下，毕竟有兴趣我们才能继续深入下去。

确定自己对编程有兴趣以后可以开始学习一些编程的基础知识。iOS开发使用的Objective C或者Swift，对于对于初学者来说可以找点相关的书籍和视频进行学习。学习基础语法编译通过是首要任务。

懂得语言基本知识以后，就可以开始学习一点iOS平台相关的东西。如果英文足够好的话，可以去读Apple官方提供的Programming Guide系列。
[Apple 官方文档连接](https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007072-CH7-SW24)

初学者不要太纠结看什么书，找点大家公认的就行了，入门只是一部分。后面的路还很长。

## App基本架构设计

目前的大多数App都是CS（Server Client）架构，也就是App+服务器。我们这里不讨论服务器的开发，从本质上来说服务器开发跟App并没有区别，只是平台不太一样。（感兴趣可以了解一下PHP，Spring Boot等技术）。

如果为了一个App我们同时要开发服务器（其实很多个人开发者都是这么干的），那我们就把问题复杂化了。我们今天只专注于App，实际上网络上很多我们可以调用的服务器接口资源，也不用完全自己开发。

我的这个App的图片搜索就是通过抓包分析百度的搜索接口得到的，百度搜索引擎的接口很多都是开放的。

### App + Server架构

#### App的职责

用通俗的话来说App要做的事情就是想Server索要数据，然后展示出来。

#### Server职责

Server就是等待App的数据请求然后给出相应的数据即可。

我们用步骤简单表述一下App需要做的事情：

> 1. 展示用户界面，等待用户的操作。
2. 用户输入关键字搜索，App将关键字发送给服务器，服务器返回搜索结果。
3. App将服务器的搜索结果展示出来。
4. 用户选择喜欢的图片，下载保存。

App的实现就是将这些逻辑用代码表达出来，我们个人的时间精力是有限的，如果要从头到尾实现所有的东西是不太可能的。幸好，iOS和很多开源项目帮我们解决了很多常用的问题。

## 开始开发
这里不可避免的会贴一些代码，我这里尽量只贴一些一目了然的东西。

### 新建项目

打开安装好的Xcode, 然后新建一个项目，选一个你喜欢的名字。
![新建项目](/image/lesson1/xcode_new_project.png)

### 写代码

#### 开发用户界面

一般开发App采用的是MVC（以及其它演进架构）架构，简单理解就是数据和界面分开开发。什么是用户界面？就是你每天在手机上面看到的那些页面。

Xcode可以使用Interface Builder进行页面开发，意味着你可以不用写一行代码就可以开始构建用户界面，你没有听错，这里可以不用写代码！

iOS上面一个页面的概念为一个叫做UIViewController的东西，下面开始简称VC。你可以使用Xcode直接新建VC，Xcode也会直接帮你新建好对应的Xib或者Storyboard方面你进行可视化的用户界面开发。

![新建项目](/image/lesson1/xcode_vc.png)

这段代码是App启动的时候的入口，我们可以在这里配置VC。不过目前的Xcode都已经将这部分自动化了。

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}
```

具体的开发代码，我这里就不详细说了，可以写一本书。

#### 开发数据模块

##### 网络数据
用户界面开发完成以后，我们主要的工作就是开发数据相关的代码。网络数据主要是要解析一种叫做JSON的数据格式，解析好存起来就行了。前面我提到网络数据接口使用的是百度的接口，前提是要抓包分析一下接口具体内容。

具体代码差不多，是这样子的，就是把一个个值拿出来。我这个是比较传统的手动解析，用一些现代的流行库，可以自动进行映射。

```objc
- (id)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        _imageId = dic[@"id"];
        _pageNumber = [dic[@"pn"] integerValue];
        _desc = dic[@"desc"];
        _tags = dic[@"tags"];
        _tag = dic[@"tag"];
        _date = dic[@"date"];
        
        _imageUrl = dic[@"image_url"];
        _imageWidth = [dic[@"image_width"] floatValue];
        _imageHeight = [dic[@"image_height"] floatValue];
        
        _thumbUrl = dic[@"thumbnail_url"];
        _thumbWidth = [dic[@"thumbnail_width"] floatValue];
        _thumbHeight = [dic[@"thumbnail_height"] floatValue];
        
        _largeThumbUrl = dic[@"thumb_large_url"];
        _largeThumbWidth = [dic[@"thumb_large_width"] floatValue];
        _largeThumbHeight = [dic[@"thumb_large_height"] floatValue];
        
        _siteUrl = dic[@"site_url"];
        _fromUrl = dic[@"from_url"];
    }
    
    return self;
}
```
不涉及太深的技术。

##### 本地数据库

一般App会有一个数据库来存储来自网络和用户输入的数据。我们可以使用coredata，sqllite等技术。

### 图片资源

等代码都开发完以后我们还要为App做一下图片资源，比如icon和闪屏之类的。没有这些的必备资源App Store是不会审核通过的。

### 测试打包

好的，代码资源都准备好以后，我们要做一点的测试保证App没有明显的问题。这是开发的优良品质。

测试完成以后，我们就可以对App进行打包了。用Xcode上面的Archive，就可以完成打包了。

### ITunes Connect上面新建App

如果要真正上架到App Store，我们需要该买Apple Developer，支付一年99美金的费用。然后在ITunes Connect这个网站上面新建一个App，也就是对应我们准备发布App的信息，包括展示图片和基本介绍。我们发布的App以后都是在ITunes Connect上面去管理的。

### 上传

好的，ITunes Connect和App包都准备好了，我们就可以进行最后一步了。我们使用Xcode的Application Loader将我们的App包ipa进行上传，只需要登录你的AppId即可。

### 审核上架
等待包上传以后，我们再一次登录到ITunes Connect将我们的App提交审核。在苹果审核通过以后我们就可以在AppStore上面看到自己开发的App了！

## 关于盈利
盈利方面，我们可以讲App设置为付费购买，或者是App内容付费来赚钱。这是App Store官方支持的盈利方式。除此之外最简单的方式就是在你的App里面接入广告盈利，国内有不少广告聚合商，不过我个人建议使用Google的Admob。只有要人点击你的App里面的广告，你就有收入了！听起来很美，不过目前来说要App Store竞争非常激烈。用户对于App质量的要求越来越高，个人开发者在有限的时间精力资源下能够占得一席之地可谓是非常困难。

但是这也并非绝对，比如之前的flappy bird，非常简单的游戏火得让人难以理解。关键还是看创意和运气吧。

## 接下来干嘛？
我想用短短的一篇文章从零开始学会iOS开发的确不太现实，本文中的每一个小点都可以写成一本书。我想通过这篇短文，给感兴趣的朋友一个感性地认识和一个大致的方向。

有任何疑问，或者有更多想了解的内容，可以在留言中告诉我。如果大家的呼声很高，我会考虑后面继续写更加详细的教程。

如果喜欢本文，或者继续看接下来的一些分享，可以关注我的公众号：Jidong，文章末尾有二维码，可以同步接收到文章的更新。

## 源码

源码的地址，关注公众号，可以回复```源码1```即可获得。

![qr_search.png](/image/qr_search.png)

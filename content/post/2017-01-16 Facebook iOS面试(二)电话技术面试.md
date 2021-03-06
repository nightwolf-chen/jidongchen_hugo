---
date: 2017-01-16
status: public
title: 'Facebook iOS面试(二) 电话技术面试'
categories: [ios,facebook,interview]
---

    经过简短的HR Initial Call后我顺利地进入了FB面试流程的下一步——电话技术面试。
## 电话技术面试
一般HR会跟你协商电话面试的时间，这里有个小技巧，尽可能多要点时间以便更好地准备。一开始HR跟我提的时间是下一周，我问最迟能可以在什么时候。因为那段时间刚好赶上感恩节国外有节假日，所以最终HR跟我约定的时间在大概一个月后。这样子我有大概一个月的时间去准备（其实是二十多天）。顺带提一下，这次面试是通过Skype Audio，几次电话面试都是没有开视频的。
## 面试覆盖的内容
FB的面试流程相当规范，在约好时间后HR马上发了相关的邮件给我。邮件里面除了提到一些面试时间以外还提供了详细的准备指导！邮件包含了这次面试将会考察到的内容，因为我是面试iOS工程师所以这次主要考察OC知识以及算法问题。这里我列出一些面试的内容要点:

>*  这次电话面试的时间为45分钟，面试时你需要使用Coderpad（在线的共享编辑器）编写代码，你在写代码的时候面试官可以实时地进行review。没有自动补全，不允许在线查询。

> * 面试官会深入考察你对iOS平台以及Objective C的知识。

> * 可能涉及到常见的技术问题，算法，数据结构，设计模式，时间复杂度分析，iOS API。

> * 也有可能会问到常见的iOS业务逻辑实现，比如网络数据加载，UIKit。

> * 要求是写出clean，可编译，高效的代码。

## 电话面试的几点技巧
具备良好的计算机知识基础，并且拥有一定开发经验的iOS工程师解决面试问题应该是没有太大问题的。沟通和交流成了我们这种国内工程师面试FB的主要问题。我相信FB在面试过程当中除了考察你的知识和编程能力以外更加看重的是你解决问题的方法和思维方式。所以在面试过程当中应该竟可能多地表达自己的想法，积极地去和面试官沟通，这里我是从HR那里获取的一些tips结合自己的经历分享几点:

>* 收到题目以后，不应该急着写代码。首先应该仔细思考问题的各种限制条件并且积极去跟面试官确认各种细节和边界条件。比如，问题的规模，输入的格式，输出的格式，结果是否需要排序，有没有重复输入等等。如果你实在想不到此类问题，念一遍题目也是好的。

> * 写代码之前一定要先把思路说给面试官听，一般思路没有问题面试官会示意继续写代码。如果有问题，面试官会给你提醒，你就需要再思考一下了。

> * 对于iOS开发，我特别提醒一下，需要对内存管理有比较透彻的理解。现在大家都用arc，但是还是要理解内存管理的原理。

> * 写出能运行的程序是首要任务，你可能没有想到最优解，但是尽可能写出可以运行解决问题的程序（尽管可能效率有问题）。

## 面试准备
我在网上看了很多面经，大部分面试准备都是刷Leetcode，不得不说我真的在面试过程中遇到过leetcode的题目。我也是以leetcode为主来准备面试的，但是因为职位要求面试当天要求使用objective c写代码，这是我没有预料到的。我一直在leetcode上面写C++，不过对于每天都使用oc的职业开发来说这也不是什么大问题。另外推荐一本书""Cracking the coding interview"，这部书必看，里面很多经典的题目。

我在面试之前去网上找了一个Mock Interview服务，也就是模拟面试。说实话当时mock完以后我感觉很糟糕，题目没有做出来，交流也有问题（当时mock的考官的是国外工作的国人）。这也激发了我的斗志，需要特训来加强自己的薄弱点。Mock之前我是一天刷一道，Mock之后我决心把Leetcode上面easy，medium难度的题目都做完，短短二十天将近两百道题还是很有挑战的。
同时我在跟朋友交流后得知在国外留学的同学找工作时都是很刻苦准备的，他们至少都刷了一遍leetcode，有些甚至刷了很多遍。对比之下，我觉得我努力还远远不够。

对于刷Leetcode我有几个tips：

>* 不要开IDE，不开debugger，直接在网页里面写。代码不出样例的时候多检查逻辑和思路。我基本都是在网页里面写好代码直接提交的，有时候会有一些编译错误，但是问题不大。你如果能够做到Web编辑器顺畅的编写代码，无疑能够加强你盲写代码的能力。

>* 建议先按照专题来刷：Array，Tree，HashTable, LinkedList，dynamic prograimming，graph,基本知识都复习巩固以后再进入题海战术。我特别重视Tree这一部分，这一部分题我刷了两遍。因为Tree这种数据结构变化最多，而且应用很有技巧，最能体现一个程序员基础的知识水平。从具体情况来看，我的判断是没有问题的，整一个面试下来有一半题目都是跟Tree有关的。

> * 遇到不会做题目不要死磕，很多算法都是建立的一定理论上面的，很可能是你这方面的知识薄弱。看答案没有什么问题，但是不要去背答案，背答案面试官是很容易看出来的。

> * 孰能生巧，多练多总结才是硬道理。

## 面试当天
面试当天我早上七点多起床热身然后在电脑面前等，一个外国小哥八点准时在Skype上打来了电话。首先自己介绍，然后问了几个iOS开发的问题，记得其中一个是NSNotification的作用和用法。然后是两道题目，要求oc进行编码。

>1，写一个方法判断两个NSRange是否相交。

>2，有两个完全一个UIView Tree， TreeA， TreeB, 给出TreeA中的节点指针NodeA，找出TreeB中对应位置的Node。

题目是不难的。第一题注意一下空Range。第二题的TreeNode就是UIView,UIView有一个superView指针可以往回找出一个路径。第二题我一开始用递归，其实直接用循环就够了，面试官稍微问了一下，我解释了一下也没有什么大问题。题目做完以后，就是问问题时间，这个可以自由发挥。

## 结果
面试完以后自己感觉还不错，几天之后收到HR约聊邮件，但是没有说结果。我有点担心这是传说中的Call To Reject。又焦急等了几天，这次HR没有准时到来，在我们约好的时间范围的最后五分钟才来电话，然后一上来祝贺我。真是套路啊，难道是要给我一个惊喜？这次谈话只有简短的五分钟，HR跟我说后面就是onsite了，由另外一个HR负责，于是我又马上开始了onsite准备。
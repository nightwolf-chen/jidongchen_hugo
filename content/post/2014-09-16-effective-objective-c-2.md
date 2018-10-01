---
layout: post
title: "Effective Objective-C(2)"
date: 2014-09-16 
comments: true
categories: [ios]
---

#### 对象，消息，以及运行时（Runtime）
这一篇，介绍oc于对象，消息和Runtime有关的实践。

#### 理解Properties
类似于java里面的set和get方法，oc提供了property特性。在java（这里以java作为典型的面向对象举例子）里面，一般是定义一个成员变量，然后再定义对应的setter和getter。在oc里面你可以这样定义一个属性:

```Objective-C  

//In interface file
@property(retain,nonatomic) NSString *aProperty;
 
 
//In implement file,optional
@synthesize aProperty = _aProperty

```

在现代的oc编译器里面，当你定义了一个property，编译器会自动生成getter和setter还有对应的变量。也就是@synthesize是可选的，你可以通过@synthesize来指定变量的名字，默认生成的变量名字是在property名字前面加一个下划线。

#### 使用_var 还是 self.var
这里我想讨论一下一个有趣的问题。property对应一个成员变量，在类的内部既可以通过直接访问变量的方式（_var）,也可以通过getter和setter的方式去访问该变量(self.var)。那到底哪种方式是比较好的呢？

一些人认为getter和setter方式效率会比较慢，因为是通过消息的形式进行访问的。这的确是有道理的，但是这细微到几乎难以察觉的差别在绝大多数情况下都是没有什么影响的（除非是超高频率的进行访问）。

无论怎么说，具体怎么写还是要按情况而定的。但是有一种比较折中的做法，也是Effective-oc里面提倡的做法。读操作采用_var的形式，写操作使用setter，setter可以出发KVO。这也算是一种折中的做法啦。

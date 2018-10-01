---
categories: [ios]
comments: true
layout: post
date: 2014-09-15 
status: public
title: Effective Objective-C (1)
---

一本好书推荐
===

最近花了一阵子的时间读了《Effective Objective-C 2.0》这本书，感觉挺不错。我觉得这本书值得每一个OC程序员读一读。它里面从很多个角度给出了OC在日常开发当中的一些实用建议，很有效地提升代码的质量。我根据自己的阅读经历，在这里总结一下这本书重要的内容。


### 让自己熟悉Objective-C

- 首先要理解oc的根源，oc是一个面向对象的语言就像java和c++一样，但其实oc里面的发消息机制是来源于smalltalk的。java和c++里面的函数调用和oc里面的发消息的作用是一样的，但是它们还是有区别的，函数（方法）调用是在编译时候确定的，而发消息却是在runtime确定的。oc是c的一个超集合（这个有点类似于c++），也就是说你可以在oc里面使用c的语法，我很喜欢这个特性。

- 要尽量减少头文件的import：尽量将头文件的引用推迟到m文件当中，因为在头文件中直接import很有可能导致预处理的问题，而且影响编译效率。多用@class，@protocol这种编译标记，尽量不要在不需要的地方暴露过多的内容。这和c++里面namespace的使用原则差不多，尽量避免名字空间的污染。有些人很喜欢在文件开始的地方using一个namespace， 这就造成了不必要的污染。总之，让import的影响范围最小化。

- 多使用字面量：为什么使用字面量？简单易懂，可读性强。比较常用的NSString的字面量，比如：@"Hello world"。像NSDictionary，NSArray，NSNumber，这些的字面量都比他们的构造方法好用的多，@{},@[],@()。还可以通过NSMutableArray *mutable = [@[@"",@""] mutableCopy] ;构造mutable的对象。NSArray还可以通过类似于数组的下标方法来访问，array[0]。另外字面量还有一个好处，就是编译器会在编译的时候检查容器中是否传入了nil。综上所述，没有理由不使用字面量^_^

- 使用有类型的常量而不是#define。我发现很多人喜欢使用宏来定义常量（甚至有些人有事没事放在头文件里面！）。的确有时候宏可以很方便地完成一些功能，但是有类型的常量才是比较好的选择。宏只是文本的替换没有类型检查，很显然有类型的常量要安全一些。而且有时候有意无意宏可能会被重新定义，这也是非常蛋疼的。一般常量都以一个小写的k字母开头，局部的定义使用static const等关键字，如果是全局的常量则使用extern关键字。只有在类型常量无法达成你的需求的时候才考虑使用宏。

- 使用enum枚举类型来表示状态（States），选项（Options），状态code（Status Codes）。一些不好的习惯是使用0，1，2这类整数型来表示一些状态，但到底表示神马意思，只有写这个代码的人才知道。用enum来表示Options的时候可以使用这种技巧：

``` C
enum Options{
	op1 = 0,
	op2 = 1 << 0,
	op3 = 1 << 1,
	op4 = 1 << 2
}
```

这样就可以同时使用多个选项，通过|操作符，在判断的时候使用&来进行判断。苹果提供了几个可以方便定义枚举的宏，可以明确指定枚举的type，比如：

```objective-c 
NS_ENUM(NSUInteger,EOCConnectionState){
...
};

：NS_ENUM(NSUInteger,EOCConnectionDirection){
...
};
```

这是针对oc这个语言特性而提出的一些实用建议。
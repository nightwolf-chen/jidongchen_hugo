---
categories: [ios,UIkit]
comments: true
layout: post
date: 2014-08-26 
status: public
title: 如何实现一个UITabbarController
---

TabbarController
===
Tabbar这种UI控件很常用，尤其是在手机APP上面。很多APP的主界面都是一个Tabbar来搭建的，在iOS上面苹果提供了UITabBarController这个类来实现tabbar的功能，UITabBarController基本上可以满足大部分APP的需求。你可以通过tabItem来定制Tabbar的外观。

但是有时候我们需要更加深入的定制Tabbar，比如说UITabBar是在屏幕底部的，我们想要将Tabbar放在顶部，比如说实现一个类似安卓顶部那种Tabbar。这种时候我们可以考虑自己去实现一个TabbarController，这里讨论我自己实现过的一种方法。

#### 理解UIView和UIViewController

#### UIView
苹果的文档是这样描述***UIView***的:
The UIView class defines a rectangular area on the screen and the interfaces for managing the content in that area. 

也就是说view负责的是自己的呈现，简单来说就是管理自身绘制的内容和提供相关的接口。在开发当中我们应该尽量保持view的这种单一职责不要在其中。

#### UIViewController
官方文档对***UIViewController***的描述是这样的：A view controller manages a set of views that make up a portion of your app’s user interface. 
我的理解是一个Controller管理了一组view，这组view属于同一个用户界面组成部分。比较常见的做法是一个Controller管理一整个屏幕的view的层级结构。有时候在一屏当中也有可能出现多个独立的页面组成部分，这个时候也可以会将逻辑独立的不同组成部分放到不同的Controller当中。也就是说一屏当中会有多个Controller，而这个时候又需要一个Controller来管理这个页所有的Controller，我们称这种Controller为Container Controller,而UITabBarController就是一个典型的Container。

> 对于常规的ViewController来说，它主要负责的是管理一个***view hierarchy***
> 用我的话来说，就是负责管理view怎么去显示，显示什么。在平时的开发代码中，我们经
> 常看到代码非常长的view controller文件，我觉得这是对MVC的一种误解。很多代码
> 习惯将所有的业务逻辑放到view controller当中，这样的代码是很难维护的。应该尽量
> 保持view controller本来的“单纯”，其它的一些逻辑应该进一步合理地进行分配划分。

自定义TabBarController
===

####手动在Controller里面切换view

我们首先简单想一下TabBarController实现的功能，直观上来看好像是按一个tab的按钮然后切换到对应的view。于是我们有了一个简单的思路，首先我们要有一个TabBarView来显示Tab的Button，然后我们要为每一个TabButton对应设置好需要跳转的view。

```objective-c 
	UIView *tab1View;
	UIView *tab2View;
	UIView *tabBarView;
	UIViewController *tabBarController
	=[MyTabBarController new]; 
```

看来只需要一个ViewController我们就可以实现TabBar的跳转功能了。将上述定义的View作为Subview加入到tabBarController的view上面，然后为tabBarView上面的按钮写事件处理函数，在对应的tabBarButton点击以后直接在tabBarController.view上面进行设置就行了。看起来很简单不是吗？其实这样做是不好的，首先每个tab对应的view之间其实是独立，按照这种实现的话所以逻辑都在一个Controller里面实现肯定是不合理的。还有一个非常不好的地方就是，每个tab的view的***View Events***将会比较难以处理。

#### 使用Container的方法

这次我们将每一屏的view分别放在各自的Controller里面去，然后我们定义这样一个Container Controller去管理这些View Controller。模仿UITabbar的接口，我们可以如下定义一个自定义的TabBarController：

```objective-c

#import <UIKit/UIKit.h>
#import "FMTabbarView.h"

@protocol FMTabBarControllerDelegate;

@interface FMTabBarController : UIViewController<FMTabbarViewDelegate>

@property (nonatomic,copy) NSArray *viewControllers;
@property (nonatomic,assign) UIViewController *selectedViewController;
@property (nonatomic,assign) NSUInteger selectedIndex;

@property (nonatomic, assign) id <FMTabBarControllerDelegate> delegate;

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)setSelectedViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

/*
 * The delegate protocol .
 */
@protocol FMTabBarControllerDelegate <NSObject>
@optional
- (BOOL)fm_tabBarController:(FMTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)fm_tabBarController:(FMTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
@end

```

具体的实现思路是这样的：在TabBarController里面我们将整个屏幕（也就是TabBarController 自身属性对应那个view）分为TabbarView的区域和content区域，简单来说就是定义两个不同的子view来作为TabBarView和各个Tab对应的Controller的view：

```objective-c
@property (nonatomic,retain) FMTabbarView *myTabbarView;
@property (nonatomic,retain) UIView *contentViewContainer;

...
[self.view addSubview:myTabbarView];
[self.view addSubview:contentViewContainer];

```
然后在Tab切换的时候将不同的tabViewController对应的view add到contentViewContainer上面就可以了。这个层级结构可以参考一下UITabBarController的结构：

![UITabBarController hierachy](/images/tabbar_controllerviews.jpg);

通过这种方式自定义TabBarController就给了你完全的自由，可以随心所欲的定制TabBar的外观了。

我们可以按照一般的初始化方法去使用这个自定义的TabBarController：

```objective-c
FMTabBarController *tabbarController = [[FMTabBarController alloc] init];
    UIViewController *discoverController = [[FMDiscoverController alloc] initWithNibName:nil bundle:nil];
    UIViewController *myMusicViewController = [[FMMyMusicController alloc] initWithNibName:nil bundle:nil];
    tabbarController.viewControllers = @[discoverController, myMusicViewController];
    self.window.rootViewController = tabbarController;

```

资源
===

这是我写的一个项目，里面用到了一个自定义的FMTabBarController，需要代码可以到[github](https://github.com/nightwolf-chen/DoubanFM_IOS)。

参考资料：[MHTabBarController](https://github.com/hollance/MHTabBarController)
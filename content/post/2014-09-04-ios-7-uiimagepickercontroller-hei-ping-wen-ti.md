---
categories: [ios,bug,UIImagePicker]
comments: true
layout: post
date: 2014-09-04
status: public
title: iOS 7 UIImagePicker 黑屏问题
---

前几天一个同事遇到一个很奇怪的bug，就是有时候iOS 7上面的UIImagePicker（也就是照相的那个界面）出现黑屏。具体来说就是在多次进入UIImagePicker的时候，有时候preview会出现较长一段时间的黑屏。

我们一起看了具体的代码，就逻辑而言没有看出什么问题。一般的代码都是类似于这样调用相机的

```objective-c
UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
photoPicker.delegate = self;
photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
[self presentViewController:photoPicker animated:YES completion:NULL];

```

我在网上搜索解决方案时发现这个问题在iOS 7上面比较常见，而且目前没有人能够给出一个具体合理的解释。这可能是iOS 7系统的一个bug，因为一个同事在iOS 6上面试过没有出现同样的问题。努力了一段时间最终还是解决了这个bug，总结一下这个bug的原因和解法。

#### 由于多次初始化UIImagePicker内存泄露导致的问题

这个原因是一种猜测，有一些人遇到这种问题的解决方案是尽量减少UIImagePicker初始化次数。有人在监视UIImagePicker的时候发现了内存泄露问题，在这种情况下可以在使用UIImagePicker的时候只初始化一次方法。我甚至发现了有个人将UIImagePicker做成单例来解决问题。按照上面对picker的使用代码，可以对应这样修改：

```objective-c
//只在一个要使用的地方初始化一次

-(UIImagePickerController *)imagePicker{
    if(!_imagePicker){
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    return _imagePicker;
}

[self presentViewController:self.imagePicker animated:YES completion:nil];

```

我试过了这个方法但是不见效，所以我的问题不是这个问题导致的。

#### 主要原因：在非主线程操作UI

后来我在StackOverflow上面看到一个非常详细的帖子[this](http://stackoverflow.com/questions/19081701/ios-7-uiimagepickercontroller-has-black-preview)

里面提到了一个非常容易忽略的问题：在非主线程操作UI。
那么怎样才算是***操作UI呢***？这里有一个可以100%复现这个bug的项目：[bug复现的demo](https://github.com/bartvandeweerdt/CameraTest)

这个demo里面在子线程里面做了如下操作：

```objective-c
// 子线程操作

  @autoreleasepool {
        self.theView = [[UIView alloc] init];
        
        for (int i = 0 ; i < 2 ; i++) {
            NSLog(@"%f", sqrt(i));
        }
        
        [(NSObject *) self.delegate performSelectorOnMainThread:@selector(operationDidFinish:) withObject:self waitUntilDone:NO];

    }


```
子线程里面只是初始化了了一个UIView，这就算是UI操作，然后就导致了这个bug发生。你可以试一下注释掉UIView初始化那一句，bug竟然就不出现了，真是很神奇啊。这的确是iOS 7本身的一个bug。


我们所遇到的黑屏就是这个原因导致的，随后我们也排查了比较长一段时间，竟然是因为在***子线程里面dealloc了一个UIImageView***！

#### 一段神代码

我还发现了一段神代码，你只要将这个文件放到你的项目里面，当你在非主线程操作UI的更新操作的时候就抛异常！是不是很神奇？就像一个守卫一样保护着。它的实现原理就是在应用启动的时候将UIView的setNeedsDisplay等更新方法method swizzling一下，在对应方法调用的时候加入是否在主线程的判断逻辑。
代码链接:[PSPDFUIKitMainThreadGuard.m](https://gist.github.com/steipete/5664345)

使用它，你只需要把它放到你的工程里面，不需要更多的操作了，Good luck！

#### 永远不要在主线程以外的线程进行UIView相关的操作

这其实在苹果的UIView programm guide里面已经强调了，不过看来很多人都会忽略到这一点。如果你真这样做了，UI就可能会出现一些奇奇怪怪的问题，不止是黑屏那么简单了！
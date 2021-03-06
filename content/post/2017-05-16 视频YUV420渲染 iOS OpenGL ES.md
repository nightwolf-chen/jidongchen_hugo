---
date: 2017-05-16
status: public
title: '视频帧YUV420渲染 iOS OpenGL ES'
categories: [ios,opengl]
---

在前面一篇[播放器原理](http://www.jidongchen.com/post/2017-04-10-ffmpeg+sdl2.0)文章中我主要讨论了一下播放器的主要流程。我在这篇文章中重点谈论一下视频帧的渲染。

## YUV420简介
想要渲染YUV我们首先简要了解一下YUV这种数据格式。
### YUV是一种颜色编码方式
首先我们需要明确的是YUV是一种颜色编码方式，也就是说跟我们熟悉的RGB同样用于编码颜色一种数据格式。彩色图像记录的格式常见的有RGB、YUV、CMYK等。

### YUV的存储方式
我们都知道RGB是按照Red，Green，Blue三原色的色度来表示彩色图像的。但是YUV跟RGB有着比较大的差别，首先YUV中Y（Luma，Luminance）表示灰度值，UV一起表示色度值。
YUV有两种存储方式：
* 紧缩格式（packed formats）：将Y、U、V值储存成Macro Pixels阵列，和RGB的存放方式类似。
* 平面格式（planar formats）：将Y、U、V的三个分量分别存放在不同的矩阵中。
我的经验里面平面格式比较常见，可能是由于简单易于理解吧。
### YUV的历史原因
YUV产生于黑白电视和彩色电视的过渡时期，使用YUV格式可以兼容黑白电视信号，对于黑白电视只需要使用Y值就够了。更重要的是YUV相对于RGB占用的带宽非常小。
具体细节可以参看百科：
[维基百科](https://zh.wikipedia.org/wiki/YUV)
[百度百科](http://baike.baidu.com/item/YUV)
### YUV与RGB的转换
同样为颜色编码YUV和RGB是可以互相转换的，有特定的公式来做这个转换，例如RGB转换YUV：
``` c
Y = 0.299*R + 0.587*G + 0.114*B
U = -0.169*R - 0.331*G + 0.5*B + 128
v = 0.5*R - 0.419*G - 0.081*B + 128 
```
相反的YUV转换RGB：
```c
R = Y + 1.13983*(V - 128)
G = Y - 0.39465 * (U - 128) - 0.58060*(V - 128)
B = Y + 2.03211*(U - 128)
```
对于线性代数比较熟悉的同学可能已经发现了，这个是一个矩阵变换，也就是矩阵乘法得到的结果。实际上在摄像机和电视里面这个变换是通过专门的硬件电路来实现的。我们也可以通过CPU去做这些运算，不过将会消耗比较大的CPU运算资源。

## YUV的渲染
需要特别提一下我这里说的YUV都是特指YUV420。通过对YUV格式的简要了解，我们知道YUV和RGB是可以互相转换的。那么最为直接的方法就是将YUV先转换为RGB然后可以有很多方法将RGB数据渲染到屏幕上面。比如使用OpenGL Texture的方式。然而这种方式最大的问题就是大量的CPU运算造成的性能瓶颈。
### 利用OpenGL shader做矩阵变换
使用这种方法需要了解一些OpenGL的知识。GPU是专门设计成做矩阵运算的硬件，所以我们使用OpenGL提供的接口让GPU去做颜色YUV到RGB的转换，这样可以大大优化性能。而这种方式就是利用OpenGL提供的Shader来做转换运算，大致思路是将YUV的三个分量分别作为Texture上载到GPU，然后在Fragment Shader中取YUV三个分量转换成RBG然后进行显示。OpenGL相关的知识可以参考：[OpenGL参考资料](https://learnopengl.com/#!Getting-started/Shaders)。
### OpenGL YUV 渲染Demo
[代码github](https://github.com/nightwolf-chen/JDCFFPlayer)
```c
git clone https://github.com/nightwolf-chen/JDCFFPlayer
git checkout opengl_texture
``` 
里面使用了kxmovie里面实现的GLView进行视频渲染。C实现的播放器被封装在JDCMediaPlayer里面，解码得到AVFrame以后简单转换成kxmovie使用的frame
```objc
- (void)render:(JDCAVFrame *)frame
{
    CGFloat originWidth = _frameWidth;
    _frameheight = frame.frameHeight;
    _frameWidth = frame.frameWidth;
    if (originWidth == 0) {
        [self updateVertices];
        [self kx_render: nil];
    }
    [self kx_render:[self handleVideoFrame:frame]];
}
```
在GLView里面有这样一段代码，去分别为YUV三个分量生成三个不同的Texture
```objc
- (void) setFrame: (KxVideoFrame *) frame
{
    KxVideoFrameYUV *yuvFrame = (KxVideoFrameYUV *)frame;
    
    assert(yuvFrame.luma.length == yuvFrame.width * yuvFrame.height);
    assert(yuvFrame.chromaB.length == (yuvFrame.width * yuvFrame.height) / 4);
    assert(yuvFrame.chromaR.length == (yuvFrame.width * yuvFrame.height) / 4);

    const NSUInteger frameWidth = frame.width;
    const NSUInteger frameHeight = frame.height;    
    
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    if (0 == _textures[0])
        glGenTextures(3, _textures);

    const UInt8 *pixels[3] = { yuvFrame.luma.bytes, yuvFrame.chromaB.bytes, yuvFrame.chromaR.bytes };
    const NSUInteger widths[3]  = { frameWidth, frameWidth / 2, frameWidth / 2 };
    const NSUInteger heights[3] = { frameHeight, frameHeight / 2, frameHeight / 2 };
    
    for (int i = 0; i < 3; ++i) {
        
        glBindTexture(GL_TEXTURE_2D, _textures[i]);
        
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_LUMINANCE,
                     widths[i],
                     heights[i],
                     0,
                     GL_LUMINANCE,
                     GL_UNSIGNED_BYTE,
                     pixels[i]);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }     
}
```
Fragment Shader拿到YUV分量进行运算最终得到RGB颜色用于着色shader:
```c
varying highp vec2 v_texcoord;
 uniform sampler2D s_texture_y;
 uniform sampler2D s_texture_u;
 uniform sampler2D s_texture_v;
 
 void main()
 {
     highp float y = texture2D(s_texture_y, v_texcoord).r;
     highp float u = texture2D(s_texture_u, v_texcoord).r - 0.5;
     highp float v = texture2D(s_texture_v, v_texcoord).r - 0.5;
     
     highp float r = y +             1.402 * v;
     highp float g = y - 0.344 * u - 0.714 * v;
     highp float b = y + 1.772 * u;
     
     gl_FragColor = vec4(r,g,b,1.0);     
 }
```

## 总结
这篇文章我讨论了YUV颜色格式，并且实现了iOSDemo，代码请见[github](https://github.com/nightwolf-chen/JDCFFPlayer/tree/opengl_texture)。

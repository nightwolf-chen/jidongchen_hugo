---
categories: [ios]
comments: true
date: 2015-01-31 
layout: post
status: public
title: 一个横向UITableView的实现
---

### 完整代码
[github完整代码](https://github.com/nightwolf-chen/JDCHorizontalTableView)。
# UITableView
UITableView是UIKit里面常用的类，几乎所有的ios app都离不开这个组件。它提供了一种连续滚动，分段显示view的ui体验，使得有限屏幕大小有着更丰富的ui体验。

#### UITableView一些设计理念
UITableView里面使用到了delegate模式和模板模式（datasource），datasource里面定义一组接口规范UITableView数据来源，比如说：cellForRowAtIndexPath
numberOfRowsInSection,UITableView的两个关键方法。简而言之，你只要按照要求提供cell的数量和提供cell的样式，接下来所有事情UITableView就会帮你做。

#### UITableView做了什么

#### cell的布局
那么UITableView为我们做了什么呢？UITableView是UIScrollView的子类，这给了UITableView可以滚动的天然特性，从外表看起来UITableView主要是实现了对cell的布局和展示。UITableView自动的按照顺序将所有的cell进行布局放到scroll上面。更深入进去，我们可以发现UITableView在cell的使用上面进行了优化，其中一点就是对cell的复用。
#### cell的复用及原理
cell的复用采用了享元模式，当cell的数量多的时候每次都重新初始化cell是很浪费资源的。因为任何时候可见的cell数量是有限的，cell应该被复用。UITableView有一个方法
dequeueReusableCellWithIdentifier，用来获取可复用的cell，UITableView的复用标准写法如下：

``` Objective-C 

UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

if (nil == cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:CellIdentifier];
}

// Do something to cell

return cell;

```

UITableView 维护一个cell pool，当cell不可见的时候cell会被回收到这个pool里面。需要输出cell之前先尝试从这个pool里面获取可复用的cell，这样便可达到复用的目的。

# 自己实现一个水平滚动的TableView
我们平时多用的是垂直滚动的tableview，有时候我们也需要水平滚动的tableview，反正我最近是遇到了这种需求。实现水平滚动有很多方法，UICollectionView，UIScrollView，还有一种将UITableView进行旋转的方法可以 [参考这里](http://stackoverflow.com/questions/2778521/iphone-tableview-use-cells-in-horizontal-scrolling-not-vertical)。

既然前面我们已经大致了解了tableview的原理，这里我们自己尝试实现一个水平滚动的tableview。简单起见，我们这里只是实现主要的布局和cell复用功能，忽略section和其它一些细节。

#### 基本思路
首先tableview继承于UIScrollView，tableview在加载数据的时候需要进行以下几个操作：

>1. 根据index计算出每一个cell在scroll上的位置，因为我们实现的tableview是水平滚动
   的，所以我们需要delegate提供cell的宽度，否则则使用默认的宽度
>2. 根据当前scroll的offset，也就是当前滚动的位置来显示cell。
>3. 将不可见的cell回收以便复用。
	（2，3步是循环进行的）

有了这个思路以后，我们可以简单的写出tableview 的reloadData方法

``` Objective-C 

- (void) reloadData
{
    [self returnNonVisibleColumsToThePool:nil];
    [self generateWidthAndOffsetData];
    [self layoutTableColums];
}

```

#### 计算cell的位置
因为cell的宽度（通过delegate获取或者使用默认）和高度（和tableview的高度一致），我们可以通过简单的数学计算将每一个cell的位置都计算出来，这个操作在reloadData的时候进行：

``` Objective-C 

- (void) generateWidthAndOffsetData
{
    CGFloat currentOffsetX = 0.0;
    
    BOOL checkWidthForEachColum = [[self delegate] respondsToSelector: @selector(ps_tableViewWidthForColum:colum:)];
    
    NSMutableArray* newColumModels = [NSMutableArray array];
    
    NSInteger numberOfColums = [[self dataSource] numberOfColums:self];
    
    for (NSInteger colum = 0; colum < numberOfColums; colum++)
    {
        PSHorizontalTableCellModel* columModel = [[PSHorizontalTableCellModel alloc] init];
        
        CGFloat columWidth = checkWidthForEachColum ? [[self delegate] ps_tableViewWidthForColum:self colum:colum] : [self columWidth];
        
        columModel.width = columWidth + kColumMargin;
        columModel.startX = currentOffsetX + kColumMargin;
        
        [newColumModels addObject:columModel];
        
        currentOffsetX += (columWidth + kColumMargin);
    }
    
    self.columModels = newColumModels;
    
    [self setContentSize: CGSizeMake(currentOffsetX, self.bounds.size.height)];
}

```
我们将计算好的cell数据存放到一个数组里面，他们的下标和index一一对应。

#### 显示cell
cell的位置数据都计算好以后，就是cell的显示了。这部分应该是tableview的核心功能。简单的来将，就是根据UIScrollView当前的offset来决定要显示哪些cell，因为scrollview的offset变化的频率是很高的，所以我们要能快速找到要显示的cell。

我们以scrollview的左边开始找，首先找到第一个可见的cell，接下来只需要在可见区域内依次逐个显示接下来的可见cell就可以了（从左往右铺）。那么怎么确定当前的offset左边第一个cell的index是什么呢？ 我们很容易得出结论满足cell.startX >= offset.x && offset.x < cell.startX + width就是我们要找的cell。很容易想到方法是遍历我们刚刚计算好的cell位置的数组,这个方法的确是可行的，但是我们前面说过了，offset变化非常频繁，每一次offset的改变我们都需要执行一次这种查找。我们要尽可能提高这种查找效率。

仔细想想，cell的位置数据是天然有序的，这里我们可以用到二分查找来优化，这样大大地提高了效率。下面给出根据offset查找cell index 的方法

``` Objective-C 

- (NSInteger) findColumForOffsetX: (CGFloat) xPosition inRange: (NSRange) range
{
    if ([[self columModels] count] == 0) return 0;
    
    PSHorizontalTableCellModel* cellModel = [[PSHorizontalTableCellModel alloc] init];
    cellModel.startX = xPosition;
    
    NSInteger returnValue = [[self columModels] indexOfObject: cellModel
                                                inSortedRange: range
                                                      options: NSBinarySearchingInsertionIndex
                                              usingComparator: ^NSComparisonResult(PSHorizontalTableCellModel* cellModel1, PSHorizontalTableCellModel* cellModel2){
                                                     if (cellModel1.startX < cellModel2.startX)
                                                         return NSOrderedAscending;
                                                     return NSOrderedDescending;
                                             }];
    if (returnValue == 0) return 0;
    return returnValue-1;
}

```

#### 将cell放到scrollview上面去
前面我们已经知道了每一个cell的位置，也有实现了查找当前需要显示的cell的index的方法。接下来就是要往scrollview上面放cell了。思路也很直接，从最左边的开始放如果没有超出右边界就一直尝试放下一个，这里给出具体实现：
``` Objective-C  
- (void) layoutTableColums
{
    if (_columModels.count <= 0) {
        return;
    }
    
    CGFloat currentStartX = [self contentOffset].x;
    CGFloat currentEndX = currentStartX + [self frame].size.width;
    
    NSInteger columToDisplay = [self findColumForOffsetX:currentStartX inRange:NSMakeRange(0, _columModels.count)];
    
    NSMutableIndexSet* newVisibleColums = [[NSMutableIndexSet alloc] init];
    
    CGFloat xOrgin;
    CGFloat columWidth;
    do
    {
        [newVisibleColums addIndex: columToDisplay];
        
        xOrgin = [self cellModelAtIndex:columToDisplay].startX;
        columWidth = [self cellModelAtIndex:columToDisplay].width;
        
        PSHorizontalTableCell *cell = [self cellModelAtIndex:columToDisplay].cachedCell;
        
        if (!cell)
        {
            cell = [[self dataSource] ps_tableView:self columForIndexPath:columToDisplay];
            [self cellModelAtIndex:columToDisplay].cachedCell = cell;
            
            cell.frame = CGRectMake(xOrgin, 0, columWidth - kColumMargin, self.bounds.size.height);
            [self addSubview: cell];
        }
        
        columToDisplay++;
    }
    while (xOrgin + columWidth < currentEndX && columToDisplay < _columModels.count);
    
    
//    NSLog(@"laying out %ld row", [_columModels count]);
    
    //将已经不可见的cell进行回收
    [self returnNonVisibleColumsToThePool:newVisibleColums];
}

//offset改变的时候要调用layoutColums
- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    [self layoutTableColums];
}


```
每一次offset发生变化，都要调用这个方法刷新cell，当前已经可见的cell没必要多次处理，所以这其中做了缓存处理。


#### cell的回收和复用
##### 回收
为了实现cell的回收我们要维护一个cell池，我们这里使用的数据结构是队列（NSMutableArray）。每一次offset改变cell都有可能从可见变成不可见，所以在cell刷新的最后要将不可见的cell回收放入到可复用cell池当中。思路比较直接，因为我们这里维护了可见cell的index，所以每一次刷新cell以后得到新的可见cell和之前旧的可见cell进行比较就可以找出需要回收的cell。

``` Objective-C
- (void) returnNonVisibleColumsToThePool: (NSMutableIndexSet*) currentVisibleColums
{
    [_visibleColums removeIndexes:currentVisibleColums];
    [_visibleColums enumerateIndexesUsingBlock:^(NSUInteger columIdx, BOOL *stop){
         PSHorizontalTableCell* tableViewCell = [self cellModelAtIndex:columIdx].cachedCell;
         if (tableViewCell)
         {
             [_resuableColumes addObject:tableViewCell];
             [tableViewCell removeFromSuperview];
             [self cellModelAtIndex:columIdx].cachedCell = nil;
         }
     }];
    
    self.visibleColums = currentVisibleColums;
}
```
##### 复用
复用的话，就是我们平时非常熟悉的dequeueReusableCellWithIdentifier，实现比较简单，只要遍历我们前面维护的可复用cell池，找到对应的reusable identifier就行了。

``` Objective-C
- (PSHorizontalTableCell *)dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier
{
    PSHorizontalTableCell *poolCell = nil;
    
    for(PSHorizontalTableCell *cell in _resuableColumes){
        if ([cell.reusableIdentifier isEqual:reuseIdentifier]) {
            poolCell = cell;
            break;
        }
    }
    
    if (poolCell) {
        [_resuableColumes removeObject:poolCell];
    }
    
    return poolCell;
}
```

# 总结
这样一来，我们就实现了一个可以使用的水平UITableView了。我还省略了一些细节，完整的源代码请到[github](https://github.com/nightwolf-chen/JDCHorizontalTableView)。

总结一下UITableView实现过程当中的几个关键：

>1.预先计算每个cell的位置。

>2.高效地寻找当前需要显示的cell（二分查找）。

>3.根据offset变化对cell布局然后进行回收复用。

这样看起来，UITableView也是可以轻松理解的。
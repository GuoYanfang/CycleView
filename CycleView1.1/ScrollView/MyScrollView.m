//
//  MyScrollView.m
//  ScrollView
//
//  Created by 郭艳芳 on 16/1/7.
//  Copyright © 2016年 郭艳芳. All rights reserved.
//

#import "MyScrollView.h"
#define TAGOFFSET 1000


// UIScrollView类目
@implementation UIScrollView (PageController)

- (NSInteger)numberOfPages {
    
    NSInteger pageNumber = self.contentSize.width / self.bounds.size.width;
    return pageNumber;
}

- (NSInteger)currentPage {
    NSInteger currentPage = floor((self.contentOffset.x - self.frame.size.width/2)/ self.frame.size.width) + 1;
    return currentPage;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    
    // 计算x偏移量
    CGFloat offsetX = self.bounds.size.width * currentPage;
    // 生成offset
    CGPoint offset = CGPointMake(offsetX, 0);
    [self setContentOffset:offset animated:animated];
    
}

- (void)autoChangePage {
    
    // 判断当前是否正在被拖拽和滑动
    if (![self isDecelerating] && ![self isDragging]) {
        // 如果是最后一页，显示第一页
        if (self.currentPage == [self numberOfPages] - 1) {
            self.currentPage = 1;
        }
        // 否则加1
        NSInteger cPage = self.currentPage + 1;
        [self setCurrentPage:cPage animated:YES];
    }
    
    [self performSelector:@selector(autoChangePage) withObject:nil afterDelay:3];
}


@end


@interface MyScrollView ()

@property (nonatomic, strong) UIScrollView *scrollView; // 滚动视图
@property (nonatomic, strong) UIPageControl *pageController; //页面控制
@property (nonatomic, strong) NSTimer *timer; // 自动播放定时器
@property (nonatomic, strong) NSMutableSet *reusebledViews; // 可重用视图集合

// 定时器关联自动播放方法
- (void)autoChangePicture:(NSTimer *)timer;

@end

@implementation MyScrollView

// 指定初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // 1.初始化ScrollView
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.scrollView.pagingEnabled = YES;
        // 隐藏水平滚动指示器
        self.scrollView.showsHorizontalScrollIndicator = NO;
        // 初始滚动大小为0
        self.scrollView.contentSize = CGSizeZero;
        [self addSubview:self.scrollView];
        
        // 2.设置滚动视图的代理
        self.scrollView.delegate = self;
        
        // 初始化定时器定时间隔， 默认3s
        self.timeInterval = 3.0f;
        
        // 3.创建可重用视图集合
        self.reusebledViews = [[NSMutableSet alloc] init];
        
    }
    
    return self;
}


// 重写pageControlEnable的setter方法
- (void)setPageControlEnable:(BOOL)pageControlEnable {
    
    if (_pageControlEnable != pageControlEnable) {
        
        _pageControlEnable = pageControlEnable;
        
        // 使能pageControl时加载
        if (_pageControlEnable == YES) {
            
            // 初始化pageControl
            self.pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20)];
            // 设置页面指示器颜色
            self.pageController.pageIndicatorTintColor = [UIColor grayColor];
            // 设置当前页面指示器的颜色
            self.pageController.currentPageIndicatorTintColor = [UIColor greenColor];
            // 添加事件
            [self.pageController addTarget:self action:@selector(pageControlChangePicture:) forControlEvents:UIControlEventValueChanged];
            // 设置页码数量
            [self.pageController setNumberOfPages:[self.imagePaths count]];
            [self addSubview:self.pageController];
            
        } else {
            
            // 禁用时移除
            [self.pageController removeFromSuperview];
        }
        
    }
    
}

// pageControl的valueChange关联的方法，改变滚动视图的当前页面
- (void)pageControlChangePicture:(UIPageControl *)pageControl {
    
    self.scrollView.currentPage = pageControl.currentPage + 1;
}


// 重写frame的setter方法，当改变view的frame时，scrollView和pageControl的frame跟着变动
- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    // 设置滚动视图和页面控制视图的frame
    self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    // 如果设置了pageControl，调整pageControl的frame
    if (_pageControlEnable == YES) {
        self.pageController.frame = CGRectMake(0, frame.size.height - 20, frame.size.width, 20);
    }
    
}

/**
 *  实现通过给定Bundle中的图片名称数组，给视图添加轮播图片的方法
 *
 *  @param imageNames 在Bundle中的图片数组名
 */
- (void)setImagePathsInBundle:(NSArray *)imageNames {
    
    // 创建imagePaths数组，存放image路径
    NSMutableArray *imagePaths = [NSMutableArray array];
    for (NSString *imageName in imageNames) {
        // 获得文件路径
        NSString *imagePath = [self getResourcePath:imageName];
        // 把文件路径添加到文件数组中
        [imagePaths addObject:imagePath];
    }
    
    // 设置轮播图片文件路径
    [self setImagePaths:imagePaths];
    
}

/**
 *  接收一个在Bundle中的图片名，返回图片路径
 *
 *  @param resourceName 在Bundle中的图片名称
 *
 *  @return 图片的路径
 */
- (NSString *)getResourcePath:(NSString *)resourceName {
    
    // 将图片名称分割成数组
    NSArray *names = [resourceName componentsSeparatedByString:@"."];
    // 获取文件扩展名
    NSString *lastName = [names lastObject];
    // 获取主文件名
    NSString *firstName = names.firstObject;
    // 获取资源路径
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:firstName ofType:lastName];
    return sourcePath;
    
}

// ImagePaths属性的setter, 该方法内实现ScrollView要轮播图片内容的设置和PageControl的属性设置
- (void)setImagePaths:(NSArray *)imagePaths {
    
    if (_imagePaths != imagePaths && [imagePaths count] != 0) {
        _imagePaths = imagePaths;
        
        // 移除scrollView上所有的imageView对象
        for (id view in self.scrollView.subviews) {
            if ([view isKindOfClass:[UIImageView class]] == YES) {
                [view removeFromSuperview];
            }
        }
        
        // 图片张数大于1时轮播显示
        if (self.imagePaths.count > 1) {
            // 根据图片数组详细设置scrollView的属性
            self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width*(imagePaths.count + 2), 0);
            CGRect rect = self.scrollView.bounds;
            for (int i = 0; i < 3; i++) {
                
                rect.origin.x = self.scrollView.bounds.size.width * i;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
                
                // 照片的索引
                NSInteger imageIndex = i;
                // 首页放最后一张照片
                if (imageIndex == 0) {
                    imageIndex = imagePaths.count - 1;
                } else {
                    imageIndex = i - 1;
                }
                
                imageView.image = [UIImage imageWithContentsOfFile:[self.imagePaths objectAtIndex:imageIndex]];
                imageView.tag = TAGOFFSET + i;
                [self.scrollView addSubview:imageView];
                
            }
            
            // 初始页码为1
            self.scrollView.tag = 1;
            // 显示第1页
            [self.scrollView setCurrentPage:1];
            
        } else { // 就一张照片
            self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, 0);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            imageView.image = [UIImage imageWithContentsOfFile:[imagePaths objectAtIndex:0]];
            [self.scrollView addSubview:imageView];
        }
        
        // 把滚动视图追加到视图上
        [self addSubview:self.scrollView];
        // 设置代理
        self.scrollView.delegate = self;
        // 设置按页滚动
        self.scrollView.pagingEnabled = YES;
        
        // 根据图片数组详细设置scrollView的属性
        if (_pageControlEnable == YES) {
            [_pageController setNumberOfPages:imagePaths.count];
        }
        
    }
    
}

/**
 *  属性AutoRunEnable的setter方法，该方法实现开启自动播放和禁止自动播放功能
 */
- (void)setAutoRunEnable:(BOOL)autoRunEnable {
    
    if (_autoRunEnable != autoRunEnable) {
        _autoRunEnable = autoRunEnable;
        
        if (autoRunEnable == YES) { // 开启自动轮播
            [self setAutoRunEnableWithInterval:_timeInterval];
        } else {
            // 禁止自动播放
            [_timer invalidate];
            _timer = nil;
        }
        
    }
    
}

/**
 *  属性timeInterval的setter方法，该方法实现在更新了时间间隔时，重新开启新的定时器的功能
 *
 */
- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    
    // 如果是新的时间间隔则更新
    if (_timeInterval != timeInterval) {
        _timeInterval = timeInterval;
        
        // 如果设置了自动播放，则重新设置定时器
        if (_autoRunEnable == YES) {
            [self setAutoRunEnableWithInterval:timeInterval];
        }
    }
    
}

/**
 *  实现能使自动播放，并设置自动播放的时间间隔
 *
 */
- (void)setAutoRunEnableWithInterval:(NSTimeInterval)timeInterval {
    
    if (timeInterval > 0.0f) {
        _autoRunEnable = YES;
        // 更新定时时间间隔
        _timeInterval = timeInterval;
        // 先把原来的定时器关掉
        [_timer invalidate];
        // 开启新的定时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(autoChangePicture:) userInfo:nil repeats:YES];
    } else {
        _autoRunEnable = NO;
        [_timer invalidate];
        _timer = nil;
    }
    
}


/**
 *  定时器关联自动播放方法，检测到页面在滚动或者用户在点击时，重新开启新的定时器，根据设定的播放方向轮番播放
 */
- (void)autoChangePicture:(NSTimer *)timer {
    
    // 只有1页，不轮播
    if (self.imagePaths.count == 1) {
        return;
    }
    
    // 读取当前页码
    NSInteger cunrrentPage = self.scrollView.currentPage;
    // 定义下一页页面变量
    NSInteger nextPage = 0;
    // 判断轮播方向
    switch (_playDirection) {
            
        case Left: // 往左轮播
            nextPage = cunrrentPage - 1;
            break;
        case Right: // 往右轮播
            nextPage = cunrrentPage + 1;
            break;
        default:
            break;
    }
    
    // 切换到下一页
    [self.scrollView setCurrentPage:nextPage animated:YES];
    
}


#pragma mark ScrollView 代理方法

// 开始拖拽时调用，用来关闭自动播放的定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    // 销毁定时器，暂停自动播放
    [self.timer invalidate];
    self.timer = nil;
    
}

// 停止减速时调用，用来重启定时器
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // 重新开启定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(autoChangePicture:) userInfo:nil repeats:YES];
    
}


// scrollView滚动时调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // 计算新页码，往高处取整
    int pageNumber = ceil(self.scrollView.contentOffset.x / self.scrollView.frame.size.width - 0.5);
    // 实现循环滚动，当滚动到最后一页时（放的是首页照片）把滚动视图的显示区域切换到第一页
    if (scrollView.contentOffset.x >= (self.imagePaths.count + 1) * scrollView.bounds.size.width) {
        
        // 把可重用的倒数第3页，放到第1页
        [self thePageNumberReuseabled:(self.imagePaths.count - 1) andThePageNumberWillBePlaced:1];
        
        // 把可重用的倒数第1页，放到第2页
        [self thePageNumberReuseabled:(self.imagePaths.count + 1) andThePageNumberWillBePlaced:2];
        
        // 把可重用的倒数第2页，放到第0页
        [self thePageNumberReuseabled:self.imagePaths.count andThePageNumberWillBePlaced:0];
        
        // 把页面切到第1页
        [scrollView setTag:1];
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
        
        return;
        
    } else if (scrollView.contentOffset.x <= 0.0f) {
        
        // 把可重用的第2页，放到倒数第2页
        [self thePageNumberReuseabled:2 andThePageNumberWillBePlaced:self.imagePaths.count];
        
        // 把可重用的第1页，放到倒数第1页
        [self thePageNumberReuseabled:1 andThePageNumberWillBePlaced:self.imagePaths.count + 1];
        
        // 把可重用的第0页，放到倒数第3页
        [self thePageNumberReuseabled:0 andThePageNumberWillBePlaced:self.imagePaths.count - 1];
        
        // 把页面切换到倒数第二页
        [scrollView setTag:self.imagePaths.count];
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width * self.imagePaths.count, 0);
        return;
        
    }
    
    // 当往右翻页时，并且不是最后一页时实现把当前不在可见范围的视图放进可重用集合，然后从可重用集合里取可重用的视图，放上对应的图片，放在当前页码的下一页上
    if (pageNumber > scrollView.tag && pageNumber != (self.imagePaths.count + 1)) { // 往右翻页
        [scrollView setTag:pageNumber];
        [self thePageNumberReuseabled:pageNumber - 2 andThePageNumberWillBePlaced:pageNumber + 1];
        
    } else if (pageNumber < scrollView.tag && pageNumber != 0) { //当往左翻页时，并且不是最后一页时
        
        [scrollView setTag:pageNumber];
        [self thePageNumberReuseabled:pageNumber + 2 andThePageNumberWillBePlaced:pageNumber - 1];
        
    }
    
    // 如果要显示pageControl，则需要进行页面调整
    if (_pageControlEnable == YES) {
        if (pageNumber == 0) {
            _pageController.currentPage = self.imagePaths.count;
        } else if (pageNumber == 1 || pageNumber == self.imagePaths.count + 1) {
            
            _pageController.currentPage = 0;
            
        } else {
            _pageController.currentPage = pageNumber - 1;
        }
    }
    
}

/**
 *  实现把指定页码的可重用视图放进可重用集合里，并从可重用视图集合里取一个视图放到要重用的页码上，并加载上对应的视图
 *
 *  @param srcPageNumber  不在可视范围内的图片页码，要放入可重用集合里的页码
 *  @param destPageNumber 将要显示的页码，即从可重用集合里取视图放在该页面上
 */
- (void)thePageNumberReuseabled:(NSInteger)srcPageNumber andThePageNumberWillBePlaced:(NSInteger)destPageNumber {
    
    // 实现把指定页码的可重用视图放进可重用集合
    UIImageView *reusebledView = (UIImageView *)[self.scrollView viewWithTag:(TAGOFFSET + srcPageNumber)];
    // 把当前不显示的view放进可重用集合里
    if (reusebledView != nil) {
        [self.reusebledViews addObject:reusebledView];
    }
    
    // 从可重用视图集合里取一个视图放到指定的页码上，并加载上对应的图片
    UIImageView *rView = [self.reusebledViews anyObject];
    
    // 如果没有可重用的view,则创建一个
    if (rView == nil) {
        rView = [[UIImageView alloc] init];
        [self.scrollView addSubview:rView];
    } else {
        
        // 如果找到了可重用的view，把它移除可重用集合
        [self.reusebledViews removeObject:rView];
    }
    
    // 为view设置tag值，供下次通过它查找其他view的计算服务
    [rView setTag:TAGOFFSET + destPageNumber];
    
    // 为view设置新的frame
    CGRect rect = self.scrollView.bounds;
    rect.origin.x = rect.size.width * destPageNumber;
    rView.frame = rect;
    
    // 为view找图片索引
    NSInteger imageIndex;
    if (destPageNumber == 0) { // 首页放最后一张
        imageIndex = self.imagePaths.count - 1;
    } else if (destPageNumber == self.imagePaths.count + 1) { // 最后一张放首页图片
        imageIndex = 0;
    } else {
        imageIndex = destPageNumber - 1;
    }
    
    // 为view获取对应的图片路径
    NSString *imagePath = [self.imagePaths objectAtIndex:imageIndex];
    // 设置对应的图片
    rView.image = [UIImage imageWithContentsOfFile:imagePath];
    
}










@end

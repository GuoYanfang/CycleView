//
//  CycleScrollView.m
//  CycleView
//
//  Created by 郭艳芳 on 16/1/11.
//  Copyright © 2016年 郭艳芳. All rights reserved.
//

#import "CycleScrollView.h"
#import "NSTimer+Addition.h"

@interface CycleScrollView ()

@property (nonatomic, strong) UIScrollView *scrollView; // 滑动视图
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *animationTimer; // 定时器

@property (nonatomic, assign) NSTimeInterval animationDuration; // 动画延迟

@property (nonatomic, assign) NSInteger currentPageIndex; // 当前页数

@property (nonatomic, strong) NSMutableArray *contentViews; // 内容视图数组


@end

@implementation CycleScrollView

#pragma mark --初始化方法--
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES; // 设置子视图自动调整布局
        self.currentPageIndex = 0; // 默认当前是第一页
        
        // 创建UIScrollView对象
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3*CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame)); // 3倍屏幕宽
        self.scrollView.delegate = self;
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0); // 显示中间的位置
        self.scrollView.pagingEnabled = YES;
        self.scrollView.bounces = NO; // 不允许反弹
        self.scrollView.showsHorizontalScrollIndicator = NO; // 关闭水平显示条
        [self addSubview:self.scrollView];
        
        // 创建UIPageControl对象
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.scrollView.frame)-100, CGRectGetHeight(self.scrollView.frame)-30, 100, 30)];
        [self addSubview:self.pageControl];
        
    }
    return self;
}

// 自定义初始化方法
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration {
    
    self = [self initWithFrame:frame];
    if (animationDuration > 0.0) {
        // 创建定时器对象，按照传入的时间间隔定时方法
//        self.animationTimer = [NSTimer timerWithTimeInterval:animationDuration target:self selector:@selector(animationTimeDidFired:) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop]addTimer:_animationTimer forMode:NSRunLoopCommonModes];

        self.animationDuration = animationDuration;
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationDuration target:self selector:@selector(animationTimeDidFired:) userInfo:nil repeats:YES];
        
        [self.animationTimer pauseTimer];
    }
    return self;
    
}

#pragma  mark --NSTimer定时方法--
- (void)animationTimeDidFired:(NSTimer *)timer {
    
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x+CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];
    
}

// 重写totalPageCount的setter
- (void)setTotalPageCount:(NSInteger)totalPageCount {
    
    _totalPageCount = totalPageCount;
    if (_totalPageCount > 0) {
        [self configContentViews];
        [self.animationTimer resumeTimerAfterTimerInterval:self.animationDuration];
        _pageControl.numberOfPages = _totalPageCount;
    }
    
}

// 配置内容页面
- (void)configContentViews {
    
    // 将scrollView上的视图全部移除
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews) {
        contentView.userInteractionEnabled = YES;
        
        // 添加单击手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
        CGRect rightRect = contentView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame)*(counter++), 0);
        contentView.frame = rightRect;
        [self.scrollView addSubview:contentView];
        
    }
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}


// 设置ScrollView的内容数据
- (void)setScrollViewContentDataSource {
    
    if (self.contentViews == nil) {
        self.contentViews = [@[] mutableCopy];
    }
    [self.contentViews removeAllObjects];
    
    // 获取前一个位置和后一个位置
    NSInteger beforePageIndex = [self getNextPageIndex:self.currentPageIndex - 1];
    NSInteger afterPageIndex = [self getNextPageIndex:self.currentPageIndex + 1];
    if (self.fetchontentViewtIndex) {
        [self.contentViews addObject:self.fetchontentViewtIndex(beforePageIndex)];
        [self.contentViews addObject:self.fetchontentViewtIndex(_currentPageIndex)];
        [self.contentViews addObject:self.fetchontentViewtIndex(afterPageIndex)];
    }
    
}

// 获取下一个页面位置
- (NSInteger)getNextPageIndex:(NSInteger)currentPageIndex{
    
    if (currentPageIndex == -1) { // 如果当前是第一页，向右划的情况下，返回最后一页
        return self.totalPageCount - 1;
    } else if (currentPageIndex == self.totalPageCount) { // 如果当前是最后一页，显示第一页
        return 0;
    } else {
        return currentPageIndex;
    }
    
}

// 点击页面进行回调
- (void)contentViewTapAction:(UITapGestureRecognizer *)gesture {
    
    if (self.TapActionBlock) {
        self.TapActionBlock(self.currentPageIndex);
    }
    
}

#pragma mark --UIScrollView的回调方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    // 滑动视图时将定时器暂停，防止手动滑动与自动滚动冲突
    [self.animationTimer pauseTimer];
//    [self.animationTimer invalidate];
//    self.animationTimer = nil;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    // 手动滑动结束后，计时器继续
    [self.animationTimer resumeTimerAfterTimerInterval:self.animationDuration];
//    if (self.animationTimer == nil) {
//        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration target:self selector:@selector(animationTimeDidFired:) userInfo:nil repeats:YES];
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    int contentOffsetX = scrollView.contentOffset.x;
    if (contentOffsetX >= 2*(CGRectGetWidth(scrollView.frame))) {
        self.currentPageIndex = [self getNextPageIndex:self.currentPageIndex + 1];
        [self configContentViews];
    }
    if (contentOffsetX <= 0) { // 向右滑动
        self.currentPageIndex = [self getNextPageIndex:self.currentPageIndex - 1];
        [self configContentViews];
    }
    _pageControl.currentPage = self.currentPageIndex;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

@end

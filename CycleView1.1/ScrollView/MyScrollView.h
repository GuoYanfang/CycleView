//
//  MyScrollView.h
//  ScrollView
//
//  Created by 郭艳芳 on 16/1/7.
//  Copyright © 2016年 郭艳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    
    Right = 0, // 循环向右播放
    Left = 1   // 循环向左播放
    
}PlayDirectionType;

@interface MyScrollView : UIView<UIScrollViewDelegate>

/**
 *  自动轮播的图片数组（存放图片路径）
 */
@property (nonatomic, strong) NSArray *imagePaths;


/**
 *  轮播图的播放时间间隔，在设置允许自动播放前设置，单位s
 */
@property (nonatomic, assign) NSTimeInterval timeInterval;


/**
 *  设置是否允许自动播放，默认不播放，如果没有设置播放时间间隔，默认是3s
 */
@property (nonatomic, assign) BOOL autoRunEnable;


/**
 *  设置是否生成pageControl
 */
@property (nonatomic, assign) BOOL pageControlEnable;


/**
 *  自动播放方向
 */
@property (nonatomic, assign) PlayDirectionType playDirection;


/**
 *  实现通过给定Bundle中的图片名称数组，给视图添加轮播图片的方法
 */
- (void)setImagePathsInBundle:(NSArray *)imageNames;


/**
 *  设置自动播放及轮播时间间隔
 */
- (void)setAutoRunEnableWithInterval:(NSTimeInterval)timeInterval;


@end


// UIScrollView类目
@interface UIScrollView (PageController)

@property (nonatomic, assign) NSInteger currentPage;

- (NSInteger)numberOfPages;

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

- (void)autoChangePage;


@end

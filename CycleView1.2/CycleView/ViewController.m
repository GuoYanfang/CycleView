//
//  ViewController.m
//  CycleView
//
//  Created by 郭艳芳 on 16/1/11.
//  Copyright © 2016年 郭艳芳. All rights reserved.
//

#import "ViewController.h"
#import "CycleScrollView.h"
#import "UIImageView+WebCache.h"

@interface ViewController ()

@property (nonatomic, strong) CycleScrollView *cycleScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *string = @"http://img2.a0bi.com/upload/ttq/20140722/1405995619576_middle.jpg";
    NSString *string1 = @"http://ww2.sinaimg.cn/mw600/c6c1d258jw1e5r59ttpkcj20gu0gsmyh.jpg";
    NSString *string2 = @"http://ww1.sinaimg.cn/mw600/bce7ca57gw1e4rg0coeqqj20dw099myu.jpg";
    NSString *string3 = @"http://imgsrc.baidu.com/forum/w%3D580/sign=7fc5b239b9a1cd1105b672288912c8b0/51b0f603738da977be0bd022b351f8198618e3b7.jpg";
    NSMutableArray *strArray = [NSMutableArray arrayWithObjects:string, string1, string2, string3, nil];
    
    self.cycleScrollView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200) animationDuration:5];
    NSMutableArray *viewsArray = [@[] mutableCopy];
    for (int i = 0; i < strArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_cycleScrollView.bounds];
        [imageView sd_setImageWithURL:[NSURL URLWithString:strArray[i]]];
        [viewsArray addObject:imageView];
    }

    [self.view addSubview:_cycleScrollView];
    _cycleScrollView.fetchontentViewtIndex = ^UIView *(NSInteger pageIndex) {
      
        return viewsArray[pageIndex];
    };
    _cycleScrollView.totalPageCount = viewsArray.count;
    
    
    _cycleScrollView.TapActionBlock = ^(NSInteger pageIndex) {
      
        NSLog(@"点击了第%ld个", pageIndex);
    };
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

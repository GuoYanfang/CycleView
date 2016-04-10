//
//  ViewController.m
//  ScrollView
//
//  Created by 郭艳芳 on 16/1/4.
//  Copyright © 2016年 郭艳芳. All rights reserved.
//

#import "ViewController.h"
#import "MyScrollView.h"

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong)NSMutableArray *imageNames;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageNames = [NSMutableArray arrayWithObjects:
                       @"h1.jpeg",
                       @"h2.jpeg",
                       @"h3.jpeg",
                       @"h4.jpeg",
                       @"h5.jpeg",
                       @"h6.jpeg",
                       @"h7.jpeg",
                       @"h8.jpeg", nil];
    
    MyScrollView *myScrollView = [[MyScrollView alloc] initWithFrame:self.view.bounds];
    [myScrollView setImagePathsInBundle:self.imageNames];
    [self.view addSubview:myScrollView];
    [myScrollView setAutoRunEnableWithInterval:3];
    myScrollView.playDirection = Right;
    myScrollView.timeInterval = 3;
    myScrollView.pageControlEnable = YES;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

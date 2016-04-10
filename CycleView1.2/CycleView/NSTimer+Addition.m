//
//  NSTimer+Addition.m
//  CycleView
//
//  Created by 郭艳芳 on 16/1/11.
//  Copyright © 2016年 郭艳芳. All rights reserved.
//

#import "NSTimer+Addition.h"

@implementation NSTimer (Addition)

// 暂停
- (void)pauseTimer {
    
    if (![self isValid]) { // 判断是否有效
        return;
    }

    // 设置启动时间
    [self setFireDate:[NSDate distantFuture]];
    
}

// 继续
- (void)resumeTimer {
    
    if (![self isValid]) {
        return;
    }

    [self setFireDate:[NSDate date]];
    
}

// 在多少秒后继续
- (void)resumeTimerAfterTimerInterval:(NSTimeInterval)timerInterval {
    
    if (![self isValid]) {
        return;
    }

    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:timerInterval]];
}


@end

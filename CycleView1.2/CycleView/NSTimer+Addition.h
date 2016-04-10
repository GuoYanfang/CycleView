//
//  NSTimer+Addition.h
//  CycleView
//
//  Created by 郭艳芳 on 16/1/11.
//  Copyright © 2016年 郭艳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Addition)

// 暂停
- (void)pauseTimer;

// 继续
- (void)resumeTimer;

// 在多少秒后继续
- (void)resumeTimerAfterTimerInterval:(NSTimeInterval)timerInterval;

@end

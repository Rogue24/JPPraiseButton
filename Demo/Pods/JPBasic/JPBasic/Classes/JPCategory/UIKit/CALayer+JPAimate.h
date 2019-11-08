//
//  CALayer+PauseAimate.h
//  QQ音乐
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 xiaomage. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (JPAimate)

// 暂停动画
- (void)jp_pauseAnimate;

// 恢复动画
- (void)jp_resumeAnimate;

@end

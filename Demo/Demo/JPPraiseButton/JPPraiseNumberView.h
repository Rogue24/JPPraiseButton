//
//  JPPraiseNumberView.h
//  JPPraiseButton
//
//  Created by 周健平 on 2018/11/9.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPPraiseNumberView : UIView
@property (nonatomic, assign) CGPoint targetOrigin;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) void (^updateBlock)(void);
- (void)resetCount;
@end

NS_ASSUME_NONNULL_END

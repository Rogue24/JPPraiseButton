//
//  JPPraiseLayer.h
//  JPPraiseButton
//
//  Created by 周健平 on 2018/11/8.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPPraiseLayer : CAEmitterLayer
+ (instancetype)praiseLayerWithIsCombo:(BOOL)isCombo;
- (void)preparePraiseAnimationWithMainAngle:(CGFloat)mainAngle angleRange:(CGFloat)angleRange;
- (void)startPraiseAnimation;
- (void)stopPraiseAnimation;
@property (nonatomic, assign, readonly) BOOL isCombo;
@end

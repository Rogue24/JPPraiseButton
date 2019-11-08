//
//  JPPraiseButton.h
//  JPPraiseButton
//
//  Created by 周健平 on 2018/11/8.
//  Copyright © 2018 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JPPositionStyle) {
    JPPositionStyleIconLeftLabelRight,
    JPPositionStyleIconTopLabelBottom,
};

@interface JPPraiseButton : UIView
+ (instancetype)praiseButtonWithNoSelectImgName:(NSString *)noSelectImgName selectedImgName:(NSString *)selectedImgName mainAngle:(CGFloat)mainAngle angleRange:(CGFloat)angleRange;
@property NSString *title;
@property (nonatomic, assign, readonly) BOOL isSelected;
@property (nonatomic, assign) BOOL defaultSelected;

- (void)setIsSelected:(BOOL)isSelected isAnimated:(BOOL)isAnimated;
@property (nonatomic, copy) void (^selectAction)(BOOL isSelected);

@property (nonatomic, assign) JPPositionStyle positionStyle;

@end

//
//  JPPraiseLayer.m
//  JPPraiseButton
//
//  Created by 周健平 on 2018/11/8.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "JPPraiseLayer.h"
#import "JPSolveTool.h"

@implementation JPPraiseLayer

static inline NSString * JPCellImageName(NSInteger index) {
    return [NSString stringWithFormat:@"like_img_%zd", index];
}

static inline NSString * JPRandomCellImageName() {
    return JPCellImageName(JPRandomNumber(1, 11));
}

- (instancetype)init {
    if (self = [super init]) {
        self.masksToBounds = NO;
        self.emitterShape = kCAEmitterLayerPoint;
        self.emitterMode = kCAEmitterLayerPoint;
        self.birthRate = 0;
    }
    return self;
}

+ (instancetype)praiseLayerWithIsCombo:(BOOL)isCombo {
    JPPraiseLayer *praiseLayer = [JPPraiseLayer layer];
    praiseLayer.isCombo = isCombo;
    return praiseLayer;
}

- (void)setIsCombo:(BOOL)isCombo {
    _isCombo = isCombo;
    if (isCombo) {
        NSMutableArray *emitterCells = [NSMutableArray array];
        for (NSInteger i = 0; i < 11; i++) {
            [emitterCells addObject:[self emitterCellWithImageName:JPCellImageName(i + 1)]];
        }
        self.emitterCells = emitterCells;
    } else {
        self.emitterCells = @[[self emitterCellWithImageName:nil]];
    }
}

- (CAEmitterCell *)emitterCellWithImageName:(NSString *)imageName {
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    
    cell.scale = 1.0 / JPScreenScale; // 0.3
    cell.scaleRange = 0.1;
    cell.scaleSpeed = 0.05;
    
    cell.spinRange = M_PI;
    
    cell.alphaRange = 1;
    
    if (self.isCombo) {
        cell.birthRate = 6;
        
        cell.lifetime = 2;
        cell.alphaSpeed = -(1.0 / cell.lifetime);
        
        cell.velocity = 600;
        cell.velocityRange = 100;
        
        cell.spin = 0;
        
        UIImage *image = [UIImage imageNamed:imageName];
        cell.contents = (id)(image.CGImage);
        
    } else {
        cell.birthRate = 15;
        cell.lifetime = 2;
        cell.alphaSpeed = -0.05;
    }
    
    return cell;
}

- (void)preparePraiseAnimationWithMainAngle:(CGFloat)mainAngle angleRange:(CGFloat)angleRange {
    for (CAEmitterCell *cell in self.emitterCells) {
        if (self.isCombo) {
            cell.emissionLongitude = mainAngle;
            if (angleRange) cell.emissionRange = angleRange * 0.8;
        } else {
            UIImage *image = [UIImage imageNamed:JPRandomCellImageName()];
            cell.contents = (id)(image.CGImage);
            
            cell.spin = JPRandomBool() * M_PI_2 * 0.25;
            
            CGFloat angle = JPRandomScale() * angleRange * 0.55;
            cell.emissionLongitude = mainAngle + angle;
            cell.velocity = 550 + JPRandomScale() * 100; // 1000
            if (angle) {
                CGFloat velocityAcceleration = cell.velocity * 0.2; // 1.38
//                cell.xAcceleration = -velocityAcceleration * cos(angle);
                cell.yAcceleration = velocityAcceleration * sin(angle);
            }
        }
    }
}

- (void)startPraiseAnimation {
    if (self.birthRate > 0) return;
    self.beginTime = CACurrentMediaTime();
    self.birthRate = 1;
    if (!self.isCombo) [self performSelector:@selector(stopPraiseAnimation) withObject:nil afterDelay:0.1];
}

- (void)stopPraiseAnimation {
    self.birthRate = 0;
    [self removeAllAnimations];
    if (self.isCombo) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperlayer];
        });
    }
}

@end

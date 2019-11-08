//
//  JPPraiseButton.m
//  JPPraiseButton
//
//  Created by 周健平 on 2018/11/8.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "JPPraiseButton.h"
#import "JPPraiseLayer.h"
#import "JPPraiseNumberView.h"
#import "UIView+JPExtension.h"
#import "UIColor+JPExtension.h"
#import "JPMacro.h"
#import "JPSolveTool.h"

@interface JPPraiseButton ()
@property (nonatomic, strong) NSArray *allPraiseLayers;
@property (nonatomic, strong) JPPraiseLayer *comboPraiseLayer;
@property (nonatomic, strong) JPPraiseNumberView *numView;
@property (nonatomic, strong) NSTimer *comboTimer;
@property (nonatomic, strong) NSTimer *didClickTimer;

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation JPPraiseButton
{
    NSInteger _praiseLayersIndex;
    NSString *_noSelectImgName;
    NSString *_selectedImgName;
    
    BOOL _isAddedPraiseLayersToWindow;
    BOOL _isKeepSelected;
    BOOL _iconAnimating;
    
    CGFloat _mainAngle;
    CGFloat _angleRange; 
}

#pragma mark - const

static NSInteger const AllPraiseLayersCount = 7;
static NSInteger const OneOfPraiseLayersCount = 7;
static NSArray *allPraiseLayers_;

#pragma mark - setter

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    self.jp_width = self.titleLabel.jp_maxX;
    
    self.positionStyle = _positionStyle;
}

- (void)setIsSelected:(BOOL)isSelected {
    [self setIsSelected:isSelected isAnimated:NO];
}

- (void)setDefaultSelected:(BOOL)defaultSelected {
    self.iconView.image = [UIImage imageNamed:(defaultSelected ? _selectedImgName : _noSelectImgName)];
    _isSelected = defaultSelected;
}
- (void)setIsSelected:(BOOL)isSelected isAnimated:(BOOL)isAnimated {
    if (_isSelected != isSelected) {
        _isSelected = isSelected;
        !self.selectAction ? : self.selectAction(isSelected);
    }
    self.iconView.image = [UIImage imageNamed:(isSelected ? _selectedImgName : _noSelectImgName)];
    if (isAnimated) [self iconViewAnimation];
    if (!isSelected) [self.numView resetCount];
}

- (void)setPositionStyle:(JPPositionStyle)positionStyle {
    _positionStyle = positionStyle;
    if (positionStyle == JPPositionStyleIconLeftLabelRight) {
        self.iconView.jp_x = 0;
        self.titleLabel.jp_x = self.iconView.jp_width + 11;
        self.jp_size = CGSizeMake(self.titleLabel.jp_maxX, MAX(self.iconView.jp_height, self.titleLabel.jp_height));
        self.iconView.jp_centerY = self.jp_height * 0.5;
        self.titleLabel.jp_centerY = self.jp_height * 0.5;
    } else if (positionStyle == JPPositionStyleIconTopLabelBottom) {
        self.iconView.jp_y = 0;
        self.titleLabel.jp_y = self.iconView.jp_maxY + 5;
        self.jp_size = CGSizeMake(MAX(self.titleLabel.jp_width, self.iconView.jp_width), self.titleLabel.jp_maxY);
        self.iconView.jp_centerX = self.jp_width * 0.5;
        self.titleLabel.jp_centerX = self.jp_width * 0.5;
    } else {
        self.jp_width = self.titleLabel.jp_maxX;
    }
}

#pragma mark - getter

- (NSArray *)allPraiseLayers {
    if (!_allPraiseLayers) {
        if (!allPraiseLayers_) {
            // 每个粒子层只有一个cell，每5个粒子层作为一组喷射，共7组（7 * 7 = 49）
            // 为什么每个粒子层不用5个cell，每组一个粒子层，从而减少粒子层的数量？（7 * 1 = 7）
            // 因为当粒子层有1个以上的cell，多次点击弹射过后，会有一定几率无法再次弹射，之后一直空白，目前暂不知原因
            // 所以只能使用一个粒子层一个cell的方法，自定义随机喷射角度，类似多个cell的假象
            // 还有一种做法就是每次点击重新创建一个新的粒子层来代替，但本人觉得这种做法不太好，多次点击使用的话还不如重复使用
            // 但连续喷射的粒子层也会有一定几率无法再次弹射，鉴于操作频率不会太多，每次连续喷射就重新创建吧
            // 【以后有时间再探究这个问题】
            NSMutableArray *allPraiseLayers = [NSMutableArray array];
            for (NSInteger i = 0; i < AllPraiseLayersCount; i++) {
                NSMutableArray *praiseLayers = [NSMutableArray array];
                for (NSInteger i = 0; i < OneOfPraiseLayersCount; i++) {
                    JPPraiseLayer *praiseLayer = [JPPraiseLayer praiseLayerWithIsCombo:NO];
                    [praiseLayers addObject:praiseLayer];
                }
                [allPraiseLayers addObject:praiseLayers];
            }
            allPraiseLayers_ = allPraiseLayers;
        }
        _allPraiseLayers = allPraiseLayers_;
    }
    return _allPraiseLayers;
}

- (JPPraiseLayer *)comboPraiseLayer {
    if (!_comboPraiseLayer) {
        _comboPraiseLayer = [JPPraiseLayer praiseLayerWithIsCombo:YES];
        _comboPraiseLayer.emitterPosition = self.praiseLayerOnWindowPosition;
        [self.window.layer addSublayer:_comboPraiseLayer];
    }
    return _comboPraiseLayer;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (CGPoint)iconViewOnWindowCenter {
    return [self convertPoint:self.iconView.center toView:self.window];
}

- (CGPoint)praiseLayerOnWindowPosition {
    CGPoint center = self.iconViewOnWindowCenter;
    return CGPointMake(center.x + 15, center.y);
}

- (CGPoint)numViewOnWindowOrigin {
    CGPoint center = self.iconViewOnWindowCenter;
    return CGPointMake(center.x + 20, center.y - 50);
}

#pragma mark - init

+ (instancetype)praiseButtonWithNoSelectImgName:(NSString *)noSelectImgName selectedImgName:(NSString *)selectedImgName mainAngle:(CGFloat)mainAngle angleRange:(CGFloat)angleRange {
    return [[self alloc] initWithNoSelectImgName:noSelectImgName selectedImgName:selectedImgName mainAngle:mainAngle angleRange:angleRange];
}

- (instancetype)initWithNoSelectImgName:(NSString *)noSelectImgName selectedImgName:(NSString *)selectedImgName mainAngle:(CGFloat)mainAngle angleRange:(CGFloat)angleRange {
    if (self = [super init]) {
        self.clipsToBounds = NO;
        
        _noSelectImgName = noSelectImgName;
        _selectedImgName = selectedImgName;
        
        _mainAngle = mainAngle;
        _angleRange = angleRange;
        
        self.numView = [[JPPraiseNumberView alloc] init];
        self.numView.layer.zPosition = 99;
        @jp_weakify(self);
        self.numView.updateBlock = ^{
            @jp_strongify(self);
            if (!self) return;
            [self iconViewAnimation];
        };
        
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:noSelectImgName]];
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = JPScaleFont(12);
        titleLabel.textColor = [UIColor jp_colorWithHexString:@"7B7B7B"];
        titleLabel.text = @"";
        [titleLabel sizeToFit];
        titleLabel.jp_x = iconView.jp_width + JP10Margin;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClick)]];
        
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPressGR.minimumPressDuration = 0.35;
        [self addGestureRecognizer:longPressGR];
        
        self.jp_size = CGSizeMake(titleLabel.jp_maxX, MAX(iconView.jp_height, titleLabel.jp_height));
    }
    return self;
}

#pragma mark - life cycle

- (void)dealloc {
    for (NSMutableArray *praiseLayers in _allPraiseLayers) {
        for (JPPraiseLayer *praiseLayer in praiseLayers) {
            [praiseLayer removeFromSuperlayer];
        }
    }
    _allPraiseLayers = nil;
    
    [_comboPraiseLayer removeFromSuperlayer];
    _comboPraiseLayer = nil;
    
    [self.numView removeFromSuperview];
    self.numView = nil;
    
    NSLog(@"赞死了");
}

#pragma mark - setup subviews

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        if (!_isAddedPraiseLayersToWindow) {
            _isAddedPraiseLayersToWindow = YES;
            for (NSMutableArray *praiseLayers in self.allPraiseLayers) {
                for (JPPraiseLayer *praiseLayer in praiseLayers) {
                    [self.window.layer addSublayer:praiseLayer];
                }
            }
            [self.window.layer addSublayer:_comboPraiseLayer];
            [self.window addSubview:self.numView];
        }
    } else {
        _isAddedPraiseLayersToWindow = NO;
        for (NSMutableArray *praiseLayers in _allPraiseLayers) {
            for (JPPraiseLayer *praiseLayer in praiseLayers) {
                [praiseLayer removeFromSuperlayer];
            }
        }
        [_comboPraiseLayer removeFromSuperlayer];
        [self.numView removeFromSuperview];
    }
}


#pragma mark - GestureRecognizer

- (void)didClick {
    [self removeDidClickTimer];
    
    if (_isKeepSelected) {
        [self setIsSelected:YES isAnimated:YES];
    } else {
        [self setIsSelected:!self.isSelected isAnimated:YES];
    }
    
    if (!self.isSelected) return;
    
    _isKeepSelected = YES;
    
    NSMutableArray *praiseLayers = self.allPraiseLayers[_praiseLayersIndex];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGPoint position = self.praiseLayerOnWindowPosition;
    for (JPPraiseLayer *praiseLayer in praiseLayers) {
        praiseLayer.emitterPosition = position;
        [praiseLayer preparePraiseAnimationWithMainAngle:_mainAngle angleRange:_angleRange];
    }
    [CATransaction commit];
    
    self.numView.targetOrigin = self.numViewOnWindowOrigin;
    
    self.numView.count += 1;
    
    for (JPPraiseLayer *praiseLayer in praiseLayers) {
        [praiseLayer startPraiseAnimation];
    }
    
    _praiseLayersIndex += 1;
    if (_praiseLayersIndex == AllPraiseLayersCount) {
        _praiseLayersIndex = 0;
    }
    
    [self addDidClickTimer];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGR {
    if (longPressGR.state == UIGestureRecognizerStateBegan) {
        [self setIsSelected:YES isAnimated:YES];
        _isKeepSelected = YES;
        [self removeDidClickTimer];
        [self addComboTimer];
        self.numView.targetOrigin = self.numViewOnWindowOrigin;
        [self.comboPraiseLayer preparePraiseAnimationWithMainAngle:_mainAngle angleRange:_angleRange];
        [self.comboPraiseLayer startPraiseAnimation];
    } else if (longPressGR.state == UIGestureRecognizerStateEnded ||
               longPressGR.state == UIGestureRecognizerStateCancelled ||
               longPressGR.state == UIGestureRecognizerStateFailed) {
        [self addDidClickTimer];
        [self removeComboTimer];
        [_comboPraiseLayer stopPraiseAnimation];
        _comboPraiseLayer = nil;
    }
}

#pragma mark - timer

- (void)addComboTimer {
    [self removeComboTimer];
    self.comboTimer = [NSTimer scheduledTimerWithTimeInterval:0.13 target:self selector:@selector(comboTimerHandle) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.comboTimer forMode:NSRunLoopCommonModes];
}

- (void)removeComboTimer {
    if (self.comboTimer) {
        [self.comboTimer invalidate];
        self.comboTimer = nil;
    }
}

- (void)comboTimerHandle {
    self.numView.count += 1;
//    [self didClick];
}

- (void)addDidClickTimer {
    [self removeDidClickTimer];
    self.didClickTimer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(didClickTimerHandle) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.didClickTimer forMode:NSRunLoopCommonModes];
}

- (void)removeDidClickTimer {
    if (self.didClickTimer) {
        [self.didClickTimer invalidate];
        self.didClickTimer = nil;
    }
}

- (void)didClickTimerHandle {
    [self removeDidClickTimer];
    _isKeepSelected = NO;
}

#pragma mark - private method

- (void)iconViewAnimation {
    if (_iconAnimating) return;
    _iconAnimating = YES;
//    [UIView animateWithDuration:0.2 animations:^{
//        self.iconView.transform = CGAffineTransformMakeScale(1.4, 1.4);
//        self.iconView.transform = CGAffineTransformRotate(self.iconView.transform, -M_PI_2 * 0.25);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.65 delay:0 usingSpringWithDamping:0.35 initialSpringVelocity:1.0 options:kNilOptions animations:^{
//            self.iconView.transform = CGAffineTransformIdentity;
//        } completion:^(BOOL finished) {
//            self->_iconAnimating = NO;
//        }];
//    }];
}

@end

//
//  JPPraiseNumberView.m
//  JPPraiseButton
//
//  Created by 周健平 on 2018/11/9.
//  Copyright © 2018 周健平. All rights reserved.
//

#import "JPPraiseNumberView.h"
#import "JPSolveTool.h"
#import "UIView+JPExtension.h"

@interface JPPraiseNumberView ();
@property (nonatomic, weak) UIImageView *oneView;
@property (nonatomic, weak) UIImageView *tenView;
@property (nonatomic, weak) UIImageView *baiView;
@property (nonatomic, weak) UIImageView *picView;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation JPPraiseNumberView

static inline NSString * JPAmazingImageName(NSInteger index) {
    return [NSString stringWithFormat:@"like_amazing_%zd", index];
}

static inline NSString * JPRandomAmazingImageName() {
    return JPAmazingImageName(JPRandomNumber(1, 3));
}

static inline NSString * JPNumberImageName(NSInteger number) {
    return [NSString stringWithFormat:@"like_num_%zd", number];
}

- (instancetype)init {
    if (self = [super init]) {
        self.clipsToBounds = NO;
        self.userInteractionEnabled = NO;
        
        UIImageView *picView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:JPAmazingImageName(1)]];
        [self addSubview:picView];
        self.picView = picView;
        
        UIImageView *oneView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, picView.frame.size.height)];
        [self addSubview:oneView];
        self.oneView = oneView;
        
        UIImageView *tenView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, picView.frame.size.height)];
        [self addSubview:tenView];
        self.tenView = tenView;
        
        UIImageView *baiView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, picView.frame.size.height)];
        [self addSubview:baiView];
        self.baiView = baiView;
        
        self.alpha = 0;
    }
    return self;
}

- (void)dealloc {
    [self removeTimer];
}

- (void)resetCount {
    _count = 0;
    self.baiView.image = nil;
    self.tenView.image = nil;
    self.oneView.image = nil;
    self.baiView.jp_width = 0;
    self.tenView.jp_width = 0;
    self.oneView.jp_width = 0;
}

- (void)setTargetOrigin:(CGPoint)targetOrigin {
    if (CGPointEqualToPoint(_targetOrigin, targetOrigin)) {
        return;
    }
    _targetOrigin = targetOrigin;
    self.jp_origin = targetOrigin;
}

- (void)setCount:(NSInteger)count {
    if (count <= 0 || count > 999) {
        if (self.alpha && !self.timer) {
            [self addTimer];
        }
        return;
    }
    
    [self removeTimer];
    
    NSInteger one = count % 100 % 10;
    NSInteger ten = count % 100 / 10;
    NSInteger bai = count / 100;
    
    UIImage *picImage = self.picView.image;
    CGRect picFrame = self.picView.frame;
    BOOL isUpdatePic = count % 10 == 0 || self.alpha == 0;
    if (isUpdatePic) {
        picImage = [UIImage imageNamed:JPRandomAmazingImageName()];
        picFrame.size = picImage.size;
    }
    
    CGFloat h = picFrame.size.height;
    CGFloat scale = 1;
    
    UIImage *baiImage = self.baiView.image;
    CGRect baiFrame = self.baiView.frame;
    BOOL isUpdateBai = bai > 0;
    if (isUpdateBai) {
        baiImage = [UIImage imageNamed:JPNumberImageName(bai)];
        baiFrame.size = CGSizeMake(baiImage.size.width * scale, baiImage.size.height * scale);
        baiFrame.origin.y = (h - baiFrame.size.height) * 0.5;
    }
    
    UIImage *tenImage = self.tenView.image;
    CGRect tenFrame = self.tenView.frame;
    BOOL isUpdateTen = ((ten == 0) && bai > 0) || ten > 0;
    if (isUpdateTen) {
        tenImage = [UIImage imageNamed:JPNumberImageName(ten)];
        tenFrame.size = CGSizeMake(tenImage.size.width * scale, tenImage.size.height * scale);
        tenFrame.origin.x = CGRectGetMaxX(baiFrame) + (baiFrame.size.width > 0 ? 5 : 0);
        tenFrame.origin.y = (h - tenFrame.size.height) * 0.5;
    }
    
    UIImage *oneImage = self.oneView.image;
    CGRect oneFrame = self.oneView.frame;
    BOOL isUpdateOne = ((one == 0) && (ten > 0 || bai > 0)) || one > 0;
    if (isUpdateOne) {
        oneImage = [UIImage imageNamed:JPNumberImageName(one)];
        oneFrame.size = CGSizeMake(oneImage.size.width * scale, oneImage.size.height * scale);
        oneFrame.origin.x = CGRectGetMaxX(tenFrame) + (tenFrame.size.width > 0 ? 5 : 0);
        oneFrame.origin.y = (h - oneFrame.size.height) * 0.5;
    }
    
    picFrame.origin.x = CGRectGetMaxX(oneFrame) + 5;
    
    CGRect bounds = self.bounds;
    bounds.size.width = CGRectGetMaxX(picFrame);
    bounds.size.height = h;
    
    void (^updateLayout)(void) = ^() {
        self.baiView.frame = baiFrame;
        self.tenView.frame = tenFrame;
        self.oneView.frame = oneFrame;
        self.picView.frame = picFrame;
        self.bounds = bounds;
    };
    
    if (isUpdateBai) self.baiView.image = baiImage;
    
    if (isUpdateTen) self.tenView.image = tenImage;
    
    if (isUpdateOne) {
        [UIView transitionWithView:self.oneView duration:0.12 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.oneView.image = oneImage;
        } completion:nil];
    }
    
    if (isUpdatePic) {
        !self.updateBlock ? : self.updateBlock();
        self.picView.image = picImage;
        
        self.transform = CGAffineTransformIdentity;
        updateLayout();
        self.jp_origin = self.targetOrigin;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.transform = CGAffineTransformTranslate(self.transform, 0, 50);
        self.transform = CGAffineTransformRotate(self.transform, -M_2_PI * 0.3);
        self.alpha = 0;
        
        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:1.0 options:kNilOptions animations:^{
            self.transform = CGAffineTransformScale(self.transform, 2, 2);
            self.transform = CGAffineTransformTranslate(self.transform, 0, -50);
            self.alpha = 1;
            self.jp_origin = self.targetOrigin;
        } completion:^(BOOL finished) {
            [self addTimer];
        }];
    } else {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:1.0 options:kNilOptions animations:^{
            updateLayout();
            self.jp_origin = self.targetOrigin;
        } completion:^(BOOL finished) {
            [self addTimer];
        }];
    }
    
    _count = count;
}

- (void)addTimer {
    [self removeTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerHandle) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerHandle {
    [self removeTimer];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    }];
}

@end

//
//  ViewController.m
//  JPPraiseButton
//
//  Created by 周健平 on 2019/11/8.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"
#import "JPPraiseButton.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.magentaColor;
    
    JPPraiseButton *praiseBtn = [JPPraiseButton praiseButtonWithNoSelectImgName:@"play_icon_like" selectedImgName:@"play_icon_liked" mainAngle:-M_PI_2 * 0.55 angleRange:M_PI_2];
    praiseBtn.frame = CGRectMake(40, 400, 30, 30);
    praiseBtn.positionStyle = JPPositionStyleIconTopLabelBottom;
    [self.view addSubview:praiseBtn];
}


@end

//
//  JUBFingerEntryAlert.m
//  JuBiterSDKDemo
//
//  Created by zhangchuan on 2020/8/12.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBFingerEntryAlert.h"
#import "FTConstant.h"
#import "Tools.h"
#import "JUBBLEDeviceListCell.h"
#import "JUBWarningAlert.h"

@interface JUBFingerEntryAlert()

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UIImageView *fingerImageView;

@property (nonatomic, copy) NSString *msg;

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation JUBFingerEntryAlert

+ (JUBFingerEntryAlert *)show {
    
    JUBFingerEntryAlert *alertView = [JUBFingerEntryAlert creatSelf];
    
    alertView.fingerNumber = 1;
    
    UIView *whiteMainView = [alertView addMainView];
    
    [alertView addSubviewAboveSuperView:whiteMainView];
    
    return alertView;
}


+ (JUBFingerEntryAlert *)creatSelf {
    
    JUBFingerEntryAlert *alertView = [[JUBFingerEntryAlert alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    
    alertView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    [[UIApplication sharedApplication].keyWindow addSubview:alertView];
    
    return alertView;
}


- (UIView *)addMainView {
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth - 50, 200)];
    
    mainView.center = CGPointMake(KScreenWidth/2, KScreenHeight*2/5);
    
    mainView.backgroundColor = [UIColor whiteColor];
    
    mainView.layer.cornerRadius = 4;
    
    mainView.layer.masksToBounds = YES;
    
    [self addSubview:mainView];
    
    return mainView;
}


- (void)addSubviewAboveSuperView:(UIView *)mainView {
    
    [self addButtonAboveSuperView:mainView];
    
    self.fingerImageView = [self addFingerImageViewAboveSuperView:mainView];
    
    self.titleLabel = [self addTitleLabelAboveSuperView:mainView];
}


#pragma mark - 添加mainview上面的子视图
- (UIButton *)addButtonAboveSuperView:(UIView *)mainView {
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainView.frame) - 25, 10, 15, 15)];
    
    [closeButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    
    [closeButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateHighlighted];
    
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [mainView addSubview:closeButton];
    
    return closeButton;
}


- (void)close {
    
    [JUBWarningAlert warningAlert:@"Are you sure you want to cancel the fingerprint enroll ?" warningCallBack:^{
        [self dismiss];
    }];
}


- (UIImageView *)addFingerImageViewAboveSuperView:(UIView *)mainView {
    
    UIImageView *fingerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(mainView.frame)/2 - 40, 30, 80, 84)];
    
    fingerImageView.image = [UIImage imageNamed:@"finger-1"];
    
    [mainView addSubview:fingerImageView];
    
    return fingerImageView;
}


- (UILabel *)addTitleLabelAboveSuperView:(UIView *)mainView {
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.fingerImageView.frame) + 20, CGRectGetWidth(mainView.frame) - 2 * 20, CGRectGetHeight(mainView.frame))];
    
    titleLabel.text = @"4 more fingerprinting is required";
    
    titleLabel.font = [UIFont systemFontOfSize:16];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.numberOfLines = 0;
    
    [mainView addSubview:titleLabel];
    
    [titleLabel sizeToFit];
    
    titleLabel.center = CGPointMake(CGRectGetWidth(mainView.frame)/2, titleLabel.center.y);
    
    UILabel *animalLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), CGRectGetMinY(titleLabel.frame), 50, CGRectGetHeight(titleLabel.frame))];
    
    animalLabel.text = @"...";
    
    [mainView addSubview:animalLabel];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        if ([animalLabel.text isEqualToString:@"..."]) {
            animalLabel.text = @"..";
        } else {
            animalLabel.text = @"...";
        }
    }];
    
    return titleLabel;
}


- (void)dismiss {
    
    [self.timer invalidate];
    
    [self removeFromSuperview];
}


#pragma mark - getter setter方法
- (void)setFingerNumber:(NSInteger)fingerNumber {
    
    NSAssert(fingerNumber >= 1, @"fingerNumber的数值最小为1");
    
    NSAssert(fingerNumber <= 5, @"fingerNumber的数值最大为5");
    
    _fingerNumber = fingerNumber;
    
    NSString *fingerImageName = [NSString stringWithFormat:@"finger-%ld", (long)fingerNumber];
    
    self.fingerImageView.image = [UIImage imageNamed:fingerImageName];
    
    if (self.fingerNumber == 5) {
        self.titleLabel.text = @"Fingerprint enroll completed";
    } else {
        self.titleLabel.text = [NSString stringWithFormat:@"%ld more fingerprinting is required", 5 - (long)self.fingerNumber];
    }
    
}

- (void)dealloc
{
    NSLog(@"JUBFingerEntryAlert-dealloc");
}

@end

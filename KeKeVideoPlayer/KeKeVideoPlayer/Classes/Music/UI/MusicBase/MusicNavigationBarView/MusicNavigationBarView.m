//
//  MusicNavigationBarView.m
//  KeKeVideoPlayer
//
//  Created by edward lannister on 2022/08/06.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicNavigationBarView.h"

@interface MusicNavigationBarView ()

@end

@implementation MusicNavigationBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = [UIColor whiteColor];
    self.footerLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.kk_height-0.5, self.kk_width, 0.5)];
    self.footerLineView.backgroundColor = Theme_Color_DEDEDE;
    [self addSubview:self.footerLineView];

    CGFloat height = [UIFont kk_heightForFont:[UIFont boldSystemFontOfSize:17]];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, self.kk_height-44+(44-height)/2.0, self.kk_width-120, height)];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
}

#pragma mark ==================================================
#pragma mark == NavigationBar Title
#pragma mark ==================================================
- (void)setTitle:(NSString *)title{
    CGSize size = [title kk_sizeWithFont:self.titleLabel.font maxSize:CGSizeMake(self.kk_width-120, 44)];
    self.titleLabel.frame = CGRectMake(60, self.kk_height-44+(44-size.height)/2.0, self.kk_width-120, size.height);
    self.titleLabel.text = title;
}

#pragma mark ==================================================
#pragma mark == NavigationBar Button
#pragma mark ==================================================
- (KKButton*)setNavLeftButtonImage:(UIImage *)image selector:(SEL)selecter target:(id)target{
    KKButton *button = [[KKButton alloc] initWithFrame:CGRectMake(0, self.kk_height-44, 60, 44) type:KKButtonType_ImgLeftTitleRight_Center];
    button.imageViewSize = CGSizeMake(30, 30);
    button.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.spaceBetweenImgTitle = 0;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selecter forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;//关闭多点
    button.backgroundColor = [UIColor clearColor];
    [self addSubview:button];
    [self.leftButton removeFromSuperview];
    self.leftButton = button;
    return button;
}

- (KKButton*)setNavRightButtonImage:(UIImage *)image selector:(SEL)selecter target:(id)target{
    KKButton *button = [[KKButton alloc] initWithFrame:CGRectMake(self.kk_width-60, self.kk_height-44, 60, 44) type:KKButtonType_ImgLeftTitleRight_Center];
    button.imageViewSize = CGSizeMake(30, 30);
    button.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.spaceBetweenImgTitle = 0;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selecter forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;//关闭多点
    button.backgroundColor = [UIColor clearColor];
    [self addSubview:button];
    [self.rightButton removeFromSuperview];
    self.rightButton = button;
    return button;
}

- (KKButton*)setNavLeftButtonTitle:(NSString *)title titleColor:(UIColor *)tColor selector:(SEL)selecter target:(id)target{
    CGSize size = [title kk_sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:KKApplicationWidth];
    CGFloat buttonWidth = size.width + 15;
    KKButton *button = [[KKButton alloc] initWithFrame:CGRectMake(0, self.kk_height-44, buttonWidth, 44) type:KKButtonType_ImgLeftTitleRight_Left];
    button.imageViewSize = CGSizeZero;
    button.edgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    button.spaceBetweenImgTitle = 0;
    [button addTarget:target action:selecter forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;//关闭多点
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:tColor forState:UIControlStateNormal];
    button.textLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:title forState:UIControlStateNormal];
    [self addSubview:button];
    [self.leftButton removeFromSuperview];
    self.leftButton = button;

    return button;
}

- (KKButton*)setNavRightButtonTitle:(NSString *)title titleColor:(UIColor *)tColor selector:(SEL)selecter target:(id)target{
    CGSize size = [title kk_sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:KKApplicationWidth];
    CGFloat buttonWidth = size.width + 15;
    KKButton *button = [[KKButton alloc] initWithFrame:CGRectMake(self.kk_width-buttonWidth, self.kk_height-44, buttonWidth, 44) type:KKButtonType_ImgLeftTitleRight_Left];
    button.imageViewSize = CGSizeZero;
    button.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    button.spaceBetweenImgTitle = 0;
    [button addTarget:target action:selecter forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;//关闭多点
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:tColor forState:UIControlStateNormal];
    button.textLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:title forState:UIControlStateNormal];
    [self addSubview:button];
    [self.rightButton removeFromSuperview];
    self.rightButton = button;
    return button;
}

@end

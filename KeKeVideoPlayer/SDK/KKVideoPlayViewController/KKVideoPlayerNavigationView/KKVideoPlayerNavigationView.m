//
//  KKVideoPlayerNavigationView.m
//  CEDongLi
//
//  Created by beartech on 15/10/23.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import "KKVideoPlayerNavigationView.h"
#import "KKCategory.h"

@implementation KKVideoPlayerNavigationView

- (void)layoutSubviews{
    [super layoutSubviews];
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self reloadSubviewsForUIInterfaceOrientation:currentInterfaceOrientation];
}

- (void)reloadSubviewsForUIInterfaceOrientation:(UIInterfaceOrientation)currentInterfaceOrientation{
    switch (currentInterfaceOrientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:{
            self.backgroundImageView.frame = self.bounds;
            self.leftButton.frame = CGRectMake(0, self.frame.size.height-44, 44, 44);
            self.titleLabel.frame = CGRectMake(44, self.frame.size.height-44, self.bounds.size.width-44-44, 44);
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown:{
            self.backgroundImageView.frame = self.bounds;
            self.leftButton.frame = CGRectMake(0, self.frame.size.height-44, 44, 44);
            self.titleLabel.frame = CGRectMake(44, self.frame.size.height-44, self.bounds.size.width-44-44, 44);
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:{
            CGFloat statusH = 0;
            CGFloat safeAreaBottomH = 0;
//            if ([[UIDevice currentDevice] isiPhoneX]) {
//                statusH = KKStatusBarHeight;
//                safeAreaBottomH = KKSafeAreaBottomHeight;
//            }

            self.backgroundImageView.frame = self.bounds;
            self.leftButton.frame = CGRectMake(safeAreaBottomH, self.frame.size.height-44, 44, 44);
            self.titleLabel.frame = CGRectMake(safeAreaBottomH+44, self.frame.size.height-44, self.bounds.size.width-44-44-statusH-safeAreaBottomH, 44);
            break;
        }
        case UIInterfaceOrientationLandscapeRight:{
            CGFloat statusH = 0;
            CGFloat safeAreaBottomH = 0;
//            if ([[UIDevice currentDevice] isiPhoneX]) {
//                statusH = KKStatusBarHeight;
//                safeAreaBottomH = KKSafeAreaBottomHeight;
//            }

            self.backgroundImageView.frame = self.bounds;
            self.leftButton.frame = CGRectMake(statusH, self.frame.size.height-44, 44, 44);
            self.titleLabel.frame = CGRectMake(statusH+44, self.frame.size.height-44, self.bounds.size.width-44-44-statusH-safeAreaBottomH, 44);
            break;
        }
        default:
            break;
    }
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self addSubview:self.backgroundImageView];
        
        self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height-44, 44, 44)];
        self.leftButton.exclusiveTouch = YES;
        [self.leftButton setImage:[self VideoPlay_NavBackDefault_ButtonImage]
                         forState:UIControlStateNormal];
        self.leftButton.backgroundColor = [UIColor clearColor];
        [self.leftButton addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.leftButton];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, self.frame.size.height-44, self.bounds.size.width-44, 44)];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)leftButtonClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayerNavigationView_LeftButtonClicked:)]) {
        [self.delegate KKVideoPlayerNavigationView_LeftButtonClicked:self];
    }
}

- (UIImage*)VideoPlay_NavBackDefault_ButtonImage{
    UIImage *image = [NSBundle kk_imageInBundle:@"KKVideoPlay_Resource.bundle" imageName:@"btn_NavBackDefault"];
    return image;
}
@end

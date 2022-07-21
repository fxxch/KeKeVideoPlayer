//
//  KKVideoPlayerForwardView.m
//  CEDongLi
//
//  Created by beartech on 15/10/25.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import "KKVideoPlayerForwardView.h"
#import "KKCategory.h"
#define KKVideoPlayerForwardView_Tag 20151025

@implementation KKVideoPlayerForwardView


+ (void)showInView:(UIView*)aSuperView
       currentTime:(NSTimeInterval)currentTime
      durationtime:(NSTimeInterval)durationtime
         isForward:(BOOL)isForward{
    KKVideoPlayerForwardView *subView = (KKVideoPlayerForwardView*)[aSuperView viewWithTag:KKVideoPlayerForwardView_Tag];
    if (!subView) {
        subView = [[KKVideoPlayerForwardView alloc] initWithFrame:CGRectMake((subView.bounds.size.width-150)/2.0, (subView.bounds.size.height-150)/2.0, 150, 150)];
        subView.tag = KKVideoPlayerForwardView_Tag;
        [aSuperView addSubview:subView];
    }
    subView.center = CGPointMake(aSuperView.bounds.size.width/2.0, aSuperView.bounds.size.height/2.0);

    [subView reloadWithCurrentTime:currentTime durationtime:durationtime isForward:isForward];
}

+ (void)hideForView:(UIView*)aSuperView{
    KKVideoPlayerForwardView *subView = (KKVideoPlayerForwardView*)[aSuperView viewWithTag:KKVideoPlayerForwardView_Tag];
    if (subView) {
        [subView hide];
    }
}

- (void)hide{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        [self kk_clearBackgroundColor];
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [backgroundView kk_setCornerRadius:5.0];
        [self addSubview:backgroundView];
        
        self.flagImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-83)/2.0, 25, 83, 76)];
        self.flagImageView.image = [self VideoPlay_forwardGesture_ButtonImage];
        [self addSubview:self.flagImageView];
        
        self.currentTimeLabel = [[UILabel alloc] init];
        self.currentTimeLabel.textColor = [UIColor blueColor];
        self.currentTimeLabel.font = [UIFont systemFontOfSize:13];
        self.currentTimeLabel.textAlignment = NSTextAlignmentRight;
        [self.currentTimeLabel kk_clearBackgroundColor];
        [self addSubview:self.currentTimeLabel];

        self.durationtimeLabel = [[UILabel alloc] init];
        self.durationtimeLabel.textColor = [UIColor whiteColor];
        self.durationtimeLabel.font = [UIFont systemFontOfSize:13];
        self.durationtimeLabel.textAlignment = NSTextAlignmentLeft;
        [self.durationtimeLabel kk_clearBackgroundColor];
        [self addSubview:self.durationtimeLabel];
    }
    return self;
}

- (void)reloadWithCurrentTime:(NSTimeInterval)currentTime
                 durationtime:(NSTimeInterval)durationtime
                    isForward:(BOOL)isForward{
    if (isForward) {
        self.flagImageView.image = [self VideoPlay_forwardGesture_ButtonImage];
    }
    else{
        self.flagImageView.image = [self VideoPlay_backwardGesture_ButtonImage];
    }
    
    NSString *timeString01 = [NSDate kk_timeDurationFormatFullString:currentTime];
    NSString *timeString02 = [NSDate kk_timeDurationFormatFullString:durationtime];
    CGSize size01 = [timeString01 kk_sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(1000, 1000)];
    CGSize size02 = [timeString02 kk_sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(1000, 1000)];

    self.currentTimeLabel.frame = CGRectMake((self.frame.size.width-size01.width-size02.width-10)/2.0, CGRectGetMaxY(self.flagImageView.frame)+10, size01.width+5, size01.height);
    self.currentTimeLabel.text = timeString01;
    self.durationtimeLabel.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), CGRectGetMaxY(self.flagImageView.frame)+10, size02.width+5, size02.height);
    self.durationtimeLabel.text = timeString02;
}

- (UIImage*)VideoPlay_forwardGesture_ButtonImage{
    UIImage *image = [NSBundle kk_imageInBundle:@"KKVideoPlay_Resource.bundle" imageName:@"VideoPlay_forwardGesture"];
    return image;
}

- (UIImage*)VideoPlay_backwardGesture_ButtonImage{
    UIImage *image = [NSBundle kk_imageInBundle:@"KKVideoPlay_Resource.bundle" imageName:@"VideoPlay_backwardGesture"];
    return image;
}


@end

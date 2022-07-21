//
//  KKVideoPlayerForwardView.h
//  CEDongLi
//
//  Created by beartech on 15/10/25.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKVideoPlayerForwardView : UIView

@property (nonatomic,strong)UIImageView *flagImageView;//前进后退标示
@property (nonatomic,strong)UILabel *currentTimeLabel;
@property (nonatomic,strong)UILabel *durationtimeLabel;

+ (void)showInView:(UIView*)aSuperView
       currentTime:(NSTimeInterval)currentTime
      durationtime:(NSTimeInterval)durationtime
         isForward:(BOOL)isForward;

+ (void)hideForView:(UIView*)aSuperView;

@end

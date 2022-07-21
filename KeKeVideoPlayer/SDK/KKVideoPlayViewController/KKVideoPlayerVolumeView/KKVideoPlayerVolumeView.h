//
//  KKVideoPlayerVolumeView.h
//  CEDongLi
//
//  Created by beartech on 15/10/24.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface KKVideoPlayerVolumeSlider : UISlider

@end

@protocol KKVideoPlayerVolumeViewDelegate;


@interface KKVideoPlayerVolumeView : UIView{
    CGFloat _currentVolume;
}

@property (nonatomic,strong)MPVolumeView *systemVolumeView;
@property (nonatomic,assign)UISlider *systemVolumeSlider;

@property (nonatomic,strong)UIImageView *backgroundImageView;
@property (nonatomic,strong)KKVideoPlayerVolumeSlider *mySlider;
@property (nonatomic,strong)UIButton *volumeButton;
@property (nonatomic,assign)CGFloat currentVolume;
@property (nonatomic,assign)id<KKVideoPlayerVolumeViewDelegate> delegate;

@end



@protocol KKVideoPlayerVolumeViewDelegate <NSObject>
@optional
- (void)KKVideoPlayerVolumeView_OpenVolumeButtonClicked:(KKVideoPlayerVolumeView*)aView;

- (void)KKVideoPlayerVolumeView_CloseVolumeButtonClicked:(KKVideoPlayerVolumeView*)aView;

- (void)KKVideoPlayerVolumeView:(KKVideoPlayerVolumeView*)aView currentVolumeChanged:(CGFloat)aCurrentVolume;


@end

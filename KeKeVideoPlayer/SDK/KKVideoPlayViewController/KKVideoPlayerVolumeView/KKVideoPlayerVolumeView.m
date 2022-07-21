//
//  KKVideoPlayerVolumeView.m
//  CEDongLi
//
//  Created by beartech on 15/10/24.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import "KKVideoPlayerVolumeView.h"
#import "KKCategory.h"

@implementation KKVideoPlayerVolumeSlider

//- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds{
//    CGRect rect = bounds;
//    rect.size.height = 10;
//    return rect;
//}
//
//- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds{
//    CGRect rect = bounds;
//    rect.size.height = 10;
//    return rect;
//}
//
- (CGRect)trackRectForBounds:(CGRect)bounds{
    CGRect rect = bounds;
    rect.size.height = 5.0;
    return rect;
}

//- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value{
//    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
//}

@end


@implementation KKVideoPlayerVolumeView
@synthesize currentVolume = _currentVolume;

- (void)dealloc{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;

        //创建系统音量控制器
        self.systemVolumeView = [[MPVolumeView alloc] init];
        self.systemVolumeView.showsVolumeSlider = NO;
        for (UIView *view in [self.systemVolumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.systemVolumeSlider = (UISlider*)view;
                break;
            }
        }

        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6];
        [self addSubview:self.backgroundImageView];
        
        CGFloat H = self.frame.size.height-40;
        CGFloat W = 10;
        self.mySlider = [[KKVideoPlayerVolumeSlider alloc] initWithFrame:CGRectMake((self.frame.size.width-W)/2.0-(H-W)/2.0, 10+(self.frame.size.height-10-30-W)/2.0, H, W)];
        self.mySlider.minimumTrackTintColor = [UIColor kk_colorWithHexString:@"#24C875"];
        self.mySlider.maximumTrackTintColor = [UIColor colorWithRed:0.82f green:0.82f blue:0.82f alpha:1.00f];
        self.mySlider.continuous = YES;
        self.mySlider.transform = CGAffineTransformMakeRotation(-M_PI/2);//绕中心旋转90°
        [self.mySlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.mySlider addTarget:self action:@selector(sliderClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.mySlider setThumbImage:[self VideoPlay_SliderPoint_ButtonImage]
                            forState:UIControlStateNormal];
        [self.mySlider setThumbImage:[self VideoPlay_SliderPoint_ButtonImage]
                            forState:UIControlStateHighlighted];
        self.mySlider.minimumValue = 0;
        self.mySlider.maximumValue = 1.0;
        [self addSubview:self.mySlider];
        
        self.volumeButton = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width-30)/2.0, self.frame.size.height-30, 30, 30)];
        [self.volumeButton setImage:[self VideoPlay_Volume_ButtonImage]
                           forState:UIControlStateNormal];
        self.volumeButton.tag = 1110;
        self.volumeButton.exclusiveTouch = YES;
        [self.volumeButton kk_clearBackgroundColor];
        [self.volumeButton addTarget:self action:@selector(volumeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.volumeButton];
        
        //监听系统音量
        NSError *error;
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        self.mySlider.value = [AVAudioSession sharedInstance].outputVolume;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Notification_SystemVolumeDidChange:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
        _currentVolume = self.mySlider.value;
        
//        // retrieve system volume
//        float systemVolume = volumeViewSlider.value;
//        
//        // change system volume, the value is between 0.0f and 1.0f
//        [volumeViewSlider setValue:1.0f animated:NO];
//        
//        // send UI control event to make the change effect right now.
//        [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        if (_currentVolume==0) {
            self.volumeButton.tag=1111;
            [self.volumeButton setImage:[self VideoPlay_VolumeOff_ButtonImage]
                               forState:UIControlStateNormal];
        }
        else{
            self.volumeButton.tag=1110;
            [self.volumeButton setImage:[self VideoPlay_Volume_ButtonImage]
                               forState:UIControlStateNormal];
        }
    }
    return self;
}

- (void)Notification_SystemVolumeDidChange:(NSNotification*)notification{
    NSDictionary *userInfo = notification.userInfo;
    self.mySlider.value = [[userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    _currentVolume = self.mySlider.value;
    if (_currentVolume==0) {
        self.volumeButton.tag=1111;
        [self.volumeButton setImage:[self VideoPlay_VolumeOff_ButtonImage]
                           forState:UIControlStateNormal];
    }
    else{
        self.volumeButton.tag=1110;
        [self.volumeButton setImage:[self VideoPlay_Volume_ButtonImage]
                           forState:UIControlStateNormal];
    }
}

- (void)setCurrentVolume:(CGFloat)currentVolume{
    if (currentVolume!=_currentVolume) {
        _currentVolume = currentVolume;
        //修改Slider
        [self.mySlider setValue:_currentVolume animated:YES];
        //修改系统声音
        [self.systemVolumeSlider setValue:_currentVolume animated:YES];
        [self.systemVolumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        if (_currentVolume==0) {
            self.volumeButton.tag=1111;
            [self.volumeButton setImage:[self VideoPlay_VolumeOff_ButtonImage]
                               forState:UIControlStateNormal];
        }
        else{
            self.volumeButton.tag=1110;
            [self.volumeButton setImage:[self VideoPlay_Volume_ButtonImage]
                               forState:UIControlStateNormal];
        }
    }
}

- (void)volumeButtonClicked{
    if (self.volumeButton.tag==1110) {
        //开始静音
        self.volumeButton.tag=1111;
        [self.volumeButton setImage:[self VideoPlay_VolumeOff_ButtonImage]
                           forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayerVolumeView_CloseVolumeButtonClicked:)]) {
            [self.delegate KKVideoPlayerVolumeView_CloseVolumeButtonClicked:self];
        }
        
        _currentVolume = 0;
        //修改Slider
        [self.mySlider setValue:0 animated:YES];
        //修改系统声音
        [self.systemVolumeSlider setValue:0 animated:YES];
        [self.systemVolumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else{
        //打开声音
        self.volumeButton.tag=1110;
        [self.volumeButton setImage:[self VideoPlay_Volume_ButtonImage]
                           forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayerVolumeView_OpenVolumeButtonClicked:)]) {
            [self.delegate KKVideoPlayerVolumeView_OpenVolumeButtonClicked:self];
        }
        
        _currentVolume = 0.2;
        //修改Slider
        [self.mySlider setValue:_currentVolume animated:YES];
        //修改系统声音
        [self.systemVolumeSlider setValue:_currentVolume animated:YES];
        [self.systemVolumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)sliderValueChanged:(UISlider*)slider{
    _currentVolume = slider.value;
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayerVolumeView:currentVolumeChanged:)]) {
        [self.delegate KKVideoPlayerVolumeView:self currentVolumeChanged:_currentVolume];
    }
    //修改Slider
    [self.mySlider setValue:_currentVolume animated:YES];
    //修改系统声音
    [self.systemVolumeSlider setValue:_currentVolume animated:YES];
    [self.systemVolumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    if (_currentVolume==0) {
        self.volumeButton.tag=1111;
        [self.volumeButton setImage:[self VideoPlay_VolumeOff_ButtonImage]
                           forState:UIControlStateNormal];
    }
    else{
        self.volumeButton.tag=1110;
        [self.volumeButton setImage:[self VideoPlay_Volume_ButtonImage]
                           forState:UIControlStateNormal];
    }
}

- (void)sliderClicked:(UISlider*)slider{
    _currentVolume = slider.value;
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayerVolumeView:currentVolumeChanged:)]) {
        [self.delegate KKVideoPlayerVolumeView:self currentVolumeChanged:_currentVolume];
    }
    
    if (_currentVolume==0) {
        self.volumeButton.tag=1111;
        [self.volumeButton setImage:[self VideoPlay_VolumeOff_ButtonImage]
                           forState:UIControlStateNormal];
    }
    else{
        self.volumeButton.tag=1110;
        [self.volumeButton setImage:[self VideoPlay_Volume_ButtonImage]
                           forState:UIControlStateNormal];
    }
}

- (UIImage*)VideoPlay_SliderPoint_ButtonImage{
    UIImage *image = [NSBundle kk_imageInBundle:@"KKVideoPlay_Resource.bundle" imageName:@"VideoPlay_SliderPoint"];
    return image;
}

- (UIImage*)VideoPlay_Volume_ButtonImage{
    UIImage *image = [NSBundle kk_imageInBundle:@"KKVideoPlay_Resource.bundle" imageName:@"VideoPlay_Volume"];
    return image;
}

- (UIImage*)VideoPlay_VolumeOff_ButtonImage{
    UIImage *image = [NSBundle kk_imageInBundle:@"KKVideoPlay_Resource.bundle" imageName:@"VideoPlay_VolumeOff"];
    return image;
}


@end

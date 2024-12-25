//
//  MusicControlView.m
//  KeKeVideoPlayer
//
//  Created by edward lannister on 2022/08/06.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicControlView.h"
#import "KKCategory.h"
#import "KKLocalizationManager.h"

@implementation MusicPlayerSlider

- (CGRect)trackRectForBounds:(CGRect)bounds{
    CGRect rect = bounds;
    rect.origin.y = (self.kk_height-2.5)/2.0;
    rect.size.height = 2.5;
    return rect;
}

@end

@implementation MusicControlView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.backgroundImageView];
        
        //滑动条
        self.mySlider = [[MusicPlayerSlider alloc] initWithFrame:CGRectMake(15, 0, self.frame.size.width-30, 40)];
        self.mySlider.minimumTrackTintColor = Theme_Color_FF7C03;
        self.mySlider.maximumTrackTintColor = Theme_Color_DEDEDE;
        [self.mySlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.mySlider addTarget:self action:@selector(sliderClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.mySlider addTarget:self action:@selector(sliderTouchedDown:) forControlEvents:UIControlEventTouchDown];
        [self.mySlider addTarget:self action:@selector(sliderTouchedOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [self.mySlider addTarget:self action:@selector(sliderTouchedOutSide:) forControlEvents:UIControlEventTouchDragOutside];
        [self.mySlider addTarget:self action:@selector(sliderTouchedOutSide:) forControlEvents:UIControlEventTouchCancel];
        [self.mySlider setThumbImage:[self VideoPlay_SliderPoint_ButtonImage] forState:UIControlStateNormal];
        [self.mySlider setThumbImage:[self VideoPlay_SliderPoint_ButtonImage] forState:UIControlStateHighlighted];
        [self addSubview:self.mySlider];
        self.mySlider.minimumValue = 0;
        self.mySlider.maximumValue = 1.0;

        //歌曲索引
        self.indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.mySlider.kk_bottom, self.frame.size.width-30, 20)];
        [self.indexLabel kk_clearBackgroundColor];
        self.indexLabel.textAlignment = NSTextAlignmentCenter;
        self.indexLabel.textColor = Theme_Color_999999;
        self.indexLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.indexLabel];

        //当前时间
        self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.mySlider.kk_bottom, self.frame.size.width-30, 20)];
        [self.currentTimeLabel kk_clearBackgroundColor];
        self.currentTimeLabel.text = KKLocalization(@"00:00:00");
        self.currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        self.currentTimeLabel.textColor = Theme_Color_999999;
        self.currentTimeLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.currentTimeLabel];

        //总时长
        self.durationtimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.mySlider.kk_bottom, self.frame.size.width-30, 20)];
        [self.durationtimeLabel kk_clearBackgroundColor];
        self.durationtimeLabel.text = KKLocalization(@"--:--:--");
        self.durationtimeLabel.textAlignment = NSTextAlignmentRight;
        self.durationtimeLabel.textColor = Theme_Color_999999;
        self.durationtimeLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.durationtimeLabel];

        //prev
        self.prevButton = [[UIButton alloc] initWithFrame:CGRectMake(30, self.durationtimeLabel.kk_bottom+20, 50, 50)];
        [self.prevButton setImage:KKThemeImage(@"Music_prev") forState:UIControlStateNormal];
        [self.prevButton addTarget:self action:@selector(prevButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.prevButton];
        
        //next
        self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-15-15-50, self.durationtimeLabel.kk_bottom+20, 50, 50)];
        [self.nextButton setImage:KKThemeImage(@"Music_next") forState:UIControlStateNormal];
        [self.nextButton addTarget:self action:@selector(nextButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.nextButton];

        //播放与暂停
        CGFloat height = 44;
        self.stopPlayButton = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width-height)/2.0, self.durationtimeLabel.kk_bottom+20, 50, 50)];
        self.stopPlayButton.exclusiveTouch = YES;
        [self.stopPlayButton setImage:KKThemeImage(@"Music_play") forState:UIControlStateNormal];
        self.stopPlayButton.tag = 1110;
        [self.stopPlayButton kk_clearBackgroundColor];
        [self.stopPlayButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.stopPlayButton];
        
        [self addShadow];
    }
    return self;
}

- (void)addShadow{
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeZero; // 设置偏移量为 0 ，四周都有阴影
    self.layer.shadowRadius = 50.0; //阴影半径,默认 3
    self.layer.shadowOpacity = 1.0; //阴影透明度 ，默认 0
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
}

#pragma mark ==================================================
#pragma mark == 按钮事件
#pragma mark ==================================================
- (void)playButtonClicked{
    if (self.stopPlayButton.tag==1110) {
        //开始播放
        self.stopPlayButton.tag=1111;
        [self.stopPlayButton setImage:KKThemeImage(@"Music_pause") forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(MusicControlView_PlayButtonClicked:)]) {
            [self.delegate MusicControlView_PlayButtonClicked:self];
        }
    }
    else{
        //暂停播放
        self.stopPlayButton.tag=1110;
        [self.stopPlayButton setImage:KKThemeImage(@"Music_play") forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(MusicControlView_PauseButtonClicked:)]) {
            [self.delegate MusicControlView_PauseButtonClicked:self];
        }
    }
}

- (void)nextButtonClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(MusicControlView_NextButtonClicked:)]) {
        [self.delegate MusicControlView_NextButtonClicked:self];
    }
}

- (void)prevButtonClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(MusicControlView_PrevButtonClicked:)]) {
        [self.delegate MusicControlView_PrevButtonClicked:self];
    }
}

- (void)sliderValueChanged:(UISlider*)slider{
    self.currentTime = slider.value;
}

- (void)sliderClicked:(UISlider*)slider{
    self.currentTime = slider.value;
    self.isSliderTouched = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(MusicControlView:currentTimeChanged:)]) {
        [self.delegate MusicControlView:self currentTimeChanged:_currentTime];
    }
}

- (void)sliderTouchedDown:(UISlider*)slider{
    self.isSliderTouched = YES;
}

- (void)sliderTouchedOutSide:(UISlider*)slider{
    self.isSliderTouched = NO;
}

#pragma mark ==================================================
#pragma mark == 外部调用
#pragma mark ==================================================
- (void)setButtonStatusStop{
    //暂停播放
    self.stopPlayButton.tag=1110;
    [self.stopPlayButton setImage:KKThemeImage(@"Music_play") forState:UIControlStateNormal];
}

- (void)setButtonStatusPlaying{
    //开始播放
    self.stopPlayButton.tag=1111;
    [self.stopPlayButton setImage:KKThemeImage(@"Music_pause") forState:UIControlStateNormal];
}

#pragma mark ==================================================
#pragma mark == 私有方法
#pragma mark ==================================================
- (void)setCurrentTime:(NSTimeInterval)currentTime{
    if (currentTime!=_currentTime) {
       _currentTime = currentTime;
        self.mySlider.value = _currentTime;
        self.currentTimeLabel.text = [NSDate kk_timeDurationFormatFullString:_currentTime];
    }
}

- (void)setDurationtime:(NSTimeInterval)durationtime{
    if (durationtime!=_durationtime) {
        _durationtime = durationtime;
        self.mySlider.minimumValue = 0;
        self.mySlider.maximumValue = MAX(_durationtime, 1.0);
        self.durationtimeLabel.text = [NSDate kk_timeDurationFormatFullString:_durationtime];
        if (durationtime<=1) {
            self.durationtimeLabel.text = KKLocalization(@"--:--:--");
        }
    }
}

- (UIImage*)VideoPlay_SliderPoint_ButtonImage{
    UIImage *image = [NSBundle kk_imageInBundle:@"KKVideoPlay_Resource.bundle" imageName:@"VideoPlay_SliderPoint"];
    return image;
}




@end

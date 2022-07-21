//
//  KKVideoPlayerBarView.h
//  CEDongLi
//
//  Created by beartech on 15/10/23.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKVideoPlayerSlider : UISlider

@end

@protocol KKVideoPlayerBarViewDelegate;

@interface KKVideoPlayerBarView : UIView{
    NSTimeInterval _currentTime;//当前时间
    NSTimeInterval _durationtime;//当前时间
}

@property (nonatomic,strong)UIImageView *backgroundImageView;
@property (nonatomic,strong)KKVideoPlayerSlider *mySlider;
@property (nonatomic,strong)UILabel *currentTimeLabel;
@property (nonatomic,strong)UILabel *durationtimeLabel;
@property (nonatomic,assign)NSTimeInterval currentTime;//当前时间
@property (nonatomic,assign)NSTimeInterval durationtime;//当前时间
@property (nonatomic,strong)UIButton *stopPlayButton;
@property (nonatomic,strong)UIButton *backButton;//返回（×）
@property (nonatomic,strong)UIButton *moreButton;//更多（…）
@property (nonatomic,assign)BOOL isSliderTouched;

@property (nonatomic,assign)id<KKVideoPlayerBarViewDelegate> delegate;

- (void)setButtonStatusStop;

- (void)setButtonStatusPlaying;

@end


@protocol KKVideoPlayerBarViewDelegate <NSObject>

- (void)KKVideoPlayerBarView_BackButtonClicked:(KKVideoPlayerBarView*)aView;

- (void)KKVideoPlayerBarView_MoreButtonClicked:(KKVideoPlayerBarView*)aView;

- (void)KKVideoPlayerBarView_PlayButtonClicked:(KKVideoPlayerBarView*)aView;

- (void)KKVideoPlayerBarView_PauseButtonClicked:(KKVideoPlayerBarView*)aView;

- (void)KKVideoPlayerBarView:(KKVideoPlayerBarView*)aView currentTimeChanged:(NSTimeInterval)aCurrentTime;

@end

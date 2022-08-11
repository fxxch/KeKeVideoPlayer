//
//  MusicControlView.h
//  KeKeVideoPlayer
//
//  Created by edward lannister on 2022/08/06.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPlayerSlider : UISlider

@end

@protocol MusicControlViewDelegate;

@interface MusicControlView : UIView{
    NSTimeInterval _currentTime;//当前时间
    NSTimeInterval _durationtime;//当前时间
}

@property (nonatomic,strong)UIImageView *backgroundImageView;
@property (nonatomic,strong)MusicPlayerSlider *mySlider;
@property (nonatomic,strong)UILabel *indexLabel;
@property (nonatomic,strong)UILabel *currentTimeLabel;
@property (nonatomic,strong)UILabel *durationtimeLabel;
@property (nonatomic,assign)NSTimeInterval currentTime;//当前时间
@property (nonatomic,assign)NSTimeInterval durationtime;//当前时间
@property (nonatomic,strong)UIButton *stopPlayButton;
@property (nonatomic,strong)UIButton *prevButton;//上一个
@property (nonatomic,strong)UIButton *nextButton;//下一个
@property (nonatomic,assign)BOOL isSliderTouched;

@property (nonatomic , weak) id<MusicControlViewDelegate> delegate;

- (void)setButtonStatusStop;

- (void)setButtonStatusPlaying;


@end


#pragma mark ==================================================
#pragma mark == MusicControlViewDelegate
#pragma mark ==================================================
@protocol MusicControlViewDelegate <NSObject>
@optional

- (void)MusicControlView_PrevButtonClicked:(MusicControlView*)aView;

- (void)MusicControlView_NextButtonClicked:(MusicControlView*)aView;

- (void)MusicControlView_PlayButtonClicked:(MusicControlView*)aView;

- (void)MusicControlView_PauseButtonClicked:(MusicControlView*)aView;

- (void)MusicControlView:(MusicControlView*)aView currentTimeChanged:(NSTimeInterval)aCurrentTime;


@end

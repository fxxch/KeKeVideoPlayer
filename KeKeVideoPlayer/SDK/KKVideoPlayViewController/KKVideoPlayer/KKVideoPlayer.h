//
//  KKVideoPlayer.h
//  CEDongLi
//
//  Created by beartech on 15/10/26.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>

typedef NS_ENUM(NSInteger,KKVideoPlayerStatus) {
    
    KKVideoPlayerStatus_None=0,
    
    KKVideoPlayerStatus_Playing=1,
    
    KKVideoPlayerStatus_Pause=2,
};


@protocol KKVideoPlayerDelegate;

@interface KKVideoPlayer : UIView

@property (nonatomic,assign)id<KKVideoPlayerDelegate> delegate;
@property (atomic, strong) id<IJKMediaPlayback> player;
@property (atomic, copy) NSString *urlString;
@property (nonatomic, assign) KKVideoPlayerStatus playerStatus;

- (instancetype)initWithFrame:(CGRect)frame URLString:(NSString*)aURLString;

- (void)startPlay;

- (void)pausePlay;

- (void)stopPlay;

- (void)seekToBackTime:(NSTimeInterval)aTime;

- (CGSize)videoFrameSize;

- (CGSize)videoRealFrameSize;

- (NSInteger)videoDegrees;

@end


@protocol KKVideoPlayerDelegate <NSObject>
@optional
//准备播放
- (void)KKVideoPlayer_IJKMediaPlaybackIsPreparedToPlayDidChange:(NSDictionary*)aVideoInfo
                                                      audioInfo:(NSDictionary*)aAudioInfo;

//获取到视频信息
- (void)KKVideoPlayer_VideoInfoDecoded:(NSDictionary*)aVideoInfo;

@required
//播放开始
- (void)KKVideoPlayer_PlayDidStart:(KKVideoPlayer*)player;

//继续开始
- (void)KKVideoPlayer_PlayDidContinuePlay:(KKVideoPlayer*)player;

//播放结束
- (void)KKVideoPlayer_PlayDidFinished:(KKVideoPlayer*)player;

//播放暂停
- (void)KKVideoPlayer_PlayDidPause:(KKVideoPlayer*)player;

//播放错误
- (void)KKVideoPlayer_CanNotPlay:(KKVideoPlayer*)player;

//播放时间改变
- (void)KKVideoPlayer:(KKVideoPlayer*)player
  playBackTimeChanged:(NSTimeInterval)currentTime
         durationtime:(NSTimeInterval)durationtime;

@end



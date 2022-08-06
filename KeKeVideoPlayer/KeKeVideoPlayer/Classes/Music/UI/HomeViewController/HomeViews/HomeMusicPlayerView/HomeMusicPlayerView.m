//
//  HomeMusicPlayerView.m
//  Music
//
//  Created by edward lannister on 2022/08/05.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "HomeMusicPlayerView.h"
#import "KKVideoPlayer.h"

@interface HomeMusicPlayerView ()<KKVideoPlayerDelegate>

@property (nonatomic , strong) KKVideoPlayer *player;
@property (nonatomic , strong) UIImageView *audioBackgroundView;

@end

@implementation HomeMusicPlayerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.audioBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    UIImage *image = [NSBundle kk_imageInBundle:@"KKVideoPlay_Resource.bundle" imageName:@"VideoPlay_musicBackground"];
    self.audioBackgroundView.image = image;
    self.audioBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.audioBackgroundView];

    //播放器
//    self.player = [[KKVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, 1, 1) URLString:self.documentRemoteURL];
//    self.player.delegate = self;
//    [self addSubview:self.player];
//    self.player.hidden = YES;
}

#pragma mark ==================================================
#pragma mark == KKVideoPlayerDelegate
#pragma mark ==================================================
//准备播放
- (void)KKVideoPlayer_IJKMediaPlaybackIsPreparedToPlayDidChange:(NSDictionary*)aVideoInfo
                                                      audioInfo:(NSDictionary*)aAudioInfo{
    
}

//获取到视频信息
- (void)KKVideoPlayer_VideoInfoDecoded:(NSDictionary*)aVideoInfo{
    
}

//播放开始
- (void)KKVideoPlayer_PlayDidStart:(KKVideoPlayer*)player{
    
}

//继续开始
- (void)KKVideoPlayer_PlayDidContinuePlay:(KKVideoPlayer*)player{
    
}

//播放结束
- (void)KKVideoPlayer_PlayDidFinished:(KKVideoPlayer*)player{
    
}

//播放暂停
- (void)KKVideoPlayer_PlayDidPause:(KKVideoPlayer*)player{
    
}

//播放错误
- (void)KKVideoPlayer_CanNotPlay:(KKVideoPlayer*)player{
    
}

//播放时间改变
- (void)KKVideoPlayer:(KKVideoPlayer*)player
  playBackTimeChanged:(NSTimeInterval)currentTime
         durationtime:(NSTimeInterval)durationtime{
    
}



@end

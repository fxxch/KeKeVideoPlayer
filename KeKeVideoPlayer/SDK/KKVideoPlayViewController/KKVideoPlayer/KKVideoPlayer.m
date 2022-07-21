//
//  KKVideoPlayer.m
//  CEDongLi
//
//  Created by beartech on 15/10/26.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import "KKVideoPlayer.h"
#import "KKWaitingView.h"
#import "KKLog.h"
#import "KKCategory.h"
#import <AVFoundation/AVFoundation.h>

@interface KKVideoPlayer ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView* mainScrollView;
@property (nonatomic, assign) NSInteger videoDegrees_Private;
@property (nonatomic, assign) CGSize videoFrameSize_Private;

@end

@implementation KKVideoPlayer


- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.mainScrollView.frame = self.bounds;
    [self.mainScrollView setZoomScale:1.0 animated:YES];
    self.player.view.frame = self.mainScrollView.bounds;
}

- (instancetype)initWithFrame:(CGRect)frame URLString:(NSString*)aURLString{
    self = [super initWithFrame:frame];
    if (self) {
        self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.mainScrollView.backgroundColor = [UIColor clearColor];
        self.mainScrollView.bounces = YES;
        self.mainScrollView.minimumZoomScale = 1.0;
        self.mainScrollView.maximumZoomScale = 5.0;
        self.mainScrollView.delegate = self;
        self.mainScrollView.contentMode = UIViewContentModeScaleAspectFill;
        self.mainScrollView.clipsToBounds = YES;
        if (@available(iOS 11.0, *)) {
            self.mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:self.mainScrollView];
        UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizer:)];
        doubleRecognizer.numberOfTapsRequired = 2;
        [self.mainScrollView addGestureRecognizer:doubleRecognizer];

        NSURL *fileURL = [NSURL URLWithString:aURLString];
        self.urlString = [fileURL absoluteString];
        self.videoDegrees_Private = -1;
        self.videoFrameSize_Private = CGSizeZero;
        
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
        
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];

        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.urlString] withOptions:options];
        
        self.player.view.frame = self.mainScrollView.bounds;
        self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
        self.player.shouldAutoplay = YES;
        [self.player setPauseInBackground:YES];
        self.autoresizesSubviews = YES;
        [self.mainScrollView addSubview:self.player.view];
    }
    return self;
}

- (void)startPlay{
    if ([self.player isPreparedToPlay] && self.playerStatus==KKVideoPlayerStatus_Pause) {
        [self.player play];
        self.playerStatus = KKVideoPlayerStatus_Playing;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_PlayDidContinuePlay:)]) {
            [self.delegate KKVideoPlayer_PlayDidContinuePlay:self];
        }
        [self playerPlaybackDidChanged];
    }
    else{
        [self installMovieNotificationObservers];
        [self.player prepareToPlay];
        [self.player setCurrentPlaybackTime:0];
        [self.player play];
        self.playerStatus = KKVideoPlayerStatus_Playing;

        if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_PlayDidStart:)]) {
            [self.delegate KKVideoPlayer_PlayDidStart:self];
        }
        
        [self playerPlaybackDidChanged];
    }
}

- (void)pausePlay{
    if ([self.player isPlaying]) {
        [self.player pause];
        self.playerStatus = KKVideoPlayerStatus_Pause;

        if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_PlayDidPause:)]) {
            [self.delegate KKVideoPlayer_PlayDidPause:self];
        }
    }
}

- (void)stopPlay{
    [self.player shutdown];
    [self removeMovieNotificationObservers];
    self.playerStatus = KKVideoPlayerStatus_None;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerPlaybackDidChanged) object:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_PlayDidFinished:)]) {
        [self.delegate KKVideoPlayer_PlayDidFinished:self];
    }
}

- (void)seekToBackTime:(NSTimeInterval)aTime{
    self.player.currentPlaybackTime = aTime;
}

#pragma mark ==================================================
#pragma mark == 播放过程通知 Notification
#pragma mark ==================================================
/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Notification_IJKMoviePlayerLoadStateDidChange:)
                                                 name:IJKMoviePlayerLoadStateDidChangeNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Notification_IJKMoviePlayerPlaybackDidFinish:)
                                                 name:IJKMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Notification_IJKMediaPlaybackIsPreparedToPlayDidChange:)
                                                 name:IJKMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Notification_IJKMoviePlayerPlaybackStateDidChange:)
                                                 name:IJKMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Notification_IJKMoviePlayerFirstVideoFrameRendered:)
                                                 name:IJKMoviePlayerFirstVideoFrameRenderedNotification
                                               object:self.player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Notification_IJKMoviePlayerFirstVideoFrameDecoded:)
                                                 name:IJKMoviePlayerFirstVideoFrameDecodedNotification
                                               object:self.player];
}

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMoviePlayerLoadStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMoviePlayerPlaybackDidFinishNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMediaPlaybackIsPreparedToPlayDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMoviePlayerPlaybackStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMoviePlayerFirstVideoFrameRenderedNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMoviePlayerFirstVideoFrameDecodedNotification object:self.player];
}

/*播放状态：缓存中……、播放中……*/
- (void)Notification_IJKMoviePlayerLoadStateDidChange:(NSNotification*)notification{
//    MPMovieLoadStateUnknown        = 0,
//    MPMovieLoadStatePlayable       = 1 << 0,
//    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
//    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = self.player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        [KKWaitingView hideForView:self];
        KKLogDebugFormat(@"loadStateDidChange: MPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    }
    else if ((loadState & IJKMPMovieLoadStatePlayable) != 0) {
        [KKWaitingView hideForView:self];
        KKLogDebugFormat(@"loadStateDidChange: MPMovieLoadStatePlayable: %d\n", (int)loadState);
    }
    else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        KKWaitingView *waitingview = [KKWaitingView showInView:self withType:KKWaitingViewType_White blackBackground:NO text:nil];
        waitingview.userInteractionEnabled = NO;
        KKLogDebugFormat(@"loadStateDidChange: MPMovieLoadStateStalled: %d\n", (int)loadState);
    }
    else {
        KKWaitingView *waitingview = [KKWaitingView showInView:self withType:KKWaitingViewType_White blackBackground:NO text:nil];
        waitingview.userInteractionEnabled = NO;
        KKLogDebugFormat(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)Notification_IJKMoviePlayerPlaybackDidFinish:(NSNotification*)notification{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            KKLogDebugFormat(@"playbackStateDidChange: MPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
        case IJKMPMovieFinishReasonUserExited:
            KKLogDebugFormat(@"playbackStateDidChange: MPMovieFinishReasonUserExited: %d\n", reason);
            break;
        case IJKMPMovieFinishReasonPlaybackError:
            KKLogDebugFormat(@"playbackStateDidChange: MPMovieFinishReasonPlaybackError: %d\n", reason);
            if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_CanNotPlay:)]) {
                [self.delegate KKVideoPlayer_CanNotPlay:self];
            }
            break;
        default:
            KKLogDebugFormat(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerPlaybackDidChanged) object:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_PlayDidFinished:)]) {
        [self.delegate KKVideoPlayer_PlayDidFinished:self];
    }
}

- (void)Notification_IJKMediaPlaybackIsPreparedToPlayDidChange:(NSNotification*)notification{
    KKLogDebug(@"mediaIsPreparedToPlayDidChange\n");
    IJKFFMoviePlayerController *media = (IJKFFMoviePlayerController*)self.player;
    NSDictionary *videoMeta = media.monitor.videoMeta;
    NSDictionary *audioMeta = media.monitor.audioMeta;
    CGFloat width = [[videoMeta objectForKey:@"width"] floatValue];
    CGFloat height = [[videoMeta objectForKey:@"height"] floatValue];
    self.videoFrameSize_Private = CGSizeMake(width, height);
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_IJKMediaPlaybackIsPreparedToPlayDidChange:audioInfo:)]) {
        [self.delegate KKVideoPlayer_IJKMediaPlaybackIsPreparedToPlayDidChange:videoMeta
                                                                     audioInfo:audioMeta];
    }

    if ([NSString kk_isLocalFilePath:self.urlString]) {
        NSURL *fileURL = [NSURL URLWithString:self.urlString];
        CGFloat degrees = [self degressFromVideoFileWithURL:fileURL];
        [self rotateVideoViewWithDegrees:degrees];
    }
}

- (void)Notification_IJKMoviePlayerPlaybackStateDidChange:(NSNotification*)notification{
//    IJKMPMoviePlaybackStateStopped,
//    IJKMPMoviePlaybackStatePlaying,
//    IJKMPMoviePlaybackStatePaused,
//    IJKMPMoviePlaybackStateInterrupted,
//    IJKMPMoviePlaybackStateSeekingForward,
//    IJKMPMoviePlaybackStateSeekingBackward

    switch (self.player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            self.playerStatus = KKVideoPlayerStatus_None;
            KKLogDebugFormat(@"moviePlayBackStateDidChange %d: stoped", (int)self.player.playbackState);
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerPlaybackDidChanged) object:nil];
            if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_PlayDidFinished:)]) {
                [self.delegate KKVideoPlayer_PlayDidFinished:self];
            }
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            self.playerStatus = KKVideoPlayerStatus_Playing;
            KKLogDebugFormat(@"moviePlayBackStateDidChange %d: playing", (int)self.player.playbackState);
            if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_PlayDidContinuePlay:)]) {
                [self.delegate KKVideoPlayer_PlayDidContinuePlay:self];
            }
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            self.playerStatus = KKVideoPlayerStatus_Pause;
            KKLogDebugFormat(@"moviePlayBackStateDidChange %d: paused", (int)self.player.playbackState);
            if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_PlayDidPause:)]) {
                [self.delegate KKVideoPlayer_PlayDidPause:self];
            }
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            self.playerStatus = KKVideoPlayerStatus_None;
            KKLogDebugFormat(@"moviePlayBackStateDidChange %d: interrupted", (int)self.player.playbackState);
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerPlaybackDidChanged) object:nil];
            if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_PlayDidFinished:)]) {
                [self.delegate KKVideoPlayer_PlayDidFinished:self];
            }
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            KKLogDebugFormat(@"moviePlayBackStateDidChange %d: seeking", (int)self.player.playbackState);
            break;
        }
        default: {
            KKLogDebugFormat(@"moviePlayBackStateDidChange %d: unknown", (int)self.player.playbackState);
            break;
        }
    }
}

- (void)Notification_IJKMoviePlayerFirstVideoFrameRendered:(NSNotification*)notice{
//    UIImage *thumbnailImage = self.player.thumbnailImageAtCurrentTime;
//    NSLog(@"");
}

- (void)Notification_IJKMoviePlayerFirstVideoFrameDecoded:(NSNotification*)notice{
    IJKFFMoviePlayerController *media = (IJKFFMoviePlayerController*)self.player;
    NSDictionary *videoInfo = media.monitor.videoMeta;
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer_VideoInfoDecoded:)]) {
        [self.delegate KKVideoPlayer_VideoInfoDecoded:videoInfo];
    }
}

- (void)playerPlaybackDidChanged{
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKVideoPlayer:playBackTimeChanged:durationtime:)]) {
        CGFloat time1 = self.player.currentPlaybackTime;
        CGFloat time2 = self.player.duration;
        
        [self.delegate KKVideoPlayer:self playBackTimeChanged:(time1<1)?0:time1 durationtime:MAX(time2, 1.0)];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerPlaybackDidChanged) object:nil];
    [self performSelector:@selector(playerPlaybackDidChanged) withObject:nil afterDelay:0.5];
}

- (void)rotateVideoViewWithDegrees:(NSInteger)degrees{
    self.videoDegrees_Private = degrees;
    if(degrees==0||degrees==360) return;
    if(degrees<0) degrees = (degrees % 360) + 360;
    if(degrees>360) degrees = degrees % 360;

    self.player.view.transform = CGAffineTransformMakeRotation(M_PI * degrees / 180.0);
    self.player.view.frame = self.bounds;
}

- (NSUInteger)degressFromVideoFileWithURL:(NSURL*_Nullable)url{
    NSUInteger degress = 0;
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

- (CGSize)videoFrameSize{
    return self.videoFrameSize_Private;
}

- (CGSize)videoRealFrameSize{
    if (self.videoDegrees_Private<0) {
        return CGSizeZero;
    }
    NSInteger degrees = self.videoDegrees_Private;
    if(degrees<0) degrees = (degrees % 360) + 360;
    if(degrees>360) degrees = degrees % 360;
    
    CGSize size =  [self videoFrameSize];
    if(degrees==0||degrees==360) {
        return size;
    }
    else if (degrees==90||degrees==270){
        return CGSizeMake(size.height, size.width);
    }
    else if (degrees==180){
        return size;
    } else {
        return size;
    }
}

- (NSInteger)videoDegrees{
    return self.videoDegrees_Private;
}

#pragma mark ==================================================
#pragma mark == Zooming
#pragma mark ==================================================
- (void) doubleTapGestureRecognizer:(UITapGestureRecognizer*) tap {
    [self.mainScrollView setZoomScale:1.0 animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.player.view;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self reloadImageViewFrame];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
//    [self reloadImageViewFrame];
//    NSLog(@"%@: SCALE:%.1f",view,scale);
}

- (void)reloadImageViewFrame{
    CGFloat offsetX = (self.mainScrollView.bounds.size.width > self.mainScrollView.contentSize.width)?(self.mainScrollView.bounds.size.width - self.mainScrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (self.mainScrollView.bounds.size.height > self.mainScrollView.contentSize.height)?(self.mainScrollView.bounds.size.height - self.mainScrollView.contentSize.height)/2 : 0.0;
    self.player.view.center = CGPointMake(self.mainScrollView.contentSize.width/2 + offsetX,self.mainScrollView.contentSize.height/2 + offsetY);
}



@end

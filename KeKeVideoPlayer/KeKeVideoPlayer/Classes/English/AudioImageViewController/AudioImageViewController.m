//
//  AudioImageViewController.m
//  English
//
//  Created by liubo on 2021/4/29.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "AudioImageViewController.h"
#import "KKVideoPlayerNavigationView.h"
#import "KKVideoPlayerBarView.h"
#import "KKVideoPlayerVolumeView.h"
#import "KKVideoPlayerForwardView.h"
#import "KKVideoPlayer.h"
#import "KKFileCacheManager.h"
#import "KKCategory.h"
#import "KKLibraryDefine.h"
#import "KKLocalizationManager.h"
#import "KKAlertView.h"
#import "KKButton.h"
#import <CoreMotion/CoreMotion.h>
#import "ENImagePageView.h"

#define HiddenPlayerBarTimerMax 5

@interface AudioImageViewController ()
<KKVideoPlayerNavigationViewDelegate,KKVideoPlayerBarViewDelegate,KKVideoPlayerVolumeViewDelegate,UIGestureRecognizerDelegate,KKVideoPlayerDelegate,ENImagePageViewDelegate>

@property (nonatomic,strong)UIImageView *audioBackgroundView;


@property (nonatomic , strong) ENImagePageView *imagePageView;
@property (nonatomic,strong)KKVideoPlayerNavigationView *navigationBarView;
@property (nonatomic,strong)KKVideoPlayerBarView *toolBarView;
@property (nonatomic,strong)KKVideoPlayerVolumeView *volumeView;
@property (nonatomic,strong)KKVideoPlayer *player;
@property (nonatomic,strong)UIButton *playButton;
@property (nonatomic,assign)BOOL isGestureON;
@property (nonatomic,assign) BOOL isVideo;
@property (nonatomic,strong) NSTimer *myTimer;//定时隐藏操作Bar
@property (nonatomic,assign) NSInteger myTimerCount;//定时隐藏操作Bar
@property (nonatomic,assign) BOOL isBarHidden;
@property (nonatomic,assign) BOOL haveViewDidAppear;

@property (nonatomic , strong) NSMutableArray *imageNamesArray;

@end

@implementation AudioImageViewController

- (void)dealloc{
    [self destroyTimer];
    [self.player stopPlay];
}

- (instancetype)initWitAudioFilePath:(NSString*)aAudioFilePath
                          imageNames:(NSArray*)aImageNamesArray
                            fileName:(NSString*)aFileName{
    self = [super init];
    if (self) {
        self.imageNamesArray = [[NSMutableArray alloc] init];
        [self.imageNamesArray addObjectsFromArray:aImageNamesArray];
        self.documentRemoteURL = aAudioFilePath;
        self.documentRemoteName = aFileName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.audioBackgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    UIImage *image = [NSBundle kk_imageInBundle:@"KKVideoPlay_Resource.bundle" imageName:@"VideoPlay_musicBackground"];
    self.audioBackgroundView.image = image;
    self.audioBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.audioBackgroundView];
    self.audioBackgroundView.hidden = YES;
    
    //背景图片
    self.imagePageView = [[ENImagePageView alloc] initWithFrame:self.view.bounds items:self.imageNamesArray];
    self.imagePageView.delegate = self;
    [self.view addSubview:self.imagePageView];
    self.audioBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    //播放器
    self.player = [[KKVideoPlayer alloc] initWithFrame:CGRectMake(-10000, -10000, 1, 1) URLString:self.documentRemoteURL];
    self.player.delegate = self;
    [self.view addSubview:self.player];
    self.player.hidden = YES;
    //添加手势
//    [self addGestureRecognizerOnView:self.player];
    
    //导航栏
    self.navigationBarView = [[KKVideoPlayerNavigationView alloc] initWithFrame:CGRectMake(0, 0, KKApplicationWidth, 64)];
    self.navigationBarView.delegate = self;
    self.navigationBarView.titleLabel.text = self.documentRemoteName;
    [self.view addSubview:self.navigationBarView];
    self.navigationBarView.hidden = YES;
    
    //底部播放控制栏
    self.toolBarView = [[KKVideoPlayerBarView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-64, KKApplicationWidth, 64)];
    self.toolBarView.delegate = self;
    self.toolBarView.durationtime = 1.0;
    self.toolBarView.currentTime = 0;
    [self.view addSubview:self.toolBarView];
    self.toolBarView.moreButton.hidden = YES;

    //声音控制栏
    self.volumeView = [[KKVideoPlayerVolumeView alloc] initWithFrame:CGRectMake(0, (KKApplicationHeight-200)/2.0, 40, 180)];
    self.volumeView.delegate = self;
    [self.view addSubview:self.volumeView];
    self.volumeView.hidden = YES;
    
    [self reloadSubViewsFrame];
        
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [self.playButton addTarget:self action:@selector(playButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    UIImage *playImage = [NSBundle kk_imageInBundle:@"KKVideoPlay_Resource.bundle" imageName:@"VideoPlay_PlayBig"];
    [self.playButton setBackgroundImage:playImage forState:UIControlStateNormal];
    [self.playButton setCenter:self.player.center];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setStatusBarHidden:NO statusBarStyle:UIStatusBarStyleLightContent withAnimation:UIStatusBarAnimationFade];
    //    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //    delegate.onlySupportPortrait = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self closeInteractivePopGestureRecognizer];
    if (self.haveViewDidAppear==NO) {
        self.haveViewDidAppear = YES;
        [self setAllBarHidden:NO];
        [self.player startPlay];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.canPlayInBackground==NO) {
        [self.player pausePlay];
    }
}

- (void)navigationControllerPopBack{
    [self.player stopPlay];
    //    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //    delegate.onlySupportPortrait = YES;
    
    if (self.navigationController.presentingViewController) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)playButtonClicked{
    [self.player startPlay];
}

- (CGSize)videoFrameSize{
    return [self.player videoRealFrameSize];
}

#pragma mark ==================================================
#pragma mark == 屏幕旋转
#pragma mark ==================================================
//屏幕旋转之后，屏幕的宽高互换，我们借此判断重新布局
//横屏：size.width > size.height
//竖屏: size.width < size.height
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
    NSLog(@"转屏前调入");
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
    NSLog(@"转屏后调入");
    [self reloadSubViewsFrame];
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)reloadSubViewsFrame{
    UIInterfaceOrientation currentIsPortrait = [UIApplication sharedApplication].statusBarOrientation;
    switch (currentIsPortrait) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:{
            self.player.frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight);
            self.audioBackgroundView.frame = self.player.frame;
            self.imagePageView.frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight);
            
            self.navigationBarView.frame = CGRectMake(0, 0, self.player.kk_width, KKStatusBarAndNavBarHeight);
            self.toolBarView.frame = CGRectMake(0, self.player.kk_height-(KKSafeAreaBottomHeight+120), self.player.kk_width, 120+KKSafeAreaBottomHeight);
            self.volumeView.frame = CGRectMake(0, (self.player.kk_height-180)/2.0, 40, 180);
            [self.playButton setCenter:self.player.center];
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown:{
            CGFloat statusH = 0;
            //            if ([[UIDevice currentDevice] isiPhoneX]) {
            //                statusH = KKStatusBarHeight;
            //            }
            
            self.player.frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight);
            self.audioBackgroundView.frame = self.player.frame;
            self.imagePageView.frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight);

            self.navigationBarView.frame = CGRectMake(0, 0, self.player.kk_width, KKSafeAreaBottomHeight+KKNavigationBarHeight);
            self.toolBarView.frame = CGRectMake(0, self.player.kk_height-(statusH+120), self.player.kk_width, 120+statusH);
            self.volumeView.frame = CGRectMake(0, (self.player.kk_height-180)/2.0, 40, 180);
            [self.playButton setCenter:self.player.center];
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:{
            CGFloat safeAreaBottomH = 0;
            //            if ([[UIDevice currentDevice] isiPhoneX]) {
            //                safeAreaBottomH = KKSafeAreaBottomHeight;
            //            }
            
            self.player.frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight);
            self.audioBackgroundView.frame = self.player.frame;
            self.imagePageView.frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight);

            /* 横屏 */
            self.navigationBarView.frame = CGRectMake(0, 0, self.player.kk_width, 64);
            self.toolBarView.frame = CGRectMake(0, self.player.kk_height-60, self.player.kk_width, 60);
            self.volumeView.frame = CGRectMake(safeAreaBottomH, (self.player.kk_height-180)/2.0, 40, 180);
            [self.playButton setCenter:self.player.center];
            break;
        }
        case UIInterfaceOrientationLandscapeRight:{
            CGFloat statusH = 0;
            if ([[UIDevice currentDevice] kk_isiPhoneX]) {
                statusH = KKStatusBarHeight;
            }
            
            self.player.frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight);
            self.audioBackgroundView.frame = self.player.frame;
            self.imagePageView.frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight);

            /* 横屏 */
            self.navigationBarView.frame = CGRectMake(0, 0, self.player.kk_width, 64);
            self.toolBarView.frame = CGRectMake(0, self.player.kk_height-60, self.player.kk_width, 60);
            self.volumeView.frame = CGRectMake(statusH, (self.player.kk_height-180)/2.0, 40, 180);
            [self.playButton setCenter:self.player.center];
            break;
        }
        default:
            break;
    }
}

#pragma mark ****************************************
#pragma mark 屏幕方向
#pragma mark ****************************************
//1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate {
    return YES;
}

//2.返回支持的旋转方向（当前viewcontroller支持哪些转屏方向）
//iPad设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
//iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

//3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark ==================================================
#pragma mark == 手势
#pragma mark ==================================================
//添加手势
- (void)addGestureRecognizerOnView:(UIView*)aView{
    
    //单击手势
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognizer.delegate = self;
    [aView addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizer:)];
    doubleRecognizer.numberOfTapsRequired = 2;// 双击
    //关键语句，给self.view添加一个手势监测；
    [aView addGestureRecognizer:doubleRecognizer];
    // 关键在这一行，双击手势确定监测失败才会触发单击手势的相应操作
    [tapGestureRecognizer requireGestureRecognizerToFail:doubleRecognizer];
    
//    //滑动手势
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
//                                                    initWithTarget:self
//                                                    action:@selector(panGestureRecognizer:)];
//    panGestureRecognizer.maximumNumberOfTouches = 1;
//    [aView addGestureRecognizer:panGestureRecognizer];
}

- (void)singleTapGestureRecognizer:(UITapGestureRecognizer*)recognizer{
    if ([self.player.player isPlaying]) {
        [self setAllBarHidden:!self.isBarHidden];
    }
}

- (void)doubleTapGestureRecognizer:(UITapGestureRecognizer*)recognizer{
    if ([self.player.player isPlaying]) {
        [self.player pausePlay];
    }
    else if ([self.player.player isPreparedToPlay]){
        [self.player startPlay];
    }
    else{
        
    }
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
    
    static CGPoint lastPoint;
    static CGPoint startPoint;
    static NSInteger panType = 0;//0未知 1、左右快进后退 2、上下音量
    static CGFloat timeStart = 0;
    
    if (recognizer.state==UIGestureRecognizerStateBegan) {
        timeStart = self.player.player.currentPlaybackTime+0.5;
        startPoint = [recognizer locationInView:self.player];
        lastPoint = [recognizer locationInView:self.player];
        self.isGestureON = YES;
    }
    else if (recognizer.state==UIGestureRecognizerStateChanged){
        CGPoint nowPoint = [recognizer locationInView:self.player];
        if (panType == 0) {
            if (ABS(nowPoint.x-lastPoint.x) > ABS(nowPoint.y-lastPoint.y)) {
                panType = 1;
            }
            else{
                panType = 2;
            }
        }
        
        if (panType == 1 && self.toolBarView.durationtime>0) {
            CGFloat xDistance = nowPoint.x-startPoint.x;
            CGFloat timePer = (self.toolBarView.durationtime>120)?120:self.toolBarView.durationtime;
            NSTimeInterval timeCha = timePer*(xDistance/recognizer.view.frame.size.width);
            if (ABS(timeCha)>=1) {
                if (timeCha>0) {
                    NSTimeInterval newTime = MIN(timeStart+ABS(timeCha), self.player.player.duration+0.5);
                    [KKVideoPlayerForwardView showInView:self.player
                                             currentTime:newTime
                                            durationtime:self.player.player.duration+0.5
                                               isForward:YES];
                    self.toolBarView.mySlider.value = newTime;
                }
                else{
                    NSTimeInterval newTime = MAX(timeStart-ABS(timeCha), 0);
                    [KKVideoPlayerForwardView showInView:self.player
                                             currentTime:newTime
                                            durationtime:self.player.player.duration+0.5
                                               isForward:NO];
                    self.toolBarView.mySlider.value = newTime;
                }
                lastPoint = nowPoint;
            }
        }
        else if (panType == 2){
            CGFloat yDistance = nowPoint.y-lastPoint.y;
            CGFloat volume = yDistance/100.0;
            if (ABS(volume)>=0.1) {
                if (volume>0) {
                    self.volumeView.currentVolume = MAX(self.volumeView.currentVolume - ABS(volume), 0);
                }
                else{
                    self.volumeView.currentVolume = MIN(self.volumeView.currentVolume + ABS(volume), 1.0);
                }
                lastPoint = nowPoint;
            }
        }
        else{
            
        }
        
    }
    else if (recognizer.state==UIGestureRecognizerStateEnded){
        if (panType == 1) {
            CGPoint nowPoint = [recognizer locationInView:self.player];
            CGFloat xDistance = nowPoint.x-startPoint.x;
            CGFloat timePer = (self.toolBarView.durationtime>120)?120:self.toolBarView.durationtime;
            NSTimeInterval time = timePer*(xDistance/recognizer.view.frame.size.width);
            if (ABS(time)>=1) {
                if (time>0) {
                    NSTimeInterval newTime = MIN(self.player.player.currentPlaybackTime+0.5+ABS(time), self.player.player.duration+0.5);
                    [self.player seekToBackTime:newTime];
                }
                else{
                    NSTimeInterval newTime = MAX(self.player.player.currentPlaybackTime+0.5-ABS(time), 0);
                    [self.player seekToBackTime:newTime];
                }
            }
        }
        
        startPoint = CGPointMake(0, 0);
        lastPoint = CGPointMake(0, 0);
        panType = 0;
        self.isGestureON = NO;
        [KKVideoPlayerForwardView hideForView:self.player];
    }
    else if (recognizer.state==UIGestureRecognizerStateCancelled){
        startPoint = CGPointMake(0, 0);
        lastPoint = CGPointMake(0, 0);
        panType = 0;
        self.isGestureON = NO;
        [KKVideoPlayerForwardView hideForView:self.player];
    }
    else{
        startPoint = CGPointMake(0, 0);
        lastPoint = CGPointMake(0, 0);
        panType = 0;
        self.isGestureON = NO;
        [KKVideoPlayerForwardView hideForView:self.player];
    }
}

#pragma mark ==================================================
#pragma mark == ENImagePageViewDelegate
#pragma mark ==================================================
- (void)ENImagePageView_SingleTap:(NSString*_Nonnull)aFileName{
    [self setAllBarHidden:!self.isBarHidden];
}

#pragma mark ==================================================
#pragma mark == 代理事件
#pragma mark ==================================================
//返回
- (void)KKVideoPlayerNavigationView_LeftButtonClicked:(KKVideoPlayerNavigationView*)aView{
    UIInterfaceOrientation nowOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (nowOrientation==UIInterfaceOrientationLandscapeLeft ||
        nowOrientation==UIInterfaceOrientationLandscapeRight) {
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [self performSelector:@selector(navigationControllerPopBack) withObject:nil afterDelay:duration*0.5];
    }
    else{
        [self performSelector:@selector(navigationControllerPopBack) withObject:nil afterDelay:0];
    }
}

- (void)KKVideoPlayerBarView_BackButtonClicked:(KKVideoPlayerBarView*)aView{
    UIInterfaceOrientation nowOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (nowOrientation==UIInterfaceOrientationLandscapeLeft ||
        nowOrientation==UIInterfaceOrientationLandscapeRight) {
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [self performSelector:@selector(navigationControllerPopBack) withObject:nil afterDelay:duration*0.5];
    }
    else{
        [self performSelector:@selector(navigationControllerPopBack) withObject:nil afterDelay:0];
    }
}

- (void)KKVideoPlayerBarView_MoreButtonClicked:(KKVideoPlayerBarView*)aView{

}

//播放
- (void)KKVideoPlayerBarView_PlayButtonClicked:(KKVideoPlayerBarView*)aView{
    [self.player startPlay];
}

//暂停
- (void)KKVideoPlayerBarView_PauseButtonClicked:(KKVideoPlayerBarView*)aView{
    [self.player pausePlay];
}

//前进
- (void)KKVideoPlayerBarView:(KKVideoPlayerBarView*)aView currentTimeChanged:(NSTimeInterval)aCurrentTime{
    [self.player seekToBackTime:aCurrentTime];
}

#pragma mark ==================================================
#pragma mark == 视频播放代理
#pragma mark ==================================================
//准备播放
- (void)KKVideoPlayer_IJKMediaPlaybackIsPreparedToPlayDidChange:(NSDictionary*)aVideoInfo
                                                      audioInfo:(NSDictionary*)aAudioInfo{
    if ([NSDictionary kk_isDictionaryNotEmpty:aVideoInfo]) {
        self.audioBackgroundView.hidden = YES;
        self.isVideo = YES;
    } else {
        self.audioBackgroundView.hidden = NO;
        self.isVideo = NO;
    }
    CGFloat width = [[aVideoInfo objectForKey:@"width"] floatValue];
    CGFloat height = [[aVideoInfo objectForKey:@"height"] floatValue];
    NSLog(@"获取到视频第一帧图片宽高：%@",NSStringFromCGSize(CGSizeMake(width, height)));
    //    [self fixVideoFrame];
}

//获取到第一帧图片
- (void)KKVideoPlayer_VideoInfoDecoded:(NSDictionary*)aVideoInfo{
    
}

//播放开始
- (void)KKVideoPlayer_PlayDidStart:(KKVideoPlayer*)player{
    [self.toolBarView setButtonStatusPlaying];
    [self startTimer];
    self.playButton.hidden = YES;
}

//继续开始
- (void)KKVideoPlayer_PlayDidContinuePlay:(KKVideoPlayer*)player{
    [self.toolBarView setButtonStatusPlaying];
    [self startTimer];
    self.playButton.hidden = YES;
}

//播放结束
- (void)KKVideoPlayer_PlayDidFinished:(KKVideoPlayer*)player{
    [self.toolBarView setButtonStatusStop];
    self.toolBarView.currentTime = 0;
    self.toolBarView.durationtime = 1.0;
    self.toolBarView.mySlider.value = 0;
    
    [self destroyTimer];
    [self setAllBarHidden:NO];
    self.playButton.hidden = NO;
}

//播放暂停
- (void)KKVideoPlayer_PlayDidPause:(KKVideoPlayer*)player{
    [self.toolBarView setButtonStatusStop];
    [self destroyTimer];
    [self setAllBarHidden:NO];
    self.playButton.hidden = NO;
}

//播放错误
- (void)KKVideoPlayer_CanNotPlay:(KKVideoPlayer*)player{
    [self destroyTimer];
    [self setAllBarHidden:NO];
    self.playButton.hidden = NO;
    
    KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:KKLibLocalizable_Common_Notice subTitle:nil message:KKLibLocalizable_Common_FileError delegate:self buttonTitles:KKLibLocalizable_Common_OK,nil];
    [alertView show];
    
    KKButton *button = [alertView buttonAtIndex:0];
    [button setTitleColor:[UIColor kk_colorWithHexString:@"#24C875"]   forState:UIControlStateNormal];
}

//播放时间改变
- (void)KKVideoPlayer:(KKVideoPlayer*)player
  playBackTimeChanged:(NSTimeInterval)currentTime
         durationtime:(NSTimeInterval)durationtime{
    if (self.isGestureON==NO && self.toolBarView.isSliderTouched==NO) {
        self.toolBarView.currentTime = currentTime;
        self.toolBarView.durationtime = durationtime;
        self.toolBarView.mySlider.value = currentTime;
    }
}

- (void)KKAlertView:(KKAlertView*)aAlertView clickedButtonAtIndex:(NSInteger)aButtonIndex{
    [self KKVideoPlayerNavigationView_LeftButtonClicked:nil];
}

#pragma mark ==================================================
#pragma mark == 定时器
#pragma mark ==================================================
- (void)startTimer{
    self.myTimerCount = HiddenPlayerBarTimerMax;
    [self destroyTimer];
    KKWeakSelf(self);
    self.myTimer = [NSTimer kk_scheduledTimerWithTimeInterval:1.0 block:^{
        [weakself timerLoop];
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.myTimer forMode:NSRunLoopCommonModes];
}

- (void)timerLoop{
    if (self.toolBarView.isSliderTouched==NO) {
        self.myTimerCount = self.myTimerCount - 1;
    } else {
        self.myTimerCount = HiddenPlayerBarTimerMax;
    }
    if (self.myTimerCount<=0) {
        [self setAllBarHidden:YES];
    }
}

- (void)destroyTimer{
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
}

- (void)setAllBarHidden:(BOOL)hidden{
    if (self.isBarHidden == hidden) {
        return;
    }
    if (self.player.hidden == YES) {
        return;
    }

    self.isBarHidden = hidden;
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    if (self.isBarHidden) {
        [self setStatusBarHidden:YES statusBarStyle:UIStatusBarStyleLightContent withAnimation:UIStatusBarAnimationFade];
        [UIView animateWithDuration:duration animations:^{
            self.navigationBarView.alpha = 0;
            self.toolBarView.alpha = 0;
            self.volumeView.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.myTimerCount = HiddenPlayerBarTimerMax;
        [self setStatusBarHidden:NO statusBarStyle:UIStatusBarStyleLightContent withAnimation:UIStatusBarAnimationFade];
        
        [UIView animateWithDuration:duration animations:^{
            self.navigationBarView.alpha = 1.0;
            self.toolBarView.alpha = 1.0;
            self.volumeView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }
}


@end

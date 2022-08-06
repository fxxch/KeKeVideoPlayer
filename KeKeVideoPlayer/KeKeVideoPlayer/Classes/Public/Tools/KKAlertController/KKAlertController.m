//
//  KKAlertController.m
//  ChervonIot
//
//  Created by edward lannister on 2022/05/24.
//  Copyright © 2022 ts. All rights reserved.
//

#import "KKAlertController.h"

@interface KKAlertController_VC : UIViewController

@property (nonatomic,assign)UIStatusBarStyle statusBarStyle;

- (instancetype)initWithUIStatusBarStyle:(UIStatusBarStyle)aStyle;

@end

@implementation KKAlertController_VC

- (instancetype)initWithUIStatusBarStyle:(UIStatusBarStyle)aStyle{
    self = [super init];
    if (self) {
        self.statusBarStyle = aStyle;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.userInteractionEnabled = NO;
    self.view.hidden = YES;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return self.statusBarStyle;
}

@end




static UIWindow  *KKAlertController_currentKeyWindow;
static UIWindow  *KKAlertController_currentShowing;

@interface KKAlertController (){

}

@property (nonatomic,strong)UIButton *backgroundBlackButton;
@property (nonatomic,strong)UIView *boxView;
@property (nonatomic,strong)UILabel *myTitleLabel;
@property (nonatomic,strong)UILabel *mySubTitleLabel;

@property (nonatomic,copy)NSString *myTitleString;
@property (nonatomic,copy)NSString *myMessageString;

@property (nonatomic, strong) KKAlertButtonConfig *leftConfig;
@property (nonatomic, strong) KKAlertButtonConfig *rightConfig;

@end

@implementation KKAlertController

- (instancetype)initWithTitle:(NSString *)aTitle
                      message:(NSString *)aMessage
                   leftConfig:(KKAlertButtonConfig*)aLeftConfig
                  rightConfig:(KKAlertButtonConfig*)aRightConfig{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight);
        self.backgroundColor = [UIColor clearColor];
                
        self.leftConfig = aLeftConfig;
        self.rightConfig = aRightConfig;

        self.myTitleString = aTitle;
        self.myMessageString = aMessage;
        
        self.backgroundBlackButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.backgroundBlackButton.backgroundColor = [UIColor blackColor];
        self.backgroundBlackButton.exclusiveTouch = YES;
        [self.backgroundBlackButton addTarget:self action:@selector(backgroundButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backgroundBlackButton];
        
        CGFloat boxViewMinHeight = 180;
        self.boxView = [[UIView alloc] initWithFrame:CGRectMake((self.kk_width-270)/2.0, 0, 270, boxViewMinHeight)];
        self.boxView.backgroundColor = [UIColor whiteColor];
        self.boxView.userInteractionEnabled = YES;
        [self addSubview:self.boxView];
        
        CGFloat offsetY = 0;
        CGFloat buttonHeight = 50;
        if ([NSString kk_isStringNotEmpty:self.myTitleString] && [NSString kk_isStringNotEmpty:self.myMessageString]) {
            offsetY = offsetY + 15;
            self.myTitleLabel = [UILabel kk_initWithTextColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:17] text:self.myTitleString lines:0 maxWidth:self.boxView.kk_width-40];
            self.myTitleLabel.frame = CGRectMake(20, offsetY, self.boxView.kk_width-40, self.myTitleLabel.kk_height);
            [self.myTitleLabel kk_clearBackgroundColor];
            self.myTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.boxView addSubview:self.myTitleLabel];
            offsetY = offsetY + self.myTitleLabel.kk_height;
            
            offsetY = offsetY + 15;
            self.mySubTitleLabel = [UILabel kk_initWithTextColor:[UIColor kk_colorWithHexString:@"#666666"] font:[UIFont systemFontOfSize:14] text:self.myMessageString lines:0 maxWidth:self.boxView.kk_width-40];
            self.mySubTitleLabel.frame = CGRectMake(20, offsetY, self.boxView.kk_width-40, self.mySubTitleLabel.kk_height);
            [self.mySubTitleLabel kk_clearBackgroundColor];
            self.mySubTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.boxView addSubview:self.mySubTitleLabel];
            offsetY = offsetY + self.mySubTitleLabel.kk_height;
            
            offsetY = offsetY + 15;

        }
        else if ([NSString kk_isStringNotEmpty:self.myTitleString] && [NSString kk_isStringEmpty:self.myMessageString]) {
            offsetY = offsetY + 15;
            self.myTitleLabel = [UILabel kk_initWithTextColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:17] text:self.myTitleString lines:0 maxWidth:self.boxView.kk_width-40];
            self.myTitleLabel.frame = CGRectMake(20, offsetY, self.boxView.kk_width-40, self.myTitleLabel.kk_height);
            [self.myTitleLabel kk_clearBackgroundColor];
            self.myTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.boxView addSubview:self.myTitleLabel];
            offsetY = offsetY + self.myTitleLabel.kk_height;
            
            offsetY = offsetY + 15;

            if (offsetY+buttonHeight<boxViewMinHeight) {
                self.myTitleLabel.frame = CGRectMake(20, ((boxViewMinHeight-buttonHeight)-self.myTitleLabel.kk_height)/2.0, self.boxView.kk_width-40, self.myTitleLabel.kk_height);
            }
        }
        else if ([NSString kk_isStringEmpty:self.myTitleString] && [NSString kk_isStringNotEmpty:self.myMessageString]) {
            offsetY = offsetY + 15;
            self.mySubTitleLabel = [UILabel kk_initWithTextColor:[UIColor kk_colorWithHexString:@"#666666"] font:[UIFont systemFontOfSize:14] text:self.myMessageString lines:0 maxWidth:self.boxView.kk_width-40];
            self.mySubTitleLabel.frame = CGRectMake(20, offsetY, self.boxView.kk_width-40, self.mySubTitleLabel.kk_height);
            [self.mySubTitleLabel kk_clearBackgroundColor];
            self.mySubTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.boxView addSubview:self.mySubTitleLabel];
            offsetY = offsetY + self.mySubTitleLabel.kk_height;
            
            offsetY = offsetY + 15;

            if (offsetY+buttonHeight<boxViewMinHeight) {
                self.mySubTitleLabel.frame = CGRectMake(20, ((boxViewMinHeight-buttonHeight)-self.mySubTitleLabel.kk_height)/2.0, self.boxView.kk_width-40, self.mySubTitleLabel.kk_height);
            }
        }
        else{}

        //最小高度180, 弹出框的宽度是270
        CGFloat boxHeight = MAX(offsetY + buttonHeight, boxViewMinHeight);
        self.boxView.frame = CGRectMake((self.kk_width-270)/2.0, (self.kk_height-boxHeight)/2.0-50, 270, boxHeight);
        [self.boxView kk_setCornerRadius:10.0];

        if (self.leftConfig && self.rightConfig) {
            UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.boxView.kk_height-buttonHeight, self.boxView.kk_width/2.0, buttonHeight)];
            leftButton.titleLabel.font = [UIFont systemFontOfSize:18];
            [leftButton setTitle:self.leftConfig.title forState:UIControlStateNormal];
            [leftButton setTitleColor:self.leftConfig.titleColor forState:UIControlStateNormal];
            [leftButton.titleLabel setAdjustsFontSizeToFitWidth:leftButton.kk_width];
            leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [leftButton addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.boxView addSubview:leftButton];
            leftButton.kk_tagInfo = self.leftConfig;
            
            UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(leftButton.kk_right, self.boxView.kk_height-buttonHeight, self.boxView.kk_width/2.0, buttonHeight)];
            rightButton.titleLabel.font = [UIFont systemFontOfSize:18];
            [rightButton setTitle:self.rightConfig.title forState:UIControlStateNormal];
            [rightButton setTitleColor:self.rightConfig.titleColor forState:UIControlStateNormal];
            [rightButton.titleLabel setAdjustsFontSizeToFitWidth:rightButton.kk_width];
            rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.boxView addSubview:rightButton];
            rightButton.kk_tagInfo = self.rightConfig;
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, leftButton.kk_top, self.boxView.kk_width, 0.5)];
            line.backgroundColor = [UIColor kk_colorWithHexString:@"#E5E5E5"];
            [self.boxView addSubview:line];
            UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(leftButton.kk_right-0.25, leftButton.kk_top, 0.5, buttonHeight)];
            line1.backgroundColor = [UIColor kk_colorWithHexString:@"#E5E5E5"];
            [self.boxView addSubview:line1];
        }
        else{
            KKAlertButtonConfig *config = self.leftConfig;
            if (config==nil) {
                config = self.rightConfig;
            }
            if (config==nil) {
                self.leftConfig = [KKAlertButtonConfig okConfig];
                config = self.leftConfig;
            }

            UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.boxView.kk_height-buttonHeight, self.boxView.kk_width, buttonHeight)];
            leftButton.titleLabel.font = [UIFont systemFontOfSize:18];
            [leftButton setTitle:config.title forState:UIControlStateNormal];
            [leftButton setTitleColor:config.titleColor forState:UIControlStateNormal];
            [leftButton.titleLabel setAdjustsFontSizeToFitWidth:leftButton.kk_width];
            leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [leftButton addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.boxView addSubview:leftButton];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, leftButton.kk_top, self.boxView.kk_width, 0.5)];
            line.backgroundColor = [UIColor kk_colorWithHexString:@"#E5E5E5"];
            [self.boxView addSubview:line];
        }
    }
    return self;
}


- (void)show{

    UIStatusBarStyle style = [UIApplication sharedApplication].statusBarStyle;
    self.rootViewController = [[KKAlertController_VC alloc] initWithUIStatusBarStyle:style];

    for (UIWindow *subWindow in [[UIApplication sharedApplication] windows]) {
        [subWindow endEditing:YES];
    }
    
    self.windowLevel = UIWindowLevelAlert;
    if (KKAlertController_currentKeyWindow==nil) {
        KKAlertController_currentKeyWindow = [UIApplication sharedApplication].keyWindow;
    }
    [self makeKeyAndVisible];

    self.backgroundBlackButton.alpha = 0;
    
    self.boxView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    [UIView animateWithDuration:0.25 animations:^{
        self.boxView.transform = CGAffineTransformMakeScale(1, 1);
        self.backgroundBlackButton.alpha = 0.5;
    } completion:^(BOOL finished) {

    }];
}

- (void)hide{
    [UIView animateWithDuration:0.25 animations:^{
        self.boxView.transform = CGAffineTransformScale(self.transform, 1.0, 1.0);
        self.boxView.transform = CGAffineTransformScale(self.transform, 0.001, 0.001);
        self.backgroundBlackButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self resignKeyWindow];
        self.alpha = 0;
        if (KKAlertController_currentKeyWindow) {
            [KKAlertController_currentKeyWindow makeKeyWindow];
        }
        KKAlertController_currentKeyWindow = nil;
        KKAlertController_currentShowing = nil;
    }];
}

+ (void)showWithTitle:(NSString *)aTitle
              message:(NSString *)aMessage
           leftConfig:(KKAlertButtonConfig*)aLeftConfig
          rightConfig:(KKAlertButtonConfig*)aRightConfig{
    KKAlertController *alertView = [[KKAlertController alloc] initWithTitle:aTitle message:aMessage leftConfig:aLeftConfig rightConfig:aRightConfig];
    KKAlertController_currentShowing = alertView;
    [alertView show];
}


#pragma mark ==================================================
#pragma mark == EVENT
#pragma mark ==================================================
- (void)backgroundButtonClicked{

}

- (void)leftButtonClicked:(UIButton*)aButton{
    KKAlertButtonConfig *config = aButton.kk_tagInfo;
    if (config && [config isKindOfClass:[KKAlertButtonConfig class]] && config.actionBlock) {
        config.actionBlock(nil);
    }
    [self hide];
}

- (void)rightButtonClicked:(UIButton*)aButton{
    KKAlertButtonConfig *config = aButton.kk_tagInfo;
    if (config && [config isKindOfClass:[KKAlertButtonConfig class]] && config.actionBlock) {
        config.actionBlock(nil);
    }
    [self hide];
}

@end

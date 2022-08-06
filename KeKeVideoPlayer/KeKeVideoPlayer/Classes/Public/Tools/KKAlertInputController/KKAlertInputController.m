//
//  KKAlertInputController.m
//  ChervonIot
//
//  Created by edward lannister on 2022/05/24.
//  Copyright © 2022 ts. All rights reserved.
//

#import "KKAlertInputController.h"

@interface KKAlertInputController_VC : UIViewController

@property (nonatomic,assign)UIStatusBarStyle statusBarStyle;

- (instancetype)initWithUIStatusBarStyle:(UIStatusBarStyle)aStyle;

@end

@implementation KKAlertInputController_VC

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




static UIWindow  *KKAlertInputController_currentKeyWindow;
static UIWindow  *KKAlertInputController_currentShowing;

@interface KKAlertInputController ()<KKTextFieldDelegate>{

}

@property (nonatomic,strong)UIButton *backgroundBlackButton;
@property (nonatomic,strong)UIView *boxView;
@property (nonatomic,strong)UILabel *myTitleLabel;
@property (nonatomic,strong)UILabel *mySubTitleLabel;
@property (nonatomic,strong)KKTextField *inputTextField;

@property (nonatomic,copy)NSString *myTitleString;
@property (nonatomic,copy)NSString *mysubTitleString;
@property (nonatomic,copy)NSString *myInputPlaceholder;
@property (nonatomic,copy)NSString *myConfirmText;
@property (nonatomic,copy)NSString *myCancelText;
@property (nonatomic,copy)NSString *myInitText;

@property (nonatomic, strong) KKAlertButtonConfig *leftConfig;
@property (nonatomic, strong) KKAlertButtonConfig *rightConfig;

@end

@implementation KKAlertInputController

- (instancetype)initWithTitle:(NSString *)aTitle
                     subTitle:(NSString *)aSubTitle
             inputPlaceholder:(NSString *)aPlaceholder
                     initText:(NSString *)aInitText
                   leftConfig:(KKAlertButtonConfig*_Nullable)aLeftConfig
                  rightConfig:(KKAlertButtonConfig*_Nullable)aRightConfig{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight);
        self.backgroundColor = [UIColor clearColor];
        [self addKeyboardNotification];

        self.leftConfig = aLeftConfig;
        self.rightConfig = aRightConfig;

        self.myTitleString = aTitle;
        self.mysubTitleString = aSubTitle;
        self.myInputPlaceholder = aPlaceholder;
        self.myInitText = aInitText;

        self.backgroundBlackButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.backgroundBlackButton.backgroundColor = [UIColor blackColor];
        self.backgroundBlackButton.exclusiveTouch = YES;
        [self.backgroundBlackButton addTarget:self action:@selector(backgroundButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backgroundBlackButton];
        
        // 弹出框的宽度是270，高度是180
        CGFloat boxViewMinHeight = 180;
        self.boxView = [[UIView alloc] initWithFrame:CGRectMake((self.kk_width-270)/2.0, 0, 270, boxViewMinHeight)];
        self.boxView.backgroundColor = [UIColor whiteColor];
        self.boxView.userInteractionEnabled = YES;
        [self addSubview:self.boxView];
        
        CGFloat offsetY = 0;
        if ([NSString kk_isStringNotEmpty:self.myTitleString] && [NSString kk_isStringNotEmpty:self.mysubTitleString]) {
            offsetY = offsetY + 15;
            self.myTitleLabel = [UILabel kk_initWithTextColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:17] text:self.myTitleString lines:0 maxWidth:self.boxView.kk_width-40];
            self.myTitleLabel.frame = CGRectMake(20, offsetY, self.boxView.kk_width-40, self.myTitleLabel.kk_height);
            [self.myTitleLabel kk_clearBackgroundColor];
            self.myTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.boxView addSubview:self.myTitleLabel];
            offsetY = offsetY + self.myTitleLabel.kk_height;
            
            offsetY = offsetY + 15;
            self.mySubTitleLabel = [UILabel kk_initWithTextColor:[UIColor kk_colorWithHexString:@"#666666"] font:[UIFont systemFontOfSize:14] text:self.mysubTitleString lines:0 maxWidth:self.boxView.kk_width-40];
            self.mySubTitleLabel.frame = CGRectMake(20, offsetY, self.boxView.kk_width-40, self.mySubTitleLabel.kk_height);
            [self.mySubTitleLabel kk_clearBackgroundColor];
            self.mySubTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.boxView addSubview:self.mySubTitleLabel];
            offsetY = offsetY + self.mySubTitleLabel.kk_height;
        }
        else if ([NSString kk_isStringNotEmpty:self.myTitleString] && [NSString kk_isStringEmpty:self.mysubTitleString]) {
            offsetY = offsetY + 15;
            self.myTitleLabel = [UILabel kk_initWithTextColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:17] text:self.myTitleString lines:0 maxWidth:self.boxView.kk_width-40];
            self.myTitleLabel.frame = CGRectMake(20, offsetY, self.boxView.kk_width-40, self.myTitleLabel.kk_height);
            [self.myTitleLabel kk_clearBackgroundColor];
            self.myTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.boxView addSubview:self.myTitleLabel];
            offsetY = offsetY + self.myTitleLabel.kk_height;
        }
        else if ([NSString kk_isStringEmpty:self.myTitleString] && [NSString kk_isStringNotEmpty:self.mysubTitleString]) {
            offsetY = offsetY + 15;
            self.mySubTitleLabel = [UILabel kk_initWithTextColor:[UIColor kk_colorWithHexString:@"#666666"] font:[UIFont systemFontOfSize:14] text:self.mysubTitleString lines:0 maxWidth:self.boxView.kk_width-40];
            self.mySubTitleLabel.frame = CGRectMake(20, offsetY, self.boxView.kk_width-40, self.mySubTitleLabel.kk_height);
            [self.mySubTitleLabel kk_clearBackgroundColor];
            self.mySubTitleLabel.textAlignment = NSTextAlignmentCenter;
            [self.boxView addSubview:self.mySubTitleLabel];
            offsetY = offsetY + self.mySubTitleLabel.kk_height;
        }
        else{}

        //标题与输入框之间的间距15
        offsetY = offsetY + 15;
        //输入框距离弹出框左右边缘15，所以宽度就是弹出框的宽度-30，输入框高度45
        KKTextField *textField = [[KKTextField alloc] initWithFrame:CGRectMake(15, offsetY, self.boxView.kk_width-30, 45)];
        textField.padding = UIEdgeInsetsMake(0, 10, 0, 10);
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        textField.textAlignment = NSTextAlignmentLeft;
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        if (self.myInputPlaceholder) {
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont boldSystemFontOfSize:17],NSFontAttributeName,
                                        [UIColor kk_colorWithHexString:@"#ADADAD"],NSForegroundColorAttributeName,
                                        nil];
            NSMutableAttributedString *placeholderString = [[NSMutableAttributedString alloc] initWithString:self.myInputPlaceholder
                                                                                                  attributes:attributes];
            textField.attributedPlaceholder = placeholderString;
        }
        textField.font = [UIFont boldSystemFontOfSize:17];
        textField.textColor = [UIColor blackColor];
        textField.secureTextEntry = NO;
        [textField kk_setCornerRadius:2.0];
        [textField kk_setBorderColor:[UIColor kk_colorWithHexString:@"#C8C8C8"] width:0.5];

        self.inputTextField = textField;
        self.inputTextField.delegate = self;
        [self.boxView addSubview:self.inputTextField];
        offsetY = offsetY + self.inputTextField.kk_height;
        self.inputTextField.text = self.myInitText;

        //输入框与cancelButton间隙20，按钮高度50
        CGFloat buttonHeight = 50;
        CGFloat boxHeight = MAX(offsetY + 20 + buttonHeight, boxViewMinHeight);
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
    self.rootViewController = [[KKAlertInputController_VC alloc] initWithUIStatusBarStyle:style];

    for (UIWindow *subWindow in [[UIApplication sharedApplication] windows]) {
        [subWindow endEditing:YES];
    }
    
    self.windowLevel = UIWindowLevelAlert;
    if (KKAlertInputController_currentKeyWindow==nil) {
        KKAlertInputController_currentKeyWindow = [UIApplication sharedApplication].keyWindow;
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
        [self removeKeyboardNotification];

        [self resignKeyWindow];
        self.alpha = 0;
        if (KKAlertInputController_currentKeyWindow) {
            [KKAlertInputController_currentKeyWindow makeKeyWindow];
        }
        KKAlertInputController_currentKeyWindow = nil;
        KKAlertInputController_currentShowing = nil;
    }];
}

+ (void)showWithTitle:(NSString *_Nullable)aTitle
             subTitle:(NSString *_Nullable)aSubTitle
     inputPlaceholder:(NSString *_Nullable)aPlaceholder
             initText:(NSString *_Nullable)aInitText
           leftConfig:(KKAlertButtonConfig*_Nullable)aLeftConfig
          rightConfig:(KKAlertButtonConfig*_Nullable)aRightConfig{
    if (KKAlertInputController_currentShowing) {
        return;
    }

    KKAlertInputController *alertView = [[KKAlertInputController alloc] initWithTitle:aTitle
                                                                               subTitle:aSubTitle
                                                                       inputPlaceholder:aPlaceholder
                                                                               initText:aInitText
                                                                             leftConfig:aLeftConfig
                                                                            rightConfig:aRightConfig];
    KKAlertInputController_currentShowing = alertView;
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
        config.actionBlock(self.inputTextField.text);
    }
    [self hide];
}

- (void)rightButtonClicked:(UIButton*)aButton{
    KKAlertButtonConfig *config = aButton.kk_tagInfo;
    if (config && [config isKindOfClass:[KKAlertButtonConfig class]] && config.actionBlock) {
        config.actionBlock(self.inputTextField.text);
    }
    [self hide];
}


#pragma mark ****************************************
#pragma mark Keyboard
#pragma mark ****************************************
- (void)addKeyboardNotification{
    
    [self removeKeyboardNotification];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(kk_UIKeyboardWillShowNotification:)
                          name:UIKeyboardWillShowNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(kk_UIKeyboardWillHideNotification:)
                          name:UIKeyboardWillHideNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(kk_UIKeyboardWillChangeFrameNotification:)
                          name:UIKeyboardWillChangeFrameNotification
                        object:nil];
}

- (void)removeKeyboardNotification{
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    //监听键盘高度的变换
    [defaultCenter removeObserver:self
                             name:UIKeyboardWillShowNotification object:nil];
    
    [defaultCenter removeObserver:self
                             name:UIKeyboardWillHideNotification object:nil];
    
    [defaultCenter removeObserver:self
                             name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)kk_UIKeyboardWillShowNotification:(NSNotification*)aNotice{
    [self keyboardWillShow:aNotice];
}

- (void)kk_UIKeyboardWillChangeFrameNotification:(NSNotification*)aNotice{
    [self keyboardWillShow:aNotice];
}

- (void)kk_UIKeyboardWillHideNotification:(NSNotification*)aNotice{
    [self keyboardWillHide:aNotice];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    //    keyboradAnimationDuration = animationDuration;//键盘两种高度 216  252
    
    [self keyboardWillShowWithAnimationDuration:animationDuration keyBoardRect:keyboardRect];
}

- (void)keyboardWillShowWithAnimationDuration:(NSTimeInterval)animationDuration keyBoardRect:(CGRect)keyBoardRect{
    
    CGFloat offsetY = self.boxView.frame.origin.y;
    
    if (keyBoardRect.size.height>1) {
        CGFloat newOffsetY = KKScreenHeight-keyBoardRect.size.height-self.boxView.frame.size.height-15;
        [self.boxView kk_setTop:MIN(offsetY, newOffsetY)];
    }
    else{
        [self.boxView kk_setTop:(self.kk_height-self.boxView.kk_height)/2.0-50];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self keyboardWillHideWithAnimationDuration:animationDuration keyBoardRect:keyboardRect];
}

- (void)keyboardWillHideWithAnimationDuration:(NSTimeInterval)animationDuration keyBoardRect:(CGRect)keyBoardRect{
    [self.boxView kk_setTop:(self.kk_height-self.boxView.kk_height)/2.0-50];
}

@end

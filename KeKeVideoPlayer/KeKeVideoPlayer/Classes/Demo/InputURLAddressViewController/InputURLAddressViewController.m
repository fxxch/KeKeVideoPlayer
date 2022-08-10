//
//  InputURLAddressViewController.m
//  CEDongLi
//
//  Created by beartech on 16/9/1.
//  Copyright © 2016年 KeKeStudio. All rights reserved.
//

#import "InputURLAddressViewController.h"
#import "WebBrowserViewController.h"
#import "KKWaitingView.h"
#import "KKGetIPAddress.h"

@interface InputURLAddressViewController ()<UITextViewDelegate>

@property (nonatomic,strong)UIView *backView;
@property (nonatomic,strong)KKTextView *myTextView;

@property (nonatomic,strong)NSMutableArray *ipArray;
@property (nonatomic,assign) NSInteger ipIndex;
@property (nonatomic,assign)BOOL initAuto;

@end

@implementation InputURLAddressViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithAuto:(BOOL)needAuto{
    self = [super init];
    if (self) {
        self.initAuto = needAuto;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"输入地址";
    [self showNavigationDefaultBackButton_ForNavPopBack];
    [self setNavRightButtonTitle:@"确定" selector:@selector(finishedEdit)];
    self.ipArray = [[NSMutableArray alloc] init];
    self.ipIndex = -1;
    
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, KKApplicationWidth+20, 122)];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.backView kk_setBorderColor:[UIColor kk_colorWithR:216/255.0f G:216/255.0f B:216/255.0f alpha:1.0] width:0.5];
    [self.view addSubview:self.backView];

    [self kk_observeNotification:UITextViewTextDidChangeNotification selector:@selector(UITextViewTextDidChangeNotification:)];

    self.myTextView = [[KKTextView alloc]initWithFrame:CGRectMake(10, 10, KKApplicationWidth-20, 110)];
    self.myTextView.delegate = self;
    [self.myTextView kk_clearBackgroundColor];
    self.myTextView.editable = YES;
    self.myTextView.selectable = YES;
    self.myTextView.returnKeyType = UIReturnKeyDone;
    self.myTextView.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.myTextView.font = [UIFont systemFontOfSize:16];
    [self.myTextView setContentInset:UIEdgeInsetsMake(-3, 5, -3, -10)];//设置UITextView的内边距
    [self.view addSubview:self.myTextView];
        
    UIButton *button01 = [[UIButton alloc] initWithFrame:CGRectMake(30, KKApplicationHeight-44-30-40-15-40-15-40-15-40, KKApplicationWidth-60, 40)];
    [button01 setTitle:@"http://192.168.0.100" forState:UIControlStateNormal];
    button01.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [button01 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button01 kk_setBorderColor:[UIColor greenColor] width:1.0];
    [button01 kk_setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button01 addTarget:self action:@selector(showAddress104) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button01];

    UIButton *button02 = [[UIButton alloc] initWithFrame:CGRectMake(30, KKApplicationHeight-44-30-40-15-40-15-40, KKApplicationWidth-60, 40)];
    [button02 setTitle:@"http://192.168.43.250" forState:UIControlStateNormal];
    button02.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [button02 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button02 kk_setBorderColor:[UIColor greenColor] width:1.0];
    [button02 kk_setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button02 addTarget:self action:@selector(showAddress108) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button02];

    UIButton *button03 = [[UIButton alloc] initWithFrame:CGRectMake(30, KKApplicationHeight-44-30-40-15-40, KKApplicationWidth-60, 40)];
    [button03 setTitle:@"+++" forState:UIControlStateNormal];
    button03.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [button03 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button03 kk_setBackgroundColor:[UIColor redColor] forState:UIControlStateNormal];
    [button03 addTarget:self action:@selector(addressPlus) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button03];

    UIButton *button04 = [[UIButton alloc] initWithFrame:CGRectMake(30, KKApplicationHeight-44-30-40, KKApplicationWidth-60, 40)];
    [button04 setTitle:@"---" forState:UIControlStateNormal];
    button04.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [button04 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button04 kk_setBackgroundColor:[UIColor greenColor] forState:UIControlStateNormal];
    [button04 addTarget:self action:@selector(addressReduce) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button04];

    if (self.initAuto) {
        NSString *wifiIPAddress = [KKGetIPAddress getCurrentWifiIP];
        if ([NSString kk_isStringNotEmpty:wifiIPAddress]) {
            NSArray *array = [wifiIPAddress componentsSeparatedByString:@"."];
            if ([array count]>=4) {
                NSString *str01 = [array objectAtIndex:0];
                NSString *str02 = [array objectAtIndex:1];
                NSString *str03 = [array objectAtIndex:2];
              //NSString *str04 = [array objectAtIndex:3];
                for (NSInteger index=2; index<=300; index++) {
                    NSString *fullString = [NSString stringWithFormat:@"%@.%@.%@.%ld",str01,str02,str03,(long)(index)];
                    [self.ipArray addObject:fullString];
                }
                
                [self autoSearchIP_Start];
            }
        }
        else{
            [KKToastView showInView:self.view text:@"请连接wifi" image:nil alignment:KKToastViewAlignment_Center];
        }
    }
    else{
        self.myTextView.text = @"http://192.168.43.250";
//        [self.myTextView becomeFirstResponder];
    }
}

- (void)finishedEdit{
    NSString *url = self.myTextView.text;
//    if ([NSString isStringNotEmpty:url] && [url isURL]) {
    if ([NSString kk_isStringNotEmpty:url]) {
        WebBrowserViewController * viewController = [[WebBrowserViewController alloc] initWithURL:[NSURL URLWithString:self.myTextView.text] navigationBarTitle:@"查看"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addKeyboardNotification];
    [self setStatusBarHidden:NO statusBarStyle:UIStatusBarStyleLightContent withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeKeyboardNotification];
}

- (void)showAddress104{
    self.myTextView.text = @"http://192.168.0.100";
}

- (void)showAddress108{
    self.myTextView.text = @"http://192.168.43.250";
}

- (void)addressPlus{
    NSString *originString = self.myTextView.text;
    NSString *string01 = [originString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    NSString *string02 = [string01 stringByReplacingOccurrencesOfString:@"/media0" withString:@""];
    NSArray *array = [string02 componentsSeparatedByString:@"."];
    if ([array count]>=4) {
        NSString *str01 = [array objectAtIndex:0];
        NSString *str02 = [array objectAtIndex:1];
        NSString *str03 = [array objectAtIndex:2];
        NSString *str04 = [array objectAtIndex:3];
        NSString *fullString = [NSString stringWithFormat:@"http://%@.%@.%@.%ld",str01,str02,str03,(long)([str04 integerValue]+1)];
        self.myTextView.text = fullString;
    }
}

- (void)addressReduce{
    NSString *originString = self.myTextView.text;
    NSString *string01 = [originString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    NSString *string02 = [string01 stringByReplacingOccurrencesOfString:@"/media0" withString:@""];
    NSArray *array = [string02 componentsSeparatedByString:@"."];
    if ([array count]>=4) {
        NSString *str01 = [array objectAtIndex:0];
        NSString *str02 = [array objectAtIndex:1];
        NSString *str03 = [array objectAtIndex:2];
        NSString *str04 = [array objectAtIndex:3];
        NSString *fullString = [NSString stringWithFormat:@"http://%@.%@.%@.%ld",str01,str02,str03,(long)([str04 integerValue]-1)];
        self.myTextView.text = fullString;
    }
}

#pragma mark ==================================================
#pragma mark == 自动检索IP地址
#pragma mark ==================================================
- (void)autoSearchIP_Start{
    [KKWaitingView showInView:self.view withType:KKWaitingViewType_Gray blackBackground:YES text:@"🔍自动搜索中"];
    self.ipIndex = 0;
    for (NSInteger i=0; i<[self.ipArray count]; i++) {
        NSString *ipString = [self.ipArray objectAtIndex:i];
        [self autoSearchIP_Process:ipString];
    }
}

- (void)autoSearchIP_Process:(NSString*)aIp{
    NSString *ipAddress = aIp;
    if (ipAddress==nil) {
        return;
    }
    if ([NSString kk_isStringNotEmpty:self.myTextView.text]) {
        return;
    }
    
    NSString *ulr = [NSString stringWithFormat:@"http://%@",ipAddress];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ulr]];
    [request setHTTPMethod:@"HEAD"];
    request.timeoutInterval = 2.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    KKWeakSelf(self);
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"error %@",error);
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSString *wifiIP = [request.URL absoluteString];
                NSLog(@"%@: 不可用",wifiIP);
                weakself.ipIndex = weakself.ipIndex+1;
                if (weakself.ipIndex==[weakself.ipArray count]) {
                    [KKWaitingView hideForView:weakself.view];
                }
            });
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                weakself.ipIndex = weakself.ipIndex+1;
                [KKWaitingView hideForView:weakself.view];
                NSString *wifiIP = [request.URL absoluteString];
                NSLog(@"%@: 可用",wifiIP);
                weakself.myTextView.text = wifiIP;
            });
        }
    }];
    [task resume];
}

#pragma mark ****************************************
#pragma mark Keyboard 监听
#pragma mark ****************************************
- (void)addKeyboardNotification{
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 键盘高度变化通知，ios5.0新增的
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)removeKeyboardNotification{
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    // 键盘高度变化通知，ios5.0新增的
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
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
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        CGFloat maxHeight = KKScreenHeight-KKStatusBarAndNavBarHeight-keyboardRect.size.height - 20;
        self.backView.frame = CGRectMake(-10, 0, KKApplicationWidth+20, maxHeight);
        self.myTextView.frame = CGRectMake(10, self.backView.frame.origin.y+10, KKApplicationWidth-20, self.backView.frame.size.height-10-2);
        
    } completion:^(BOOL finished) {
        
        
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.backView.frame = CGRectMake(-10, 0, KKApplicationWidth+20, 122);
        self.myTextView.frame = CGRectMake(10, self.backView.frame.origin.y+10, KKApplicationWidth-20, self.backView.frame.size.height-10);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark ****************************************
#pragma mark 【UITextViewDelegate】
#pragma mark ****************************************
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    else{
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    
}

- (void)UITextViewTextDidChangeNotification:(NSNotification*)notice{

}

#pragma mark ****************************************
#pragma mark 屏幕方向
#pragma mark ****************************************
//1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate {
    return NO;
}

//2.返回支持的旋转方向（当前viewcontroller支持哪些转屏方向）
//iPad设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
//iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

//3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end

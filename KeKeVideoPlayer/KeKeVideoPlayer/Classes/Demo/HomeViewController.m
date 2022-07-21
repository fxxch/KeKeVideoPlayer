//
//  HomeViewController.m
//  Demo
//
//  Created by liubo on 2021/4/27.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "HomeViewController.h"
#import "DemoLocalFilesListViewController.h"
#import "InputURLAddressViewController.h"
#import "FileDownloadListViewController.h"
#import "FileDownloadManager.h"
#import "KKToastView.h"

@interface HomeViewController ()

@property (nonatomic , strong) UIButton *autoButton;
@property (nonatomic , strong) UIButton *manualButton;
@property (nonatomic , strong) UIButton *downloadListButton;
@property (nonatomic , strong) UIButton *downloadButton;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //左导航
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"" forState:UIControlStateNormal];
    [button setTitle:@"" forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.exclusiveTouch = YES;//关闭多点
    
    UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizer:)];
    doubleRecognizer.numberOfTapsRequired = 5;// 双击
    //关键语句，给self.view添加一个手势监测；
    [button addGestureRecognizer:doubleRecognizer];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSeperator.width = -15;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSeperator,leftItem, nil];
    
    CGRect frame1 = CGRectMake(50, 50, KKScreenWidth-100, 80);
    UIColor *backgroundColor1 = [UIColor systemGreenColor];
    self.autoButton = [UIButton kk_initWithFrame:frame1
                                                title:@"自动搜索"
                                            titleFont:[UIFont boldSystemFontOfSize:18]
                                           titleColor:[UIColor whiteColor]
                                      backgroundColor:backgroundColor1];
    [self.autoButton kk_setCornerRadius:10];
    [self.autoButton addTarget:self action:@selector(autoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.autoButton];

    CGRect frame2 = CGRectMake(50, 180, KKScreenWidth-100, 80);
    UIColor *backgroundColor2 = [UIColor systemTealColor];
    self.manualButton = [UIButton kk_initWithFrame:frame2
                                                  title:@"手动配置"
                                              titleFont:[UIFont boldSystemFontOfSize:18]
                                             titleColor:[UIColor whiteColor]
                                        backgroundColor:backgroundColor2];
    [self.manualButton kk_setCornerRadius:10];
    [self.manualButton addTarget:self action:@selector(manualButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.manualButton];

    CGRect frame3 = CGRectMake(50, 310, KKScreenWidth-100, 80);
    UIColor *backgroundColor3 = [UIColor systemPinkColor];
    self.downloadListButton = [UIButton kk_initWithFrame:frame3
                                             title:@"下载列表"
                                         titleFont:[UIFont boldSystemFontOfSize:18]
                                        titleColor:[UIColor whiteColor]
                                   backgroundColor:backgroundColor3];
    [self.downloadListButton kk_setCornerRadius:10];
    [self.downloadListButton addTarget:self action:@selector(downloadListButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadListButton];

    CGRect frame4 = CGRectMake(50, 440, KKScreenWidth-100, 80);
    UIColor *backgroundColor4 = [UIColor systemBlueColor];
    self.downloadButton = [UIButton kk_initWithFrame:frame4
                                                   title:@"下载"
                                               titleFont:[UIFont boldSystemFontOfSize:18]
                                              titleColor:[UIColor whiteColor]
                                         backgroundColor:backgroundColor4];
    [self.downloadButton kk_setCornerRadius:10];
    [self.downloadButton addTarget:self action:@selector(downloadButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
}

- (void)doubleTapGestureRecognizer:(UITapGestureRecognizer*)recognizer{
    DemoLocalFilesListViewController * viewController = [[DemoLocalFilesListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)autoButtonClicked{
    InputURLAddressViewController *viewController = [[InputURLAddressViewController alloc] initWithAuto:YES];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)manualButtonClicked{
    InputURLAddressViewController *viewController = [[InputURLAddressViewController alloc] initWithAuto:NO];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)downloadListButtonClicked{
    [self.navigationController kk_pushViewController:@"FileDownloadListViewController" withParms:nil];
}

- (void)downloadButtonClicked{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *fileURL = pasteboard.string;
    if ([NSString kk_isStringEmpty:fileURL]) {
        [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"未在剪贴板识别到下载链接" image:nil alignment:KKToastViewAlignment_Center];
        return;
    }
    [[FileDownloadManager defaultManager] downloadFileWithURL:[fileURL kk_KKURLDecodedString]];
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

//
//  BaseViewController.m
//  StreetDancing
//
//  Created by beartech on 15/4/14.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import "BaseViewController.h"
#import "KKThemeManager.h"

@implementation BaseViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

/* 子类可重写该方法，不重写的话默认是白色 */
- (UIColor*)kk_DefaultNavigationBarBackgroundColor{
    return [UIColor blackColor];
}

- (KKButton*)showNavigationDefaultBackButton_ForNavPopBack{
    UIImage *image = KKThemeImage(@"btn_NavBack");
    UIImage *nImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    KKButton *leftButton = [self setNavLeftButtonImage:nImage highlightImage:nil selector:@selector(navigationControllerPopBack)];
    leftButton.imageView.tintColor = [UIColor whiteColor];
    return leftButton;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setStatusBarHidden:NO statusBarStyle:UIStatusBarStyleLightContent withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

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



//
//  MusicSettingViewController.m
//  Music
//
//  Created by edward lannister on 2022/08/12.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicSettingViewController.h"

@interface MusicSettingViewController ()

@property (nonatomic , strong) MusicNavigationBarView *navBarView;

@end

@implementation MusicSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI{
    self.navBarView = [[MusicNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKStatusBarAndNavBarHeight)];
    [self.view addSubview:self.navBarView];
    [self.navBarView setTitle:@"关于"];
//    [self.navBarView setNavLeftButtonImage:KKThemeImage(@"Music_btn_NavPlus") selector:@selector(navAddTagButtonClicked) target:self];
    [self.navBarView setNavRightButtonImage:KKThemeImage(@"Music_btn_pop_cha") selector:@selector(navChaButtonClicked) target:self];

    //当前版本
    NSString *version = [NSString stringWithFormat:@"Version  %@",[NSBundle kk_bundleVersion]];
    UILabel *versionLabel = [UILabel kk_initWithTextColor:Theme_Color_939393 font:[UIFont boldSystemFontOfSize:17] text:version lines:0 maxWidth:KKScreenWidth];
    versionLabel.frame = CGRectMake(15, self.navBarView.kk_bottom+30, KKScreenWidth-30, versionLabel.kk_height);
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionLabel];
    
    NSString *versionBuild = [NSString stringWithFormat:@"build  %@",[NSBundle kk_bundleBuildVersion]];
    UILabel *versionBuildLabel = [UILabel kk_initWithTextColor:Theme_Color_C6C6C6 font:[UIFont systemFontOfSize:12] text:versionBuild lines:0 maxWidth:KKScreenWidth];
    versionBuildLabel.frame = CGRectMake(15, versionLabel.kk_bottom+10, KKScreenWidth-30, versionLabel.kk_height);
    versionBuildLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionBuildLabel];

    //开发者
    NSString *developer = [NSString stringWithFormat:@"👤  %@",@"拂晓新晨"];
    UILabel *developerLabel = [UILabel kk_initWithTextColor:Theme_Color_939393 font:[UIFont systemFontOfSize:17] text:developer lines:0 maxWidth:KKScreenWidth];
    developerLabel.frame = CGRectMake(15, versionBuildLabel.kk_bottom+50, KKScreenWidth-30, versionLabel.kk_height);
    developerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:developerLabel];

    //Email
    NSString *email = [NSString stringWithFormat:@"%@",@"349230334@qq.com"];
    UILabel *emailLabel = [UILabel kk_initWithTextColor:Theme_Color_C6C6C6 font:[UIFont systemFontOfSize:14] text:email lines:0 maxWidth:KKScreenWidth];
    emailLabel.frame = CGRectMake(15, developerLabel.kk_bottom+10, KKScreenWidth-30, versionLabel.kk_height);
    emailLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:emailLabel];

}

- (void)navChaButtonClicked{
    [self viewControllerDismiss];
}

@end

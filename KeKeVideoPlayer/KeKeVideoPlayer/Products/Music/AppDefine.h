//
//  AppDefine.h
//  CEDongLi
//
//  Created by beartech on 15/11/5.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#ifndef CEDongLi_AppDefine_h
#define CEDongLi_AppDefine_h

#import "Tool.h"
#import "MusicDBManager.h"
#import "KKVideoPlayViewController.h"
#import "KKFileDownloadManager.h"
#import "MusicNavigationBarView.h"
#import "HomeMusicPlayerView.h"

//默认主题包
#define DefaultThemeBundleName    @"Default"

//============================================================
//==  通知
//============================================================
#define NotificationName_HomeSelectPlayerView          @"NotificationName_HomeSelectPlayerView"
#define NotificationName_MusicDeleteFinished           @"NotificationName_MusicDeleteFinished"
#define NotificationName_MusicPlayerStartPlayDataSouce @"NotificationName_MusicPlayerStartPlayDataSouce"
#define NotificationName_UIEventSubtypeRemoteControl   @"NotificationName_UIEventSubtypeRemoteControl"
#define NotificationName_MusicPlayerStartPlayMusicItem @"NotificationName_MusicPlayerStartPlayMusicItem"

#pragma mark - ==================================================
#pragma mark == 颜色
#pragma mark ====================================================
//黑色——>灰色——>白色
#define Theme_Color_111111 [UIColor kk_colorWithHexString:@"#111111"]
#define Theme_Color_333333 [UIColor kk_colorWithHexString:@"#333333"]
#define Theme_Color_666666 [UIColor kk_colorWithHexString:@"#666666"]
#define Theme_Color_999999 [UIColor kk_colorWithHexString:@"#999999"]//border
#define Theme_Color_F0F0F0 [UIColor kk_colorWithHexString:@"#F0F0F0"]
#define Theme_Color_F8F8F8 [UIColor kk_colorWithHexString:@"#F8F8F8"]
#define Theme_Color_FFFFFF [UIColor kk_colorWithHexString:@"#FFFFFF"]
#define Theme_Color_F5F5F5 [UIColor kk_colorWithHexString:@"#F5F5F5"] //v3
#define Theme_Color_F1F1F1 [UIColor kk_colorWithHexString:@"#F1F1F1"] //v3

#define Theme_Color_E1AE68 [UIColor kk_colorWithHexString:@"#E1AE68"] //v3
#define Theme_Color_FFD26E [UIColor kk_colorWithHexString:@"#FFD26E"] //v3

//红
#define Theme_Color_D31925 [UIColor kk_colorWithHexString:@"#D31925"] //v3
#define Theme_Color_E5E5E5 [UIColor kk_colorWithHexString:@"#E5E5E5"] //v3
#define Theme_Color_FFE8E3 [UIColor kk_colorWithHexString:@"#FFE8E3"] //v3
#define Theme_Color_FFE8A3 [UIColor kk_colorWithHexString:@"#FFE8A3"] //v3
#define Theme_Color_FFF2F3 [UIColor kk_colorWithHexString:@"#FFF2F3"] //v3
#define Theme_Color_02B94D [UIColor kk_colorWithHexString:@"#02B94D"] //v3
#define Theme_Color_008D3A [UIColor kk_colorWithHexString:@"#008D3A"] //v3

//蓝
#define Theme_Color_3B6AE7 [UIColor kk_colorWithHexString:@"#3B6AE7"]
#define Theme_Color_4A90E2 [UIColor kk_colorWithHexString:@"#4A90E2"]
//卡其色
#define Theme_Color_DEC38B [UIColor kk_colorWithHexString:@"#DEC38B"]
#define Theme_Color_C09C60 [UIColor kk_colorWithHexString:@"#C09C60"]
#define Theme_Color_C4A266 [UIColor kk_colorWithHexString:@"#C4A266"]
#define Theme_Color_D8BE98 [UIColor kk_colorWithHexString:@"#D8BE98"]
#define Theme_Color_FFFAED [UIColor kk_colorWithHexString:@"#FFFAED"]//V3
#define Theme_Color_E99100 [UIColor kk_colorWithHexString:@"#E99100"]//V3


//深灰
#define Theme_Color_939393 [UIColor kk_colorWithHexString:@"#939393"]
#define Theme_Color_C4C4C4 [UIColor kk_colorWithHexString:@"#C4C4C4"]
#define Theme_Color_C6C6C6 [UIColor kk_colorWithHexString:@"#C6C6C6"]//V3

#define Theme_Color_C9C9C9 [UIColor kk_colorWithHexString:@"#C9C9C9"]//V3
#define Theme_Color_F9F9F9 [UIColor kk_colorWithHexString:@"#F9F9F9"]//V3


//浅灰
#define Theme_Color_D3D3D3 [UIColor kk_colorWithHexString:@"#D3D3D3"]
#define Theme_Color_CCCCCC [UIColor kk_colorWithHexString:@"#CCCCCC"]
//淡灰
#define Theme_Color_DEDEDE [UIColor kk_colorWithHexString:@"#DEDEDE"]//line
#define Theme_Color_EDEDED [UIColor kk_colorWithHexString:@"#EDEDED"]//line
#define Theme_Color_FCFCFC [UIColor kk_colorWithHexString:@"#FCFCFC"]
#define Theme_Color_E7E7E7 [UIColor kk_colorWithHexString:@"#E7E7E7"]
#define Theme_Color_FEF4F7 [UIColor kk_colorWithHexString:@"#FEF4F7"]

//橘黄
#define Theme_Color_FF7C03 [UIColor kk_colorWithHexString:@"#FF7C03"]
#define Theme_Color_FFF9E5 [UIColor kk_colorWithHexString:@"#FFF9E5"]

#endif

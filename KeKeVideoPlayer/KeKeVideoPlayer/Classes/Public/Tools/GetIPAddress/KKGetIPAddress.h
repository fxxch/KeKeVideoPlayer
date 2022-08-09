//
//  KKGetIPAddress.h
//  TCWeiBoSDKDemo
//
//  Created by wang ying on 12-8-19.
//  Copyright (c) 2012年 bysft. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "KKIPAddress.h"


@interface KKGetIPAddress : NSObject

+ (NSString *_Nonnull)deviceIPAdress;

+ (NSArray *_Nonnull)allIPAdress;

+ (nullable NSString*)getCurrentWifiIP;

/* 包含信息：
 {
 BSSID = "ac:29:3a:99:33:45";
 SSID = "三千";
 SSIDDATA = <e4b889e5 8d83>;
 }
 */
+ (nullable NSDictionary *)getCurreWiFiInformation;

@end

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

#pragma mark ==================================================
#pragma mark == 老办法
#pragma mark ==================================================
+ (NSString *_Nonnull)deviceIPAdress;

+ (NSArray *_Nonnull)allIPAdress;

#pragma mark ==================================================
#pragma mark == 新方法
#pragma mark ==================================================
+ (nullable NSString*)getCurrentWifiIP;

/*
    #define IOS_WIFI        @"en0"
    #define IOS_BRIDGE      @"bridge100" //桥接、热点ip：比如Mac将有线网通过WiFi共享热点
    #define IOS_Local       @"lo0" //本地IP
    #define IOS_CELLULAR    @"pdp_ip0"
    //有些分配的地址为en0 有些分配的en1
    #define IOS_WIFI2       @"en2"
    #define IOS_WIFI1       @"en1"
    //#define IOS_VPN       @"utun0"  //vpn很少用到可以注释
    #define IP_ADDR_IPv4    @"ipv4"
    #define IP_ADDR_IPv6    @"ipv6"
 */
+ (nullable NSDictionary*)getAllIPAddress;

/* 包含信息：
 {
 BSSID = "ac:29:3a:99:33:45";
 SSID = "三千";
 SSIDDATA = <e4b889e5 8d83>;
 }
 */
+ (nullable NSDictionary *)getCurreWiFiInformation;

@end

//
//  KKGetIPAddress.m
//  TCWeiBoSDKDemo
//
//  Created by wang ying on 12-8-19.
//  Copyright (c) 2012年 bysft. All rights reserved.
//

#include "KKGetIPAddress.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation KKGetIPAddress

+ (NSString *)deviceIPAdress{
    KK_InitAddresses();
    KK_GetIPAddresses();
    KK_GetHWAddresses();
    return [NSString stringWithFormat:@"%s", KK_ip_names[1]];
}

+ (NSArray *)allIPAdress{
    KK_InitAddresses();
    KK_GetIPAddresses();
    KK_GetHWAddresses();
    
    NSMutableArray *returnArray = [NSMutableArray array];
    for (int i=0; i<MAXADDRS; ++i)  {
        if (KK_ip_names[i]) {
            [returnArray addObject:[NSString stringWithFormat:@"%s", KK_ip_names[i]]];
        }
        else{
            break;
        }
    }
    return returnArray;
}

+ (nullable NSString*)getCurrentWifiIP{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSString *ipName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                NSLog(@"%@: %@",ipName,ipAddress);
                if([ipName isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = ipAddress;
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (nullable NSDictionary*)getAllIPAddress{
    
    NSMutableDictionary *allIPs = [NSMutableDictionary dictionary];
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSString *ipName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                NSLog(@"%@: %@",ipName,ipAddress);
                if ([NSString kk_isStringNotEmpty:ipName] &&
                    [NSString kk_isStringNotEmpty:ipAddress] ) {
                    [allIPs setObject:ipAddress forKey:ipName];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return allIPs;
}

+ (nullable NSDictionary *)getCurreWiFiInformation{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSDictionary *info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        /* info包含信息：
         {
         BSSID = "ac:29:3a:99:33:45";
         SSID = "三千";
         SSIDDATA = <e4b889e5 8d83>;
         }
         */
        //NSLog(@"SSID:%@  BSSID:%@",SSID,BSSID);
        if (info && [info count]) {
            break;
        }
    }
    return info;
}


@end








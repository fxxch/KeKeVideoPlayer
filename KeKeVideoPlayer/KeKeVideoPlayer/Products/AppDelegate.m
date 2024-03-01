//
//  AppDelegate.m
//  KKLibrary_Demo
//
//  Created by beartech on 14-10-20.
//  Copyright (c) 2014年 KeKeStudio. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "BaseNavigationController.h"
#if KK_SUPORT_APNS
#import <UserNotifications/UserNotifications.h>
#endif

/**
 *  RemoteNotificationProcessType
 */
typedef NS_ENUM(NSInteger,RemoteNotificationProcessType) {
    
    RemoteNotificationFrom_AppLaunch = 0,
    
    RemoteNotificationFrom_NotificationCenterAction = 1,
    
    RemoteNotificationFrom_AppInForeground = 2,
    
    RemoteNotificationFrom_AppInBackground = 3
};
#pragma mark ==================================================
#pragma mark == CONST KEY
#pragma mark ==================================================
#define KKUserDefaultsManagerKey_DeviceTokenAPNS @"DeviceToken_APNS"
#define KKUserDefaultsManagerKey_DeviceTokenVOIP @"DeviceToken_VOIP"

@interface AppDelegate ()
#if KK_SUPORT_APNS
<UNUserNotificationCenterDelegate>
#endif

@end

@implementation AppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];

    [self reloadRootViewController];

#if KK_SUPORT_APNS
    [self registerAppleNotification:^(BOOL granted) {
        
    }];
#endif
    
    [UIApplication.sharedApplication setApplicationIconBadgeNumber:0];
    
    return YES;
}

- (void)reloadRootViewController{
    HomeViewController * viewController = [[HomeViewController alloc] init];
    BaseNavigationController* nav = [[BaseNavigationController alloc] initWithRootViewController:viewController];
    window.rootViewController = nav;
    [window makeKeyAndVisible];
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (event.type==UIEventTypeRemoteControl) {
        [self kk_postNotification:NotificationName_UIEventSubtypeRemoteControl object:[NSNumber numberWithInteger:event.subtype]];
    }
}

- (BOOL)isCurrentPlayListContainInformation:(NSDictionary*)aDic{
    if ([self.window.rootViewController isKindOfClass:[BaseNavigationController class]]) {
        BaseNavigationController *nav = (BaseNavigationController*)self.window.rootViewController;
        UIViewController *viewController = [[nav viewControllers] firstObject];
        if (viewController && [viewController isKindOfClass:[HomeViewController class]]) {
            HomeViewController *home = (HomeViewController*)viewController;
            return [home isCurrentPlayListContainInformation:aDic];
        } else {
            return NO;
        }
    }
    else{
        return NO;
    }
}

#if KK_SUPORT_APNS
#pragma mark ==================================================
#pragma mark === APNS
#pragma mark ==================================================
- (void)registerAppleNotification:(void(^)(BOOL granted))completionHandler{
    // 同時タップ禁止
    [[UIView appearance]  setExclusiveTouch:YES];

    // 通知許可確認
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center setDelegate:self];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge |
                                             UNAuthorizationOptionSound |
                                             UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            KKLogErrorFormat(@"%@", error.localizedDescription);
        }
        // マイク許可確認
        if (completionHandler) {
            completionHandler(granted);
        }
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark ==================================================
#pragma mark === APNS【DeviceToken】
#pragma mark ==================================================
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString* token = nil;
    if (@available(iOS 13.0, *)) {
        NSMutableString *deviceTokenString = [NSMutableString string];
        const char *bytes = deviceToken.bytes;
        NSInteger iCount = deviceToken.length;
        for (NSInteger i = 0; i < iCount; i++) {
            [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
        }
        token = deviceTokenString;
    }
    else{
        token = [NSString stringWithFormat:@"%@", deviceToken];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    }

    KKLogDebugFormat(@"apns deviceToken: %@",token);
    if ([NSString kk_isStringNotEmpty:token]) {
        [KKUserDefaultsManager setObject:token forKey:KKUserDefaultsManagerKey_DeviceTokenAPNS identifier:nil];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    KKLogErrorFormat(@"deviceToken error: %@",error.localizedDescription);
}

#pragma mark ==================================================
#pragma mark === APNS【Received】
#pragma mark ==================================================
/* app not in background  */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler __API_AVAILABLE(macos(10.14), ios(10.0), watchos(3.0), tvos(10.0)){
    NSString *message = [NSString stringWithFormat:@"💖userNotificationCenter_willPresentNotification_withCompletionHandler:%@",notification.request.content.userInfo];
    [self debugAPNSMessage:message];

    [self ts_processRemoteNotification_WithUserInfo:notification.request.content.userInfo
                                           fromType:RemoteNotificationFrom_AppInForeground
                                     fromUserAction:nil
                              withCompletionHandler:completionHandler];
}

/* app in background, user touched message in message center */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler __API_AVAILABLE(macos(10.14), ios(10.0), watchos(3.0)) __API_UNAVAILABLE(tvos){
    NSString *message = [NSString stringWithFormat:@"💖userNotificationCenter_didReceiveNotificationResponse_withCompletionHandler:%@",response.notification.request.content.userInfo];
    [self debugAPNSMessage:message];
    
    NSString *userAction = response.actionIdentifier;
    if ([userAction isEqualToString:UNNotificationDefaultActionIdentifier]) {
        NSLog(@"User opened the notification.");
        [self ts_processRemoteNotification_WithUserInfo:response.notification.request.content.userInfo
                                               fromType:RemoteNotificationFrom_NotificationCenterAction
                                         fromUserAction:userAction
                                  withCompletionHandler:nil];
    }
    if ([userAction isEqualToString:UNNotificationDismissActionIdentifier]) {
        NSLog(@"User dismissed the notification.");
    }
    NSString *customAction1 = @"action1";
    NSString *customAction2 = @"action2";
    if ([userAction isEqualToString:customAction1]) {
        NSLog(@"User custom action1.");
    }
    if ([userAction isEqualToString:customAction2]) {
        NSLog(@"User custom action2.");
    }

    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSString *message = [NSString stringWithFormat:@"💖application_didReceiveRemoteNotification_fetchCompletionHandler:%@",userInfo];
    [self debugAPNSMessage:message];

    [self ts_processRemoteNotification_WithUserInfo:userInfo
                                           fromType:RemoteNotificationFrom_AppInBackground
                                     fromUserAction:nil
                              withCompletionHandler:nil];

    completionHandler(UIBackgroundFetchResultNewData);
}

/* app not launched, user touched message in message center */
- (void)ts_checkRemoteNotification_FromApplicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions{

    NSDictionary *remoteNotificationInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if([NSDictionary kk_isDictionaryNotEmpty:remoteNotificationInfo])
    {
        NSString *message = [NSString stringWithFormat:@"💖receiveRemoteNotification_FromApplicationDidFinishLaunchingWithOptions:%@",remoteNotificationInfo];
        [self debugAPNSMessage:message];

        [self ts_processRemoteNotification_WithUserInfo:remoteNotificationInfo
                                               fromType:RemoteNotificationFrom_AppLaunch
                                         fromUserAction:nil
                                  withCompletionHandler:nil];
    }
}

- (void)ts_processRemoteNotification_WithUserInfo:(NSDictionary *)userInfo
                                         fromType:(RemoteNotificationProcessType)aType
                                   fromUserAction:(NSString*)aUserAction
                            withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
        
    // イベントIDがないならトースト表示
//    NSDictionary *aps = [userInfo validDictionaryForKey:@"aps"];
//    NSDictionary *pushArguments = [aps validDictionaryForKey:@"arguments"];
//    NSString *eventId = [pushArguments validStringForKey:@"eventId"];

    if (aUserAction){
        NSLog(@"ts_processRemoteNotification: %@",aUserAction);
    }
    if (aType==RemoteNotificationFrom_AppLaunch){
        NSLog(@"ts_processRemoteNotification: RemoteNotificationFrom_AppLaunch");
    }
    else if (aType==RemoteNotificationFrom_NotificationCenterAction){
        NSLog(@"ts_processRemoteNotification: RemoteNotificationFrom_NotificationCenterAction");
    }
    else if (aType==RemoteNotificationFrom_AppInForeground){
        NSLog(@"ts_processRemoteNotification: RemoteNotificationFrom_AppInForeground");
        if (completionHandler) {
            if ([UIDevice kk_isSystemVersionBigerThan:@"14"]) {
                if (@available(iOS 14.0, *)) {
                    completionHandler(UNNotificationPresentationOptionList |
                                      UNNotificationPresentationOptionBadge);
                } else {
                    completionHandler(UNNotificationPresentationOptionAlert |
                                      UNNotificationPresentationOptionBadge);
                }
            }
            else{
                completionHandler(UNNotificationPresentationOptionAlert |
                                  UNNotificationPresentationOptionBadge);
            }
        }
        
        KKAlertView *alertView = [[KKAlertView alloc] initWithTitle:KKLocalization(@"APNS Message")
                                                           subTitle:nil
                                                            message:KKLocalization(@"This is an apns message.")
                                                           delegate:self
                                                       buttonTitles:KKLocalization(@"NO"),KKLocalization(@"YES"),nil];
        [alertView show];
    }
    else if (aType==RemoteNotificationFrom_AppInBackground){
        NSLog(@"ts_processRemoteNotification: RemoteNotificationFrom_AppInBackground");
    }
    else {
        
    }
}

- (void)debugAPNSMessage:(NSString*)aMessage{
    NSLog(@"%@",aMessage);
}

#pragma mark ==================================================
#pragma mark == KKAlertView
#pragma mark ==================================================
- (void)KKAlertView:(KKAlertView*_Nonnull)aAlertView clickedButtonAtIndex:(NSInteger)aButtonIndex{
    
}
#endif

@end

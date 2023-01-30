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

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];

    [self reloadRootViewController];
            
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

@end

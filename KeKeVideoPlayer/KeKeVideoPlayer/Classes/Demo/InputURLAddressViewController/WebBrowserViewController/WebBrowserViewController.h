//
//  WebBrowserViewController.h
//  GouUse
//
//  Created by beartech on 2018/2/24.
//  Copyright © 2018年 KeKeStudio. All rights reserved.
//

#import "BaseViewController.h"
#import "FileDownloadManager.h"

UIKIT_EXTERN NSNotificationName const NotificationName_TSWebBrowserViewControllerClose;

@interface WebBrowserViewController : BaseViewController

@property (nonatomic,copy)NSURL *myURL;

#pragma mark ==================================================
#pragma mark == 初始化
#pragma mark ==================================================
- (instancetype)initWithURL:(NSURL*)aURL;

- (instancetype)initWithURL:(NSURL*)aURL
         navigationBarTitle:(NSString*)aTitle;

- (instancetype)initWithURL:(NSURL*)aURL
         navigationBarTitle:(NSString*)aTitle
     needShowNavRightButton:(BOOL)aNeedShowNavRightButton;

@end

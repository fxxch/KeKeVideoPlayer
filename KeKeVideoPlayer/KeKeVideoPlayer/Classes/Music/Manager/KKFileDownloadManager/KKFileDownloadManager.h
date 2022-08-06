//
//  KKFileDownloadManager.h
//  KeKeVideoPlayer
//
//  Created by edward lannister on 2022/08/01.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKToastView.h"
#import "KKFileDownloader.h"
#import "KKFileDownloadInfo.h"
#import "MusicDBManager.h"

UIKIT_EXTERN NSAttributedStringKey const KKMusicFile_CachePath;

static NSString *KKNotificationName_KKFileDownloadManager_Update = @"KKNotificationName_KKFileDownloadManager_Update";
static NSString *KKNotificationName_KKFileDownloadManager_Progress = @"KKNotificationName_KKFileDownloadManager_Progress";

@interface KKFileDownloadManager : NSObject

@property (nonatomic , strong) NSMutableDictionary *willDownloadFiles;

+ (KKFileDownloadManager*)defaultManager;

- (void)downloadFileWithURL:(NSString*)aURLString;

- (void)deleteFileWithURL:(NSString*)aURLString;

@end


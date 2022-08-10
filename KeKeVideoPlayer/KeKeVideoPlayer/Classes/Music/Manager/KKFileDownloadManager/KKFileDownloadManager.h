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
static NSString *KKNotificationName_KKFileDownloadManager_Finished = @"KKNotificationName_KKFileDownloadManager_Finished";

@interface KKFileDownloadManager : NSObject

@property (nonatomic , strong) NSMutableDictionary *willDownloadFiles;

+ (KKFileDownloadManager*)defaultManager;

/// 下载文件
/// @param aURLString 下载的文件的URL
/// @param tagsArray //下载之后，保存到的标签列表
- (void)downloadFileWithURL:(NSString*)aURLString toTagsArray:(NSArray*)tagsArray;

- (void)deleteFileWithURL:(NSString*)aURLString;

@end


//
//  FileDownloadManager.h
//  Demo
//
//  Created by liubo on 2021/10/18.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDownLoader.h"
#import "FileInfo.h"

UIKIT_EXTERN NSAttributedStringKey const FileDownloadManager_Files_CacheKey;
UIKIT_EXTERN NSNotificationName const KKNotificationName_FileDownloadManager_Update;
UIKIT_EXTERN NSNotificationName const KKNotificationName_FileDownloadManager_Progress;

@interface FileDownloadManager : NSObject<FileDownLoaderDelegate>

@property (nonatomic , strong) NSMutableArray *filesArray;
@property (nonatomic , strong) NSMutableArray *willDownloadFileArray;
@property (nonatomic , assign) BOOL isDownloading;

+ (FileDownloadManager*)defaultManager;

- (void)downloadFileWithURL:(NSString*)aURLString;
- (void)deleteFileWithURL:(NSString*)aURLString;

@end

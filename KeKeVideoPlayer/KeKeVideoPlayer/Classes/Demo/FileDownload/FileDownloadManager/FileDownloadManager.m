//
//  FileDownloadManager.m
//  Demo
//
//  Created by liubo on 2021/10/18.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "FileDownloadManager.h"
#import "KKToastView.h"


NSAttributedStringKey const FileDownloadManager_Files_CacheKey  = @"FileDownloadManager_Files_CacheKey";
NSNotificationName const KKNotificationName_FileDownloadManager_Update = @"KKNotificationName_FileDownloadManager_Update";
NSNotificationName const KKNotificationName_FileDownloadManager_Progress = @"KKNotificationName_FileDownloadManager_Progress";

@implementation FileDownloadManager

+ (FileDownloadManager *)defaultManager{
    static FileDownloadManager *FileDownloadManager_default = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        FileDownloadManager_default = [[self alloc] init];
    });
    return FileDownloadManager_default;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.filesArray = [[NSMutableArray alloc] init];
        self.willDownloadFileArray = [[NSMutableArray alloc] init];
        NSArray *array = [KKUserDefaultsManager objectForKey:FileDownloadManager_Files_CacheKey identifier:nil];
        if ([NSArray kk_isArrayNotEmpty:array]) {
            for (NSInteger i=0; i<[array count]; i++) {
                FileInfo *info = [[FileInfo alloc] init];
                info.url = [array objectAtIndex:i];
                info.isFinished = YES;
                [self.filesArray addObject:info];
            }
        }
    }
    return self;
}

- (void)downloadFileWithURL:(NSString*)aURLString{
    NSInteger index = NSNotFound;
    for (NSInteger i=0; i<self.filesArray.count; i++) {
        FileInfo *item = [self.filesArray objectAtIndex:i];
        if ([item.url isEqualToString:aURLString]) {
            index = i;
            break;
        }
    }
    
    if (index!=NSNotFound) {
        [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"文件已经下载了" image:nil alignment:KKToastViewAlignment_Center];
        return;
    }
    
    for (NSInteger i=0; i<self.willDownloadFileArray.count; i++) {
        FileInfo *item = [self.willDownloadFileArray objectAtIndex:i];
        if ([item.url isEqualToString:aURLString]) {
            index = i;
            break;
        }
    }
    if (index!=NSNotFound) {
        [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"文件已经正在下载列表中……" image:nil alignment:KKToastViewAlignment_Center];
        return;
    }

    FileInfo *info = [[FileInfo alloc] init];
    info.url = aURLString;
    info.progress = @"0%%";
    info.byteString = @"等待下载中";
    info.isFinished = NO;
    [self.willDownloadFileArray addObject:info];
    [self startDownloadProgress];
}

- (void)deleteFileWithURL:(NSString*)aURLString{
    NSInteger index = NSNotFound;
    NSMutableArray *saveArray = [NSMutableArray array];
    for (NSInteger i=0; i<self.filesArray.count; i++) {
        FileInfo *item = [self.filesArray objectAtIndex:i];
        if ([item.url isEqualToString:aURLString]) {
            index = i;
            continue;
        }
        else{
            [saveArray addObject:item.url];
        }
    }
    [KKUserDefaultsManager setObject:saveArray
                              forKey:FileDownloadManager_Files_CacheKey identifier:nil];
    if (index!=NSNotFound) {
        [self.filesArray removeObjectAtIndex:index];
    }
        
    [self kk_postNotification:KKNotificationName_FileDownloadManager_Update object:aURLString];
}


- (void)startDownloadProgress{
    if (self.isDownloading) {
        return;
    }
    FileInfo *info = [self.willDownloadFileArray firstObject];
    if (info) {
        self.isDownloading = YES;
        FileDownLoader *downloader = [[FileDownLoader alloc] init];
        downloader.delegate = self;
        [downloader startDownloadFile:info.url];
    }
}

#pragma mark ==================================================
#pragma mark == FileDownLoaderDelegate
#pragma mark ==================================================
- (void)FileDownLoader_didStart:(FileDownLoader*)aLoader{
    
}

- (void)FileDownLoader_didFinished:(FileDownLoader*)aLoader{
    if ([KKFileCacheManager isExistCacheData:aLoader.urlString]) {
        
        FileInfo *info = [[FileInfo alloc] init];
        info.url = aLoader.urlString;
        info.isFinished = YES;
        [self.filesArray addObject:info];

        NSMutableArray *saveArray = [NSMutableArray array];
        for (NSInteger i=0; i<self.filesArray.count; i++) {
            FileInfo *item = [self.filesArray objectAtIndex:i];
            [saveArray addObject:item.url];
        }
        [KKUserDefaultsManager setObject:saveArray
                                  forKey:FileDownloadManager_Files_CacheKey identifier:nil];
    }
    self.isDownloading = NO;
    [self.willDownloadFileArray removeObjectAtIndex:0];
    
    [self kk_postNotification:KKNotificationName_FileDownloadManager_Update object:aLoader.urlString];

    [self startDownloadProgress];
}

- (void)FileDownLoader_didFailed:(FileDownLoader*)aLoader{
    self.isDownloading = NO;
    [self.willDownloadFileArray removeObjectAtIndex:0];
    [self kk_postNotification:KKNotificationName_FileDownloadManager_Update object:aLoader.urlString];
    
    [self startDownloadProgress];
}

- (void)FileDownLoader:(FileDownLoader*)aLoader
       progressUpdated:(NSString*)aProgress
              byteSize:(NSString*)aByteSize{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:aProgress forKey:@"progress"];
    [dictionary setObject:aByteSize forKey:@"byte"];
    FileInfo *info = [self.willDownloadFileArray objectAtIndex:0];
    info.progress = aProgress;
    info.byteString = aByteSize;
    [self kk_postNotification:KKNotificationName_FileDownloadManager_Progress object:aLoader.urlString userInfo:dictionary];
}


@end

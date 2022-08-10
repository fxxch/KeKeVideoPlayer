//
//  KKFileDownloadManager.m
//  KeKeVideoPlayer
//
//  Created by edward lannister on 2022/08/01.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "KKFileDownloadManager.h"

NSAttributedStringKey const KKMusicFile_CachePath  = @"KKMusicFile";

//NSNotificationName const KKNotificationName_FileDownloadManager_Update = @"KKNotificationName_KKFileDownloadManager_Update";
//NSNotificationName const KKNotificationName_FileDownloadManager_Progress = @"KKNotificationName_KKFileDownloadManager_Progress";

@interface KKFileDownloadManager ()<KKFileDownloaderDelegate>

@property (nonatomic , strong) KKFileDownloader *downloader;

@end


@implementation KKFileDownloadManager

+ (KKFileDownloadManager *)defaultManager{
    static KKFileDownloadManager *KKFileDownloadManager_default = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        KKFileDownloadManager_default = [[self alloc] init];
    });
    return KKFileDownloadManager_default;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.willDownloadFiles = [[NSMutableDictionary alloc] init];
    }
    return self;
}


/// 下载文件
/// @param aURLString 下载的文件的URL
/// @param tagsArray //下载之后，保存到的标签列表
- (void)downloadFileWithURL:(NSString*)aURLString toTagsArray:(NSArray*)tagsArray{
    
    if ([KKFileCacheManager isExistCacheData:aURLString]) {
        [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"文件已经下载了" image:nil alignment:KKToastViewAlignment_Center];
        return;
    }
    
    if ([self.willDownloadFiles objectForKey:aURLString]) {
        [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"文件已经正在下载列表中……" image:nil alignment:KKToastViewAlignment_Center];
        return;
    }

    KKFileDownloadInfo *info = [[KKFileDownloadInfo alloc] init];
    info.url = aURLString;
    info.progress = @"0%";
    info.byteString = @"等待下载中";
    info.status = KKFileDownloadStatus_WaitDownload;
    info.toTagsArray = tagsArray;
    [self.willDownloadFiles setObject:info forKey:aURLString];
    [self startDownloadProgress];
}

- (void)deleteFileWithURL:(NSString*)aURLString{
    
    if ([aURLString isEqualToString:self.downloader.urlString]) {
        [self.downloader stop];
        [self.willDownloadFiles removeObjectForKey:aURLString];
        [self startDownloadProgress];
        [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"删除成功" image:nil alignment:KKToastViewAlignment_Center];
        [self kk_postNotification:KKNotificationName_KKFileDownloadManager_Update object:aURLString];
        return;
    }
    
    if ([KKFileCacheManager isExistCacheData:aURLString]) {
        [KKFileCacheManager deleteCacheData:aURLString];
        [self startDownloadProgress];
        [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"删除成功" image:nil alignment:KKToastViewAlignment_Center];
        [MusicDBManager.defaultManager DBDelete_MediaTag_WithMediaIdentifer:aURLString];
        [MusicDBManager.defaultManager DBDelete_Media_WithIdentifer:aURLString];
        [self kk_postNotification:NotificationName_MusicDeleteFinished object:aURLString];
        [self kk_postNotification:KKNotificationName_KKFileDownloadManager_Update object:aURLString];
        return;
    }

    KKFileDownloadInfo *info = [self.willDownloadFiles objectForKey:aURLString];
    if (info) {
        [self.willDownloadFiles removeObjectForKey:aURLString];
        [self kk_postNotification:KKNotificationName_KKFileDownloadManager_Update object:aURLString];
    }
}


- (void)startDownloadProgress{
    if (self.downloader) {
        return;
    }
    
    if (self.willDownloadFiles.count>0) {
        NSString *key = [[self.willDownloadFiles allKeys] firstObject];
        KKFileDownloadInfo *info = [self.willDownloadFiles objectForKey:key];
        if (info) {
            info.status = KKFileDownloadStatus_Downloading;
            self.downloader = [[KKFileDownloader alloc] init];
            self.downloader.delegate = self;
            [self.downloader startDownloadFile:info.url];
        }
    }
}

#pragma mark ==================================================
#pragma mark == FileDownLoaderDelegate
#pragma mark ==================================================
- (void)KKFileDownloader_didStart:(KKFileDownloader*)aLoader{
    
}

- (void)KKFileDownloader:(KKFileDownloader*)aLoader didFinishDownloadingToURL:(NSURL *)location suggestedFilename:(NSString*)suggestedFilename{

    NSString *fileName = [self.downloader.urlString lastPathComponent];
    if ([NSString kk_isStringEmpty:fileName]) {
        fileName = suggestedFilename;
    }
    //将文件转移到安全的地方去
    NSData *data = [NSData dataWithContentsOfURL:location];
    [KKFileCacheManager saveData:data
                toCacheDirectory:KKMusicFile_CachePath
                 displayFullName:fileName
                      identifier:aLoader.urlString
                       remoteURL:aLoader.urlString
                 dataInformation:nil];

    [NSFileManager.defaultManager removeItemAtURL:location error:nil];

    if ([KKFileCacheManager isExistCacheData:aLoader.urlString]) {
        NSDictionary *info = [KKFileCacheManager cacheDataInformation:aLoader.urlString];
        [MusicDBManager.defaultManager DBInsert_Media_Information:info];
        
        KKFileDownloadInfo *downloadInfo = [self.willDownloadFiles objectForKey:aLoader.urlString];
        if ([NSArray kk_isArrayNotEmpty:downloadInfo.toTagsArray]) {
            NSString *identifier = aLoader.urlString;
            for (NSInteger i=0; i<[downloadInfo.toTagsArray count]; i++) {
                NSDictionary *tagInfo = [downloadInfo.toTagsArray objectAtIndex:i];
                NSString *tag_id = [tagInfo kk_validStringForKey:Table_Tag_tag_id];
                [MusicDBManager.defaultManager DBInsert_MediaTag_WithMediaIdentifer:identifier tagId:tag_id];
            }
        }
    }
    
    [self.willDownloadFiles removeObjectForKey:aLoader.urlString];
    self.downloader = nil;
    [self kk_postNotification:KKNotificationName_KKFileDownloadManager_Update object:aLoader.urlString];
    [self kk_postNotification:KKNotificationName_KKFileDownloadManager_Finished object:aLoader.urlString];
    
    [self startDownloadProgress];
}

- (void)KKFileDownloader_didFailed:(KKFileDownloader*)aLoader{
    [self.willDownloadFiles removeObjectForKey:aLoader.urlString];
    self.downloader = nil;
    [self kk_postNotification:KKNotificationName_KKFileDownloadManager_Update object:aLoader.urlString];
    
    [self startDownloadProgress];
}

- (void)KKFileDownloader:(KKFileDownloader*)aLoader
         progressUpdated:(NSString*)aProgress
                byteSize:(NSString*)aByteSize{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:aProgress forKey:@"progress"];
    [dictionary setObject:aByteSize forKey:@"byte"];
    KKFileDownloadInfo *info = [self.willDownloadFiles objectForKey:aLoader.urlString];
    info.progress = aProgress;
    info.byteString = aByteSize;
    [self kk_postNotification:KKNotificationName_KKFileDownloadManager_Progress object:aLoader.urlString userInfo:dictionary];
}

@end

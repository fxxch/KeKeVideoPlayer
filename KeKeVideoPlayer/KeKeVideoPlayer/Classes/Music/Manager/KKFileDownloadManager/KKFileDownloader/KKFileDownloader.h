//
//  KKFileDownloader.h
//  KeKeVideoPlayer
//
//  Created by edward lannister on 2022/08/01.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KKFileDownloaderDelegate;

@interface KKFileDownloader : NSObject

@property (nonatomic , weak) id<KKFileDownloaderDelegate> delegate;
@property (nonatomic , copy) NSString* urlString;

- (void)startDownloadFile:(NSString*)aURLString;

- (void)stop;

@end


#pragma mark ==================================================
#pragma mark == KKFileDownloaderDelegate
#pragma mark ==================================================
@protocol KKFileDownloaderDelegate <NSObject>
@optional

- (void)KKFileDownloader_didStart:(KKFileDownloader*)aLoader;

- (void)KKFileDownloader:(KKFileDownloader*)aLoader didFinishDownloadingToURL:(NSURL *)location suggestedFilename:(NSString*)suggestedFilename;

- (void)KKFileDownloader_didFailed:(KKFileDownloader*)aLoader;

- (void)KKFileDownloader:(KKFileDownloader*)aLoader
         progressUpdated:(NSString*)aProgress
                byteSize:(NSString*)aByteSize;

@end


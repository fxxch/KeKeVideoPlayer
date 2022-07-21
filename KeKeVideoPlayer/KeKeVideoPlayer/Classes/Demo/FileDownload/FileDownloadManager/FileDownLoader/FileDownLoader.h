//
//  FileDownLoader.h
//  Demo
//
//  Created by liubo on 2021/10/18.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSAttributedStringKey const FileDownloadManager_Files_CachePath;

@protocol FileDownLoaderDelegate;

@interface FileDownLoader : NSObject

@property (nonatomic , weak) id<FileDownLoaderDelegate> delegate;
@property (nonatomic , copy) NSString* urlString;

- (void)startDownloadFile:(NSString*)aURLString;

@end


#pragma mark ==================================================
#pragma mark == FileDownLoaderDelegate
#pragma mark ==================================================
@protocol FileDownLoaderDelegate <NSObject>
@optional

- (void)FileDownLoader_didStart:(FileDownLoader*)aLoader;

- (void)FileDownLoader_didFinished:(FileDownLoader*)aLoader;

- (void)FileDownLoader_didFailed:(FileDownLoader*)aLoader;

- (void)FileDownLoader:(FileDownLoader*)aLoader
       progressUpdated:(NSString*)aProgress
              byteSize:(NSString*)aByteSize;

@end


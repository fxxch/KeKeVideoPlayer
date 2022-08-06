//
//  KKFileDownloadInfo.h
//  Music
//
//  Created by edward lannister on 2022/08/02.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  KKFileDownloadStatus
 */
typedef NS_ENUM(NSInteger,KKFileDownloadStatus) {
    
    KKFileDownloadStatus_WaitDownload = 0,/* 等待下载 */
    
    KKFileDownloadStatus_Downloading = 1,/* 下载中 */
    
    KKFileDownloadStatus_DownloadFinished = 2,/* 下载完成 */
    
};

@interface KKFileDownloadInfo : NSObject

@property (nonatomic , copy) NSString *url;
@property (nonatomic , assign) KKFileDownloadStatus status;
@property (nonatomic , copy) NSString *progress;
@property (nonatomic , copy) NSString *byteString;

@end

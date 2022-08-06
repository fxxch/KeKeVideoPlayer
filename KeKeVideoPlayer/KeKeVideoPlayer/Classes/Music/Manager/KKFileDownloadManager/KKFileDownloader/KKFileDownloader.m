//
//  KKFileDownloader.m
//  KeKeVideoPlayer
//
//  Created by edward lannister on 2022/08/01.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "KKFileDownloader.h"

@interface KKFileDownloader ()<NSURLSessionDownloadDelegate>

@property (nonatomic,assign)long long bytesReceived;//已接收大小
@property (nonatomic,assign)long long bytesExpected;//文件总大小

@property(nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property(nonatomic,strong) NSURLSession *session;
@property(nonatomic,strong) NSData  *fileInfoData;//取消下载时保存的数据

@end

@implementation KKFileDownloader

- (void)dealloc{
    NSLog(@"KKFileDownloader dealloc");
}

- (void)startDownloadFile:(NSString*)aURLString{

    self.urlString = aURLString;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKFileDownloader_didStart:)]) {
        [self.delegate KKFileDownloader_didStart:self];
    }
    
    self.bytesReceived = 0;
    self.bytesExpected = 0;
    
    //请求数据
    NSURL *url = [NSURL URLWithString:[self.urlString kk_KKURLEncodedString]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //使用这个方法为session设置代理，监听下载进度和过程
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self start];
}

- (void)stop{
    [self cancel:NO];
}


//开始下载
- (void)start{
    NSLog(@"开始下载");
    [self.downloadTask resume];
    
}

//暂停下载
- (void)suspend{
    [self.downloadTask suspend];
    NSLog(@"暂停下载");
}

//取消下载
- (void)cancel:(BOOL)saveTempData{
    
    //如果想要保存已经下载的数据，以便后续继续下载
    if (saveTempData) {
        //resumeData 可以用来恢复下载的数据
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            self.fileInfoData = resumeData;
        }];
    }
    else{
        //普通的取消是不能恢复的.
        [self.downloadTask cancel];
    }
    
    //取消后 将downloadTask置空。
    self.downloadTask = nil;
}

//恢复下载
- (void)resume{
    //如果已经取消了下载，需要拿到可恢复的数据重新创建下载任务
    if (self.fileInfoData.length > 0) {
        //根据可恢复数据重新创建一个新的downloadTask指针指向全局下载任务
        self.downloadTask = [self.session downloadTaskWithResumeData:self.fileInfoData];
        [_downloadTask resume];
    }
    else {
        [self.downloadTask resume];
    }
}

#pragma mark ==================================================
#pragma mark == NSURLSessionDownloadDelegate <NSURLSessionTaskDelegate>
#pragma mark ==================================================
//bytesWritten 本次写入数据的大小
//totalBytesWritten 写入数据的总大小
//totalBytesExpectedToWrite 文件的总大小
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //下载进度
    NSLog(@"----%f", 1.0 * totalBytesWritten/totalBytesExpectedToWrite);
    
    self.bytesReceived = totalBytesWritten;
    self.bytesExpected = totalBytesExpectedToWrite;
//    lblDownloadBytes.text = [NSString stringWithFormat:@"0/%.02fMB",(float)expectedBytes/1048576];
    [self reloadPercent];
}

//下载完成调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
        
    [self reloadPercent];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKFileDownloader:didFinishDownloadingToURL:suggestedFilename:)]) {
        [self.delegate KKFileDownloader:self didFinishDownloadingToURL:location suggestedFilename:downloadTask.response.suggestedFilename];
    }
    self.downloadTask = nil;
}

//整个请求完成或者请求失败调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"didCompleteWithError");
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(KKFileDownloader_didFailed:)]) {
            [self.delegate KKFileDownloader_didFailed:self];
        }
    }
    self.downloadTask = nil;
}

- (void)reloadPercent{
    NSString *percent = [NSString stringWithFormat:@"%.0f%%",(((float)self.bytesReceived/1048576)/((float)self.bytesExpected/1048576))*100];
    
    NSString *byteSize = [NSString stringWithFormat:@"%.01f/%.01fMB",(float)self.bytesReceived/1048576,(float)self.bytesExpected/1048576];
    
    NSLog(@"%@, %@",percent,byteSize);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(KKFileDownloader:progressUpdated:byteSize:)]) {
        [self.delegate KKFileDownloader:self progressUpdated:percent byteSize:byteSize];
    }
}

@end

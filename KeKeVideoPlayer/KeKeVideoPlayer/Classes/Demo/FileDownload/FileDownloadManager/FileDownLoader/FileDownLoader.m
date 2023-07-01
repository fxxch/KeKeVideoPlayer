//
//  FileDownLoader.m
//  Demo
//
//  Created by liubo on 2021/10/18.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "FileDownLoader.h"

NSAttributedStringKey const FileDownloadManager_Files_CachePath  = @"FileDownloadManager_Files_CachePath";

@interface FileDownLoader ()

@property (nonatomic,retain)NSURLConnection *DownloadConnection;
@property (nonatomic,retain)NSMutableData   *receivedData;
@property (nonatomic,assign)long long bytesReceived;//已接收大小
@property (nonatomic,assign)long long bytesExpected;//文件总大小

@end

@implementation FileDownLoader

- (void)dealloc
{
    [self kk_unobserveAllNotification];
    NSLog(@"FileDownLoader dealloc");
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)startDownloadFile:(NSString*)aURLString{
    
    self.urlString = aURLString;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(FileDownLoader_didStart:)]) {
        [self.delegate FileDownLoader_didStart:self];
    }
    
    if (self.DownloadConnection) {
        [self.DownloadConnection cancel];
        self.DownloadConnection = nil;
    }

    if (self.receivedData) {
        self.receivedData = nil;
    }
    
    self.bytesReceived = 0;
    self.bytesExpected = 0;
    
    [self kk_observeNotification:UIApplicationDidEnterBackgroundNotification selector:@selector(Notification_UIApplicationDidEnterBackgroundNotification:)];
    [self kk_observeNotification:UIApplicationWillEnterForegroundNotification selector:@selector(Notification_UIApplicationWillEnterForegroundNotification:)];

    //请求数据
    NSURLRequest *DownloadRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[self.urlString kk_KKURLEncodedString]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    self.DownloadConnection = [[NSURLConnection alloc] initWithRequest:DownloadRequest delegate:self startImmediately:YES];
    if(self.DownloadConnection == nil) {
        return;
    }
}

#pragma mark ==================================================
#pragma mark == Notification
#pragma mark ==================================================
- (void)Notification_UIApplicationDidEnterBackgroundNotification:(NSNotification*)notice{
    
}

- (void)Notification_UIApplicationWillEnterForegroundNotification:(NSNotification*)notice{
    
}

#pragma mark ========================================
#pragma mark == NSURLConnectionDelegate
#pragma mark ========================================
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(FileDownLoader_didFailed:)]) {
        [self.delegate FileDownLoader_didFailed:self];
    }

    if (self.DownloadConnection) {
        [self.DownloadConnection cancel];
        self.DownloadConnection = nil;
    }
    
    if (self.receivedData) {
        self.receivedData = nil;
    }
}

//下面两段是重点，要服务器端单项HTTPS 验证，iOS 客户端忽略证书验证。
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSLog(@"didReceiveAuthenticationChallenge %@ %zd", [[challenge protectionSpace] authenticationMethod], (ssize_t) [challenge previousFailureCount]);
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        
        [[challenge sender]  useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        
        [[challenge sender]  continueWithoutCredentialForAuthenticationChallenge: challenge];
    }
}


#pragma mark ========================================
#pragma mark == NSURLConnectionDataDelegate
#pragma mark ========================================
////接收完HTTP协议头，开始真正接手数据时候调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //    NSHTTPURLResponse * res = (NSHTTPURLResponse *)response;
    //    NSInteger statusCode = [res statusCode];
    //    if(statusCode >= 400)     {
    //        NSLog(@"HTTP ERROR CODE %ld",(long)statusCode);
    //    }
    //    NSDictionary * dic = [res allHeaderFields];
    //    NSLog(@"all Header Field %@",dic);
    
    self.bytesExpected = [response expectedContentLength];
    //    lblDownloadBytes.text = [NSString stringWithFormat:@"0/%.02fMB",(float)expectedBytes/1048576];
    [self reloadPercent];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (!self.receivedData) {
        self.receivedData = [[NSMutableData alloc] init];
    }
    [self.receivedData appendData:data];
    NSInteger receivedLen = [data length];
    self.bytesReceived = (self.bytesReceived + receivedLen);
    
    [self reloadPercent];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //    lblDownloadBytes.textColor = [UIColor blueColor];
    //    lblDownloadPercent.textColor = [UIColor blueColor];
    
    [self reloadPercent];
    
    if (self.receivedData && self.receivedData.length>1024) {
        [self saveData];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(FileDownLoader_didFinished:)]) {
            [self.delegate FileDownLoader_didFinished:self];
        }
    }
    else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(FileDownLoader_didFailed:)]) {
            [self.delegate FileDownLoader_didFailed:self];
        }
    }
    
    if (self.DownloadConnection) {
        [self.DownloadConnection cancel];
        self.DownloadConnection = nil;
    }
    
    if (self.receivedData) {
        self.receivedData = nil;
    }
}

- (void)saveData{
    NSString *fileName = [self.urlString lastPathComponent];
    [KKFileCacheManager saveData:self.receivedData
                toCacheDirectory:FileDownloadManager_Files_CachePath
                 displayFullName:fileName
                      identifier:self.urlString
                       remoteURL:self.urlString
                 dataInformation:nil];
}

- (void)reloadPercent{
    NSString *percent = [NSString stringWithFormat:@"%.0f%%",(((float)self.bytesReceived/1048576)/((float)self.bytesExpected/1048576))*100];
    
    NSString *byteSize = [NSString stringWithFormat:@"%.01f/%.01fMB",(float)self.bytesReceived/1048576,(float)self.bytesExpected/1048576];
    
    NSLog(@"%@, %@",percent,byteSize);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(FileDownLoader:progressUpdated:byteSize:)]) {
        [self.delegate FileDownLoader:self progressUpdated:percent byteSize:byteSize];
    }
}



@end

//
//  HomeDataSynchronousView.m
//  Music
//
//  Created by edward lannister on 2022/08/05.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "HomeDataSynchronousView.h"
#import "DataListNotDownloadView.h"
#import "DataListCloudAllView.h"
#import "DataListDownloadingView.h"
#import "KKGetIPAddress.h"
#import "MusicServerAddressListView.h"
#import "MusicTagSelectView.h"

#define MusicPath @"music"

@interface HomeDataSynchronousView ()<MusicNavigationBarViewDelegate,KKSegmentViewDelegate>

@property (nonatomic , strong) MusicNavigationBarView *navBarView;

@property (nonatomic , strong) KKSegmentView *segmentView;
@property (nonatomic , strong) DataListNotDownloadView *notDownloadView;
@property (nonatomic , strong) DataListCloudAllView *cloudAllView;
@property (nonatomic , strong) DataListDownloadingView *downloadingView;

@property (nonatomic , strong) NSMutableArray *auto_ipArray;
@property (nonatomic , assign) NSInteger auto_ipIndex;
@property (nonatomic , copy) NSString *hostRootPath;// http://192.168.1.105
@property (nonatomic , strong) NSArray *synchronousAutoTagsArray;

@end

@implementation HomeDataSynchronousView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.navBarView = [[MusicNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKStatusBarAndNavBarHeight)];
    self.navBarView.delegate = self;
    [self addSubview:self.navBarView];
    [self.navBarView showTextField];
    [self.navBarView showTextFieldRightButtonWithTaget:self selector:@selector(navTextFieldRightButtonClicked) image:KKThemeImage(@"Music_btn_arrow_down")];
    self.navBarView.footerLineView.hidden = YES;
    [self.navBarView setNavRightButtonImage:KKThemeImage(@"Music_btn_NavCloud") selector:@selector(navCloudButtonClicked) target:self];
        
    //KKSegmentView
    self.segmentView = [[KKSegmentView alloc] initWithFrame:CGRectMake(0, self.navBarView.kk_height, KKApplicationWidth, 40)];
    self.segmentView.delegate = self;
    self.segmentView.backgroundColor = [UIColor whiteColor];
    self.segmentView.sliderView.hidden = NO;
    self.segmentView.sliderSize = CGSizeMake(60, 3.0);
    self.segmentView.sliderView.backgroundColor = Theme_Color_D31925;
    [self addSubview:self.segmentView];
    [self.segmentView selectedIndex:0 needRespondsDelegate:NO];
    [self.segmentView kk_setCornerRadius:2.0];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.segmentView.kk_bottom-0.25, self.kk_width, 0.25)];
    line.backgroundColor = Theme_Color_999999;
    [self addSubview:line];

    CGFloat offsetY = self.segmentView.kk_bottom;
    self.notDownloadView = [[DataListNotDownloadView alloc] initWithFrame:CGRectMake(0, offsetY, KKApplicationWidth, self.kk_height-offsetY)];
    [self addSubview:self.notDownloadView];
    [self.notDownloadView reloadURL:self.navBarView.inputTextField.text];

    self.downloadingView = [[DataListDownloadingView alloc] initWithFrame:CGRectMake(0, offsetY, KKApplicationWidth, self.kk_height-offsetY)];
    [self addSubview:self.downloadingView];
    [self.downloadingView reloadDatasource];
    self.downloadingView.hidden = YES;

    self.cloudAllView = [[DataListCloudAllView alloc] initWithFrame:CGRectMake(0, offsetY, KKApplicationWidth, self.kk_height-offsetY)];
    [self addSubview:self.cloudAllView];
    [self.cloudAllView reloadURL:self.navBarView.inputTextField.text];
    self.cloudAllView.hidden = YES;
    
    [self autoCheckWifiIP];
}

- (void)synchronousAuto{
    [KKWaitingView showInView:self withType:KKWaitingViewType_Gray blackBackground:YES text:@"自动同步中……"];
    
    KKWeakSelf(self);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.navBarView.inputTextField.text]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error==nil && data) {
                NSError *aError = nil;
                HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&aError];
                [weakself parserHTMLParser_audio:parser];
            }
            else{
                NSLog(@"%@",error);
                [KKWaitingView hideForView:self];
            }

        });
        
    }];
    [task resume];
}

#pragma mark ==================================================
#pragma mark == 自动检索IP地址
#pragma mark ==================================================
- (void)autoCheckWifiIP{
    self.navBarView.inputTextField.text = nil;
    [self.notDownloadView reloadURL:self.navBarView.inputTextField.text];
    [self.cloudAllView reloadURL:self.navBarView.inputTextField.text];
    self.hostRootPath = nil;

    if (self.auto_ipArray==nil) {
        self.auto_ipArray = [[NSMutableArray alloc] init];
    }
    [self.auto_ipArray removeAllObjects];
    self.auto_ipIndex = 0;
    
    NSString *wifiIPAddress = [KKGetIPAddress getCurrentWifiIP];
    if ([NSString kk_isStringNotEmpty:wifiIPAddress]) {
        NSArray *array = [wifiIPAddress componentsSeparatedByString:@"."];
        if ([array count]>=4) {
            NSString *str01 = [array objectAtIndex:0];
            NSString *str02 = [array objectAtIndex:1];
            NSString *str03 = [array objectAtIndex:2];
          //NSString *str04 = [array objectAtIndex:3];
            for (NSInteger index=2; index<=300; index++) {
                NSString *fullString = [NSString stringWithFormat:@"%@.%@.%@.%ld",str01,str02,str03,(long)(index)];
                [self.auto_ipArray addObject:fullString];
            }
            
            [self autoSearchIP_Start];
        }
    }
    else{
        [KKToastView showInView:self text:@"请连接wifi" image:nil alignment:KKToastViewAlignment_Center];
    }

}

- (void)autoSearchIP_Start{
    self.auto_ipIndex = 0;
    for (NSInteger i=0; i<[self.auto_ipArray count]; i++) {
        NSString *ipString = [self.auto_ipArray objectAtIndex:i];
        [self autoSearchIP_Process:ipString];
    }
}

- (void)autoSearchIP_Process:(NSString*)aIp{
    NSString *ipAddress = aIp;
    if (ipAddress==nil) {
        return;
    }
    
    NSString *ulr = [NSString stringWithFormat:@"http://%@/%@",ipAddress,MusicPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ulr]];
    [request setHTTPMethod:@"HEAD"];
    request.timeoutInterval = 2.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    KKWeakSelf(self);
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                weakself.auto_ipIndex = weakself.auto_ipIndex+1;
                if (weakself.auto_ipIndex==[weakself.auto_ipArray count]) {
                }
            });
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                weakself.auto_ipIndex = weakself.auto_ipIndex+1;
                NSString *wifiURL = [request.URL absoluteString];
                NSString *wifiIP = [wifiURL stringByDeletingLastPathComponent];
                if ([wifiIP isEqualToString:weakself.hostRootPath]==NO) {
                    weakself.navBarView.inputTextField.text = wifiURL;
                    [weakself.notDownloadView reloadURL:weakself.navBarView.inputTextField.text];
                    [weakself.cloudAllView reloadURL:weakself.navBarView.inputTextField.text];

                    weakself.hostRootPath = wifiIP;
                }
            });
        }
    }];
    [task resume];
}

#pragma mark ==================================================
#pragma mark == Event
#pragma mark ==================================================
- (void)navCloudButtonClicked{
    KKWeakSelf(self)
    [MusicTagSelectView showInView:[UIWindow kk_currentKeyWindow] finishedBlock:^(NSArray * _Nullable tagsArray) {
        weakself.synchronousAutoTagsArray = tagsArray;
        [weakself synchronousAuto];
    }];
}

- (void)navTextFieldRightButtonClicked{
    [self searchCloudPaths:self.navBarView.inputTextField.text showParent:YES];
}

#pragma mark ==================================================
#pragma mark == 检索目录
#pragma mark ==================================================
- (void)searchCloudPaths:(NSString*)aParentPath showParent:(BOOL)showParent{
    if ([NSString kk_isStringEmpty:aParentPath]) {
        return;
    }
    [KKWaitingView showInView:self withType:KKWaitingViewType_Gray blackBackground:NO text:@""];
    KKWeakSelf(self);
    __block NSString *headPath = aParentPath;
    __block BOOL needCheckParent = showParent;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:headPath]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error==nil && data) {
                NSError *aError = nil;
                HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&aError];
                [weakself parserHTMLParser_directory:parser headPath:headPath showParent:needCheckParent];
            }
            else{
                NSLog(@"%@",error);
                [KKWaitingView hideForView:self];
            }
        });
    }];
    [task resume];
}

#pragma mark ==================================================
#pragma mark == parserHTMLParser
#pragma mark ==================================================
- (void)parserHTMLParser_audio:(HTMLParser*)parser{
    [KKWaitingView hideForView:self];

    NSArray *audioFileNames = [MusicHTMLParser parserHTMLParser:parser type:MusicHTMLParserType_Audio];
    for (NSInteger i=0; i<[audioFileNames count]; i++) {
        NSString *fileName = [audioFileNames objectAtIndex:i];
        NSString *urlString = [self.navBarView.inputTextField.text stringByAppendingPathComponent:fileName];
        if ([MusicDBManager.defaultManager DBQuery_Table:TableName_Media isExistValue:fileName forKey:Table_Media_local_name]) {

        }
        else{
            [KKFileDownloadManager.defaultManager downloadFileWithURL:urlString toTagsArray:self.synchronousAutoTagsArray];
        }
    }
    if (audioFileNames.count>0) {
        [self.segmentView selectedIndex:1 needRespondsDelegate:YES];
    }
    else{
        [KKToastView showInView:self text:@"数据已是最新" image:nil alignment:KKToastViewAlignment_Center];
    }
    self.synchronousAutoTagsArray = nil;
}

/// 解析目录
/// @param parser 源数据
/// @param aHeadPath 头部地址
/// @param showParent 如果没解析到子目录，是否继续解析父节点
- (void)parserHTMLParser_directory:(HTMLParser*)parser headPath:(NSString*)aHeadPath showParent:(BOOL)showParent{
    [KKWaitingView hideForView:self];

    NSMutableArray *pathArray = [NSMutableArray array];

    NSArray *directoryNames = [MusicHTMLParser parserHTMLParser:parser type:MusicHTMLParserType_Directory];
    for (NSInteger i=0; i<[directoryNames count]; i++) {
        NSString *directory = [directoryNames objectAtIndex:i];
        NSString *pathTemp = [aHeadPath stringByAppendingPathComponent:directory];
        [pathArray addObject:pathTemp];
    }

    //找到了子目录，显示当前目录+子目录
    if (pathArray.count>0) {
        NSMutableArray *arrayShow = [NSMutableArray array];
        [arrayShow addObject:aHeadPath];
        [arrayShow addObjectsFromArray:pathArray];
        KKWeakSelf(self);
        [MusicServerAddressListView showInView:[UIWindow kk_currentKeyWindow] dataSource:arrayShow selected:self.navBarView.inputTextField.text finishedBlock:^(NSString * _Nullable address) {
            weakself.navBarView.inputTextField.text = address;
            [weakself.notDownloadView reloadURL:weakself.navBarView.inputTextField.text];
            [weakself.cloudAllView reloadURL:weakself.navBarView.inputTextField.text];
        }];
    }
    //没找到子目录,显示父目录和当前目录
    else{
        //如果当前目录已经是根目录了，不显示任何东西
        NSString *currentPath = self.navBarView.inputTextField.text;
        NSString *rootPath = [self.hostRootPath stringByAppendingPathComponent:MusicPath];
        if ([currentPath isEqualToString:rootPath]) {
            
        }
        //显示父目录和其子目录
        else{
            if (showParent) {
                NSString *parentPath = [aHeadPath stringByDeletingLastPathComponent];
                [self searchCloudPaths:parentPath showParent:NO];
            }
        }
    }
}

#pragma mark ==================================================
#pragma mark == MusicNavigationBarViewDelegate
#pragma mark ==================================================
- (void)MusicNavigationBarView:(MusicNavigationBarView*)aBarView textDidEndEditing:(KKTextField*)aTextField{
    [self.notDownloadView reloadURL:self.navBarView.inputTextField.text];
    [self.cloudAllView reloadURL:self.navBarView.inputTextField.text];
}


#pragma mark ==================================================
#pragma mark == KKSegmentViewDelegate
#pragma mark ==================================================
- (NSInteger)KKSegmentView_NumberOfButtons:(KKSegmentView*)aSegmentView{
    return 3;
}

- (KKButton*)KKSegmentView:(KKSegmentView*)aSegmentView
            buttonForIndex:(NSInteger)aIndex{

    KKButton *itemButton = [[KKButton alloc] initWithFrame:CGRectMake(0,0, KKScreenWidth/3, 40) type:KKButtonType_ImgTopTitleBottom_Center];
    if (aIndex==0) {
        itemButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self setButtonStyle:itemButton
                   withTitle:@"未下载"
                 normalImage:nil
            highlightedImage:nil
                   imageSize:CGSizeZero];
    }
    else if (aIndex==1){
        itemButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self setButtonStyle:itemButton
                   withTitle:@"下载中"
                 normalImage:nil
            highlightedImage:nil
                   imageSize:CGSizeZero];
    }
    else{
        itemButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self setButtonStyle:itemButton
                   withTitle:@"全部"
                 normalImage:nil
            highlightedImage:nil
                   imageSize:CGSizeZero];
    }
    return itemButton;
}

/*
 选中了新的Button
 */
- (void)KKSegmentView:(KKSegmentView*)aSegementView willDeselectIndex:(NSInteger)aOldIndex willSelectNewIndex:(NSInteger)aNewIndex{
    
    KKButton *btn0 = [aSegementView buttonAtIndex:aOldIndex];
    btn0.textLabel.font = [UIFont systemFontOfSize:14];
    [btn0 setTitleColor:Theme_Color_333333 forState:UIControlStateNormal];

    KKButton *btn1 = [aSegementView buttonAtIndex:aNewIndex];
    btn1.textLabel.font = [UIFont boldSystemFontOfSize:16];
    [btn1 setTitleColor:Theme_Color_D31925 forState:UIControlStateNormal];

    if (aNewIndex==0) {
        self.notDownloadView.hidden = NO;
        [self.notDownloadView reloadURL:self.navBarView.inputTextField.text];
        self.downloadingView.hidden = YES;
        self.cloudAllView.hidden = YES;
    }
    else if (aNewIndex==1) {
        self.notDownloadView.hidden = YES;
        self.downloadingView.hidden = NO;
        [self.downloadingView reloadDatasource];
        self.cloudAllView.hidden = YES;
    }
    else{
        self.notDownloadView.hidden = YES;
        self.downloadingView.hidden = YES;
        self.cloudAllView.hidden = NO;
        [self.cloudAllView reloadURL:self.navBarView.inputTextField.text];
    }
}

- (void)setButtonStyle:(KKButton*)aButton
             withTitle:(NSString*)aTitle
           normalImage:(UIImage*)aImageNor
      highlightedImage:(UIImage*)aImageSel
             imageSize:(CGSize)aSize{
    aButton.buttonType = KKButtonType_ImgTopTitleBottom_Center;
    aButton.spaceBetweenImgTitle = 0.0;
    aButton.imageViewSize = aSize;
    aButton.textLabel.font = [UIFont systemFontOfSize:14];
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    [aButton setTitle:aTitle forState:UIControlStateSelected];
    [aButton setTitleColor:Theme_Color_333333 forState:UIControlStateNormal];
    [aButton setTitleColor:Theme_Color_D31925 forState:UIControlStateSelected];
    [aButton setImage:aImageNor forState:UIControlStateNormal];
    [aButton setImage:aImageSel forState:UIControlStateSelected];
}

@end

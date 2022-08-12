//
//  DataListNotDownloadView.m
//  Music
//
//  Created by edward lannister on 2022/08/05.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "DataListNotDownloadView.h"
#import "MusicTagSelectView.h"

@interface DataListNotDownloadView ()<UITableViewDataSource,UITableViewDelegate,KKRefreshHeaderViewDelegate>

@property (nonatomic , strong)UITableView *table;
@property (nonatomic , strong)NSMutableArray *dataSource;
@property (nonatomic , copy) NSString *url;

@end

@implementation DataListNotDownloadView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.dataSource = [[NSMutableArray alloc] init];
    [self kk_observeNotification:KKNotificationName_KKFileDownloadManager_Finished selector:@selector(KKNotification_KKFileDownloadManager_Finished:)];
    
    self.table = [UITableView kk_initWithFrame:self.bounds style:UITableViewStylePlain delegate:self datasource:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    [self addSubview:self.table];
    [self.table showRefreshHeaderWithDelegate:self];

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.5)];
    [self.table setTableFooterView:header];

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.5)];
    [self.table setTableFooterView:footer];
}

- (void)reloadURL:(NSString*)aURL{
    self.url = aURL;
    [self.table startRefreshHeader];
}

- (void)reloadDatasource:(NSString*)aURL{
    
    KKWeakSelf(self);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.dataSource removeAllObjects];
            [weakself.table reloadData];

            if (error==nil && data) {
                NSError *aError = nil;
                HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&aError];
                [weakself parserHTMLParser_audio:parser];
            }
            else{
                NSLog(@"%@",error);
//                [KKToastView showInView:self text:@"刷新失败" image:nil alignment:KKToastViewAlignment_Center];
                [self.table stopRefreshHeader];
            }

        });
        
    }];
    [task resume];
}

//触发刷新加载数据
- (void)KKRefreshHeaderView_BeginRefresh:(KKRefreshHeaderView*)view{
    [self reloadDatasource:self.url];
}

#pragma mark ==================================================
#pragma mark == Notification
#pragma mark ==================================================
- (void)KKNotification_KKFileDownloadManager_Finished:(NSNotification*)notice{
    NSString *identifier = notice.object;
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.dataSource];
    for (NSDictionary *info in self.dataSource) {
        NSString *url = [info kk_validStringForKey:@"url"];
        if ([url isEqualToString:identifier]) {
            [array removeObject:info];
        }
    }
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:array];
    [self.table reloadData];
}

#pragma mark ==================================================
#pragma mark == parserHTMLParser
#pragma mark ==================================================
- (void)parserHTMLParser_audio:(HTMLParser*)parser{
    
    NSArray *audioFileNames = [MusicHTMLParser parserHTMLParser:parser type:MusicHTMLParserType_Audio];
    for (NSInteger i=0; i<[audioFileNames count]; i++) {
        NSString *fileName = [audioFileNames objectAtIndex:i];
        NSString *urlString = [self.url stringByAppendingPathComponent:fileName];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    fileName,@"fileName",
                                    urlString,@"url",
                                    nil];
        if ([MusicDBManager.defaultManager DBQuery_Table:TableName_Media isExistValue:fileName forKey:Table_Media_local_name]) {

        }
        else{
            [self.dataSource addObject:dictionary];
        }
    }

    [self.table stopRefreshHeader];
    [self.table reloadData];
}

#pragma mark ========================================
#pragma mark ==UITableView
#pragma mark ========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.dataSource.count>0) {
        return 30;
    }
    else{
        return 0.1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.dataSource.count>0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 30)];
        view.backgroundColor = Theme_Color_FFF9E5;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, KKScreenWidth-30, 14)];
        label.font = [UIFont systemFontOfSize:12];
        label.text = [NSString stringWithFormat:@"总共 %ld条 数据",self.dataSource.count];
        
        [view addSubview:label];

        return view;
    }
    else{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.1)];
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.1)];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier1=@"cellIdentifier1";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        cell.accessoryType=UITableViewCellAccessoryNone;

        CGSize size = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:17]];
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (60-size.height)/2.0, KKApplicationWidth-30-30-10, size.height)];
        mainLabel.tag = 199901;
        mainLabel.textColor = [UIColor blackColor];
        mainLabel.font = [UIFont systemFontOfSize:14];
        mainLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [cell.contentView addSubview:mainLabel];
        
        UIButton *download_Button = [[UIButton alloc] initWithFrame:CGRectMake(KKScreenWidth-15-30, 15, 30, 30)];
        [download_Button setBackgroundImage:KKThemeImage(@"Music_download") forState:UIControlStateNormal];
        [download_Button addTarget:self action:@selector(downloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        download_Button.tag = 199902;
        [cell.contentView addSubview:download_Button];
    }
    
    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];;
    UILabel *mainLabel = (UILabel*)[cell.contentView viewWithTag:199901];
    mainLabel.text = [info kk_validStringForKey:@"fileName"];
    
    UIButton *download_Button = (UIButton*)[cell.contentView viewWithTag:199902];
    download_Button.kk_tagInfo = [NSString kk_stringWithInteger:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];;
    NSString *url = [info kk_validStringForKey:@"url"];
    NSString *filePath = [KKFileCacheManager cacheDataPath:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        KKVideoPlayViewController *viewController = [[KKVideoPlayViewController alloc] initWitFilePath:filePath fileName:url.lastPathComponent];
        [self.kk_viewController.navigationController pushViewController:viewController animated:YES];
    }
    else{
        NSString *requestURL = url;
        NSString *pathExtension = [[[requestURL lowercaseString] pathExtension] lowercaseString];
        if ([NSFileManager kk_isFileType_VIDEO:pathExtension] ||
            [NSFileManager kk_isFileType_AUDIO:pathExtension] ) {
            KKVideoPlayViewController *viewController = [[KKVideoPlayViewController alloc] initWitFilePath:requestURL fileName:requestURL.lastPathComponent?requestURL.lastPathComponent:@"播放文件"];
            [self.kk_viewController.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (void)downloadButtonClicked:(UIButton*)aButton{
    
     NSInteger index = [aButton.kk_tagInfo integerValue];
    KKWeakSelf(self);
    [MusicTagSelectView showInView:[UIWindow kk_currentKeyWindow] finishedBlock:^(NSArray * _Nullable tagsArray) {
       
        NSDictionary *info = [weakself.dataSource objectAtIndex:index];
        NSString *url = [info kk_validStringForKey:@"url"];
        [KKFileDownloadManager.defaultManager downloadFileWithURL:url toTagsArray:tagsArray];

    }];
    
}

@end

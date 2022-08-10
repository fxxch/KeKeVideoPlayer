//
//  DataListDownloadingView.m
//  Music
//
//  Created by edward lannister on 2022/08/05.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "DataListDownloadingView.h"

@interface DataListDownloadingView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , strong)UITableView *table;
@property (nonatomic , strong)NSMutableArray *dataSource;

@end

@implementation DataListDownloadingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(KKNotification_KKFileDownloadManager_Update:) name:KKNotificationName_KKFileDownloadManager_Update object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(KKNotification_KKFileDownloadManager_Progress:) name:KKNotificationName_KKFileDownloadManager_Progress object:nil];
    
    self.dataSource = [[NSMutableArray alloc] init];

    self.table = [UITableView kk_initWithFrame:self.bounds style:UITableViewStylePlain delegate:self datasource:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    [self addSubview:self.table];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.5)];
    [self.table setTableFooterView:header];

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.5)];
    [self.table setTableFooterView:footer];
}

- (void)reloadDatasource{
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:[KKFileDownloadManager.defaultManager willDownloadFiles].allValues];
    [self.table reloadData];
}

#pragma mark ==================================================
#pragma mark == 通知
#pragma mark ==================================================
- (void)KKNotification_KKFileDownloadManager_Update:(NSNotification*)notice{
    [self reloadDatasource];
}

- (void)KKNotification_KKFileDownloadManager_Progress:(NSNotification*)notice{
    [self reloadDatasource];
}

#pragma mark ========================================
#pragma mark ==UITableView
#pragma mark ========================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize sizeM = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:16]];
            
    CGSize sizeS = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:12]];

    return 10+sizeM.height+5+sizeS.height+10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifierD=@"cellIdentifierD";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierD];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierD];
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGSize sizeM = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:16]];
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, KKApplicationWidth-30, sizeM.height)];
        mainLabel.tag = 2201;
        mainLabel.font = [UIFont systemFontOfSize:16];
        mainLabel.numberOfLines = 1;
        mainLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:mainLabel];
        
        CGSize sizeS = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:12]];
        
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, mainLabel.kk_bottom+5, KKApplicationWidth-30, sizeS.height)];
        subLabel.tag = 2202;
        subLabel.font = [UIFont systemFontOfSize:12];
        subLabel.numberOfLines = 1;
        subLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:subLabel];
    }
    
    KKFileDownloadInfo *info = [self.dataSource objectAtIndex:indexPath.row];;
    NSString *url = info.url;
    NSString *title = [url lastPathComponent];
    
    UILabel *mainLabel = (UILabel*)[cell viewWithTag:2201];
    UILabel *subLabel = (UILabel*)[cell viewWithTag:2202];
    mainLabel.text = title;
    subLabel.text = [NSString stringWithFormat:@"%@        %@",info.progress,info.byteString];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


@end

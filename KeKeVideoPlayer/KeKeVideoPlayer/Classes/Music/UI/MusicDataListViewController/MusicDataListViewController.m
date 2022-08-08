//
//  MusicDataListViewController.m
//  Music
//
//  Created by edward lannister on 2022/08/08.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicDataListViewController.h"
#import "MusicCell.h"

@interface MusicDataListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , strong)UITableView *table;
@property (nonatomic , strong) NSMutableArray *dataSource;

@property (nonatomic , assign) MusicDataListType type;
@property (nonatomic , strong) NSDictionary *tagInformation;

@end

@implementation MusicDataListViewController

- (instancetype)initMusicDataListType:(MusicDataListType)aType dataArray:(NSArray*)aDataArray{
    self = [super init];
    if (self) {
        self.type = aType;
        self.dataSource = [[NSMutableArray alloc] init];
        [self.dataSource addObjectsFromArray:aDataArray];
    }
    return self;
}

- (instancetype)initWithTagInfo:(NSDictionary*)aTagInformation{
    self = [super init];
    if (self) {
        self.dataSource = [[NSMutableArray alloc] init];
        self.type = MusicDataListType_Tag;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self showNavigationDefaultBackButton_ForNavPopBack];
    switch (self.type) {
        case MusicDataListType_All:{
            self.title = @"全部歌曲";
            KKButton *button = [self setNavRightButtonTitle:@"播放全部" selector:@selector(navPlayAllButtonClicked)];
            [button setTitleColor:Theme_Color_666666 forState:UIControlStateNormal];
            break;
        }
        case MusicDataListType_NoTag:{
            self.title = @"未分类歌曲";
            KKButton *button = [self setNavRightButtonTitle:@"播放全部" selector:@selector(navPlayAllButtonClicked)];
            [button setTitleColor:Theme_Color_666666 forState:UIControlStateNormal];
            break;
        }
        case MusicDataListType_Error:{
            self.title = @"异常歌曲";
            KKButton *button = [self setNavRightButtonTitle:@"删除全部" selector:@selector(navDeleteAllButtonClicked)];
            [button setTitleColor:Theme_Color_D31925 forState:UIControlStateNormal];
            break;
        }
        case MusicDataListType_Tag:{
            KKButton *button = [self setNavRightButtonTitle:@"播放全部" selector:@selector(navPlayAllButtonClicked)];
            [button setTitleColor:Theme_Color_666666 forState:UIControlStateNormal];

            NSString *tagId = [self.tagInformation kk_validStringForKey:Table_Tag_tag_id];
            NSString *tagName = [self.tagInformation kk_validStringForKey:Table_Tag_tag_name];
            self.title = tagName;
            [self.dataSource removeAllObjects];
            NSArray *array = [MusicDBManager.defaultManager DBQuery_Media_WithTagId:tagId];
            [self.dataSource addObjectsFromArray:array];
            [self.table reloadData];
            break;
        }
        default:
            break;
    }
    
    [self initUI];
}

- (void)initUI{
    self.table = [UITableView kk_initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKScreenHeight-KKStatusBarAndNavBarHeight) style:UITableViewStylePlain delegate:self datasource:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    [self.view addSubview:self.table];
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.5)];
    [self.table setTableFooterView:header];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKSafeAreaBottomHeight)];
    [self.table setTableFooterView:footer];
}

- (void)navPlayAllButtonClicked{
    [self kk_postNotification:KKNotificationName_StartPlayDataSouce object:self.dataSource];
    [self kk_postNotification:NotificationName_HomeSelectPlayerView];
}

- (void)navDeleteAllButtonClicked{
    for (NSDictionary *info in self.dataSource) {
        NSString *identifier = [info kk_validStringForKey:Table_Media_identifier];
        
        //删除缓存数据
        [KKFileCacheManager deleteCacheData:identifier];
        //删除音乐-Tag关系表
        [MusicDBManager.defaultManager DBDelete_MediaTag_WithMediaIdentifer:identifier];
        //删除音乐表
        [MusicDBManager.defaultManager DBDelete_Media_WithIdentifer:identifier];
        
        
    }
    
    [self.dataSource removeAllObjects];;
    [self.table reloadData];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.1)];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.1)];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MusicCell cellHeightWithInformation:[self.dataSource objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier1=@"cellIdentifier1";
    MusicCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    if (!cell) {
        cell=[[MusicCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    
    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];;
    [cell reloadWithInformation:info];
    cell.name_Label.textColor = [UIColor blackColor];

    if (self.type==MusicDataListType_Error) {
        cell.tag_Button.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KKWeakSelf(self);
    //删除
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSDictionary *info = [weakself.dataSource objectAtIndex:indexPath.row];
        NSString *identifier = [info kk_validStringForKey:Table_Media_identifier];
        
        //删除缓存数据
        [KKFileCacheManager deleteCacheData:identifier];
        //删除音乐-Tag关系表
        [MusicDBManager.defaultManager DBDelete_MediaTag_WithMediaIdentifer:identifier];
        //删除音乐表
        [MusicDBManager.defaultManager DBDelete_Media_WithIdentifer:identifier];
                
        [self kk_postNotification:NotificationName_MusicDeleteFinished object:identifier];
        
        [weakself.dataSource removeObject:info];
        [weakself.table reloadData];
        
        completionHandler (YES);
    }];
    deleteRowAction.backgroundColor = [UIColor kk_colorWithHexString:@"#FF4646"];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
}

@end

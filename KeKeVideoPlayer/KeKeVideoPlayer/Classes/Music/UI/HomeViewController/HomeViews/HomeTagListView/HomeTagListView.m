//
//  HomeTagListView.m
//  Music
//
//  Created by edward lannister on 2022/08/05.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "HomeTagListView.h"
#import "MusicDataListViewController.h"
#import "MusicSearchViewController.h"
#import "MusicSettingViewController.h"

#define TagCellHeight (60.0f)

@interface HomeTagListView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , strong) MusicNavigationBarView *navBarView;
@property (nonatomic , strong) UITableView *table;
@property (nonatomic , strong) NSMutableArray *dataSource;
@property (nonatomic , strong) NSMutableArray *noTagArray;
@property (nonatomic , strong) NSMutableArray *errorDataArray;

@end

@implementation HomeTagListView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.dataSource = [[NSMutableArray alloc] init];
    self.noTagArray = [[NSMutableArray alloc] init];
    self.errorDataArray = [[NSMutableArray alloc] init];

    self.navBarView = [[MusicNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKStatusBarAndNavBarHeight)];
    [self addSubview:self.navBarView];
    [self.navBarView setTitle:@"标签"];
    [self.navBarView setNavLeftButtonImage:KKThemeImage(@"Music_btn_NavPlus") selector:@selector(navAddTagButtonClicked) target:self];
//    [self.navBarView setNavRightButtonImage:KKThemeImage(@"Music_btn_search") selector:@selector(navSearchButtonClicked) target:self];
    [self.navBarView setNavRightButtonImage:KKThemeImage(@"Music_Setting_version") selector:@selector(navSettingButtonClicked) target:self];

    self.table = [UITableView kk_initWithFrame:CGRectMake(0, self.navBarView.kk_height, KKApplicationWidth, self.kk_height-self.navBarView.kk_height) style:UITableViewStyleGrouped delegate:self datasource:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    [self addSubview:self.table];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.1)];
    [self.table setTableHeaderView:header];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.1)];
    [self.table setTableFooterView:footer];
    
    [self reloadDatasource];
    
    [self bringSubviewToFront:self.navBarView];
}

- (void)reloadDatasource{
    [self.dataSource removeAllObjects];
    NSArray *array = [MusicDBManager.defaultManager DBQuery_Tag_All];
    [self.dataSource addObjectsFromArray:array];
    
    [self.noTagArray removeAllObjects];
    [self.noTagArray addObjectsFromArray:[MusicDBManager.defaultManager DBQuery_Media_NotTag]];
    
    [self.errorDataArray removeAllObjects];
    NSArray *arrayM = [MusicDBManager.defaultManager DBQuery_Media_All];
    for (NSDictionary *info in arrayM) {
        NSString *identifier = [info kk_validStringForKey:Table_Media_identifier];
        NSString *filePath = [KKFileCacheManager cacheDataPath:identifier];
        long long fileSize = [NSFileManager kk_fileSizeAtPath:filePath];
        if (fileSize<(1024*2)) {
            [self.errorDataArray addObject:info];
        }
    }
    
    [self.table reloadData];
}

#pragma mark ==================================================
#pragma mark == Event
#pragma mark ==================================================
- (void)navAddTagButtonClicked{
    KKWeakSelf(self);
    KKAlertButtonConfig *leftConfig = [KKAlertButtonConfig cancelConfig];
    KKAlertButtonConfig *rightConfig = [KKAlertButtonConfig okConfig];
    rightConfig.actionBlock = ^(NSString *text) {
        BOOL result = [MusicDBManager.defaultManager DBInsert_Tag_Name:text];
        if (result) {
            [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"添加成功" image:nil alignment:KKToastViewAlignment_Center];
            [weakself reloadDatasource];
        }
        else{
            [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"添加失败" image:nil alignment:KKToastViewAlignment_Center];
        }
    };

    [KKAlertInputController showWithTitle:@"新建标签" subTitle:nil inputPlaceholder:nil initText:nil leftConfig:leftConfig rightConfig:rightConfig];
}

- (void)navSearchButtonClicked{
    MusicSearchViewController *viewController = [[MusicSearchViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.kk_viewController.navigationController presentViewController:viewController animated:YES completion:^{
        
    }];
}

- (void)navSettingButtonClicked{
    MusicSettingViewController *viewController = [[MusicSettingViewController alloc] init];
//    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.kk_viewController.navigationController presentViewController:viewController animated:YES completion:^{
        
    }];
}

#pragma mark ========================================
#pragma mark ==UITableView
#pragma mark ========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        NSInteger count = 1;
        if (self.noTagArray.count>0) {
            count = count + 1;
        }
        if (self.errorDataArray.count>0) {
            count = count + 1;
        }
        return count;
    }
    else{
        return [self.dataSource count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 30;
    }
    else{
        return 30;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 30)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, KKScreenWidth-30, 14)];
        label.font = [UIFont systemFontOfSize:12];
        label.text = @"全部歌曲";
        [view addSubview:label];
        view.backgroundColor = [UIColor kk_colorWithHexString:@"#E5E5E5"];
        return view;
    }
    else{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 30)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, KKScreenWidth-30, 14)];
        label.font = [UIFont systemFontOfSize:12];
        label.text = @"我的标签";
        [view addSubview:label];
        view.backgroundColor = [UIColor kk_colorWithHexString:@"#E5E5E5"];
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
    return TagCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        static NSString *cellIdentifier1=@"cellIdentifier1";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (!cell) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            cell.accessoryType=UITableViewCellAccessoryNone;
            
            CGSize size = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:17]];
            
            UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (TagCellHeight-size.height)/2.0, KKApplicationWidth-30, size.height)];
            mainLabel.tag = 199801;
            mainLabel.textColor = [UIColor blackColor];
            mainLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:mainLabel];
        }
        
        UILabel *mainLabel = (UILabel*)[cell viewWithTag:199801];
        if (indexPath.row==0) {
            NSString *count = [NSString stringWithFormat:@"(%ld)",[MusicDBManager.defaultManager DBQuery_Media_All].count];
            NSString *maintext = [NSString stringWithFormat:@"全部歌曲 %@",count];
            mainLabel.text = maintext;
            [mainLabel kk_setTextColor:[UIColor kk_colorWithHexString:@"#E5E5E5"] contentString:count];
        }
        else if (indexPath.row==1){
            if (self.noTagArray.count>0) {
                NSString *count = [NSString stringWithFormat:@"(%ld)",self.noTagArray.count];
                NSString *maintext = [NSString stringWithFormat:@"未分类歌曲 %@",count];
                mainLabel.text = maintext;
                [mainLabel kk_setTextColor:[UIColor kk_colorWithHexString:@"#E5E5E5"] contentString:count];
            }
            else{
                NSString *count = [NSString stringWithFormat:@"(%ld)",self.errorDataArray.count];
                NSString *maintext = [NSString stringWithFormat:@"异常歌曲 %@",count];
                mainLabel.text = maintext;
                [mainLabel kk_setTextColor:[UIColor kk_colorWithHexString:@"#E5E5E5"] contentString:count];
            }
        }
        else {
            NSString *count = [NSString stringWithFormat:@"(%ld)",self.errorDataArray.count];
            NSString *maintext = [NSString stringWithFormat:@"异常歌曲 %@",count];
            mainLabel.text = maintext;
            [mainLabel kk_setTextColor:[UIColor kk_colorWithHexString:@"#E5E5E5"] contentString:count];
        }
        return cell;
    }
    else{
        static NSString *cellIdentifier=@"cellIdentifier";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.accessoryType=UITableViewCellAccessoryNone;
            
            CGSize size = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:17]];
            
            UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (TagCellHeight-size.height)/2.0, KKApplicationWidth-30, size.height)];
            mainLabel.tag = 1102;
            mainLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:mainLabel];
        }
        
        UILabel *mainLabel = (UILabel*)[cell viewWithTag:1102];

        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *tag_name = [info kk_validStringForKey:Table_Tag_tag_name];
        NSString *tag_id = [info kk_validStringForKey:Table_Tag_tag_id];

        NSString *count = [NSString stringWithFormat:@"(%ld)",[MusicDBManager.defaultManager DBQuery_Media_WithTagId:tag_id].count];
        NSString *maintext = [NSString stringWithFormat:@"%@ %@",tag_name,count];
        mainLabel.text = maintext;
        [mainLabel kk_setTextColor:[UIColor kk_colorWithHexString:@"#E5E5E5"] contentString:count];
        
        return cell;

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            NSArray *array = [MusicDBManager.defaultManager DBQuery_Media_All];
            MusicDataListViewController *viewController = [[MusicDataListViewController alloc] initMusicDataListType:MusicDataListType_All dataArray:array];
            [self.kk_viewController.navigationController pushViewController:viewController animated:YES];
        }
        else if (indexPath.row==1){
            //未分类歌曲
            if (self.noTagArray.count>0) {
                MusicDataListViewController *viewController = [[MusicDataListViewController alloc] initMusicDataListType:MusicDataListType_NoTag dataArray:self.noTagArray];
                [self.kk_viewController.navigationController pushViewController:viewController animated:YES];
            }
            // 异常歌曲
            else{
                MusicDataListViewController *viewController = [[MusicDataListViewController alloc] initMusicDataListType:MusicDataListType_Error dataArray:self.errorDataArray];
                [self.kk_viewController.navigationController pushViewController:viewController animated:YES];
            }
        }
        // 异常歌曲
        else {
            MusicDataListViewController *viewController = [[MusicDataListViewController alloc] initMusicDataListType:MusicDataListType_Error dataArray:self.errorDataArray];
            [self.kk_viewController.navigationController pushViewController:viewController animated:YES];
        }
    }
    else{
        MusicDataListViewController *viewController = [[MusicDataListViewController alloc] initWithTagInfo:[self.dataSource objectAtIndex:indexPath.row]];
        [self.kk_viewController.navigationController pushViewController:viewController animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section!=0) {
        return YES;
    }
    else{
        return NO;
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KKWeakSelf(self);
    //删除
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSDictionary *info = [weakself.dataSource objectAtIndex:indexPath.row];
        NSString *tag_name = [info kk_validStringForKey:Table_Tag_tag_name];
        NSString *tag_id = [info kk_validStringForKey:Table_Tag_tag_id];

        //删除Tag表
        [MusicDBManager.defaultManager DBDelete_Tag_WithName:tag_name];
        //删除音乐-Tag关系表
        [MusicDBManager.defaultManager DBDelete_MediaTag_WithTagId:tag_id];
        
        completionHandler (YES);
        
        [weakself reloadDatasource];
    }];
    deleteRowAction.backgroundColor = [UIColor kk_colorWithHexString:@"#FF4646"];
    
    //修改
    UIContextualAction *editRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"修改" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSDictionary *info = [weakself.dataSource objectAtIndex:indexPath.row];
        NSString *tag_name = [info kk_validStringForKey:Table_Tag_tag_name];
        NSString *tag_id = [info kk_validStringForKey:Table_Tag_tag_id];
        
        KKAlertButtonConfig *leftConfig = [KKAlertButtonConfig cancelConfig];
        KKAlertButtonConfig *rightConfig = [KKAlertButtonConfig okConfig];
        rightConfig.actionBlock = ^(NSString *text) {
            BOOL result = [MusicDBManager.defaultManager DBUpdate_Tag_WithName:text tagId:tag_id];
            if (result) {
                [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"修改成功" image:nil alignment:KKToastViewAlignment_Center];
                [weakself reloadDatasource];
            }
            else{
                [KKToastView showInView:[UIWindow kk_currentKeyWindow] text:@"修改失败" image:nil alignment:KKToastViewAlignment_Center];
            }
        };
        [KKAlertInputController showWithTitle:@"编辑标签" subTitle:nil inputPlaceholder:nil initText:tag_name leftConfig:leftConfig rightConfig:rightConfig];

        completionHandler (YES);
        
    }];
    editRowAction.backgroundColor = [UIColor kk_colorWithHexString:@"#53A0F4"];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[editRowAction,deleteRowAction]];
    return config;
}



@end

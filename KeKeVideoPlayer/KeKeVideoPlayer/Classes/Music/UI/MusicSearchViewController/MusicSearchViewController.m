//
//  MusicSearchViewController.m
//  Music
//
//  Created by edward lannister on 2022/08/09.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicSearchViewController.h"
#import "MusicCell.h"

@interface MusicSearchViewController ()<UITableViewDataSource,UITableViewDelegate,MusicNavigationBarViewDelegate>

@property (nonatomic , strong) MusicNavigationBarView *navBarView;
@property (nonatomic , strong) UITableView *table;
@property (nonatomic , strong) NSMutableArray *dataSource;

@end

@implementation MusicSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
}

- (void)initUI{
    self.dataSource = [[NSMutableArray alloc] init];

    self.navBarView = [[MusicNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKStatusBarAndNavBarHeight)];
    self.navBarView.delegate = self;
    [self.view addSubview:self.navBarView];
    [self.navBarView showTextField];
    [self.navBarView setNavRightButtonTitle:@"取消" titleColor:Theme_Color_999999 selector:@selector(navCancelButtonClicked) target:self];

    self.table = [UITableView kk_initWithFrame:CGRectMake(0, self.navBarView.kk_height, KKApplicationWidth, KKScreenHeight-self.navBarView.kk_height) style:UITableViewStyleGrouped delegate:self datasource:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    [self.view addSubview:self.table];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.1)];
    [self.table setTableHeaderView:header];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKSafeAreaBottomHeight)];
    [self.table setTableFooterView:footer];
    
    [self.view bringSubviewToFront:self.navBarView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navBarView.inputTextField becomeFirstResponder];
}

- (void)navCancelButtonClicked{
    [self viewControllerDismiss];
}

#pragma mark ==================================================
#pragma mark == MusicNavigationBarViewDelegate
#pragma mark ==================================================
- (BOOL)MusicNavigationBarView:(MusicNavigationBarView*)aBarView textField:(KKTextField*)aTextField textCanChangedToString:(NSString*)aText{
    if ([NSString kk_isStringEmpty:aText]) {
        [self.dataSource removeAllObjects];
        [self.table reloadData];
    }
    else{
        NSArray *array = [MusicDBManager.defaultManager DBQuery_Media_WithKeywords:aText];
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:array];
        [self.table reloadData];
    }
    return YES;
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
    [cell reloadWithInformation:info indexPath:indexPath];
    cell.name_Label.textColor = [UIColor blackColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];;
    [self kk_postNotification:NotificationName_MusicPlayerStartPlayMusicItem object:info];
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

        completionHandler (YES);
        
        [weakself.dataSource removeObject:info];
        [weakself.table reloadData];
    }];
    deleteRowAction.backgroundColor = [UIColor kk_colorWithHexString:@"#FF4646"];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
}


@end

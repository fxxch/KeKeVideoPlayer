//
//  FileDownloadListViewController.m
//  Demo
//
//  Created by liubo on 2021/10/18.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "FileDownloadListViewController.h"
#import "KKVideoPlayViewController.h"
#import "FileDownloadManager.h"
#import "KKSegmentView.h"

@interface FileDownloadListViewController ()<UITableViewDataSource,UITableViewDelegate,KKSegmentViewDelegate>

@property(nonatomic,strong)KKSegmentView *segmentView;
@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)NSMutableArray *dataSource;
@property(nonatomic,strong)UITableView *tableD;
@property(nonatomic,strong)NSMutableArray *dataSourceD;

@end

@implementation FileDownloadListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"下载的资源"];
    [self showNavigationDefaultBackButton_ForNavPopBack];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
}

- (void)initUI{

    [self kk_observeNotification:KKNotificationName_FileDownloadManager_Update selector:@selector(KKNotification_FileDownloadManager_Update:)];
    [self kk_observeNotification:KKNotificationName_FileDownloadManager_Progress selector:@selector(KKNotification_FileDownloadManager_Progress:)];

    self.dataSource = [[NSMutableArray alloc] init];
    NSArray *array = [[FileDownloadManager defaultManager] filesArray];
    [self.dataSource addObjectsFromArray:array];

    self.dataSourceD = [[NSMutableArray alloc] init];
    NSArray *arrayD = [[FileDownloadManager defaultManager] willDownloadFileArray];
    [self.dataSourceD addObjectsFromArray:arrayD];

    self.segmentView = [[KKSegmentView alloc] initWithFrame:CGRectMake(0, 0, KKApplicationWidth, 40)];
    self.segmentView.delegate = self;
    [self.view addSubview:self.segmentView];
    [self.segmentView selectedIndex:0 needRespondsDelegate:NO];
    
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, KKApplicationWidth, KKApplicationHeight-KKNavigationBarHeight-40) style:UITableViewStylePlain];
    self.table.backgroundColor = [UIColor clearColor];
    self.table.backgroundView.backgroundColor = [UIColor clearColor];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    self.table.backgroundView = nil;
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
    self.tableD = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, KKApplicationWidth, KKApplicationHeight-KKNavigationBarHeight-40) style:UITableViewStylePlain];
    self.tableD.backgroundColor = [UIColor clearColor];
    self.tableD.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableD.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableD.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    self.tableD.backgroundView = nil;
    self.tableD.delegate = self;
    self.tableD.dataSource = self;
    [self.view addSubview:self.tableD];
    self.tableD.hidden = YES;
}

/**
 有多少个按钮
 */
- (NSInteger)KKSegmentView_NumberOfButtons:(KKSegmentView*)aSegmentView{
    return 2;
}

- (KKButton*)KKSegmentView:(KKSegmentView*)aSegmentView
            buttonForIndex:(NSInteger)aIndex{
    if (aIndex==0) {
        KKButton *aButton = [[KKButton alloc] initWithFrame:CGRectMake(0,0, KKScreenWidth/2.0, 40) type:KKButtonType_ImgLeftTitleRight_Center];
        aButton.imageViewSize = CGSizeMake(0, 0);
        aButton.spaceBetweenImgTitle = 0;
        aButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [aButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [aButton setTitle:@"已下载" forState:UIControlStateNormal];
        [aButton setTitle:@"已下载" forState:UIControlStateNormal];
        return aButton;
    }
    else{
        KKButton *aButton = [[KKButton alloc] initWithFrame:CGRectMake(KKScreenWidth/2.0,0, KKScreenWidth/2.0, 40) type:KKButtonType_ImgLeftTitleRight_Center];
        aButton.imageViewSize = CGSizeMake(0, 0);
        aButton.spaceBetweenImgTitle = 0;
        aButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [aButton setTitle:@"下载中" forState:UIControlStateNormal];
        [aButton setTitle:@"下载中" forState:UIControlStateNormal];
        return aButton;
    }
}

/*
 选中了新的Button
 */
- (void)KKSegmentView:(KKSegmentView*)aSegementView
    willDeselectIndex:(NSInteger)aOldIndex
   willSelectNewIndex:(NSInteger)aNewIndex{
    
    KKButton *btn0 = [aSegementView buttonAtIndex:aOldIndex];
    [btn0 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    KKButton *btn1 = [aSegementView buttonAtIndex:aNewIndex];
    [btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    if (aNewIndex==0) {
        self.table.hidden = NO;
        self.tableD.hidden = YES;
    }
    else{
        self.table.hidden = YES;
        self.tableD.hidden = NO;
    }
}

#pragma mark ==================================================
#pragma mark == 通知
#pragma mark ==================================================
- (void)KKNotification_FileDownloadManager_Update:(NSNotification*)notice{
    [self.dataSource removeAllObjects];
    NSArray *array = [[FileDownloadManager defaultManager] filesArray];
    [self.dataSource addObjectsFromArray:array];
    [self.table reloadData];
    
    [self.dataSourceD removeAllObjects];
    NSArray *arrayD = [[FileDownloadManager defaultManager] willDownloadFileArray];
    [self.dataSourceD addObjectsFromArray:arrayD];
    [self.tableD reloadData];
}

- (void)KKNotification_FileDownloadManager_Progress:(NSNotification*)notice{
    [self.dataSourceD removeAllObjects];
    NSArray *array = [[FileDownloadManager defaultManager] willDownloadFileArray];
    [self.dataSourceD addObjectsFromArray:array];
    [self.tableD reloadData];
}

#pragma mark ========================================
#pragma mark ==UITableView
#pragma mark ========================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==self.table) {
        return [self.dataSource count];
    }
    else{
        return [self.dataSourceD count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.table) {
        return 60;
    }
    else{
        CGSize sizeM = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:16]];
                
        CGSize sizeS = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:12]];

        return 10+sizeM.height+5+sizeS.height+10;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView==self.table) {
        static NSString *cellIdentifier=@"cellIdentifier";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundView.backgroundColor = [UIColor clearColor];
            
            CGSize sizeM = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:16]];
            
            UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (60-sizeM.height)/2.0, KKApplicationWidth-30, sizeM.height)];
            mainLabel.tag = 199501;
            mainLabel.font = [UIFont systemFontOfSize:16];
            mainLabel.numberOfLines = 0;
            mainLabel.backgroundColor = [UIColor clearColor];
            [cell addSubview:mainLabel];
        }
        
        FileInfo *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *url = info.url;
        NSString *title = [url lastPathComponent];
        
        UILabel *mainLabel = (UILabel*)[cell viewWithTag:199501];
        CGSize size = [title kk_sizeWithFont:[UIFont systemFontOfSize:16] maxWidth:KKApplicationWidth-30];
        mainLabel.text = title;
        if (size.height>30) {
            mainLabel.frame = CGRectMake(15, 10, KKApplicationWidth-30, 40);
        }
        else{
            mainLabel.frame = CGRectMake(15, (60-size.height)/2.0, KKApplicationWidth-30, size.height);
        }
        
        return cell;
    }
    else{
        static NSString *cellIdentifierD=@"cellIdentifierD";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierD];
        if (!cell) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierD];
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundView.backgroundColor = [UIColor clearColor];

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
        
        FileInfo *info = [self.dataSourceD objectAtIndex:indexPath.row];;
        NSString *url = info.url;
        NSString *title = [url lastPathComponent];
        
        UILabel *mainLabel = (UILabel*)[cell viewWithTag:2201];
        UILabel *subLabel = (UILabel*)[cell viewWithTag:2202];
        mainLabel.text = title;
        subLabel.text = [NSString stringWithFormat:@"%@        %@",info.progress,info.byteString];
        
        return cell;

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView==self.table) {
        FileInfo *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *url = info.url;
        NSString *filePath = [KKFileCacheManager cacheDataPath:url];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            KKVideoPlayViewController *viewController = [[KKVideoPlayViewController alloc] initWitFilePath:filePath fileName:url.lastPathComponent];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

//左滑编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.table==tableView) {
        return UITableViewCellEditingStyleDelete;
    }
    else{
        return UITableViewCellEditingStyleNone;
    }
}
// 进编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.table==tableView) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            FileInfo *info = [self.dataSource objectAtIndex:indexPath.row];
            NSString *url = info.url;
            [[FileDownloadManager defaultManager] deleteFileWithURL:url];
        }
    }
    else{
        
    }

}
// 左滑编辑上面的文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.table==tableView) {
        return @"删除";
    }
    else{
        return nil;
    }
}
//指定可删除的row
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.table==tableView) {
        return YES;
    }
    else{
        return NO;
    }
}

//#pragma mark 也可以使用 IOS11之后
//- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //删除
//    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        //左滑删除之后数据处理操作
//    }];
//    deleteRowAction.image = [UIImage imageNamed:@"ceshi.png"];//给删除赋值图片
//    deleteRowAction.backgroundColor = [UIColor grayColor];//删除背景颜色
//    UISwipeActionsConfiguration *Configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
//    return Configuration;
//}


@end

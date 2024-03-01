//
//  EnglishVideoListViewController.m
//  English
//
//  Created by edward lannister on 2024/03/01.
//  Copyright © 2024 KeKeStudio. All rights reserved.
//

#import "EnglishVideoListViewController.h"
#import "KKVideoPlayViewController.h"

@interface EnglishVideoListViewController ()
<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)NSArray *dataSource;
@property (nonatomic , copy) NSString *navTitle;

@end

@implementation EnglishVideoListViewController

- (instancetype)initWithFileNames:(NSArray*)aArray title:(NSString*)aTitle
{
    self = [super init];
    if (self) {
        self.dataSource = aArray;
        self.navTitle = aTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.navTitle;
    [self showNavigationDefaultBackButton_ForNavPopBack];
    
    [self initUI];
}

- (void)initUI{
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKScreenHeight-KKStatusBarAndNavBarHeight) style:UITableViewStyleGrouped];
    self.table.backgroundColor = [UIColor clearColor];
    self.table.backgroundView.backgroundColor = [UIColor clearColor];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
    [self.table setTableHeaderView:[UIView new]];
    [self.table setTableFooterView:[UIView new]];
}


#pragma mark ==================================================
#pragma mark == UITableViewDelegate
#pragma mark ==================================================
/* heightForRow */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (KKScreenWidth - 45)/2.0;
    CGFloat height = width*932/1240;
    return height + 30;
}

/* Header Height */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

/* Header View */
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

/* Footer Height */
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

/* Footer View */
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}

/* didSelectRow */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark ==================================================
#pragma mark == UITableViewDataSource
#pragma mark ==================================================
/* numberOfSections */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

/* numberOfRowsInSection */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSource.count%2==0) {
        return self.dataSource.count/2;
    } else {
        return self.dataSource.count/2 + 1;
    }
}

/* cellForRowAtIndexPath */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        CGFloat width = (KKScreenWidth - 45)/2.0;
        CGFloat height = width*932/1240;

        UIButton *button01 = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, width, height)];
        [button01 addTarget:self action:@selector(cellItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button01.imageView.contentMode = UIViewContentModeScaleAspectFill;
        button01.tag = 199301;
        [cell.contentView addSubview:button01];
        UIView *backview01 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, button01.kk_width, 20)];
        backview01.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [button01 addSubview:backview01];
        UILabel *label1 = [[UILabel alloc] initWithFrame:backview01.frame];
        label1.textColor = [UIColor whiteColor];
        label1.font = [UIFont systemFontOfSize:14];
        label1.tag = 2024030201;
        label1.adjustsFontSizeToFitWidth = YES;
        [button01 addSubview:label1];

        UIButton *button02 = [[UIButton alloc] initWithFrame:CGRectMake(button01.kk_right+15, 15, width, height)];
        button02.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button02 addTarget:self action:@selector(cellItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button02.tag = 199302;
        [cell.contentView addSubview:button02];
        UIView *backview02 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, button01.kk_width, 20)];
        backview02.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [button02 addSubview:backview02];
        UILabel *label2 = [[UILabel alloc] initWithFrame:backview02.frame];
        label2.textColor = [UIColor whiteColor];
        label2.font = [UIFont systemFontOfSize:14];
        label2.tag = 2024030201;
        label2.adjustsFontSizeToFitWidth = YES;
        [button02 addSubview:label2];

    }
        
    UIButton *button01 = [cell.contentView viewWithTag:199301];
    NSInteger index1 = indexPath.row*2 + 0;
    if (index1<self.dataSource.count) {
        [self setButtonBackgroundImage:button01 index:index1];
        button01.hidden = NO;
    } else {
        button01.hidden = YES;
    }
    button01.kk_tagInfo = [self.dataSource kk_objectAtIndex_Safe:index1];
    UILabel *label1 = [button01 viewWithTag:2024030201];
    NSString * title1 = [self.dataSource kk_objectAtIndex_Safe:index1];
    label1.text = [title1 kk_substringFromIndex_Safe:8];
    
    UIButton *button02 = [cell.contentView viewWithTag:199302];
    NSInteger index2 = indexPath.row*2 + 1;
    if (index2<self.dataSource.count) {
        [self setButtonBackgroundImage:button02 index:index2];
        button01.hidden = NO;
    } else {
        button01.hidden = YES;
    }
    button02.kk_tagInfo = [self.dataSource kk_objectAtIndex_Safe:index2];
    UILabel *label2 = [button02 viewWithTag:2024030201];
    NSString * title2 = [self.dataSource kk_objectAtIndex_Safe:index2];
    label2.text = [title2 kk_substringFromIndex_Safe:8];

    return cell;
}

- (void)setButtonBackgroundImage:(UIButton*)aButton index:(NSInteger)aIndex{
    // 为了防止界面卡住，可以异步执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *fileName = [self.dataSource kk_objectAtIndex_Safe:aIndex];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        UIImage *image = [NSFileManager kk_getVideoPreViewImageWithURL:fileURL];
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [aButton setBackgroundImage:image forState:UIControlStateNormal];
        });
    });
    
}

- (void)cellItemButtonClicked:(UIButton*)aButton{
    NSString *fileName = aButton.kk_tagInfo;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    KKVideoPlayViewController *viewController = [[KKVideoPlayViewController alloc] initWitFilePath:[fileURL absoluteString] fileName:fileName];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark ****************************************
#pragma mark 屏幕方向
#pragma mark ****************************************
//1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate {
    return NO;
}

//2.返回支持的旋转方向（当前viewcontroller支持哪些转屏方向）
//iPad设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
//iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

//3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end

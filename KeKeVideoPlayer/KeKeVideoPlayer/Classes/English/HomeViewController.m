//
//  HomeViewController.m
//  English
//
//  Created by liubo on 2021/4/29.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "HomeViewController.h"
#import "EnglishVideoListViewController.h"

@interface HomeViewController ()
<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic , assign) NSInteger bookCount;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"英语视频";
    
    [self initUI];
}

- (void)initUI{
    self.dataSource = [[NSMutableArray alloc] init];
    
    NSArray *array1_1 = [NSArray arrayWithObjects:
                         @"Grade11_Module_01_Unit_1_Activity_1.mp4",
                         @"Grade11_Module_01_Unit_1_Activity_2.mp4",
                         @"Grade11_Module_01_Unit_2_Activity_1.mp4",
                         @"Grade11_Module_01_Unit_2_Activity_2.mp4",
                         @"Grade11_Module_01_Unit_3_Song.mp4",
                         @"Grade11_Module_01_Unit_4_Words.mp4",
                         @"Grade11_Module_02_Unit_1_Activity_1.mp4",
                         @"Grade11_Module_02_Unit_1_Activity_2.mp4",
                         @"Grade11_Module_02_Unit_2_Activity_1.mp4",
                         @"Grade11_Module_02_Unit_2_Activity_2.mp4",
                         @"Grade11_Module_02_Unit_3_Song.mp4",
                         @"Grade11_Module_02_Unit_4_Words.mp4",
                         @"Grade11_Module_03_Unit_1_Activity_1.mp4",
                         @"Grade11_Module_03_Unit_1_Activity_2.mp4",
                         @"Grade11_Module_03_Unit_2_Activity_1.mp4",
                         @"Grade11_Module_03_Unit_2_Activity_2.mp4",
                         @"Grade11_Module_03_Unit_3_Song.mp4",
                         @"Grade11_Module_03_Unit_4_Words.mp4",
                         @"Grade11_Module_04_Unit_1_Activity_1.mp4",
                         @"Grade11_Module_04_Unit_1_Activity_2.mp4",
                         @"Grade11_Module_04_Unit_2_Activity_1.mp4",
                         @"Grade11_Module_04_Unit_2_Activity_2.mp4",
                         @"Grade11_Module_04_Unit_3_Song.mp4",
                         @"Grade11_Module_04_Unit_4_Words.mp4",
                         @"Grade11_Module_05_Unit_1_Activity_1.mp4",
                         @"Grade11_Module_05_Unit_1_Activity_2.mp4",
                         @"Grade11_Module_05_Unit_2_Activity_1.mp4",
                         @"Grade11_Module_05_Unit_2_Activity_2.mp4",
                         @"Grade11_Module_05_Unit_3_Song.mp4",
                         @"Grade11_Module_05_Unit_4_Words.mp4",
                         @"Grade11_Module_06_Unit_1_Activity_1.mp4",
                         @"Grade11_Module_06_Unit_1_Activity_2.mp4",
                         @"Grade11_Module_06_Unit_2_Activity_1.mp4",
                         @"Grade11_Module_06_Unit_2_Activity_2.mp4",
                         @"Grade11_Module_06_Unit_3_Song.mp4",
                         @"Grade11_Module_06_Unit_4_Words.mp4",
                         @"Grade11_Module_07_Unit_1_Activity_1.mp4",
                         @"Grade11_Module_07_Unit_1_Activity_2.mp4",
                         @"Grade11_Module_07_Unit_2_Activity_1.mp4",
                         @"Grade11_Module_07_Unit_2_Activity_2.mp4",
                         @"Grade11_Module_07_Unit_3_Song.mp4",
                         @"Grade11_Module_07_Unit_4_Words.mp4",
                         @"Grade11_Module_08_Unit_1_Activity_1.mp4",
                         @"Grade11_Module_08_Unit_1_Activity_2.mp4",
                         @"Grade11_Module_08_Unit_2_Activity_1.mp4",
                         @"Grade11_Module_08_Unit_2_Activity_2.mp4",
                         @"Grade11_Module_08_Unit_3_Song.mp4",
                         @"Grade11_Module_08_Unit_4_Words.mp4",
                         @"Grade11_Module_09_Unit_1_Activity_1.mp4",
                         @"Grade11_Module_09_Unit_1_Activity_2.mp4",
                         @"Grade11_Module_09_Unit_2_Activity_1.mp4",
                         @"Grade11_Module_09_Unit_2_Activity_2.mp4",
                         @"Grade11_Module_09_Unit_3_Song.mp4",
                         @"Grade11_Module_09_Unit_4_Words.mp4",
                         @"Grade11_Module_10_Unit_1_Activity_1.mp4",
                         @"Grade11_Module_10_Unit_1_Activity_2.mp4",
                         @"Grade11_Module_10_Unit_2_Activity_1.mp4",
                         @"Grade11_Module_10_Unit_2_Activity_2.mp4",
                         @"Grade11_Module_10_Unit_3_Song.mp4",
                         @"Grade11_Module_10_Unit_4_Words.mp4",
                         nil];
    [self.dataSource addObject:array1_1];

    NSArray *array1_2 = [NSArray arrayWithObjects:
                         @"Grade12_Module_01_Unit_1_Activity_1.MP4",
                         @"Grade12_Module_01_Unit_1_Activity_2.MP4",
                         @"Grade12_Module_01_Unit_2_Activity_1.MP4",
                         @"Grade12_Module_01_Unit_2_Activity_2.MP4",
                         @"Grade12_Module_01_Unit_2_Activity_4.MP4",
                         @"Grade12_Module_02_Unit_1_Activity_1.MP4",
                         @"Grade12_Module_02_Unit_1_Activity_2.MP4",
                         @"Grade12_Module_02_Unit_2_Activity_1.MP4",
                         @"Grade12_Module_02_Unit_2_Activity_2.MP4",
                         @"Grade12_Module_02_Unit_2_Activity_4.MP4",
                         @"Grade12_Module_03_Unit_1_Activity_1.MP4",
                         @"Grade12_Module_03_Unit_1_Activity_2.MP4",
                         @"Grade12_Module_03_Unit_2_Activity_1.MP4",
                         @"Grade12_Module_03_Unit_2_Activity_2.MP4",
                         @"Grade12_Module_03_Unit_2_Activity_4.MP4",
                         @"Grade12_Module_04_Unit_1_Activity_1.MP4",
                         @"Grade12_Module_04_Unit_1_Activity_2.MP4",
                         @"Grade12_Module_04_Unit_2_Activity_1.MP4",
                         @"Grade12_Module_04_Unit_2_Activity_2.MP4",
                         @"Grade12_Module_04_Unit_2_Activity_4.MP4",
                         @"Grade12_Module_05_Unit_1_Activity_1.MP4",
                         @"Grade12_Module_05_Unit_1_Activity_2.MP4",
                         @"Grade12_Module_05_Unit_2_Activity_1.MP4",
                         @"Grade12_Module_05_Unit_2_Activity_2.MP4",
                         @"Grade12_Module_05_Unit_2_Activity_4.MP4",
                         @"Grade12_Module_06_Unit_1_Activity_1.MP4",
                         @"Grade12_Module_06_Unit_1_Activity_2.MP4",
                         @"Grade12_Module_06_Unit_2_Activity_1.MP4",
                         @"Grade12_Module_06_Unit_2_Activity_2.MP4",
                         @"Grade12_Module_06_Unit_2_Activity_4.MP4",
                         @"Grade12_Module_07_Unit_1_Activity_1.MP4",
                         @"Grade12_Module_07_Unit_1_Activity_2.MP4",
                         @"Grade12_Module_07_Unit_2_Activity_1.MP4",
                         @"Grade12_Module_07_Unit_2_Activity_2.MP4",
                         @"Grade12_Module_07_Unit_2_Activity_4.MP4",
                         @"Grade12_Module_08_Unit_1_Activity_1.MP4",
                         @"Grade12_Module_08_Unit_1_Activity_2.MP4",
                         @"Grade12_Module_08_Unit_2_Activity_1.MP4",
                         @"Grade12_Module_08_Unit_2_Activity_2.MP4",
                         @"Grade12_Module_08_Unit_2_Activity_4.MP4",
                         @"Grade12_Module_09_Unit_1_Activity_1.MP4",
                         @"Grade12_Module_09_Unit_1_Activity_2.MP4",
                         @"Grade12_Module_09_Unit_2_Activity_1.MP4",
                         @"Grade12_Module_09_Unit_2_Activity_2.MP4",
                         @"Grade12_Module_09_Unit_2_Activity_4.MP4",
                         @"Grade12_Module_10_Unit_1_Activity_1.MP4",
                         @"Grade12_Module_10_Unit_1_Activity_2.MP4",
                         @"Grade12_Module_10_Unit_2_Activity_1.MP4",
                         @"Grade12_Module_10_Unit_2_Activity_2.MP4",
                         @"Grade12_Module_10_Unit_2_Activity_4.MP4",
                         nil];
    [self.dataSource addObject:array1_2];
    self.bookCount = [self.dataSource count];

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
    CGFloat height = width*1473/1047;
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
    if (self.bookCount%2==0) {
        return self.bookCount/2;
    } else {
        return self.bookCount/2 + 1;
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
        CGFloat height = width*1473/1047;

        UIButton *button01 = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, width, height)];
        [button01 addTarget:self action:@selector(cellItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button01.imageView.contentMode = UIViewContentModeScaleAspectFill;
        button01.tag = 199301;
        [cell.contentView addSubview:button01];

        UIButton *button02 = [[UIButton alloc] initWithFrame:CGRectMake(button01.kk_right+15, 15, width, height)];
        button02.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button02 addTarget:self action:@selector(cellItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button02.tag = 199302;
        [cell.contentView addSubview:button02];
    }
        
    UIButton *button01 = [cell.contentView viewWithTag:199301];
    NSInteger index1 = indexPath.row*2 + 0;
    if (index1<self.bookCount) {
        [self setButtonBackgroundImage:button01 index:index1];
        button01.hidden = NO;
    } else {
        button01.hidden = YES;
    }
    button01.kk_tagInfo = [NSString kk_stringWithInteger:index1];

    UIButton *button02 = [cell.contentView viewWithTag:199302];
    NSInteger index2 = indexPath.row*2 + 1;
    if (index2<self.bookCount) {
        [self setButtonBackgroundImage:button02 index:index2];
        button01.hidden = NO;
    } else {
        button01.hidden = YES;
    }
    button02.kk_tagInfo = [NSString kk_stringWithInteger:index2];
    
    return cell;
}

- (void)setButtonBackgroundImage:(UIButton*)aButton index:(NSInteger)aIndex{
    
    switch (aIndex) {
        case 0:{
            NSString *fileName = @"Grade1_1.png";
            NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            [aButton setBackgroundImage:image forState:UIControlStateNormal];
            break;
        }
        case 1:{
            NSString *fileName = @"Grade1_2.png";
            NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            [aButton setBackgroundImage:image forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    
}

- (void)cellItemButtonClicked:(UIButton*)aButton{
    NSInteger aIndex = [aButton.kk_tagInfo integerValue];
    NSArray *array = [self.dataSource kk_objectAtIndex_Safe:aIndex];
    switch (aIndex) {
        case 0:{
            NSString *title = @"一年级上册";
            EnglishVideoListViewController *viewController = [[EnglishVideoListViewController alloc] initWithFileNames:array title:title];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case 1:{
            NSString *title = @"一年级下册";
            EnglishVideoListViewController *viewController = [[EnglishVideoListViewController alloc] initWithFileNames:array title:title];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        default:
            break;
    }
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

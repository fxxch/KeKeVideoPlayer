//
//  HomeViewController.m
//  English
//
//  Created by liubo on 2021/4/29.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "HomeViewController.h"
#import "KKVideoPlayViewController.h"
#import "AudioImageViewController.h"

@interface HomeViewController ()
<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)NSMutableArray *sectionTitleArray;
@property(nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"英语学习";
    
    [self initUI];
}

- (void)initUI{
    self.sectionTitleArray = [[NSMutableArray alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"EnglishFileSource.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    for (NSInteger i=[array count]-1; i>=0; i--) {
        NSArray *item = [array objectAtIndex_Safe:i];
        NSString *sectionName = [item objectAtIndex_Safe:0];

        NSMutableArray *arrayImage = [[NSMutableArray alloc] init];
        NSMutableArray *arrayMedia = [[NSMutableArray alloc] init];
        //现将文件名分类分组
        for (NSInteger j=1; j<[item count]; j++) {
            NSString *fileName = [item objectAtIndex_Safe:j];
            if ([NSFileManager isFileType_IMG:[fileName pathExtension]]) {
                [arrayImage addObject:fileName];
            }
            else if ([NSFileManager isFileType_AUDIO:[fileName pathExtension]]) {
                [arrayMedia addObject:fileName];
            }
            else if ([NSFileManager isFileType_VIDEO:[fileName pathExtension]]) {
                [arrayMedia addObject:fileName];
            }
            else{
                
            }
        }
        
        //根据多媒体组的元素个数，创建一个Section的元素个数
        NSMutableArray *arrayRowItems = [[NSMutableArray alloc] init];
        for (NSInteger n=0; n<[arrayMedia count]; n++) {
            NSString *fileName = [arrayMedia objectAtIndex:n];
            NSMutableDictionary *itemDic = [[NSMutableDictionary alloc] init];
            [itemDic setObject:arrayImage forKey:@"images"];
            [itemDic setObject:fileName forKey:@"fileName"];
            [arrayRowItems addObject:itemDic];
        }
        
        //组装section
        NSMutableDictionary *setionsInfo = [[NSMutableDictionary alloc] init];
        [setionsInfo setObject:arrayRowItems forKey:@"items"];
        [setionsInfo setObject:sectionName forKey:@"title"];
        [self.dataSource addObject:setionsInfo];
    }

    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKScreenHeight-KKStatusBarAndNavBarHeight) style:UITableViewStyleGrouped];
    self.table.backgroundColor = [UIColor colorWithHexString:@"#FB89BA"];
    self.table.backgroundView.backgroundColor = [UIColor colorWithHexString:@"#FB89BA"];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
    [self.table setTableHeaderView:[UIView new]];
    [self.table setTableFooterView:[UIView new]];
    //    [self.table setBorderColor:[UIColor redColor] width:3.0];
}


#pragma mark ==================================================
#pragma mark == UITableViewDelegate
#pragma mark ==================================================
/* heightForRow */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (KKScreenWidth - 240)/3.0;
    CGFloat height = width*4/3;
    return height + 30;
}

/* Header Height */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 75;
}

/* Header View */
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 75)];
    NSDictionary *dic = [self.dataSource objectAtIndex:section];
    NSString *title = [dic validStringForKey:@"title"];
    UILabel *label = [UILabel kk_initWithTextColor:[UIColor whiteColor] font:[UIFont boldSystemFontOfSize:28] text:title maxWidth:KKScreenWidth];
    label.frame = CGRectMake(60, (75-label.height)/2.0, label.width, label.height);
    [headerView addSubview:label];
    headerView.backgroundColor = [UIColor colorWithHexString:@"#7BBFEA"];
    return headerView;
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
    return [self.dataSource count];
}

/* numberOfRowsInSection */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic = [self.dataSource objectAtIndex:section];
    NSArray *array = [dic validArrayForKey:@"items"];
    if ([array count]%2==0) {
        return [array count]/2;
    }
    else{
        return [array count]/2+1;
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

        CGFloat width = (KKScreenWidth - 180)/2.0;
        CGFloat height = width*3/4;

        KKButton *button01 = [[KKButton alloc] initWithFrame:CGRectMake(60, 15, width, height) type:KKButtonType_ImgFull_TitleLeftCenter];
        button01.imageViewSize = CGSizeMake(width, height);
        button01.spaceBetweenImgTitle = 0;
        button01.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        button01.textLabel.font = [UIFont systemFontOfSize:16];
        [button01 addTarget:self action:@selector(cellItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button01.imageView.contentMode = UIViewContentModeScaleAspectFit;
        button01.tag = 1101;
        [cell.contentView addSubview:button01];
        [button01 setCornerRadius:8.0];

        KKButton *button02 = [[KKButton alloc] initWithFrame:CGRectMake(button01.right+60, 15, width, height) type:KKButtonType_ImgFull_TitleLeftCenter];
        button02.imageViewSize = CGSizeMake(width, height);
        button02.spaceBetweenImgTitle = 0;
        button02.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        button02.textLabel.font = [UIFont systemFontOfSize:16];
        button02.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button02 addTarget:self action:@selector(cellItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button02.tag = 1102;
        [cell.contentView addSubview:button02];
        [button02 setCornerRadius:8.0];
    }
    
    NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.section];
    NSArray *items = [dic validArrayForKey:@"items"];

    KKButton *button01 = [cell.contentView viewWithTag:1101];
    NSInteger index1 = indexPath.row*2 + 0;
    NSDictionary *info1 = [items objectAtIndex_Safe:index1];
    if (info1) {
        button01.hidden = NO;
        [self setItemWithDictionary:info1 button:button01];
    }
    else{
        button01.hidden = YES;
    }
    button01.tagInfo = info1;

    KKButton *button02 = [cell.contentView viewWithTag:1102];
    NSInteger index2 = indexPath.row*2 + 1;
    NSDictionary *info2 = [items objectAtIndex_Safe:index2];
    if (info2) {
        button02.hidden = NO;
        [self setItemWithDictionary:info2 button:button02];
    }
    else{
        button02.hidden = YES;
    }
    button02.tagInfo = info2;
    
    return cell;
}

- (void)setItemWithDictionary:(NSDictionary*)aDic button:(KKButton*)aButton{
    NSString *fileName = [aDic validStringForKey:@"fileName"];
    if ([NSFileManager isFileType_AUDIO:[fileName pathExtension]]) {
        NSArray *images = [aDic validArrayForKey:@"images"];
        NSString *imageName = [images firstObject];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        [aButton setImage:image title:nil titleColor:nil backgroundColor:[UIColor colorWithHexString:@"#FDD403"] forState:UIControlStateNormal];
    }
    else{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:filePath];

        // 为了防止界面卡住，可以异步执行
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            UIImage *image = [NSFileManager getVideoPreViewImageWithURL:url];

            //回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [aButton setImage:image title:nil titleColor:nil backgroundColor:[UIColor colorWithHexString:@"#FDD403"] forState:UIControlStateNormal];
            });

        });
    }
}

- (void)cellItemButtonClicked:(KKButton*)aButton{
    NSDictionary *aDic = aButton.tagInfo;
    NSString *fileName = [aDic validStringForKey:@"fileName"];
    if ([NSFileManager isFileType_AUDIO:[fileName pathExtension]]) {
        NSArray *images = [aDic validArrayForKey:@"images"];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:filePath];

        AudioImageViewController *viewController = [[AudioImageViewController alloc] initWitAudioFilePath:[url absoluteString] imageNames:images fileName:fileName];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        KKVideoPlayViewController *viewController = [[KKVideoPlayViewController alloc] initWitFilePath:[url absoluteString] fileName:fileName];
        [self.navigationController pushViewController:viewController animated:YES];
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

//
//  HomeViewController.m
//  Japanese
//
//  Created by liubo on 2021/4/26.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "HomeViewController.h"
#import "KKVideoPlayViewController.h"

@interface HomeViewController ()
<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"中日标准日本语【初级】";
    
    [self initUI];
}

- (void)initUI{
    self.dataSource = [[NSMutableArray alloc] init];
    
    NSString *fileName0 = @"JapaneseA001.wmv";
    NSString *filePath0 = [[NSBundle mainBundle] pathForResource:fileName0 ofType:nil];
    NSDictionary *fileDictionary0 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     fileName0,@"name",
                                     @"入门单元01",@"displayName",
                                     filePath0,@"path",
                                     nil];
    [self.dataSource addObject:fileDictionary0];
    
    NSString *fileName1 = @"JapaneseA002.wmv";
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:fileName1 ofType:nil];
    NSDictionary *fileDictionary1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     fileName1,@"name",
                                     @"入门单元02",@"displayName",
                                     filePath1,@"path",
                                     nil];
    [self.dataSource addObject:fileDictionary1];
    
    
    for (NSInteger i=1; i<=48; i++) {
        NSString *fileName = [NSString stringWithFormat:@"JapaneseA%02d.wmv",(int)i];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSString *displayName = [NSString stringWithFormat:@"第 %02d 课",(int)i];
            NSDictionary *fileDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                            fileName,@"name",
                                            displayName,@"displayName",
                                            filePath,@"path",
                                            nil];
            [self.dataSource addObject:fileDictionary];
        }
    }
    
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKScreenHeight-KKStatusBarAndNavBarHeight) style:UITableViewStylePlain];
    self.table.backgroundColor = [UIColor clearColor];
    self.table.backgroundView.backgroundColor = [UIColor clearColor];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    self.table.backgroundView = nil;
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
//    [self.table setBorderColor:[UIColor redColor] width:3.0];
}


#pragma mark ==================================================
#pragma mark == UITableViewDelegate
#pragma mark ==================================================
/* heightForRow */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

/* Header Height */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

/* Header View */
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] init];
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
    
    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
    NSString *fileName = [info validStringForKey:@"name"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    KKVideoPlayViewController *viewController = [[KKVideoPlayViewController alloc] initWitFilePath:[url absoluteString] fileName:[filePath lastPathComponent]];
    [self.navigationController pushViewController:viewController animated:YES];
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
    return [self.dataSource count];
}

/* cellForRowAtIndexPath */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, KKScreenWidth-30, 20)];
        mainLabel.tag = 199201;
        [cell.contentView addSubview:mainLabel];
        
//        UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40, 100, 100)];
//        previewImageView.tag = 1102;
//        [cell.contentView addSubview:previewImageView];
    }
    
    NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
    UILabel *mainLabel = [cell.contentView viewWithTag:199201];
    mainLabel.text = [info validStringForKey:@"displayName"];
    
//    UIImageView *previewImageView = [cell.contentView viewWithTag:1102];
//    KKWeakSelf(self)
//    // 为了防止界面卡住，可以异步执行
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        NSDictionary *info = [weakself.dataSource objectAtIndex:indexPath.row];
//        NSString *fileName = [info validStringForKey:@"name"];
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
//        NSURL *url = [NSURL fileURLWithPath:filePath];
//        UIImage *image = [NSFileManager getVideoPreViewImageWithURL:url];
//
//        //回到主线程
//        dispatch_async(dispatch_get_main_queue(), ^{
//            previewImageView.image = image;
//        });
//
//    });

    return cell;
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

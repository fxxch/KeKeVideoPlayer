//
//  DemoLocalFilesListViewController.m
//  Demo
//
//  Created by liubo on 2021/4/27.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "DemoLocalFilesListViewController.h"
#import "KKVideoPlayViewController.h"

@interface DemoLocalFilesListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)NSMutableArray *dataSource;

@end

@implementation DemoLocalFilesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"本地资源"];
    [self showNavigationDefaultBackButton_ForNavPopBack];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
}

- (void)initUI{
    self.dataSource = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DemoLocalFileList.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    for (NSInteger i=0; i<[array count]; i++) {
        NSString *fileName = [array objectAtIndex:i];
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [self.dataSource addObject:fileName];
        }
    }

    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KKApplicationWidth, KKApplicationHeight-KKNavigationBarHeight) style:UITableViewStylePlain];
    self.table.backgroundColor = [UIColor clearColor];
    self.table.backgroundView.backgroundColor = [UIColor clearColor];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    self.table.backgroundView = nil;
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
}

#pragma mark ========================================
#pragma mark ==UITableView
#pragma mark ========================================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier=@"cellIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType=UITableViewCellAccessoryNone;
        
        CGSize size = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:17]];
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (60-size.height)/2.0, KKApplicationWidth-30, size.height)];
        mainLabel.tag = 199401;
        mainLabel.font = [UIFont systemFontOfSize:16];
        mainLabel.numberOfLines = 0;
        [cell addSubview:mainLabel];
    }
    
    NSString *title = [self.dataSource objectAtIndex:indexPath.row];
    
    UILabel *mainLabel = (UILabel*)[cell viewWithTag:199401];
    CGSize size = [title kk_sizeWithFont:[UIFont systemFontOfSize:16] maxWidth:KKApplicationWidth-30];
    mainLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    if (size.height>30) {
        mainLabel.frame = CGRectMake(15, 10, KKApplicationWidth-30, 40);
    }
    else{
        mainLabel.frame = CGRectMake(15, (60-size.height)/2.0, KKApplicationWidth-30, size.height);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *fileName = [self.dataSource objectAtIndex:indexPath.row];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        KKVideoPlayViewController *viewController = [[KKVideoPlayViewController alloc] initWitFilePath:[url absoluteString] fileName:[filePath lastPathComponent]];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end

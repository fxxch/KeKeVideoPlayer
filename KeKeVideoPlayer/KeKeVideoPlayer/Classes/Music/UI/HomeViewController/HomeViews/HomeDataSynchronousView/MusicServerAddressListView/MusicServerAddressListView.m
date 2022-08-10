//
//  MusicServerAddressListView.m
//  Music
//
//  Created by edward lannister on 2022/08/10.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicServerAddressListView.h"

@interface MusicServerAddressListView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , strong) UIButton *backButton;
@property (nonatomic , strong) UIButton *contentView;
@property (nonatomic , strong) UITableView *table;
@property (nonatomic , strong) NSArray *dataSource;

@property (nonatomic , copy) MusicServerAddressSelectFinishedBlock completeBlock;

@end


@implementation MusicServerAddressListView

#define kMusicServerAddressListViewTag (2022081099)

#pragma mark ==================================================
#pragma mark == 接口
#pragma mark ==================================================

+ (MusicServerAddressListView*_Nullable)showInView:(UIView*_Nullable)aView dataSource:(NSArray*)aArray finishedBlock:(MusicServerAddressSelectFinishedBlock _Nullable )finishedBlock{
    if ([aView viewWithTag:kMusicServerAddressListViewTag]) {
        return nil;
    }
    if ([NSArray kk_isArrayEmpty:aArray]) {
        return nil;
    }

    MusicServerAddressListView *pickerView = [[MusicServerAddressListView alloc] initWithFrame:aView.bounds dataSource:aArray finishedBlock:finishedBlock];
    pickerView.tag = kMusicServerAddressListViewTag;
    [aView addSubview:pickerView];
    [aView bringSubviewToFront:pickerView];

    [pickerView show];
    return pickerView;
}

#pragma mark ==================================================
#pragma mark == 初始化
#pragma mark ==================================================
- (id)initWithFrame:(CGRect)frame dataSource:(NSArray*)aArray finishedBlock:(MusicServerAddressSelectFinishedBlock)finishedBlock{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = aArray;
        self.completeBlock = finishedBlock;
        
        self.backButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.backButton.backgroundColor = [UIColor clearColor];
        [self.backButton addTarget:self action:@selector(singleTap) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.backButton];
        
        self.contentView = [[UIButton alloc] initWithFrame:CGRectMake(0, KKStatusBarAndNavBarHeight, self.frame.size.width, KKScreenHeight-KKStatusBarAndNavBarHeight-55-KKSafeAreaBottomHeight)];
        self.contentView.backgroundColor = [UIColor kk_colorWithHexString:@"#F9F9F9"];
        [self.contentView addTarget:self action:@selector(singleTap) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.contentView];
        
        self.table = [UITableView kk_initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, MIN(self.dataSource.count*50, MIN(self.contentView.kk_height, self.dataSource.count*50))) style:UITableViewStylePlain delegate:self datasource:self];
        self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
        self.table.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.table];
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.5)];
        [self.table setTableFooterView:header];
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 0.5)];
        [self.table setTableFooterView:footer];
        
        if (self.table.contentSize.height<self.contentView.kk_height) {
            self.table.scrollEnabled = NO;
        }
    }
    return self;
}

- (void)show{
    self.table.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 0.1);
    [UIView animateWithDuration:0.25 animations:^{
        self.table.frame = CGRectMake(0, 0, self.contentView.frame.size.width, MIN(self.contentView.kk_height, self.dataSource.count*50));
    } completion:^(BOOL finished) {

    }];
}

- (void)hide{
    [self removeFromSuperview];

//    [UIView animateWithDuration:0.25 animations:^{
//        self.contentView.frame = CGRectMake(0, KKStatusBarAndNavBarHeight, self.contentView.frame.size.width, 0.1);
//    } completion:^(BOOL finished) {
//        [self removeFromSuperview];
//    }];
}

- (void)singleTap{
    [self hide];
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
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier1=@"cellIdentifier1";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        cell.accessoryType=UITableViewCellAccessoryNone;
        
        CGSize size = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:17]];
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (50-size.height)/2.0, KKApplicationWidth-30, size.height)];
        mainLabel.tag = 199701;
        mainLabel.textColor = Theme_Color_333333;
        mainLabel.font = [UIFont systemFontOfSize:14];
        mainLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [cell.contentView addSubview:mainLabel];
    }
    
    UILabel *mainLabel = (UILabel*)[cell.contentView viewWithTag:199701];
    mainLabel.text = [self.dataSource objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.completeBlock) {
        self.completeBlock([self.dataSource objectAtIndex:indexPath.row]);
    }
    [self hide];
}

@end

//
//  CloudMusicListViewController.m
//  Music
//
//  Created by edward lannister on 2022/08/05.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "CloudMusicListViewController.h"

#define MusicDataCellHeight (60.0f)

@interface CloudMusicListViewController ()<KKTextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , strong) KKTextField *inputTextField;
@property (nonatomic , strong)UITableView *table;
@property (nonatomic , strong)NSMutableArray *dataSourceNotDownload;
@property (nonatomic , strong)NSMutableArray *dataSourceDownload;

@property (nonatomic , copy) NSString *in_URL;

@end

@implementation CloudMusicListViewController

- (instancetype)initWithURL:(NSString *)url{
    self = [super init];
    if (self) {
        self.in_URL = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"音乐下载";
    [self showNavigationDefaultBackButton_ForNavPopBack];
    [self setNavRightButtonTitle:@"确定" selector:@selector(finishedEdit)];
    self.view.backgroundColor = [UIColor whiteColor];

    [self initTableView];
    
    [self initTableViewHeader];
    
    [self reloadDatasource];
}

- (void)initTableView{
    self.dataSourceNotDownload = [[NSMutableArray alloc] init];
    self.dataSourceDownload = [[NSMutableArray alloc] init];

    self.table = [UITableView kk_initWithFrame:CGRectMake(0, 0, KKApplicationWidth, KKApplicationHeight-KKNavigationBarHeight) style:UITableViewStyleGrouped delegate:self datasource:self];
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor = [UIColor colorWithRed:0.86f green:0.87f blue:0.87f alpha:1.00f];
    [self.view addSubview:self.table];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 70)];
    [self.table setTableFooterView:footer];
}

- (void)initTableViewHeader{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKApplicationWidth, 65)];
    headerView.backgroundColor = [UIColor whiteColor];

    KKTextField *textField = [[KKTextField alloc] initWithFrame:CGRectMake(15, 10, KKApplicationWidth-30, 45)];
    textField.padding = UIEdgeInsetsMake(0, 10, 0, 10);
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    textField.textAlignment = NSTextAlignmentLeft;
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    textField.font = [UIFont boldSystemFontOfSize:16];
    textField.textColor = [UIColor blackColor];
    textField.secureTextEntry = NO;
    [textField kk_setCornerRadius:2.0];
    [textField kk_setBorderColor:Theme_Color_999999 width:0.5];
    [headerView addSubview:textField];

    self.inputTextField = textField;
    self.inputTextField.delegate = self;
    if (self.in_URL) {
        self.inputTextField.text = self.in_URL;
    }
    
    [self.table setTableHeaderView:headerView];
}

- (void)reloadDatasource{
    
    [KKWaitingView showInView:self.view withType:KKWaitingViewType_Gray blackBackground:YES text:@"数据同步中……"];
    
    KKWeakSelf(self);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.inputTextField.text]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [KKWaitingView hideForView:self.view];

            if (error==nil && data) {
                [weakself.dataSourceNotDownload removeAllObjects];
                [weakself.dataSourceDownload removeAllObjects];
                [weakself.table reloadData];
                
                NSError *aError = nil;
                HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&aError];
                [weakself parserHTMLParser:parser];
            }
            else{
                NSLog(@"%@",error);
            }

        });

        
    }];
    [task resume];
}

- (void)finishedEdit{
    [self.inputTextField resignFirstResponder];
    [self reloadDatasource];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setStatusBarHidden:NO statusBarStyle:UIStatusBarStyleLightContent withAnimation:UIStatusBarAnimationNone];
}

#pragma mark ==================================================
#pragma mark == UITextFieldDelegate
#pragma mark ==================================================
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        [self reloadDatasource];
        return NO;
    }
    else{
        return YES;
    }
}

#pragma mark ==================================================
#pragma mark == parserHTMLParser
#pragma mark ==================================================
- (void)parserHTMLParser:(HTMLParser*)parser{
    
    HTMLNode *body = [parser body];
    HTMLNode *tableTag = [body findChildTag:@"table"];
    NSArray *tags = [tableTag findChildTags:@"tr"];

    for (int i=0; i<[tags count]; i++) {
        HTMLNode *tr_Node = [tags objectAtIndex:i];
        HTMLNode *top_node = [tr_Node findChildWithAttribute:@"valign" matchingName:@"top" allowPartial:YES];
        if (top_node==nil) {
            continue;
        }
        else{
            HTMLNode *imgNode = [top_node findChildTag:@"img"];
            if (imgNode==nil) {
                continue;
            }
            else{
                NSString *alt = [imgNode getAttributeNamed:@"alt"];
                if ([alt isEqualToString:@"[ICO]"]) {
                    continue;
                }
                else{
                    HTMLNode *a_node = [tr_Node findChildTag:@"a"];
                    if (a_node) {
                        //NSString *name = [a_node contents]; 中文有乱码，暂时无法解决
                        NSString *href = [[a_node getAttributeNamed:@"href"] kk_KKURLDecodedString];
                        href = [href stringByReplacingOccurrencesOfString:@"/" withString:@""];
//                        NSLog(@"href: %@",href);

                        NSString *nodeType = alt;
                        if ([nodeType isEqualToString:@"[DIR]"]) {
                            NSLog(@"找到目录：%@",href);
                        }
                        else if ([nodeType isEqualToString:@"[TXT]"]){
                            NSLog(@"找到文本文件、：%@",href);
                        }
                        else if ([nodeType isEqualToString:@"[IMG]"]){
                            NSLog(@"找到图片文件：%@",href);
                        }
                        else if ([nodeType isEqualToString:@"[SND]"]){
                            NSLog(@"找到音乐文件：%@",href);
                            NSString *url = [self.inputTextField.text stringByAppendingPathComponent:href];
                            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        href,@"fileName",
                                                        url,@"url",
                                                        nil];
                            if ([MusicDBManager.defaultManager DBQuery_Table:TableName_Media isExistValue:url forKey:Table_Media_identifier]) {
                                [self.dataSourceDownload addObject:dictionary];
                            }
                            else{
                                [self.dataSourceNotDownload addObject:dictionary];

                            }
                        }
                        else if ([nodeType isEqualToString:@"[VID]"]){
                            NSLog(@"找到视频文件：%@",href);
                        }
                        else{
                            NSLog(@"找到其他文件：%@ - （ %@ ）",href,nodeType);
                        }
                    }
                    else{
                        NSLog(@"没有找到超链接标签");
                    }
                }
            }
        }
    }

    [self.table reloadData];
}

#pragma mark ========================================
#pragma mark ==UITableView
#pragma mark ========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return [self.dataSourceNotDownload count];
    }
    else{
        return [self.dataSourceDownload count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, KKScreenWidth-30, 14)];
    label.font = [UIFont systemFontOfSize:12];
    [view addSubview:label];
    view.backgroundColor = [UIColor kk_colorWithHexString:@"#E5E5E5"];
    if (section==0) {
        label.text = @"未下载";
    }
    else{
        label.text = @"已下载";
    }
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
    return MusicDataCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier1=@"cellIdentifier1";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        cell.accessoryType=UITableViewCellAccessoryNone;
        
        CGSize size = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:17]];
        
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (MusicDataCellHeight-size.height)/2.0, KKApplicationWidth-30, size.height)];
        mainLabel.tag = 1101;
        mainLabel.textColor = [UIColor blackColor];
        mainLabel.font = [UIFont systemFontOfSize:14];
        mainLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [cell addSubview:mainLabel];
    }
    
    NSDictionary *info = nil;
    if (indexPath.section==0) {
        info = [self.dataSourceNotDownload objectAtIndex:indexPath.row];
    }
    else{
        info = [self.dataSourceDownload objectAtIndex:indexPath.row];
    }
    
    UILabel *mainLabel = (UILabel*)[cell viewWithTag:1101];
    mainLabel.text = [info kk_validStringForKey:@"fileName"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

@end

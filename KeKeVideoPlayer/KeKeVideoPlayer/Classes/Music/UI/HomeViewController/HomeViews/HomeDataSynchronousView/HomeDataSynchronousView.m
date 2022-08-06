//
//  HomeDataSynchronousView.m
//  Music
//
//  Created by edward lannister on 2022/08/05.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "HomeDataSynchronousView.h"
#import "DataListNotDownloadView.h"
#import "DataListCloudAllView.h"
#import "DataListDownloadingView.h"

@interface HomeDataSynchronousView ()<KKTextFieldDelegate,KKSegmentViewDelegate>

@property (nonatomic , strong) MusicNavigationBarView *navBarView;

@property (nonatomic , strong) KKTextField *inputTextField;
@property (nonatomic , strong) KKSegmentView *segmentView;
@property (nonatomic , strong) DataListNotDownloadView *notDownloadView;
@property (nonatomic , strong) DataListCloudAllView *cloudAllView;
@property (nonatomic , strong) DataListDownloadingView *downloadingView;

@end

@implementation HomeDataSynchronousView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.navBarView = [[MusicNavigationBarView alloc] initWithFrame:CGRectMake(0, 0, KKScreenWidth, KKStatusBarAndNavBarHeight)];
    [self addSubview:self.navBarView];
    [self.navBarView setNavRightButtonImage:KKThemeImage(@"btn_NavCloud") selector:@selector(navCloudButtonClicked) target:self];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navBarView.kk_height, KKApplicationWidth, 105)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:headerView];

    KKTextField *textField = [[KKTextField alloc] initWithFrame:CGRectMake(15, 10, KKApplicationWidth-30, 45)];
    textField.padding = UIEdgeInsetsMake(0, 10, 0, 10);
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    textField.textAlignment = NSTextAlignmentLeft;
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    textField.font = [UIFont boldSystemFontOfSize:14];
    textField.textColor = [UIColor blackColor];
    textField.secureTextEntry = NO;
    [textField kk_setCornerRadius:2.0];
    [textField kk_setBorderColor:Theme_Color_999999 width:0.5];
    textField.delegate = self;
    textField.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textField];
    self.inputTextField = textField;
    self.inputTextField.text = URL_CarMusic;
        
    //KKSegmentView
    self.segmentView = [[KKSegmentView alloc] initWithFrame:CGRectMake(0, 65, KKApplicationWidth, 40)];
    self.segmentView.delegate = self;
    self.segmentView.backgroundColor = [UIColor clearColor];
    self.segmentView.sliderView.hidden = NO;
    self.segmentView.sliderSize = CGSizeMake(60, 3.0);
    self.segmentView.sliderView.backgroundColor = Theme_Color_D31925;
    [headerView addSubview:self.segmentView];
    [self.segmentView selectedIndex:0 needRespondsDelegate:NO];
    [self.segmentView kk_setCornerRadius:2.0];
//    [self.segmentView kk_setBorderColor:Theme_Color_999999 width:0.5];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 65, headerView.kk_width, 0.25)];
    line.backgroundColor = Theme_Color_999999;
    [headerView addSubview:line];

    CGFloat offsetY = headerView.kk_bottom;
    self.cloudAllView = [[DataListCloudAllView alloc] initWithFrame:CGRectMake(0, offsetY, KKApplicationWidth, self.kk_height-offsetY)];
    [self addSubview:self.cloudAllView];
    self.cloudAllView.url = self.inputTextField.text;

    self.notDownloadView = [[DataListNotDownloadView alloc] initWithFrame:CGRectMake(0, offsetY, KKApplicationWidth, self.kk_height-offsetY)];
    [self addSubview:self.notDownloadView];
    self.notDownloadView.url = self.inputTextField.text;
    self.notDownloadView.hidden = YES;

    self.downloadingView = [[DataListDownloadingView alloc] initWithFrame:CGRectMake(0, offsetY, KKApplicationWidth, self.kk_height-offsetY)];
    [self addSubview:self.downloadingView];
    [self.downloadingView reloadDatasource];
    self.downloadingView.hidden = YES;
}

- (void)synchronousAuto{
    [KKWaitingView showInView:self withType:KKWaitingViewType_Gray blackBackground:YES text:@"自动同步中……"];
    
    KKWeakSelf(self);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.inputTextField.text]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error==nil && data) {
                NSError *aError = nil;
                HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&aError];
                [weakself parserHTMLParser:parser];
            }
            else{
                NSLog(@"%@",error);
                [KKWaitingView hideForView:self];
            }

        });
        
    }];
    [task resume];
}

#pragma mark ==================================================
#pragma mark == Event
#pragma mark ==================================================
- (void)navCloudButtonClicked{
    [self synchronousAuto];
}

#pragma mark ==================================================
#pragma mark == parserHTMLParser
#pragma mark ==================================================
- (void)parserHTMLParser:(HTMLParser*)parser{
    
    BOOL haveData = NO;
    
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
                            KKLogDebugFormat(@"找到目录：%@",href);
                        }
                        else if ([nodeType isEqualToString:@"[TXT]"]){
                            KKLogDebugFormat(@"找到文本文件、：%@",href);
                        }
                        else if ([nodeType isEqualToString:@"[IMG]"]){
                            KKLogDebugFormat(@"找到图片文件：%@",href);
                        }
                        else if ([nodeType isEqualToString:@"[SND]"]){
                            KKLogDebugFormat(@"找到音乐文件：%@",href);
                            NSString *urlString = [self.inputTextField.text stringByAppendingPathComponent:href];
                            if ([MusicDBManager.defaultManager DBQuery_Table:TableName_Media isExistValue:href forKey:Table_Media_local_name]) {

                            }
                            else{
                                haveData = YES;
                                [KKFileDownloadManager.defaultManager downloadFileWithURL:urlString];
                            }
                        }
                        else if ([nodeType isEqualToString:@"[VID]"]){
                            KKLogDebugFormat(@"找到视频文件：%@",href);
                        }
                        else{
                            KKLogDebugFormat(@"找到其他文件：%@ - （ %@ ）",href,nodeType);
                        }
                    }
                    else{
                        KKLogDebugFormat(@"没有找到超链接标签");
                    }
                }
            }
        }
    }

    [KKWaitingView hideForView:self];

    if (haveData) {
        [self.segmentView selectedIndex:2 needRespondsDelegate:YES];
    }
    else{
        [KKToastView showInView:self text:@"数据已是最新" image:nil alignment:KKToastViewAlignment_Center];
    }
    
}


#pragma mark ==================================================
#pragma mark == UITextFieldDelegate
#pragma mark ==================================================
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        self.notDownloadView.url = self.inputTextField.text;
        self.cloudAllView.url = self.inputTextField.text;
        return NO;
    }
    else{
        return YES;
    }
}

#pragma mark ==================================================
#pragma mark == KKSegmentViewDelegate
#pragma mark ==================================================
- (NSInteger)KKSegmentView_NumberOfButtons:(KKSegmentView*)aSegmentView{
    return 3;
}

- (KKButton*)KKSegmentView:(KKSegmentView*)aSegmentView
            buttonForIndex:(NSInteger)aIndex{

    KKButton *itemButton = [[KKButton alloc] initWithFrame:CGRectMake(0,0, KKScreenWidth/3, 40) type:KKButtonType_ImgTopTitleBottom_Center];
    if (aIndex==0) {
        itemButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self setButtonStyle:itemButton
                   withTitle:@"全部"
                 normalImage:nil
            highlightedImage:nil
                   imageSize:CGSizeZero];
    }
    else if (aIndex==1){
        itemButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self setButtonStyle:itemButton
                   withTitle:@"未下载"
                 normalImage:nil
            highlightedImage:nil
                   imageSize:CGSizeZero];
    }
    else{
        itemButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self setButtonStyle:itemButton
                   withTitle:@"下载中"
                 normalImage:nil
            highlightedImage:nil
                   imageSize:CGSizeZero];
    }
    return itemButton;
}

/*
 选中了新的Button
 */
- (void)KKSegmentView:(KKSegmentView*)aSegementView willDeselectIndex:(NSInteger)aOldIndex willSelectNewIndex:(NSInteger)aNewIndex{
    
    KKButton *btn0 = [aSegementView buttonAtIndex:aOldIndex];
    btn0.textLabel.font = [UIFont systemFontOfSize:14];
    [btn0 setTitleColor:Theme_Color_333333 forState:UIControlStateNormal];

    KKButton *btn1 = [aSegementView buttonAtIndex:aNewIndex];
    btn1.textLabel.font = [UIFont boldSystemFontOfSize:16];
    [btn1 setTitleColor:Theme_Color_D31925 forState:UIControlStateNormal];

    if (aNewIndex==0) {
        self.cloudAllView.hidden = NO;
        self.notDownloadView.hidden = YES;
        self.downloadingView.hidden = YES;
    }
    else if (aNewIndex==1) {
        self.cloudAllView.hidden = YES;
        self.notDownloadView.hidden = NO;
        self.downloadingView.hidden = YES;
    }
    else{
        self.notDownloadView.hidden = YES;
        self.cloudAllView.hidden = YES;
        self.downloadingView.hidden = NO;
        [self.downloadingView reloadDatasource];
    }
}

- (void)setButtonStyle:(KKButton*)aButton
             withTitle:(NSString*)aTitle
           normalImage:(UIImage*)aImageNor
      highlightedImage:(UIImage*)aImageSel
             imageSize:(CGSize)aSize{
    aButton.buttonType = KKButtonType_ImgTopTitleBottom_Center;
    aButton.spaceBetweenImgTitle = 0.0;
    aButton.imageViewSize = aSize;
    aButton.textLabel.font = [UIFont systemFontOfSize:14];
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    [aButton setTitle:aTitle forState:UIControlStateSelected];
    [aButton setTitleColor:Theme_Color_333333 forState:UIControlStateNormal];
    [aButton setTitleColor:Theme_Color_D31925 forState:UIControlStateSelected];
    [aButton setImage:aImageNor forState:UIControlStateNormal];
    [aButton setImage:aImageSel forState:UIControlStateSelected];
}

@end

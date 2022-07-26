//
//  MusicTagView.m
//  Music
//
//  Created by edward lannister on 2022/08/08.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicTagView.h"

@interface MusicTagView ()

@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIScrollView *mainScrollView;

@property (nonatomic , strong) NSDictionary *mediaInformation;
@property (nonatomic , strong) NSMutableArray *tagsArray;

@end


@implementation MusicTagView

#define kMusicTagViewTag (2022071888)

#pragma mark ==================================================
#pragma mark == 接口
#pragma mark ==================================================

+ (MusicTagView*_Nullable)showWithMediaInformation:(NSDictionary *_Nullable)aMediaInformation inView:(UIView*_Nullable)aView {
    if ([aView viewWithTag:kMusicTagViewTag]) {
        return nil;
    }
    
    MusicTagView *pickerView = [[MusicTagView alloc] initWithFrame:aView.bounds information:aMediaInformation];
    pickerView.tag = kMusicTagViewTag;
    [aView addSubview:pickerView];
    [aView bringSubviewToFront:pickerView];

    [pickerView show];
    return pickerView;
}

#pragma mark ==================================================
#pragma mark == 初始化
#pragma mark ==================================================
- (id)initWithFrame:(CGRect)frame information:(NSDictionary*)aInformation{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.mediaInformation = [NSMutableDictionary dictionary];
        self.mediaInformation = aInformation;
        
        self.backButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.backButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.backButton addTarget:self action:@selector(singleTap) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.backButton];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, KKScreenHeight/2.0+20+50)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.contentView];
        [self.contentView kk_setCornerRadius:10];
        [self addShadow];
        
        self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 49, self.contentView.kk_width, self.contentView.kk_height-20-49)];
        self.mainScrollView.showsVerticalScrollIndicator = NO;
        [self.contentView addSubview:self.mainScrollView];
        
        //titleView
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.kk_width, 49)];
        self.headerView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.headerView];
        UILabel *titleLabel = [UILabel kk_initWithTextColor:Theme_Color_333333 font:[UIFont boldSystemFontOfSize:16] text:@"设置标签" maxWidth:self.contentView.kk_width];
        titleLabel.frame = CGRectMake(15, (self.headerView.kk_height-titleLabel.kk_height)/2.0, self.contentView.kk_width-30, titleLabel.kk_height);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.headerView addSubview:titleLabel];

        KKButton *iconButton = [[KKButton alloc] initWithFrame:CGRectMake(self.headerView.kk_width-self.headerView.kk_height,0 , self.headerView.kk_height, self.headerView.kk_height) type:KKButtonType_ImgLeftTitleRight_Left];
        iconButton.imageViewSize = CGSizeMake(12, 12);
        iconButton.spaceBetweenImgTitle = 0;
        iconButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        [iconButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [iconButton setImage:KKThemeImage(@"Music_btn_pop_cha") title:nil titleColor:nil backgroundColor:nil forState:UIControlStateNormal];
        [self.headerView addSubview:iconButton];

        UIView *headerLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.kk_height-0.5, self.headerView.kk_width, 0.5)];
        headerLine.backgroundColor = Theme_Color_F0F0F0;
        [self.headerView addSubview:headerLine];

        
        CGFloat offsetX = 10;
        CGFloat offsetY = 15;
        CGFloat buttonHeight = 40;
        NSArray *tags = [MusicDBManager.defaultManager DBQuery_Tag_All];
        self.tagsArray = [[NSMutableArray alloc] init];
        [self.tagsArray addObjectsFromArray:tags];
        CGFloat buttonMinWidth = [@"我我我我" kk_sizeWithFont:[UIFont systemFontOfSize:12]  maxWidth:self.kk_width-20].width;
        for (NSInteger i=0; i<[self.tagsArray count]; i++) {
            NSDictionary *tagInfo = [self.tagsArray objectAtIndex:i];
            NSString *tagName = [tagInfo kk_validStringForKey:Table_Tag_tag_name];
            CGSize size = [tagName kk_sizeWithFont:[UIFont systemFontOfSize:12]  maxWidth:self.kk_width-20];
            CGFloat buttonWidth = MAX(buttonMinWidth, size.width) + 15;
            if (offsetX+buttonWidth>(self.contentView.kk_width-10)) {
                offsetY = offsetY + buttonHeight + 10;
                offsetX = 10;
            }
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, MIN(buttonWidth, self.contentView.kk_width-20), buttonHeight)];
            [button addTarget:self action:@selector(tagButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.mainScrollView addSubview:button];
            offsetX = offsetX + button.kk_width + 10;
            button.tag = 1111+i;
            button.kk_tagInfo = tagInfo;
            [button setTitle:tagName forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button kk_setCornerRadius:button.kk_height/2.0];
            
            NSString *identifier = [self.mediaInformation kk_validStringForKey:Table_Media_identifier];
            NSString *tagId = [tagInfo kk_validStringForKey:Table_Tag_tag_id];
            NSDictionary *dbData = [MusicDBManager.defaultManager DBQuery_MediaTag_WithMediaIdentifer:identifier tagId:tagId];
            if ([NSDictionary kk_isDictionaryNotEmpty:dbData]) {
                button.backgroundColor = Theme_Color_D31925;
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else{
                button.backgroundColor = Theme_Color_F8F8F8;
                [button setTitleColor:Theme_Color_666666 forState:UIControlStateNormal];
                [button kk_setBorderColor:Theme_Color_DEDEDE width:0.5];
            }
            
            if (i==[tags count]-1) {
                offsetY = offsetY + buttonHeight + 10;
            }
        }
        
        self.mainScrollView.contentSize = CGSizeMake(KKScreenWidth, offsetY);

    }
    return self;
}

- (void)addShadow{
    self.contentView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.contentView.layer.shadowOffset = CGSizeZero; // 设置偏移量为 0 ，四周都有阴影
    self.contentView.layer.shadowRadius = 25.0; //阴影半径,默认 3
    self.contentView.layer.shadowOpacity = 1.0; //阴影透明度 ，默认 0
    self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
}

- (void)show{
    self.contentView.frame = CGRectMake(0, self.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.frame = CGRectMake(0, self.kk_height-self.contentView.frame.size.height+20, self.contentView.frame.size.width, self.contentView.frame.size.height);
    } completion:^(BOOL finished) {

    }];
}

- (void)hide{
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.frame = CGRectMake(0, self.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)singleTap{
    [self hide];
}

#pragma mark ==================================================
#pragma mark == Network: Request Result
#pragma mark ==================================================
- (void)tagButtonClicked:(UIButton*)button{
    NSDictionary *tagInfo = button.kk_tagInfo;
    NSString *identifier = [self.mediaInformation kk_validStringForKey:Table_Media_identifier];
    NSString *tagId = [tagInfo kk_validStringForKey:Table_Tag_tag_id];
    NSDictionary *dbData = [MusicDBManager.defaultManager DBQuery_MediaTag_WithMediaIdentifer:identifier tagId:tagId];
    if ([NSDictionary kk_isDictionaryNotEmpty:dbData]) {
        if ([MusicDBManager.defaultManager DBDelete_MediaTag_WithMediaIdentifer:identifier tagId:tagId]) {
            button.backgroundColor = Theme_Color_F8F8F8;
            [button setTitleColor:Theme_Color_666666 forState:UIControlStateNormal];
            [button kk_setBorderColor:Theme_Color_DEDEDE width:0.5];
        }
        else{
            [KKToastView showInView:self text:@"操作失败" image:nil alignment:KKToastViewAlignment_Center];
        }
    }
    else{
        if ([MusicDBManager.defaultManager DBInsert_MediaTag_WithMediaIdentifer:identifier tagId:tagId]) {
            button.backgroundColor = Theme_Color_D31925;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else{
            [KKToastView showInView:self text:@"操作失败" image:nil alignment:KKToastViewAlignment_Center];
        }
    }
}


@end

//
//  HomeViewController.m
//  Music
//
//  Created by edward lannister on 2022/08/01.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeMusicPlayerView.h"
#import "HomeTagListView.h"
#import "HomeDataSynchronousView.h"

@interface HomeViewController ()<KKSegmentViewDelegate>


@property (nonatomic , strong) HomeTagListView *home_tagListView;
@property (nonatomic , strong) HomeMusicPlayerView *home_musicPlayerView;
@property (nonatomic , strong) HomeDataSynchronousView *home_dataSynchronousView;
@property (nonatomic , strong) KKSegmentView *segmentView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标签";

    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark -
#pragma mark ==================================================
#pragma mark == UI界面
#pragma mark ==================================================
- (void)initUI {

    CGRect frame = CGRectMake(0, 0, KKScreenWidth, KKScreenHeight-55-KKSafeAreaBottomHeight);
    //TagList
    self.home_tagListView = [[HomeTagListView alloc] initWithFrame:frame];
    [self.view addSubview:self.home_tagListView];

    //MusicPlayer
    self.home_musicPlayerView = [[HomeMusicPlayerView alloc] initWithFrame:frame];
    [self.view addSubview:self.home_musicPlayerView];
    self.home_musicPlayerView.hidden = YES;
    
    //DataSynchronous
    self.home_dataSynchronousView = [[HomeDataSynchronousView alloc] initWithFrame:frame];
    [self.view addSubview:self.home_dataSynchronousView];
    self.home_dataSynchronousView.hidden = YES;

    self.segmentView = [[KKSegmentView alloc] initWithFrame:CGRectMake(0, KKScreenHeight-55-KKSafeAreaBottomHeight, KKApplicationWidth, 55)];
    self.segmentView.delegate = self;
    self.segmentView.backgroundImageView.backgroundColor = [UIColor whiteColor];
    self.segmentView.headLineView.backgroundColor = [UIColor kk_colorWithHexString:@"#EEEEEE"];
    self.segmentView.headLineView.hidden = YES;
    [self.segmentView selectedIndex:0 needRespondsDelegate:NO];
    [self.view addSubview:self.segmentView];
    [[UIScreen mainScreen] kk_createiPhoneXFooterForView:self.segmentView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.segmentView.kk_top, KKScreenWidth, 0.25)];
    line.backgroundColor = [UIColor kk_colorWithHexString:@"#E5E5E5"];
    [self.view addSubview:line];
}

#pragma mark -
#pragma mark ==================================================
#pragma mark == 协议代理 KKSegmentViewDelegate
#pragma mark ==================================================
- (NSInteger)KKSegmentView_NumberOfButtons:(KKSegmentView*)aSegmentView{
    return 3;
}

- (KKButton*)KKSegmentView:(KKSegmentView*)aSegmentView buttonForIndex:(NSInteger)aIndex{
    
    KKButton *itemButton = nil;
    itemButton = [[KKButton alloc] initWithFrame:CGRectMake(0,0, KKApplicationWidth/3, 55) type:KKButtonType_ImgTopTitleBottom_Center];
    if (aIndex==0) {
        itemButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self setButtonStyle:itemButton
                   withTitle:@"标签"
                 normalImage:KKThemeImage(@"Music_Home_BottomBtn_0N")
            highlightedImage:KKThemeImage(@"Music_Home_BottomBtn_0H")
                   imageSize:CGSizeMake(22, 22)];
    }
    else if (aIndex==1){
        itemButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self setButtonStyle:itemButton
                   withTitle:nil
                 normalImage:KKThemeImage(@"Music_Home_BottomBtn_1N")
            highlightedImage:KKThemeImage(@"Music_Home_BottomBtn_1H")
                   imageSize:CGSizeMake(40, 40)];
    }
    else{
        itemButton.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self setButtonStyle:itemButton
                   withTitle:@"云音库"
                 normalImage:KKThemeImage(@"Music_Home_BottomBtn_2N")
            highlightedImage:KKThemeImage(@"Music_Home_BottomBtn_2H")
                   imageSize:CGSizeMake(22, 22)];
    }
    
    return itemButton;
}

/*
 被选中的Button再次被点击
 */
- (void)KKSegmentView:(KKSegmentView*)aSegementView selectedSameIndex:(NSInteger)aIndex{
    
}

/*
 选中了新的Button
 */
- (void)KKSegmentView:(KKSegmentView*)aSegementView willDeselectIndex:(NSInteger)aOldIndex willSelectNewIndex:(NSInteger)aNewIndex{
    
    [self footBarwillDeselectIndex:aOldIndex willSelectNewIndex:aNewIndex];
}

- (void)setButtonStyle:(KKButton*)aButton
             withTitle:(NSString*)aTitle
           normalImage:(UIImage*)aImageNor
      highlightedImage:(UIImage*)aImageSel
             imageSize:(CGSize)aSize{
    aButton.buttonType = KKButtonType_ImgTopTitleBottom_Center;
    aButton.spaceBetweenImgTitle = 5.0;
    aButton.imageViewSize = aSize;
    aButton.textLabel.font = [UIFont systemFontOfSize:9];
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    [aButton setTitle:aTitle forState:UIControlStateSelected];
    [aButton setTitleColor:[UIColor kk_colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [aButton setTitleColor:[UIColor kk_colorWithHexString:@"#D31925"] forState:UIControlStateSelected];
    [aButton setImage:aImageNor forState:UIControlStateNormal];
    [aButton setImage:aImageSel forState:UIControlStateSelected];
}


- (void)footBarwillDeselectIndex:(NSInteger)aOldIndex
              willSelectNewIndex:(NSInteger)aNewIndex{
    
    [self showButtonAnimation:aNewIndex];

    self.home_tagListView.hidden = YES;
    self.home_musicPlayerView.hidden = YES;
    self.home_dataSynchronousView.hidden = YES;
    if (aNewIndex==0) {
        self.home_tagListView.hidden = NO;
        [self.home_tagListView reloadDatasource];
        self.title = @"标签";
    }
    else if (aNewIndex==1){
        self.home_musicPlayerView.hidden = NO;
        self.title = @"播放器";
    }
    else{
        self.home_dataSynchronousView.hidden = NO;
        self.title = @"云音库";
    }
}

- (void)showButtonAnimation:(NSInteger)index{
    
    KKButton *button = [self.segmentView buttonAtIndex:index];
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];

    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.85, 0.85, 1.0)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    
    [button.imageView.layer addAnimation:animation forKey:nil];
}

@end

//
//  ENImagePageView.m
//  English
//
//  Created by liubo on 2021/4/29.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "ENImagePageView.h"
#import "ENImageItemView.h"

@interface ENImagePageView ()<ENImageItemViewDelegate,KKPageScrollViewDelegate>

@property (nonatomic,strong)UIView *backgroundView;
@property (nonatomic,strong)UIPageControl *myPageControl;
@property (nonatomic,strong)KKPageScrollView *myPageView;
@property (nonatomic,strong) NSMutableArray *imagesNamesArray;

@property (nonatomic , assign) NSInteger nowSelectedIndex;

@end


@implementation ENImagePageView

- (id)initWithFrame:(CGRect)frame items:(NSArray*)aItemsArray{
    self = [super initWithFrame:frame];
    if (self) {
        self.imagesNamesArray = [[NSMutableArray alloc]init];
        [self.imagesNamesArray addObjectsFromArray:aItemsArray];
        
        self.nowSelectedIndex = 0;
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.userInteractionEnabled = NO;
        self.backgroundView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.backgroundView];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.myPageView = [[KKPageScrollView alloc] initWithFrame:self.bounds];
        self.myPageView.delegate = self;
        self.myPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.myPageView.clipsToBounds = YES;
        [self.myPageView showPageIndex:self.nowSelectedIndex animated:NO];
        [self.myPageView setPageSpace:10];
        [self.myPageView reloadData];
        [self.myPageView clearBackgroundColor];
        [self addSubview:self.myPageView];
        
        self.myPageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.frame.size.height-30, self.frame.size.width, 20)];
        self.myPageControl.hidesForSinglePage = YES;
        self.myPageControl.numberOfPages = [self.imagesNamesArray count];
        self.myPageControl.currentPage = self.nowSelectedIndex;
        self.myPageControl.currentPageIndicatorTintColor = [UIColor redColor];
        self.myPageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        [self addSubview:self.myPageControl];
//        self.myPageControl.hidden = YES;
    }
    return self;
}

#pragma mark ==================================================
#pragma mark == KKPageScrollViewDelegate
#pragma mark ==================================================
- (UIView*)pageView:(KKPageScrollView*)pageView viewForPage:(NSInteger)pageIndex{
    
    ENImageItemView *itemView = (ENImageItemView*)[self.myPageView viewForPageIndex:pageIndex];
    if (!itemView) {
        itemView = [[ENImageItemView alloc] initWithFrame:pageView.bounds];
        itemView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        itemView.delegate = self;
    }
    
    NSString *itemName = [self.imagesNamesArray objectAtIndex_Safe:pageIndex];
    [itemView reloaWithFileName:itemName];
    
    return itemView;
}

- (NSInteger)numberOfPagesInPageView:(KKPageScrollView*)pageView{
    return [self.imagesNamesArray count];
}

- (BOOL)pageViewCanRepeat:(KKPageScrollView*)pageView{
    return NO;
}

- (void)pageView:(KKPageScrollView*)pageView didScrolledToPageIndex:(NSInteger)pageIndex{
    self.myPageControl.currentPage = pageIndex;
    ENImageItemView *itemView = (ENImageItemView*)[self.myPageView viewForPageIndex:pageIndex];
    [itemView.myScrollView setZoomScale:1.0 animated:NO];
    self.nowSelectedIndex = pageIndex;
}

- (void)ENImageItemViewSingleTap:(NSString*_Nonnull)aFileName{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ENImagePageView_SingleTap:)]) {
        [self.delegate ENImagePageView_SingleTap:aFileName];
    }
}

@end

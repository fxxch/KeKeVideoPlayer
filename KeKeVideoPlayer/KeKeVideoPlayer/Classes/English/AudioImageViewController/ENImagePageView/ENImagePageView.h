//
//  ENImagePageView.h
//  English
//
//  Created by liubo on 2021/4/29.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ENImagePageViewDelegate;

@interface ENImagePageView : UIView

@property (nonatomic , weak) id<ENImagePageViewDelegate> _Nullable delegate;

- (id)initWithFrame:(CGRect)frame items:(NSArray*_Nullable)aItemsArray;

@end



#pragma mark ==================================================
#pragma mark == ENImagePageViewDelegate
#pragma mark ==================================================
@protocol ENImagePageViewDelegate <NSObject>
@optional

- (void)ENImagePageView_SingleTap:(NSString*_Nonnull)aFileName;

@end




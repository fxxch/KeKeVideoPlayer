//
//  ENImageItemView.h
//  English
//
//  Created by liubo on 2021/4/29.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ENImageItemViewDelegate;

@interface ENImageItemView : UIView<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic,strong)UIImageView *_Nonnull myImageView;
@property (nonatomic,strong)UIScrollView *_Nonnull myScrollView;
@property (nonatomic , copy) NSString * _Nullable fileName;

@property (nonatomic,weak)id<ENImageItemViewDelegate> _Nullable delegate;

- (void)reloaWithFileName:(NSString*_Nonnull)aFileName;

@end


@protocol ENImageItemViewDelegate <NSObject>

- (void)ENImageItemViewSingleTap:(NSString*_Nonnull)aFileName;

@end

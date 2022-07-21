//
//  KKVideoPlayerNavigationView.h
//  CEDongLi
//
//  Created by beartech on 15/10/23.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKVideoPlayerNavigationViewDelegate;

@interface KKVideoPlayerNavigationView : UIView

@property (nonatomic,strong)UIImageView *backgroundImageView;
@property (nonatomic,strong)UIButton *leftButton;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,assign)id<KKVideoPlayerNavigationViewDelegate> delegate;

@end


@protocol KKVideoPlayerNavigationViewDelegate <NSObject>

- (void)KKVideoPlayerNavigationView_LeftButtonClicked:(KKVideoPlayerNavigationView*)aView;

@end

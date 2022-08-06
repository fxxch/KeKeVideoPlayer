//
//  MusicNavigationBarView.h
//  KeKeVideoPlayer
//
//  Created by edward lannister on 2022/08/06.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicNavigationBarView : UIView

@property (nonatomic , strong) KKButton *leftButton;
@property (nonatomic , strong) KKButton *rightButton;
@property (nonatomic , strong) UILabel *titleLabel;
@property (nonatomic , strong) UIImageView *footerLineView;

#pragma mark ==================================================
#pragma mark == NavigationBar Title
#pragma mark ==================================================
- (void)setTitle:(NSString *)title;

#pragma mark ==================================================
#pragma mark == NavigationBar Button
#pragma mark ==================================================
- (KKButton*)setNavLeftButtonImage:(UIImage *)image selector:(SEL)selecter target:(id)target;

- (KKButton*)setNavRightButtonImage:(UIImage *)image selector:(SEL)selecter target:(id)target;

- (KKButton*)setNavLeftButtonTitle:(NSString *)title titleColor:(UIColor *)tColor selector:(SEL)selecter target:(id)target;

- (KKButton*)setNavRightButtonTitle:(NSString *)title titleColor:(UIColor *)tColor selector:(SEL)selecter target:(id)target;

@end

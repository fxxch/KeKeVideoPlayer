//
//  MusicNavigationBarView.h
//  KeKeVideoPlayer
//
//  Created by edward lannister on 2022/08/06.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKTextField.h"

@protocol MusicNavigationBarViewDelegate;

@interface MusicNavigationBarView : UIView<KKTextFieldDelegate>

@property (nonatomic , strong) UIView *barView;
@property (nonatomic , strong) KKButton *leftButton;
@property (nonatomic , strong) KKButton *rightButton;
@property (nonatomic , strong) UILabel *titleLabel;
@property (nonatomic , strong) UIImageView *footerLineView;
@property (nonatomic , strong) KKTextField *inputTextField;

@property (nonatomic , weak) id<MusicNavigationBarViewDelegate> delegate;

- (void)addShadow;

#pragma mark ==================================================
#pragma mark == Title
#pragma mark ==================================================
- (void)setTitle:(NSString *)title;
- (void)setTitle:(NSString *)title autoResize:(BOOL)autoResize;

#pragma mark ==================================================
#pragma mark == TextField
#pragma mark ==================================================
- (void)showTextField;
- (UIButton*)showTextFieldRightButtonWithTaget:(id)target selector:(SEL)action image:(UIImage*)aImage;

#pragma mark ==================================================
#pragma mark == Button
#pragma mark ==================================================
- (KKButton*)setNavLeftButtonImage:(UIImage *)image selector:(SEL)selecter target:(id)target;

- (KKButton*)setNavRightButtonImage:(UIImage *)image selector:(SEL)selecter target:(id)target;

- (KKButton*)setNavLeftButtonTitle:(NSString *)title titleColor:(UIColor *)tColor selector:(SEL)selecter target:(id)target;

- (KKButton*)setNavRightButtonTitle:(NSString *)title titleColor:(UIColor *)tColor selector:(SEL)selecter target:(id)target;

@end


#pragma mark ==================================================
#pragma mark == MusicNavigationBarViewDelegate
#pragma mark ==================================================
@protocol MusicNavigationBarViewDelegate <NSObject>
@optional

/// 输入View开始输入（键盘弹起）
/// @param aTextFieldView 当前输入View
- (void)MusicNavigationBarView:(MusicNavigationBarView*)aBarView textFieldDidBeginEditing:(KKTextField*)aTextField;


/// 输入View输入内容发生变化
/// @param aTextFieldView 当前输入View
- (BOOL)MusicNavigationBarView:(MusicNavigationBarView*)aBarView textField:(KKTextField*)aTextField textCanChangedToString:(NSString*)aText;


/// 输入View结束输入（键盘收起）
/// @param aTextFieldView 当前输入View
- (void)MusicNavigationBarView:(MusicNavigationBarView*)aBarView textDidEndEditing:(KKTextField*)aTextField;

@end


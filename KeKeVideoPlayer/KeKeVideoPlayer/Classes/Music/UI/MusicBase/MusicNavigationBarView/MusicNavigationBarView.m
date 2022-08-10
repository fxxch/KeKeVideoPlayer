//
//  MusicNavigationBarView.m
//  KeKeVideoPlayer
//
//  Created by edward lannister on 2022/08/06.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicNavigationBarView.h"

@interface MusicNavigationBarView ()<KKTextFieldDelegate>

@end

@implementation MusicNavigationBarView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = [UIColor whiteColor];
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, self.kk_height-KKNavigationBarHeight, self.kk_width, KKNavigationBarHeight)];
    [self addSubview:self.barView];
    
    self.footerLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.barView.kk_bottom-0.5, self.kk_width, 0.5)];
    self.footerLineView.backgroundColor = Theme_Color_DEDEDE;
    [self addSubview:self.footerLineView];
}

- (void)addShadow{
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 5); // 设置偏移量为 0 ，四周都有阴影
    self.layer.shadowRadius = 25.0; //阴影半径,默认 3
    self.layer.shadowOpacity = 1.0; //阴影透明度 ，默认 0
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
}

#pragma mark ==================================================
#pragma mark == Title
#pragma mark ==================================================
- (void)initTitleLabel{
    CGFloat height = [UIFont kk_heightForFont:[UIFont boldSystemFontOfSize:17]];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, (self.barView.kk_height-height)/2.0, self.barView.kk_width-120, height)];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.barView addSubview:self.titleLabel];
}

- (void)setTitle:(NSString *)title{
    [self setTitle:title autoResize:NO];
}

- (void)setTitle:(NSString *)title autoResize:(BOOL)autoResize{
    if (self.titleLabel==nil) {
        [self initTitleLabel];
    }
    
    if (autoResize) {
        CGSize size = [title kk_sizeWithFont:[UIFont boldSystemFontOfSize:17] maxSize:CGSizeMake(self.barView.kk_width-120, self.barView.kk_height)];
        CGFloat height = [UIFont kk_heightForFont:[UIFont boldSystemFontOfSize:17]];
        if (size.height>height) {
            self.titleLabel.numberOfLines = 2;
            CGSize size13 = [title kk_sizeWithFont:[UIFont boldSystemFontOfSize:13] maxSize:CGSizeMake(self.kk_width-120, self.barView.kk_height)];
            self.titleLabel.font = [UIFont systemFontOfSize:13];
            self.titleLabel.frame = CGRectMake(60, (self.barView.kk_height-size13.height)/2.0, self.barView.kk_width-120, size13.height);
            self.titleLabel.text = title;
            self.titleLabel.textColor = Theme_Color_D31925;
        }
        else{
            self.titleLabel.frame = CGRectMake(60, (self.barView.kk_height-size.height)/2.0, self.barView.kk_width-120, size.height);
            self.titleLabel.text = title;
            self.titleLabel.textColor = Theme_Color_D31925;
            self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        }
    }
    else{
        CGSize size = [title kk_sizeWithFont:[UIFont boldSystemFontOfSize:17] maxSize:CGSizeMake(self.barView.kk_width-120, self.barView.kk_height)];
        self.titleLabel.frame = CGRectMake(60, (self.barView.kk_height-size.height)/2.0, self.barView.kk_width-120, size.height);
        self.titleLabel.text = title;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    }
}

#pragma mark ==================================================
#pragma mark == TextField
#pragma mark ==================================================
- (void)showTextField{
    if (self.inputTextField) {
        return;
    }
    self.titleLabel.text = nil;
    
    KKTextField *textField = [[KKTextField alloc] initWithFrame:CGRectMake(60, (self.barView.kk_height-35)/2.0, self.barView.kk_width-120, 35)];
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
    textField.delegate = self;
    textField.backgroundColor = Theme_Color_F8F8F8;
    [textField kk_setCornerRadius:textField.kk_height/2.0];
    [textField kk_setBorderColor:Theme_Color_DEDEDE width:0.5];
    [self.barView addSubview:textField];
    self.inputTextField = textField;
    
    [self reloadTextFieldFrame];
}

- (UIButton*)showTextFieldRightButtonWithTaget:(id)target selector:(SEL)action image:(UIImage*)aImage{
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [rightButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.inputTextField.rightView = rightButton;
    self.inputTextField.rightViewMode = UITextFieldViewModeAlways;

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 25, 25)];
    imageView.image = KKThemeImage(@"Music_btn_arrow_down");
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [rightButton addSubview:imageView];

    return rightButton;
}

- (void)reloadTextFieldFrame{
    if (self.inputTextField==nil) {
        return;
    }
    CGFloat offsetL = 15;
    CGFloat offsetR = 15;
    if (self.leftButton) {
        offsetL = 60;
    }
    if (self.rightButton) {
        offsetR = 60;
    }
    self.inputTextField.frame = CGRectMake(offsetL, (self.barView.kk_height-35)/2.0, self.barView.kk_width-(offsetL+offsetR), 35);
}

#pragma mark ==================================================
#pragma mark == UITextFieldDelegate
#pragma mark ==================================================
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(MusicNavigationBarView:textFieldDidBeginEditing:)]) {
        [self.delegate MusicNavigationBarView:self textFieldDidBeginEditing:self.inputTextField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField==self.inputTextField){
        if ([string isEqualToString:@"\n"]) {
            [textField resignFirstResponder];
            if (self.delegate && [self.delegate respondsToSelector:@selector(MusicNavigationBarView:textDidEndEditing:)]) {
                [self.delegate MusicNavigationBarView:self textDidEndEditing:self.inputTextField];
            }
            return NO;
        }
        else{
            NSString *tobeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            if (self.delegate && [self.delegate respondsToSelector:@selector(MusicNavigationBarView:textField:textCanChangedToString:)]) {
                return [self.delegate MusicNavigationBarView:self textField:self.inputTextField textCanChangedToString:tobeString];
            }
            else{
                return YES;
            }
        }
    }
    return YES;
}

#pragma mark ==================================================
#pragma mark == NavigationBar Button
#pragma mark ==================================================
- (KKButton*)setNavLeftButtonImage:(UIImage *)image selector:(SEL)selecter target:(id)target{
    KKButton *button = [[KKButton alloc] initWithFrame:CGRectMake(0, 0, 60, self.barView.kk_height) type:KKButtonType_ImgLeftTitleRight_Center];
    button.imageViewSize = CGSizeMake(30, 30);
    button.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.spaceBetweenImgTitle = 0;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selecter forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;//关闭多点
    button.backgroundColor = [UIColor clearColor];
    [self.barView addSubview:button];
    [self.leftButton removeFromSuperview];
    self.leftButton = button;
    
    [self reloadTextFieldFrame];
    return button;
}

- (KKButton*)setNavRightButtonImage:(UIImage *)image selector:(SEL)selecter target:(id)target{
    KKButton *button = [[KKButton alloc] initWithFrame:CGRectMake(self.barView.kk_width-60, 0, 60, self.barView.kk_height) type:KKButtonType_ImgLeftTitleRight_Center];
    button.imageViewSize = CGSizeMake(30, 30);
    button.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.spaceBetweenImgTitle = 0;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selecter forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;//关闭多点
    button.backgroundColor = [UIColor clearColor];
    [self.barView addSubview:button];
    [self.rightButton removeFromSuperview];
    self.rightButton = button;
    
    [self reloadTextFieldFrame];
    return button;
}

- (KKButton*)setNavLeftButtonTitle:(NSString *)title titleColor:(UIColor *)tColor selector:(SEL)selecter target:(id)target{
    CGSize size = [title kk_sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:self.barView.kk_width];
    CGFloat buttonWidth = size.width + 15;
    KKButton *button = [[KKButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, self.barView.kk_height) type:KKButtonType_ImgLeftTitleRight_Left];
    button.imageViewSize = CGSizeZero;
    button.edgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    button.spaceBetweenImgTitle = 0;
    [button addTarget:target action:selecter forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;//关闭多点
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:tColor forState:UIControlStateNormal];
    button.textLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:title forState:UIControlStateNormal];
    [self.barView addSubview:button];
    [self.leftButton removeFromSuperview];
    self.leftButton = button;

    [self reloadTextFieldFrame];
    return button;
}

- (KKButton*)setNavRightButtonTitle:(NSString *)title titleColor:(UIColor *)tColor selector:(SEL)selecter target:(id)target{
    CGSize size = [title kk_sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:self.barView.kk_width];
    CGFloat buttonWidth = size.width + 15;
    KKButton *button = [[KKButton alloc] initWithFrame:CGRectMake(self.barView.kk_width-buttonWidth, 0, buttonWidth, self.barView.kk_height) type:KKButtonType_ImgLeftTitleRight_Left];
    button.imageViewSize = CGSizeZero;
    button.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    button.spaceBetweenImgTitle = 0;
    [button addTarget:target action:selecter forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;//关闭多点
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:tColor forState:UIControlStateNormal];
    button.textLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:title forState:UIControlStateNormal];
    [self.barView addSubview:button];
    [self.rightButton removeFromSuperview];
    self.rightButton = button;
    
    [self reloadTextFieldFrame];
    return button;
}

@end

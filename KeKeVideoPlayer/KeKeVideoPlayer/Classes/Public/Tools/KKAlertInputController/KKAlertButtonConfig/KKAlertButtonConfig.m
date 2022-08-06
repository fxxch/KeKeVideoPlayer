//
//  KKAlertButtonConfig.m
//  ChervonIot
//
//  Created by edward lannister on 2022/07/14.
//  Copyright © 2022 ts. All rights reserved.
//

#import "KKAlertButtonConfig.h"

@implementation KKAlertButtonConfig


+ (KKAlertButtonConfig*)cancelConfig{
    KKAlertButtonConfig *config = [KKAlertButtonConfig alloc];
    config.title = @"取消";
    config.titleColor = [UIColor kk_colorWithHexString:@"#3C3936"];
    return config;
}

+ (KKAlertButtonConfig*)okConfig{
    KKAlertButtonConfig *config = [KKAlertButtonConfig alloc];
    config.title = @"确定";
    config.titleColor = [UIColor kk_colorWithHexString:@"#77BC1F"];
    return config;
}

@end

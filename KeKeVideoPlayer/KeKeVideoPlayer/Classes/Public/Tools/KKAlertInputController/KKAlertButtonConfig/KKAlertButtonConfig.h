//
//  KKAlertButtonConfig.h
//  ChervonIot
//
//  Created by edward lannister on 2022/07/14.
//  Copyright © 2022 ts. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^KKAlertActionBlock)(NSString *text);

@interface KKAlertButtonConfig : NSObject

@property (nonatomic , copy) NSString *title;
@property (nonatomic , strong) UIColor *titleColor;
@property (nonatomic , copy) KKAlertActionBlock actionBlock;

+ (KKAlertButtonConfig*)cancelConfig;

+ (KKAlertButtonConfig*)okConfig;

@end

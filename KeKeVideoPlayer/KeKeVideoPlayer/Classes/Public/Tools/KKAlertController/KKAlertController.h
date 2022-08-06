//
//  KKAlertController.h
//  ChervonIot
//
//  Created by edward lannister on 2022/05/24.
//  Copyright © 2022 ts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKAlertButtonConfig.h"

@interface KKAlertController : UIWindow

+ (void)showWithTitle:(NSString *)aTitle
              message:(NSString *)aMessage
           leftConfig:(KKAlertButtonConfig*)aLeftConfig
          rightConfig:(KKAlertButtonConfig*)aRightConfig;

@end



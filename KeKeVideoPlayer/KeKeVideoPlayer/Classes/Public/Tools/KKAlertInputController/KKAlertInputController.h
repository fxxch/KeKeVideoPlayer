//
//  KKAlertInputController.h
//  ChervonIot
//
//  Created by edward lannister on 2022/05/24.
//  Copyright © 2022 ts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKAlertButtonConfig.h"

@interface KKAlertInputController : UIWindow

+ (void)showWithTitle:(NSString *_Nullable)aTitle
             subTitle:(NSString *_Nullable)aSubTitle
     inputPlaceholder:(NSString *_Nullable)aPlaceholder
             initText:(NSString *_Nullable)aInitText
           leftConfig:(KKAlertButtonConfig*_Nullable)aLeftConfig
          rightConfig:(KKAlertButtonConfig*_Nullable)aRightConfig;

@end



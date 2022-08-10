//
//  MusicServerAddressListView.h
//  Music
//
//  Created by edward lannister on 2022/08/10.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MusicServerAddressSelectFinishedBlock)(NSString *_Nullable address);

@interface MusicServerAddressListView : UIView

+ (MusicServerAddressListView*_Nullable)showInView:(UIView*_Nullable)aView dataSource:(NSArray*_Nullable)aArray finishedBlock:(MusicServerAddressSelectFinishedBlock _Nullable )finishedBlock;


@end

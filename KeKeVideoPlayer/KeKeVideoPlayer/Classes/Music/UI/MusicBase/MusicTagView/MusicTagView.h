//
//  MusicTagView.h
//  Music
//
//  Created by edward lannister on 2022/08/08.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MusicTagView : UIView

+ (MusicTagView*_Nullable)showWithMediaInformation:(NSDictionary *_Nullable)aMediaInformation inView:(UIView*_Nullable)aView;

@end

//
//  MusicTagSelectView.h
//  Music
//
//  Created by edward lannister on 2022/08/10.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MusicTagSelectFinishedBlock)(NSArray *_Nullable tagsArray);

@interface MusicTagSelectView : UIView

+ (MusicTagSelectView*_Nullable)showInView:(UIView*_Nullable)aView finishedBlock:(MusicTagSelectFinishedBlock _Nullable )finishedBlock;

@end

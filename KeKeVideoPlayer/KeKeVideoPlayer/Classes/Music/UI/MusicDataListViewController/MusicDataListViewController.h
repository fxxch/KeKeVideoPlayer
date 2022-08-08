//
//  MusicDataListViewController.h
//  Music
//
//  Created by edward lannister on 2022/08/08.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicBaseViewController.h"

typedef NS_ENUM(NSInteger,MusicDataListType) {
    
    MusicDataListType_All = 0,/* 全部歌曲 */
    
    MusicDataListType_NoTag = 1,/* 没有标签的 */
    
    MusicDataListType_Error = 2,/* 错误数据 */
    
    MusicDataListType_Tag = 3,/* 有标签的 */
};


@interface MusicDataListViewController : MusicBaseViewController

- (instancetype)initMusicDataListType:(MusicDataListType)aType dataArray:(NSArray*)aDataArray;

- (instancetype)initWithTagInfo:(NSDictionary*)aTagInformation;

@end

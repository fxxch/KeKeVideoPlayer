//
//  KKVideoPlayViewController.h
//  CEDongLi
//
//  Created by beartech on 15/10/24.
//  Copyright (c) 2015年 KeKeStudio. All rights reserved.
//

#import "KKViewController.h"
#import "KKWindowActionView.h"

@protocol KKVideoPlayViewControllerDelegate;

/* 需要引入 libbz2.dylib */
@interface KKVideoPlayViewController : KKViewController

@property (nonatomic,copy)NSString *documentRemoteURL;
@property (nonatomic,copy)NSString *documentRemoteName;
@property (nonatomic , weak) id<KKVideoPlayViewControllerDelegate> delegate;
@property (nonatomic , strong) NSArray<KKWindowActionViewItem*>* moreActionItems;
@property (nonatomic,assign)BOOL canPlayInBackground;

/**
* 1、aFilePath 文档的URL,（file:///xxxxx的路径e格式,或者http://格式）
* 2、aFileName 文档的名称 (xxxx.jpg 类似带扩展名的文件名全称)
*/
- (instancetype)initWitFilePath:(NSString*)aFilePath
                       fileName:(NSString*)aFileName;

- (CGSize)videoFrameSize;

@end


#pragma mark ==================================================
#pragma mark == KKVideoPlayViewControllerDelegate
#pragma mark ==================================================
@protocol KKVideoPlayViewControllerDelegate <NSObject>
@optional

- (void)KKVideoPlayViewController:(KKVideoPlayViewController*)aViewController selectMoreActionItem:(KKWindowActionViewItem*)aItem;

@end


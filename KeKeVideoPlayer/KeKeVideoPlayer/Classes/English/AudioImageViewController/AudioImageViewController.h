//
//  AudioImageViewController.h
//  English
//
//  Created by liubo on 2021/4/29.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AudioImageViewController : BaseViewController

@property (nonatomic,copy)NSString *documentRemoteURL;
@property (nonatomic,copy)NSString *documentRemoteName;

/**
 * 1、aFilePath 文档的URL,（file:///xxxxx的路径e格式,或者http://格式）
 * 2、aFileName 文档的名称 (xxxx.jpg 类似带扩展名的文件名全称)
 */
- (instancetype)initWitAudioFilePath:(NSString*)aAudioFilePath
                          imageNames:(NSArray*)aImageNamesArray
                            fileName:(NSString*)aFileName;
@end

NS_ASSUME_NONNULL_END

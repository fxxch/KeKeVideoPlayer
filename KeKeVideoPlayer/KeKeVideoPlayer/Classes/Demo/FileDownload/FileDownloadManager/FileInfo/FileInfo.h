//
//  FileInfo.h
//  Demo
//
//  Created by liubo on 2021/10/19.
//  Copyright © 2021 KeKeStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileInfo : NSObject

@property (nonatomic , copy) NSString *url;
@property (nonatomic , assign) BOOL isFinished;
@property (nonatomic , copy) NSString *progress;
@property (nonatomic , copy) NSString *byteString;

@end

NS_ASSUME_NONNULL_END

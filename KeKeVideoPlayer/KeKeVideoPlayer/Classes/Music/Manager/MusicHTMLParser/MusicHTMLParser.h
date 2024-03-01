//
//  MusicHTMLParser.h
//  Music
//
//  Created by edward lannister on 2022/08/11.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger,MusicHTMLParserType) {
    
    MusicHTMLParserType_Audio = 0,/* 音频 */

    MusicHTMLParserType_Video = 1,/* 视频 */

    MusicHTMLParserType_Directory = 2,/* 目录 */
};


@interface MusicHTMLParser : NSObject

+ (NSArray*)parserHTMLParser:(HTMLParser*)parser type:(MusicHTMLParserType)aType;

@end

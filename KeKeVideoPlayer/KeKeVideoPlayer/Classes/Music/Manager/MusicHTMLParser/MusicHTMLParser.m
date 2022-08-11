//
//  MusicHTMLParser.m
//  Music
//
//  Created by edward lannister on 2022/08/11.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicHTMLParser.h"

@implementation MusicHTMLParser

+ (NSArray*)parserHTMLParser:(HTMLParser*)parser type:(MusicHTMLParserType)aType{
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    HTMLNode *body = [parser body];
    HTMLNode *tableTag = [body findChildTag:@"table"];
    NSArray *tags = [tableTag findChildTags:@"tr"];

    for (int i=0; i<[tags count]; i++) {
        HTMLNode *tr_Node = [tags objectAtIndex:i];
        HTMLNode *top_node = [tr_Node findChildWithAttribute:@"valign" matchingName:@"top" allowPartial:YES];
        if (top_node==nil) {
            continue;
        }
        else{
            HTMLNode *imgNode = [top_node findChildTag:@"img"];
            if (imgNode==nil) {
                continue;
            }
            else{
                NSString *alt = [imgNode getAttributeNamed:@"alt"];
                if ([alt isEqualToString:@"[ICO]"]) {
                    continue;
                }
                else{
                    HTMLNode *a_node = [tr_Node findChildTag:@"a"];
                    if (a_node) {
                        //NSString *name = [a_node contents]; 中文有乱码，暂时无法解决
                        NSString *href = [[a_node getAttributeNamed:@"href"] kk_KKURLDecodedString];
                        href = [href stringByReplacingOccurrencesOfString:@"/" withString:@""];
                        if ([href hasPrefix:@"."]) {
                            href = [href stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                        }

                        NSString *nodeType = alt;
                        if ([nodeType isEqualToString:@"[DIR]"]) {
                            KKLogDebugFormat(@"找到目录：%@",href);
                            if (aType==MusicHTMLParserType_Directory) {
                                [returnArray addObject:href];
                            }
                        }
                        else{
                            if ([NSFileManager kk_isFileType_AUDIO:[href pathExtension]]) {
                                if (aType==MusicHTMLParserType_Audio) {
                                    [returnArray addObject:href];
                                }
                            }
                            else if ([NSFileManager kk_isFileType_AUDIO:[href pathExtension]]) {
                                KKLogDebugFormat(@"找到视频文件：%@",href);

                            }
                            else{
                                KKLogDebugFormat(@"找到q其他文件：%@",href);

                            }
                        }
                    }
                    else{
                        KKLogDebugFormat(@"没有找到超链接标签");
                    }
                }
            }
        }
    }

    return returnArray;
}

@end

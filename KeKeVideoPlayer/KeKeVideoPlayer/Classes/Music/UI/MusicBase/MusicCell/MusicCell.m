//
//  MusicCell.m
//  Music
//
//  Created by edward lannister on 2022/08/08.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import "MusicCell.h"

@implementation MusicCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    self.icon_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
    [self.icon_imageView kk_setCornerRadius:5];
    [self.contentView addSubview:self.icon_imageView];
    
    CGFloat nameHeight = [UIFont kk_sizeOfFont:[UIFont boldSystemFontOfSize:16]].height;
    self.name_Label  = [[UILabel alloc] initWithFrame:CGRectMake(85, 10, KKScreenWidth-85, nameHeight)];
    self.name_Label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.name_Label.font = [UIFont boldSystemFontOfSize:16];
    self.name_Label.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.name_Label];

    CGFloat artistHeight = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:12]].height;
    self.artist_Label  = [[UILabel alloc] initWithFrame:CGRectMake(85, self.name_Label.kk_bottom+5, KKScreenWidth-85-15-30-10, artistHeight)];
    self.artist_Label.font = [UIFont systemFontOfSize:12];
    self.artist_Label.textColor = Theme_Color_999999;
    [self.contentView addSubview:self.artist_Label];

    CGFloat fileSizeHeight = [UIFont kk_sizeOfFont:[UIFont systemFontOfSize:12]].height;
    self.fileSize_Label  = [[UILabel alloc] initWithFrame:CGRectMake(85, self.artist_Label.kk_bottom+5, KKScreenWidth-85-15-30-10, fileSizeHeight)];
    self.fileSize_Label.font = [UIFont systemFontOfSize:12];
    self.fileSize_Label.textColor = Theme_Color_999999;
    [self.contentView addSubview:self.fileSize_Label];

    self.tag_Button = [[UIButton alloc] initWithFrame:CGRectMake(KKScreenWidth-15-30, self.name_Label.kk_bottom+5, 30, 30)];
    [self.tag_Button setBackgroundImage:KKThemeImage(@"Music_btn_cell_tag") forState:UIControlStateNormal];
    [self.tag_Button addTarget:self action:@selector(tagButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.tag_Button];
}

+ (CGFloat)cellHeightWithInformation:(NSDictionary*)aInformation{
    return 80;
    
}

- (void)reloadWithInformation:(NSDictionary*)aInformation{
    
    self.cellInformation = nil;
    self.cellInformation = aInformation;

    NSString *name = [self.cellInformation kk_validStringForKey:Table_Media_local_name];
    self.name_Label.text = name;
    
    NSString *identifier = [self.cellInformation kk_validStringForKey:Table_Media_identifier];
    NSString *filePath = [KKFileCacheManager cacheDataPath:identifier];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];

    AVURLAsset *avURLAsset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    CMTime audioDuration = avURLAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
//      NSLog(@"duration:%f",audioDurationSeconds);

    NSString *time = nil;
    int HH = audioDurationSeconds/(60*60);
    int MM = (audioDurationSeconds - HH*(60*60))/60;
    int SS = audioDurationSeconds - HH*(60*60) - MM*60;
    if (HH>0) {
        time = [NSString stringWithFormat:@"%02d:%02d:%02d",HH,MM,SS];
    }
    else{
        time = [NSString stringWithFormat:@"%02d:%02d",MM,SS];
    }
    
    long long fileSize = [NSFileManager kk_fileSizeAtPath:filePath];
    NSString *fileSizeFormatted = [NSFileManager kk_fileSizeStringFormat:fileSize];

    NSString *artist_name = nil;//歌手
    NSString *artist_album = nil;//专辑名
    UIImage *artwork = nil;//图片
    for (NSString *format in [avURLAsset availableMetadataFormats]) {
        for (AVMetadataItem *metadata in [avURLAsset metadataForFormat:format]) {
//            NSLog(@"commonKey:%@,key:%@ duration:%f",metadata.commonKey,metadata.key,CMTimeGetSeconds(metadata.duration));
//                //歌名
//                if([metadata.commonKey isEqualToString:@"title"]){
//                    NSString *title = (NSString*)metadata.value;
//                }
            //歌手
            if([metadata.commonKey isEqualToString:@"artist"]){
                NSString *title = (NSString*)metadata.value;
                artist_name = title;
            }
            //专辑名
            if([metadata.commonKey isEqualToString:@"albumName"]){
                NSString *title = (NSString*)metadata.value;
                artist_album = title;
            }
            //图片
            if([metadata.commonKey isEqualToString:@"artwork"]){
                if (metadata.value && [metadata.value isKindOfClass:[NSData class]]) {
                    artwork = [UIImage imageWithData:(NSData*)metadata.value];
                }
            }
        }
    }

    if (artwork) {
        self.icon_imageView.image = artwork;
    }
    else{
        self.icon_imageView.image = KKThemeImage(@"Music_placeholder");
    }
    
    if ([NSString kk_isStringNotEmpty:artist_name]) {
        if ([NSString kk_isStringNotEmpty:artist_album]) {
            self.artist_Label.text = [NSString stringWithFormat:@"歌手：%@  专辑：%@",artist_name,artist_album];
        }
        else{
            self.artist_Label.text = [NSString stringWithFormat:@"歌手：%@",artist_name];
        }
    }
    else{
        if ([NSString kk_isStringNotEmpty:artist_album]) {
            self.artist_Label.text = [NSString stringWithFormat:@"歌手：未知  专辑：%@",artist_album];
        }
        else{
            self.artist_Label.text = @"歌手：未知";
        }
    }

    self.fileSize_Label.text = [NSString stringWithFormat:@"%@  %@",time,fileSizeFormatted];;

}


- (void)tagButtonClicked{
    
}

@end

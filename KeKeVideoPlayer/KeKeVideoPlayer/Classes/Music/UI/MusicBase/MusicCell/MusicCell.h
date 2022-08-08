//
//  MusicCell.h
//  Music
//
//  Created by edward lannister on 2022/08/08.
//  Copyright © 2022 KeKeStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVMetadataItem.h>


@interface MusicCell : UITableViewCell

@property (nonatomic , strong) UIImageView *icon_imageView;
@property (nonatomic , strong) UILabel *name_Label;
@property (nonatomic , strong) UILabel *artist_Label;
@property (nonatomic , strong) UILabel *fileSize_Label;
@property (nonatomic , strong) UIButton *tag_Button;


@property (nonatomic,strong)NSDictionary *cellInformation;

+ (CGFloat)cellHeightWithInformation:(NSDictionary*)aInformation;

- (void)reloadWithInformation:(NSDictionary*)aInformation;

@end

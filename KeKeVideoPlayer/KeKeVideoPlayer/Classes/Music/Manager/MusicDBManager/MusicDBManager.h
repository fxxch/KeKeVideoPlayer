//
//  MusicDBManager.h
//  BM
//
//  Created by 刘波 on 2020/3/1.
//  Copyright © 2020 bm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <fmdb/FMDB.h>

@interface FMDatabase (MusicDBManager)

- (NSArray*)kkMusic_getTableColumnNames:(NSString*)tableName;

@end

#define MusicDBManager_DBName @"MusicDBManager.sqlite"

#define TableName_Media @"Media"
#pragma mark ==================================================
#pragma mark == Media
#pragma mark ==================================================
#define Table_Media_id                          @"id" //自增字段
/* 文件标示符（一般是文件的远程URL字符串）*/
#define Table_Media_identifier                  @"identifier"
/* 文件远程URL*/
#define Table_Media_url                         @"remote_url"
/* 所处的文件夹类型Web_Image、Album_Image…… */
#define Table_Media_cache_directory             @"cache_directory"
/* 文件扩展名（PNG、MP4、pdf…………）*/
#define Table_Media_extention                   @"extention"
/* 文件本地路径*/
#define Table_Media_local_path                  @"local_path"
/* 本地文件名(20141212_094434_123999) */
#define Table_Media_local_name                  @"local_name"
/* 本地文件名(20141212_094434_123999.png) */
#define Table_Media_local_full_name             @"local_full_name"
/* 远程文件名/显示的文件名(国庆出游.png) */
#define Table_Media_display_name                @"display_name"
/* 文件信息（扩展字段）*/
#define Table_Media_extra_information           @"extra_information"
/* timestamp */
#define Table_Media_timestamp                   @"timestamp"

#define TableName_Tag @"Tag"
#pragma mark ==================================================
#pragma mark == Tag 标签表
#pragma mark ==================================================
#define Table_Tag_tag_id                        @"tag_id" //自增字段
/* 标签名字*/
#define Table_Tag_tag_name                      @"tag_name"

#define TableName_MediaTag @"MediaTag"
#pragma mark ==================================================
#pragma mark == MediaTag 标签关系表
#pragma mark ==================================================
#define Table_MediaTag_media_tag_id             @"media_tag_id" //自增字段
/* 文件标示符（一般是文件的远程URL字符串）*/
#define Table_MediaTag_media_identifier         @"media_identifier"
/* 标签Id*/
#define Table_MediaTag_tag_Id                   @"tag_id"

@interface MusicDBManager : NSObject{
    FMDatabaseQueue *m_db;
}

@property (nonatomic,strong) FMDatabaseQueue *db;

+ (MusicDBManager *)defaultManager;

- (void)openDB;

- (void)closeDB;

#pragma mark ==================================================
#pragma mark == 公共方法
#pragma mark ==================================================
- (BOOL)DBQuery_Table:(NSString*)tableName isExistValue:(NSString*)aValue forKey:(NSString*)aKey;

#pragma mark ==================================================
#pragma mark == Media
#pragma mark ==================================================
- (BOOL)DBInsert_Media_Information:(NSDictionary*_Nullable)aInformation;

- (BOOL)DBDelete_Media_WithIdentifer:(NSString*_Nullable)aIdentifier;

- (NSDictionary*_Nullable)DBQuery_Media_WithIdentifer:(NSString*_Nullable)aIdentifier;

- (NSArray*_Nullable)DBQuery_Media_All;

- (NSArray*_Nullable)DBQuery_Media_NotTag;

- (NSArray*_Nullable)DBQuery_Media_WithTagId:(NSString*_Nullable)aTagId;


#pragma mark ==================================================
#pragma mark == Tag
#pragma mark ==================================================
- (BOOL)DBInsert_Tag_Name:(NSString*_Nullable)aName;

- (BOOL)DBDelete_Tag_WithName:(NSString*_Nullable)aName;

- (BOOL)DBUpdate_Tag_WithName:(NSString*_Nullable)aName tagId:(NSString*_Nullable)aTagId;

- (NSDictionary*_Nullable)DBQuery_Tag_WithName:(NSString*_Nullable)aName;

- (NSArray*_Nullable)DBQuery_Tag_All;

#pragma mark ==================================================
#pragma mark == MediaTag
#pragma mark ==================================================
- (BOOL)DBInsert_MediaTag_WithMediaIdentifer:(NSString*_Nullable)aIdentifier tagId:(NSString*_Nullable)aTagId;

- (BOOL)DBDelete_MediaTag_WithMediaIdentifer:(NSString*_Nullable)aIdentifier tagId:(NSString*_Nullable)aTagId;

- (BOOL)DBDelete_MediaTag_WithMediaIdentifer:(NSString*_Nullable)aIdentifier;

- (BOOL)DBDelete_MediaTag_WithTagId:(NSString*_Nullable)aTagId;

- (NSDictionary*_Nullable)DBQuery_MediaTag_WithMediaIdentifer:(NSString*_Nullable)aIdentifier tagId:(NSString*_Nullable)aTagId;

@end

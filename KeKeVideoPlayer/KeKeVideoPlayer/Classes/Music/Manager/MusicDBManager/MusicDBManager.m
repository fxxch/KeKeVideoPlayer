//
//  MusicDBManager.m
//  BM
//
//  Created by 刘波 on 2020/3/1.
//  Copyright © 2020 bm. All rights reserved.
//

#import "MusicDBManager.h"
#import "KKLog.h"
#import "KKCategory.h"

@implementation FMDatabase (MusicDBManager)

- (NSArray*)kkMusic_getTableColumnNames:(NSString*)tableName{

    FMResultSet *rs = [self getTableSchema:[tableName lowercaseString]];

    NSMutableArray *namesArray = [NSMutableArray array];
    //check if column is present in table schema
    while ([rs next]) {
        NSString *name = [rs stringForColumn:@"name"];
        if (name && [name length]>0) {
            [namesArray addObject:name];
        }
    }

    //If this is not done FMDatabase instance stays out of pool
    [rs close];

    return namesArray;
}

@end


@implementation MusicDBManager
@synthesize db = m_db;

- (void)dealloc{
    [m_db close];
}

+ (MusicDBManager *)defaultManager {
    static MusicDBManager *MusicDBManager_defaultManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        MusicDBManager_defaultManager = [[self alloc] init];
    });
    return MusicDBManager_defaultManager;
}


#pragma mark ==================================================
#pragma mark == 实例化DB
#pragma mark ==================================================
- (id)init{
    if (self = [super init]) {
        [self openDB];
    }
    return self;
}

- (void)openDB{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:MusicDBManager_DBName];

    //拷贝已经存在的（内置）数据库文件 到 document目录下
    NSFileManager* file = [NSFileManager defaultManager];
    if (![file fileExistsAtPath:dbPath]) {
        NSString* path = [[NSBundle mainBundle] pathForResource:MusicDBManager_DBName ofType:nil];
        NSError* error = nil;
        [file copyItemAtPath:path toPath:dbPath error:&error];
    }

    [self closeDB];

    m_db = [[FMDatabaseQueue alloc] initWithPath:dbPath] ;
    if (!m_db) {
        KKLogError(@"数据库拷贝失败");
    }
}

- (void)closeDB{
    [m_db close];
    m_db = nil;
}

#pragma mark ==================================================
#pragma mark == 公共方法
#pragma mark ==================================================
- (BOOL)DBQuery_Table:(NSString*)tableName isExistValue:(NSString*)aValue forKey:(NSString*)aKey{
    __block NSString *selectSql = [NSString stringWithFormat:@"SELECT count(1) FROM %@ where %@=? ",tableName,aKey];
    __block NSInteger count = 0;

    [m_db inDatabase:^(FMDatabase *db){
        count = [db intForQuery: selectSql,aValue];
    }];

    if (count>0) {
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)DBDelete_Table:(NSString*)tableName withValue:(NSString*)aValue forKey:(NSString*)aKey{
    __block NSString *selectSql = [NSString stringWithFormat:@"Delete FROM %@ where %@=? ",tableName,aKey];
    __block NSInteger count = 0;

    [m_db inDatabase:^(FMDatabase *db){
        count = [db intForQuery: selectSql,aValue];
    }];

    if (count>0) {
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)DBUpdate_Table:(NSString*)tableName withValue:(NSString*)aValue forKey:(NSString*)aKey{

    NSString *updateSql = [NSString stringWithFormat:@"Update %@ set %@=? ",tableName,aKey];
    __block BOOL result = NO;

    [m_db inDatabase:^(FMDatabase *db){

        result = [db executeUpdate:updateSql,aValue];

        if (!result) {
            KKLogErrorFormat(@"数据库操作失败：%s",__FUNCTION__);
        }
    }];

    return result;
}

/**
 清空表
 */
- (BOOL)DBTruncate_Table:(NSString*)tableName{

    __block BOOL result = NO;
    //插入数据
    NSString *updateSql = [NSString stringWithFormat:@"Delete From %@",tableName];

    [m_db inDatabase:^(FMDatabase *db){

        result = [db executeUpdate:updateSql];

        if (!result) {
            KKLogErrorFormat(@"数据库操作失败：%s",__FUNCTION__);
        }
    }];

    return  result;
}

/**
 * 将数据库查询出来的数据，自动封装成Dictionary
 */
- (NSDictionary*)dictionaryFromFMResultSet:(FMResultSet*)rs{
    if (rs && rs.columnNameToIndexMap) {
        NSArray *columnNameArray = [rs.columnNameToIndexMap allKeys];
        if ([columnNameArray count]>0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (NSInteger i=0; i<[columnNameArray count]; i++) {
                NSString *columnName = [columnNameArray objectAtIndex:i];
                NSString *value = [rs stringForColumn:columnName];
                if (value && ![value isKindOfClass:[NSNull class]]) {
                    [dic setObject:value forKey:columnName];
                }
                else{
                    [dic setObject:@"" forKey:columnName];
                }
            }
            return dic;
        }
        else{
            return nil;
        }
    }
    else{
        return nil;
    }
}

/**
 * 将Dictionary插入到数据库对应的表中
 */
- (BOOL)insertInformation:(NSDictionary*)aInformation toTable:(NSString*)aTableName{

    __block BOOL result = NO;

    [m_db inDatabase:^(FMDatabase *db){

        NSMutableDictionary *ParameterDictionary = [NSMutableDictionary dictionary];

        NSArray *tableColumnNamesArray = [db getTableColumnNames:aTableName];

        if ([tableColumnNamesArray count]>0) {
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (",aTableName];
            NSString *insertSql_Values = [NSString stringWithFormat:@" VALUES ("];

            for (NSInteger i=0; i<[tableColumnNamesArray count]; i++) {
                NSString *columnName = [tableColumnNamesArray objectAtIndex:i];
                if (i==[tableColumnNamesArray count]-1) {
                    insertSql = [insertSql stringByAppendingFormat:@"%@)",columnName];
                    insertSql_Values = [insertSql_Values stringByAppendingFormat:@":%@)",columnName];
                }
                else{
                    insertSql = [insertSql stringByAppendingFormat:@"%@,",columnName];
                    insertSql_Values = [insertSql_Values stringByAppendingFormat:@":%@,",columnName];
                }

                NSObject *value = [aInformation objectForKey:columnName];
                if (value && [value isKindOfClass:[NSString class]]) {
                    [ParameterDictionary setObject:(NSString*)value forKey:columnName];
                }
                else if (value && [value isKindOfClass:[NSDictionary class]]){
                    [ParameterDictionary setObject:(NSString*)[(NSDictionary*)value kk_translateToJSONString] forKey:columnName];
                }
                else if (value && [value isKindOfClass:[NSArray class]]){
                    [ParameterDictionary setObject:(NSString*)[(NSArray*)value kk_translateToJSONString] forKey:columnName];
                }
                else if (value && [value isKindOfClass:[NSNumber class]]){
                    [ParameterDictionary setObject:[(NSNumber*)value stringValue] forKey:columnName];
                }
                else{
                    [ParameterDictionary setObject:[NSNull null] forKey:columnName];
                }
            }

            insertSql = [insertSql stringByAppendingString:insertSql_Values];

            result = [db executeUpdate:insertSql withParameterDictionary:ParameterDictionary];

            if (!result) {
                KKLogErrorFormat(@"数据库操作失败：%s",__FUNCTION__);
            }
        }
    }];

    return result;
}

#pragma mark ==================================================
#pragma mark == Media
#pragma mark ==================================================
- (BOOL)DBInsert_Media_Information:(NSDictionary*_Nullable)aInformation{
    if ([NSDictionary kk_isDictionaryEmpty:aInformation]) {
        return NO;
    }

    //存在该条数据【删除】
    NSString *identifer  = [aInformation kk_validStringForKey:Table_Media_identifier];
    NSDictionary *oldInformation = [self DBQuery_Media_WithIdentifer:identifer];
    if ([NSDictionary kk_isDictionaryNotEmpty:oldInformation]) {
        [self DBDelete_Media_WithIdentifer:identifer];
    }
    
    NSMutableDictionary *dictionaryInsert = [NSMutableDictionary dictionary];
    [dictionaryInsert setValuesForKeysWithDictionary:aInformation];
    
    NSString *timestamp = [NSDate kk_getStringWithFormatter:KKDateFormatter01];
    [dictionaryInsert setObject:timestamp forKey:Table_Media_timestamp];

    BOOL result =  [self insertInformation:dictionaryInsert toTable:TableName_Media];

    return  result;
}

- (BOOL)DBDelete_Media_WithIdentifer:(NSString*_Nullable)aIdentifier{
    if ([NSString kk_isStringEmpty:aIdentifier]) {
        return NO;
    }
    
    __block NSString *selectSql = [NSString stringWithFormat:@"Delete FROM %@ where %@=? ",TableName_Media,Table_Media_identifier];
    __block NSInteger count = 0;

    [m_db inDatabase:^(FMDatabase *db){
        count = [db intForQuery: selectSql,aIdentifier];
    }];

    if (count>0) {
        return YES;
    }
    else{
        return NO;
    }
}

- (NSDictionary*_Nullable)DBQuery_Media_WithIdentifer:(NSString*_Nullable)aIdentifier{
    if ([NSString kk_isStringEmpty:aIdentifier]) {
        return nil;
    }

    NSString *selectSql = [NSString stringWithFormat:@" SELECT * FROM %@ "
                           " where %@ = ?",TableName_Media,Table_Media_identifier];

    __block NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [m_db inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery: selectSql,aIdentifier];
        while ([rs next]) {
            NSDictionary *dictionary = [MusicDBManager.defaultManager dictionaryFromFMResultSet:rs];
            [dic setValuesForKeysWithDictionary:dictionary];
        }
        [rs close];
    }];

    return dic;
}

- (NSArray*_Nullable)DBQuery_Media_All{
    NSString *selectSql = [NSString stringWithFormat:@" SELECT * FROM %@ ",TableName_Media];

    __block NSMutableArray *array = [[NSMutableArray alloc] init];

    [m_db inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery: selectSql];
        while ([rs next]) {
            NSDictionary *dictionary = [MusicDBManager.defaultManager dictionaryFromFMResultSet:rs];
            [array addObject:dictionary];
        }
        [rs close];
    }];

    return array;
}

- (NSArray*_Nullable)DBQuery_Media_NotTag{
    NSString *selectSql = [NSString stringWithFormat:@" SELECT * FROM %@ where identifier not in (select distinct media_identifier from MediaTag)",TableName_Media];

    __block NSMutableArray *array = [[NSMutableArray alloc] init];

    [m_db inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery: selectSql];
        while ([rs next]) {
            NSDictionary *dictionary = [MusicDBManager.defaultManager dictionaryFromFMResultSet:rs];
            [array addObject:dictionary];
        }
        [rs close];
    }];

    return array;
}

- (NSArray*_Nullable)DBQuery_Media_WithTagId:(NSString*_Nullable)aTagId{
    NSString *selectSql = [NSString stringWithFormat:@" SELECT * FROM %@ where identifier in (select media_identifier from MediaTag where tag_id=?)",TableName_Media];

    __block NSMutableArray *array = [[NSMutableArray alloc] init];

    [m_db inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery: selectSql,aTagId];
        while ([rs next]) {
            NSDictionary *dictionary = [MusicDBManager.defaultManager dictionaryFromFMResultSet:rs];
            [array addObject:dictionary];
        }
        [rs close];
    }];

    return array;
}

#pragma mark ==================================================
#pragma mark == Tag
#pragma mark ==================================================
- (BOOL)DBInsert_Tag_Name:(NSString*_Nullable)aName{
    if ([NSString kk_isStringEmpty:aName]) {
        return NO;
    }

    //存在该条数据【删除】
    NSDictionary *oldInformation = [self DBQuery_Tag_WithName:aName];
    if ([NSDictionary kk_isDictionaryNotEmpty:oldInformation]) {
        return NO;
    }
    
    NSMutableDictionary *dictionaryInsert = [NSMutableDictionary dictionary];
    [dictionaryInsert setObject:aName forKey:Table_Tag_tag_name];

    BOOL result =  [self insertInformation:dictionaryInsert toTable:TableName_Tag];

    return  result;
}

- (BOOL)DBDelete_Tag_WithName:(NSString*_Nullable)aName{
    if ([NSString kk_isStringEmpty:aName]) {
        return NO;
    }
    
    __block NSString *selectSql = [NSString stringWithFormat:@"Delete FROM %@ where %@=? ",TableName_Tag,Table_Tag_tag_name];
    __block NSInteger count = 0;

    [m_db inDatabase:^(FMDatabase *db){
        count = [db intForQuery: selectSql,aName];
    }];

    if (count>0) {
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)DBUpdate_Tag_WithName:(NSString*_Nullable)aName tagId:(NSString*_Nullable)aTagId{
    if ([NSString kk_isStringEmpty:aName]) {
        return NO;
    }
    if ([NSString kk_isStringEmpty:aTagId]) {
        return NO;
    }

    NSString *updateSql = [NSString stringWithFormat:@"Update %@ set %@=? where %@=?",TableName_Tag,Table_Tag_tag_name,Table_Tag_tag_id];
    __block BOOL result = NO;

    [m_db inDatabase:^(FMDatabase *db){

        result = [db executeUpdate:updateSql,aName,aTagId];

        if (!result) {
            KKLogErrorFormat(@"数据库操作失败：%s",__FUNCTION__);
        }
    }];

    return result;

}

- (NSDictionary*_Nullable)DBQuery_Tag_WithName:(NSString*_Nullable)aName{
    if ([NSString kk_isStringEmpty:aName]) {
        return nil;
    }

    NSString *selectSql = [NSString stringWithFormat:@" SELECT * FROM %@ "
                           " where %@ = ?",TableName_Tag,Table_Tag_tag_name];

    __block NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [m_db inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery: selectSql,aName];
        while ([rs next]) {
            NSDictionary *dictionary = [MusicDBManager.defaultManager dictionaryFromFMResultSet:rs];
            [dic setValuesForKeysWithDictionary:dictionary];
        }
        [rs close];
    }];

    return dic;
}

- (NSArray*_Nullable)DBQuery_Tag_All{

    NSString *selectSql = [NSString stringWithFormat:@" SELECT * FROM %@ ",TableName_Tag];

    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [m_db inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery: selectSql];
        while ([rs next]) {
            NSDictionary *dictionary = [MusicDBManager.defaultManager dictionaryFromFMResultSet:rs];
            [array addObject:dictionary];
        }
        [rs close];
    }];

    return array;
}

#pragma mark ==================================================
#pragma mark == MediaTag
#pragma mark ==================================================
- (BOOL)DBInsert_MediaTag_WithMediaIdentifer:(NSString*_Nullable)aIdentifier tagId:(NSString*_Nullable)aTagId{
    if ([NSString kk_isStringEmpty:aIdentifier]) {
        return NO;
    }
    if ([NSString kk_isStringEmpty:aTagId]) {
        return NO;
    }

    //存在该条数据【删除】
    NSDictionary *oldInformation = [self DBQuery_MediaTag_WithMediaIdentifer:aIdentifier tagId:aTagId];
    if ([NSDictionary kk_isDictionaryNotEmpty:oldInformation]) {
        return NO;
    }

    NSMutableDictionary *aInformation = [NSMutableDictionary dictionary];
    [aInformation setObject:aIdentifier forKey:Table_MediaTag_media_identifier];
    [aInformation setObject:aTagId forKey:Table_MediaTag_media_tag_id];
    
    BOOL result =  [self insertInformation:aInformation toTable:TableName_MediaTag];

    return  result;
}

- (BOOL)DBDelete_MediaTag_WithMediaIdentifer:(NSString*_Nullable)aIdentifier tagId:(NSString*_Nullable)aTagId{
    if ([NSString kk_isStringEmpty:aIdentifier]) {
        return NO;
    }
    if ([NSString kk_isStringEmpty:aTagId]) {
        return NO;
    }

    __block NSString *selectSql = [NSString stringWithFormat:@"Delete FROM %@ where %@ = ? and %@ = ? ",TableName_MediaTag,Table_MediaTag_media_identifier,Table_MediaTag_tag_Id];
    __block NSInteger count = 0;

    [m_db inDatabase:^(FMDatabase *db){
        count = [db intForQuery: selectSql,aIdentifier,aTagId];
    }];

    if (count>0) {
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)DBDelete_MediaTag_WithMediaIdentifer:(NSString*_Nullable)aIdentifier{
    if ([NSString kk_isStringEmpty:aIdentifier]) {
        return NO;
    }

    __block NSString *selectSql = [NSString stringWithFormat:@"Delete FROM %@ where %@ = ? ",TableName_MediaTag,Table_MediaTag_media_identifier];
    __block NSInteger count = 0;

    [m_db inDatabase:^(FMDatabase *db){
        count = [db intForQuery: selectSql,aIdentifier];
    }];

    if (count>0) {
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)DBDelete_MediaTag_WithTagId:(NSString*_Nullable)aTagId{
    if ([NSString kk_isStringEmpty:aTagId]) {
        return NO;
    }

    __block NSString *selectSql = [NSString stringWithFormat:@"Delete FROM %@ where %@ = ? ",TableName_MediaTag,Table_MediaTag_tag_Id];
    __block NSInteger count = 0;

    [m_db inDatabase:^(FMDatabase *db){
        count = [db intForQuery: selectSql,aTagId];
    }];

    if (count>0) {
        return YES;
    }
    else{
        return NO;
    }
}


- (NSDictionary*_Nullable)DBQuery_MediaTag_WithMediaIdentifer:(NSString*_Nullable)aIdentifier tagId:(NSString*_Nullable)aTagId{
    if ([NSString kk_isStringEmpty:aIdentifier]) {
        return nil;
    }
    if ([NSString kk_isStringEmpty:aTagId]) {
        return nil;
    }

    NSString *selectSql = [NSString stringWithFormat:@" SELECT * FROM %@ "
                           " where %@ = ? and %@ = ? ",TableName_MediaTag,Table_MediaTag_media_identifier,Table_MediaTag_tag_Id];

    __block NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [m_db inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery: selectSql,aIdentifier,aTagId];
        while ([rs next]) {
            NSDictionary *dictionary = [MusicDBManager.defaultManager dictionaryFromFMResultSet:rs];
            [dic setValuesForKeysWithDictionary:dictionary];
        }
        [rs close];
    }];

    return dic;
}

@end

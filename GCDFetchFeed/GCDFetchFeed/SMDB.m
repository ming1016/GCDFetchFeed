//
//  SMDB.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/2/23.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMDB.h"


@interface SMDB()

@property (nonatomic, copy) NSString *dbPath;
@property (nonatomic, assign) SMDBTable dbTable;
@property (nonatomic, copy) NSString *dbName;
@property (nonatomic, copy) NSString *dbCreateSql;

@end

@implementation SMDB

#pragma mark - Life Cycle
- (instancetype)initWithDBTable:(SMDBTable)dbTable {
    if (self = [super init]) {
        self.dbTable = dbTable;
        
    }
    return self;
}

- (void)createTableWithSql:(NSString *)sql {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dbPath] == NO) {
        FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
        if ([db open]) {
            NSString *sql = @"";
        }
    }
}

#pragma mark - Interface
- (void)executeUpdateWithSql:(NSString *)sql {
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        BOOL result = [db executeUpdate:sql];
        if (!result) {
            //出错时的处理
        }
        [db close];
    }
}
- (FMResultSet *)executeQueryWithSql:(NSString *)sql {
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        FMResultSet *resultSet = [db executeQuery:sql];
        [db close];
        return resultSet;
    }
    return nil;
}

#pragma mark - Private

#pragma mark - Getter
- (NSString *)dbCreateSql {
    if (!_dbCreateSql) {
        switch (self.dbTable) {
            case SMDBTableTypeFeeds:
                _dbCreateSql = @"";
                break;
            case SMDBTableTypeFeedItem:
                _dbCreateSql = @"";
                break;
            default:
                break;
        }
    }
    return _dbCreateSql;
}
- (NSString *)dbName {
    if (!_dbName) {
        switch (self.dbTable) {
            case SMDBTableTypeFeeds:
                _dbName = @"feeds";
                break;
            case SMDBTableTypeFeedItem:
                _dbName = @"feedItem";
                break;
            default:
                break;
        }
    }
    return _dbName;
}
- (NSString *)dbPath {
    if (!_dbPath) {
        _dbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",self.dbName]];
    }
    return _dbPath;
}


@end

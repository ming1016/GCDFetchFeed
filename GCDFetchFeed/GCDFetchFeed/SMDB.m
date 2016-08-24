//
//  SMDB.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/2/23.
//  Copyright © 2016年 Starming. All rights reserved.
//

//打开当前模拟器目录po NSHomeDirectory()
//platform shell open /Users/xxx/Library/CoreSimulator/...上面打印出来的模拟器地址

#import "SMDB.h"


@interface SMDB()

@property (nonatomic, copy) NSString *feedDBPath;
@property (nonatomic, copy) NSString *feedItemDBPath;

@end

@implementation SMDB

#pragma mark - Life Cycle
+ (SMDB *)shareInstance {
    static SMDB *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SMDB alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {

        _feedDBPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"feeds.sqlite"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_feedDBPath] == NO) {
            FMDatabase *db = [FMDatabase databaseWithPath:_feedDBPath];
            if ([db open]) {
                NSString *createSql = @"create table feeds (fid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, title text, link text, des text, copyright text, generator text, imageurl text, feedurl text, unread integer)";
                [db executeUpdate:createSql];
                NSString *createItemSql = @"create table feeditem (iid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, fid integer, link text, title text, author text, category text, pubdate text, des blob, isread integer)";
                [db executeUpdate:createItemSql];
            }
        }
        
    }
    return self;
}
#pragma mark - DB Operate
- (RACSignal *)insertWithFeedModel:(SMFeedModel *)feedModel {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            //检查是否存在这个feed
            FMResultSet *rsl = [db executeQuery:@"select fid from feeds where feedurl = ?",feedModel.feedUrl];
            int fid = 0;
            if ([rsl next]) {
                //存在返回fid
                fid = [rsl intForColumn:@"fid"];
                
            } else {
                //不存在创建一个，同时返回fid
                [db executeUpdate:@"insert into feeds (title, link, des, copyright, generator, imageurl, feedurl) values (?, ?, ?, ?, ?, ?, ?)", feedModel.title, feedModel.link, feedModel.des, feedModel.copyright, feedModel.generator, feedModel.imageUrl, feedModel.feedUrl];
                
                FMResultSet *fidRsl = [db executeQuery:@"select fid from feeds where feedurl = ?",feedModel.feedUrl];
                if ([fidRsl next]) {
                    fid = [fidRsl intForColumn:@"fid"];
                }
                
            }
            //添加feed item
            if (feedModel.items.count > 0) {
                for (SMFeedItemModel *itemModel in feedModel.items) {
                    FMResultSet *iRsl = [db executeQuery:@"select iid from feeditem where link = ?",itemModel.link];
                    if ([iRsl next]) {
                    } else {
                        [db executeUpdate:@"insert into feeditem (fid, link, title, author, category, pubdate, des, isread) values (?, ?, ?, ?, ?, ?, ?, ?)", @(fid), itemModel.link, itemModel.title, itemModel.author, itemModel.category, itemModel.pubDate, itemModel.des, @0];
                    }
                }
            }
            //读取未读item数
            FMResultSet *uRsl = [db executeQuery:@"select iid from feeditem where fid = ? and isread = ?",@(fid), @0];
            NSUInteger count = 0;
            while ([uRsl next]) {
                count++;
            }
            feedModel.unReadCount = count;
            //存在的话同时更新下feed信息
            [db executeUpdate:@"update feeds set title = ?, link = ?, des = ?, copyright = ?, generator = ?, imageurl = ?, unread = ? where fid = ?",feedModel.title, feedModel.link, feedModel.des, feedModel.copyright, feedModel.generator, feedModel.imageUrl, @(count), @(fid)];
            //告知完成可以接下来的操作
            [subscriber sendNext:@(fid)];
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
    
}

- (RACSignal *)selectAllFeeds {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            FMResultSet *rs = [db executeQuery:@"select * from feeds"];
            NSUInteger count = 0;
            NSMutableArray *feedsArray = [NSMutableArray array];
            while ([rs next]) {
                SMFeedModel *feedModel = [[SMFeedModel alloc] init];
                feedModel.fid = [rs intForColumn:@"fid"];
                feedModel.title = [rs stringForColumn:@"title"];
                feedModel.link = [rs stringForColumn:@"link"];
                feedModel.des = [rs stringForColumn:@"des"];
                feedModel.copyright = [rs stringForColumn:@"copyright"];
                feedModel.generator = [rs stringForColumn:@"generator"];
                feedModel.imageUrl = [rs stringForColumn:@"imageurl"];
                feedModel.feedUrl = [rs stringForColumn:@"feedurl"];
                feedModel.unReadCount = [rs intForColumn:@"unread"];
                [feedsArray addObject:feedModel];
                count++;
            }
            [subscriber sendNext:feedsArray];
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}

- (RACSignal *)selectFeedItemsWithPage:(NSUInteger)page fid:(NSUInteger)fid {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            FMResultSet *rs = [db executeQuery:@"select * from feeditem where fid = ? order by iid desc limit ?, 20",@(fid), @(page * 20)];
            NSUInteger count = 0;
            NSMutableArray *feedItemsArray = [NSMutableArray array];
            while ([rs next]) {
                SMFeedItemModel *itemModel = [[SMFeedItemModel alloc] init];
                itemModel.iid = [rs intForColumn:@"iid"];
                itemModel.fid = [rs intForColumn:@"fid"];
                itemModel.link = [rs stringForColumn:@"link"];
                itemModel.title = [rs stringForColumn:@"title"];
                itemModel.author = [rs stringForColumn:@"author"];
                itemModel.category = [rs stringForColumn:@"category"];
                itemModel.pubDate = [rs stringForColumn:@"pubDate"];
                itemModel.des = [rs stringForColumn:@"des"];
                itemModel.isRead = [rs intForColumn:@"isread"];
                [feedItemsArray addObject:itemModel];
                count++;
            }
            if (count > 0) {
                [subscriber sendNext:feedItemsArray];
            } else {
                [subscriber sendError:nil];
            }
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}
//标注已读
- (RACSignal *)markFeedItemAsRead:(NSUInteger)iid {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            [db executeUpdate:@"update feeditem set isread = ? where iid = ?", @(1), @(iid)];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}

//标注全部已读
- (RACSignal *)markFeedAllItemsAsRead:(NSUInteger)fid {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            [db executeUpdate:@"update feeditem set isread = ? where fid = ?", @(1), @(fid)];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}



@end

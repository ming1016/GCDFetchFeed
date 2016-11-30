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
                /*
                 unread：未读数
                 updatetime：最后更新时间用来排序
                 ishide：是否隐藏，0表示显示，1表示不显示
                 */
                NSString *createSql = @"create table feeds (fid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, title text, link text, des text, copyright text, generator text, imageurl text, feedurl text, unread integer, updatetime integer, ishide integer)";
                [db executeUpdate:createSql];
                /*
                 des：正文内容
                 isread：是否点开查看过，0表示没看过，1表示看过
                 isCached：是否缓存了内容
                 thumbnails：图片集，各个图片地址使用|作为分隔符
                 */
                NSString *createItemSql = @"create table feeditem (iid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, fid integer, link text, title text, author text, category text, pubdate text, des blob, isread integer, iscached integer, thumbnails text)";
                [db executeUpdate:createItemSql];
            }
        }
        
    }
    return self;
}
#pragma mark - Interface
//清理数据
- (void)clearFeedItemByFid:(NSUInteger)fid db:(FMDatabase *)db {
    BOOL needCloseDb = NO;
    if (!db) {
        needCloseDb = YES;
        db = [FMDatabase databaseWithPath:self.feedDBPath];
        [db open];
    }
    FMResultSet *rs = [db executeQuery:@"select iid from feeditem where fid = ? and isread = ? order by iid asc",@(fid), @(1)];
    NSUInteger count = 0;
    while ([rs next]) {
        count += 1;
    }
    //本地存储数据超过400就开始清理，只保留最新200条
    if (count > 400) {
        [db executeUpdate:@"delete from feeditem where fid = ? and isread = ? order by iid asc limit 0, ?", @(fid), @(1), @(count - 200)];
    }
    if (needCloseDb) {
        [db close];
    }
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
                [db executeUpdate:@"insert into feeds (title, link, des, copyright, generator, imageurl, feedurl, ishide) values (?, ?, ?, ?, ?, ?, ?, ?)", feedModel.title, feedModel.link, feedModel.des, feedModel.copyright, feedModel.generator, feedModel.imageUrl, feedModel.feedUrl, @(0)];
                
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
                        //过滤字符串
                        NSString *badChars = @"\\\'";
                        NSCharacterSet *badCharSet = [NSCharacterSet characterSetWithCharactersInString: badChars];
                        itemModel.title = [itemModel.title stringByTrimmingCharactersInSet:badCharSet];
                        itemModel.des = [itemModel.des stringByTrimmingCharactersInSet:badCharSet];
                        //入库
                        [db executeUpdate:@"insert into feeditem (fid, link, title, author, category, pubdate, des, isread, iscached) values (?, ?, ?, ?, ?, ?, ?, ?, ?)", @(fid), itemModel.link, itemModel.title, itemModel.author, itemModel.category, itemModel.pubDate, itemModel.des, @0, @0];
                        [db executeUpdate:@"update feeds set updatetime = ? where fid = ?",@(time(NULL)),@(fid)];
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

//本地读取首页订阅源数据
- (RACSignal *)selectAllFeeds {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            FMResultSet *rs = [db executeQuery:@"select * from feeds where ishide = ? order by updatetime desc",@(0)];
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
                //feedicons
                if (feedModel.imageUrl.length > 0) {
                    NSString *fidStr = [NSString stringWithFormat:@"%lu",(unsigned long)feedModel.fid];
                    self.feedIcons[fidStr] = feedModel.imageUrl;
                }
            }
            [subscriber sendNext:feedsArray];
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}
//按照翻页取数据
- (RACSignal *)selectFeedItemsWithPage:(NSUInteger)page fid:(NSUInteger)fid {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            //分页获取
            FMResultSet *rs = [FMResultSet new];
            if (fid == 0) {
                rs = [db executeQuery:@"select * from feeditem where isread = ? order by iid desc limit ?, 50", @(0), @(page * 50)];
            } else {
                rs = [db executeQuery:@"select * from feeditem where fid = ? and isread = ? order by iid desc limit ?, 50",@(fid), @(0), @(page * 50)];
            }
            NSUInteger count = 0;
            NSMutableArray *feedItemsArray = [NSMutableArray array];
            //设置返回Array里的Model
            while ([rs next]) {
                SMFeedItemModel *itemModel = [self itmeModelFromResultSet:rs];
                [feedItemsArray addObject:itemModel];
                count++;
            }
            if (count > 0) {
                [subscriber sendNext:feedItemsArray];
            } else {
                //获取出错处理
                [subscriber sendError:nil];
            }
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}

//标记已读
- (RACSignal *)markFeedItemAsRead:(NSUInteger)iid fid:(NSUInteger)fid{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            FMResultSet *rs = [FMResultSet new];
            if (fid == 0) {
                rs = [db executeQuery:@"select * from feeditem where isread = ? and iid >= ? order by iid desc", @(0), @(iid)];
            } else {
                rs = [db executeQuery:@"select * from feeditem where isread = ? and iid >= ? and fid = ? order by iid desc", @(0), @(iid), @(fid)];
            }
            NSUInteger count = 0;
            while ([rs next]) {
                count++;
            }
            if (fid == 0) {
                [db executeUpdate:@"update feeditem set isread = ? where iid >= ?", @(1), @(iid)];
            } else {
                [db executeUpdate:@"update feeditem set isread = ? where iid >= ? and fid = ?", @(1), @(iid), @(fid)];
            }
            
            [subscriber sendNext:@(count)];
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}
//标记全部已读
- (RACSignal *)markFeedAllItemsAsRead:(NSUInteger)fid {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            [db executeUpdate:@"update feeditem set isread = ? where fid = ?", @(1), @(fid)];
            [db executeUpdate:@"update feeds set unread = ? where fid = ?",@0,@(fid)]; //更新feeds表里未读数
            [self clearFeedItemByFid:fid db:db];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}

//是否取消订阅
- (RACSignal *)isHideFeed:(BOOL)hide {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            //
        }
        return nil;
    }];
}
//读取所有未缓存的本地rss item
- (RACSignal *)selectAllUnCachedFeedItems {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            //分页获取
            FMResultSet *rs = [FMResultSet new];
            rs = [db executeQuery:@"select * from feeditem where iscached = ? and isread = ? order by iid desc", @(0), @(0)];
            NSUInteger count = 0;
            NSMutableArray *feedItemsArray = [NSMutableArray array];
            //设置返回Array里的Model
            while ([rs next]) {
                SMFeedItemModel *itemModel = [self itmeModelFromResultSet:rs];
                [feedItemsArray addObject:itemModel];
                count++;
            }
            if (count > 0) {
                [subscriber sendNext:feedItemsArray];
            } else {
                //获取出错处理
                [subscriber sendError:nil];
            }
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}
//标记为已经缓存
- (RACSignal *)markFeedItemAsCached:(NSUInteger)iid {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.feedDBPath];
        if ([db open]) {
            [db executeUpdate:@"update feeditem set iscached = ? where iid = ?", @(1), @(iid)];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}

#pragma mark - Private

//合并到item的model里
- (SMFeedItemModel *)itmeModelFromResultSet:(FMResultSet *)rs {
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
    itemModel.isCached = [rs intForColumn:@"iscached"];
    //icon url
    NSString *fidStr = [NSString stringWithFormat:@"%lu",(unsigned long)itemModel.fid];
    if (self.feedIcons[fidStr]) {
        itemModel.iconUrl = self.feedIcons[fidStr];
    }
    return itemModel;
}

#pragma mark - Getter
- (NSMutableDictionary *)feedIcons {
    if (!_feedIcons) {
        _feedIcons = [NSMutableDictionary dictionary];
    }
    return _feedIcons;
}

@end

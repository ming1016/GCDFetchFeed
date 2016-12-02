//
//  SMDB.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/2/23.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "SMFeedModel.h"

#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


@interface SMDB : NSObject
@property (nonatomic, strong) NSMutableDictionary *feedIcons;

+ (SMDB *)shareInstance;
- (RACSignal *)insertWithFeedModel:(SMFeedModel *)feedModel; //插入feed内容
- (RACSignal *)selectAllFeeds; //读取所有feeds
- (RACSignal *)selectFeedItemsWithPage:(NSUInteger)page fid:(NSUInteger)fid;
- (RACSignal *)markFeedItemAsRead:(NSUInteger)iid fid:(NSUInteger)fid; //标注已读
- (RACSignal *)markFeedAllItemsAsRead:(NSUInteger)fid; //标注全部已读
- (RACSignal *)selectAllUnCachedFeedItems; //读取所有未缓存的本地rss item
- (RACSignal *)markFeedItemAsCached:(NSUInteger)iid; //标记为已经缓存
- (RACSignal *)markAllFeedItemAsCached; //标记全部为已经缓存

- (void)clearFeedItemByFid:(NSUInteger)fid db:(FMDatabase *)db;
@end

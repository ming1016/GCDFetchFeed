//
//  SMNetManager.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMNetManager.h"
#import "SMFeedModel.h"
#import "SMNotificationConst.h"
#import "SMFeedStore.h"
#import "SMDB.h"
#import "STMURLCache.h"

@interface SMNetManager()

@property (nonatomic, strong)SMFeedStore *feedStore;

@end

@implementation SMNetManager

+ (SMNetManager *)shareInstance {
    static SMNetManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SMNetManager manager];
        instance.responseSerializer = [AFHTTPResponseSerializer serializer];
        instance.requestSerializer.timeoutInterval = 20.f;
    });
    return instance;
}

- (RACSignal *)fetchAllFeedWithModelArray:(NSMutableArray *)modelArray {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        //创建并行队列
        dispatch_queue_t fetchFeedQueue = dispatch_queue_create("com.starming.fetchfeed.fetchfeed", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t group = dispatch_group_create();
        self.feeds = modelArray;
        
        for (int i = 0; i < modelArray.count; i++) {
            dispatch_group_enter(group);
            SMFeedModel *feedModel = modelArray[i];
            
            
            [self GET:feedModel.feedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                //                    NSString *xmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                //                    NSLog(@"Data: %@", xmlString);
                //                    NSLog(@"%@",feedModel);
                dispatch_async(fetchFeedQueue, ^{
                    @strongify(self);
                    //解析feed
                    self.feeds[i] = [self.feedStore updateFeedModelWithData:responseObject preModel:feedModel];
                    //入库存储
                    SMDB *db = [SMDB shareInstance];
                    @weakify(db);
                    [[db insertWithFeedModel:self.feeds[i]] subscribeNext:^(NSNumber *x) {
                        @strongify(db);
                        SMFeedModel *model = (SMFeedModel *)self.feeds[i];
                        model.fid = [x integerValue];
                        if (model.imageUrl.length > 0) {
                            NSString *fidStr = [x stringValue];
                            db.feedIcons[fidStr] = model.imageUrl;
                        }
                        //插入本地数据库成功后开始sendNext
                        [subscriber sendNext:@(i)];
                        //通知单个完成
                        dispatch_group_leave(group);
                    }];
                    
                });//end dispatch async
                
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                dispatch_async(fetchFeedQueue, ^{
                    @strongify(self);
                    [[[SMDB shareInstance] insertWithFeedModel:self.feeds[i]] subscribeNext:^(NSNumber *x) {
                        SMFeedModel *model = (SMFeedModel *)self.feeds[i];
                        model.fid = [x integerValue];
                        dispatch_group_leave(group);
                    }];
                    
                });//end dispatch async
                
            }];
            
        }//end for
        //全完成后执行事件
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [subscriber sendCompleted];
        });
        return nil;
    }];
}

#pragma mark - Getter
- (SMFeedStore *)feedStore {
    if (!_feedStore) {
        _feedStore = [[SMFeedStore alloc] init];
    }
    return _feedStore;
}
- (NSMutableArray *)feeds {
    if (!_feeds) {
        _feeds = [NSMutableArray array];
    }
    return _feeds;
}


@end

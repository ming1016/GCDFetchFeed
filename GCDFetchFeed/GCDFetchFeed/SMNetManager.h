//
//  SMNetManager.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface SMNetManager : AFHTTPSessionManager

+ (SMNetManager *)shareInstance;

@property (nonatomic, strong) NSMutableArray *feeds;

- (void)fetchAllFeedWithModelArray:(NSArray *)modelArray;

@end

//
//  SMNetManager.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMNetManager.h"

@implementation SMNetManager

+ (AFHTTPSessionManager *)shareInstance {
    static SMNetManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SMNetManager manager];
        instance.responseSerializer = [AFHTTPResponseSerializer serializer];
        instance.requestSerializer.timeoutInterval = 20.f;
    });
    return instance;
}

@end

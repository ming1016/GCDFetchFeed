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

+ (AFHTTPSessionManager *)shareInstance;

@end

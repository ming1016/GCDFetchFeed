//
//  SMDB.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/2/23.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

typedef NS_ENUM(NSInteger, SMDBTable) {
    SMDBTableTypeFeeds,
    SMDBTableTypeFeedItem,
};

@interface SMDB : NSObject

@end

//
//  SMFeedStore.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/20.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMFeedModel.h"

@interface SMFeedStore : NSObject

- (SMFeedModel *)updateFeedModelWithData:(NSData *)feedData preModel:(SMFeedModel *)preModel;

@end

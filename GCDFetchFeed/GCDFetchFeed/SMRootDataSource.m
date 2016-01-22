//
//  SMRootDataSource.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/20.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMRootDataSource.h"

@implementation SMRootDataSource

#pragma mark - Getter
- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

@end

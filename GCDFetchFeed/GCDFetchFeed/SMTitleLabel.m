//
//  SMTitleLabel.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMTitleLabel.h"

@implementation SMTitleLabel

- (instancetype)init {
    if (self = [super init]) {
        self.font = [SMStyle fontHuge];
        self.textColor = [SMStyle colorBlack];
    }
    return self;
}

@end

//
//  SMSubContentLabel.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMSubContentLabel.h"

@implementation SMSubContentLabel

- (instancetype)init {
    if (self = [super init]) {
        self.font = [SMStyle fontSmall];
        self.textColor = [SMStyle colorGrayLight];
    }
    return self;
}

@end

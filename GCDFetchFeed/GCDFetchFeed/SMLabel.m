//
//  SMLabel.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMLabel.h"

@implementation SMLabel

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.font = [SMStyle fontNormal];
        self.textColor = [SMStyle colorGrayDark];
    }
    return self;
}

@end

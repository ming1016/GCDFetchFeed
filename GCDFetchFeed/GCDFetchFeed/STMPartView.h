//
//  STMPartView.h
//  HomePageTest
//
//  Created by DaiMing on 16/5/31.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMPartMaker.h"

@interface STMPartView : NSObject

@property (nonatomic, strong) STMPartMaker *maker;

+ (STMPartView *)createView:(void(^)(STMPartMaker *make))partMaker;

@end

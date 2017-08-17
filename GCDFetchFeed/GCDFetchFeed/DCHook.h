//
//  DCHook.h
//
//  Created by DaiMing on 16/4/26. Maintain by DaiMing
//  Copyright © 2016年 DiDi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCHook : NSObject

+ (void)hookClass:(Class)classObject fromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;

@end

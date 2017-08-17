//
//  DCHook.m
//
//  Created by DaiMing on 16/4/26. Maintain by DaiMing
//  Copyright © 2016年 DiDi. All rights reserved.
//

#import "DCHook.h"
#import <objc/runtime.h>

@implementation DCHook

+ (void)hookClass:(Class)classObject fromSelector:(SEL)fromSelector toSelector:(SEL)toSelector {
    Class class = classObject;
    
    Method fromMethod = class_getInstanceMethod(class, fromSelector);
    Method toMethod = class_getInstanceMethod(class, toSelector);
    
    if(class_addMethod(class, fromSelector, method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        class_replaceMethod(class, toSelector, method_getImplementation(fromMethod), method_getTypeEncoding(fromMethod));
    } else {
        method_exchangeImplementations(fromMethod, toMethod);
    }
    
}

@end

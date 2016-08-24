//
//  STMAssembleMaker.m
//  HomePageTest
//
//  Created by DaiMing on 16/5/31.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "STMAssembleMaker.h"

#import "STMAssembleView.h"

@implementation STMAssembleMaker

- (STMAssembleMaker *(^)(STMAssembleView *))addAssembleView {
    return ^STMAssembleMaker *(STMAssembleView *view) {
        [self.subViews addObject:view];
        return self;
    };
}
- (STMAssembleMaker *(^)(STMPartView *))addPartView {
    return ^STMAssembleMaker *(STMPartView *view) {
        [self.subViews addObject:view];
        return self;
    };
}
- (STMAssembleMaker *(^)(UIView *))addView {
    return ^STMAssembleMaker *(UIView *view) {
        [self.subViews addObject:view];
        return self;
    };
}
- (STMAssembleMaker *(^)(CGFloat))paddingEqualTo {
    return ^STMAssembleMaker *(CGFloat value) {
        self.padding = value;
        return self;
    };
}
- (STMAssembleMaker *(^)(STMAssembleAlignment))alignmentEqualTo {
    return ^STMAssembleMaker *(STMAssembleAlignment alignment) {
        self.alignment = alignment;
        return self;
    };
}
- (STMAssembleMaker *(^)(STMAssembleArrange))arrangeEqualTo {
    return ^STMAssembleMaker *(STMAssembleArrange arrange) {
        self.arrange = arrange;
        return self;
    };
}
- (STMAssembleMaker *(^)(NSUInteger))extendWithEqualTo {
    return ^STMAssembleMaker *(NSUInteger num) {
        self.extendWith = num;
        return self;
    };
}


#pragma mark - Getter
- (NSMutableArray *)subViews {
    if (!_subViews) {
        _subViews = [NSMutableArray array];
    }
    return _subViews;
}

@end

//
//  STMAssembleMaker.h
//  HomePageTest
//
//  Created by DaiMing on 16/5/31.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMPartView.h"

@class STMAssembleView;

typedef NS_ENUM(NSUInteger, STMAssembleAlignment) {
    STMAssembleAlignmentCenter,
    STMAssembleAlignmentLeft,
    STMAssembleAlignmentRight,
    STMAssembleAlignmentTop,
    STMAssembleAlignmentBottom
};
typedef NS_ENUM(NSUInteger, STMAssembleArrange) {
    STMAssembleArrangeHorizontal,
    STMAssembleArrangeVertical
};

typedef void(^ParsingFormatStringCompleteBlock)(STMAssembleView *asView);

@interface STMAssembleMaker : NSObject
//属性
@property (nonatomic, strong) NSMutableArray *subViews; //存放所有子视图
@property (nonatomic) CGFloat padding;                  //间隔距离
@property (nonatomic) STMAssembleAlignment alignment;   //对齐
@property (nonatomic) STMAssembleArrange arrange;       //水平还是垂直排列
@property (nonatomic) NSUInteger extendWith;            //由第几个PartView来撑开AssembleView的大小
@property (nonatomic, copy) ParsingFormatStringCompleteBlock parsingCompletion;


//方法
- (STMAssembleMaker *(^)(STMAssembleView *))addAssembleView;
- (STMAssembleMaker *(^)(STMPartView *))addPartView;
- (STMAssembleMaker *(^)(UIView *))addView;

- (STMAssembleMaker *(^)(CGFloat))paddingEqualTo;
- (STMAssembleMaker *(^)(STMAssembleAlignment))alignmentEqualTo;
- (STMAssembleMaker *(^)(STMAssembleArrange))arrangeEqualTo;
- (STMAssembleMaker *(^)(NSUInteger))extendWithEqualTo;


@end

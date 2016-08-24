//
//  STMAssembleView.h
//  HomePageTest
//
//  Created by DaiMing on 16/4/15.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMAssembleMaker.h"
//@class STMAssembleMaker;
@class STMPartView;

@interface STMAssembleView : UIView

@property (nonatomic, strong, readonly) STMAssembleMaker *maker;

+ (STMAssembleView *)createView:(void(^)(STMAssembleMaker *make))assembleMaker;

//使用格式化字符串创建AssembleView
+ (STMAssembleView *)fs:(NSString *)string objects:(NSDictionary *)objs;
+ (void)fsAsync:(NSString *)string objects:(NSDictionary *)objs completion:(ParsingFormatStringCompleteBlock)completeBlock;

//简化NSString的format
FOUNDATION_EXPORT NSString *ASS(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@end

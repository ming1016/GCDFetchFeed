//
//  STMAssembleView.m
//  HomePageTest
//
//  Created by DaiMing on 16/4/15.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "STMAssembleView.h"

#import "Masonry.h"
#import "STMPartView.h"
#import <objc/message.h>
@interface STMAssembleView()

@property (nonatomic, strong) STMAssembleMaker *maker;

@end

@implementation STMAssembleView


/*-------------创建Assemble View------------*/
+ (STMAssembleView *)createView:(void(^)(STMAssembleMaker *))assembleMaker {
    STMAssembleView *assembleView = [[self alloc] init];
    assembleView.maker = [[STMAssembleMaker alloc] init];
    assembleMaker(assembleView.maker);
    assembleView = [assembleView buildAssembleView];
    return assembleView;
}
- (STMAssembleView *)buildAssembleView{
    STMAssembleMaker *assembleMaker = self.maker;
    if (!(assembleMaker.subViews.count > 0)) {
        return self;
    }
    
    UIView __block *lastView = nil;
    NSUInteger i = 0;
    NSUInteger count = assembleMaker.subViews.count;
    for (id x in assembleMaker.subViews) {
        UIView *xView = nil;
        STMPartView *partView = nil;
        if ([x isKindOfClass:[STMPartView class]]) {
            partView = (STMPartView *)x;
            xView = partView.maker.view;
        } else {
            xView = (UIView *)x;
        }
        [self addSubview:xView];
        //设置权重
        if (partView.maker.CRpriority != STMPriorityDefault) {
            switch (partView.maker.CRpriority) {
                case STMPriorityFittingSizeLevel:
                    [xView setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
                    break;
                case STMPriorityDefaultLow:
                    [xView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
                    break;
                case STMPriorityDefaultHigh:
                    [xView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
                    break;
                case STMPriorityRequired:
                    [xView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
                    break;
                default:
                    break;
            }
        }
        
        //设置布局约束
        [xView mas_makeConstraints:^(MASConstraintMaker *make) {
            //通用情况处理
            CGFloat xViewPadding = assembleMaker.padding;
            if ([x isKindOfClass:[STMAssembleView class]]) {
                //
            } else if([x isKindOfClass:[STMPartView class]]) {
                //大小
                if (partView.maker.size.width > 0) {
                    make.width.mas_equalTo(partView.maker.size.width);
                }
                if (partView.maker.size.height > 0) {
                    make.height.mas_equalTo(partView.maker.size.height);
                }
                //根据排列方式是否填充满，如果设置填充，对应的宽高需要设置为0
                if (partView.maker.isFill) {
                    if (assembleMaker.arrange == STMAssembleArrangeHorizontal) {
                        make.height.equalTo(self);
                    } else if (assembleMaker.arrange == STMAssembleArrangeVertical) {
                        make.width.equalTo(self);
                    }
                }
                //间隔Padding的设置
                if (partView.maker.padding != 0) {
                    xViewPadding = partView.maker.padding;
                }
            }
            
            CGFloat partViewMarginOffset = 0; //对齐时的partView设置的间距
            if (partView.maker.alignmentMargin > 0) {
                partViewMarginOffset = partView.maker.alignmentMargin;
            }
            //排序设置
            if (assembleMaker.arrange == STMAssembleArrangeHorizontal) {
                BOOL hNeedAsAlignment = YES; //是否需要assemble配置
                //水平情况
                if (partView.maker.partAlignment != STMPartAlignmentDefault) {
                    //如果有PartView自定义布局的情况
                    hNeedAsAlignment = NO;
                    if (partView.maker.partAlignment == STMPartAlignmentCenter) {
                        make.centerY.equalTo(self).offset(partViewMarginOffset);
                    } else if (partView.maker.partAlignment == STMPartAlignmentTop) {
                        make.top.equalTo(self).offset(partViewMarginOffset);
                    } else if (partView.maker.partAlignment == STMPartAlignmentBottom) {
                        make.bottom.equalTo(self).offset(partViewMarginOffset);
                    } else if (partView.maker.partAlignment == STMPartAlignmentLeft) {
                        //在只有一个视图，或者这一个part视图是assemble的情况
                        make.left.equalTo(self).offset(partViewMarginOffset);
                        hNeedAsAlignment = YES;
                    } else if (partView.maker.partAlignment == STMPartAlignmentRight) {
                        //在只有一个视图，或者这一个part视图是assemble的情况
                        hNeedAsAlignment = YES;
                        make.right.equalTo(self).offset(partViewMarginOffset);
                    }
                }
                if (hNeedAsAlignment) {
                    //需要按照assemble maker来配置的情况
                    if (assembleMaker.alignment == STMAssembleAlignmentCenter) {
                        make.centerY.equalTo(self);
                    } else if (assembleMaker.alignment == STMAssembleAlignmentTop) {
                        make.top.equalTo(self);
                    } else if (assembleMaker.alignment == STMAssembleAlignmentBottom) {
                        make.bottom.equalTo(self);
                    }
                }
                //由内部撑大AssembleView
                if (assembleMaker.extendWith == i + 1) {
                    make.top.equalTo(self);
                    make.bottom.equalTo(self);
                }
                
                if (partView.maker.ignoreAlignment == STMPartAlignmentLeft) {
                    //如果设置忽略左约束就不设置左约束
                } else {
                    make.left.equalTo(lastView ? lastView.mas_right : self.mas_left).offset(lastView ? xViewPadding : 0);
                }
                //最后一个元素
                if (i == count - 1) {
                    make.right.equalTo(self.mas_right);
                }
                //lessThanOrEqualTo和greaterThanOrEqualTo的设置
                if (partView.maker.minWidth > 0) {
                    make.width.greaterThanOrEqualTo(@(partView.maker.minWidth));
                }
                if (partView.maker.maxWidth > 0) {
                    make.width.lessThanOrEqualTo(@(partView.maker.maxWidth));
                }
                
            } else if (assembleMaker.arrange == STMAssembleArrangeVertical) {
                //垂直情况
                if (partView.maker.partAlignment != STMPartAlignmentDefault) {
                    //如果有PartView自定义布局的情况
                    if (partView.maker.partAlignment == STMPartAlignmentCenter) {
                        make.centerX.equalTo(self).offset(partViewMarginOffset);
                    } else if (partView.maker.partAlignment == STMPartAlignmentLeft) {
                        make.left.equalTo(self).offset(partViewMarginOffset);
                    } else if (partView.maker.partAlignment == STMPartAlignmentRight) {
                        make.right.equalTo(self).offset(partViewMarginOffset);
                    } else if (partView.maker.partAlignment == STMPartAlignmentTop) {
                        make.top.equalTo(self).offset(partViewMarginOffset);
                    } else if (partView.maker.partAlignment == STMPartAlignmentBottom) {
                        make.bottom.equalTo(self).offset(partViewMarginOffset);
                    }
                } else {
                    //按Assemble View的maker设置来
                    if (assembleMaker.alignment == STMAssembleAlignmentCenter) {
                        make.centerX.equalTo(self);
                    } else if (assembleMaker.alignment == STMAssembleAlignmentLeft) {
                        make.left.equalTo(self);
                    } else if (assembleMaker.alignment == STMAssembleAlignmentRight) {
                        make.right.equalTo(self);
                    }
                }
                //由内部撑大AssembleView
                if (assembleMaker.extendWith == i + 1) {
                    make.left.equalTo(self);
                    make.right.equalTo(self);
                }
                
                make.right.lessThanOrEqualTo(self);
                
                if (partView.maker.ignoreAlignment == STMPartAlignmentTop) {
                    //如果设置忽略上约束就不设置上约束
                } else {
                    make.top.equalTo(lastView ? lastView.mas_bottom : self.mas_top).offset(lastView ? xViewPadding : 0);
                }
                
                if (i == count - 1) {
                    make.bottom.equalTo(self.mas_bottom);
                }
            }
            
            
        }];
        
        lastView = xView;
        i++;
    }
    if (assembleMaker.parsingCompletion) {
        assembleMaker.parsingCompletion(self);
    }
    return self;
}

/*-------------格式化字符串创建Part View----------------*/
+ (STMAssembleView *)fs:(NSString *)string objects:(NSDictionary *)objs {
    return [STMAssembleView createViewWithFormatString:string objects:objs completion:nil];
}

+ (void)fsAsync:(NSString *)string objects:(NSDictionary *)objs completion:(ParsingFormatStringCompleteBlock)completeBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [STMAssembleView createViewWithFormatString:string objects:objs completion:completeBlock];
    });
}

+ (STMAssembleView *)createViewWithFormatString:(NSString *)string objects:(NSDictionary *)objs completion:(ParsingFormatStringCompleteBlock)completeBlock {
    //根据格式化字符串来
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet]; //跳过换行和空格
    NSMutableArray *tokens = [NSMutableArray array];
    NSMutableCharacterSet *mCSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [mCSet addCharactersInString:@"./|?!$%#-+_&：“”。，《》！"];
    //下一步需要做个特殊字符串映射对应关系，比如说属性的值里需要“:”这个符号和关键符号冲突了就需要通过映射表来处理
    while (!scanner.isAtEnd) {
        for (NSString *operator in @[@"(",@")",@":",@",",@"[",@"]",@"{",@"}",@"<",@">"]) {
            if ([scanner scanString:operator intoString:NULL]) {
                [tokens addObject:operator];
            }
            NSString *result = nil;
            if ([scanner scanCharactersFromSet:mCSet intoString:&result]) {
                [tokens addObject:result];
            }
        }
    }
    if (completeBlock) {
        dispatch_async(dispatch_get_main_queue(),^{
            [STMAssembleView createViewWithFormatArray:tokens objects:objs completion:completeBlock];
        });
        return [[STMAssembleView alloc] init];
    } else {
        return [STMAssembleView createViewWithFormatArray:tokens objects:objs completion:completeBlock];
    }
    
    
}

+ (STMAssembleView *)createViewWithFormatArray:(NSArray *)array objects:(NSDictionary *)objs completion:(ParsingFormatStringCompleteBlock)completeBlock {
    STMAssembleView *asView = [STMAssembleView createView:^(STMAssembleMaker *make) {
        if (completeBlock) {
            make.parsingCompletion = completeBlock;
        } else {
            make.parsingCompletion = nil;
        }
        
        NSMutableArray *asPropertyArray = [NSMutableArray array]; //asView的属性array
        NSMutableArray *partsArray = [NSMutableArray array]; //用来装所有partView的array的array，二级array
        NSMutableArray *partArray = [NSMutableArray array];  //单个partView的array
        
        BOOL isParsingAssembleProperty = NO;    //正在处理assemble的属性
        BOOL isParsingPart = NO;                //正在处理part view
        BOOL isParsingPartContainAssemble = NO; //正在处理part view里包含assemble的情况
        NSInteger PCAcount = 0;                //part view里包含assemble对层级的计数，当为0时判断为解析结束
        NSUInteger i = 0;
        for (NSString *token in array) {
            //校验是否是合适的assemble view字符串
            if (i == 0) {
                if ([token isEqualToString:@"{"]) {
                    i++;
                    continue;
                } else {
                    break;
                }
            }
            //处理排序方向和对齐方向
            if (i == 1 && token.length == 2) {
                NSString *arrangeStr = [token substringWithRange:NSMakeRange(0, 1)];
                NSString *alignmentStr = [token substringWithRange:NSMakeRange(1, 1)];
                if ([arrangeStr isEqualToString:@"v"]) {
                    make.arrangeEqualTo(STMAssembleArrangeVertical);
                }
                if ([arrangeStr isEqualToString:@"h"]) {
                    make.arrangeEqualTo(STMAssembleArrangeHorizontal);
                }
                if ([alignmentStr isEqualToString:@"c"]) {
                    make.alignmentEqualTo(STMAssembleAlignmentCenter);
                }
                if ([alignmentStr isEqualToString:@"l"]) {
                    make.alignmentEqualTo(STMAssembleAlignmentLeft);
                }
                if ([alignmentStr isEqualToString:@"r"]) {
                    make.alignmentEqualTo(STMAssembleAlignmentRight);
                }
                if ([alignmentStr isEqualToString:@"t"]) {
                    make.alignmentEqualTo(STMAssembleAlignmentTop);
                }
                if ([alignmentStr isEqualToString:@"b"]) {
                    make.alignmentEqualTo(STMAssembleAlignmentBottom);
                }
            }
            //--------处理assemble view的属性---------
            if (i == 2 && [token isEqualToString:@"("]) {
                isParsingAssembleProperty = YES;
            }
            //灌数组
            if (isParsingAssembleProperty) {
                if ([token isEqualToString:@"("] || [token isEqualToString:@")"]) {
                    //对应的()符号不用灌
                } else {
                    [asPropertyArray addObject:token];
                }
            }
            //结束处理assemble view的属性
            if (isParsingAssembleProperty && [token isEqualToString:@")"]) {
                isParsingAssembleProperty = NO;
            }
            
            //--------处理part view---------
            if ([token isEqualToString:@"["]) {
                isParsingPart = YES;
            }
            //灌数组
            if (isParsingPart) {
                if ([token isEqualToString:@"{"]) {
                    isParsingPartContainAssemble = YES;
                    PCAcount += 1;
                }
                if ([token isEqualToString:@"}"]) {
                    PCAcount -= 1;
                    if (PCAcount == 0) {
                        //这时assemble view的灌结束
                        isParsingPartContainAssemble = NO;
                    }
                }
                
                if (([token isEqualToString:@"["] || [token isEqualToString:@"]"]) && !isParsingPartContainAssemble) {
                    //对应的[]符号不用灌
                } else {
                    [partArray addObject:token];
                }
            }
            //结束处理part view
            if (isParsingPart && [token isEqualToString:@"]"] && !isParsingPartContainAssemble) {
                [partsArray addObject:partArray];
                partArray = [NSMutableArray array];
                isParsingPart = NO;
            }
            
            i++;
        }
        
        //遍历解析到的assemble view的属性
        NSMutableDictionary *keyValueProperty = [STMAssembleView parsingPropertyFormatArray:asPropertyArray objects:objs];
        NSArray *keys = [keyValueProperty allKeys];
        for (NSString *key in keys) {
            if ([key isEqualToString:@"padding"]) {
                make.paddingEqualTo([keyValueProperty[key] floatValue]);
            }
            if ([key isEqualToString:@"extendWith"]) {
                make.extendWithEqualTo([keyValueProperty[key] floatValue]);
            }
        }
        
        //part view解析
        for (NSMutableArray *part in partsArray) {
            make.addPartView([STMAssembleView createPartViewWithFormatArray:part objects:objs]);
        }
        
        
    }];
    return asView;
}
/*-------------格式化字符串创建Part View----------------*/
+ (STMPartView *)createPartViewWithFormatArray:(NSMutableArray *)array objects:(NSDictionary *)objs {
    return [STMPartView createView:^(STMPartMaker *make) {
        NSArray *allObjKeys = objs.allKeys;
        
        NSMutableArray *propertyArray = [NSMutableArray array];  //属性
        NSMutableArray *asArray = [NSMutableArray array];        //assemble view
        
        BOOL isParsingProperty = NO; //正在处理属性
        BOOL isParsingAssemble = NO; //正在处理assemble view数组
        NSInteger PCAcount = 0;      //part view里包含assemble对层级的计数，当为0时判断为解析结束
        
        NSUInteger i = 0;
        
        for (NSString *token in array) {
            //处理assemble view
            if ([token isEqualToString:@"{"]) {
                isParsingAssemble = YES;
                PCAcount += 1;
            }
            if (isParsingAssemble) {
                [asArray addObject:token];
            }
            if ([token isEqualToString:@"}"]) {
                PCAcount -= 1;
                if (PCAcount == 0) {
                    //as的处理结束
                    isParsingAssemble = NO;
                }
            }
            
            //处理property
            if ([token isEqualToString:@"("] && !isParsingAssemble) {
                isParsingProperty = YES;
            }
            if (isParsingProperty) {
                if ([token isEqualToString:@"("] || [token isEqualToString:@")"]) {
                    //这里就不用记录这两个符号了
                } else {
                    [propertyArray addObject:token];
                }
            }
            if ([token isEqualToString:@")"] && !isParsingAssemble) {
                isParsingProperty = NO;
            }
            
            //处理自定义视图
            if (!isParsingProperty && !isParsingAssemble) {
                for (NSString *objKey in allObjKeys) {
                    if ([objKey isEqualToString:token]) {
                        make.customViewEqualTo(objs[objKey]);
                    }
                }
            }
            
            i++;
        }
        
        //assemble view的情况就用递归完成
        if (asArray.count > 0) {
            make.customViewEqualTo([STMAssembleView createViewWithFormatArray:asArray objects:objs completion:nil]);
        }
        
        //开始设置Part属性
        if (propertyArray.count > 0) {
            NSMutableDictionary *dic = [STMAssembleView parsingPropertyFormatArray:propertyArray objects:objs];
            NSArray *keys = [dic allKeys];
            CGFloat width = 0;
            CGFloat height = 0;
            for (NSString *key in keys) {
                //设置布局
                if ([key isEqualToString:@"width"]) {
                    width = [dic[key] floatValue];
                }
                if ([key isEqualToString:@"height"]) {
                    height = [dic[key] floatValue];
                }
                if ([key isEqualToString:@"isFill"]) {
                    if ([dic[key] integerValue] > 0) {
                        make.isFillEqualTo(YES);
                    } else {
                        make.isFillEqualTo(NO);
                    }
                }
                if ([key isEqualToString:@"padding"]) {
                    make.paddingEqualTo([dic[key] floatValue]);
                }
                if ([key isEqualToString:@"partAlignment"]) {
                    if ([dic[key] isEqualToString:@"center"]) {
                        make.partAlignmentEqualTo(STMPartAlignmentCenter);
                    }
                    if ([dic[key] isEqualToString:@"left"]) {
                        make.partAlignmentEqualTo(STMPartAlignmentLeft);
                    }
                    if ([dic[key] isEqualToString:@"right"]) {
                        make.partAlignmentEqualTo(STMPartAlignmentRight);
                    }
                    if ([dic[key] isEqualToString:@"top"]) {
                        make.partAlignmentEqualTo(STMPartAlignmentTop);
                    }
                    if ([dic[key] isEqualToString:@"bottom"]) {
                        make.partAlignmentEqualTo(STMPartAlignmentBottom);
                    }
                }
                if ([key isEqualToString:@"ignoreAlignment"]) {
                    if ([dic[key] isEqualToString:@"center"]) {
                        make.ignoreAlignmentEqualTo(STMPartAlignmentCenter);
                    }
                    if ([dic[key] isEqualToString:@"left"]) {
                        make.ignoreAlignmentEqualTo(STMPartAlignmentLeft);
                    }
                    if ([dic[key] isEqualToString:@"right"]) {
                        make.ignoreAlignmentEqualTo(STMPartAlignmentRight);
                    }
                    if ([dic[key] isEqualToString:@"top"]) {
                        make.ignoreAlignmentEqualTo(STMPartAlignmentTop);
                    }
                    if ([dic[key] isEqualToString:@"bottom"]) {
                        make.ignoreAlignmentEqualTo(STMPartAlignmentBottom);
                    }
                }
                if ([key isEqualToString:@"alignmentMargin"]) {
                    make.alignmentMarginEqualTo([dic[key] floatValue]);
                }
                //设置权重
                if ([key isEqualToString:@"crp"]) {
                    if ([dic[key] isEqualToString:@"fit"]) {
                        make.CRpriorityEqualTo(STMPriorityFittingSizeLevel);
                    }
                    if ([dic[key] isEqualToString:@"low"]) {
                        make.CRpriorityEqualTo(STMPriorityDefaultLow);
                    }
                    if ([dic[key] isEqualToString:@"high"]) {
                        make.CRpriorityEqualTo(STMPriorityDefaultHigh);
                    }
                    if ([dic[key] isEqualToString:@"required"]) {
                        make.CRpriorityEqualTo(STMPriorityRequired);
                    }
                }
                //设置最大，最小宽
                if ([key isEqualToString:@"minWidth"]) {
                    make.minWidthEqualTo([dic[key] floatValue]);
                }
                if ([key isEqualToString:@"maxWidth"]) {
                    make.maxWidthEqualTo([dic[key] floatValue]);
                }
                //设置控件通用
                if ([key isEqualToString:@"backColor"]) {
                    if ([dic[key] isKindOfClass:[UIColor class]]) {
                        UIColor *pColor = (UIColor *)dic[key];
                        make.backColorIs(pColor);
                    } else {
                        make.backColorHexStringIs(dic[key]);
                    }
                }
                if ([key isEqualToString:@"backColorHexString"]) {
                    make.backColorHexStringIs(dic[key]);
                }
                if ([key isEqualToString:@"backPaddingHorizontal"]) {
                    make.backPaddingHorizontalIs([dic[key] floatValue]);
                }
                if ([key isEqualToString:@"backPaddingVertical"]) {
                    make.backPaddingVerticalIs([dic[key] floatValue]);
                }
                if ([key isEqualToString:@"backBorderColor"]) {
                    if ([dic[key] isKindOfClass:[UIColor class]]) {
                        UIColor *pColor = (UIColor *)dic[key];
                        make.backBorderColorIs(pColor);
                    } else {
                        make.backBorderColorHexStringIs(dic[key]);
                    }
                }
                if ([key isEqualToString:@"backBorderColorHexString"]) {
                    make.backBorderColorHexStringIs(dic[key]);
                }
                if ([key isEqualToString:@"backBorderWidth"]) {
                    make.backBorderWidthIs([dic[key] floatValue]);
                }
                if ([key isEqualToString:@"backBorderRadius"] || [key isEqualToString:@"radius"]) {
                    make.backBorderRadiusIs([dic[key] floatValue]);
                }
                if ([key isEqualToString:@"button"]) {
                    make.buttonIs(dic[key]);
                }
                if ([key isEqualToString:@"buttonHighlightColor"]) {
                    if ([dic[key] isKindOfClass:[UIColor class]]) {
                        make.buttonHighlightColorIs(dic[key]);
                    }
                }
                //设置控件属性
                if ([key isEqualToString:@"text"]) {
                    make.textIs(dic[key]);
                }
                if ([key isEqualToString:@"fontSize"]) {
                    make.fontSizeIs([dic[key] floatValue]);
                }
                if ([key isEqualToString:@"font"]) {
                    if ([dic[key] isKindOfClass:[UIFont class]]) {
                        UIFont *pFont = (UIFont *)dic[key];
                        make.fontIs(pFont);
                    } else {
                        make.fontSizeIs([dic[key] floatValue]);
                    }
                }
                if ([key isEqualToString:@"color"]) {
                    if ([dic[key] isKindOfClass:[UIColor class]]) {
                        UIColor *pColor = (UIColor *)dic[key];
                        make.colorIs(pColor);
                    } else {
                        make.colorHexStringIs(dic[key]);
                    }
                }
                if ([key isEqualToString:@"colorHexString"]) {
                    make.colorHexStringIs(dic[key]);
                }
                if ([key isEqualToString:@"imageName"]) {
                    make.imageNameIs(dic[key]);
                }
                if ([key isEqualToString:@"image"]) {
                    if ([dic[key] isKindOfClass:[UIImage class]]) {
                        make.imageIs(dic[key]);
                    }
                }
                if ([key isEqualToString:@"imageUrl"]) {
                    make.imageUrlIs(dic[key]);
                }
                
            }
            //处理多个值需要组合的情况
            if (width > 0 || height > 0) {
                make.sizeEqualTo(CGSizeMake(width, height));
            }
        }
        
    }];
}
/*-------------辅助方法--------------------*/
//将属性数组转成键值对应的字典
+ (NSMutableDictionary *)parsingPropertyFormatArray:(NSMutableArray *)array objects:(NSDictionary *)objs{
    NSArray *allObjKeys = objs.allKeys;
    //遍历解析到的assemble view的属性
    [array addObject:@","];//处理最后一个没添加,的情况
    BOOL isParsingOneProperty = NO;
    NSString *parsingKey = @"";
    BOOL isParsingObj = NO;
    NSMutableDictionary *keyValuePropertys = [NSMutableDictionary dictionary];
    for (NSString *proStr in array) {
        //属性
        if (!isParsingOneProperty) {
            isParsingOneProperty = YES;
            parsingKey = proStr;
        } else if ([proStr isEqualToString:@":"]) {
            //直接略过
        } else if ([proStr isEqualToString:@","]){
            //需要结束
            isParsingOneProperty = NO;
        } else if (isParsingOneProperty) {
            if ([proStr isEqualToString:@"<"]) {
                isParsingObj = YES;
            } else if ([proStr isEqualToString:@">"]) {
                isParsingObj = NO;
            } else if (isParsingObj) {
                //处理obj传入的属性
                //                keyValuePropertys[parsingKey] =
                for (NSString *objKey in allObjKeys) {
                    if ([objKey isEqualToString:proStr]) {
                        keyValuePropertys[parsingKey] = objs[objKey];
                    }
                }
            } else {
                keyValuePropertys[parsingKey] = proStr;
            }
            
        }
        
    }
    return keyValuePropertys;
}

//宏
NSString *ASS(NSString *format, ...) {
    va_list args;
    if (format) {
        va_start(args, format);
        
        NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        return str;
    }
    return @"";
}

@end

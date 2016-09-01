//
//  SMStyle.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/21.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMStyle.h"

@implementation SMStyle
//--------------------------
//         UIFont
//--------------------------
+ (UIFont *)fontHuge {
    return [UIFont systemFontOfSize:18];
}
+ (UIFont *)fontBig {
    return [UIFont systemFontOfSize:16];
}
+ (UIFont *)fontNormal {
    return [UIFont systemFontOfSize:14];
}
+ (UIFont *)fontSmall {
    return [UIFont systemFontOfSize:12];
}

//--------------------------
//         UIColor
//--------------------------
+ (UIColor *)colorBlackLightAlpha {
    return [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.05];
}
+ (UIColor *)colorBlack {
    return [UIColor blackColor];
}
+ (UIColor *)colorGrayLight {
    return [UIColor colorWithHexString:@"cccccc"];
}
+ (UIColor *)colorGrayDark {
    return [UIColor colorWithHexString:@"666666"];
}
+ (UIColor *)colorOrangeLight {
    return [UIColor colorWithHexString:@"ff9933"];
}
+ (UIColor *)colorPaperDark {
    return [UIColor colorWithHexString:@"E8E7E2"];
}
+ (UIColor *)colorPaperLight {
    return [UIColor colorWithHexString:@"F2F1ED"];
}
+ (UIColor *)colorPaperBlack {
    return [UIColor colorWithHexString:@"62625F"];
}
+ (UIColor *)colorPaperGray {
    return [UIColor colorWithHexString:@"AAA9A5"];
}

//-------------------------
//         CGFloat
//--------------------------
+ (CGFloat)floatScreenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}
+ (CGFloat)floatScreenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}
+ (CGFloat)floatMarginMassive {
    return 20;
}
+ (CGFloat)floatMarginNormal {
    return 10;
}
+ (CGFloat)floatMarginMinor {
    return 5;
}
+ (CGFloat)floatTextIntervalHorizontal {
    return 8;
}
+ (CGFloat)floatTextIntervalVertical {
    return 10;
}
+ (CGFloat)floatIconNormal {
    return 30;
}

+ (CGFloat)floatCompatibleWithStyleName:(NSString *)styleName {
    return 0;
}
@end

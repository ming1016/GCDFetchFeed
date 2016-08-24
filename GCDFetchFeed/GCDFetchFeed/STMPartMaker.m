//
//  STMPartMaker.m
//  HomePageTest
//
//  Created by DaiMing on 16/6/2.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "STMPartMaker.h"


typedef NS_ENUM(NSUInteger, STMPartType) {
    STMPartTypeCustom,
    STMPartTypeUILabel,
    STMPartTypeUIImageView
};

@implementation STMPartMaker

- (STMPartMaker *(^)(CGSize))sizeEqualTo {
    return ^STMPartMaker *(CGSize size) {
        self.size = size;
        return self;
    };
}
- (STMPartMaker *(^)(UIView *))customViewEqualTo {
    return ^STMPartMaker *(UIView *customView) {
        self.view = customView;
        return self;
    };
}
- (STMPartMaker *(^)(BOOL))isFillEqualTo {
    return ^STMPartMaker *(BOOL isFill) {
        self.isFill = isFill;
        return self;
    };
}
- (STMPartMaker *(^)(CGFloat))paddingEqualTo {
    return ^STMPartMaker *(CGFloat padding) {
        self.padding = padding;
        return self;
    };
}
- (STMPartMaker *(^)(STMPartAlignment))partAlignmentEqualTo {
    return ^STMPartMaker *(STMPartAlignment alignment) {
        self.partAlignment = alignment;
        return self;
    };
}
- (STMPartMaker *(^)(CGFloat))alignmentMarginEqualTo {
    return ^STMPartMaker *(CGFloat margin) {
        self.alignmentMargin = margin;
        return self;
    };
}
- (STMPartMaker *(^)(STMPartAlignment))ignoreAlignmentEqualTo {
    return ^STMPartMaker *(STMPartAlignment alignment) {
        self.ignoreAlignment = alignment;
        return self;
    };
}
- (STMPartMaker *(^)(STMPartPriority))CRpriorityEqualTo {
    return ^STMPartMaker *(STMPartPriority priority) {
        self.CRpriority = priority;
        return self;
    };
}
- (STMPartMaker *(^)(CGFloat))minWidthEqualTo {
    return ^STMPartMaker *(CGFloat width) {
        self.minWidth = width;
        return self;
    };
}
- (STMPartMaker *(^)(CGFloat))maxWidthEqualTo {
    return ^STMPartMaker *(CGFloat width) {
        self.maxWidth = width;
        return self;
    };
}

//控件
//通用
- (STMPartMaker *(^)(UIColor *))backColorIs {
    return ^STMPartMaker *(UIColor *color) {
        self.backColor = color;
        return self;
    };
}
- (STMPartMaker *(^)(NSString *))backColorHexStringIs {
    return ^STMPartMaker *(NSString *str) {
        self.backColor = [STMPartMaker colorWithHexString:str];
        return self;
    };
}
- (STMPartMaker *(^)(UIColor *))backBorderColorIs {
    return ^STMPartMaker *(UIColor *color) {
        self.backBorderColor = color;
        return self;
    };
}
- (STMPartMaker *(^)(NSString *))backBorderColorHexStringIs {
    return ^STMPartMaker *(NSString *str) {
        self.backBorderColor = [STMPartMaker colorWithHexString:str];
        return self;
    };
}
- (STMPartMaker *(^)(CGFloat))backBorderWidthIs {
    return ^STMPartMaker *(CGFloat size) {
        self.backBorderWidth = size;
        return self;
    };
}
- (STMPartMaker *(^)(CGFloat))backBorderRadiusIs {
    return ^STMPartMaker *(CGFloat rd) {
        self.backBorderRadius = rd;
        return self;
    };
}
- (STMPartMaker *(^)(CGFloat))backPaddingHorizontalIs {
    return ^STMPartMaker *(CGFloat padding) {
        self.backPaddingHorizontal = padding;
        return self;
    };
}
- (STMPartMaker *(^)(CGFloat))backPaddingVerticalIs {
    return ^STMPartMaker *(CGFloat padding) {
        self.backPaddingVertical = padding;
        return self;
    };
}
- (STMPartMaker *(^)(UIButton *))buttonIs {
    return ^STMPartMaker *(UIButton *bt) {
        self.button = bt;
        return self;
    };
}
- (STMPartMaker *(^)(UIColor *))buttonHighlightColorIs {
    return ^STMPartMaker *(UIColor *color) {
        self.buttonHighlightColor = color;
        return self;
    };
}
//label
- (STMPartMaker *(^)(NSString *))textIs {
    return ^STMPartMaker *(NSString *text) {
        self.text = text;
        return self;
    };
}
- (STMPartMaker *(^)(UIFont *))fontIs {
    return ^STMPartMaker *(UIFont *font) {
        self.font = font;
        return self;
    };
}
- (STMPartMaker *(^)(CGFloat))fontSizeIs {
    return ^STMPartMaker *(CGFloat size) {
        self.font = [UIFont systemFontOfSize:size];
        return self;
    };
}
- (STMPartMaker *(^)(UIColor *))colorIs {
    return ^STMPartMaker *(UIColor *color) {
        self.color = color;
        return self;
    };
}
- (STMPartMaker *(^)(NSString *))colorHexStringIs {
    return ^STMPartMaker *(NSString *string) {
        self.color = [STMPartMaker colorWithHexString:string];
        return self;
    };
}
- (STMPartMaker *(^)(STMPartColorType))colorTypeIs {
    return ^STMPartMaker *(STMPartColorType type) {
        switch (type) {
            case STMPartColorWhite:
                self.color = [UIColor whiteColor];
                break;
            case STMPartColorBlack:
                self.color = [UIColor blueColor];
                break;
            case STMpartColorRed:
                self.color = [UIColor redColor];
                break;
            case STMpartColorGray:
                self.color = [UIColor grayColor];
                break;
            case STMpartColorLightGray:
                self.color = [UIColor lightGrayColor];
                break;
            case STMpartColorDarkGray:
                self.color = [UIColor darkGrayColor];
                break;
            case STMpartColorOrange:
                self.color = [UIColor orangeColor];
                break;
        }
        return self;
    };
}

//Image View
- (STMPartMaker *(^)(UIImage *))imageIs {
    return ^STMPartMaker *(UIImage *image) {
        self.image = image;
        return self;
    };
}
- (STMPartMaker *(^)(NSString *))imageNameIs {
    return ^STMPartMaker *(NSString *name) {
        self.image = [UIImage imageNamed:name]; //这里需要根据情况
        return self;
    };
}
- (STMPartMaker *(^)(NSString *))imageUrlIs {
    return ^STMPartMaker *(NSString *url) {
        self.imageUrl = url;
        return self;
    };
}
- (STMPartMaker *(^)(UIImage *))imagePlaceholderIs {
    return ^STMPartMaker *(UIImage *image) {
        self.imagePlaceholder = image;
        return self;
    };
}
- (STMPartMaker *(^)(NSString *))imagePlaceholderNameIs {
    return ^STMPartMaker *(NSString *name) {
        self.imagePlaceholder = [UIImage imageNamed:name];
        return self;
    };
}


//辅助方法
+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *stringToConvert = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [STMPartMaker colorWithRGBHex:hexNum];
}

@end


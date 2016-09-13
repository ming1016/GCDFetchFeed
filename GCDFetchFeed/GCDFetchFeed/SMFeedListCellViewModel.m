//
//  SMFeedListCellViewModel.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/22.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMFeedListCellViewModel.h"
#import "SMStyle.h"

@implementation SMFeedListCellViewModel

- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    CGRect frame = [titleString boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - [SMStyle floatMarginNormal]*2, 999) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[SMStyle fontHuge]} context:nil];
    _cellHeight = 70 + (frame.size.height - 18);
}

@end

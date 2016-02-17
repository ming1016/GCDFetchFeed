//
//  SMArticleViewController.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/2/16.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMArticleViewController.h"
#import "Masonry.h"
#import <DTCoreText/DTCoreText.h>

#import "SMFeedStore.h"
#import "SMCellViewImport.h"

@interface SMArticleViewController ()

@property (nonatomic, strong) NSString *articleString;
@property (nonatomic, strong) SMFeedItemModel *feedItemModel;
@property (nonatomic, strong) DTAttributedLabel *articleLabel;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UIView *backScrollViewContainer;
@property (nonatomic, strong) DTAttributedTextContentView *articleView;

@end

@implementation SMArticleViewController

#pragma mark - Life Cycle
- (instancetype)initWithFeedModel:(SMFeedItemModel *)feedItemModel {
    if (self = [super init]) {
        self.feedItemModel = feedItemModel;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backScrollView];
    [self.backScrollView addSubview:self.backScrollViewContainer];
    [self.backScrollViewContainer addSubview:self.articleView];
    [self.backScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    [self.backScrollViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.backScrollView);
        make.width.equalTo(self.backScrollView);
    }];
    [self.articleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backScrollViewContainer).offset([SMStyle floatMarginMassive]);
        make.left.equalTo(self.backScrollViewContainer).offset([SMStyle floatMarginMassive]);
        make.right.equalTo(self.backScrollViewContainer).offset(-[SMStyle floatMarginMassive]);
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Html转Native
    NSError *err = nil;
    NSString *styleString = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"css.html"] encoding:NSUTF8StringEncoding error:&err];
    self.feedItemModel.des = [NSString stringWithFormat:@"%@%@",styleString,self.feedItemModel.des];
    NSData *data = [self.feedItemModel.des dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:nil];
    self.articleView.attributedString = attrString;
    //算高
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attrString];
    CGRect maxRect = CGRectMake(0, 0, [SMStyle floatScreenWidth], CGFLOAT_HEIGHT_UNKNOWN);
    NSRange entireString = NSMakeRange(0, [attrString length]);
    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:maxRect range:entireString];
    CGSize sizeNeed = [layoutFrame frame].size;
    //更新高
    [self.articleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(sizeNeed.height + [SMStyle floatMarginMassive]*2);
    }];
    [self.backScrollViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.articleView.mas_bottom);
    }];
}

#pragma mark - Getter
- (UIScrollView *)backScrollView {
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc] init];
    }
    return _backScrollView;
}
- (UIView *)backScrollViewContainer {
    if (!_backScrollViewContainer) {
        _backScrollViewContainer = [[UIView alloc] init];
    }
    return _backScrollViewContainer;
}
- (DTAttributedLabel *)articleLabel {
    if (!_articleLabel) {
        _articleLabel = [[DTAttributedLabel alloc] init];
        _articleLabel.numberOfLines = 0;
        _articleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _articleLabel;
}
- (DTAttributedTextContentView *)articleView {
    if (!_articleView) {
        _articleView = [[DTAttributedTextContentView alloc] init];
    }
    return _articleView;
}

@end

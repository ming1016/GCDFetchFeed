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
#import <SafariServices/SafariServices.h>

#import "SMFeedStore.h"
#import "SMCellViewImport.h"


@interface SMArticleViewController ()<DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) NSString *articleString;
@property (nonatomic, strong) SMFeedItemModel *feedItemModel;
@property (nonatomic, strong) DTAttributedLabel *articleLabel;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UIView *backScrollViewContainer;
@property (nonatomic, strong) DTAttributedTextContentView *articleView;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSURL *lastActionLink;
@property (nonatomic, strong) UIActivityViewController *activityVC;
@property (nonatomic, strong) UIWebView *wbView;

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
    self.view.backgroundColor = [SMStyle colorPaperLight];
//    [self.view addSubview:self.backScrollView];
//    [self.backScrollView addSubview:self.backScrollViewContainer];
//    [self.backScrollViewContainer addSubview:self.articleView];
//    [self.backScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.bottom.equalTo(self.view);
//    }];
//    [self.backScrollViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.backScrollView);
//        make.width.equalTo(self.backScrollView);
//    }];
//    [self.articleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.backScrollViewContainer).offset([SMStyle floatMarginMassive]);
//        make.left.equalTo(self.backScrollViewContainer).offset([SMStyle floatMarginMassive]);
//        make.right.equalTo(self.backScrollViewContainer).offset(-[SMStyle floatMarginMassive]);
//    }];
    self.wbView = [[UIWebView alloc] init];
    [self.view addSubview:self.wbView];
    [self.wbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    [self.wbView setBackgroundColor:[SMStyle colorPaperLight]];
    self.wbView.scalesPageToFit = YES;
    self.wbView.scrollView.directionalLockEnabled = YES;
    self.wbView.scrollView.showsHorizontalScrollIndicator = NO;
    [self.wbView setOpaque:NO]; // 默认是透明的
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.feedItemModel.title;
    //Html转Native
    NSError *err = nil;
    NSString *feedString = [NSString stringWithFormat:@"%@<p><a href=\"%@\">阅读原文</a></p>",self.feedItemModel.des,self.feedItemModel.link];
    NSString *styleString = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"css.html"] encoding:NSUTF8StringEncoding error:&err];
    NSString *articleString = [NSString stringWithFormat:@"%@%@",styleString,feedString];
//    NSData *data = [articleString dataUsingEncoding:NSUTF8StringEncoding];
//    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:nil];
//    self.articleView.attributedString = attrString;
//    //算高
//    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attrString];
//    CGRect maxRect = CGRectMake(0, 0, [SMStyle floatScreenWidth], CGFLOAT_HEIGHT_UNKNOWN);
//    NSRange entireString = NSMakeRange(0, [attrString length]);
//    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:maxRect range:entireString];
//    CGSize sizeNeed = [layoutFrame frame].size;
//    //更新高
//    [self.articleView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(sizeNeed.height + [SMStyle floatMarginMassive]*2);
//    }];
//    [self.backScrollViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.articleView.mas_bottom);
//    }];
    if (self.feedItemModel.isCached) {
        NSURLRequest *re = [NSURLRequest requestWithURL:[NSURL URLWithString:self.feedItemModel.link]];
        [self.wbView loadRequest:re];
    } else {
        [self.wbView loadHTMLString:articleString baseURL:nil];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    
    //更多功能
    self.alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [self.alertController addAction:[UIAlertAction actionWithTitle:@"浏览器打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [[UIApplication sharedApplication] openURL:[self.lastActionLink absoluteURL]];
    }]];
    [self.alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }]];
    
    //分享
    NSURL *urlToShare = [NSURL URLWithString:self.feedItemModel.link];
    NSArray *activityItems = @[urlToShare];
    self.activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    self.activityVC.excludedActivityTypes = @[UIActivityTypePrint,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll
                                         ];
    
}

#pragma mark - Private
- (void)share {
    [self presentViewController:self.activityVC animated:YES completion:nil];
}




@end

//
//  SMArticleViewController.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/2/16.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMArticleViewController.h"
#import "Masonry.h"
#import <SafariServices/SafariServices.h>

#import "SMFeedStore.h"
#import "SMCellViewImport.h"


@interface SMArticleViewController ()<UIActionSheetDelegate,UIWebViewDelegate>

@property (nonatomic, strong) NSString *articleString;
@property (nonatomic, strong) SMFeedItemModel *feedItemModel;
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

    self.wbView = [[UIWebView alloc] init];
    self.wbView.delegate = self;
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

    [self.wbView loadHTMLString:articleString baseURL:nil];
    
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

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString isEqualToString:self.feedItemModel.link]) {
        SFSafariViewController *sfVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:self.feedItemModel.link]];
        [self presentViewController:sfVC animated:YES completion:nil];
        return NO;
    }
    return YES;
}

#pragma mark - Private
- (void)share {
    [self presentViewController:self.activityVC animated:YES completion:nil];
}




@end

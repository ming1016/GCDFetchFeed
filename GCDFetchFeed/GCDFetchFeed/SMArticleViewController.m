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

@interface SMArticleViewController ()<DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) NSString *articleString;
@property (nonatomic, strong) SMFeedItemModel *feedItemModel;
@property (nonatomic, strong) DTAttributedLabel *articleLabel;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UIView *backScrollViewContainer;
//@property (nonatomic, strong) DTAttributedTextContentView *articleView;
@property (nonatomic, strong) DTAttributedTextContentView *articleView;

@property (nonatomic, strong) NSURL *lastActionLink;

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
    NSString *feedString = [NSString stringWithFormat:@"%@<p><a href=\"%@\">阅读原文</a></p>",self.feedItemModel.des,self.feedItemModel.link];
    NSString *styleString = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"css.html"] encoding:NSUTF8StringEncoding error:&err];
    self.feedItemModel.des = [NSString stringWithFormat:@"%@%@",styleString,feedString];
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

#pragma mark - Private
//链接点击
- (void)linkClicked:(DTLinkButton *)button {
    NSURL *URL = button.URL;
    
    if ([[UIApplication sharedApplication] canOpenURL:[URL absoluteURL]])
    {
        [[UIApplication sharedApplication] openURL:[URL absoluteURL]];
    }
    else
    {
        if (![URL host] && ![URL path])
        {
            //无效链接情况
        }
    }
}
//链接长按
- (void)linkLongPressed:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        DTLinkButton *button = (id)[gesture view];
        button.highlighted = NO;
        self.lastActionLink = button.URL;
        
        if ([[UIApplication sharedApplication] canOpenURL:[button.URL absoluteURL]])
        {
            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:[[button.URL absoluteURL] description] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", nil];
            [action showFromRect:button.frame inView:button.superview animated:YES];
        }
    }
}


#pragma mark - Delegate
#pragma mark - DTAttributedTextContentViewDelegate
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame {
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
    NSURL *url = [attributes objectForKey:DTLinkAttribute];
    NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
    
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = url;
    button.minimumHitSize = CGSizeMake(25, 25);
    button.GUID = identifier;
    
    //链接正常显示
    UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
    [button setImage:normalImage forState:UIControlStateNormal];
    
    //链接按下
    UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    //跳转
    //链接跳转
    [button addTarget:self action:@selector(linkClicked:) forControlEvents:UIControlEventTouchUpInside];
    //连接长按
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
    [button addGestureRecognizer:longPress];
    
    return button;
}
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame {
    
    if ([attachment isKindOfClass:[DTImageTextAttachment class]]) {
        //处理图像大小的变化
        DTLazyImageView *lazyImageView = [[DTLazyImageView alloc] initWithFrame:frame];
        lazyImageView.delegate = self;
        
        lazyImageView.image = [(DTImageTextAttachment *)attachment image];
        lazyImageView.url = attachment.contentURL;
        
        //如果图片是可点击的
        if (attachment.hyperLinkURL) {
            lazyImageView.userInteractionEnabled = YES;
            DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:lazyImageView.bounds];
            button.URL = attachment.hyperLinkURL;
            button.minimumHitSize = CGSizeMake(25, 25);
            button.GUID = attachment.hyperLinkGUID;
            
            //跳转
            [button addTarget:self action:@selector(linkClicked:) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
            [button addGestureRecognizer:longPress];
            
        }
        return lazyImageView;
    }
    
    return nil;
}
- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame {
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame,1,1) cornerRadius:10];
    
    CGColorRef color = [textBlock.backgroundColor CGColor];
    if (color)
    {
        CGContextSetFillColorWithColor(context, color);
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextFillPath(context);
        
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        CGContextStrokePath(context);
        return NO;
    }
    
    return YES; // draw standard background
}

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        [[UIApplication sharedApplication] openURL:[self.lastActionLink absoluteURL]];
    }
}

#pragma mark - DTLazyImageViewDelegate
- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    NSURL *url = lazyImageView.url;
    CGSize imageSize = size;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    
    BOOL didUpdate = NO;
    
    // update all attachments that matchin this URL (possibly multiple images with same size)
    for (DTTextAttachment *oneAttachment in [self.articleView.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            CGFloat rw = [SMStyle floatScreenWidth] - [SMStyle floatMarginMassive]*2;
            CGFloat rh = (rw*imageSize.height)/imageSize.width;
            oneAttachment.displaySize = CGSizeMake(rw, rh);
            
            didUpdate = YES;
        }
    }
    
    if (didUpdate)
    {
        // layout might have changed due to image sizes
        self.articleView.layouter = nil;
        [self.articleView relayoutText];
        CGSize sizeNeed = self.articleView.layoutFrame.frame.size;
//        //更新高
        [self.articleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(sizeNeed.height + [SMStyle floatMarginMassive]*3);
        }];
        [self.backScrollViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.articleView.mas_bottom);
        }];
        
    }
    
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
        _articleView.shouldDrawImages = NO;
        _articleView.shouldDrawLinks = NO;
        _articleView.delegate = self;
    }
    return _articleView;
}

@end

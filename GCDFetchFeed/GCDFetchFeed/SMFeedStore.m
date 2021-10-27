//
//  SMFeedStore.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/20.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMFeedStore.h"
#import "Ono.h"

@interface SMFeedStore()



@end

@implementation SMFeedStore

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        //
    }
    return self;
}

#pragma mark - Interface
- (SMFeedModel *)updateFeedModelWithData:(NSData *)feedData preModel:(SMFeedModel *)preModel{
    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:feedData error:nil];
    SMFeedModel *feedModel = [[SMFeedModel alloc] init];
    //原有model需要保留的
    feedModel.feedUrl = preModel.feedUrl;
    feedModel.fid = preModel.fid;
    feedModel.unReadCount = preModel.unReadCount;
    feedModel.des = preModel.des;
    //开始解析
    NSMutableArray *itemArray = [NSMutableArray array];
    for (ONOXMLElement *element in document.rootElement.children) {
        
        //rss2类型
        if ([element.tag isEqualToString:@"channel"]) {
            for (ONOXMLElement *channelChild in element.children) {
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"title"]) {
                    feedModel.title = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"link"]) {
                    feedModel.link = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"description"]) {
                    feedModel.des = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"copyright"]) {
                    feedModel.copyright = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"generator"]) {
                    feedModel.generator = channelChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"image"]) {
                    for (ONOXMLElement *channelImage in channelChild.children) {
                        if ([self isEqualToWithDoNotCareLowcaseString:channelImage.tag compareString:@"url"]) {
                            if (channelImage.stringValue.length > 0 && !(preModel.imageUrl.length > 0)) {
                                feedModel.imageUrl = channelImage.stringValue;
                            }
                        }
                    }
                }
                if ([self isEqualToWithDoNotCareLowcaseString:channelChild.tag compareString:@"item"]) {
                    
                    SMFeedItemModel *itemModel = [[SMFeedItemModel alloc] init];
                    for (ONOXMLElement *channelItem in channelChild.children) {
                        
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"link"]) {
                            itemModel.link = channelItem.stringValue;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"title"]) {
                            itemModel.title = channelItem.stringValue;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"author"]) {
                            itemModel.author = channelItem.stringValue;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"category"]) {
                            itemModel.category = channelItem.stringValue;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"pubdate"]) {
                            itemModel.pubDate = channelItem.stringValue;
                        }
                        if ([self isEqualToWithDoNotCareLowcaseString:channelItem.tag compareString:@"description"]) {
                            itemModel.des = channelItem.stringValue;
                        }
                        
                    }
                    [itemArray addObject:itemModel];
                } //end item
                
            } //end channel
        }
        
        //--------atom类型的处理------
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"title"]) {
            feedModel.title = element.stringValue;
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"subtitle"]) {
            feedModel.des = element.stringValue;
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"link"]) {
            feedModel.link = (NSString *)[element valueForAttribute:@"href"];
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"id"]) {
            feedModel.link = element.stringValue;
        }
        if ([self isEqualToWithDoNotCareLowcaseString:element.tag compareString:@"rights"]) {
            feedModel.copyright = element.stringValue;
        }
        if ([element.tag isEqualToString:@"entry"]) {
            SMFeedItemModel *itemModel = [[SMFeedItemModel alloc] init];
            for (ONOXMLElement *entryChild in element.children) {
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"link"]) {
                    itemModel.link = (NSString *)[entryChild valueForAttribute:@"href"];;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"title"]) {
                    itemModel.title = entryChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"author"]) {
                    for (ONOXMLElement *authorChild in entryChild.children) {
                        if ([self isEqualToWithDoNotCareLowcaseString:authorChild.tag compareString:@"name"]) {
                            if (authorChild.stringValue.length > 0) {
                                itemModel.author = authorChild.stringValue;
                            }
                        }
                    }
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"updated"]) {
                    itemModel.pubDate = entryChild.stringValue;
                }
                if ([self isEqualToWithDoNotCareLowcaseString:entryChild.tag compareString:@"content"]) {
                    itemModel.des = entryChild.stringValue;
                }
            }
            [itemArray addObject:itemModel];
        } //end entry
        
        //preModel和feedModel的合并取舍
        if (!(feedModel.imageUrl.length > 0)) {
            feedModel.imageUrl = preModel.imageUrl;
        }
    }
    feedModel.items = itemArray;
    return feedModel;
}

+ (NSMutableArray *)defaultFeeds {
    NSMutableArray *mArr = [NSMutableArray array];
    SMFeedModel *starmingFeed = [[SMFeedModel alloc] init];
    starmingFeed.title = @"Starming星光社最新更新";
    starmingFeed.feedUrl = @"http://www.starming.com/atom.xml";
    starmingFeed.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_starming.png?raw=true";
    starmingFeed.des = @"戴铭的博客";
    [mArr addObject:starmingFeed];
    
    SMFeedModel *cnbetaFeed = [[SMFeedModel alloc] init];
    cnbetaFeed.title = @"cnBeta.COM业界咨询";
    cnbetaFeed.feedUrl = @"http://www.cnbeta.com/backend.php";
    cnbetaFeed.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_cnbeta.jpeg?raw=true";
    [mArr addObject:cnbetaFeed];
    
    SMFeedModel *kr36Feed = [[SMFeedModel alloc] init];
    kr36Feed.title = @"InfoQ";
    kr36Feed.feedUrl = @"https://www.infoq.cn/feed.xml";
    kr36Feed.imageUrl = @"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAN4AAABCCAYAAAA4w2iPAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3NpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMDY3IDc5LjE1Nzc0NywgMjAxNS8wMy8zMC0yMzo0MDo0MiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkODJhNjkwMy02N2Y0LTQzZDUtYjQ4Zi01YWY3MDFmYzYwMjgiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QkE3RDVDM0RBOEREMTFFOEE4NDZFOTE1MUQ2NkUyQjkiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QkE3RDVDM0NBOEREMTFFOEE4NDZFOTE1MUQ2NkUyQjkiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChNYWNpbnRvc2gpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6Y2Q4MTJmYzctNDhhNy00YzM5LWE0MzgtYjk3ZTdkMTFhYjFhIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOmQ4MmE2OTAzLTY3ZjQtNDNkNS1iNDhmLTVhZjcwMWZjNjAyOCIvPiA8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";
    [mArr addObject:kr36Feed];
    
    SMFeedModel *dgtleFeed = [[SMFeedModel alloc] init];
    dgtleFeed.title = @"数字尾巴-分享美好数字生活";
    dgtleFeed.feedUrl = @"http://www.dgtle.com/rss/dgtle.xml";
    dgtleFeed.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_dgtle.jpeg?raw=true";
    [mArr addObject:dgtleFeed];
    
    SMFeedModel *ifanrFeed = [[SMFeedModel alloc] init];
    ifanrFeed.title = @"爱范儿";
    ifanrFeed.feedUrl = @"http://www.ifanr.com/feed";
    ifanrFeed.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_ifanr.jpeg?raw=true";
    [mArr addObject:ifanrFeed];
    
    SMFeedModel *v2exFeed = [[SMFeedModel alloc] init];
    v2exFeed.title = @"V2EX";
    v2exFeed.feedUrl = @"http://www.v2ex.com/index.xml";
    v2exFeed.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_v2ex.png?raw=true";
    [mArr addObject:v2exFeed];
    
    SMFeedModel *ftFeed = [[SMFeedModel alloc] init];
    ftFeed.title = @"FT中文网";
    ftFeed.feedUrl = @"http://www.ftchinese.com/rss/feed";
    ftFeed.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_ft.jpg?raw=true";
    [mArr addObject:ftFeed];
    
    SMFeedModel *zhihuDaily = [[SMFeedModel alloc] init];
    zhihuDaily.title = @"知乎每日精选";
    zhihuDaily.feedUrl = @"http://www.zhihu.com/rss";
    zhihuDaily.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_zhihu.png?raw=true";
    [mArr addObject:zhihuDaily];
    
    SMFeedModel *cnEngadget = [[SMFeedModel alloc] init];
    cnEngadget.title = @"engadget中国版";
    cnEngadget.feedUrl = @"http://cn.engadget.com/rss.xml";
    cnEngadget.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_engadget.jpg?raw=true";
    [mArr addObject:cnEngadget];
    
    SMFeedModel *geekpark = [[SMFeedModel alloc] init];
    geekpark.title = @"极客公园";
    geekpark.feedUrl = @"http://www.geekpark.net/rss";
    geekpark.imageUrl = @"https://github.com/ming1016/GCDFetchFeed/blob/master/GCDFetchFeed/resource/logo_geekpark.jpeg?raw=true";
    [mArr addObject:geekpark];
    
    return mArr;
}

#pragma mark - private
- (BOOL)isEqualToWithDoNotCareLowcaseString:(NSString *)string compareString:(NSString *)compareString {
    if ([string.lowercaseString isEqualToString:compareString.lowercaseString]) {
        return YES;
    }
    return NO;
}

@end

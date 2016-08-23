//
//  SMFeedModel.h
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/19.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@class SMFeedItemModel;

@interface SMFeedModel : JSONModel
@property (nonatomic) NSUInteger fid;
@property (nonatomic, copy) NSString<Optional> *title;        //名称
@property (nonatomic, copy) NSString<Optional> *link;         //博客链接
@property (nonatomic, copy) NSString<Optional> *des;          //简介
@property (nonatomic, copy) NSString<Optional> *copyright;
@property (nonatomic, copy) NSString<Optional> *generator;
@property (nonatomic, copy) NSString<Optional> *imageUrl;     //icon图标
@property (nonatomic, strong) NSArray *items;                 //SMFeedItemModel
@property (nonatomic, copy) NSString<Optional> *feedUrl;      //博客feed的链接
@property (nonatomic) NSUInteger unReadCount;

@end

//feed item
@interface SMFeedItemModel : JSONModel
@property (nonatomic) NSUInteger iid;
@property (nonatomic) NSUInteger fid;
@property (nonatomic, copy) NSString<Optional> *link;         //文章链接
@property (nonatomic, copy) NSString<Optional> *title;        //文章标题
@property (nonatomic, copy) NSString<Optional> *author;       //作者
@property (nonatomic, copy) NSString<Optional> *category;     //分类
@property (nonatomic, copy) NSString<Optional> *pubDate;      //发布日期
@property (nonatomic, copy) NSString<Optional> *des;
@property (nonatomic) NSUInteger isRead;

@end

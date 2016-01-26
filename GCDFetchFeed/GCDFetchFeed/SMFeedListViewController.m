//
//  SMFeedListViewController.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/22.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMFeedListViewController.h"
#import "Masonry.h"
#import "SMFeedStore.h"
#import "SMFeedListCell.h"

@interface SMFeedListViewController()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) SMFeedModel *feedModel;    //需要用的feed的model
@property (nonatomic, strong) NSMutableArray *listData;  //datasource
@property (nonatomic, strong) SMFeedStore *feedStore;
@property (nonatomic, strong) UITableView *tableView;


@end

@implementation SMFeedListViewController

- (instancetype)init {
    if (self = [super init]) {
        //
    }
    return self;
}

- (instancetype)initWithModel:(SMFeedModel *)model {
    if (self = [super init]) {
        self.feedModel = model;
        self.listData = [NSMutableArray arrayWithArray:model.items];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Getter
- (NSMutableArray *)listData {
    if (!_listData) {
        _listData = [NSMutableArray array];
    }
    return _listData;
}

@end

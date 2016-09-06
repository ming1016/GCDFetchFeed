//
//  SMRootViewController.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/19.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMRootViewController.h"
#import "SMNetManager.h"
#import "Ono.h"
#import "Masonry.h"
#import "SMNotificationConst.h"
#import "SMSubContentLabel.h"

#import "SMFeedStore.h"
#import "SMRootDataSource.h"
#import "SMRootCell.h"

#import "SMDB.h"

#import "SMFeedListViewController.h"

static NSString *rootViewControllerIdentifier = @"SMRootViewControllerCell";

@interface SMRootViewController()<UITableViewDataSource,UITableViewDelegate,SMRootCellDelegate>
//data
@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic, strong) SMFeedStore *feedStore;
@property (nonatomic, strong) SMRootDataSource *dataSource;
@property (nonatomic) NSUInteger fetchingCount;
//view
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tbHeaderView;
@property (nonatomic, strong) SMSubContentLabel *tbHeaderLabel;
@end

@implementation SMRootViewController

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //Notification
    //UI
    self.title = @"已阅";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:rootViewControllerIdentifier];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    self.tbHeaderView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30);
    [self.tbHeaderView addSubview:self.tbHeaderLabel];
    
    [self.tbHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.tbHeaderView);
        make.centerX.equalTo(self.tbHeaderView);
    }];
    
    //本地
    @weakify(self);
    //首页列表数据赋值，过滤无效数据
    RAC(self, feeds) = [[[SMDB shareInstance] selectAllFeeds] filter:^BOOL(NSMutableArray *feedsArray) {
        if (feedsArray.count > 0) {
            return YES;
        } else {
            return NO;
        }
    }];
    //监听列表数据变化进行列表更新
    [RACObserve(self, feeds) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    //网络获取
    [self fetchAllFeeds];
    
    [[self rac_signalForSelector:@selector(smRootCellView:clickWithFeedModel:) fromProtocol:@protocol(SMRootCellDelegate)] subscribeNext:^(RACTuple *value) {
        @strongify(self);
        SMFeedModel *feedModel = (SMFeedModel *)value.second;
        SMFeedListViewController *feedList = [[SMFeedListViewController alloc] initWithFeedModel:feedModel];
        [self.navigationController pushViewController:feedList animated:YES];
    }];
    
}

#pragma mark - private
- (void)fetchAllFeeds {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.tableView.tableHeaderView = self.tbHeaderView;
    self.fetchingCount = 0; //统计抓取数量
    @weakify(self);
    [[[[[[SMNetManager shareInstance] fetchAllFeedWithModelArray:self.feeds] map:^id(NSNumber *value) {
        @strongify(self);
        NSUInteger index = [value integerValue];
        self.feeds[index] = [SMNetManager shareInstance].feeds[index];
        return self.feeds[index];
    }] doCompleted:^{
        //抓完所有的feeds
        @strongify(self);
        NSLog(@"fetch complete");
        //完成置为默认状态
        self.tbHeaderLabel.text = @"";
        self.tableView.tableHeaderView = [[UIView alloc] init];
        self.fetchingCount = 0;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(SMFeedModel *feedModel) {
        //抓完一个
        @strongify(self);
        //显示抓取状态
        self.fetchingCount += 1;
        self.tbHeaderLabel.text = [NSString stringWithFormat:@"正在获取%@...(%lu/%lu)",feedModel.title,(unsigned long)self.fetchingCount,(unsigned long)self.feeds.count];
        [self.tableView reloadData];
    }];
}

#pragma mark - Delegate
#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feeds count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rootViewControllerIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    SMRootCell *v = (SMRootCell *)[cell viewWithTag:123432];
    
    if (!v) {
        v = [[SMRootCell alloc] init];
        v.tag = 123432;
        v.delegate = self;
        [cell.contentView addSubview:v];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.top.bottom.equalTo(cell.contentView);
        }];
    }
    
    SMFeedModel *model = self.feeds[indexPath.row];
    SMRootCellViewModel *viewModel = [[SMRootCellViewModel alloc] init];
    viewModel.titleString = model.title;
    viewModel.contentString = model.des;
    viewModel.iconUrl = model.imageUrl;
    viewModel.highlightString = [NSString stringWithFormat:@"%lu",(unsigned long)model.unReadCount];
    viewModel.feedModel = model;
    [v updateWithViewModel:viewModel];
    
    return cell;
}

#pragma mark - Getter
- (SMRootDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[SMRootDataSource alloc] init];
    }
    return _dataSource;
}
- (SMFeedStore *)feedStore {
    if (!_feedStore) {
        _feedStore = [[SMFeedStore alloc] init];
    }
    return _feedStore;
}
- (NSMutableArray *)feeds {
    if (!_feeds) {
        _feeds = [SMFeedStore defaultFeeds];
    }
    return _feeds;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [SMStyle colorPaperLight];
        _tableView.showsVerticalScrollIndicator = false;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}
- (UIView *)tbHeaderView {
    if (!_tbHeaderView) {
        _tbHeaderView = [[UIView alloc] init];
    }
    return _tbHeaderView;
}
- (SMSubContentLabel *)tbHeaderLabel {
    if (!_tbHeaderLabel) {
        _tbHeaderLabel = [[SMSubContentLabel alloc] init];
    }
    return _tbHeaderLabel;
}


@end

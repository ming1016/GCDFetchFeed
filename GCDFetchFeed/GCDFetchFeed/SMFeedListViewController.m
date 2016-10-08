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
#import "SMFeedListCellViewModel.h"
#import "NSDate+InternetDateTime.h"
#import "SMArticleViewController.h"
#import "SMDB.h"
#import "SMNetManager.h"
#import "MJRefresh.h"
#import "SMStyle.h"
#import "SMSubContentLabel.h"

static NSString *feedListViewControllerCellIdentifier = @"SMFeedListViewControllerCell";

@interface SMFeedListViewController()<UITableViewDataSource,UITableViewDelegate,SMFeedListCellDelegate>

@property (nonatomic, strong) SMFeedModel *feedModel;    //需要用的feed的model
@property (nonatomic, strong) NSMutableArray *listData;  //datasource
@property (nonatomic, strong) SMFeedStore *feedStore;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSUInteger page;

//下拉刷新
@property (nonatomic) NSUInteger fetchingCount;
@property (nonatomic, strong) UIView *tbHeaderView;
@property (nonatomic, strong) SMSubContentLabel *tbHeaderLabel;
@property (nonatomic, strong) NSMutableArray *feeds;

@end

@implementation SMFeedListViewController

#pragma mark - Life Cycle

- (instancetype)initWithFeedModel:(SMFeedModel *)feedModel {
    if (self = [super init]) {
        self.feedModel = feedModel;
        self.page = 0;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SMStyle colorPaperLight];
    
    RAC(self, feeds) = [[[SMDB shareInstance] selectAllFeeds] filter:^BOOL(NSMutableArray *feedsArray) {
        if (feedsArray.count > 0) {
            return YES;
        } else {
            return NO;
        }
    }];
    self.tbHeaderView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30);
    [self.tbHeaderView addSubview:self.tbHeaderLabel];
    
    [self.tbHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.tbHeaderView);
        make.centerX.equalTo(self.tbHeaderView);
    }];
    
    //列表类型不同的处理
    if (self.feedModel.fid == 0) {
        self.title = @"列表";
        //下拉刷新
        @weakify(self);
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            self.fetchingCount = 0; //统计抓取数量
            @weakify(self);
            [[[[[[SMNetManager shareInstance] fetchAllFeedWithModelArray:self.feeds] map:^id(NSNumber *value) {
                NSUInteger index = [value integerValue];
                self.feeds[index] = [SMNetManager shareInstance].feeds[index];
                return [SMNetManager shareInstance].feeds[index];
            }] doCompleted:^{
                //抓完所有的feeds
                @strongify(self);
                NSLog(@"fetch complete");
                //完成置为默认状态
                self.tbHeaderLabel.text = @"";
                self.tableView.tableHeaderView = [[UIView alloc] init];
                self.fetchingCount = 0;
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                //更新列表
                self.page = 0;
                self.listData = [NSMutableArray array];
                [self selectFeedItems];
                
            }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(SMFeedModel *feedModel) {
                //抓完一个
                @strongify(self);
                self.tableView.tableHeaderView = self.tbHeaderView;
                //显示抓取状态
                self.fetchingCount += 1;
                self.tbHeaderLabel.text = [NSString stringWithFormat:@"正在获取%@...(%lu/%lu)",feedModel.title,(unsigned long)self.fetchingCount,(unsigned long)self.feeds.count];
            }];
        }];
        MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)_tableView.mj_header;
        header.lastUpdatedTimeLabel.hidden = YES;
        [header.arrowView setImage:[UIImage imageNamed:@""]];
        header.stateLabel.font = [SMStyle fontSmall];
        header.stateLabel.textColor = [SMStyle colorPaperGray];
        [header setTitle:@"下拉更新数据" forState:MJRefreshStateIdle];
        [header setTitle:@"松开立刻更新" forState:MJRefreshStatePulling];
        [header setTitle:@"更新数据..." forState:MJRefreshStateRefreshing];
    } else {
        self.title = self.feedModel.title;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全部已读" style:UIBarButtonItemStylePlain target:self action:@selector(markAllAsRead)];
    }
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:feedListViewControllerCellIdentifier];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    [self selectFeedItems];
    
}

#pragma mark - Private
- (void)markAllAsRead {
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault];
    [[[[[SMDB shareInstance] markFeedAllItemsAsRead:self.feedModel.fid]
      subscribeOn:scheduler]
     deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
        //
    }];
    self.feedModel.unReadCount = 0;
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)reloadFeedItems {
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    @weakify(self);
    [[[[[SMDB shareInstance] selectFeedItemsWithPage:self.page fid:self.feedModel.fid] subscribeOn:scheduler] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        self.listData = x;
        if (self.listData.count < 50) {
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
    } completed:^{
        
    }];
}
- (void)selectFeedItems {
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    @weakify(self);
    [[[[[SMDB shareInstance] selectFeedItemsWithPage:self.page fid:self.feedModel.fid]
       subscribeOn:scheduler]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSMutableArray *x) {
         @strongify(self);
         self.tableView.mj_footer.hidden = NO;
         if (self.listData.count > 0) {
             //加载更多
             [self.listData addObjectsFromArray:x];
         } else {
             //进入时加载
             self.listData = x;
             if (self.listData.count < 50) {
                 self.tableView.mj_footer.hidden = YES;
             }
         }
         if (self.feedModel.fid == 0) {
             //下拉刷新关闭
             [self.tableView.mj_header endRefreshing];
         }
         //刷新
         [self.tableView reloadData];
    } error:^(NSError *error) {
        //处理无数据的显示
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } completed:^{
        //加载完成后的处理
        [self.tableView.mj_footer endRefreshing];
    }];
    self.page += 1;
}

#pragma mark - Delegate
#pragma mark - SMFeedListCell Delegate
- (void)smFeedListCellView:(SMFeedListCell *)cell clickWithItemModel:(SMFeedItemModel *)itemModel {
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    @weakify(self);
    [[[[[SMDB shareInstance] markFeedItemAsRead:itemModel.iid fid:self.feedModel.fid] subscribeOn:scheduler] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if (itemModel.isRead > 0) {
            //
        } else {
            //界面显示处理
            itemModel.isRead = 1;
            for (SMFeedItemModel *aItemModel in self.listData) {
                if (aItemModel.iid > itemModel.iid) {
                    aItemModel.isRead = 1;
                }
            }
            [self.tableView reloadData];
            self.feedModel.unReadCount -= [x integerValue];
        }
    }];
    SMArticleViewController *articleVC = [[SMArticleViewController alloc] initWithFeedModel:itemModel];
    articleVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:articleVC animated:YES];
}
#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMFeedItemModel *itemModel = self.listData[indexPath.row];
    SMFeedListCellViewModel *viewModel = [[SMFeedListCellViewModel alloc] init];
    viewModel.titleString = itemModel.title;
    return viewModel.cellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:feedListViewControllerCellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    SMFeedListCell *v = (SMFeedListCell *)[cell viewWithTag:132421];
    if (!v) {
        v = [[SMFeedListCell alloc] init];
        v.tag = 132421;
        v.delegate = self;
        [cell.contentView addSubview:v];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.top.bottom.equalTo(cell.contentView);
        }];
    }
    
    SMFeedItemModel *itemModel = self.listData[indexPath.row];
    SMFeedListCellViewModel *viewModel = [[SMFeedListCellViewModel alloc] init];
    viewModel.titleString = itemModel.title;
    NSDate *date = [NSDate dateFromInternetDateTimeString:itemModel.pubDate formatHint:DateFormatHintRFC822];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    NSString *authorString = @"";
    if (itemModel.author.length > 0) {
        authorString = itemModel.author;
    }
    NSString *categoryString = @"";
    if (itemModel.category.length > 0) {
        categoryString = [NSString stringWithFormat:@"[%@]",itemModel.category];
    }
    NSString *dateString = @"";
    if ([dateFormatter stringFromDate:date]) {
        dateString = [NSString stringWithFormat:@"%@ ",[dateFormatter stringFromDate:date]];
    }
    viewModel.contentString = [NSString stringWithFormat:@"%@%@ %@",dateString,categoryString,authorString];
    viewModel.iconUrlString = itemModel.iconUrl;
    viewModel.itemModel = itemModel;
    [v updateWithViewModel:viewModel];
    
    return cell;
}

#pragma mark - Getter
- (NSMutableArray *)listData {
    if (!_listData) {
        _listData = [NSMutableArray array];
    }
    return _listData;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //mj
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(selectFeedItems)];
        MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)_tableView.mj_footer;
        footer.stateLabel.font = [SMStyle fontSmall];
        footer.stateLabel.textColor = [SMStyle colorPaperGray];
        [footer setTitle:@"上拉读取更多" forState:MJRefreshStateIdle];
        [footer setTitle:@"正在读取..." forState:MJRefreshStateRefreshing];
        [footer setTitle:@"已读取完毕" forState:MJRefreshStateNoMoreData];
        
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

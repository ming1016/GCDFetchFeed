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
#import "MJRefresh.h"
#import "SMStyle.h"

static NSString *feedListViewControllerCellIdentifier = @"SMFeedListViewControllerCell";

@interface SMFeedListViewController()<UITableViewDataSource,UITableViewDelegate,SMFeedListCellDelegate>

@property (nonatomic, strong) SMFeedModel *feedModel;    //需要用的feed的model
@property (nonatomic, strong) NSMutableArray *listData;  //datasource
@property (nonatomic, strong) SMFeedStore *feedStore;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSUInteger page;

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
    self.title = self.feedModel.title;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:feedListViewControllerCellIdentifier];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    [self selectFeedItems];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全部已读" style:UIBarButtonItemStylePlain target:self action:@selector(markAllAsRead)];
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
    [[[[[SMDB shareInstance] markFeedItemAsRead:itemModel.iid] subscribeOn:scheduler] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        if (itemModel.isRead > 0) {
            //
        } else {
            itemModel.isRead = 1;
            [self.tableView reloadData];
            self.feedModel.unReadCount -= 1;
        }
    }];
    SMArticleViewController *articleVC = [[SMArticleViewController alloc] initWithFeedModel:itemModel];
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

@end

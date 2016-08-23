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
- (instancetype)init {
    if (self = [super init]) {
        //
    }
    return self;
}
- (instancetype)initWithFeedModel:(SMFeedModel *)feedModel {
    if (self = [super init]) {
        self.feedModel = feedModel;
//        if (feedModel.items.count > 0) {
//            self.listData = [NSMutableArray arrayWithArray:feedModel.items];
//        }
        self.page = 0;
        [self selectFeedItems];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.feedModel.title;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:feedListViewControllerCellIdentifier];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
//    [self.tableView reloadData];
}

#pragma mark - Private
- (void)selectFeedItems {
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];

    @weakify(self);
    [[[[[SMDB shareInstance] selectFeedItemsWithPage:self.page fid:self.feedModel.fid]
       subscribeOn:scheduler]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSMutableArray *x) {
        @strongify(self);
        if (self.listData.count > 0) {
            [self.listData addObjectsFromArray:x];
        } else {
            self.listData = x;
        }
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } completed:^{
        [self.tableView.mj_footer endRefreshing];
    }];
    self.page += 1;
}

#pragma mark - Delegate
#pragma mark - SMFeedListCell Delegate
- (void)smFeedListCellView:(SMFeedListCell *)cell clickWithItemModel:(SMFeedItemModel *)itemModel {
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
    if ([UIDevice currentDevice].systemVersion.integerValue > 7) {
        return UITableViewAutomaticDimension;
    }
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
    [dateFormatter setDateFormat:@"MM-dd"];
    NSString *authorString = @"";
    if (itemModel.author.length > 0) {
        authorString = itemModel.author;
    }
    NSString *categoryString = @"";
    if (itemModel.category.length > 0) {
        categoryString = [NSString stringWithFormat:@"[%@]",itemModel.category];
    }
    viewModel.contentString = [NSString stringWithFormat:@"%@ %@ %@",[dateFormatter stringFromDate:date],categoryString,authorString];
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
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //mj
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(selectFeedItems)];
    }
    return _tableView;
}

@end

//
//  SMStackViewController.m
//  DecoupleDemo
//
//  Created by DaiMing on 2017/8/17.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import "SMStackViewController.h"
#import "MJRefresh.h"
#import "SMStackCell.h"
#import "Masonry.h"
#import "SMLagDB.h"
#import "SMLagButton.h"

static NSString *smStackCellIdentifier = @"smStackCell";

@interface SMStackViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *listData;
@property (nonatomic, strong) UITableView *tbView;
@property (nonatomic) NSUInteger page;
@property (nonatomic, strong) SMLagButton *closeView;
@property (nonatomic, strong) SMLagButton *clearAndCloseView;

@end

@implementation SMStackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.page = 0;
    [self selectItems];
    [self.tbView registerClass:[UITableViewCell class] forCellReuseIdentifier:smStackCellIdentifier];
    [self.view addSubview:self.tbView];
    [self.tbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
    }];
    [self.view addSubview:self.closeView];
    [self.closeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.view).offset(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.view addSubview:self.clearAndCloseView];
    [self.clearAndCloseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.closeView.mas_left).offset(-10);
        make.top.equalTo(self.closeView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)selectItems {
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    @weakify(self);
    [[[[[SMLagDB shareInstance] selectStackWithPage:self.page]
    subscribeOn:scheduler]
    deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(id x) {
        @strongify(self);
        self.tbView.mj_footer.hidden = NO;
        if (self.listData.count > 0) {
            //加载更多
            [self.listData addObjectsFromArray:x];
        } else {
            //进入时加载
            self.listData = x;
            if (self.listData.count < 50) {
                self.tbView.mj_footer.hidden = YES;
            }
        }
        //刷新
        [self.tbView reloadData];
    } error:^(NSError *error) {
        //处理无数据显示
        [self.tbView.mj_footer endRefreshingWithNoMoreData];
    } completed:^{
        //加载完成后的处理
        [self.tbView.mj_footer endRefreshing];
    }];
    self.page += 1;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:smStackCellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.selected = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    SMStackCell *v = (SMStackCell *)[cell viewWithTag:231876];
    if (!v) {
        v = [[SMStackCell alloc] init];
        v.tag = 231876;
        if (cell) {
            [cell.contentView addSubview:v];
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.left.top.bottom.equalTo(cell.contentView);
            }];
        }
    }
    
    NSString *str = self.listData[indexPath.row];
    [v updateWithStr:str];
    return cell;
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter
- (NSMutableArray *)listData {
    if (!_listData) {
        _listData = [NSMutableArray array];
    }
    return _listData;
}
- (UITableView *)tbView {
    if (!_tbView) {
        _tbView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tbView.dataSource = self;
        _tbView.delegate = self;
        _tbView.backgroundColor = [UIColor clearColor];
        _tbView.separatorStyle = UITableViewCellSelectionStyleNone;
        //mj
        _tbView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(selectItems)];
        MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)_tbView.mj_footer;
        footer.stateLabel.font = [UIFont systemFontOfSize:12];
        footer.stateLabel.textColor = [UIColor lightGrayColor];
        [footer setTitle:@"上拉读取更多" forState:MJRefreshStateIdle];
        [footer setTitle:@"正在读取..." forState:MJRefreshStateRefreshing];
        [footer setTitle:@"已读取完毕" forState:MJRefreshStateNoMoreData];
    }
    return _tbView;
}
- (SMLagButton *)closeView {
    if (!_closeView) {
        _closeView = [[SMLagButton alloc] initWithStr:@"X" size:24 backgroundColor:[UIColor blackColor]];
        @weakify(self);
        [[_closeView click] subscribeNext:^(id x) {
            @strongify(self);
            [self close];
        }];
    }
    return _closeView;
}
- (SMLagButton *)clearAndCloseView {
    if (!_clearAndCloseView) {
        _clearAndCloseView = [[SMLagButton alloc] initWithStr:@"CX" size:20 backgroundColor:[UIColor redColor]];
        @weakify(self);
        [[_clearAndCloseView click] subscribeNext:^(id x) {
            @strongify(self);
            [[SMLagDB shareInstance] clearStackData];
            [self close];
        }];
    }
    return _clearAndCloseView;
}

@end

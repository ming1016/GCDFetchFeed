//
//  SMFeedListCell.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/22.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMFeedListCell.h"
#import "SMCellViewImport.h"

@interface SMFeedListCell()

@property (nonatomic, strong) SMTitleLabel *titleLabel;
@property (nonatomic, strong) SMContentLabel *contentLabel;
@property (nonatomic, strong) SMFeedItemModel *itemModel;

@property (nonatomic, strong) UIButton *clickButton;

@end

@implementation SMFeedListCell

- (instancetype)init {
    if (self = [super init]) {
        [self buildUI];
    }
    return self;
}
- (instancetype)initWithViewModel:(SMFeedListCellViewModel *)viewModel {
    if (self = [super init]) {
        [self buildUI];
        [self updateWithViewModel:viewModel];
    }
    return self;
}

- (void)buildUI {
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.clickButton];
    
    [self.clickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset([SMStyle floatMarginMassive]);
    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset([SMStyle floatTextIntervalHorizontal]);
        make.bottom.equalTo(self);
    }];
    
}

#pragma mark - Interface
- (void)updateWithViewModel:(SMFeedListCellViewModel *)viewModel {
    self.titleLabel.text = viewModel.titleString;
    self.contentLabel.text = viewModel.contentString;
    if (viewModel.itemModel.isRead > 0) {
        self.titleLabel.textColor = [SMStyle colorPaperGray];
    } else {
        self.titleLabel.textColor = [SMStyle colorPaperBlack];
    }
    self.itemModel = viewModel.itemModel;
}

#pragma mark - Private
- (void)clickedButton {
    if ([self.delegate respondsToSelector:@selector(smFeedListCellView:clickWithItemModel:)]) {
        [self.delegate smFeedListCellView:self clickWithItemModel:self.itemModel];
    }
}

#pragma mark - Getter
- (SMTitleLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SMTitleLabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - [SMStyle floatMarginMassive]*2;
        [_titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _titleLabel;
}
- (SMContentLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[SMContentLabel alloc] init];
        _contentLabel.textColor = [SMStyle colorPaperGray];
    }
    return _contentLabel;
}
- (UIButton *)clickButton {
    if (!_clickButton) {
        _clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clickButton setBackgroundColor:[SMStyle colorBlackLightAlpha] forState:UIControlStateHighlighted];
        [_clickButton addTarget:self action:@selector(clickedButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clickButton;
}

@end

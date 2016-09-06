//
//  SMRootCell.m
//  GCDFetchFeed
//
//  Created by DaiMing on 16/1/20.
//  Copyright © 2016年 Starming. All rights reserved.
//

#import "SMRootCell.h"
#import "SMCellViewImport.h"

@interface SMRootCell()

@property (nonatomic, strong) SMImageView *iconImageView;
@property (nonatomic, strong) SMTitleLabel *titleLabel;
@property (nonatomic, strong) SMContentLabel *contentLabel;
@property (nonatomic, strong) SMHighlightLabel *highlightLabel;
@property (nonatomic, strong) SMFeedModel *feedModel;

@property (nonatomic, strong) UIButton *clickButton;

@end

@implementation SMRootCell

- (instancetype)init {
    if (self = [super init]) {
        [self buildUI];
    }
    return self;
}

- (instancetype)initWithViewModel:(SMRootCellViewModel *)viewModel {
    if (self = [super init]) {
        [self buildUI];
        [self updateWithViewModel:viewModel];
    }
    return self;
}

- (void)buildUI {
    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.highlightLabel];
    [self addSubview:self.clickButton];
    
    [self.clickButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset([SMStyle floatMarginMassive]);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset([SMStyle floatMarginNormal]);
        make.top.equalTo(self.iconImageView).offset([SMStyle floatMarginMinor]);
        make.right.lessThanOrEqualTo(self).offset(-50);
    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset([SMStyle floatTextIntervalVertical]);
        make.right.lessThanOrEqualTo(self).offset(-50);
    }];
    [self.highlightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-[SMStyle floatMarginMassive]);
        make.top.equalTo(self.titleLabel).offset([SMStyle floatMarginMinor]);
    }];
}
#pragma mark - Interface
- (void)updateWithViewModel:(SMRootCellViewModel *)viewModel {
    self.titleLabel.text = viewModel.titleString;
    self.contentLabel.text = viewModel.contentString;
    [self.iconImageView updateWithImageWebUrl:viewModel.iconUrl];
    self.highlightLabel.text = viewModel.highlightString;
    self.feedModel = viewModel.feedModel;
}
#pragma mark - Private
- (void)clickedButton {
    if ([self.delegate respondsToSelector:@selector(smRootCellView:clickWithFeedModel:)]) {
        [self.delegate smRootCellView:self clickWithFeedModel:self.feedModel];
    }
}

#pragma mark - Getter
- (SMImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[SMImageView alloc] init];
    }
    return _iconImageView;
}
- (SMTitleLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SMTitleLabel alloc] init];
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
- (SMHighlightLabel *)highlightLabel {
    if (!_highlightLabel) {
        _highlightLabel = [[SMHighlightLabel alloc] init];
        _highlightLabel.textAlignment = NSTextAlignmentRight;
        _highlightLabel.textColor = [SMStyle colorPaperGray];
    }
    return _highlightLabel;
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

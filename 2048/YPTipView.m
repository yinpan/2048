//
//  YPTipView.m
//  2048
//
//  Created by yinpan on 16/3/23.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import "YPTipView.h"
#import "UIColor+Util.h"
@interface YPTipView ()

@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;


@end
@implementation YPTipView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        self.userInteractionEnabled = YES;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        CGFloat w = CGRectGetWidth(frame);
        CGFloat h = CGRectGetHeight(frame);
        self.backgroundColor = [[UIColor themeBackgroudColor] colorWithAlphaComponent:0.8];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0, h * 0.1 ,w, h * 0.2)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _titleLabel.textColor = [UIColor theme32BackgroundColor];
        [self addSubview:_titleLabel];
        
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, h *0.3, w, h * 0.3)];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont systemFontOfSize:30];
        _contentLabel.textColor = [UIColor themeTitleColor];
        _contentLabel.adjustsFontSizeToFitWidth = YES;
        _contentLabel.numberOfLines = 2;
        [self addSubview:_contentLabel];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(w * 0.15, h * 0.65, w * 0.25, 36)];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:_cancelButton];
        [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.layer.cornerRadius = 18;
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.backgroundColor = [UIColor themeScoreButtonColor];
        
        _okButton = [[UIButton alloc] initWithFrame:CGRectMake(w * 0.6, w * 0.65, w * 0.25, 36)];
        [_okButton addTarget:self action:@selector(okButtonCliked) forControlEvents:UIControlEventTouchUpInside];
        [_okButton setTitle:@"Continue" forState:UIControlStateNormal];
        _okButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _okButton.layer.cornerRadius = 18;
        _okButton.layer.masksToBounds = YES;
        _okButton.backgroundColor = [UIColor themeScoreButtonColor];
        [self addSubview:_okButton];
    }
    return self;
}

- (void)showTipWithTipStyle:(YPTipStyle)tipStyle withRecord:(NSInteger)record
{
    self.hidden = NO;
    switch (tipStyle) {
        case YPTipStyleFail:
            [_okButton setTitle:@"OK" forState:UIControlStateNormal];
            _contentLabel.text = @"Fail,try again";
            _titleLabel.text = @"Fail";
            _okButton.transform = CGAffineTransformMakeTranslation(- CGRectGetWidth(self.frame) * 0.225, 0);
            _cancelButton.hidden = YES;
            _okButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            break;
        case YPTipStyleNewRecord:
            [_okButton setTitle:@"OK" forState:UIControlStateNormal];
            _contentLabel.text = [NSString stringWithFormat:@"New Record: %ld",record];
            _titleLabel.text = @"New";
            _okButton.transform = CGAffineTransformMakeTranslation(- CGRectGetWidth(self.frame) * 0.225, 0);
            _cancelButton.hidden = YES;
            _okButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            break;
        case YPTipStyleSuccess:
            [_okButton setTitle:@"Continue" forState:UIControlStateNormal];
            _contentLabel.text = @"Good job,you get the 2048";
            _titleLabel.text = @"New Record";
            _okButton.transform = CGAffineTransformMakeTranslation(- CGRectGetWidth(self.frame) * 0.225, 0);
            _cancelButton.hidden = YES;
            _okButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            break;
        case YPTipStyleWarn:
            [_okButton setTitle:@"OK" forState:UIControlStateNormal];
            _contentLabel.text = @"Are you sure start \n new game?";
            _titleLabel.text = @"Warn";
            _okButton.transform = CGAffineTransformIdentity;
            _cancelButton.hidden = NO;
            _okButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            break;
        default:
            break;
    }
    
}

- (void)cancel
{
    self.hidden = YES;
}

- (void)okButtonCliked
{
    self.hidden = YES;
    self.finished(YES);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

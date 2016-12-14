//
//  YPCellView.m
//  2048
//
//  Created by yinpan on 16/3/20.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import "YPCellView.h"
#import "UIColor+Util.h"
#import "YPCellModel.h"


@interface YPCellView ()

@property (nonatomic, strong) UILabel *animateLabel;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, assign) CGFloat width;
@end

@implementation YPCellView



- (instancetype)initWithFrame:(CGRect)frame borderWidth:(CGFloat)borderWidth
{
    if (self = [super initWithFrame:frame]) {
        self.value = 1;
        _borderWidth = borderWidth;
        _width = CGRectGetWidth(frame);
        _baseView = [[UIView alloc] initWithFrame:self.bounds];
        _baseView.layer.cornerRadius = 5;
        _baseView.layer.masksToBounds = YES;
        [self addSubview:_baseView];
        _baseView.backgroundColor = [UIColor themeCellBackgroundColor];
        
        _animateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:_animateLabel];
        _animateLabel.font = [UIFont boldSystemFontOfSize:25];
        _animateLabel.adjustsFontSizeToFitWidth = YES;
        _animateLabel.layer.cornerRadius = 5;
        _animateLabel.layer.masksToBounds = YES;
        _animateLabel.textAlignment = NSTextAlignmentCenter;
        
        _model = [[YPCellModel alloc] init];
    }
    return self;
}


- (void)setValue:(NSUInteger)value
{
    _value = value;
    _model.value = _value;
    [self refreshColor];
    if (_value >= 2) {
        [self move];
    }else{
        _animateLabel.text = @"";
        _animateLabel.backgroundColor = [UIColor themeCellBackgroundColor];
    }
    
}


/** 出现 */
- (void)appear
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _animateLabel.transform = CGAffineTransformMakeScale(0.25, 0.25);
        _value = 2;
        _model.value = 2;
        _model.step = 0;
        _animateLabel.text = @"2";
        _animateLabel.backgroundColor = [UIColor theme2BackgroundColor];
        _animateLabel.textColor = [UIColor theme2TitleColor];
        [UIView animateWithDuration:0.15 animations:^{
            _animateLabel.transform = CGAffineTransformIdentity;
        }];
    });
}



/** 放大 */
- (void)zoomUnit
{
    _animateLabel.text = [NSString stringWithFormat:@"%ld",_value];
    if (self.model.isScale) {
        [UIView animateWithDuration:0.15 animations:^{
            _animateLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
            [self refreshColor];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                _animateLabel.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.model.isScale = NO;
            }];
        }];
    }else{
        [UIView animateWithDuration:0.15 animations:^{
            [self refreshColor];
        }];
    }
}



- (void)move
{
    CGRect rect = self.bounds;
    CGFloat distance = (_width + _borderWidth) * _step;
    _model.step = 0;
    _step = 0;
    switch (_direction) {
        case Up:{
            rect.origin.y -= distance;
        }
        case Down:{
            rect.origin.y += distance;
        }
        case Left:{
            rect.origin.x -= distance;
        }
        case Right:{
            rect.origin.x += distance;
        }
        default:
            break;
    }
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        _animateLabel.transform = CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y);
    } completion:^(BOOL finished) {
        _animateLabel.transform = CGAffineTransformIdentity;
        [self zoomUnit];
    }];
}

- (void)refreshColor
{
    switch (_value) {
        case 1:{
            _animateLabel.backgroundColor = [UIColor clearColor];
            break;
        }
        case 2:{
            _animateLabel.backgroundColor = [UIColor theme2BackgroundColor];
            _animateLabel.textColor = [UIColor theme2TitleColor];
            break;
        }
        case 4:{
            _animateLabel.backgroundColor = [UIColor theme4BackgroundColor];
            _animateLabel.textColor = [UIColor theme4TitleColor];
            break;
        }
        case 8:{
            _animateLabel.backgroundColor = [UIColor theme8BackgroundColor];
            break;
        }
        case 16:{
            _animateLabel.backgroundColor = [UIColor theme16BackgroundColor];
            break;
        }
        case 32:{
            _animateLabel.backgroundColor = [UIColor theme32BackgroundColor];
            break;
        }
        case 64:{
            _animateLabel.backgroundColor = [UIColor theme64BackgroundColor];
            break;
        }
        case 128:{
            _animateLabel.backgroundColor = [UIColor theme128BackgroundColor];
            break;
        }
        case 256:{
            _animateLabel.backgroundColor = [UIColor theme256BackgroundColor];
            break;
        }
        case 512:{
            _animateLabel.backgroundColor = [UIColor theme512BackgroundColor];
            break;
        }
        case 1024:{
            _animateLabel.backgroundColor = [UIColor theme1024BackgroundColor];
            break;
        }
        case 2048:{
            _animateLabel.backgroundColor = [UIColor theme2048BackgroundColor];
            break;
        }
        default:
            _animateLabel.backgroundColor = [UIColor themeMoreBackgroundColor];
            break;
    }
    if (_value > 4) {
        _animateLabel.textColor = [UIColor themeMoreTitleColor];
    }
    _step = 0;
    _model.step = 0;
}



- (void)comeTrue
{
    self.step = _model.step;
    self.value = _model.value;
}


@end

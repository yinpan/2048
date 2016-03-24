//
//  YPTipLabel.m
//  2048
//
//  Created by 千锋 on 16/3/22.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import "YPTipLabel.h"
#import "UIColor+Util.h"

@implementation YPTipLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.textColor = [UIColor theme32BackgroundColor];
        self.font = [UIFont boldSystemFontOfSize:18];
        self.textAlignment = NSTextAlignmentRight;
        self.adjustsFontSizeToFitWidth = YES;
        self.hidden = YES;
    }
    return self;
}


- (void)setValue:(NSInteger)value
{
    _isUsing = YES;
    _value = value;
    self.text = [NSString stringWithFormat:@"+%ld",_value];
    self.hidden = NO;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(0.6, 0.6), 0, - CGRectGetHeight(self.frame));
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
        _isUsing = NO;
    }];
}

@end

//
//  YPScoreLabel.m
//  2048
//
//  Created by 千锋 on 16/3/22.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import "YPScoreLabel.h"
#import "YPTipLabel.h"

@interface YPScoreLabel ()

@property (nonatomic, strong) NSMutableArray *tipArray;

@end

@implementation YPScoreLabel

- (NSMutableArray *)tipArray
{
    if (_tipArray == nil) {
        _tipArray = [NSMutableArray array];
    }
    return _tipArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        for (int i = 0; i < 4 ; i++) {
            YPTipLabel *tipLabel = [[YPTipLabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) * 0.5, CGRectGetHeight(frame) * 0.5 - 20, CGRectGetWidth(frame) * 0.5, 25)];
            [self addSubview:tipLabel];
            [self.tipArray addObject:tipLabel];
        }
    }
    return self;
}


- (void)setScore:(NSInteger)score
{
    for (YPTipLabel *label in self.tipArray) {
        if (!label.isUsing) {
            label.value = score;
            break;
        }
    }
}

@end

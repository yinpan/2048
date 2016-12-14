//
//  YPCellModel.m
//  2048
//
//  Created by yinpan on 16/3/21.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import "YPCellModel.h"

@implementation YPCellModel

- (instancetype)init
{
    if (self = [super init]) {
        _value = 1;
        _step = 0;
        _isScale = NO;
    }
    return self;
}

@end

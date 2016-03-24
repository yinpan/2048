//
//  YPManager.m
//  2048
//
//  Created by 千锋 on 16/3/17.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import "YPManager.h"

@implementation YPManager

+ (id)userObjectWithKey:(NSString *)key
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return obj;
}

+ (void)userSetObject:(id)object forKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
}

+ (void)traversalArray:(NSMutableArray *)array  handle:(YPHandleBlock)handleBlock
{
    NSInteger count = array.count;
    for (int i = 0; i < count; ++i) {
        NSArray *subArray = array[i];
        for (int j = 0; j < count; ++j) {
            handleBlock(subArray[j]);
        }
    }
}


@end

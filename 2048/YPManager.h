//
//  YPManager.h
//  2048
//
//  Created by 千锋 on 16/3/17.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^YPHandleBlock)(id);
@interface YPManager : NSObject

+ (void)traversalArray:(NSMutableArray *)array handle:(YPHandleBlock)handleBlock;

+ (void)userSetObject:(id)object forKey:(NSString *)key;

+ (id)userObjectWithKey:(NSString *)key;

@end

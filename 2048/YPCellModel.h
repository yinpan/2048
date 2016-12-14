//
//  YPCellModel.h
//  2048
//
//  Created by yinpan on 16/3/21.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPCellModel : NSObject

@property (nonatomic, assign) NSInteger step;
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) BOOL isScale;

@end

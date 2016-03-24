//
//  YPCellView.h
//  2048
//
//  Created by 千锋 on 16/3/20.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPCellModel.h"

typedef NS_ENUM(NSInteger,Direction){
    Up=1,
    Down,
    Left,
    Right
};
@interface YPCellView : UIView


@property (nonatomic, assign) Direction direction;
@property (nonatomic, assign) NSUInteger value;
@property (nonatomic, assign) NSUInteger oldValue;
@property (nonatomic, assign) NSUInteger step;
@property (nonatomic, strong) YPCellModel *model;


- (instancetype)initWithFrame:(CGRect)frame borderWidth:(CGFloat)borderWidth;

/** 出现 */
- (void)appear;

/** 实现 */
- (void)comeTrue;


@end

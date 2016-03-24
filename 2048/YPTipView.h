//
//  YPTipView.h
//  2048
//
//  Created by 千锋 on 16/3/23.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YPTipStyle) {
    YPTipStyleSuccess = 0,
    YPTipStyleFail,
    YPTipStyleWarn,
    YPTipStyleNewRecord
};
typedef void(^YPTipViewFinishedBlock)(BOOL isOk);
@interface YPTipView : UIView

@property (nonatomic, copy) YPTipViewFinishedBlock finished;

- (void)showTipWithTipStyle:(YPTipStyle)tipStyle withRecord:(NSInteger)record;

@end

//
//  YPGameViewController.h
//  2048
//
//  Created by yinpan on 16/3/20.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YPGameMode) {
    YPGameMode4= 4,
    YPGameMode6= 6,
    YPGameMode8= 8
};

@interface YPGameViewController : UIViewController

@property (nonatomic, assign) YPGameMode gameMode;

@property (nonatomic, assign) YPGameMode actionMode;

@end

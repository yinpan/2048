//
//  AppDelegate.h
//  2048
//
//  Created by yinpan on 15/12/28.
//  Copyright (c) 2015年 yinpans. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol YPGameAppDelegate <NSObject>

- (void)gameVCSavedata;

@end
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, weak) id<YPGameAppDelegate> saveDelegate;

@end


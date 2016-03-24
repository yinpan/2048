//
//  YPGameViewController.m
//  2048
//
//  Created by 千锋 on 16/3/20.
//  Copyright © 2016年 yinpans. All rights reserved.
//

#import "YPGameViewController.h"
#import "YPManager.h"
#import "YPCellView.h"
#import "UIColor+Util.h"
#import "YPCellModel.h"
#import "YPScoreLabel.h"
#import "AppDelegate.h"
#import "YPTipView.h"



#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define KEY_BEST_GRADE @"BESTGRADE"
#define KEY_LAST_State @"LASTSTATE"
#define KEY_NOW_GRADE @"NOWGRADE"
#define KEY_GAME_MODE @"GAMEMODE"
#define KEY_BESTGRADE_GAMEMODE_4 @"BESTGRADE4"
#define KEY_BESTGRADE_GAMEMODE_6 @"BESTGRADE6"
#define KEY_BESTGRADE_GAMEMODE_8 @"BESTGRADE8"



typedef NS_ENUM(NSInteger, YPGameMode) {
    YPGameMode4= 4,
    YPGameMode6= 6,
    YPGameMode8= 8
};


typedef void(^YPRunCodeBlock)();
static const CGFloat kContentViewSpace = 10;
@interface YPGameViewController ()<YPGameAppDelegate>

@property (nonatomic, strong) NSMutableArray* valueArray;
@property (nonatomic, assign) NSUInteger bestGrade;
@property (nonatomic, assign) NSUInteger nowGrade;
@property (nonatomic, strong) NSMutableArray *cellArray;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *bestScoreLabel;
@property (nonatomic, strong) YPScoreLabel *currentScoreLabel;
@property (nonatomic, strong) UILabel *bestTypeLabel;
@property (nonatomic, assign) YPGameMode gameMode;
@property (nonatomic, assign) Direction direction;
@property (nonatomic, strong) UIView *gameModeMenuView;

@property (nonatomic, strong) NSMutableArray *menuBtnArray;

@end

@implementation YPGameViewController{
    UIButton *newGameBtn;
    UIButton *setBtn;
    NSInteger addValue;
    BOOL isGameModeMenuOpen;
    BOOL isChange;
    UIImageView *newRecordImageView;
    YPTipView *tipView;
    YPTipStyle nowTip;
    BOOL isSuccess;
    BOOL isNewRecord;
}

- (NSMutableArray *)menuBtnArray
{
    if (_menuBtnArray == nil) {
        _menuBtnArray = [NSMutableArray array];
    }
    return _menuBtnArray;
}




- (NSMutableArray *)cellArray
{
    if (_cellArray == nil) {
        _cellArray = [NSMutableArray array];
    }
    return _cellArray;
}

- (NSMutableArray *)valueArray
{
    if (_valueArray == nil) {
        if ([YPManager userObjectWithKey:KEY_LAST_State]) {
            _valueArray = [YPManager userObjectWithKey:KEY_LAST_State];
        }else{
            _valueArray = [self InitializedArray];
        }
    }
    return _valueArray;
}

- (UIView *)gameModeMenuView
{
    if (_gameModeMenuView == nil) {
        _gameModeMenuView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(newGameBtn.frame), 0, CGRectGetWidth(newGameBtn.frame), CGRectGetHeight(newGameBtn.frame))];
        _gameModeMenuView.backgroundColor = [UIColor themeScoreButtonColor];
        [newGameBtn addSubview:_gameModeMenuView];
        NSArray *array = @[@"4",@"6",@"8"];
        for (int i = 0; i < 3; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * CGRectGetWidth(_gameModeMenuView.frame) / 3.0, 0, CGRectGetWidth(_gameModeMenuView.frame) / 3.0, CGRectGetHeight(_gameModeMenuView.frame))];
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor themeBorderColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor themeCellBackgroundColor]];
            [button addTarget:self action:@selector(changeGameMode:) forControlEvents:UIControlEventTouchUpInside];
            [_gameModeMenuView addSubview:button];
            [self.menuBtnArray addObject:button];
        }
    }
    return _gameModeMenuView;
}

#pragma mark -- 循环对象初始化
- (NSMutableArray *)InitializedArray
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.gameMode ; i++) {
        NSMutableArray *subArray = [NSMutableArray array];
        for (int i = 0; i < self.gameMode; i++) {
            [subArray addObject:@"1"];
        }
        [array addObject:subArray];
    }
    return array;
}

- (YPGameMode)gameMode
{
    if (!_gameMode) {
        if ([YPManager userObjectWithKey:KEY_GAME_MODE]) {
            _gameMode = [[YPManager userObjectWithKey:KEY_GAME_MODE] integerValue];
        }else{
            _gameMode = YPGameMode4;
        }
    }
    return _gameMode;
}

- (void)setBestGrade:(NSUInteger)bestGrade
{
    _bestGrade = bestGrade;
    isNewRecord = YES;
    _bestScoreLabel.text = [NSString stringWithFormat:@"%ld",_bestGrade];
    switch (self.gameMode) {
        case YPGameMode6:
            [YPManager userSetObject:_bestScoreLabel.text forKey:KEY_BESTGRADE_GAMEMODE_6];
            break;
        case YPGameMode8:
            [YPManager userSetObject:_bestScoreLabel.text forKey:KEY_BESTGRADE_GAMEMODE_8];
            break;
        default:
            [YPManager userSetObject:_bestScoreLabel.text forKey:KEY_BESTGRADE_GAMEMODE_4];
            break;
    }
}

- (void)setNowGrade:(NSUInteger)nowGrade
{
    _nowGrade = nowGrade;
    if (_bestGrade < _nowGrade) {
        self.bestGrade = _nowGrade;
        newRecordImageView.hidden = NO;
    }else{
        newRecordImageView.hidden = YES;
    }
    _currentScoreLabel.text = [NSString stringWithFormat:@"%ld",_nowGrade];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",NSHomeDirectory());
    [self addGameSaveDelegate];
    [self creatUI];
    [self InitializedData];
    [self loadGameMode:YES];
}


#pragma  mark -- 代理与保存数据回调
- (void)addGameSaveDelegate
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.saveDelegate = self;
}

- (void)creatUI
{
    CGFloat top = 40;
    if (WIDTH < 350) {
        top = 30;
    }
    self.view.backgroundColor = [UIColor themeBackgroudColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, top, WIDTH * 0.55, HEIGHT * 0.1)];
    titleLabel.text = @"  2048+";
    titleLabel.textColor = [UIColor themeTitleColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:42];
    [self.view addSubview:titleLabel];
    
    
    UIView *bestScoreView = [[UIView alloc] initWithFrame:CGRectMake(WIDTH * 0.55 , CGRectGetMinY(titleLabel.frame), WIDTH * 0.2, HEIGHT * 0.1)];
    bestScoreView.backgroundColor = [UIColor themeScoreButtonColor];
    bestScoreView.layer.cornerRadius = 3;
    bestScoreView.layer.masksToBounds = YES;
    [self.view addSubview:bestScoreView];
    
    
    UILabel *bestTitleLabel = [[ UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bestScoreView.frame), CGRectGetHeight(bestScoreView.frame) * 0.4)];
    bestTitleLabel.textColor = [UIColor themeWhiteColor];
    bestTitleLabel.textAlignment = NSTextAlignmentCenter;
    bestTitleLabel.text = @"BEST ";
    [bestScoreView addSubview:bestTitleLabel];
    
    _bestTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(-8, 5, 23, 15)];
    _bestTypeLabel.backgroundColor = [UIColor themeWhiteColor];
    _bestTypeLabel.layer.cornerRadius = 8;
    _bestTypeLabel.layer.masksToBounds = YES;
    _bestTypeLabel.textColor = [UIColor themeScoreButtonColor];
    _bestTypeLabel.font = [UIFont boldSystemFontOfSize:14];
    _bestTypeLabel.textAlignment = NSTextAlignmentCenter;
    [bestScoreView addSubview:_bestTypeLabel];
    
    
    _bestScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, CGRectGetHeight(bestScoreView.frame) * 0.4, CGRectGetWidth(bestScoreView.frame) - 8, CGRectGetHeight(bestScoreView.frame) * 0.6)];
    _bestScoreLabel.textColor = [UIColor themeWhiteColor];
    _bestScoreLabel.font = [UIFont boldSystemFontOfSize:25];
    _bestScoreLabel.adjustsFontSizeToFitWidth = YES;
    _bestScoreLabel.textAlignment = NSTextAlignmentCenter;
    [bestScoreView addSubview:_bestScoreLabel];
    
    newRecordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(bestScoreView.frame) - 20, 0, 20, 20)];
    newRecordImageView.image = [UIImage imageNamed:@"new"];
    newRecordImageView.hidden = YES;
    [bestScoreView addSubview:newRecordImageView];
    
    
    UIView *currentView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bestScoreView.frame) + WIDTH * 0.02, CGRectGetMinY(bestScoreView.frame), CGRectGetWidth(bestScoreView.frame), CGRectGetHeight(bestScoreView.frame))];
    currentView.backgroundColor = [UIColor themeScoreButtonColor];
    currentView.layer.cornerRadius = 3;
    currentView.layer.masksToBounds = YES;
    [self.view addSubview:currentView];
    
    UILabel *currentTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(currentView.frame), CGRectGetHeight(currentView.frame) * 0.4)];
    currentTitleLabel.textAlignment = NSTextAlignmentCenter;
    currentTitleLabel.textColor = [UIColor themeWhiteColor];
    currentTitleLabel.text = @"SCORE";
    [currentView addSubview:currentTitleLabel];
    
    if (WIDTH < 350) {
        bestTitleLabel.font = [UIFont boldSystemFontOfSize:11];
        currentTitleLabel.font =[UIFont boldSystemFontOfSize:11];
    }else{
        bestTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        currentTitleLabel.font =[UIFont boldSystemFontOfSize:14];
    }
    
    _currentScoreLabel = [[YPScoreLabel alloc] initWithFrame:CGRectMake(4, CGRectGetMaxY(currentTitleLabel.frame), CGRectGetWidth(currentView.frame) - 8, CGRectGetHeight(currentView.frame) * 0.6)];
    _currentScoreLabel.textAlignment = NSTextAlignmentCenter;
    _currentScoreLabel.font = [UIFont boldSystemFontOfSize:25];
    _currentScoreLabel.adjustsFontSizeToFitWidth = YES;
    _currentScoreLabel.textColor = [UIColor themeWhiteColor];
    [currentView addSubview:_currentScoreLabel];
    
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(titleLabel.frame) + 10, CGRectGetWidth(titleLabel.frame) - 15, 40)];
    tipLabel.text = @"Join the numbers and get to the 2048 title!";
    tipLabel.numberOfLines = 2;
    tipLabel.font = [UIFont systemFontOfSize:13];
    tipLabel.textColor = [UIColor themeTitleColor];
    [self.view addSubview:tipLabel];
    
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tipLabel.frame) + 15, CGRectGetMinY(tipLabel.frame), CGRectGetMaxX(currentView.frame) - CGRectGetMinX(bestScoreView.frame) - 15, 40)];
    [self.view addSubview:baseView];
    baseView.backgroundColor = [UIColor themeNewGameButtonColor];
    baseView.layer.cornerRadius = 5;
    baseView.layer.masksToBounds = YES;
    
    
    newGameBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(baseView.frame) - 40, 40)];
    [newGameBtn setTitle:@"New Game" forState:UIControlStateNormal];
    [newGameBtn addTarget:self action:@selector(newGame) forControlEvents:UIControlEventTouchUpInside];
    newGameBtn.layer.masksToBounds = YES;
    newGameBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [baseView addSubview:newGameBtn];
    
    setBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(newGameBtn.frame), 0, 40, 40)];
    setBtn.backgroundColor = [UIColor themeCellBackgroundColor];
    [setBtn setImage:[UIImage imageNamed:@"setting_24"] forState:UIControlStateNormal];
    [setBtn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [baseView addSubview:setBtn];
    
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(kContentViewSpace, CGRectGetMaxY(tipLabel.frame) + 30, WIDTH - 2 * kContentViewSpace, WIDTH - 2 * kContentViewSpace)];
    _contentView.backgroundColor = [UIColor themeBorderColor];
    _contentView.layer.cornerRadius = 5;
    _contentView.layer.masksToBounds = YES;
    [self.view addSubview:_contentView];
    [self addRecognizer:_contentView];
}

- (void)loadGameMode:(BOOL)isInit
{
    [self.cellArray removeAllObjects];
    for (YPCellView *cell in _contentView.subviews) {
        [cell removeFromSuperview];
    }
    newRecordImageView.hidden = YES;
    isNewRecord = NO;
    CGFloat borderWidth,cellWidth;
    switch (self.gameMode) {
        case YPGameMode6:
            borderWidth = 10;
            cellWidth = (WIDTH - 2 * kContentViewSpace - borderWidth * 7)/6.0;
            break;
        case YPGameMode8:
            borderWidth = 5;
            cellWidth = (WIDTH - 2 * kContentViewSpace - borderWidth * 9)/8.0;
            break;
        default:
            borderWidth = 15;
            cellWidth = (WIDTH - 2 * kContentViewSpace - borderWidth * 5)/4.0;
            break;
    }
    NSArray *initValueArray = nil;
    if (!isInit) {
        initValueArray = [self InitializedArray];
    }
    for (int i = 0; i < self.gameMode; i++) {
        NSArray *valueArray = nil;
        if (isInit) {
            valueArray = self.valueArray[i];
        }else{
            valueArray = initValueArray[i];
        }
        NSMutableArray *array = [NSMutableArray array];
        for (int j = 0; j < _gameMode; j++) {
            CGRect rect = CGRectMake( borderWidth + j * (borderWidth + cellWidth), borderWidth + i * (borderWidth + cellWidth), cellWidth , cellWidth);
            YPCellView *cell = [[YPCellView alloc] initWithFrame:rect borderWidth:borderWidth];
            if (valueArray[j]) {
                cell.value = [valueArray[j] integerValue];
                NSLog(@"%ld",cell.value);
            }
            [_contentView addSubview:cell];
            [array addObject:cell];
        }
        [self.cellArray addObject:array];
    }
    [self startGame];
}


#pragma  mark -- New Game
- (void)newGame
{
    isNewRecord = NO;
    self.nowGrade = 0;
    __weak typeof(self) weakSelf = self;
    [self tipView].finished = ^(BOOL isOK){
        if (isOK) {
            if (isOK) {
                [weakSelf loadGameMode:NO];
            }
        }
    };
    [[self tipView] showTipWithTipStyle:YPTipStyleWarn withRecord:0];
}


#pragma mark - 加载数据
- (void)InitializedData
{
    self.gameMode = [[YPManager userObjectWithKey:KEY_GAME_MODE] integerValue]?:YPGameMode4;
    switch (self.gameMode) {
        case YPGameMode6:
            self.bestGrade = [[YPManager userObjectWithKey:KEY_BESTGRADE_GAMEMODE_6] integerValue]?:0;
            break;
        case YPGameMode8:
            self.bestGrade = [[YPManager userObjectWithKey:KEY_BESTGRADE_GAMEMODE_8] integerValue]?:0;
            break;
        default:
            self.bestGrade = [[YPManager userObjectWithKey:KEY_BESTGRADE_GAMEMODE_4] integerValue]?:0;
            break;
    }
    if ([YPManager userObjectWithKey:KEY_LAST_State]) {
        self.valueArray = [YPManager userObjectWithKey:KEY_LAST_State];
        switch (self.gameMode) {
            case YPGameMode6:
                if (self.valueArray.count == 6) {
                    [self loadGameMode:YES];
                }else{
                    [self loadGameMode:NO];
                }
                break;
            case YPGameMode8:
                if (self.valueArray.count == 8) {
                    [self loadGameMode:YES];
                }else{
                    [self loadGameMode:NO];
                }
                break;
            default:
                if (self.valueArray.count == 4) {
                    [self loadGameMode:YES];
                }else{
                    [self loadGameMode:NO];
                }
                break;
        }
    }
    if ([YPManager userObjectWithKey:KEY_NOW_GRADE]) {
        self.nowGrade = [[YPManager userObjectWithKey:KEY_NOW_GRADE] intValue];
    }else{
        self.nowGrade = 0;
    }
    _bestTypeLabel.text = [NSString stringWithFormat:@"%ld",self.gameMode];
}




#pragma mark - 添加手势
- (void)addRecognizer:(UIView *)view
{
    UISwipeGestureRecognizer* recognizer1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer1 setDirection:UISwipeGestureRecognizerDirectionRight];
    [view addGestureRecognizer:recognizer1];
    UISwipeGestureRecognizer* recognizer2 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer2 setDirection:UISwipeGestureRecognizerDirectionLeft];
    [view addGestureRecognizer:recognizer2];
    UISwipeGestureRecognizer* recognizer3 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer3 setDirection:UISwipeGestureRecognizerDirectionDown];
    [view addGestureRecognizer:recognizer3];
    UISwipeGestureRecognizer* recognizer4 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer4 setDirection:UISwipeGestureRecognizerDirectionUp];
    [view addGestureRecognizer:recognizer4];
}

- (void)startGame
{
    switch (_gameMode) {
        case YPGameMode8:
            [self randomNumber];
            [self randomNumber];
            [self randomNumber];
            break;
        case YPGameMode6:
            [self randomNumber];
            [self randomNumber];
            break;
        default:
            [self randomNumber];
            [self randomNumber];
            break;
    }
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        [self calculateWithDirection:Down];
        //执行程序
    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionUp) {
        
        [self calculateWithDirection:Up];
        //执行程序
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        
        [self calculateWithDirection:Left];
        //执行程序
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self calculateWithDirection:Right];
        //执行程序
    }
}

- (void)randomNumber
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.gameMode; i++) {
        NSArray *subArray = self.cellArray[i];
        for (YPCellView *cell in subArray) {
            if (cell.value < 2) {
                [array addObject:cell];
            }
        }
    }
    if (array.count) {
        YPCellView *cell = array[arc4random()%array.count];
        [cell appear];
    }
}

- (void)calculateWithDirection:(NSInteger)direction
{
    _direction = direction;
    addValue = 0;
    switch (direction) {
        case Up:{
            //上滑
            [self UpHander];
            break;
        }
        case Down:{
            //下滑
            [self DownHander];
            break;
        }
        case Left:{
            [self LeftHander];
            //左滑
            break;
        }
        case Right:{
            //右滑
            [self RightHander];
            break;
        }
    }
    if (isChange) {
        isChange = NO;
        switch (_gameMode) {
            case YPGameMode8:
                [self randomNumber];
                [self randomNumber];
                [self randomNumber];
                break;
            case YPGameMode6:
                [self randomNumber];
                [self randomNumber];
                break;
            default:
                [self randomNumber];
                break;
        }
    }
}


/** 以左滑的方式处理 */
- (void)arrangeByTurnLeftWithArray:(NSArray *)array
{
    for (int i = 0; i < array.count; i++) {
        [self singleLineArrange:array[i]];
    }
}

- (void)singleLineArrange:(NSArray *)array
{
    NSInteger start = 0;
    for (int i = 1; i < self.gameMode; i++) {
        YPCellView *cell = array[i];
        NSInteger step = 0;
        BOOL isUnit = NO;
        for (int j = i-1; start <= j; --j) {
            YPCellView *nowCell = array[j+1];
            YPCellView *prevCell = array[j];
            step += 1;
            if (nowCell.model.value == 1) {
                step -= 1;
                break;
            }else  if (prevCell.model.value == 1) {
                prevCell.model.value = nowCell.model.value;
                nowCell.model.value = 1;
                isChange = YES;
                if (j==0) {
                    break;
                }
            }else if (prevCell.model.value == nowCell.model.value) {
                isUnit = !isUnit;
                if (isUnit) {
                    prevCell.model.isScale = YES;
                    prevCell.model.value *= 2;
                    addValue += prevCell.model.value;
                    start +=1;
                    nowCell.model.value = 1;
                    isChange = YES;
                }else{
                    continue;
                }
            }else{
                step -= 1;
                break;
            }
        }
        cell.model.step = step;
    }
    if (addValue == 0) {
        for (int i = 0; i < self.gameMode; ++i) {
            NSArray *array = self.cellArray[i];
            for (int j = 0; j < self.gameMode; ++j) {
                YPCellView *cell = array[j];
                if (cell.model.value == 1) {
                    return;
                }
            }
        }
        [self judgeIsFail];
    }
}



/** 判断是否有相同失败 */
- (void)judgeIsFail
{

    // 向下方向
    NSMutableArray* tmpArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.gameMode; i++) {
        NSMutableArray* tArray = [[NSMutableArray alloc]init];
        for (int j = 0; j< self.gameMode; j++) {
            [tArray addObject:self.cellArray[self.gameMode -1 -j][i]];
        }
        [tmpArray addObject:tArray];
    }
    if ([self isHaveEquelValueWithArray:tmpArray]==NO && [self isHaveEquelValueWithArray:self.cellArray]==NO) {
        [self showFail];
    }
    
}


- (BOOL)isHaveEquelValueWithArray:(NSArray *)array
{
    for (int i = 0; i < self.gameMode; ++i) {
        NSArray *tmpArray = array[i];
        for (int j = 1; j < self.gameMode; ++j) {
            YPCellView *cell1 = tmpArray[j-1];
            YPCellView *cell2 = tmpArray[j];
            if (cell1.model.value == cell2.model.value) {
                return YES;
            }
        }
    }
    return NO;
}


- (void)showFail
{
    __weak typeof(self) weakSelf = self;
    [self tipView].finished = ^(BOOL isOK){
        if (isOK) {
            [weakSelf tipView].hidden = YES;
            self.nowGrade = 0;
            [self loadGameMode:NO];
        }
    };
    if (isNewRecord) {
        [[self tipView] showTipWithTipStyle:YPTipStyleNewRecord withRecord:self.bestGrade];
    }else{
        [[self tipView] showTipWithTipStyle:YPTipStyleFail withRecord:self.bestGrade];
    }
}




/** 刷新视图 */
- (void)refreshView
{
    
    [YPManager traversalArray:self.cellArray handle:^(YPCellView *cell) {
        cell.direction = _direction;
        [cell comeTrue];
        if (cell.model.value >= 2048) {
            if (!isSuccess) {
                isSuccess = YES;
                __weak typeof(self) weakSelf = self;
                [self tipView].finished = ^(BOOL isOK){
                    if (isOK) {
                        [weakSelf tipView].hidden = YES;
                    }
                };
                [[self tipView] showTipWithTipStyle:YPTipStyleSuccess withRecord:0];
            }
        }
    }];
    [self showAddScoreTip];
}

- (void)LeftHander
{
    [self arrangeByTurnLeftWithArray:self.cellArray];
    [self refreshView];
}


- (void)RightHander
{
    NSMutableArray* tmpArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.gameMode; i++) {
        NSMutableArray* tArray = [[NSMutableArray alloc]init];
        for (int j = 0; j< self.gameMode; j++) {
            [tArray addObject:self.cellArray[i][self.gameMode - 1 - j]];
        }
        [tmpArray addObject:tArray];
    }
    [self arrangeByTurnLeftWithArray:tmpArray];
    [self refreshView];
}



- (void)UpHander
{
    NSMutableArray* tmpArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.gameMode; i++) {
        NSMutableArray* tArray = [[NSMutableArray alloc]init];
        for (int j = 0; j< self.gameMode; j++) {
            [tArray addObject:self.cellArray[j][self.gameMode - 1 - i]];
        }
        [tmpArray addObject:tArray];
    }
    [self arrangeByTurnLeftWithArray:tmpArray];
    [self refreshView];
}



- (void)DownHander
{
    NSMutableArray* tmpArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.gameMode; i++) {
        NSMutableArray* tArray = [[NSMutableArray alloc]init];
        for (int j = 0; j< self.gameMode; j++) {
            [tArray addObject:self.cellArray[self.gameMode -1 -j][i]];
        }
        [tmpArray addObject:tArray];
    }
    [self arrangeByTurnLeftWithArray:tmpArray];
    [self refreshView];
}



- (void)restart
{
    _nowGrade = 0;
    isSuccess = NO;
    isNewRecord = NO;
    [self startGame];
}

- (void)savePlayerData
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < self.gameMode; ++i) {
        NSMutableArray *subarray = [NSMutableArray array];
        NSArray *cellArray = self.cellArray[i];
        for (int j = 0; j < self.gameMode; ++j) {
            YPCellView *cell = cellArray[j];
            [subarray addObject:[NSString stringWithFormat:@"%ld",cell.value]];
        }
        [array addObject:subarray];
    }
    [YPManager userSetObject:[NSString stringWithFormat:@"%ld",self.gameMode] forKey:KEY_GAME_MODE];
    [YPManager userSetObject:array forKey:KEY_LAST_State];
    switch (self.gameMode) {
        case YPGameMode6:
            [YPManager userSetObject:[NSString stringWithFormat:@"%ld",self.bestGrade] forKey:KEY_BESTGRADE_GAMEMODE_6];
            break;
        case YPGameMode8:
            [YPManager userSetObject:[NSString stringWithFormat:@"%ld",self.bestGrade] forKey:KEY_BESTGRADE_GAMEMODE_8];
            break;
        default:
            [YPManager userSetObject:[NSString stringWithFormat:@"%ld",self.bestGrade] forKey:KEY_BESTGRADE_GAMEMODE_4];
            break;
    }
    [YPManager userSetObject:[NSString stringWithFormat:@"%ld",self.nowGrade] forKey:KEY_NOW_GRADE];
}

#pragma mark -- 加分提示
- (void)showAddScoreTip
{
    if (addValue) {
        self.nowGrade += addValue;
        _currentScoreLabel.score = addValue;
    }
}


- (void)showMenu:sender
{
    if (!isGameModeMenuOpen) {
        int index = 0;
        switch (self.gameMode) {
            case YPGameMode8:
                index = 2;
                break;
            case YPGameMode6:
                index = 1;
                break;
            default:
                index = 0;
                break;
        }
        [self gameModeMenuView];
        for (int i = 0; i < 3; i++) {
            UIButton *button = [self.menuBtnArray objectAtIndex:i];
            if (i == index) {
                button.backgroundColor = [UIColor themeNewGameButtonColor];
                [button setTitleColor:[UIColor themeWhiteColor] forState:UIControlStateNormal];
            }else{
                button.backgroundColor = [UIColor themeScoreButtonColor];
                [button setTitleColor:[UIColor themeTitleColor] forState:UIControlStateNormal];
            }

        }
        [sender setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.gameModeMenuView.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(newGameBtn.frame), 0);
        } completion:^(BOOL finished) {
            isGameModeMenuOpen = !isGameModeMenuOpen;
        }];
    }else{
        [sender setImage:[UIImage imageNamed:@"setting_24"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.gameModeMenuView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            isGameModeMenuOpen = !isGameModeMenuOpen;
        }];
    }
}


- (void)changeGameMode:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.gameModeMenuView.transform = CGAffineTransformIdentity;
    } completion:nil];
    [setBtn setImage:[UIImage imageNamed:@"setting_24"] forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    [self tipView].finished = ^(BOOL isOK){
        if (isOK) {
            [weakSelf sureChangeGameMode:sender];
        }else{
            isGameModeMenuOpen = !isGameModeMenuOpen;
        }
    };
    [[self tipView] showTipWithTipStyle:YPTipStyleWarn withRecord:0];
}

- (void)sureChangeGameMode:(UIButton *)sender
{
    tipView.hidden = YES;
    for (UIButton *button in self.menuBtnArray) {
        if (button == sender) {
            button.backgroundColor = [UIColor themeNewGameButtonColor];
            [button setTitleColor:[UIColor themeWhiteColor] forState:UIControlStateNormal];
        }else{
            button.backgroundColor = [UIColor themeScoreButtonColor];
            [button setTitleColor:[UIColor themeTitleColor] forState:UIControlStateNormal];
        }
    }
    switch ([self.menuBtnArray indexOfObject:sender]) {
        case 1:
            if (self.gameMode == YPGameMode6) {
                return;
            }
            self.gameMode = YPGameMode6;
            [self loadGameMode:NO];
            break;
        case 2:
            if (self.gameMode == YPGameMode8) {
                return;
            }
            self.gameMode = YPGameMode8;
            [self loadGameMode:NO];
            break;
        default:
            if (self.gameMode == YPGameMode4) {
                return;
            }
            self.gameMode = YPGameMode4;
            [self loadGameMode:NO];
            break;
    }
    _bestTypeLabel.text = [NSString stringWithFormat:@"%ld",self.gameMode];
    switch (self.gameMode) {
        case 6:
            _bestScoreLabel.text = [YPManager userObjectWithKey:KEY_BESTGRADE_GAMEMODE_6]?:@"0";
            break;
        case 8:
            _bestScoreLabel.text = [YPManager userObjectWithKey:KEY_BESTGRADE_GAMEMODE_8]?:@"0";
            break;
        default:
            _bestScoreLabel.text = [YPManager userObjectWithKey:KEY_BESTGRADE_GAMEMODE_4]?:@"0";
            break;
    }
    _bestGrade = [_bestScoreLabel.text integerValue];
    self.nowGrade = 0;
    isSuccess = NO;
    isNewRecord = NO;
    [self showMenu:setBtn];
}

- (YPTipView *)tipView
{
    if (tipView == nil) {
        tipView = [[YPTipView alloc] initWithFrame:_contentView.bounds];
        tipView.center = _contentView.center;
        [self.view addSubview:tipView];
        [self.view bringSubviewToFront:tipView];
    }
    return tipView;
}




#pragma mark -- 保存数据
-  (void)gameVCSavedata
{
    [self savePlayerData];
}



@end

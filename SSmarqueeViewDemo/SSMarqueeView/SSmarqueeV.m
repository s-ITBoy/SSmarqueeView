//
//  SSmarqueeV.m
//  baseProject
//
//  Created by F S on 2017/12/23.
//  Copyright © 2017 FL S. All rights reserved.
//

#import "SSmarqueeV.h"

///仅用于 左右方向的参数
static const CGFloat SS_itemSpace = 10.0;


@protocol SStimerManagerDelegate <NSObject>
- (void)SStimerSelector;
@end
@interface SStimerManager : NSObject
@property(nonatomic,weak) id<SStimerManagerDelegate> delegate;
@property(nonatomic,assign) CGFloat timeInterval;

- (void)SSstartTimer:(CGFloat)timeInterval;
- (void)SSpauseTimer;

@end

@interface SStimerManager ()
@property(nonatomic,strong) NSTimer* timer;
@end

@implementation SStimerManager

- (void)SSstartTimer:(CGFloat)timeInterval {
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerSelector) userInfo:nil repeats:YES];
}

- (void)timerSelector {
    if ([self.delegate respondsToSelector:@selector(SStimerSelector)]) {
        [self.delegate SStimerSelector];
    }
}

- (void)SSpauseTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)SSresetTimer {
    [self SSpauseTimer];
}

- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end

@interface SSmarqueeV ()<SStimerManagerDelegate>
@property(nonatomic,strong) UIView* contentV;
@property(nonatomic,strong) NSMutableArray<UIView*>* itemsArr;
///默认显示数量：1
@property(nonatomic,assign) NSInteger showCount;
@property(nonatomic,assign) NSInteger dataIndex;
@property(nonatomic,assign) NSInteger firstItemIndex;

@property(nonatomic,assign) SSmarqueeDirection direction;
@property(nonatomic,strong) NSTimer* scrollTimer;
@property(nonatomic,strong) SStimerManager* timerManager;
@end
@implementation SSmarqueeV
- (SStimerManager *)timerManager {
    if (!_timerManager) {
        _timerManager = [[SStimerManager alloc] init];
//        _timerManager.delegate = self;
    }
    return _timerManager;
}

- (instancetype)initWithDirection:(SSmarqueeDirection)direction {
    if (self = [super init]) {
        _direction = direction;
        _timeIntervalForTimer = 2.0;
        _durationForScroll = 1;
        
        _contentV = [[UIView alloc] initWithFrame:self.bounds];
        _contentV.clipsToBounds = YES;
        [self addSubview:_contentV];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame direction:(SSmarqueeDirection)direction {
    if (self = [super initWithFrame:frame]) {
        _direction = direction;
        _timeIntervalForTimer = 2.0;
        _durationForScroll = 1.0;
        
        _contentV = [[UIView alloc] initWithFrame:self.bounds];
        _contentV.clipsToBounds = YES;
        [self addSubview:_contentV];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_contentV setFrame:self.bounds];
}

- (void)setTimeIntervalForTimer:(CGFloat)timeIntervalForTimer {
    _timeIntervalForTimer = timeIntervalForTimer;
}

- (void)setDurationForScroll:(CGFloat)durationForScroll {
    _durationForScroll = durationForScroll;
}

- (void)setSubV {
    self.dataIndex = -1;
    self.firstItemIndex = 0;
    if (_itemsArr) {
        [_itemsArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_itemsArr removeAllObjects];
    }else {
        _itemsArr = [NSMutableArray array];
    }
    
    if (_direction == SSmarqueeDirectionToUp || _direction == SSmarqueeDirectionToDown) {
        if ([_delegate respondsToSelector:@selector(SSnumberOfShowItemForMarquee:)]) {
            self.showCount = [_delegate SSnumberOfShowItemForMarquee:self];
            if (self.showCount <= 0) {
                self.showCount = 1;
            }
        }else {
            self.showCount = 1;
        }
    }else {
        self.showCount = 1;
    }
    
    for (int i=0; i<self.showCount+2; i++) {
        UIView* itemV = [[UIView alloc] init];
        [_contentV addSubview:itemV];
        [_itemsArr addObject:itemV];
    }
    
    [self setSubVPosition];
    
    for (int i=0; i<_itemsArr.count; i++) {
        NSInteger index = (i+_firstItemIndex) % _itemsArr.count;
        if (i == 0) {
            if ([_delegate respondsToSelector:@selector(SScreateItemView:index:forMarquee:)]) {
                [_delegate SScreateItemView:_itemsArr[index] index:_dataIndex forMarquee:self];
            }
            _itemsArr[index].tag = _dataIndex;
        }else {
            [self nextDataIndex];
            if ([_delegate respondsToSelector:@selector(SScreateItemView:index:forMarquee:)]) {
                [_delegate SScreateItemView:_itemsArr[index] index:_dataIndex forMarquee:self];
            }
            _itemsArr[index].tag = _dataIndex;
            
            if ([_delegate respondsToSelector:@selector(SSupdateItemView:index:forMarquee:)]) {
                [_delegate SSupdateItemView:_itemsArr[index] index:_dataIndex forMarquee:self];
            }
        }
    }
}

- (void)setSubVPosition {
    if (_direction == SSmarqueeDirectionToUp || _direction == SSmarqueeDirectionToDown) {
        CGFloat itemWidth = CGRectGetWidth(self.frame);
        CGFloat itemHeight = CGRectGetHeight(self.frame) / self.showCount;
        for (int i=0; i<_itemsArr.count; i++) {
            NSInteger index = (i +_firstItemIndex) % _itemsArr.count;
            if (_direction == SSmarqueeDirectionToUp) {
                if (i == 0) {
                    [_itemsArr[index] setFrame:CGRectMake(0, -itemHeight, itemWidth, itemHeight)];
                }else if (i == _itemsArr.count-1) {
                    [_itemsArr[index] setFrame:CGRectMake(0, self.bounds.size.height, itemWidth, itemHeight)];
                }else {
                    [_itemsArr[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 1), itemWidth, itemHeight)];
                }
            }else {
                if (i == 0) {
                    [_itemsArr[index] setFrame:CGRectMake(0, self.bounds.size.height, itemWidth, itemHeight)];
                }else if (i == _itemsArr.count-1) {
                    [_itemsArr[index] setFrame:CGRectMake(0, -itemHeight, itemWidth, itemHeight)];
                }else {
                    [_itemsArr[index] setFrame:CGRectMake(0.0f, self.bounds.size.height - itemHeight * i, itemWidth, itemHeight)];
                }
            }
            
        }
        
    }else {
       
        CGFloat itemHeight = CGRectGetHeight(self.frame) / self.showCount;
        CGFloat lastMaxXX = 0.0;
        for (int i=0; i<_itemsArr.count; i++) {
            NSInteger index = (i +_firstItemIndex) % _itemsArr.count;
            CGFloat itemWidth = CGRectGetWidth(self.frame);
            if (_itemsArr[index].tag != -1) {
                if ([_delegate respondsToSelector:@selector(SSitemWidthAt:forMarquee:)]) {
                    itemWidth = MAX([_delegate SSitemWidthAt:_itemsArr[index].tag forMarquee:self]+SS_itemSpace, self.bounds.size.width);
                }
            }
            if (_direction == SSmarqueeDirectionToLeft) {
                if (i == 0) {
                    [_itemsArr[index] setFrame:CGRectMake(-itemWidth, 0, itemWidth, itemHeight)];
                    lastMaxXX = 0.0;
                }else {
                    [_itemsArr[index] setFrame:CGRectMake(lastMaxXX, 0, itemWidth, itemHeight)];
                    lastMaxXX += itemWidth;
                }
                
            }else {
                if (i == 0) {
                    [_itemsArr[index] setFrame:CGRectMake(self.bounds.size.width, 0, itemWidth, itemHeight)];
                    lastMaxXX = 0;
                }else {
                    [_itemsArr[index] setFrame:CGRectMake(self.bounds.size.width - itemWidth - lastMaxXX, 0, itemWidth, itemHeight)];
                    lastMaxXX += itemWidth;
                }
                
            }
        }
    }
}

- (void)SSreloadData {
    [self SSpause];
    [self setSubV];
    [self startTimer:YES];
}

- (void)SSstart {
    [self startTimer:NO];
}

- (void)SSpause {
    if (self.scrollTimer) {
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
    }
    _isStartTimer = NO;
}

- (void)resetTimer {
    [self SSpause];
    [self startTimer:YES];
}

- (void)startTimer:(BOOL)affterInterval {
    if (_scrollTimer || _itemsArr.count <= 0) {
        return;
    }
    
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:affterInterval ? self.timeIntervalForTimer : 0 target:self selector:@selector(scrollTimerSelector) userInfo:nil repeats:YES];
}

- (void)scrollTimerSelector {
    _isStartTimer = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.direction == SSmarqueeDirectionToUp || self.direction == SSmarqueeDirectionToDown) {
            [self nextDataIndex];
            CGFloat itemWidth = self.bounds.size.width;
            CGFloat itemHeight = self.bounds.size.height / self.showCount;
            self.itemsArr[self.firstItemIndex].tag = self.dataIndex;
            
            if (self.direction == SSmarqueeDirectionToUp) {
                [self.itemsArr[self.firstItemIndex] setFrame:CGRectMake(0, self.bounds.size.height, itemWidth, itemHeight)];
                if ([self.delegate respondsToSelector:@selector(SSupdateItemView:index:forMarquee:)]) {
                    [self.delegate SSupdateItemView:self.itemsArr[self.firstItemIndex] index:self.dataIndex forMarquee:self];
                }
                [UIView animateWithDuration:self.durationForScroll animations:^{
                    for (int i = 0; i < self.itemsArr.count; i++) {
                        NSInteger index = (i + self.firstItemIndex) % self.itemsArr.count;
                        if (i == 0) {
                            continue;
                        } else if (i == 1) {
                            [self.itemsArr[index] setFrame:CGRectMake(0, -itemHeight, itemWidth, itemHeight)];
                        } else {
                            [self.itemsArr[index] setFrame:CGRectMake(0, itemHeight * (i-2), itemWidth, itemHeight)];
                        }
                    }
                } completion:^(BOOL finished) {
                    
                }];
            }else {
                [self.itemsArr[self.firstItemIndex] setFrame:CGRectMake(0, -itemHeight, itemWidth, itemHeight)];
                if ([self.delegate respondsToSelector:@selector(SSupdateItemView:index:forMarquee:)]) {
                    [self.delegate SSupdateItemView:self.itemsArr[self.firstItemIndex] index:self.dataIndex forMarquee:self];
                }
                [UIView animateWithDuration:self.durationForScroll animations:^{
                    for (int i = 0; i < self.itemsArr.count; i++) {
                        NSInteger index = (i + self.firstItemIndex) % self.itemsArr.count;
                        if (i == 0) {
                            continue;
                        } else if (i == 1) {
                            [self.itemsArr[index] setFrame:CGRectMake(0, self.bounds.size.height, itemWidth, itemHeight)];
                        } else {
                            [self.itemsArr[index] setFrame:CGRectMake(0, self.bounds.size.height - itemHeight*(i-1), itemWidth, itemHeight)];
                        }
                    }
                } completion:^(BOOL finished) {
                    
                }];
            }
            [self nextItemIndex];
            
        }else {
            [self nextDataIndex];
            self.itemsArr[self.firstItemIndex].tag = self.dataIndex;
            CGFloat itemWidth = self.bounds.size.width;
            CGFloat itemHeight = self.bounds.size.height / self.showCount;
            
            if (self.direction == SSmarqueeDirectionToLeft) {
                CGFloat xx = 0.0;
                for (int i=0; i<self.itemsArr.count; i++) {
                    NSInteger index = (i+self.firstItemIndex) % self.itemsArr.count;
                    if (self.itemsArr[index].tag != -1) {
                        if ([self.delegate respondsToSelector:@selector(SSitemWidthAt:forMarquee:)]) {
                            itemWidth = MAX([self.delegate SSitemWidthAt:self.itemsArr[index].tag forMarquee:self]+SS_itemSpace, self.bounds.size.height);
                        }
                    }
                    if (i == 0) {
                        xx = -itemWidth;
                    } else if (i == 1) {
                        xx = 0;
                    } else {
                        xx += itemWidth;
                    }
                }
                [self.itemsArr[self.firstItemIndex] setFrame:CGRectMake(xx, 0, itemWidth, itemHeight)];
                if ([self.delegate respondsToSelector:@selector(SSupdateItemView:index:forMarquee:)]) {
                    [self.delegate SSupdateItemView:self.itemsArr[self.firstItemIndex] index:self.dataIndex forMarquee:self];
                }
                [UIView animateWithDuration:self.durationForScroll animations:^{
                    CGFloat lastMaxXX = 0.0;;
                    for (int i=0; i<self.itemsArr.count; i++) {
                        NSInteger index = (i+self.firstItemIndex) % self.itemsArr.count;
                        CGFloat itemWidth = self.bounds.size.width;
                        if ([self.delegate respondsToSelector:@selector(SSitemWidthAt:forMarquee:)]) {
                            itemWidth = MAX([self.delegate SSitemWidthAt:self.itemsArr[index].tag forMarquee:self]+SS_itemSpace, itemWidth);
                        }
                        
                        if (i == 0) {
                            continue;;
                        }else if (i == 1) {
                            [self.itemsArr[index] setFrame:CGRectMake(-itemWidth, 0, itemWidth, itemHeight)];
                            lastMaxXX = 0.0;
                        }else {
                            [self.itemsArr[index] setFrame:CGRectMake(lastMaxXX, 0, itemWidth, itemHeight)];
                            lastMaxXX += itemWidth;
                        }
                    }
                } completion:^(BOOL finished) {
                    
                }];
                
            }else {
                CGFloat xx = 0.0;
                for (int i=0; i<self.itemsArr.count; i++) {
                    NSInteger index = (i+self.firstItemIndex) % self.itemsArr.count;
                    
                    if (self.itemsArr[index].tag != -1) {
                        if ([self.delegate respondsToSelector:@selector(SSitemWidthAt:forMarquee:)]) {
                            itemWidth = MAX([self.delegate SSitemWidthAt:self.itemsArr[index].tag forMarquee:self]+SS_itemSpace, self.bounds.size.width);
                        }
                    }
                    if (i == 0) {
                        xx = self.bounds.size.width;
                    }else if (i == 1) {
                        xx = self.bounds.size.width - itemWidth;
                    }else {
                        xx = xx - itemWidth;
                    }
                }
                [self.itemsArr[self.firstItemIndex] setFrame:CGRectMake(xx, 0, itemWidth, itemHeight)];
                if ([self.delegate respondsToSelector:@selector(SSupdateItemView:index:forMarquee:)]) {
                    [self.delegate SSupdateItemView:self.itemsArr[self.firstItemIndex] index:self.dataIndex forMarquee:self];
                }
                [UIView animateWithDuration:self.durationForScroll animations:^{
                    CGFloat lastMaxXX = 0.0;;
                    for (int i=0; i<self.itemsArr.count; i++) {
                        NSInteger index = (i+self.firstItemIndex) % self.itemsArr.count;
                        CGFloat itemWidth = self.bounds.size.width;
                        if ([self.delegate respondsToSelector:@selector(SSitemWidthAt:forMarquee:)]) {
                            itemWidth = MAX([self.delegate SSitemWidthAt:self.itemsArr[index].tag forMarquee:self]+SS_itemSpace, itemWidth);
                        }
                        
                        if (i == 0) {
                            continue;;
                        }else if (i == 1) {
                            [self.itemsArr[index] setFrame:CGRectMake(self.bounds.size.width, 0, itemWidth, itemHeight)];
                            lastMaxXX = 0.0;
                        }else {
                            lastMaxXX += itemWidth;
                            [self.itemsArr[index] setFrame:CGRectMake(self.bounds.size.width-lastMaxXX, 0, itemWidth, itemHeight)];
                            
                        }
                    }
                } completion:^(BOOL finished) {
                    
                }];
                
            }
            
            [self nextItemIndex];
        }
    });
}


- (void)nextDataIndex {
    NSInteger dataCount = 0;
    if ([_delegate respondsToSelector:@selector(SSnumberOfDataForMarquee:)]) {
        dataCount = [_delegate SSnumberOfDataForMarquee:self];
    }
    self.dataIndex = self.dataIndex + 1;
    if (self.dataIndex < 0 || self.dataIndex > dataCount-1) {
        _dataIndex = 0;
    }
}

- (void)nextItemIndex {
    if (self.firstItemIndex >= self.itemsArr.count-1) {
        self.firstItemIndex = 0;
    }else {
        self.firstItemIndex++;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (UIView* itemView in _itemsArr) {
        if ([itemView.layer.presentationLayer hitTest:point]) {
            if ([_delegate respondsToSelector:@selector(SSdidTouchItemAt:forMarquee:)]) {
                [_delegate SSdidTouchItemAt:itemView.tag forMarquee:self];
            }
        }
    }
}

//----------- 方式二 --------------
- (void)SSreloadDataByDelegate {
    [self SSpauseByDelegate];
    [self setSubV];
    [self startTimerByDelegate:YES];
}

- (void)SSstartByDelegate {
    [self startTimerByDelegate:NO];
}

- (void)SSpauseByDelegate {
    [_timerManager SSpauseTimer];
    _isStartTimer = NO;
}

- (void)startTimerByDelegate:(BOOL)affterInterval {
    if (_itemsArr.count <= 0) {
        return;
    }
    self.timerManager.delegate = nil;
    self.timerManager.delegate = self;
    [self.timerManager SSstartTimer:affterInterval ? self.timeIntervalForTimer : 0];
}

#pragma mark ------ SStimerManagerDelegate --------
- (void)SStimerSelector {
    [self scrollTimerSelector];
}

//----------- 方式三 --------------
- (void)SSreloadData_ios_10 {
    [self SSpause];
    [self setSubV];
    [self startTimer_ios_10:YES];
}

- (void)SSstart_ios_10 {
    [self startTimer_ios_10:NO];
}

- (void)SSpause_ios_10 {
    [self SSpause];
}

- (void)startTimer_ios_10:(BOOL)affterInterval {
    if (_scrollTimer || _itemsArr.count  == 0) {
        return;
    }
    __weak typeof(self)weakSelf = self;
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:affterInterval ? self.timeIntervalForTimer : 0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf scrollTimerSelector];
    }];
}


- (void)dealloc {
    [self SSpause];
    if (_timerManager) {
        [_timerManager SSpauseTimer];
        _timerManager.delegate = nil;
        _timerManager = nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

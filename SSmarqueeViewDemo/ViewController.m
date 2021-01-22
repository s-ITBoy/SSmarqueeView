//
//  ViewController.m
//  SSmarqueeViewDemo
//
//  Created by F S on 2021/1/21.
//  Copyright © 2021 F S. All rights reserved.
//

#import "ViewController.h"
#import "SSmarqueeV.h"

@interface ViewController ()<SSmarqueeDelegate>
@property(nonatomic,strong) SSmarqueeV* marqueeLeft;
@property(nonatomic,strong) SSmarqueeV* marqueeUp;
@property(nonatomic,strong) SSmarqueeV* marqueeDown;

@property(nonatomic,strong) NSArray* dataArr;
@end

@implementation ViewController
- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[@"11111111",@"2222222",@"33333333",@"4444444",@"55555555"];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SSmarqueeV* marqueeLeft = [[SSmarqueeV alloc] initWithFrame:CGRectMake(10, 88, 180, 50) direction:SSmarqueeDirectionToLeft];
    marqueeLeft.backgroundColor = [UIColor greenColor];
    [self.view addSubview:marqueeLeft];
    marqueeLeft.delegate = self;
    self.marqueeLeft = marqueeLeft;
    [marqueeLeft SSreloadData];
    
    SSmarqueeV* marqueeUp = [[SSmarqueeV alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(marqueeLeft.frame)+10, 180, 50) direction:SSmarqueeDirectionToUp];
    marqueeUp.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:marqueeUp];
    marqueeUp.delegate = self;
    self.marqueeUp = marqueeUp;
    [marqueeUp SSreloadData];
    
    SSmarqueeV* marqueeDown = [[SSmarqueeV alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(marqueeUp.frame)+10, 180, 50) direction:SSmarqueeDirectionToDown];
    marqueeDown.backgroundColor = [UIColor greenColor];
    marqueeDown.durationForScroll = 0.5;
    marqueeDown.timeIntervalForTimer = 1;
    [self.view addSubview:marqueeDown];
    marqueeDown.delegate = self;
    self.marqueeDown = marqueeDown;
    [marqueeDown SSreloadData];
    
}

#pragma mark ----------- SSmarqueeDelegate ------------
- (NSInteger)SSnumberOfDataForMarquee:(SSmarqueeV*)marquee {
    return self.dataArr.count;
}

- (void)SScreateItemView:(UIView*)itemV index:(NSUInteger)index forMarquee:(SSmarqueeV*)marquee {
    UILabel* lab = [[UILabel alloc] init];
    lab.frame = CGRectMake(0, 0, itemV.frame.size.width, itemV.frame.size.height);

    lab.textColor = [UIColor blackColor];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.tag = 1001001;
    [itemV addSubview:lab];
}

- (void)SSupdateItemView:(UIView*)itemV index:(NSUInteger)index forMarquee:(SSmarqueeV*)marquee {
    UILabel* lab = (UILabel*)[itemV viewWithTag:1001001];
    lab.text = self.dataArr[index];
}

///此方法仅对 上下方向
- (NSInteger)SSnumberOfShowItemForMarquee:(SSmarqueeV*)marquee {
    if ([marquee isEqual:self.marqueeUp]) {
        return 2;
    }
    
    return 1;
}

- (void)dealloc {
    [self.marqueeLeft SSpause];
    [self.marqueeUp SSpause];
    [self.marqueeDown SSpause];
}


@end

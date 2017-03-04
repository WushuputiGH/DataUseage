//
//  DataUsage.h
//  HDJY_iOS
//
//  Created by huang.ziyang on 17/1/20.
//  Copyright © 2017年 HENGDA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataUsage : NSObject

@property (nonatomic, assign, readwrite) double initNumber;

@property (nonatomic, assign, readwrite) double lastNumber;

@property (nonatomic, assign, readwrite) double total;

@property (nonatomic, strong, readwrite) UILabel *dataUsageLabel;

@property (nonatomic, strong, readwrite) NSTimer *timer;

+ (instancetype)share;

- (void)show;


@end

//
//  DataUsage.m
//  HDJY_iOS
//
//  Created by huang.ziyang on 17/1/20.
//  Copyright © 2017年 HENGDA. All rights reserved.
//

#import "DataUsage.h"
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>
@import SystemConfiguration;

static DataUsage *share = nil;
static NSString *const DataCounterKeyWWANSent = @"WWANSent";
static NSString *const DataCounterKeyWWANReceived = @"WWANReceived";
static NSString *const DataCounterKeyWiFiSent = @"WiFiSent";
static NSString *const DataCounterKeyWiFiReceived = @"WiFiReceived";
@implementation DataUsage


+ (instancetype)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[DataUsage alloc] init];
        NSDictionary *dataDic = DataCounters();
        double data = 0;
        for (NSString *key in dataDic.allKeys) {
            data += [dataDic[key] doubleValue];
        }
        share.lastNumber = data;
        share.initNumber = data;
        share.total = data;
    });
    return share;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataUsageLabel = [UILabel labelWithText:@"" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:12]];
        self.dataUsageLabel.backgroundColor = [UIColor redColor];
        UIView *childrenView = [[[UIApplication sharedApplication] valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"];
        [childrenView addSubview:self.dataUsageLabel];
        [self.dataUsageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(childrenView.mas_left).offset(8);
            make.centerY.equalTo(childrenView.mas_centerY);
        }];

    }
    return self;
}

- (double)total{
    NSDictionary *dataDic = DataCounters();
    double data = 0;
    for (NSString *key in dataDic.allKeys) {
        data += [dataDic[key] doubleValue];
    }
    return data;
}

NSDictionary *DataCounters(){
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    u_int32_t WiFiSent = 0;
    u_int32_t WiFiReceived = 0;
    u_int32_t WWANSent = 0;
    u_int32_t WWANReceived = 0;
    
    if (getifaddrs(&addrs) == 0)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
#ifdef DEBUG
                const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                if(ifa_data != NULL)
                {
//                    NSLog(@"Interface name %s: sent %tu received %tu",cursor->ifa_name,ifa_data->ifi_obytes,ifa_data->ifi_ibytes);
                }
#endif
                
                // name of interfaces:
                // en0 is WiFi
                // pdp_ip0 is WWAN
                NSString *name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
                if ([name hasPrefix:@"en"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WiFiSent += ifa_data->ifi_obytes;
                        WiFiReceived += ifa_data->ifi_ibytes;
                    }
                }
                
                if ([name hasPrefix:@"pdp_ip"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WWANSent += ifa_data->ifi_obytes;
                        WWANReceived += ifa_data->ifi_ibytes;
                    }
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    return @{DataCounterKeyWiFiSent:[NSNumber numberWithUnsignedInt:WiFiSent],
             DataCounterKeyWiFiReceived:[NSNumber numberWithUnsignedInt:WiFiReceived],
             DataCounterKeyWWANSent:[NSNumber numberWithUnsignedInt:WWANSent],
             DataCounterKeyWWANReceived:[NSNumber numberWithUnsignedInt:WWANReceived]};
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateData) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    return _timer;
    
}

- (void)show{
    [self.timer fire];
}


- (void)updateData{
    
    self.dataUsageLabel.text = [NSString stringWithFormat:@"   %.2lf  %.2lfKb/s", (self.total - self.initNumber) / 1024, (self.total - self.lastNumber) / 1024];
    self.lastNumber = self.total;
}



@end

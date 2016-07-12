//
//  DateTool.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/7/1.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "DateTool.h"

@implementation DateTool

+(NSString *)dateToString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

+(NSString *)randomNumber {
    NSString *randomNumber;
    int num = (arc4random() % 1000000);
    randomNumber = [NSString stringWithFormat:@"%.6d", num];
    return randomNumber;
}

@end

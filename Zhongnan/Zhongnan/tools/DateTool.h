//
//  DateTool.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/7/1.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTool : NSObject

/**
 *  2015-08-02
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)dateToString:(NSDate *)date;
/**
 *  2015/08/02
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)dateWithString:(NSDate *)date;
/**
 *  2015-08-02 19:20:23
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)datetimeToString:(NSDate *)date;
+(NSString *)randomNumber;
@end

//
//  SCDirout.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/29.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

/**
 * 直入直出单 上传用
 */
@interface SCDirout : JKDBModel

@property (nonatomic, copy) NSDate *preparetime;
@property (nonatomic, copy) NSString *zrzcid;
@property (nonatomic, copy) NSString *orderid;
@property (nonatomic, copy) NSString *orderEntryid;
@property (nonatomic, assign) double qty;
@property (nonatomic, copy) NSString *consumerid;


@property (nonatomic, assign) int hasPrint;//1,已打印,0,未打印

@end

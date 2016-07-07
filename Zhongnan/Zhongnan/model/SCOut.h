//
//  SCOut.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/29.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

/**
 * 出库单 上传用
 */

@interface SCOut : JKDBModel
@property (nonatomic, copy) NSDate *preparetime;
@property (nonatomic, copy) NSString *deliverNo;
@property (nonatomic, copy) NSString *deliverid;
@property (nonatomic, copy) NSString *receiveid; //入库单号 scorderout.id
@property (nonatomic, copy) NSString *orderEntryid;
@property (nonatomic, assign) double qty;
@property (nonatomic, copy) NSString *consumerid;//领料商

@property (nonatomic, assign) int hasPrint;//1,已打印,0,未打印

@end

//
//  SCOrderOutMat.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

/**
 *  出库订单上的材料明细
 */
@interface SCOrderOutMat : JKDBModel

@property (nonatomic, copy) NSString *orderid;
@property (nonatomic, copy) NSString *OrderMXID;
@property (nonatomic, copy) NSString *wareentry;//材料在入库单的记录id
@property (nonatomic, copy) NSString *orderentryid;
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *unit;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *consumerName;//补打时显示领料商
@property (nonatomic, assign) double sourceQty;
@property (nonatomic, assign) double limitQty;
@property (nonatomic, assign) double qty;//这次处理的数量
@property (nonatomic, assign) double hasQty;//前几次操作已经处理的数量
@property (nonatomic, assign) double price;

@property (nonatomic, assign) int isFinish;//0,未结束    1,已结束

@end

//
//  PuOrderChild.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/17.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

@interface PuOrderChild : JKDBModel

@property(nonatomic,copy) NSString *orderentryid;
@property(nonatomic,copy) NSString *Name;
@property(nonatomic,copy) NSString *model;
@property(nonatomic,copy) NSString *unit;
@property(nonatomic,copy) NSString *brand;
@property(nonatomic,copy) NSString *note;
@property(nonatomic,copy) NSString *wareentryid;//材料明细id
@property(nonatomic,assign) double sourceQty;//单据上的数量
@property(nonatomic,assign) double limitQty;//出库上限
@property(nonatomic,assign) double ckQty;//已出数量  直出
@property(nonatomic,assign) double rkQty;//已入库数量
@property(nonatomic,assign) double curQty;//当前选择数量
@property(nonatomic,assign) double leftQty;
@property(nonatomic,copy) NSDate *time;
@property(nonatomic,assign) double price;
@property(nonatomic,copy) NSString *orderid; // 来源订单 外键表id
@property(nonatomic,assign)int isFinish;//0,未完成;1,已完成

//手机自制的入库单生成出库任务
@property (nonatomic,copy)NSString *sourceid;//入库单的来源订单id
@property (nonatomic,copy)NSString *sourcecid;//入库单的来源订单的子表id

@end

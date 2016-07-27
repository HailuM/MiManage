//
//  OutBill.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/17.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

@interface OutBill : JKDBModel
@property (nonatomic,copy) NSString *gid;//出库单主表id
@property (nonatomic,copy) NSString *orderid;//来源订单表头ID  1
@property (nonatomic,copy) NSString *preparertime;//制单时间  格式 yyyy-mm-dd hh:mm:ss  2
@property (nonatomic,copy) NSString *deliverNo;//生成的直入直出单单号 5
@property (nonatomic,copy) NSString *consumerid;//领料商id  3
@property (nonatomic,copy) NSString *consumername;//领料商名称
@property (nonatomic,assign) int printcount;//打印次数 4
@property (nonatomic,copy) NSString * receiveid;//来源入库单的主表id 来源  未知来源
@property (nonatomic,copy) NSString * receiverOID;//领用商id ????

@property (nonatomic,copy) NSString *supplier;
@property (nonatomic,copy) NSString *materialDesc;
@property (nonatomic,copy) NSString *Addr;
@property (nonatomic,copy) NSString *ProjectName;
@property (nonatomic,copy) NSString *Company;

@property (nonatomic,copy) NSString *type;//@"ck"  @"rkck"

@end

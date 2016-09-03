//
//  DirBillChild.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/17.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

@interface DirBillChild : JKDBModel

@property (nonatomic,copy) NSString *zrzcid;//上传用的生成直入直出主表id uuid生成
@property (nonatomic,copy) NSString *orderEntryid;//来源订单子表id
@property (nonatomic,copy) NSString *orderid;//来源订单表头ID  1
@property (nonatomic,copy) NSString *deliverNo;//生成的直入直出单单号 5
@property (nonatomic,copy) NSString *preparertime;//制单时间  格式 yyyy-mm-dd hh:mm:ss  2
@property (nonatomic,copy) NSString *consumerid;//领料商id  3
@property (nonatomic,assign) int printcount;//打印次数 4
@property (nonatomic,copy) NSString * receiverOID;//来源入库单的主表id
/** 直入直出单行的数量*/
@property(nonatomic,copy) NSString *qty;


@property(nonatomic,copy) NSString *Name;//材料名称
@property(nonatomic,copy) NSString *model;//规格
@property(nonatomic,copy) NSString *unit;//单位
@property(nonatomic,copy) NSString *brand;//品牌
@property(nonatomic,copy) NSString *note;//备注
@property(nonatomic,copy) NSString *price;//单价


@property(nonatomic,assign) int temp;//0,临时


@property(nonatomic,assign) int xsxh;//排序


@end

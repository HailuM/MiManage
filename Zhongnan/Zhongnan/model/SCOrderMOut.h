//
//  SCOrderMOut.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/12.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"
//出库主表
@interface SCOrderMOut : JKDBModel

@property (nonatomic, copy) NSString *id;//来源入库订单的id,不是直入直出的id
@property (nonatomic, copy) NSString *OrderId;//不明
@property (nonatomic, copy) NSString *number;//订单号
@property (nonatomic, copy) NSString *date;//订单制单时间
@property (nonatomic, copy) NSString *supplier;//供应商
@property (nonatomic, copy) NSString *materialDesc;//材料描述
@property (nonatomic, copy) NSString *Addr;//地址楼栋
@property (nonatomic, copy) NSString *ProjectName;//项目名称
@property (nonatomic, copy) NSString *Company;//公司
//以上信息是出库订单即SCOrderIn的信息

@property (nonatomic, copy) NSString *gid;//直入直出的id主键
@property (nonatomic, copy) NSDate *time;
@property (nonatomic, copy) NSString *deliverNo;
@property (nonatomic, copy) NSString *consumerid;
@property (nonatomic, copy) NSString *consumerName;

//SCDirout关联zrzcid

@property (nonatomic, assign) int printcount;
@property (nonatomic, assign) int isPrint;//0,未打印 1,已打印

@end

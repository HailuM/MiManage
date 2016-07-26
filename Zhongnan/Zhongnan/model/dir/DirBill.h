//
//  DirBill.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/17.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

@interface DirBill : JKDBModel

@property (nonatomic,copy) NSString *zrzcid;//上传用的生成直入直出主表id
@property (nonatomic,copy) NSString *orderid;//来源订单表头ID  1
@property (nonatomic,copy) NSString *number;//生成的直入直出单单号 5
@property (nonatomic,copy) NSString *supplier;
@property (nonatomic,copy) NSString *materialDesc;
@property (nonatomic,copy) NSString *Addr;
@property (nonatomic,copy) NSString *ProjectName;
@property (nonatomic,copy) NSString *Company;
@property (nonatomic,copy) NSString *preparertime;//制单时间  格式 yyyy-mm-dd hh:mm:ss  2
@property (nonatomic,copy) NSString *consumerid;//领料商id  3
@property (nonatomic,copy) NSString *consumername;//领料商名称 
@property (nonatomic,copy) NSString *date;//从服务器下载的订单的Date,用来显示订单时间
@property (nonatomic,assign) int printcount;//打印次数 4
@property (nonatomic,copy) NSString * receiverOID;//来源入库单的主表id


@property(nonatomic,assign) int temp;//0,临时的直入直出单  其他,直入直出单完成了,可以返回主界面

@end

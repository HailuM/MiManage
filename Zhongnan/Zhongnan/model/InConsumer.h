//
//  Consumer.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/29.
//  Copyright © 2016年 EMI. All rights reserved.
//
#import "JKDBModel.h"

@interface InConsumer : JKDBModel

/**  
 * 领料商
 * "Orderid": "00021872-0000-0000-0000-00007c7e9d71",
 * "consumerid": "10001",
 * "Name": "南通建筑总承包有限公司"
 */

@property (nonatomic, copy) NSString *Orderid;
@property (nonatomic, copy) NSString *consumerid;
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *receiverOID;

@end

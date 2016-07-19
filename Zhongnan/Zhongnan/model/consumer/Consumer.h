//
//  Consumer.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/17.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

@interface Consumer : JKDBModel

@property (nonatomic,assign) int id;
@property (nonatomic,copy) NSString *consumerid;
@property (nonatomic,copy) NSString *receiverOID;
@property (nonatomic,copy) NSString *Name;
@property (nonatomic,copy) NSString *Orderid; // 外键表id
@end

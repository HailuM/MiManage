//
//  InBillSer.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/17.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InBill.h"
#import "InBillChild.h"

@interface InBillSer : NSObject

@property (nonatomic, strong) InBill *bill;
@property (nonatomic, strong) NSArray<InBillChild *> *childArray;

@end

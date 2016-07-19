//
//  PuOrderSer.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/17.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuOrder.h"
#import "PuOrderChild.h"

@interface PuOrderSer : NSObject

@property (nonatomic, strong) PuOrder *order;
@property (nonatomic, strong) NSArray<PuOrderChild *> *childArray;

@end

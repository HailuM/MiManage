//
//  OrderImage.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/9/22.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "JKDBModel.h"

@interface OrderImage : JKDBModel

@property (nonatomic,copy) NSString *orderId;//单据id
@property (nonatomic,copy) NSString *imageData;//存储的图片字符串
@property (nonatomic,copy) NSString *type;//入库出库类型

@end

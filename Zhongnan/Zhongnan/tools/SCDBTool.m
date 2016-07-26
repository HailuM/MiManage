//
//  SCDBTool.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/29.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "SCDBTool.h"

@implementation SCDBTool

+(NSDictionary *)dictionaryWithJSONString:(NSString *)string {
    if (string == nil) {
        return nil;
    }
    
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+(NSArray *)arrayWithJSONString:(NSString *)string {
    if (string == nil) {
        return nil;
    }
    
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return array;
}


+(NSString *)stringWithData:(id)object {
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

+(BOOL)clearInData:(NSString *)rkToken {
    //删除入库订单表
    if([PuOrder isExistInTable]){
        //删除直入直出订单
        NSArray *zrzcArray = [PuOrder findByCriteria:@" where type = 'zrzc'"];
        for(PuOrder *order in zrzcArray){
            //删除材料子表
            if([PuOrderChild isExistInTable]){
                [PuOrderChild deleteObjectsByCriteria:[NSString stringWithFormat:@" where orderid = '%@'",order.id]];
            }else{
                [PuOrderChild createTable];
            }
            //删除入库订单的领料商
            if([Consumer isExistInTable]){
                [Consumer deleteObjectsByCriteria:[NSString stringWithFormat:@" where orderid = '%@'",order.id]];
            }else{
                [Consumer createTable];
            }
        }
        [PuOrder deleteObjects:zrzcArray];
        
        //删除入库订单表
        NSArray *rkArray = [PuOrder findByCriteria:@" where type = 'rk'"];
        for(PuOrder *order in rkArray){
            //删除材料子表
            if([PuOrderChild isExistInTable]){
                [PuOrderChild deleteObjectsByCriteria:[NSString stringWithFormat:@" where orderid = '%@'",order.id]];
            }else{
                [PuOrderChild createTable];
            }
            //删除入库订单的领料商
            if([Consumer isExistInTable]){
                [Consumer deleteObjectsByCriteria:[NSString stringWithFormat:@" where orderid = '%@'",order.id]];
            }else{
                [Consumer createTable];
            }
        }
        [PuOrder deleteObjects:rkArray];
        
        //删除自制的入库出库订单
        NSArray *rkckArray = [PuOrder findByCriteria:@" where type = 'rkck'"];
        for(PuOrder *order in rkckArray){
            //删除材料子表
            if([PuOrderChild isExistInTable]){
                [PuOrderChild deleteObjectsByCriteria:[NSString stringWithFormat:@" where orderid = '%@'",order.id]];
            }else{
                [PuOrderChild createTable];
            }
            //删除入库订单的领料商
            if([Consumer isExistInTable]){
                [Consumer deleteObjectsByCriteria:[NSString stringWithFormat:@" where orderid = '%@'",order.id]];
            }else{
                [Consumer createTable];
            }
            
        }
        [PuOrder deleteObjects:rkckArray];
    }else{
        [PuOrder createTable];
    }
    
    
    
    //删除直入直出主表
    if([DirBill isExistInTable]){
        [DirBill clearTable];
    }else{
        [DirBill createTable];
    }
    
    //删除直入直出字表
    if([DirBillChild isExistInTable]){
        [DirBillChild clearTable];
    }else{
        [DirBillChild createTable];
    }
    
    //删除入库单主表
    if([InBill isExistInTable]){
        [InBill clearTable];
    }else{
        [InBill createTable];
    }
    
    //删除入库单子表
    if([InBillChild isExistInTable]){
        [InBillChild clearTable];
    }else{
        [InBillChild createTable];
    }
    
    //TODO
    //删除自制的入库出库主表
    if([OutBill isExistInTable]){
        [OutBill clearTable];
    }else{
        [OutBill createTable];
    }
    
    
    //删除自制的入库出库子表
    if([OutBillChild isExistInTable]){
        [OutBillChild clearTable];
    }else{
        [OutBillChild createTable];
    }
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setObject:@"" forKey:@"rkToken"];
    
    return YES;
}

+(BOOL)clearOutData:(NSString *)ckToken {
    //删除入库订单表
    if([PuOrder isExistInTable]){
        //删除出库订单
        NSArray *ckArray = [PuOrder findByCriteria:@" where type = 'ck'"];
        for(PuOrder *order in ckArray){
            //删除材料子表
            if([PuOrderChild isExistInTable]){
                [PuOrderChild deleteObjectsByCriteria:[NSString stringWithFormat:@" where orderid = '%@'",order.id]];
            }else{
                [PuOrderChild createTable];
            }
            //删除入库订单的领料商
            if([Consumer isExistInTable]){
                [Consumer deleteObjectsByCriteria:[NSString stringWithFormat:@" where orderid = '%@'",order.id]];
            }else{
                [Consumer createTable];
            }
        }
        [PuOrder deleteObjects:ckArray];
        
        //删除入库出库订单表
        NSArray *rkckArray = [PuOrder findByCriteria:@" where type = 'rkck'"];
        for(PuOrder *order in rkckArray){
            //删除材料子表
            if([PuOrderChild isExistInTable]){
                [PuOrderChild deleteObjectsByCriteria:[NSString stringWithFormat:@" where orderid = '%@'",order.id]];
            }else{
                [PuOrderChild createTable];
            }
            //删除入库订单的领料商
            if([Consumer isExistInTable]){
                [Consumer deleteObjectsByCriteria:[NSString stringWithFormat:@" where orderid = '%@'",order.id]];
            }else{
                [Consumer createTable];
            }
        }
        [PuOrder deleteObjects:rkckArray];
        
    }else{
        [PuOrder createTable];
    }
    
    
    
    //删除出库主表
    if([OutBill isExistInTable]){
        [OutBill clearTable];
    }else{
        [OutBill createTable];
    }
    
    //删除出库子表
    if([OutBillChild isExistInTable]){
        [OutBillChild clearTable];
    }else{
        [OutBillChild createTable];
    }
    
    
    //出库token置空
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setObject:@"" forKey:@"ckToken"];
    
    return YES;
}




@end

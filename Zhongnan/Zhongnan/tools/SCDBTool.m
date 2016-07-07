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
    if([SCOrderIn isExistInTable]){
        [SCOrderIn clearTable];
    }else{
        [SCOrderIn createTable];
    }
    
    //删除入库订单材料明细表
    if([SCOrderInMat isExistInTable]){
        [SCOrderInMat clearTable];
    }else{
        [SCOrderInMat createTable];
    }
    
    //删除入库订单领料商
    if([InConsumer isExistInTable]){
        [InConsumer clearTable];
    }else{
        [InConsumer createTable];
    }
    
    //删除直入直出
    if([SCDirout isExistInTable]){
        [SCDirout clearTable];
    }else{
        [SCDirout createTable];
    }
    
    //删除入库单
    if([SCIn isExistInTable]){
        [SCIn clearTable];
    }else{
        [SCIn createTable];
    }
    return YES;
}

+(BOOL)clearOutData:(NSString *)ckToken {
    //删除出库订单
    if([SCOrderOut isExistInTable]){
        [SCOrderOut clearTable];
    }else{
        [SCOrderOut createTable];
    }
    
    //删除出库订单材料明细表
    if([SCOrderOutMat isExistInTable]){
        [SCOrderOutMat clearTable];
    }else{
        [SCOrderOutMat createTable];
    }
    
    //删除出库订单领料商表
    if([OutConsumer isExistInTable]){
        [OutConsumer clearTable];
    }else{
        [OutConsumer createTable];
    }
    
    //删除出库单
    if([SCOut isExistInTable]){
        [SCOut clearTable];
    }else{
        [SCOut createTable];
    }
    
    return YES;
}




@end

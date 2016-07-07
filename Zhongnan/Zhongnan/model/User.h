//
//  User.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/28.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  登录返回的用户信息
 */
@interface User : NSObject

@property (nonatomic,copy) NSString *UserOID;//用户ID
@property (nonatomic,copy) NSString *UserName;//用户名
@property (nonatomic,copy) NSString *ErrMsg;//错误信息
@property (nonatomic,copy) NSString *IsLogin;//

@end

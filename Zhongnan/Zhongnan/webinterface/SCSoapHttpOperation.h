//
//  SCSoapHttpOperation.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/8/5.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetWorking.h"

//定义返回请求数据的block类型
typedef void (^ReturnValueBlock) (id returnValue);
//typedef void (^ErrorCodeBlock) (id errorCode);
typedef void (^FailureBlock)();

@interface SCSoapHttpOperation : NSObject <NSXMLParserDelegate> {
    NSString *resultDomain;         //结果节点
    NSMutableString *soapResults;   //返回的结果
    BOOL recordResults;
}

@property (nonatomic ,copy) NSString *resData;//XML解析后的返回数据

- (void) postwithURL : (NSString *)url
       withparameter : (id)soapMessage
      withSoapAction : (NSString *)soapAction
    withResultDomain : (NSString *)result
WithReturnValeuBlock : (ReturnValueBlock)block
    WithFailureBlock : (FailureBlock)failureBlock;


//-(void)postwithURL:(NSString *)url withFile:) withResultDomain:(NSString *)result WithReturnValeuBlock:(ReturnValueBlock)block WithFailureBlock:(FailureBlock)failureBlock


@end

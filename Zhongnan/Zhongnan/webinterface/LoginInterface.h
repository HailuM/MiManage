//
//  LoginInterface.h
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/28.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface LoginInterface : NSObject<NSXMLParserDelegate> {
    NSXMLParser *xmlParser;
    
    
    NSMutableString *userName;
    NSMutableString *isLogin;
    NSMutableString *userOID;
    NSMutableString *errMsg;
}

@property (nonatomic, strong) User *user;
@property(nonatomic,retain) NSMutableString *reciveContent;//服务器返回数据
@property (nonatomic,copy) NSData *webData;

@property (nonatomic,copy) NSString *nodeName;//节点名称
@property (nonatomic,copy) NSString *curNodeName;//当前解析的节点名称

@property (nonatomic,copy) NSMutableString *result;//登录接口返回的<ToLoginResult></ToLoginResult>内容

-(instancetype)initWithContent:(NSString *)content;

-(void)praseTheXml;

@end

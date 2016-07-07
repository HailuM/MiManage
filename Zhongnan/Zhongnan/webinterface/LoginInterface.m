//
//  LoginInterface.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/28.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "LoginInterface.h"

@implementation LoginInterface
-(instancetype)initWithContent:(NSString *)content{
    self = [super init];
    if(self){
        //
        self.reciveContent = [NSMutableString stringWithString:content];
    }
    return self;
}

-(void)praseTheXml {
    self.webData = [self.reciveContent dataUsingEncoding:NSUTF8StringEncoding];
    if(self.webData){
        xmlParser = [[NSXMLParser alloc] initWithData:self.webData];
        
        [xmlParser setDelegate:self];
        [xmlParser setShouldResolveExternalEntities:YES];
        [xmlParser parse];
    }
    
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"-------------------------start--------------------------");
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    self.curNodeName=elementName;
    NSLog(@"这里是取出节点：%@",self.curNodeName);
    if (!userName) {
        userName= [[NSMutableString alloc] init];
    }
    if(!isLogin){
        isLogin= [[NSMutableString alloc] init];
    }
    if(!userOID){
        userOID= [[NSMutableString alloc] init];
    }
    if(!errMsg){
        errMsg= [[NSMutableString alloc] init];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if([self.curNodeName isEqualToString:@"UserName"] )
    {
        [userName appendString: string];
    }
    if([self.curNodeName isEqualToString:@"IsLogin"])
    {
        [isLogin appendString:string];
    }
    if([self.curNodeName isEqualToString:@"ErrMsg"])
    {
        [errMsg appendString:string];
    }
    if([self.curNodeName isEqualToString:@"UserOID"])
    {
        [userOID appendString:string];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(nonnull NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName {
    if ([elementName isEqualToString:@"UserLogin"]) {
        NSLog(@"登录返回的结果信息:%@",userOID);
        self.user = [[User alloc] init];
        self.user.UserOID =userOID;
        self.user.UserName = userName;
        self.user.ErrMsg = errMsg;
        self.user.IsLogin = isLogin;
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"-------------------------end--------------------------");
}

@end

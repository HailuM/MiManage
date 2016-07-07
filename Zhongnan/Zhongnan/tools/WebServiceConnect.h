//
//  WebServiceConnect.h
//  XinRiSystem
//
//  Created by 吴 钰南 on 14-2-28.
//  Copyright (c) 2014年 吴 钰南. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceConnect : NSObject<NSXMLParserDelegate>
{
    NSString *conneAddr;   //连接webservices的ip地址
    NSString *xmlTopInfo;
    NSString *methodName;
    NSString *type;
    
    
    NSMutableString *temStr;
    
    NSMutableData *webData;         //webservice的数据
    NSMutableString *soapResults;   //返回的结果
    NSXMLParser *xmlParser;         //xml的解析
    
    BOOL recordResults;

}
@property (nonatomic,retain) NSString *conneAddr; //连接webservices的ip地址
@property (nonatomic,retain) NSString *xmlTopInfo; //连接webservices的ip地址
@property (nonatomic,retain) NSString *methodName;
@property (nonatomic,retain) NSString *type;

@property(nonatomic, retain) NSMutableString *tempStr;

@property(nonatomic, retain) NSMutableData *webData;
@property(nonatomic, retain) NSMutableString *soapResults;
@property(nonatomic, retain) NSXMLParser *xmlParser;

- (id) initWithConnect:(NSString *)connectIP :(NSString *)topMessage :(NSString *)method :(NSString *)type;
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)getTestConnet;

@end

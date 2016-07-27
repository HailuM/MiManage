//
//  WebServiceConnect.m
//  XinRiSystem
//
//  Created by 吴 钰南 on 14-2-28.
//  Copyright (c) 2014年 吴 钰南. All rights reserved.
//

#import "WebServiceConnect.h"

@implementation WebServiceConnect

@synthesize conneAddr,xmlTopInfo,methodName,type; //连接webservices的ip地址


@synthesize webData, soapResults, xmlParser,tempStr;

- (id) initWithConnect:(NSString *)connectIP :(NSString *)topMessage :(NSString *)method :(NSString *)typeName
{
    self = [super init];
    self.conneAddr=[NSString stringWithFormat: @"%@",connectIP];
    self.xmlTopInfo=[NSString stringWithFormat: @"%@",topMessage];
    self.methodName=[NSString stringWithFormat: @"%@",method];
    self.type=[NSString stringWithFormat: @"%@",typeName];
    return self;
}

-(void) getTestConnet{
    
    recordResults = NO;
    //封装soap请求消息
    NSString *soapMessage =self.xmlTopInfo;
    // NSLog(soapMessage);
    //请求发送到的路径
    NSURL *url = [NSURL URLWithString:self.conneAddr];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    //以下对请求信息添加属性前四句是必有的，第五句是soap信息。
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [theRequest addValue: self.methodName forHTTPHeaderField:@"SOAPAction"];
    
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    //同步接受
    NSData  * responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
    NSMutableString *result = [[NSMutableString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
//    NSLog(@"dd%@",result);
    if(responseData){
        xmlParser = [[NSXMLParser alloc] initWithData: responseData];
        [xmlParser setDelegate: self];
        [xmlParser setShouldResolveExternalEntities: YES];
        [xmlParser parse];
    }
    
    
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
   attributes: (NSDictionary *)attributeDict
{
    
    if( [elementName isEqualToString:self.type])
    {
        if(!soapResults)
        {
            soapResults = [[NSMutableString alloc] init];
        }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
        recordResults = YES;
    }
    
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    if( recordResults )
    {
        [soapResults appendString: string];
    }
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if( [elementName isEqualToString:self.type])
    {
        recordResults = FALSE;
        
        
        self.tempStr=soapResults;
        
        soapResults = nil;
        NSLog(@"hoursOffset result");
    }
    
}
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"-------------------start--------------");
}
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"-------------------end--------------");
    
}

@end

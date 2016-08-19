//
//  SCSoapHttpOperation.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/8/5.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "SCSoapHttpOperation.h"

@implementation SCSoapHttpOperation

- (void) postwithURL : (NSString *)url
       withparameter : (NSString *)soapMessage
      withSoapAction : (NSString *)soapAction
    withResultDomain : (NSString *)result
WithReturnValeuBlock : (ReturnValueBlock)block
    WithFailureBlock : (FailureBlock)failureBlock
{
    resultDomain = result;
    recordResults = NO;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 300;
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return soapMessage;
    }];
    
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [manager.requestSerializer setValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [manager.requestSerializer setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [manager POST:url parameters:soapMessage success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //开始解析xml
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData: (NSData *)responseObject];
        [xmlParser setDelegate: self];
        [xmlParser setShouldResolveExternalEntities: YES];
        [xmlParser parse];
        block(self.resData);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@, %@",operation, error);
        failureBlock();
    }];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
   attributes: (NSDictionary *)attributeDict
{
    if( [elementName isEqualToString:resultDomain])
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
    if(recordResults)
    {
        [soapResults appendString: string];
    }
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if( [elementName isEqualToString:resultDomain])
    {
        recordResults = FALSE;
        self.resData = soapResults;
        soapResults = nil;
        NSLog(@"XML解析后的返回参数:%@",self.resData);
    }
}
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    NSLog(@"-------------------start--------------");
}
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"-------------------end--------------");
    
}
@end

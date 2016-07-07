//
//  DownloadOrderInfoInterface.h
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/1.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadOrderInfoInterface : NSObject<NSXMLParserDelegate>{
    NSXMLParser *xmlParser;
}
@property(nonatomic,retain) NSMutableString *reciveContent;//服务器返回数据
@property (nonatomic,copy) NSData *webData;

@property (nonatomic,copy) NSString *nodeName;//节点名称
@property (nonatomic,copy) NSString *curNodeName;//当前解析的节点名称

@property (nonatomic,copy) NSMutableString *result;//登录接口返回的<Mobile_DownloadOrderInfoResult></Mobile_DownloadOrderInfoResult>内容

-(instancetype)initWithContent:(NSString *)content;

-(void)praseTheXml;
@end

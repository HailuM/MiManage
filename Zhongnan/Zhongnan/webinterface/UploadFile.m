//
//  UploadFile.m
//  yunya
//
//  Created by WongSuechang on 16/3/29.
//  Copyright © 2016年 emi365. All rights reserved.
//

#import "UploadFile.h"
#import "UUIDUtil.h"

@interface UploadFile()

@property (nonatomic, strong) NSMutableData *receiveData;
@property (nonatomic, copy) NSString *imgpath;

@property (nonatomic,copy) NSString *url;
@property (nonatomic, strong) NSData *imageData;//图片data
@property (nonatomic,copy) NSString *orderId;//单据id
@property (nonatomic,copy) NSString *type;//单据类型

@end

@implementation UploadFile

- (instancetype) init {
    self = [super init];
    if(self){

    }
    return self;
}

#pragma mark - 私有方法
/**
 *  保存文件在沙盒中
 *
 *  @param data
 */
- (NSString *)saveImage:(NSData *)data{
    //这里将图片放在沙盒的documents文件夹中
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *gid = [UUIDUtil getUUID];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@.png",gid]] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    NSString *filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
    return filePath;
}


#pragma mark - 上传文件
- (void)uploadFileWithUrl:(NSString*)url orderId:(NSString*)orderId type:(NSString *)type data:(NSData *)data
{
    self.url = url;
    self.imageData = data;
    self.orderId = orderId;
    self.type = type;
    
    NSString *filePath = [self saveImage:data];
    NSString *inputStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    
    NSNumber *contentLength = (NSNumber *)[[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] objectForKey:NSFileSize];
    NSMutableURLRequest *request;
    NSString *desUrl = [NSString stringWithFormat:@"%@?id=%@&lx=%@",url,orderId,type];
    
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:desUrl]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBodyStream:inputStream];
    [request setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[contentLength description] forHTTPHeaderField:@"Content-Length"];
    NSURLConnection *task = [NSURLConnection connectionWithRequest:request delegate:self];
}

//接收到服务器回应的时候调用此方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
    self.receiveData = [NSMutableData data];
    
}

//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSData  *infoData = [[NSMutableData alloc] init];
    infoData =self.receiveData;
//    NSString *receiveStr = [[NSString alloc]initWithData:infoData encoding:NSUTF8StringEncoding];
//    NSError *error;
    //将请求的url数据放到NSData对象中
    NSString *result = [[NSString alloc] initWithData:infoData  encoding:NSUTF8StringEncoding];
    if([result isEqualToString:@"success"]){
        //成功
        if([self.delegate respondsToSelector:@selector(returnSuccess:)]){
            [self.delegate performSelector:@selector(returnSuccess:) withObject:@"success"];
        }
    }else{
        //失败  需要再次上传
        if([self.delegate respondsToSelector:@selector(returnUrl:orderId:type:data:)]){
            [self.delegate performSelector:@selector(returnUrl:orderId:type:data:) withObject:@[self.url,self.orderId,self.type] withObject:self.imageData];
        }
    }
}
@end

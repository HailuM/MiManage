//
//  UploadFile.m
//  yunya
//
//  Created by WongSuechang on 16/3/29.
//  Copyright © 2016年 emi365. All rights reserved.
//

#import "UploadFile.h"
#import "UUIDUtil.h"
#import "AFHTTPRequestOperationManager.h"
#import "ImageToBase64.h"

@interface UploadFile()

@property (nonatomic, strong) NSMutableData *receiveData;
@property (nonatomic, copy) NSString *imgpath;

@property (nonatomic,copy) NSString *url;
@property (nonatomic, strong) NSData *imageData;//图片data
@property (nonatomic,copy) NSString *orderId;//单据id
@property (nonatomic,copy) NSString *type;//单据类型
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) int pk;//表内主键
@property (nonatomic,assign) int index;//第几次上传

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
    BOOL success = [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@.png",gid]] contents:data attributes:nil];
    
    if(success){
        //得到选择后沙盒中图片的完整路径
        NSString *filePath1 = [[NSString alloc]initWithFormat:@"%@/%@.png",DocumentsPath,gid];
        return filePath1;
    }else{
        return nil;
    }
    
}



-(void)uploadFileWithUrl:(NSString *)url orderId:(NSString *)orderId type:(NSString *)type image:(UIImage *)image pk:(int)pk index:(int)index success:(void (^)(id responseObject))success fail:(void (^)())fail {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 300.f;
    self.url = url;
    self.orderId = orderId;
    self.type = type;
    self.image  = image;
    self.pk = pk;
    self.index = index;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:orderId forKey:@"id"];
    [dict setObject:type forKey:@"lx"];
    [manager POST:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"" fileName:@"pic.png" mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"成功:%@", result);
        if([result isEqualToString:@"success"]){
            success(@[@"success",[NSString stringWithFormat:@"%d",self.pk]]);
        }else{
            self.index++;
            
                success(@[self.orderId,self.type,self.image,[NSString stringWithFormat:@"%d",self.pk],[NSString stringWithFormat:@"%d",self.index]]);
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败:%@/n%@",operation,error);
    }];
    
}
@end

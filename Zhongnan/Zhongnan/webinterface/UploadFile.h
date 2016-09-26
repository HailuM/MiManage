//
//  UploadFile.h
//  yunya
//
//  Created by WongSuechang on 16/3/29.
//  Copyright © 2016年 emi365. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UploadFileDelegate <NSObject>
@optional
- (void)returnUrl:(NSArray *)array data:(NSData *)data;
- (void)returnSuccess:(NSString *)success;

@end

@interface UploadFile : NSObject {
    NSString *filePath;
}

@property (nonatomic, strong) id<UploadFileDelegate> delegate;

//- (void)uploadFileWithUrl:(NSString*)url orderId:(NSString*)orderId type:(NSString *)type data:(NSData *)data;



-(void)uploadFileWithUrl:(NSString *)url orderId:(NSString *)orderId type:(NSString *)type image:(UIImage *)image pk:(int)pk index:(int)index success:(void (^)(id responseObject))success fail:(void (^)())fail;
@end

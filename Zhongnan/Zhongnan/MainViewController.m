//
//  MainViewController.m
//  Zhongnan
//
//  Created by Emi-iMac on 16/6/28.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "MainViewController.h"
#import "Reachability.h"
#import "WebServiceConnect.h"
#import "UIView+Toast.h"
#import "SCDBTool.h"
#import "MJExtension.h"
#import "UIBarButtonItem+Extension.h"
#import <CoreGraphics/CoreGraphics.h>
#import "MBProgressHUD.h"

@interface MainViewController (){
    NSMutableArray *outPrintArray;//当前打印出库单
    NSMutableArray *dirPrintArray;//当前打印直入直出单
    
    MBProgressHUD *HUD;
    UIAlertView *asyncRK;//同步入库,如果本地没有上传的单据,确认用户是否删除已下载的入库订单
    UIAlertView *asyncCK;//同步出库,如果本地没有上传的单据,确认用户是否删除已下载的出库订单
    
    
    
    int hasIn;//已上传的入库明细数量
    int hasDir;//已上传的直入直出明细数量
    int hasOut;//已上传的出库明细数量
}

@end

@implementation MainViewController


-(void)back:(id)sender {
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
    self.user = [User findFirstByCriteria:@""];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary *myDictionary  = [userDefaultes  objectForKey:@"getServerInfo"];
    serverUrl=[myDictionary valueForKey:@"ServerIP"];//
    if(serverUrl==nil||serverUrl.length==0){
        serverUrl = @"fdcwzm.zhongnangroup.cn:82";
    }
    
    //读取入库的token
    
    inToken = [userDefaultes valueForKey:@"rkToken"];//
    
    //读取出库的token
    outToken = [userDefaultes valueForKey:@"ckToken"];//
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"新物资系统";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"" highImageName:@"" target:self action:@selector(back:)];
    
    //第一次查看网络是否连接
    if (![self isConnectionAvailable:@"http:\\www.baidu.com"]) {
        //错误提示框的初始化
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"当前的网络连接不可用，同步功能无法使用,请退出应用并到有网络的环境中再打开！"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
        isHaveNet=@"0";//表示没有网络
    }else{
        isHaveNet=@"1";//表示有网络
    }
    
    //获取最新服务地址
    //轻量级系统存储变量
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary *myDictionary  = [userDefaultes  objectForKey:@"getServerInfo"];
    serverUrl=[myDictionary valueForKey:@"ServerIP"];//
    
    //读取入库的token
    inToken = [userDefaultes valueForKey:@"rkToken"];//
    
    //读取出库的token
    outToken = [userDefaultes valueForKey:@"ckToken"];//
    
//    db = [FMDatabase databaseWithPath:@"/tmp/zn.db"];
    
//    测试
//    Consumer *consumer = [[Consumer alloc] init];
//    consumer.Name = @"南通浪潮";
//    consumer.Orderid = @"13affda-245de6-243431";
//    consumer.consumerid = @"13affda-245ce6-24346";
//    
//    [consumer save];
    
    
//    uartLib = [[UartLib alloc] init];
//    [uartLib setUartDelegate:self];
//    connectAlertView = [[UIAlertView alloc] initWithTitle:@"连接蓝牙打印机" message: @"连接中，请稍后!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil,nil];
}

//验证网络是否通畅
-(BOOL)isConnectionAvailable:(NSString *)url{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostname:url];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }
    return isExistenceNetwork;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView isEqual:asyncRK]){
        if(buttonIndex==1){
            [self uploadInCompleteWithRkToken:inToken withDirout:0 withInCount:0 withOutCounr:0];

            //删除数据库中的入库单及其关联表
            [SCDBTool clearInData:inToken];
            //直接下载入库订单
            [self getOrderInTitle];
        }
    }else if([alertView isEqual:asyncCK]){
        if(buttonIndex==1){
            [self uploadOutCompleteWithCkToken:outToken withOutCount:0];
            //删除数据库中的出库单及其关联表
            [SCDBTool clearOutData:outToken];
            
            //下载当前出库订单表头
            [self getOrderOutTitle];
        }
    }
}

//同步入库
- (IBAction)synStorage:(id)sender {
    if (![self isConnectionAvailable:@"http:\\www.baidu.com"]) {
        //错误提示框的初始化
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"当前的网络连接不可用，同步功能无法使用,请退出应用并到有网络的环境中再打开！"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
    }else{
        NSDate *first = [NSDate date];
        NSLog(@"开始时间:%@",[DateTool datetimeToString:first]);
        
        
        //查询当前数据库中的入库单,并上传
        NSInteger dirN = 0;//直入直出单条数
        NSInteger inN = 0;//入库单条数
        NSInteger outN = 0;//出库单条数
        
        hasIn = 0;
        hasDir = 0;
        hasOut = 0;
        
        if(inToken && inToken.length>0){
            //存在入库Token
            //查询入库单
            NSArray *inArray = [InBillChild findAll];
            //查询直入直出
            NSArray *diroutArray = [DirBillChild findAll];
            //查询出库单
            NSArray *outArray = [OutBillChild findByCriteria:@" where type = 'rkck'"];
            
            //上传直入直出
            dirN = diroutArray.count;
            //上传入库单
            inN = inArray.count;
            //如果没有ckToken,上传出库单
    //        if(outToken==nil||outToken.length==0){
                outN = outArray.count;
    //        }
            
            
            //查看来源单据
            NSArray *sourceArray = [PuOrder findAll];
            
            
            
            NSInteger sum = dirN+inN+outN;
            if(sum>0){
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
                HUD.label.text = @"上传中......";
                
                [HUD showAnimated:YES whileExecutingBlock:^{
                    float f = 0.0f;
    //                while(f<1.0f){
                        //上传直入直出单
                        for(DirBillChild *dir in diroutArray){
                            f = f + (float)(1.0f/(sum+1));
                            [HUD setProgress:f];
                            NSString *json = [SCDBTool stringWithData:dir.mj_keyValues];
                            [self uploadDiroutWithRkToken:inToken withData:json];
                            
    //                        [self performSelector:@selector(myTask) withObject:nil afterDelay:0.001];
                            
                        }
                    
                        for (InBillChild *inChild in inArray) {
                            f = f + (float)(1.0f/(sum+1));
                            [HUD setProgress:f];
                            //生成入库单jsonString
                            NSString *json = [SCDBTool stringWithData:inChild.mj_keyValues];
                            [self uploadInWithRkToken:inToken withData:json];
    //                        [self performSelector:@selector(myTask) withObject:nil afterDelay:0.001];
                            
                            
                        }
                    
                        //需要上传出库单
                        if(outN>0){
                            for(OutBillChild *outChild in outArray){
                                f = f + (float)(1.0f/(sum+1));
                                [HUD setProgress:f];
                                NSString *json = [SCDBTool stringWithData:outChild.mj_keyValues];
                                [self uploadOutWithCkToken:inToken withData:json withType:@"rkck"];
    //                            [self performSelector:@selector(myTask) withObject:nil afterDelay:0.001];
//                                [outChild deleteObject];
                                
                            }
                            
                        }
    //                }
                    //上传入库单结束
                    if(hasIn==inN && hasOut == outN && hasDir == dirN){
                    
                        [self uploadInCompleteWithRkToken:inToken withDirout:dirN withInCount:inN withOutCounr:outN];
                        NSDate *middle = [NSDate date];
                        NSLog(@"上传结束时间:%@",[DateTool datetimeToString:middle]);
                        [self performSelector:@selector(myTask) withObject:nil afterDelay:0.001];
                        f = f + (float)(1.0f/(sum+1));
                        HUD.progress = f;
                        
                        [self.view makeToast:[NSString stringWithFormat:@"本次上传直入直出单明细%ld条,入库单明细%ld条,出库单明细%ld条",(long)dirN,(long)inN,(long)outN] duration:5.0 position:CSToastPositionCenter];
                        //删除数据库中的入库单及其关联表
                        [SCDBTool clearInData:inToken];
                        NSDate *middle1 = [NSDate date];
                        NSLog(@"清除数据时间:%@",[DateTool datetimeToString:middle1]);
                        //直接下载入库订单
                        [self getOrderInTitle];
                        NSDate *middle2 = [NSDate date];
                        NSLog(@"下载结束时间:%@",[DateTool datetimeToString:middle2]);
                    }else{
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                                      message:@"上传中断!"
                                                                     delegate:self
                                                            cancelButtonTitle:@"确定"
                                                            otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    
                } completionBlock:^{
                    [HUD removeFromSuperViewOnHide];
                    HUD = nil;
                }];
                
            }else {
                asyncRK = [[UIAlertView alloc] initWithTitle:@"重新下载" message:@"您想重新下载数据吗？若是则会清除已下载数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [asyncRK show];
            }
        }else{
            
            //删除数据库中的入库单及其关联表
            [SCDBTool clearInData:inToken];
            //直接下载入库订单
            [self getOrderInTitle];
        }
        
        NSDate *end = [NSDate date];
        NSLog(@"结束时间:%@",[DateTool datetimeToString:end]);
    }
}

-(void)myTask {
    NSLog(@"耗时操作");
}

//同步出库
- (IBAction)syncOut:(id)sender {
    if (![self isConnectionAvailable:@"http:\\www.baidu.com"]) {
        //错误提示框的初始化
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"当前的网络连接不可用，同步功能无法使用,请退出应用并到有网络的环境中再打开！"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
    }else{
        
        
        
        hasOut = 0;
        
        
        
        
        
        
        
        
        //查询当前数据库中的出库单,并上传
        if(outToken && outToken.length>0){
            
            
            //查询入库单
            NSArray *inArray = [InBillChild findAll];
            //如果存在未上传的入库单,则提示先同步入库
            if(inArray.count>0){
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"存在未上传的入库单,请先同步入库!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }else{
            
                //存在出库Token
                //查询出库单
                NSArray *outArray = [OutBillChild findByCriteria:@" where type = 'ck'"];
                
                if(outArray.count>0){
                    HUD = [[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:HUD];
                    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
                    HUD.label.text = @"上传中......";
                    [HUD showAnimated:YES whileExecutingBlock:^{
                        float f = 0.f;
                        for (OutBillChild *outChild in outArray) {
                            NSString *json = [SCDBTool stringWithData:outChild.mj_keyValues];
                            [self uploadOutWithCkToken:outToken withData:json withType:@"ck"];
                            f = f + (float)(1.0/outArray.count);
                            HUD.progress = f;
                        }
                        
                        
                        if(hasOut==outArray.count){
                        //上传出库单结束
                        [self uploadOutCompleteWithCkToken:outToken withOutCount:outArray.count];
                        [self.view makeToast:[NSString stringWithFormat:@"本次上传出库单明细%ld条",outArray.count] duration:5.0 position:CSToastPositionCenter];
                        //删除数据库中的出库单及其关联表
                            [SCDBTool clearOutData:outToken];
                            //下载当前出库订单表头
                            [self getOrderOutTitle];
                        }else{
                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                                          message:@"上传中断!"
                                                                         delegate:self
                                                                cancelButtonTitle:@"确定"
                                                                otherButtonTitles:nil, nil];
                            [alert show];
                        }
                        
                        
                    } completionBlock:^{
                        [HUD removeFromSuperViewOnHide];
                        HUD = nil;
                    }];
                }else{
                    asyncCK = [[UIAlertView alloc] initWithTitle:@"重新下载" message:@"您想重新下载数据吗？若是则会清除已下载数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [asyncCK show];
                }
            }
        }else{
            //查询入库单
            NSArray *inArray = [InBillChild findAll];
            //如果存在未上传的入库单,则提示先同步入库
            if(inArray.count>0){
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"存在未上传的入库单,请先同步入库!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }else{
            
                //删除数据库中的出库单及其关联表
                [SCDBTool clearOutData:outToken];
                
                //下载当前出库订单表头
                [self getOrderOutTitle];
            }
        }
    
    }
}
/**
 *  下载订单入库表头
 */
-(void)getOrderInTitle {
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_DownloadOrderInfo",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_DownloadOrderInfo xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "</Mobile_DownloadOrderInfo>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID];
        
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_DownloadOrderInfo" :@"Mobile_DownloadOrderInfoResult"];
        [da getTestConnet];
        if([[da.tempStr substringToIndex:5] isEqualToString:@"false"]){
            //无数据
            NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:stringArray[1]
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映

        }else{
            //解析JSON字符串数据
            NSDictionary *dict = [SCDBTool dictionaryWithJSONString:da.tempStr];
            if(dict){
                NSString *rkToken = [dict objectForKey:@"tokenStr"];
                inToken = rkToken;
                NSArray *details = [dict objectForKey:@"details"];
                NSArray *orderInArray = [PuOrder mj_objectArrayWithKeyValuesArray:details];
                //保存rktoken
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                
                [userDefaultes setObject:inToken forKey:@"rkToken"];
                //保存入库订单
                
                if(![PuOrder isExistInTable]){
                    [PuOrder createTable];
                }
                for(PuOrder *order in orderInArray){
                    order.type = @"rk";
                    [order saveOrUpdate];
                }
                //遍历下载订单对应的物料信息和领料商
                if(rkToken.length>0){
                    for(PuOrder *order in orderInArray){
                        [self getOrderInMatWithOrderId:order.id withRkToken:rkToken];
                        [self getConsumerForDiroutWithOrderId:order.id withRkToken:rkToken];
                    }
                    [self.view makeToast:[NSString stringWithFormat:@"本次下载订单%lu张!",(unsigned long)orderInArray.count] duration:3.0 position:CSToastPositionCenter];
                    [self orderCompletewithRkToken:inToken];
                }
            }
        }
    }
}

/**
 *  下载订单入库表体
 *
 *  @param orderid <#orderid description#>
 *  @param rkToken <#rkToken description#>
 */
-(void)getOrderInMatWithOrderId:(NSString *)orderid withRkToken:(NSString *)rkToken{
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_DownloadOrderMaterial",serverUrl];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                                                                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                                                                        "<soap:Body>\n"
                                                                                        "<Mobile_DownloadOrderMaterial xmlns=\"http://tempuri.org/\">\n"
                                                                                        "<userOID>%@</userOID>"
                                                                                        "<orderId>%@</orderId>"
                                                                                        "<rktokenStr>%@</rktokenStr>"
                                                                                        "</Mobile_DownloadOrderMaterial>\n"
                                                                                        "</soap:Body>\n"
                                                                                        "</soap:Envelope>\n",self.user.UserOID,orderid,rkToken] :@"http://tempuri.org/Mobile_DownloadOrderMaterial" :@"Mobile_DownloadOrderMaterialResult"];
        [da getTestConnet];
        NSArray *array = [SCDBTool arrayWithJSONString:da.tempStr];
        if(array){
            NSArray *matArray = [PuOrderChild mj_objectArrayWithKeyValuesArray:array];
            //保存材料明细
            for(PuOrderChild *mat in matArray){
                [mat saveOrUpdate];
            }
        }
        //        [self.view makeToast:da.tempStr duration:3.0 position:CSToastPositionCenter];
        NSDate *middle = [NSDate date];
        NSLog(@"下载表头结束时间:%@",[DateTool datetimeToString:middle]);
    }
}

/**
 *  下载订单入库领料商
 *
 *  @param orderid <#orderid description#>
 *  @param rkToken <#rkToken description#>
 */
-(void)getConsumerForDiroutWithOrderId:(NSString *)orderid withRkToken:(NSString *)rkToken {
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_DownloadOrderconsumer",serverUrl];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                                                                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                                                                        "<soap:Body>\n"
                                                                                        "<Mobile_DownloadOrderconsumer xmlns=\"http://tempuri.org/\">\n"
                                                                                        "<userOID>%@</userOID>"
                                                                                        "<orderId>%@</orderId>"
                                                                                        "<rktokenStr>%@</rktokenStr>"
                                                                                        "</Mobile_DownloadOrderconsumer>\n"
                                                                                        "</soap:Body>\n"
                                                                                        "</soap:Envelope>\n",self.user.UserOID,orderid,rkToken] :@"http://tempuri.org/Mobile_DownloadOrderconsumer" :@"Mobile_DownloadOrderconsumerResult"];
        [da getTestConnet];
        NSArray *array = [SCDBTool arrayWithJSONString:da.tempStr];
        if(array){
            NSArray *consumerArray = [Consumer mj_objectArrayWithKeyValuesArray:array];
            //保存订单入库领料商
            for(Consumer *consumer in consumerArray){
                [consumer saveOrUpdate];
            }
        }
        //        [self.view makeToast:da.tempStr duration:3.0 position:CSToastPositionCenter];
        NSDate *middle = [NSDate date];
        NSLog(@"下载领料商时间:%@",[DateTool datetimeToString:middle]);
    }
}
/**
 *  下载订单入库完成
 */
-(void)orderCompletewithRkToken:(NSString *)rkToken {
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_DownLoadOrderComplete",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_DownLoadOrderComplete xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "<rktokenStr>%@</rktokenStr>"
                          "</Mobile_DownLoadOrderComplete>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID,rkToken];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_DownLoadOrderComplete" :@"Mobile_DownLoadOrderCompleteResult"];
        [da getTestConnet];
        //todo
        if(da.tempStr.length>6){
            if([[da.tempStr substringToIndex:5] isEqualToString:@"false"]){
                //无数据
                NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                              message:stringArray[1]
                                                             delegate:self
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil, nil];
                [alert show];//提示框的显示 必须写 不然没有任何反映
                
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                              message:@"同步入库下载成功!"
                                                             delegate:self
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil, nil];
                [alert show];//提示框的显示 必须写 不然没有任何反映
            }
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:@"网络错误!"
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
        }
    }
}
//直入直出
- (IBAction)dirOut:(id)sender {
    //跳转到直入直出
}

//入库
- (IBAction)toStorage:(id)sender {
}



/**
 *  下载出库订单表头
 */
-(void)getOrderOutTitle {
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_downloadReceiveInfo",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_downloadReceiveInfo xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "</Mobile_downloadReceiveInfo>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID];
        
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_downloadReceiveInfo" :@"Mobile_downloadReceiveInfoResult"];
        [da getTestConnet];
        NSLog(@"出入单表头数据:%@",da.tempStr);
        if(da.tempStr.length>6){
        if([[da.tempStr substringToIndex:5] isEqualToString:@"false"]){
            //无数据
            NSString *string = [da.tempStr substringFromIndex:6];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:string
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
            
        }else{
            //解析JSON字符串数据
            NSDictionary *dict = [SCDBTool dictionaryWithJSONString:da.tempStr];
            if(dict){
                NSString *ckToken = [dict objectForKey:@"tokenStr"];
                outToken = ckToken;
                NSArray *details = [dict objectForKey:@"details"];
                NSArray *orderOutArray = [PuOrder mj_objectArrayWithKeyValuesArray:details];
                //保存cktoken
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                [userDefaultes setObject:outToken forKey:@"ckToken"];
                //保存出库订单
                
                if(![PuOrder isExistInTable]){
                    [PuOrder createTable];
                }
                for(PuOrder *orderOut in orderOutArray){
                    orderOut.type = @"ck";
                    [orderOut saveOrUpdate];
                }
                //遍历下载订单对应的材料信息和领料商信息
                if(outToken){
                    for(PuOrder *orderout in orderOutArray){
                        [self getOrderOutMatWithOrderId:orderout.id withCkToken:ckToken];
                        [self getOrderOutConsumerWithOrderId:orderout.id withCkToken:ckToken];
                    }
                //结束下载出库订单
                [self.view makeToast:[NSString stringWithFormat:@"本次下载订单%lu张!",(unsigned long)orderOutArray.count] duration:3.0 position:CSToastPositionCenter];
                    [self getOrderOutCompleteWithCkToken:outToken];
                }
                
            }
        }
        }
        
        
    }
}
/**
 *  下载订单出库对应的材料明细表体
 *
 *  @param orderid <#orderid description#>
 *  @param ckToken <#ckToken description#>
 */
-(void)getOrderOutMatWithOrderId:(NSString *)orderid withCkToken:(NSString *)ckToken{
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_DownloadReceiveMaterial",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_DownloadReceiveMaterial xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "<receiveId>%@</receiveId>"
                          "<cktokenStr>%@</cktokenStr>"
                          "</Mobile_DownloadReceiveMaterial>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID,orderid,ckToken];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_DownloadReceiveMaterial" :@"Mobile_DownloadReceiveMaterialResult"];
        [da getTestConnet];
        if(da.tempStr.length>6){
        if([[da.tempStr substringToIndex:5] isEqualToString:@"false"]){
            //无数据
            NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:stringArray[1]
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
            
        }else{
            NSArray *array = [SCDBTool arrayWithJSONString:da.tempStr];
            if(array){
                NSArray *matArray = [PuOrderChild mj_objectArrayWithKeyValuesArray:array];
                //保存材料明细
                for(PuOrderChild *mat in matArray){
                    [mat saveOrUpdate];
                }
            }
        }
        }
    }
}

/**
 *  下载订单出库对应的领料商
 *
 *  @param orderId <#orderId description#>
 *  @param ckToken <#ckToken description#>
 */
- (void)getOrderOutConsumerWithOrderId:(NSString *)orderid withCkToken:(NSString *)ckToken {
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_DownloadReceiveconsumer",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_DownloadReceiveconsumer xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "<receiveId>%@</receiveId>"
                          "<cktokenStr>%@</cktokenStr>"
                          "</Mobile_DownloadReceiveconsumer>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID,orderid,ckToken];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_DownloadReceiveconsumer" :@"Mobile_DownloadReceiveconsumerResult"];
        [da getTestConnet];
        //保存出库领料商
        NSLog(@"出库领料商:%@",da.tempStr);
        if(da.tempStr.length>6){
            if([[da.tempStr substringToIndex:5] isEqualToString:@"false"]){
                //无数据
                NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                              message:stringArray[1]
                                                             delegate:self
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil, nil];
                [alert show];//提示框的显示 必须写 不然没有任何反映
            
            }else{
                NSArray *array = [SCDBTool arrayWithJSONString:da.tempStr];
                if(array){
                    NSArray *matArray = [Consumer mj_objectArrayWithKeyValuesArray:array];
                    //保存出库领料商
                    for(Consumer *consumer in matArray){
                        consumer.Orderid = [consumer.Orderid uppercaseString];
                        [consumer saveOrUpdate];
                    }
                }
            }
        }
    }
}
/**
 *  下载出库订单结束
 *
 *  @param ckToken <#ckToken description#>
 */
- (void)getOrderOutCompleteWithCkToken:(NSString *)ckToken {
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_DownLoadReceiveComplete",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_DownLoadReceiveComplete xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "<cktokenStr>%@</cktokenStr>"
                          "</Mobile_DownLoadReceiveComplete>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID,ckToken];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_DownLoadReceiveComplete" :@"Mobile_DownLoadReceiveCompleteResult"];
        [da getTestConnet];
        NSLog(@"下载出库订单结束:%@",da.tempStr);
        NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
        if([stringArray[0] isEqualToString:@"false"]){
            //无数据
            NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:stringArray[1]
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
            
        }else{
            //结束下载出库订单成功!
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:@"同步出库成功!"
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
}

/**
 *  上传直入直出数据
 */
- (void)uploadDiroutWithRkToken:(NSString *)rkToken withData:(NSString *)jsonData{
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_uploadZRZCInfo",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_uploadZRZCInfo xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "<rktokenStr>%@</rktokenStr>"
                          "<jsonData>%@</jsonData>"
                          "</Mobile_uploadZRZCInfo>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID,rkToken,jsonData];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_uploadZRZCInfo" :@"Mobile_uploadZRZCInfoResult"];
        [da getTestConnet];
        
        NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
        if([stringArray[0] isEqualToString:@"false"]){
            //无数据
            NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:stringArray[1]
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
            
        }else{
            //直入直出上传成功!
            hasDir ++;
        }
    }
//    sleep(1);
}

/**
 *  上传入库数据
 */
-(void)uploadInWithRkToken:(NSString *)rkToken withData:(NSString *)jsonData{
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_uploadrkInfo",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_uploadrkInfo xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "<rktokenStr>%@</rktokenStr>"
                          "<jsonData>%@</jsonData>"
                          "</Mobile_uploadrkInfo>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID,rkToken,jsonData];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_uploadrkInfo" :@"Mobile_uploadrkInfoResult"];
        [da getTestConnet];
        NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
        if([stringArray[0] isEqualToString:@"false"]){
            //无数据
//            NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:stringArray[1]
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
            
        }else{
            //入库上传成功!
            hasIn ++;
        }
        
    }
//    sleep(1);
}
/**
 *  上传入库相关结束
 */
-(void)uploadInCompleteWithRkToken:(NSString *)rkToken withDirout:(NSInteger)diroutCount withInCount:(NSInteger)inCount withOutCounr:(NSInteger)outCount {
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_uploadrkComplete",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_uploadrkComplete xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "<rktokenStr>%@</rktokenStr>"
                          "<zrzcBillCount>%ld</zrzcBillCount>"
                          "<rkBillCount>%ld</rkBillCount>"
                          "<ckBillCount>%ld</ckBillCount>"
                          "</Mobile_uploadrkComplete>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID,rkToken,(long)diroutCount,(long)inCount,(long)outCount];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_uploadrkComplete" :@"Mobile_uploadrkCompleteResult"];
        [da getTestConnet];
        NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
        if([stringArray[0] isEqualToString:@"false"]){
            //无数据
            
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:stringArray[1]
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
            
        }else{
            //入库上传成功!
            [self.view makeToast:@"同步上传入库成功!" duration:3.0 position:CSToastPositionCenter];
        }
    }
//    sleep(1);
}

/**
 *  上传出库单
 *
 *  @param ckToken  <#ckToken description#>
 *  @param jsonData <#jsonData description#>
 */
-(void)uploadOutWithCkToken:(NSString *)ckToken withData:(NSString *)jsonData withType:(NSString *)type{
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_uploadckInfo",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_uploadckInfo xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "<cktokenStr>%@</cktokenStr>"
                          "<jsonData>%@</jsonData>"
                          "<type>%@</type>"
                          "</Mobile_uploadckInfo>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID,ckToken,jsonData,type];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_uploadckInfo" :@"Mobile_uploadckInfoResult"];
        [da getTestConnet];
        NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
        if([stringArray[0] isEqualToString:@"false"]){
            //无数据
            
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:stringArray[1]
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
            
        }else{
            //出库上传成功!
            
            
            hasOut ++;
//            [self.view makeToast:@"上传成功!" duration:3.0 position:CSToastPositionCenter];
        }
        //        [self.view makeToast:da.tempStr duration:3.0 position:CSToastPositionCenter];
    }
    
//    sleep(1);
}

/**
 *  上传出库单完成
 *
 *  @param ckToken
 *  @param outCount 
 */
-(void)uploadOutCompleteWithCkToken:(NSString *)ckToken withOutCount:(NSInteger)outCount {
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示!" message:@"请先维护好服务器设置!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSString *connectUrl=[NSString stringWithFormat:@"http://%@/ZNWZCRK/othersource/ZhongNanWuZiMobileServices.asmx?op=Mobile_uploadckComplete",serverUrl];
        
        NSString *data = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                          "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                          "<soap:Body>\n"
                          "<Mobile_uploadckComplete xmlns=\"http://tempuri.org/\">\n"
                          "<userOID>%@</userOID>"
                          "<cktokenStr>%@</cktokenStr>"
                          "<ckBillCount>%ld</ckBillCount>"
                          "</Mobile_uploadckComplete>\n"
                          "</soap:Body>\n"
                          "</soap:Envelope>\n",self.user.UserOID,ckToken,(long)outCount];
        WebServiceConnect *da = [[WebServiceConnect alloc] initWithConnect:connectUrl :data :@"http://tempuri.org/Mobile_uploadckComplete" :@"Mobile_uploadckCompleteResult"];
        [da getTestConnet];
        NSArray<NSString *> *stringArray = [da.tempStr componentsSeparatedByString:@":"];
        if([stringArray[0] isEqualToString:@"false"]){
            //无数据
            
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:stringArray[1]
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
            
        }else{
            //出库上传成功!
            [self.view makeToast:@"同步上传出库成功!" duration:3.0 position:CSToastPositionCenter];
        }
        //        [self.view makeToast:da.tempStr duration:3.0 position:CSToastPositionCenter];
    }
}

//出库
- (IBAction)toOut:(id)sender {
}

//补打
- (IBAction)rePrint:(id)sender {
    //跳转到补打页面
    //查询出所有未打印的出库单和直入直出单
    
//    //查询出库单
//    NSArray *orderOutArray = [SCOrderMOut findByCriteria:@" WHERE isPrint = 0 "];//未打印的出库单
////    NSArray *outArray = [SCOut findByCriteria:@" WHERE printcount = 0 "];//
//    for(SCOrderMOut *orderout in orderOutArray){
//        //待打印的材料数组
//        NSArray *outArray = [SCOut findByCriteria:[NSString stringWithFormat:@" WHERE  deliverid = '%@' ",orderout.gid]];
//        //准备打印出库单数据
//        if(outArray.count>0){
//            printContant=[NSString stringWithFormat:@"%@\n第%d次打印%@%@%@%@%@%@%@%@%@",
//                          @"------------------------------",
//                          (orderout.printcount+1),
//                          @"\n出库单号:",orderout.deliverNo,
//                          @"\n项目:",orderout.ProjectName,
//                          @"\n领用商:",orderout.consumerName,
//                          @"\n地产公司:",orderout.Company,
//                          @"\n------------------------------"];
//            for (int i = 0; i<outArray.count; i++) {
//                SCOut *outM = outArray[i];
//                outM.isPrint = 1;
//                outM.printcount ++;
//                [outM saveOrUpdate];
//                SCOrderOutMat *outMat = [SCOrderOutMat findFirstByCriteria:[NSString stringWithFormat:@" WHERE wareentry = '%@'",outM.wareentry]];
//                NSString *matString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%f%@%f%@%f%@%@\n ",
//                                       @"\n材料名称:",outMat.Name,
//                                       @"\n品牌:",outMat.brand,
//                                       @"\n规格型号:",outMat.model,
//                                       @"\n数量:",outM.qty,
//                                       @"\n单价:",outMat.price,
//                                       @"\n金额:",outM.qty*outMat.price,
//                                       @"\n备注:",outMat.note];
//                printContant = [printContant stringByAppendingString:matString];
//            }
//            printContant = [NSString stringWithFormat:@"%@%@%@%@",printContant,
//                            @"\n收货人:__________________",
//                            @"\n                        ",
//                            @"\n证明人:__________________"];
//            //开始打印
//            //--------------
//            [uartLib scanStart];//scan
//            NSLog(@"connect Peripheral");
//            
//            [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
//        }
//        orderout.isPrint = 1;
//        orderout.printcount ++;
//        [orderout saveOrUpdate];
//    }
//    
//    
//    
//    //查询直入直出单
//    NSArray *orderInArray = [SCOrderMDirout findByCriteria:@" WHERE isPrint = 0 "];//未打印的直入直出单
////    NSArray *inArray = [SCDirout findByCriteria:@" WHERE printcount = 0 "];//直入直出单
//    for(SCOrderMDirout *orderDirout in orderInArray){
//        //待打印的材料数组
//        NSArray *diroutArray = [SCDirout findByCriteria:[NSString stringWithFormat:@" WHERE  zrzcid = '%@' ",orderDirout.gid]];
//        //准备打印出库单数据
//        if(diroutArray.count>0){
//            printContant=[NSString stringWithFormat:@"%@\n第%d次打印%@%@%@%@%@%@%@%@%@",
//                          @"------------------------------",
//                          (orderDirout.printcount+1),
//                          @"\n出库单号:",orderDirout.deliverNo,
//                          @"\n项目:",orderDirout.ProjectName,
//                          @"\n领用商:",orderDirout.consumerName,
//                          @"\n地产公司:",orderDirout.Company,
//                          @"\n------------------------------"];
//            for (int i = 0; i<diroutArray.count; i++) {
//                SCDirout *dirout = diroutArray[i];
//                dirout.isPrint = 1;
//                dirout.printcount ++;
//                [dirout saveOrUpdate];
//                SCOrderInMat *inMat = [SCOrderInMat findFirstByCriteria:[NSString stringWithFormat:@" WHERE wareentry = '%@'",dirout.wareentry]];
//                NSString *matString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%f%@%f%@%f%@%@\n ",
//                                       @"\n材料名称:",inMat.Name,
//                                       @"\n品牌:",inMat.brand,
//                                       @"\n规格型号:",inMat.model,
//                                       @"\n数量:",dirout.qty,
//                                       @"\n单价:",inMat.price,
//                                       @"\n金额:",dirout.qty*inMat.price,
//                                       @"\n备注:",inMat.note];
//                printContant = [printContant stringByAppendingString:matString];
//            }
//            printContant = [NSString stringWithFormat:@"%@%@%@%@",printContant,
//                            @"\n收货人:____________________",
//                            @"\n                          ",
//                            @"\n证明人:____________________"];
//            //开始打印
//            //--------------
//            [uartLib scanStart];//scan
//            NSLog(@"connect Peripheral");
//            
//            [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
//        }
//        orderDirout.isPrint = 1;
//        orderDirout.printcount ++;
//        [orderDirout saveOrUpdate];
//        
//    }
    
}
//-------
//-(void)searchPrinter{
//    if(connectPeripheral ==nil){
//        [uartLib scanStart];//scan
//        [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
//    }else{
//        [uartLib scanStop];
//        [uartLib connectPeripheral:connectPeripheral];
//        [connectAlertView show];
//        [self performSelector:@selector(pirntData) withObject:nil afterDelay:3];
//    }
//    
//}
////-----
//-(void)pirntData{
//    NSString *curPrintContent;
//    
//    curPrintContent = printContant;
//    
//    if ([curPrintContent length]) {
//        NSString *printed = [curPrintContent stringByAppendingFormat:@"%c%c%c", '\n', '\n', '\n'];
//        
//        [self PrintWithFormat:printed];
//        //打印完成 记得该状态  todo
//        if(outPrintArray.count>0){
//            for(SCOut *scout in outPrintArray){
//                scout.isPrint = 1;
//                [scout saveOrUpdate];
//            }
//            outPrintArray = nil;
//        }
//        
//        if(dirPrintArray.count>0){
//            for (SCDirout *dirout in dirPrintArray) {
//                dirout.isPrint = 1;
//                [dirout saveOrUpdate];
//            }
//            dirPrintArray = nil;
//        }
//    }
//    [uartLib scanStop];
//    [uartLib disconnectPeripheral:connectPeripheral];
//    
//}
//
//参数设置
- (IBAction)toSetting:(id)sender {
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


//#pragma mark -
//#pragma mark UartDelegate
///****************************************************************************/
///*                       UartDelegate Methods                        */
///****************************************************************************/
//- (void) didScanedPeripherals:(NSMutableArray  *)foundPeripherals;
//{
//    NSLog(@"didScanedPeripherals(%lu)", (unsigned long)[foundPeripherals count]);
//    
//    CBPeripheral	*peripheral;
//    
//    for (peripheral in foundPeripherals) {
//        NSLog(@"--Peripheral:%@", [peripheral name]);
//    }
//    
//    if ([foundPeripherals count] > 0) {
//        connectPeripheral = [foundPeripherals objectAtIndex:0];
//        if ([connectPeripheral name] == nil) {
//            // [[self peripheralName] setText:@"BTCOM"];
//        }else{
//            // [[self peripheralName] setText:[connectPeripheral name]];
//        }
//    }else{
//        //[[self peripheralName] setText:nil];
//        connectPeripheral = nil;
//    }
//}
//
//- (void) didConnectPeripheral:(CBPeripheral *)peripheral{
//    NSLog(@"did Connect Peripheral");
//    
//    //[[self sendButton] setEnabled:TRUE];
//    
//    [connectAlertView dismissWithClickedButtonIndex:0 animated:YES];
//    
//    //[self printerNotifyEnable];
//}
//
//- (void) didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
//    NSLog(@"did Disconnect Peripheral");
//    
//    // [[self sendButton] setEnabled:FALSE];
//    //[[self peripheralName] setText:@""];
//    [connectAlertView dismissWithClickedButtonIndex:0 animated:YES];
//    
//    //  [[[UIAlertView alloc] initWithTitle:@"Connect fail" message: @"Fail to connect,Please reconnect!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil] show];
//    //--------------wynadd
//    [uartLib scanStart];//scan
//    NSLog(@"connect Peripheral");
//    [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
//    
//}
//
//- (void) didWriteData:(CBPeripheral *)peripheral error:(NSError *)error{
//    NSLog(@"didWriteData:%@", [peripheral name]);
//}
//
//
//- (void) didReceiveData:(CBPeripheral *)peripheral recvData:(NSData *)recvData
//{
//    NSLog(@"uart recv(%lu):%@", (unsigned long)[recvData length], recvData);
//    
//    if ([recvData length] == 4) {
//        Byte *recvByte = (Byte *)[recvData bytes];
//        
//        if (recvByte[2] == 0x0c) {
//            NSLog(@"缺纸");
//        }else{
//            NSLog(@"正常");
//        }
//    }
//    //[self promptDisplay:recvData];
//}
//
//- (void) didBluetoothPoweredOff{
//    
//}
//- (void) didBluetoothPoweredOn{
//    
//}
//
//- (void) didRetrievePeripheral:(NSArray *)peripherals{
//    
//}
//
//- (void) didRecvRSSI:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI{
//    
//}
//- (void) didDiscoverPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI{
//    
//}
//
//- (void) didDiscoverPeripheralAndName:(CBPeripheral *)peripheral DevName:(NSString *)devName{
//    
//}
//
//- (void) didrecvCustom:(CBPeripheral *)peripheral CustomerRight:(bool) bRight{
//    
//}
//
//- (void) PrintWithFormat:(NSString *)printContent{
//#define MAX_CHARACTERISTIC_VALUE_SIZE 20
//    NSData  *data	= nil;
//    NSUInteger i;
//    NSUInteger strLength;
//    NSUInteger cellCount;
//    NSUInteger cellMin;
//    NSUInteger cellLen;
//    
//    Byte caPrintFmt[5];
//    
//    /*初始化命令：ESC @ 即0x1b,0x40*/
//    caPrintFmt[0] = 0x1b;
//    caPrintFmt[1] = 0x40;
//    
//    /*字符设置命令：ESC ! n即0x1b,0x21,n*/
//    caPrintFmt[2] = 0x1b;
//    caPrintFmt[3] = 0x21;
//    
//    caPrintFmt[4] = 0x00;
//    
//    NSData *cmdData =[[NSData alloc] initWithBytes:caPrintFmt length:5];
//    
//    [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];
//    NSLog(@"format:%@", cmdData);
//    
//    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    //NSData *data = [curPrintContent dataUsingEncoding:enc];
//    //NSLog(@"dd:%@", data);
//    //NSString *retStr = [[NSString alloc] initWithData:data encoding:enc];
//    //NSLog(@"str:%@", retStr);
//    
//    strLength = [printContent length];
//    if (strLength < 1) {
//        return;
//    }
//    
//    cellCount = (strLength%MAX_CHARACTERISTIC_VALUE_SIZE)?(strLength/MAX_CHARACTERISTIC_VALUE_SIZE + 1):(strLength/MAX_CHARACTERISTIC_VALUE_SIZE);
//    for (i=0; i<cellCount; i++) {
//        cellMin = i*MAX_CHARACTERISTIC_VALUE_SIZE;
//        if (cellMin + MAX_CHARACTERISTIC_VALUE_SIZE > strLength) {
//            cellLen = strLength-cellMin;
//        }
//        else {
//            cellLen = MAX_CHARACTERISTIC_VALUE_SIZE;
//        }
//        
//        //NSLog(@"print:%d,%d,%d,%d", strLength,cellCount, cellMin, cellLen);
//        NSRange rang = NSMakeRange(cellMin, cellLen);
//        NSString *strRang = [printContent substringWithRange:rang];
//        NSLog(@"print:%@", strRang);
//        
//        data = [strRang dataUsingEncoding: enc];
//        //data = [strRang dataUsingEncoding: NSUTF8StringEncoding];
//        NSLog(@"print:%@", data);
//        //data = [strRang dataUsingEncoding: NSUTF8StringEncoding];
//        //NSLog(@"print:%@", data);
//        
//        [uartLib sendValue:connectPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
//    }
//}


@end

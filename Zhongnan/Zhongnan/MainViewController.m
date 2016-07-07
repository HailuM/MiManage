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

@interface MainViewController (){
    NSMutableArray *outPrintArray;//当前打印出库单
    NSMutableArray *dirPrintArray;//当前打印直入直出单
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"新物资系统";
    self.navigationItem.leftBarButtonItem = nil;
    
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
    NSDictionary *tokenDic  = [userDefaultes  objectForKey:@"getToken"];
    inToken = [tokenDic valueForKey:@"rkToken"];//
    
    //读取出库的token
    outToken = [tokenDic valueForKey:@"ckToken"];//
    
//    db = [FMDatabase databaseWithPath:@"/tmp/zn.db"];
    
//    测试
//    Consumer *consumer = [[Consumer alloc] init];
//    consumer.Name = @"南通浪潮";
//    consumer.Orderid = @"13affda-245de6-243431";
//    consumer.consumerid = @"13affda-245ce6-24346";
//    
//    [consumer save];
    
    
    uartLib = [[UartLib alloc] init];
    [uartLib setUartDelegate:self];
    connectAlertView = [[UIAlertView alloc] initWithTitle:@"连接蓝牙打印机" message: @"连接中，请稍后!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil,nil];
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


//同步入库
- (IBAction)synStorage:(id)sender {
    //查询当前数据库中的入库单,并上传
    
    if(inToken && inToken.length>0){
        //存在入库Token
        //查询入库单
        NSArray *inArray = [SCIn findAll];
        //查询直入直出
        NSArray *diroutArray = [SCDirout findAll];
            for (SCIn *inOrder in inArray) {
                //生成入库单jsonString
                NSString *json = [SCDBTool stringWithData:inOrder.mj_keyValues];
                [self uploadInWithRkToken:inToken withData:json];
            }
        
        for (SCDirout *dirout in diroutArray) {
            //生成直入直出单jsonString
            NSString *json = [SCDBTool stringWithData:dirout.mj_keyValues];
            [self uploadDiroutWithRkToken:inToken withData:json];
        }
        //上传入库单结束
        [self uploadInCompleteWithRkToken:inToken withDirout:diroutArray.count withInCount:inArray.count withOutCounr:@0];
        //删除数据库中的入库单及其关联表
        [SCDBTool clearInData:inToken];
        //直接下载入库订单
        [self getOrderInTitle];
    }else{
        //删除数据库中的入库单及其关联表
        [SCDBTool clearInData:inToken];
        //直接下载入库订单
        [self getOrderInTitle];
    }
}

//同步出库
- (IBAction)syncOut:(id)sender {
    //查询当前数据库中的出库单,并上传
    if(outToken && outToken.length>0){
        //存在出库Token
        //查询出库单
        NSArray *outArray = [SCOut findAll];
        for (SCOut *outOrder in outArray) {
            NSString *json = [SCDBTool stringWithData:outOrder.mj_keyValues];
            [self uploadOutWithCkToken:outToken withData:json withType:1];
        }
        
        //上传出库单结束
        [self uploadOutCompleteWithCkToken:outToken withOutCount:outArray.count];
        //删除数据库中的出库单及其关联表
        [SCDBTool clearOutData:outToken];
        
        //下载当前出库订单表头
        [self getOrderOutTitle];
    }else{
        //删除数据库中的出库单及其关联表
        [SCDBTool clearOutData:outToken];
        
        //下载当前出库订单表头
        [self getOrderOutTitle];
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
                NSArray *orderInArray = [SCOrderIn mj_objectArrayWithKeyValuesArray:details];
                //保存rktoken
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                NSDictionary *rkDic = [NSDictionary dictionaryWithObjectsAndKeys:rkToken,@"rkToken", nil];
                [userDefaultes setObject:rkDic forKey:@"GetToken"];
                //保存入库订单
                
                if(![SCOrderIn isExistInTable]){
                    [SCOrderIn createTable];
                }
                for(SCOrderIn *orderIn in orderInArray){
                    [orderIn saveOrUpdate];
                }
                //遍历下载订单对应的物料信息
                
                for(SCOrderIn *orderIn in orderInArray){
                    [self getOrderInMatWithOrderId:orderIn.id withRkToken:rkToken];
                    [self getConsumerForDiroutWithOrderId:orderIn.id withRkToken:rkToken];
                }
            }
        }
        [self orderCompletewithRkToken:inToken];
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
            NSArray *matArray = [SCOrderInMat mj_objectArrayWithKeyValuesArray:array];
            //保存材料明细
            for(SCOrderInMat *mat in matArray){
                [mat saveOrUpdate];
            }
        }
        //        [self.view makeToast:da.tempStr duration:3.0 position:CSToastPositionCenter];
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
            NSArray *consumerArray = [InConsumer mj_objectArrayWithKeyValuesArray:array];
            //保存订单入库领料商
            for(InConsumer *consumer in consumerArray){
                [consumer saveOrUpdate];
            }
        }
        //        [self.view makeToast:da.tempStr duration:3.0 position:CSToastPositionCenter];
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
        
        //        [self.view makeToast:da.tempStr duration:3.0 position:CSToastPositionCenter];
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
                NSString *ckToken = [dict objectForKey:@"tokenStr"];
                outToken = ckToken;
                NSArray *details = [dict objectForKey:@"details"];
                NSArray *orderOutArray = [SCOrderOut mj_objectArrayWithKeyValuesArray:details];
                //保存cktoken
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                NSDictionary *rkDic = [NSDictionary dictionaryWithObjectsAndKeys:ckToken,@"ckToken", nil];
                [userDefaultes setObject:rkDic forKey:@"GetToken"];
                //保存出库订单
                
                if(![SCOrderOut isExistInTable]){
                    [SCOrderOut createTable];
                }
                for(SCOrderOut *orderOut in orderOutArray){
                    [orderOut saveOrUpdate];
                }
                //遍历下载订单对应的材料信息和领料商信息
                
                for(SCOrderOut *orderout in orderOutArray){
                    [self getOrderOutMatWithOrderId:orderout.id withCkToken:ckToken];
                    [self getOrderOutConsumerWithOrderId:orderout.id withCkToken:ckToken];
                }
            }
        }
        //结束下载出库订单
        [self getOrderOutCompleteWithCkToken:outToken];
        
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
                NSArray *matArray = [SCOrderOutMat mj_objectArrayWithKeyValuesArray:array];
                //保存材料明细
                for(SCOrderOutMat *mat in matArray){
                    [mat saveOrUpdate];
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
                NSArray *matArray = [OutConsumer mj_objectArrayWithKeyValuesArray:array];
                //保存出库领料商
                for(OutConsumer *consumer in matArray){
                    [consumer saveOrUpdate];
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
        }
    }
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
        }
        
    }
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
}

/**
 *  上传出库单
 *
 *  @param ckToken  <#ckToken description#>
 *  @param jsonData <#jsonData description#>
 */
-(void)uploadOutWithCkToken:(NSString *)ckToken withData:(NSString *)jsonData withType:(int)type{
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
                          "<type>%d</type>"
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
//            [self.view makeToast:@"上传成功!" duration:3.0 position:CSToastPositionCenter];
        }
        //        [self.view makeToast:da.tempStr duration:3.0 position:CSToastPositionCenter];
    }
}

/**
 *  上传出库单完成
 *
 *  @param ckToken  <#ckToken description#>
 *  @param outCount <#outCount description#>
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
    
    //查询出所有未打印的出库单和直入直出单
    
    //查询出库单
    NSArray *orderOutArray = [SCOrderOut findAll];
    NSArray *outArray = [SCOut findByCriteria:@" WHERE hasPrint = 0 "];
    for(SCOrderOut *orderout in orderOutArray){
        //待打印的材料数组
        NSMutableArray *printArray = [[NSMutableArray alloc] init];
        NSString *deliverNo;
        OutConsumer *consumer;
        outPrintArray = [[NSMutableArray alloc] init];
        for(SCOut *scout in outArray){
            if([scout.receiveid isEqualToString:orderout.id]){
                [outPrintArray addObject:scout];
                //查询供应商
                consumer = [OutConsumer findFirstByCriteria:[NSString stringWithFormat:@" WHERE consumerid = '%@'",scout.consumerid]];
                deliverNo = scout.deliverNo;
                //查询材料明细
                SCOrderOutMat *mat = [SCOrderOutMat findFirstByCriteria:[NSString stringWithFormat:@" WHERE orderentryid =  '%@'",scout.orderEntryid]];
                //让查询到的处理数量为出库单上的数量
                mat.qty = scout.qty;
                [printArray addObject:mat];
            }
        }
        //准备打印出库单数据
        if(printArray.count>0){
           printContant=[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",
                          @"------------------------------",
                          @"\n出库单号:",deliverNo,
                          @"\n项目:",orderout.ProjectName,
                          @"\n领用商:",consumer.Name,
                          @"\n地产公司:",orderout.Company,
                          @"\n------------------------------"];
            for (int i = 0; i<printArray.count; i++) {
                SCOrderOutMat *outMat = printArray[i];
                NSString *matString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%f%@%f%@%f%@%@\n ",
                                       @"\n材料名称:",outMat.Name,
                                       @"\n品牌:",outMat.brand,
                                       @"\n规格型号:",outMat.model,
                                       @"\n数量:",outMat.qty,
                                       @"\n单价:",outMat.price,
                                       @"\n金额:",outMat.qty*outMat.price,
                                       @"\n备注:",outMat.note];
                printContant = [printContant stringByAppendingString:matString];
            }
            printContant = [NSString stringWithFormat:@"%@%@%@",printContant,
                            @"\n收货人:",
                            @"\n证明人:"];
            //开始打印
            //--------------
            [uartLib scanStart];//scan
            NSLog(@"connect Peripheral");
            
            [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
        }
    }
    
    
    
    //查询直入直出单
    NSArray *orderInArray = [SCOrderIn findAll];//入库单
    NSArray *inArray = [SCDirout findByCriteria:@" WHERE hasPrint = 0 "];//直入直出单
    for(SCOrderIn *orderin in orderInArray){
        //待打印的材料数组
        NSMutableArray *printArray = [[NSMutableArray alloc] init];
        NSString *deliverNo;
        InConsumer *consumer;
        dirPrintArray = [[NSMutableArray alloc] init];
        for(SCDirout *dirout in inArray){
            if([dirout.orderid isEqualToString:orderin.id]){
                [dirPrintArray addObject:dirout];
                //查询供应商
                consumer = [InConsumer findFirstByCriteria:[NSString stringWithFormat:@" WHERE consumerid = '%@'",dirout.consumerid]];
                deliverNo = dirout.zrzcid;
                //查询材料明细
                SCOrderInMat *mat = [SCOrderInMat findFirstByCriteria:[NSString stringWithFormat:@" WHERE orderentryid =  '%@'",dirout.orderEntryid]];
                //让查询到的处理数量为出库单上的数量
                mat.qty = dirout.qty;
                [printArray addObject:mat];
            }
        }
        //准备打印出库单数据
        if(printArray.count>0){
            printContant=[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",
                          @"------------------------------",
                          @"\n出库单号:",deliverNo,
                          @"\n项目:",orderin.ProjectName,
                          @"\n领用商:",consumer.Name,
                          @"\n地产公司:",orderin.Company,
                          @"\n------------------------------"];
            for (int i = 0; i<printArray.count; i++) {
                SCOrderInMat *inMat = printArray[i];
                NSString *matString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%f%@%f%@%f%@%@\n ",
                                       @"\n材料名称:",inMat.Name,
                                       @"\n品牌:",inMat.brand,
                                       @"\n规格型号:",inMat.model,
                                       @"\n数量:",inMat.qty,
                                       @"\n单价:",inMat.price,
                                       @"\n金额:",inMat.qty*inMat.price,
                                       @"\n备注:",inMat.note];
                printContant = [printContant stringByAppendingString:matString];
            }
            printContant = [NSString stringWithFormat:@"%@%@%@",printContant,
                            @"\n收货人:",
                            @"\n证明人:"];
            //开始打印
            //--------------
            [uartLib scanStart];//scan
            NSLog(@"connect Peripheral");
            
            [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
        }
        
        
    }
    
}
//-------
-(void)searchPrinter{
    if(connectPeripheral ==nil){
        [uartLib scanStart];//scan
        [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
    }else{
        [uartLib scanStop];
        [uartLib connectPeripheral:connectPeripheral];
        [connectAlertView show];
        [self performSelector:@selector(pirntData) withObject:nil afterDelay:3];
    }
    
}
//-----
-(void)pirntData{
    NSString *curPrintContent;
    
    curPrintContent = printContant;
    
    if ([curPrintContent length]) {
        NSString *printed = [curPrintContent stringByAppendingFormat:@"%c%c%c", '\n', '\n', '\n'];
        
        [self PrintWithFormat:printed];
        //打印完成 记得该状态  todo
        if(outPrintArray.count>0){
            for(SCOut *scout in outPrintArray){
                scout.hasPrint = 1;
                [scout saveOrUpdate];
            }
            outPrintArray = nil;
        }
        
        if(dirPrintArray.count>0){
            for (SCDirout *dirout in dirPrintArray) {
                dirout.hasPrint = 1;
                [dirout saveOrUpdate];
            }
            dirPrintArray = nil;
        }
    }
    [uartLib scanStop];
    [uartLib disconnectPeripheral:connectPeripheral];
    
}

//参数设置
- (IBAction)toSetting:(id)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark UartDelegate
/****************************************************************************/
/*                       UartDelegate Methods                        */
/****************************************************************************/
- (void) didScanedPeripherals:(NSMutableArray  *)foundPeripherals;
{
    NSLog(@"didScanedPeripherals(%lu)", (unsigned long)[foundPeripherals count]);
    
    CBPeripheral	*peripheral;
    
    for (peripheral in foundPeripherals) {
        NSLog(@"--Peripheral:%@", [peripheral name]);
    }
    
    if ([foundPeripherals count] > 0) {
        connectPeripheral = [foundPeripherals objectAtIndex:0];
        if ([connectPeripheral name] == nil) {
            // [[self peripheralName] setText:@"BTCOM"];
        }else{
            // [[self peripheralName] setText:[connectPeripheral name]];
        }
    }else{
        //[[self peripheralName] setText:nil];
        connectPeripheral = nil;
    }
}

- (void) didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"did Connect Peripheral");
    
    //[[self sendButton] setEnabled:TRUE];
    
    [connectAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    //[self printerNotifyEnable];
}

- (void) didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"did Disconnect Peripheral");
    
    // [[self sendButton] setEnabled:FALSE];
    //[[self peripheralName] setText:@""];
    [connectAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    //  [[[UIAlertView alloc] initWithTitle:@"Connect fail" message: @"Fail to connect,Please reconnect!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil] show];
    //--------------wynadd
    [uartLib scanStart];//scan
    NSLog(@"connect Peripheral");
    [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
    
}

- (void) didWriteData:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didWriteData:%@", [peripheral name]);
}


- (void) didReceiveData:(CBPeripheral *)peripheral recvData:(NSData *)recvData
{
    NSLog(@"uart recv(%lu):%@", (unsigned long)[recvData length], recvData);
    
    if ([recvData length] == 4) {
        Byte *recvByte = (Byte *)[recvData bytes];
        
        if (recvByte[2] == 0x0c) {
            NSLog(@"缺纸");
        }else{
            NSLog(@"正常");
        }
    }
    //[self promptDisplay:recvData];
}

- (void) didBluetoothPoweredOff{
    
}
- (void) didBluetoothPoweredOn{
    
}

- (void) didRetrievePeripheral:(NSArray *)peripherals{
    
}

- (void) didRecvRSSI:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI{
    
}
- (void) didDiscoverPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI{
    
}

- (void) didDiscoverPeripheralAndName:(CBPeripheral *)peripheral DevName:(NSString *)devName{
    
}

- (void) didrecvCustom:(CBPeripheral *)peripheral CustomerRight:(bool) bRight{
    
}

- (void) PrintWithFormat:(NSString *)printContent{
#define MAX_CHARACTERISTIC_VALUE_SIZE 20
    NSData  *data	= nil;
    NSUInteger i;
    NSUInteger strLength;
    NSUInteger cellCount;
    NSUInteger cellMin;
    NSUInteger cellLen;
    
    Byte caPrintFmt[5];
    
    /*初始化命令：ESC @ 即0x1b,0x40*/
    caPrintFmt[0] = 0x1b;
    caPrintFmt[1] = 0x40;
    
    /*字符设置命令：ESC ! n即0x1b,0x21,n*/
    caPrintFmt[2] = 0x1b;
    caPrintFmt[3] = 0x21;
    
    caPrintFmt[4] = 0x00;
    
    NSData *cmdData =[[NSData alloc] initWithBytes:caPrintFmt length:5];
    
    [uartLib sendValue:connectPeripheral sendData:cmdData type:CBCharacteristicWriteWithResponse];
    NSLog(@"format:%@", cmdData);
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //NSData *data = [curPrintContent dataUsingEncoding:enc];
    //NSLog(@"dd:%@", data);
    //NSString *retStr = [[NSString alloc] initWithData:data encoding:enc];
    //NSLog(@"str:%@", retStr);
    
    strLength = [printContent length];
    if (strLength < 1) {
        return;
    }
    
    cellCount = (strLength%MAX_CHARACTERISTIC_VALUE_SIZE)?(strLength/MAX_CHARACTERISTIC_VALUE_SIZE + 1):(strLength/MAX_CHARACTERISTIC_VALUE_SIZE);
    for (i=0; i<cellCount; i++) {
        cellMin = i*MAX_CHARACTERISTIC_VALUE_SIZE;
        if (cellMin + MAX_CHARACTERISTIC_VALUE_SIZE > strLength) {
            cellLen = strLength-cellMin;
        }
        else {
            cellLen = MAX_CHARACTERISTIC_VALUE_SIZE;
        }
        
        //NSLog(@"print:%d,%d,%d,%d", strLength,cellCount, cellMin, cellLen);
        NSRange rang = NSMakeRange(cellMin, cellLen);
        NSString *strRang = [printContent substringWithRange:rang];
        NSLog(@"print:%@", strRang);
        
        data = [strRang dataUsingEncoding: enc];
        //data = [strRang dataUsingEncoding: NSUTF8StringEncoding];
        NSLog(@"print:%@", data);
        //data = [strRang dataUsingEncoding: NSUTF8StringEncoding];
        //NSLog(@"print:%@", data);
        
        [uartLib sendValue:connectPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    }
}


@end

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
//#import "MBProgressHUD.h"

@interface MainViewController (){
    NSMutableArray *outPrintArray;//当前打印出库单
    NSMutableArray *dirPrintArray;//当前打印直入直出单
    
//    MBProgressHUD *HUD;
    UIAlertView *asyncRK;//同步入库,如果本地没有上传的单据,确认用户是否删除已下载的入库订单
    UIAlertView *asyncCK;//同步出库,如果本地没有上传的单据,确认用户是否删除已下载的出库订单
    
    NSInteger sum;
    float progress;
    
    int hasIn;//已上传的入库明细数量
    int hasDir;//已上传的直入直出明细数量
    int hasInOut;//已上传的入库出库明细数量
    int hasOut;//已上传的出库明细数量
    
    NSInteger dirN;//直入直出单条数
    NSInteger inN;//入库单条数
    NSInteger inoutN;//入库出库条数
    NSInteger outN;//出库单条数
    
    //查询入库单
    NSArray *inArray;
    //查询直入直出
    NSArray *diroutArray;
    //查询入库出库
    NSArray *inoutArray;
    //查询出库单
    NSArray *outArray;
}

@end

@implementation MainViewController


-(void)back:(id)sender {
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    progress = 0.0f;
    
    
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
                                                      message:@"当前的网络连接不可用，数据上传和瞎子啊功能无法使用,请退出应用并到有网络的环境中再打开！"
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



//数据上传
- (IBAction)upload:(id)sender {
    if (![self isConnectionAvailable:@"http:\\www.baidu.com"]) {
        //错误提示框的初始化
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"当前的网络连接不可用，数据上传和下载功能无法使用,请退出应用并到有网络的环境中再打开！"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
    }else{

        [self checkToUpload];
    
        if(sum>0){
            progress = 0.0f;
            //SVProgressHUD
            [SVProgressHUD showProgress:0.0 status:@"上传中..."];
            
            //上传直入直出单
            if(dirN>0){
                for(DirBillChild *child in diroutArray){
                    [self uploadDiroutWithRkToken:inToken withData:child];
                }
            }
            
            //上传入库单
            if(inN>0){
                for(InBillChild *child in inArray){
                    [self uploadInWithRkToken:inToken withData:child];
                }
            }
            
            //上传出库单
            if(outN>0){
                for(OutBillChild *child in outArray){
                    [self uploadOutWithCkToken:outToken withData:child withType:@"ck"];
                }
            }
            
        }else{
            [self.view makeToast:@"暂无上传的数据!" duration:3.0 position:CSToastPositionCenter];
        }
        
        
    }
    
}

//查询需要上传的数据
- (void)checkToUpload
{
    //查询数据  直入直出、入库、入库出库、出库数据
    hasIn = 0;
    hasDir = 0;
    hasInOut = 0;
    hasOut = 0;
    dirN = 0;//直入直出单条数
    inN = 0;//入库单条数
    inoutN = 0;//入库出库条数
    outN = 0;//出库单条数

    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    //读取入库的token
    
    inToken = [userDefaultes valueForKey:@"rkToken"];//
    
    //读取出库的token
    outToken = [userDefaultes valueForKey:@"ckToken"];//
    if(inToken && inToken.length>0){
        //查询入库单
        inArray = [InBillChild findAll];
        //查询直入直出
        diroutArray = [DirBillChild findAll];
        //查询出库单
        inoutArray = [OutBillChild findByCriteria:@" where type = 'rkck'"];
        
        //上传直入直出数量
        dirN = diroutArray.count;
        //上传入库单数量
        inN = inArray.count;
        //上传入库出库单数量
        inoutN = inoutArray.count;
    }
    
    if(outToken && outToken.length>0){
        //查询出库单
        outArray = [OutBillChild findByCriteria:@" where type = 'ck'"];
        //上传出库单数量
        outN =outArray.count;
    }
    
    sum = dirN+inN+inoutN+outN;
}



//入库下载
- (IBAction)synStorage:(id)sender {
    if (![self isConnectionAvailable:@"http:\\www.baidu.com"]) {
        //错误提示框的初始化
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"当前的网络连接不可用，数据上传和下载功能无法使用,请退出应用并到有网络的环境中再打开！"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
    }else{
        //查询当前数据库中需要上传的数据
        [self checkToUpload];
        
        if(sum>0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"存在需要上传的数据,请先上传数据" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }else{
            //查询是否存在入库相关的单据
            if(inToken&& inToken.length>0){
                asyncRK = [[UIAlertView alloc] initWithTitle:@"重新下载" message:@"您想重新下载数据吗？若是则会清除已下载数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [asyncRK show];
            }else{
                //删除数据库中的入库单及其关联表
                [SCDBTool clearInData:inToken];
                //直接下载入库订单
                [self getOrderInTitle];
            }
        }
    }
}

-(void)myTask {
    NSLog(@"耗时操作");
}

//出库下载
- (IBAction)syncOut:(id)sender {
    if (![self isConnectionAvailable:@"http:\\www.baidu.com"]) {
        //错误提示框的初始化
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                      message:@"当前的网络连接不可用，数据上传和下载功能无法使用,请退出应用并到有网络的环境中再打开！"
                                                     delegate:self
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
        [alert show];//提示框的显示 必须写 不然没有任何反映
    }else{
        //查询当前数据库中需要上传的数据
        [self checkToUpload];
        if(sum>0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"存在需要上传的数据,请先上传数据" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }else{
            if(outToken && outToken.length>0){
                asyncCK = [[UIAlertView alloc] initWithTitle:@"重新下载" message:@"您想重新下载数据吗？若是则会清除已下载数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [asyncCK show];
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
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
            [self.view makeToast:stringArray[1] duration:3.0 position:CSToastPositionCenter];

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
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
                [self.view makeToast:@"入库下载成功!" duration:3.0 position:CSToastPositionCenter];
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
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
            
            [self.view makeToast:string duration:3.0 position:CSToastPositionCenter];
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
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
                                                          message:@"出库下载成功!"
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
- (void)uploadDiroutWithRkToken:(NSString *)rkToken withData:(id)object{
    NSString *json = [SCDBTool stringWithData:((DirBillChild *)object).mj_keyValues];
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
                          "</soap:Envelope>\n",self.user.UserOID,rkToken,json];
        
        SCSoapHttpOperation *operation = [[SCSoapHttpOperation alloc] init];
        [operation postwithURL:connectUrl withparameter:data withSoapAction:@"http://tempuri.org/Mobile_uploadZRZCInfo" withResultDomain:@"Mobile_uploadZRZCInfoResult" WithReturnValeuBlock:^(id returnValue) {
            NSArray<NSString *> *stringArray = [(NSString *)returnValue componentsSeparatedByString:@":"];
            if([stringArray[0] isEqualToString:@"false"]){
                //无数据
                NSArray<NSString *> *stringArray = [(NSString *)returnValue componentsSeparatedByString:@":"];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                              message:stringArray[1]
                                                             delegate:self
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil, nil];
                [alert show];//提示框的显示 必须写 不然没有任何反映
                
            }else if([stringArray[0] isEqualToString:@"true"]){
                //直入直出上传成功!
                hasDir ++;
                progress = progress + (float)(1.0f/sum);
                if(progress<1){
                    [SVProgressHUD showProgress:progress status:@"上传中..."];
                    //                if(hasDir+1<dirN){
                    //                    [self uploadDiroutWithRkToken:inToken withData:diroutArray[hasDir]];
                    //                }
                }else{
                    [SVProgressHUD dismissWithDelay:0.0];
                    
                    NSString *string00 = @"本次上传";
                    NSString *string01 = @"";//入库明细
                    NSString *string02 = @"";//入库出库明细
                    NSString *string03 = @"";//直入直出明细
                    NSString *string04 = @"";//出库明细
                    if(inN>0){
                        string01 = [NSString stringWithFormat:@"入库单明细%ld条 ",inN];
                    }
                    
                    if(inoutN>0){
                        string02 = [NSString stringWithFormat:@"入库出库单明细%ld条 ",inoutN];
                    }
                    
                    if(dirN>0){
                        string03 = [NSString stringWithFormat:@"直入直出单明细%ld条 ",dirN];
                    }
                    
                    if(outN>0){
                        string04 = [NSString stringWithFormat:@"出库单明细%ld条 ",outN];
                    }
                    
                    
                    NSString *string = [NSString stringWithFormat:@"%@%@%@%@%@",string00,string01,string02,string03,string04];
                    [self.view makeToast:string duration:3.0 position:CSToastPositionCenter];
                }
            }
            //上传入库单结束
            if(hasIn==inN && hasInOut == inoutN && hasDir == dirN){
//                [SVProgressHUD dismissWithDelay:0.0];
                [self uploadInCompleteWithRkToken:inToken withDirout:dirN withInCount:inN withOutCounr:inoutN];
                //删除数据库中的入库单及其关联表
                [SCDBTool clearInData:inToken];
                inoutArray = nil;
                diroutArray = nil;
                inArray = nil;
                
            }
        } WithFailureBlock:^{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:@"网络连接中断!"
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
        }];
    }
}

/**
 *  上传入库数据
 */
-(void)uploadInWithRkToken:(NSString *)rkToken withData:(id)object{
    NSString *jsonData = [SCDBTool stringWithData:((InBillChild *)object).mj_keyValues];
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
        SCSoapHttpOperation *operation = [[SCSoapHttpOperation alloc] init];
        [operation postwithURL:connectUrl withparameter:data withSoapAction:@"http://tempuri.org/Mobile_uploadrkInfo" withResultDomain:@"Mobile_uploadrkInfoResult" WithReturnValeuBlock:^(id returnValue) {
            NSArray<NSString *> *stringArray = [(NSString *)returnValue componentsSeparatedByString:@":"];
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
                progress = progress + (float)(1.0f/sum);
                if(progress<1){
                    [SVProgressHUD showProgress:progress status:@"上传中..."];
                }else{
                    [SVProgressHUD dismissWithDelay:0.0];
                    
                    NSString *string00 = @"本次上传";
                    NSString *string01 = @"";//入库明细
                    NSString *string02 = @"";//入库出库明细
                    NSString *string03 = @"";//直入直出明细
                    NSString *string04 = @"";//出库明细
                    if(inN>0){
                        string01 = [NSString stringWithFormat:@"入库单明细%ld条 ",inN];
                    }
                    
                    if(inoutN>0){
                        string02 = [NSString stringWithFormat:@"入库出库单明细%ld条 ",inoutN];
                    }
                    
                    if(dirN>0){
                        string03 = [NSString stringWithFormat:@"直入直出单明细%ld条 ",dirN];
                    }
                    
                    if(outN>0){
                        string04 = [NSString stringWithFormat:@"出库单明细%ld条 ",outN];
                    }
                    
                    
                    NSString *string = [NSString stringWithFormat:@"%@%@%@%@%@",string00,string01,string02,string03,string04];
                    [self.view makeToast:string duration:3.0 position:CSToastPositionCenter];
                }
            }
            //上传入库单结束
            if(hasIn==inN && hasInOut == inoutN && hasDir == dirN){
//                [SVProgressHUD dismissWithDelay:0.0];
                [self uploadInCompleteWithRkToken:inToken withDirout:dirN withInCount:inN withOutCounr:inoutN];
                
                //删除数据库中的入库单及其关联表
                [SCDBTool clearInData:inToken];
                inoutArray = nil;
                diroutArray = nil;
                inArray = nil;

            }else {
                if(hasIn==inN){
                    //入库单上传结束,才可以上传出库单
                    if(inoutN>0){
                        for(OutBillChild *child in inoutArray){
                            [self uploadOutWithCkToken:inToken withData:child withType:@"rkck"];
                        }
                        
                    }
                }
            }
        } WithFailureBlock:^{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:@"网络连接中断!"
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
        }];
    }
}
/**
 *  上传入库相关结束
 */
-(void)uploadInCompleteWithRkToken:(NSString *)rkToken withDirout:(NSInteger)diroutCount withInCount:(NSInteger)inCount withOutCounr:(NSInteger)outCount {
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
            if(diroutCount>0 && inCount>0 && outCount>0){
                //入库上传成功!
                if(outN==hasOut){
                    [self.view makeToast:@"上传入库成功!" duration:3.0 position:CSToastPositionCenter];
                }
            }
        }
    }
}

/**
 *  上传出库单
 *
 *  @param ckToken  <#ckToken description#>
 *  @param jsonData <#jsonData description#>
 */
-(void)uploadOutWithCkToken:(NSString *)ckToken withData:(id)object withType:(NSString *)type{
    NSString *jsonData = [SCDBTool stringWithData:((OutBillChild *)object).mj_keyValues];
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
        
        SCSoapHttpOperation *operation = [[SCSoapHttpOperation alloc] init];
        [operation postwithURL:connectUrl withparameter:data withSoapAction:@"http://tempuri.org/Mobile_uploadckInfo" withResultDomain:@"Mobile_uploadckInfoResult" WithReturnValeuBlock:^(id returnValue) {
            
            NSArray<NSString *> *stringArray = [(NSString *)returnValue componentsSeparatedByString:@":"];
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
                
                if([type isEqual:@"ck"]){
                    hasOut ++;
                }else{
                    hasInOut ++;
                }
                progress = progress + (float)(1.0f/sum);
                if(progress<1){
                    [SVProgressHUD showProgress:progress status:@"上传中..."];
                }else{
                    [SVProgressHUD dismissWithDelay:0.0];
                    NSString *string00 = @"本次上传";
                    NSString *string01 = @"";//入库明细
                    NSString *string02 = @"";//入库出库明细
                    NSString *string03 = @"";//直入直出明细
                    NSString *string04 = @"";//出库明细
                    if(inN>0){
                        string01 = [NSString stringWithFormat:@"入库单明细%ld条 ",inN];
                    }
                    
                    if(inoutN>0){
                        string02 = [NSString stringWithFormat:@"入库出库单明细%ld条 ",inoutN];
                    }
                    
                    if(dirN>0){
                        string03 = [NSString stringWithFormat:@"直入直出单明细%ld条 ",dirN];
                    }
                    
                    if(outN>0){
                        string04 = [NSString stringWithFormat:@"出库单明细%ld条 ",outN];
                    }
                    
                    
                    NSString *string = [NSString stringWithFormat:@"%@%@%@%@%@",string00,string01,string02,string03,string04];
                    [self.view makeToast:string duration:3.0 position:CSToastPositionCenter];
                }
            }
            
            if([type isEqualToString:@"rkck"]){
                //上传入库单结束
                if(hasIn==inN && hasInOut == inoutN && hasDir == dirN){
//                    [SVProgressHUD dismissWithDelay:0.0];
                    [self uploadInCompleteWithRkToken:inToken withDirout:dirN withInCount:inN withOutCounr:inoutN];
                    
                    //删除数据库中的入库单及其关联表
                    [SCDBTool clearInData:inToken];
                    inoutArray = nil;
                    diroutArray = nil;
                    inArray = nil;
                    
                }
            }else if([type isEqualToString:@"ck"]){
                if(hasOut==outN){
                    
//                    [SVProgressHUD dismissWithDelay:0.0];
                    //上传出库单结束
                    [self uploadOutCompleteWithCkToken:outToken withOutCount:outN];
                    
                    //删除数据库中的出库单及其关联表
                    [SCDBTool clearOutData:outToken];
                    outArray = nil;
                    
                }
            }
        } WithFailureBlock:^{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:@"网络连接中断!"
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
        }];
    }
}

/**
 *  上传出库单完成
 *
 *  @param ckToken
 *  @param outCount
 */
-(void)uploadOutCompleteWithCkToken:(NSString *)ckToken withOutCount:(NSInteger)outCount {
    if([serverUrl isEqualToString:@""] || serverUrl == nil){
        [self.view makeToast:@"请先维护好服务器配置!" duration:3.0 position:CSToastPositionCenter];
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
            if(outCount>0){
                if(hasIn==inN && hasInOut == inoutN && hasDir == dirN){
                    [self.view makeToast:@"上传出库成功!" duration:3.0 position:CSToastPositionCenter];
                }
            }
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
}
//参数设置
- (IBAction)toSetting:(id)sender {
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end

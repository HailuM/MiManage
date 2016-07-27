//
//  PrintViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/19.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "PrintViewController.h"
#import "OutBill.h"
#import "OutBillChild.h"
#import "DirBill.h"
#import "DirBillChild.h"
#import "OrderTableViewCell.h"
#import "MainViewController.h"


@interface PrintViewController (){
    NSArray *outArray;//出库单
    NSArray *dirArray;//直入直出单
    
    NSMutableArray *array;
    
    //打印用
    UIAlertView *connectAlertView;
    UartLib *uartLib;
    CBPeripheral *connectPeripheral;
    NSString *printContant;
 
    
    
    NSInteger type;//0, 出库单   1,直入直出单
    
    OutBill *outBill;
    NSArray *outChildArray;
    
    DirBill *dirBill;
    NSArray *dirChildArray;
    
    UIAlertView *printAlert;
    
    
    int timeCount;
//    UIAlertView *bleAlert;//提示未连接上蓝牙
}

@end

@implementation PrintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    timeCount = 0;
    // Do any additional setup after loading the view.
    
    self.title = @"打印";
    uartLib = [[UartLib alloc] init];
    [uartLib setUartDelegate:self];
    connectAlertView = [[UIAlertView alloc] initWithTitle:@"连接蓝牙打印机" message: @"连接中，请稍后!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil,nil];
    
//    bleAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法连接上蓝牙打印机，是否返回主界面？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    
    
    array = [[NSMutableArray alloc] init];
    
    //查询出库单和直入直出单
    [self fetchOut];
    [self fetchDir];
}

/**
 *  查询出库单
 */
-(void)fetchOut {
    outArray = [OutBill findAll];
    [array addObjectsFromArray:outArray];
    [self.tableView reloadData];
}

/**
 *  查询直入直出单
 */
-(void)fetchDir{
    dirArray = [DirBill findAll];
    [array addObjectsFromArray:dirArray];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView==connectAlertView){
        switch (buttonIndex) {
            case 0:
                NSLog(@"Cancel Button Pressed");
                [uartLib scanStop];
                [uartLib disconnectPeripheral:connectPeripheral];
                break;
                
            default:
                break;
        }
    }else if(alertView==printAlert){
        if(buttonIndex==0){
            [uartLib scanStart];//scan
            NSLog(@"connect Peripheral");
            [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
        }
    }
//    else if([alertView isEqual:bleAlert]){
//        if(buttonIndex==1){
//            //返回首页
//            NSArray *controllers = self.navigationController.viewControllers;
//            for(UIViewController *viewController in controllers){
//                if([viewController isKindOfClass:[MainViewController class]]){
//                    [self.navigationController popToViewController:viewController animated:YES];
//                }
//            }
//        }else{
//            timeCount = 0;
//            [uartLib scanStart];//scan
//            NSLog(@"connect Peripheral");
//            [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
//        }
//    }
}

#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 131.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderTableViewCell *cell = [OrderTableViewCell cellWithTableView:tableView];
    PuOrder *order = array[indexPath.row];
    cell.flag = 1;
    [cell showCell:order];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //提示打印
    id value = array[indexPath.row];
    if([value isKindOfClass:[OutBill class]]){
        //出库单
        //查询出库单的材料明细
        type=0;
        outBill = value;
        NSString *cri = [NSString stringWithFormat:@" WHERE outgid = '%@'",((OutBill*)value).gid];
        outChildArray = [OutBillChild findByCriteria:cri];
        //开始打印
        printContant=[NSString stringWithFormat:@"%@\n第%d次打印%@%@%@%@%@%@%@%@%@",
                      @"------------------------------",
                      (outBill.printcount+1),
                      @"\n出库单号:",outBill.deliverNo,
                      @"\n项目:",outBill.ProjectName,
                      @"\n领用商:",outBill.consumername,
                      @"\n地产公司:",outBill.Company,
                      @"\n------------------------------"];
        for (int i = 0; i<outChildArray.count; i++) {
            OutBillChild *outMat = outChildArray[i];
            NSString *matString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@\n ",
                                   @"\n材料名称:",outMat.Name,
                                   @"\n品牌:",outMat.brand,
                                   @"\n规格型号:",outMat.model,
                                   @"\n数量:",[StringUtil changeFloat:outMat.qty],
                                   @"\n备注:",outMat.note];
            printContant = [printContant stringByAppendingString:matString];
        }
        printContant = [NSString stringWithFormat:@"%@%@%@%@",printContant,
                        @"\n收货人:________________________",
                        @"\n                                ",
                        @"\n证明人:________________________"];
    }
    if([value isKindOfClass:[DirBill class]]){
        //直入直出单
        //查询直入直出单的材料明细
        type = 1;
        NSString *cri = [NSString stringWithFormat:@" WHERE zrzcid = '%@'",((DirBill*)value).zrzcid];
        dirChildArray = [DirBillChild findByCriteria:cri];
        //生成打印的字符串
        dirBill = value;
        //开始打印
        printContant=[NSString stringWithFormat:@"%@\n第%d次打印%@%@%@%@%@%@%@%@%@",
                      @"\n-----------------------------",
                      (dirBill.printcount+1),
                      @"\n出库单号:",dirBill.number,
                      @"\n项目:",dirBill.ProjectName,
                      @"\n领用商:",dirBill.consumername,
                      @"\n地产公司:",dirBill.Company,
                      @"\n-----------------------------"];
        for (int i = 0; i<dirChildArray.count; i++) {
            DirBillChild *billChild = dirChildArray[i];
            NSString *matString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@\n ",
                                   @"\n材料名称:",billChild.Name,
                                   @"\n品牌:",billChild.brand,
                                   @"\n规格型号:",billChild.model,
                                   @"\n数量:",[StringUtil changeFloat:billChild.qty],
                                   @"\n备注:",billChild.note];
            printContant = [printContant stringByAppendingString:matString];
        }
        printContant = [NSString stringWithFormat:@"%@%@%@%@",printContant,
                        @"\n收货人:_____________________",
                        @"\n",
                        @"\n证明人:_____________________"];
    }
    //准备好的打印字符串
    //--------------
    
    printAlert = [[UIAlertView alloc] initWithTitle:@"打印预览" message:printContant delegate:self cancelButtonTitle:@"打印" otherButtonTitles: nil];
    NSArray *subViewArray = printAlert.subviews;
    for(int x=0;x<[subViewArray count];x++){
        if([[[subViewArray objectAtIndex:x] class] isSubclassOfClass:[UILabel class]])
        {
            UILabel *label = [subViewArray objectAtIndex:x];
            label.textAlignment = UITextAlignmentLeft;
        }
        
    }
    [printAlert show];
}

//-------
-(void)searchPrinter{
    if(connectPeripheral ==nil){
        if(timeCount>10){
            //提示，未连接上蓝牙，是否返回主页面
            [self.view makeToast:@"无连接上蓝牙打印机!"];
            //返回首页
            [uartLib scanStop];
            //主线程延迟5秒
            [self performSelector:@selector(delayMethod) withObject:nil afterDelay:5.0f];
            
            NSArray *controllers = self.navigationController.viewControllers;
            for(UIViewController *viewController in controllers){
                if([viewController isKindOfClass:[MainViewController class]]){
                    [self.navigationController popToViewController:viewController animated:YES];
                }
            }
        }else{
            [uartLib scanStart];//scan
            [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
            timeCount = timeCount+3;
        }
    }else{
        [uartLib scanStop];
        [uartLib connectPeripheral:connectPeripheral];
        [connectAlertView show];
        [self performSelector:@selector(pirntData) withObject:nil afterDelay:3];
    }
    
}
- (void)delayMethod { NSLog(@"execute"); }

//-----
-(void)pirntData{
    NSString *curPrintContent;
    
    curPrintContent = printContant;
    
    if ([curPrintContent length]) {
        NSString *printed = [curPrintContent stringByAppendingFormat:@"%c%c%c", '\n', '\n', '\n'];
        
        [self PrintWithFormat:printed];
        if(type==0){
            outBill.printcount ++;
            [outBill saveOrUpdate];
            for(OutBillChild *childPrint in outChildArray){
                childPrint.printcount ++;
                [childPrint saveOrUpdate];
            }
            
        }
        
        if(type==1){
            dirBill.printcount ++;
            [dirBill saveOrUpdate];
            for(DirBillChild *childPrint in outChildArray){
                childPrint.printcount ++;
                [childPrint saveOrUpdate];
            }
        }
    }
    [uartLib scanStop];
    [uartLib disconnectPeripheral:connectPeripheral];
    
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
//    [uartLib scanStart];//scan
//    NSLog(@"connect Peripheral");
//    [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
    
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

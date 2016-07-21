//
//  ConfirmDiroutViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "ConfirmDiroutViewController.h"
#import "UIView+Toast.h"
#import "UUIDUtil.h"


@interface ConfirmDiroutViewController (){
    UIAlertView *connectAlertView;
    UartLib *uartLib;
    CBPeripheral *connectPeripheral;
    NSString *printContant;
    
    
    UIAlertView *printAlert;
    
    DirBill *bill;
    
}

@end

@implementation ConfirmDiroutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"直入直出确认";
    
    [self showOrder];
    
    [self.confirmBtn addTarget:self action:@selector(confirmDealDirout:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *chooseConsumerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseConsumer:)];
    self.consumerLabel.userInteractionEnabled = YES;
    [self.consumerLabel addGestureRecognizer:chooseConsumerTap];
    
    uartLib = [[UartLib alloc] init];
    [uartLib setUartDelegate:self];
    connectAlertView = [[UIAlertView alloc] initWithTitle:@"连接蓝牙打印机" message: @"连接中，请稍后!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil,nil];
}

/**
 *  选择领料商
 *
 *  @param sender <#sender description#>
 */
-(void)chooseConsumer:(id)sender{
    [self performSegueWithIdentifier:@"diroutconfirmtochoose" sender:self];
}
/**
 *  展示订单信息
 */
-(void)showOrder{
    if(self.order){
        self.numberLabel.text = self.order.number;
        self.supplierLabel.text = self.order.supplier;
        self.addrLabel.text = self.order.Addr;
        // todo
        //        self.contactLabel.text = self.order.con
        if(!self.selArray){
            self.selArray = [[NSMutableArray alloc] init];
        }
        double sum = 0;
        for(PuOrderChild *inMat in self.selArray){
            sum = sum + inMat.curQty;
        }
        self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)self.selArray.count];
        //        [self initData];
        if(self.consumer){
            self.consumerLabel.text = self.consumer.Name;
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"diroutdetailtochoose"]){
        ChooseConsumerViewController *viewController = segue.destinationViewController;
        viewController.flag = 1;
        viewController.orderid = self.order.id;
        viewController.delegate = self;
    }
}

#pragma mark - TableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderDetailTableViewCell *cell = [OrderDetailTableViewCell cellWithTableView:tableView];
    cell.orderType = self.order.type;
    PuOrderChild *inMat = self.selArray[indexPath.row];
    [cell showCell:inMat];
    cell.addBtn.tag = 1000+indexPath.row;
    [cell.addBtn setImage:[UIImage imageNamed:@"del"] forState:UIControlStateNormal];
    [cell.addBtn addTarget:self action:@selector(delToCheck:) forControlEvents:UIControlEventTouchUpInside];
    
    //减号"-"事件
    cell.delLabel.tag = 2000+indexPath.row;
    [cell.delLabel addTarget:self action:@selector(delQty:) forControlEvents:UIControlEventTouchUpInside];
    
    //加号"+"事件
    cell.addLabel.tag = 3000+indexPath.row;[cell.addLabel addTarget:self action:@selector(addQty:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //弹出对话框,填写数量
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 4000+indexPath.row;
    PuOrderChild *inMat = self.selArray[indexPath.row];
    
    UITextField *countText = [alert textFieldAtIndex:0];
    [countText setKeyboardType:UIKeyboardTypeDecimalPad];
    //尾数去0
    countText.text = [StringUtil changeFloat:[NSString stringWithFormat:@"%f",inMat.curQty]];
    [alert show];
}
/**
 *  减号 不能小于0
 *
 *  @param sender <#sender description#>
 */
-(void)delQty:(id)sender{
    UILabel *label = sender;
    NSInteger tag = label.tag-2000;
    PuOrderChild *inMat = self.selArray[tag];
    if(inMat.curQty-1<=0){
        inMat.curQty = 0;
    }else{
        inMat.curQty = inMat.curQty-1;
    }
    [self.tableView reloadData];
}

-(void)addQty:(id)sender {
    UILabel *label = sender;
    NSInteger tag = label.tag-3000;
    PuOrderChild *inMat = self.selArray[tag];
    if(inMat.curQty+1>inMat.limitQty){
        inMat.curQty = inMat.limitQty;
    }else{
        inMat.curQty = inMat.curQty+1;
    }
    [self.tableView reloadData];
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
    }else{
        if(buttonIndex==alertView.firstOtherButtonIndex){
            NSInteger tag = alertView.tag-4000;
            UITextField *countText = [alertView textFieldAtIndex:0];
            NSString *count = countText.text;
            PuOrderChild *inMat = self.selArray[tag];
            double qty = [count doubleValue];
            
            if(qty>inMat.limitQty){
                [self.view makeToast:@"数量超过上限,请重新输入!" duration:3.0 position:CSToastPositionCenter];
            }else if(qty<inMat.sourceQty){
                [self.view makeToast:@"数量未达到订单最低限制!" duration:3.0 position:CSToastPositionCenter];
            }else{
                inMat.curQty = qty;
            }
            
            
            [self.tableView reloadData];
        }
    }
}


-(void)delToCheck:(id)sender {
    UIButton *btn = sender;
    NSInteger position = btn.tag - 1000;
    [self.unSelArray addObject:self.selArray[position]];
    [self.selArray removeObjectAtIndex:position];
    [self.tableView reloadData];
}

-(void)pass:(id)value {
    self.consumer = value;
    if(self.consumer){
        self.consumerLabel.text = self.consumer.Name;
    }
}
/**
 *  确认直入直出,保存至数据库
 *
 *  @param sender
 */
- (void)confirmDealDirout:(id)sender {
    if(self.consumer){
 
        double sum = 0;
        for(PuOrderChild *inMat in self.selArray){
            sum = sum + inMat.curQty;
        }
        if(self.selArray.count==0 || sum==0){
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:@"尚未选择材料入库,请执行入库后再提交!"
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
        }else if(self.unSelArray.count==0){
            //保存数据库
            // TODO 涉及到出入库的数量判断
            self.array = [[NSMutableArray alloc] init];
            NSDate *now = [NSDate date];
            
            //直入直出单号
            NSString *deliverNo = [NSString stringWithFormat:@"%@%@",[DateTool dateToString:now],[DateTool randomNumber]];
            int finish = 0;//判断单据是否结束:0,已结束  >0,未结束
            for (int i = 0; i<self.selArray.count; i++) {
                PuOrderChild *inMat = self.selArray[i];
                if(inMat.curQty+inMat.rkQty>=inMat.sourceQty && inMat.curQty+inMat.rkQty<=inMat.limitQty){
                    finish = finish;
                }else{
                    finish ++;
                }
            }
            //订单已结束
            if(finish==0){
                //生成直入直出单主表
                bill = [[DirBill alloc] init];
                bill.zrzcid = [UUIDUtil getUUID];
                bill.orderid = self.order.id;
                bill.number = [StringUtil generateNo:@"SCZRZC"];
                bill.date = self.order.date;
                bill.supplier = self.order.supplier;
                bill.materialDesc = self.order.materialDesc;
                bill.Addr = self.order.Addr;
                bill.ProjectName= self.order.ProjectName;
                bill.Company = self.order.Company;
                bill.preparertime = [DateTool datetimeToString:now];
                bill.consumerid = self.consumer.consumerid;
                bill.consumername = self.consumer.Name;
                bill.printcount = 0;
                
                [bill saveOrUpdate];//保存直入直出单主表
                
                for (int i = 0; i<self.selArray.count; i++) {
                    PuOrderChild *inMat = self.selArray[i];
                    //更新已处理数量
                    inMat.ckQty = inMat.ckQty+inMat.curQty;//已出库数量
                    inMat.rkQty = inMat.rkQty+inMat.curQty;//已入库数量
                    
                    //生成入库单
                    DirBillChild *billChild = [[DirBillChild alloc] init];
                    billChild.orderid = bill.orderid;
                    billChild.preparertime = bill.preparertime;
                    billChild.consumerid = bill.consumerid;
                    billChild.orderEntryid = inMat.orderentryid;
                    billChild.zrzcid = bill.zrzcid;
                    billChild.qty = inMat.curQty;
                    billChild.printcount = bill.printcount;
                    billChild.deliverNo = bill.number;
                    billChild.receiverOID = self.consumer.receiverOID;
                    billChild.Name = inMat.Name;
                    billChild.model = inMat.model;
                    billChild.unit = inMat.unit;
                    billChild.brand = inMat.brand;
                    billChild.note = inMat.note;
                    billChild.price = inMat.price;
                    
                    [billChild saveOrUpdate];
                    [self.array addObject:billChild];
                    inMat.curQty = 0;
                    inMat.isFinish = 1;
                    [inMat saveOrUpdate];
                }
                
                /**
                 *  设置订单只能直入直出
                 */
                self.order.type = @"zrzc";
                self.order.isFinish = 1;
                [self.order saveOrUpdate];
                
                //开始打印
                printContant=[NSString stringWithFormat:@"%@\n第%d次打印%@%@%@%@%@%@%@%@%@",
                              @"\n------------------------------",
                              (bill.printcount+1),
                              @"\n出库单号:",bill.number,
                              @"\n项目:",bill.ProjectName,
                              @"\n领用商:",bill.consumername,
                              @"\n地产公司:",bill.Company,
                              @"\n-----------------------------"];
                for (int i = 0; i<self.array.count; i++) {
                    DirBillChild *billChild = self.array[i];
                    NSString *matString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@\n ",
                                           @"\n材料名称:",billChild.Name,
                                           @"\n品牌:",billChild.brand,
                                           @"\n规格型号:",billChild.model,
                                           @"\n数量:",[StringUtil changeFloat:[NSString stringWithFormat:@"%f",billChild.qty]],
                                           @"\n备注:",billChild.note];
                    printContant = [printContant stringByAppendingString:matString];
                }
                printContant = [NSString stringWithFormat:@"%@%@%@%@",printContant,
                                @"\n收货人:_____________________",
                                @"\n    ",
                                @"\n证明人:_____________________"];
                
                //准备好的打印字符串
                //--------------
                
                printAlert = [[UIAlertView alloc] initWithTitle:@"打印预览" message:printContant delegate:self cancelButtonTitle:@"打印" otherButtonTitles: nil];
                [printAlert show];
                
                //返回首页
                NSArray *controllers = self.navigationController.viewControllers;
                for(UIViewController *viewController in controllers){
                    if([viewController isKindOfClass:[DiroutDealViewController class]]){
                        [self.navigationController popToViewController:viewController animated:YES];
                    }
                }

            }else{
                [self.view makeToast:@"直入直出必须一次性处理完材料!" duration:3.0 position:CSToastPositionCenter];
            }
        }else{
            [self.view makeToast:@"直入直出必须一次性处理完材料!" duration:3.0 position:CSToastPositionCenter];
        }
        
    }else{
        [self.view makeToast:@"请选择领料商!" duration:3.0 position:CSToastPositionCenter];
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
        
        //查找当前存入数据库的直入直出单,修改打印次数
        DirBill *billPrint = [DirBill findFirstByCriteria:[NSString stringWithFormat:@" WHERE zrzcid = '%@'",bill.zrzcid]];
        billPrint.printcount ++;
        [billPrint saveOrUpdate];
        
        //根据当前存入数据库的直入直出单,修改对应材料的打印次数
        NSArray *printArray = [DirBillChild findByCriteria:[NSString stringWithFormat:@" WHERE zrzcid = '%@'",billPrint.zrzcid]];
        for(DirBillChild *childPrint in printArray){
            childPrint.printcount ++;
            [childPrint saveOrUpdate];
        }
    }
    [uartLib scanStop];
    [uartLib disconnectPeripheral:connectPeripheral];
    
}


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

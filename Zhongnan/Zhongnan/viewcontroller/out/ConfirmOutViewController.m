//
//  ConfirmOutViewController.m
//  Zhongnan
//
//  Created by WongSuechang on 2016/7/2.
//  Copyright © 2016年 EMI. All rights reserved.
//

#import "ConfirmOutViewController.h"
#import "OrderDetailTableViewCell.h"
#import "DateTool.h"
#import "StringUtil.h"
#import "UUIDUtil.h"
#import "UIView+Toast.h"

@interface ConfirmOutViewController (){
    UIAlertView *connectAlertView;
    UartLib *uartLib;
    CBPeripheral *connectPeripheral;
    NSString *printContant;
    
    SCOrderMOut *mOut;
}

@end

@implementation ConfirmOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"出库确认";
    [self showOrder];
    
    [self.confirmBtn addTarget:self action:@selector(confirmDealOut:) forControlEvents:UIControlEventTouchUpInside];
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
    [self performSegueWithIdentifier:@"outconfirmtochoose" sender:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        for(SCOrderOutMat *outMat in self.selArray){
            sum = sum + outMat.qty;
        }
        self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu;总数量:%.2f",(unsigned long)self.selArray.count,sum];
        //        [self initData];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"outconfirmtochoose"]){
        ChooseConsumerViewController *viewController = segue.destinationViewController;
        viewController.flag = 0;
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
    SCOrderOutMat *outMat = self.selArray[indexPath.row];
    [cell showCell:outMat];
    cell.addBtn.tag = 1000+indexPath.row;
    [cell.addBtn setImage:[UIImage imageNamed:@"del"] forState:UIControlStateNormal];
    [cell.addBtn addTarget:self action:@selector(delToCheck:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //弹出对话框,填写数量
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 2000+indexPath.row;
    SCOrderOutMat *inMat = self.selArray[indexPath.row];
    
    UITextField *countText = [alert textFieldAtIndex:0];
    [countText setKeyboardType:UIKeyboardTypeDecimalPad];
    countText.text = [NSString stringWithFormat:@"%f",inMat.qty];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == connectAlertView) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"Cancel Button Pressed");
                [uartLib scanStop];
                [uartLib disconnectPeripheral:connectPeripheral];
                break;
                
            default:
                break;
        }
    }else{
        if(buttonIndex==alertView.firstOtherButtonIndex){
            NSInteger tag = alertView.tag-2000;
            UITextField *countText = [alertView textFieldAtIndex:0];
            NSString *count = countText.text;
            SCOrderOutMat *inMat = self.selArray[tag];
            double qty = [count doubleValue];
            if(qty+inMat.hasQty>inMat.sourceQty){
                //数量过大
                [self.view makeToast:@"数量超过上限,请重新输入!" duration:3.0 position:CSToastPositionCenter];
            }else{
                inMat.qty = qty;
            }
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

/**
 *  确认入库,保存至数据库
 *
 *  @param sender
 */
- (void)confirmDealOut:(id)sender {
    if(self.consumer){
        double sum = 0;
        for(SCOrderOutMat *outMat in self.selArray){
            sum = sum + outMat.qty;
        }
        if(self.selArray.count==0 || sum==0){
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:@"尚未选择材料入库,请执行入库后再提交!"
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
        }else{
            //保存数据库
            // TODO 涉及到出入库的数量判断
            NSDate *now = [NSDate date];
            NSString *deliverNo = [NSString stringWithFormat:@"%@%@",[DateTool dateToString:now],[DateTool randomNumber]];
            
            
            
            //生成出库单主表
            mOut = [[SCOrderMOut alloc] init];
            
            mOut.id = self.order.id;
            mOut.OrderId = self.order.OrderId;
            mOut.number = self.order.number;
            mOut.date = self.order.date;
            mOut.supplier = self.order.supplier;
            mOut.materialDesc = self.order.materialDesc;
            mOut.Addr = self.order.Addr;
            mOut.ProjectName= self.order.ProjectName;
            mOut.Company = self.order.Company;
            
            mOut.gid = [UUIDUtil getUUID];
            mOut.time = now;
            mOut.deliverNo = deliverNo;
            mOut.consumerid = self.consumer.consumerid;
            mOut.consumerName = self.consumer.Name;
            [mOut saveOrUpdate];//保存直入直出单
            
            
            self.array = [[NSMutableArray alloc] init];
            for (int i = 0; i<self.selArray.count; i++) {
                SCOrderOutMat *outMat = self.selArray[i];
                outMat.hasQty = outMat.hasQty+outMat.qty;
                if(outMat.hasQty==outMat.sourceQty){
                    outMat.isFinish = 1;
                }
                [outMat saveOrUpdate];
                //生成入库单
                SCOut *scOut = [[SCOut alloc] init];
                scOut.time = now;
                scOut.deliverNo = deliverNo;
                scOut.deliverid = mOut.gid;
                scOut.receiveid = self.order.id;
                scOut.orderEntryid = outMat.orderentryid;
                scOut.qty = outMat.qty;
                scOut.wareentry = outMat.wareentry;
                [scOut saveOrUpdate];
                [self.array addObject:scOut];
            }
            int finish = 0;//判断单据是否结束:0,未结束  >0,已结束
            if(self.unSelArray.count>0){
                //未结束
                finish = 0;
            }else{
                for (int i = 0; i<self.selArray.count; i++) {
                    SCOrderOutMat *outMat = self.selArray[i];
                    if(outMat.isFinish==0){
                        finish++;
                    }
                }
            }
            if(finish==0){
                self.order.isFinish = 0;
            }else{
                self.order.isFinish = 1;
            }
            
            [self.order saveOrUpdate];
            //开始打印
            printContant=[NSString stringWithFormat:@"%@\n第%d次打印%@%@%@%@%@%@%@%@%@",
                          @"------------------------------",
                          (mOut.printcount+1),
                          @"\n出库单号:",deliverNo,
                          @"\n项目:",mOut.ProjectName,
                          @"\n领用商:",mOut.consumerName,
                          @"\n地产公司:",mOut.Company,
                          @"\n------------------------------"];
            for (int i = 0; i<self.selArray.count; i++) {
                SCOrderOutMat *outMat = self.selArray[i];
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
            printContant = [NSString stringWithFormat:@"%@%@%@%@",printContant,
                            @"\n收货人:__________________________",
                            @"\n                                ",
                            @"\n证明人:__________________________"];
            
            //准备好的打印字符串
            //--------------
            [uartLib scanStart];//scan
            NSLog(@"connect Peripheral");
            
            [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
            
            //返回首页
            NSArray *controllers = self.navigationController.viewControllers;
            for(UIViewController *viewController in controllers){
                if([viewController isKindOfClass:[OutDealViewController class]]){
                    [self.navigationController popToViewController:viewController animated:YES];
                }
            }
        }
    } else {
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
        for(SCOut *scout in self.array){
            scout.printcount ++;
            scout.isPrint = 1;
            [scout saveOrUpdate];
        }
        mOut.isPrint = 1;
        mOut.printcount ++;
        
        [mOut saveOrUpdate];
    }
    [uartLib scanStop];
    [uartLib disconnectPeripheral:connectPeripheral];
    
}

-(void)pass:(id)value {
    self.consumer = value;
    if(self.consumer){
        self.consumerLabel.text = self.consumer.Name;
    }
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

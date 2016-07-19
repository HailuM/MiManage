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
    
    
    SCOrderMDirout *mDirout;
    
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
        for(SCOrderInMat *inMat in self.selArray){
            sum = sum + inMat.qty;
        }
        self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu;总数量:%.2f",(unsigned long)self.selArray.count,sum];
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
    SCOrderInMat *inMat = self.selArray[indexPath.row];
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
    alert.tag = 2000+indexPath.row;
    SCOrderInMat *inMat = self.selArray[indexPath.row];
    
    UITextField *countText = [alert textFieldAtIndex:0];
    [countText setKeyboardType:UIKeyboardTypeDecimalPad];
    countText.text = [NSString stringWithFormat:@"%f",inMat.qty];
    [alert show];
}
-(void)delQty:(id)sender{
    UILabel *label = sender;
    NSInteger tag = label.tag-2000;
    SCOrderInMat *inMat = self.selArray[tag];
    if(inMat.qty-1<=0){
        inMat.qty = 0.0;
    }else{
        inMat.qty = inMat.qty-1;
    }
    [self.tableView reloadData];
}

-(void)addQty:(id)sender {
    UILabel *label = sender;
    NSInteger tag = label.tag-3000;
    SCOrderInMat *inMat = self.selArray[tag];
    if(inMat.qty+1>inMat.limitQty-inMat.hasQty){
        inMat.qty = inMat.limitQty-inMat.hasQty;
    }else{
        inMat.qty = inMat.qty+1;
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
    }else{
        if(buttonIndex==alertView.firstOtherButtonIndex){
            NSInteger tag = alertView.tag-2000;
            UITextField *countText = [alertView textFieldAtIndex:0];
            NSString *count = countText.text;
            SCOrderInMat *inMat = self.selArray[tag];
            double qty = [count doubleValue];

            if(qty+inMat.hasQty>inMat.sourceQty){
                [self.view makeToast:@"数量超过上限,请重新输入!" duration:3.0 position:CSToastPositionCenter];
            }else if(qty+inMat.hasQty<inMat.limitQty){
                [self.view makeToast:@"数量未达到订单最低限制!" duration:3.0 position:CSToastPositionCenter];
            }else{
                inMat.qty = qty;
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
        for(SCOrderInMat *inMat in self.selArray){
            sum = sum + inMat.qty;
        }
        if(self.selArray.count==0 || sum==0){
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:@"尚未选择材料入库,请执行入库后再提交!"
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
        }else if(self.unSelArray.count!=0){
            //保存数据库
            // TODO 涉及到出入库的数量判断
            self.array = [[NSMutableArray alloc] init];
            NSDate *now = [NSDate date];
            
            //直入直出单号
            NSString *deliverNo = [NSString stringWithFormat:@"%@%@",[DateTool dateToString:now],[DateTool randomNumber]];
            int finish = 0;//判断单据是否结束:0,已结束  >0,未结束
            for (int i = 0; i<self.selArray.count; i++) {
                PuOrderChild v *inMat = self.selArray[i];
                if(inMat.qty+inMat.hasQty>=inMat.sourceQty && inMat.qty+inMat.hasQty<=inMat.limitQty){
                    finish = 0;
                }else{
                    finish ++;
                }
            }
            //订单已结束
            if(finish==0){
                
                //生成直入直出单
                mDirout = [[SCOrderMDirout alloc] init];
                
                mDirout.id = self.order.id;
                mDirout.OrderId = self.order.OrderId;
                mDirout.number = self.order.number;
                mDirout.date = self.order.date;
                mDirout.supplier = self.order.supplier;
                mDirout.materialDesc = self.order.materialDesc;
                mDirout.Addr = self.order.Addr;
                mDirout.ProjectName= self.order.ProjectName;
                mDirout.Company = self.order.Company;
                
                mDirout.gid = [UUIDUtil getUUID];
                mDirout.time = now;
                mDirout.deliverNo = deliverNo;
                mDirout.consumerid = self.consumer.consumerid;
                mDirout.consumerName = self.consumer.Name;
                [mDirout saveOrUpdate];//保存直入直出单
                
                
                for (int i = 0; i<self.selArray.count; i++) {
                    SCOrderInMat *inMat = self.selArray[i];
                    //更新已处理数量
                    inMat.hasQty = inMat.qty+inMat.hasQty;
                    inMat.isFinish = 1;
                    [inMat saveOrUpdate];
                    //生成入库单
                    SCDirout *scDirout = [[SCDirout alloc] init];
                    scDirout.wareentry = inMat.wareentry;
                    scDirout.deliverNo = deliverNo;
                    scDirout.preparetime = now;
                    scDirout.consumerid = self.consumer.consumerid;
                    scDirout.zrzcid = mDirout.gid;
                    scDirout.orderid = inMat.orderid;
                    scDirout.orderEntryid = inMat.orderentryid;
                    scDirout.qty = inMat.qty;
                    [scDirout saveOrUpdate];
                    [self.array addObject:scDirout];
                }
                
                /**
                 *  设置订单只能直入直出
                 */
                self.order.isDirout = 1;
                self.order.isFinish = 1;
                [self.order saveOrUpdate];
                
                //开始打印
                printContant=[NSString stringWithFormat:@"%@\n第%d次打印%@%@%@%@%@%@%@%@%@",
                              @"------------------------------",
                              (mDirout.printcount+1),
                              @"\n出库单号:",deliverNo,
                              @"\n项目:",mDirout.ProjectName,
                              @"\n领用商:",mDirout.consumerName,
                              @"\n地产公司:",mDirout.Company,
                              @"\n------------------------------"];
                for (int i = 0; i<self.selArray.count; i++) {
                    SCOrderInMat *outMat = self.selArray[i];
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
                                @"\n收货人:_________________________",
                                @"\n证明人:_________________________"];
                
                //准备好的打印字符串
                //--------------
                [uartLib scanStart];//scan
                NSLog(@"connect Peripheral");
                
                [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
                
                
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
        for(SCOut *scout in self.array){
            scout.printcount ++;
            scout.isPrint = 1;
            [scout saveOrUpdate];
        }
        mDirout.printcount++;
        mDirout.isPrint = 1;
        
        [mDirout saveOrUpdate];
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

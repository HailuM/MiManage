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
#import "ImageToBase64.h"
#import "OrderImage.h"

@interface ConfirmOutViewController (){
    UIAlertView *connectAlertView;
    UartLib *uartLib;
    CBPeripheral *connectPeripheral;
    NSString *printContant;
    
    OutBill *outBill;
    
    UIAlertView *printAlert;
    
    
    
    int timeCount;
//    UIAlertView *bleAlert;//提示未连接上蓝牙
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
    
//    bleAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法连接上蓝牙打印机，是否返回主界面？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    
    
    
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
//        double sum = 0;
//        for(PuOrderChild *outMat in self.selArray){
//            
//        }
        self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)self.selArray.count];
        //        [self initData];
        
        
        if(self.consumer){
            self.consumerLabel.text = self.consumer.Name;
        }
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
        if([self.order.type isEqualToString:@"rkck"]){
            viewController.orderid = self.order.sourceid;
        }else{
            viewController.orderid = self.order.OrderId;
        }
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
    PuOrderChild *outMat = self.selArray[indexPath.row];
    [cell showCell:outMat];
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
    countText.text = [StringUtil changeFloat:inMat.curQty];
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
    }else if(alertView == printAlert){
        if(buttonIndex==1){
            [uartLib scanStart];//scan
            NSLog(@"connect Peripheral");
            [self performSelector:@selector(searchPrinter) withObject:nil afterDelay:3];
        }else{
            NSArray *controllers = self.navigationController.viewControllers;
            for(UIViewController *viewController in controllers){
                if([viewController isKindOfClass:[MainViewController class]]){
                    [self.navigationController popToViewController:viewController animated:YES];
                }
            }
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
    else{
        if(buttonIndex==alertView.firstOtherButtonIndex){
            NSInteger tag = alertView.tag-4000;
            UITextField *countText = [alertView textFieldAtIndex:0];
            NSString *count = countText.text;
            PuOrderChild *inMat = self.selArray[tag];
            double qty = [count doubleValue];
            double limit = 0;
            //获取最终上限
            if([inMat.limitQty doubleValue]<=0)
            {
                limit = [inMat.sourceQty doubleValue];
            } else {
                limit = [inMat.limitQty doubleValue];
            }
            double cur = [inMat.curQty doubleValue];
            double source = [inMat.sourceQty doubleValue];
            double ck = [inMat.ckQty doubleValue];
            
            if(qty==0){
                //如果用户输入无效的字符串或者0
                cur = 0;
            }else{
                if(qty+ck>source){
                    //数量过大
                    cur = source-ck;
                    [self.view makeToast:@"数量超过上限!" duration:3.0 position:CSToastPositionCenter];
                }else{
                    cur = qty;
                }
            }
            
            inMat.curQty = [NSString stringWithFormat:@"%f",cur];
            
            [self.tableView reloadData];
        }
    }
    
}

-(void)delQty:(id)sender{
    UILabel *label = sender;
    NSInteger tag = label.tag-2000;
    PuOrderChild *outMat = self.selArray[tag];
    
    
    double limit = 0;
    //获取最终上限
    if([outMat.limitQty doubleValue]<=0)
    {
        limit = [outMat.sourceQty doubleValue];
    } else {
        limit = [outMat.limitQty doubleValue];
    }
    double cur = [outMat.curQty doubleValue];
    //    double source = [inMat.sourceQty doubleValue];
    //    double ck = [outMat.ckQty doubleValue];
    
    
    
    if(cur-1<=0){
        cur = 0.0;
    }else{
        cur = cur-1;
    }
    outMat.curQty = [NSString stringWithFormat:@"%f",cur];
    [self.tableView reloadData];
}

-(void)addQty:(id)sender {
    UILabel *label = sender;
    NSInteger tag = label.tag-3000;
    PuOrderChild *outMat = self.selArray[tag];
    
    double limit = 0;
    //获取最终上限
    if([outMat.limitQty doubleValue]<=0)
    {
        limit = [outMat.sourceQty doubleValue];
    } else {
        limit = [outMat.limitQty doubleValue];
    }
    double cur = [outMat.curQty doubleValue];
    double source = [outMat.sourceQty doubleValue];
    double ck = [outMat.ckQty doubleValue];
    
    
    
    if(cur+1>source-ck){
        cur = source-ck;
    }else{
        cur = cur+1;
    }
    outMat.curQty = [NSString stringWithFormat:@"%f",cur];
    [self.tableView reloadData];
}

-(void)delToCheck:(id)sender {
    UIButton *btn = sender;
    NSInteger position = btn.tag - 1000;
    [self.unSelArray addObject:self.selArray[position]];
    [self.selArray removeObjectAtIndex:position];
    [self.tableView reloadData];
    self.checkedNumLabel.text = [NSString stringWithFormat:@"已选品种:%lu",(unsigned long)self.selArray.count];
}

/**
 *  确认入库,保存至数据库
 *
 *  @param sender
 */
- (void)confirmDealOut:(id)sender {
    if(self.consumer){
        double sum = 0;
        for(PuOrderChild *outMat in self.selArray){
            sum = sum + [outMat.curQty doubleValue];
        }
        if(self.selArray.count==0 || sum==0){
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示！"
                                                          message:@"请先选择物料信息!"
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
            [alert show];//提示框的显示 必须写 不然没有任何反映
        }else{
            //保存数据库
            
            [self saveOrder];
            
            
            
            [self preparePrintString];

            
            
//            //返回首页
//            NSArray *controllers = self.navigationController.viewControllers;
//            for(UIViewController *viewController in controllers){
//                if([viewController isKindOfClass:[MainViewController class]]){
//                    [self.navigationController popToViewController:viewController animated:YES];
//                }
//            }
        }
    } else {
        [self.view makeToast:@"请选择领料商!" duration:3.0 position:CSToastPositionCenter];
    }
    
}

-(void) preparePrintString {
    //不上传图片
    //打印数据
    //开始打印
    printContant=[NSString stringWithFormat:@"%@\n打印次数:%d%@%@%@%@%@%@%@%@%@",
                  @"------------------------------",
                  (outBill.printcount+1),
                  @"\n出库单号:",outBill.deliverNo,
                  @"\n项目:",outBill.ProjectName,
                  @"\n领用商:",outBill.consumername,
                  @"\n地产公司:",outBill.Company,
                  @"\n------------------------------"];
    for (int i = 0; i<self.array.count; i++) {
        OutBillChild *outMat = self.array[i];
        NSString *matString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@\n",
                               @"\n材料名称:",outMat.Name,
                               @"\n品牌:",outMat.brand,
                               @"\n规格型号:",outMat.model,
                               @"\n数量:",[StringUtil changeFloat:outMat.qty],
                               @"\n备注:",outMat.note];
        printContant = [printContant stringByAppendingString:matString];
    }
    printContant = [NSString stringWithFormat:@"%@%@%@%@%@%@",printContant,
                    @"\n领用人:________________________",
                    @"\n  ",
                    @"\n施工单位:_____________________",
                    @"\n",
                    @"\n证明人(监理):________________________"];
    
    //准备好的打印字符串
    //--------------
    printAlert = [[UIAlertView alloc] initWithTitle:@"打印预览" message:printContant delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"打印", nil];
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


-(void)saveOrder{
    // TODO 涉及到出入库的数量判断
    NSDate *now = [NSDate date];

    //生成出库单主表
    outBill = [[OutBill alloc] init];
    
    outBill.gid = [UUIDUtil getUUID];
    outBill.orderid = self.order.id;
    outBill.preparertime = [DateTool datetimeToString:now];
    outBill.deliverNo = [StringUtil generateNo:@"SCCK"];
    outBill.consumerid = self.consumer.consumerid;
    outBill.consumername = self.consumer.Name;
    outBill.printcount = 0;
    // TODO
    outBill.receiveid = self.order.id;
    outBill.receiverOID = self.consumer.receiverOID;
    
    outBill.supplier = self.order.supplier;
    outBill.materialDesc = self.order.materialDesc;
    outBill.Addr = self.order.Addr;
    outBill.ProjectName= self.order.ProjectName;
    outBill.Company = self.order.Company;
    outBill.type = self.order.type;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [outBill saveOrUpdate];//保存出库单主表
    });
    
    
    self.array = [[NSMutableArray alloc] init];
    for (int i = 0; i<self.selArray.count; i++) {
        PuOrderChild *outMat = self.selArray[i];
        outMat.ckQty = [NSString stringWithFormat:@"%f",[outMat.ckQty doubleValue]+[outMat.curQty doubleValue]];
        if([outMat.ckQty doubleValue]==[outMat.sourceQty doubleValue]){
            outMat.isFinish = 1;
        }
        
        //生成出库单子表
        OutBillChild *outChild = [[OutBillChild alloc] init];
        outChild.outgid = outBill.gid;//出库单子表关联的主表id
        
        outChild.xsxh = outMat.xsxh;
        outChild.preparertime = outBill.preparertime;
        outChild.deliverNo = outBill.deliverNo;
//        outChild.deliverid = [UUIDUtil getUUID];
        outChild.deliverid = outBill.gid;
        
        
        outChild.consumerid = self.consumer.consumerid;
        outChild.orderEntryid = outMat.orderentryid;
        outChild.printcount = 0;
        outChild.qty = outMat.curQty;
        // TODO
        //                outChild.receiveid = outBill.receiveid;//确认来源
        outChild.receiveid = outMat.sourcecid;
        if(!outMat.sourcecid || outMat.sourcecid.length==0){
            outChild.receiveid = self.order.id;
        }
        outChild.type = self.order.type;
        outChild.orderid = self.order.sourceid;
        outChild.receiverOID = self.consumer.receiverOID;
        
        //目前未知
        outChild.wareid = outMat.orderid;
        
        
        
        
        outChild.wareentryid = outMat.wareentryid;
        outChild.Name = outMat.Name;
        outChild.model = outMat.model;
        outChild.unit = outMat.unit;
        outChild.brand = outMat.brand;
        outChild.note = outMat.note;
        outChild.price = outMat.price;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [outChild saveOrUpdate];
        });
        [self.array addObject:outChild];
        outMat.curQty = 0;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [outMat saveOrUpdate];
        });
    }
    int finish = 0;//判断单据是否结束:0,未结束  >0,已结束
    if(self.unSelArray.count>0){
        //未结束
        finish = 1;
    }else{
        for (int i = 0; i<self.array.count; i++) {
            PuOrderChild *outMat = self.selArray[i];
            if(outMat.isFinish==0){
                finish++;
            }
        }
    }
    if(finish>0){
        self.order.isFinish = 0;
    }else{
        self.order.isFinish = 1;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.order saveOrUpdate];
    });
}

#pragma mark - IBActionSheet delegate
-(void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == sheet.cancelButtonIndex){
        
        //todo
        //取消拍照或者选择图片
        //返回首页
        NSArray *controllers = self.navigationController.viewControllers;
        for(UIViewController *viewController in controllers){
            if([viewController isKindOfClass:[MainViewController class]]){
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
        
    }
    if(buttonIndex == 0){
        //拍照
        
        SCCNavigationController *nav = [[SCCNavigationController alloc] init];
        nav.scNaigationDelegate = self;
        [nav showCameraWithParentController:self];
        
    }else if(buttonIndex == 1){
        //从手机相册选择
        
        DoImagePickerController *cont = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
        cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
        cont.delegate = self;
        cont.nMaxCount = -1;
        cont.nColumnCount = 3;
        [self presentViewController:cont animated:YES completion:nil];
    }
}

#pragma mark - SCNavigationController delegate
//拍照委托
- (void)didTakePicture:(SCCNavigationController *)navigationController image:(UIImage *)image {
    [navigationController dismissModalViewControllerAnimated:YES];
    //将图片转成字符串保存到数据库
    NSString *imageData = [ImageToBase64 imageWithNoCompressToBase64:image];
    OrderImage *orderImage = [[OrderImage alloc] init];
    orderImage.orderId = outBill.gid;
    if([self.order.type isEqualToString:@"ck"]){
        orderImage.flag= @"ck";
    }else{
        orderImage.flag= @"rk";
    }

    orderImage.type= @"ck";
    orderImage.imageData = imageData;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [orderImage saveOrUpdate];
    });
}

-(BOOL)willDismissNavigationController:(SCCNavigationController *)navigatonController {
    if(sheet){
        [sheet showInView:self.view];
    }else{
        //弹出alert是否继续拍照
        sheet = [[IBActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
        [sheet setFont:[UIFont systemFontOfSize:15.f]];
        [sheet setButtonTextColor:[UIColor blackColor]];
        [sheet setButtonBackgroundColor:[UIColor whiteColor]];
        [sheet showInView:self.view];
    }
    return YES;
}

#pragma mark - DoImagePickerControllerDelegate
//选择照片的委托
- (void)didCancelDoImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)aSelected
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (picker.nResultType == DO_PICKER_RESULT_UIIMAGE)
    {
        if(aSelected && aSelected.count >0){
            
            for(UIImage *image in aSelected){
                NSString *imageData = [ImageToBase64 imageWithNoCompressToBase64:image];
                OrderImage *orderImage = [[OrderImage alloc] init];
                orderImage.orderId = outBill.gid;
                orderImage.orderId = outBill.gid;
                if([self.order.type isEqualToString:@"ck"]){
                    orderImage.flag= @"ck";
                }else{
                    orderImage.flag= @"rk";
                }
                
                orderImage.type= @"ck";
                
                orderImage.imageData = imageData;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [orderImage saveOrUpdate];
                });
            }
        }
    }
}


//-------
-(void)searchPrinter{
    if(connectPeripheral ==nil){
        
        [self.view makeToast:@"蓝牙搜索中......"];
        if(timeCount>10){
            //提示，未连接上蓝牙，是否返回主页面
//            [bleAlert show];
            [self.view makeToast:@"无法连接上蓝牙"];
            //停止扫描
            @try{
                [uartLib scanStop];
                [uartLib disconnectPeripheral:connectPeripheral];
            } @catch (NSException *exception) {
                NSLog(@"蓝牙停止扫描,出现%@",exception);
            } @finally {
                
            }
            //主线程延迟5秒
            [self performSelector:@selector(delayMethod) withObject:nil afterDelay:5.0f];
//            //返回首页
//            NSArray *controllers = self.navigationController.viewControllers;
//            for(UIViewController *viewController in controllers){
//                if([viewController isKindOfClass:[MainViewController class]]){
//                    [self.navigationController popToViewController:viewController animated:YES];
//                }
//            }
            
            
            
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
        if(hasPaper==0){
            NSString *printed = [curPrintContent stringByAppendingFormat:@"%c%c%c", '\n', '\n', '\n'];
            
            [self PrintWithFormat:printed];
            outBill.printcount ++;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [outBill saveOrUpdate];
            });
            for(OutBillChild *childPrint in self.array){
                childPrint.printcount ++;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [childPrint saveOrUpdate];
                });
            }
        }else{
            [self.view makeToast:@"打印机缺纸!" duration:3.0 position:CSToastPositionCenter];
        }
        // TODO 2016/10/08 修改,打印完成后选择上传图片
        
        sheet = [[IBActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
        [sheet setFont:[UIFont systemFontOfSize:15.f]];
        [sheet setButtonTextColor:[UIColor blackColor]];
        [sheet setButtonBackgroundColor:[UIColor whiteColor]];
        [sheet showInView:self.view];
        
        
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
            hasPaper = 1;
            NSLog(@"缺纸");
        }else{
            hasPaper = 0;
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

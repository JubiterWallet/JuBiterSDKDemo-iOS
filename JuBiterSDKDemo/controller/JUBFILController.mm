//
//  JUBFILController.m
//  JuBiterSDKDemo
//
//  Created by Administrator on 2021/1/26.
//  Copyright © 2021 pengshanshan. All rights reserved.
//

#import "JUBFILController.h"
#import "JUBFILAmount.h"
@interface JUBFILController ()

@end

@implementation JUBFILController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"FIL options";
    self.optItem = JUB_NS_ENUM_MAIN::OPT_FIL;
}
- (NSArray*) subMenu {
    
    return @[
        BUTTON_TITLE_FIL
    ];
}

#pragma mark - 通讯库寻卡回调
- (void) CoinFILOpt:(NSUInteger)deviceID {
    
    const char* json_file = JSON_FILE_FIL;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", json_file]
                                                         ofType:@"json"];
    Json::Value root = readJSON([filePath UTF8String]);
    
    [self FIL_test:deviceID
              root:root
            choice:(int)self.optIndex];
}


#pragma mark - FIL applet
- (void) FIL_test:(NSUInteger)deviceID
             root:(Json::Value)root
           choice:(int)choice {
    
    JUB_RV rv = JUBR_ERROR;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    try {
        JUB_UINT16 contextID = [sharedData currContextID];
        if (0 != contextID) {
            [sharedData setCurrMainPath:nil];
            [sharedData setCurrCoinType:-1];
            rv = [g_sdk clearContext:contextID];
            if (JUBR_OK != rv) {
                [self addMsgData:[NSString stringWithFormat:@"[JUB_ClearContext() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            }
            else {
                [self addMsgData:[NSString stringWithFormat:@"[JUB_ClearContext() OK.]"]];
            }
            [sharedData setCurrContextID:0];
        }
        
        CommonProtosContextCfg * cfg = [[CommonProtosContextCfg alloc]init];
        cfg.mainPath = [NSString stringWithCString:root["main_path"].asCString() encoding:NSUTF8StringEncoding];
        
        CommonProtosResultInt * rvInt = [g_sdk createContextFIL:cfg deviceID:deviceID];
        rv = rvInt.stateCode;
        
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextFIL() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        contextID = rvInt.value;
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextFIL() OK.]"]];
        [sharedData setCurrMainPath:[NSString stringWithFormat:@"%@", cfg.mainPath]];
        [sharedData setCurrContextID:contextID];
        
        [self CoinOpt:contextID
                 root:root
               choice:choice];
    }
    catch (...) {
        error_exit("[Error format json file.]\n");
        [self addMsgData:[NSString stringWithFormat:@"[Error format json file.]"]];
    }
}

- (NSUInteger) set_my_address_proc:(NSUInteger)contextID {
    
    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return rv;
    }

    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change       = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
    JUB_CHAR_PTR address = nullptr;
//    rv = JUB_SetMyAddressFIL(contextID, path, &address);
    rvStr = [g_sdk setMyAddressFIL:contextID pbPath:path];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressFIL() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressFIL() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Set my address(%@/%u/%llu) is: %s.", [sharedData currMainPath], path.change, path.addressIndex, address]];
    
    return rv;
}

- (void) get_address_pubkey:(NSUInteger)contextID {
    
    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    char* pubkey = nullptr;
    rvStr = [g_sdk getMainHDNodeFIL:contextID pbFormat:CommonProtosENUM_PUB_FORMAT_Hex];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeFIL() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    pubkey = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeFIL() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"MainXpub(%@) in hex format: %s.", [sharedData currMainPath], pubkey]];

    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
    pubkey = nullptr;
    rvStr = [g_sdk getHDNodeFIL:contextID pbFormat:CommonProtosENUM_PUB_FORMAT_Hex pbPath:path];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetFILDNodeFIL() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    pubkey = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetFILDNodeFIL() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"pubkey(%@/%d/%llu) in hex format: %s.", [sharedData currMainPath], path.change, path.addressIndex, pubkey]];

    pubkey = nullptr;
    char* address = nullptr;
    rvStr = [g_sdk getAddressFIL:contextID pbPath:path bShow:NO];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressFIL() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressFIL() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"address(%@/%d/%llu): %s.", [sharedData currMainPath], path.change, path.addressIndex, address]];
}

- (void) show_address_test:(NSUInteger)contextID {
    
    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
    JUB_CHAR_PTR address;

    rvStr = [g_sdk getAddressFIL:contextID pbPath:path bShow:YES];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressFIL() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressFIL() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%d/%llu) is: %s.", [sharedData currMainPath], path.change, path.addressIndex, address]];
}

- (NSString*) inputAmount {
    
    __block
    NSString *amount;
    
    __block
    BOOL isDone = NO;
    JUBCustomInputAlert *customInputAlert = [JUBCustomInputAlert showCallBack:^(
        NSString * _Nonnull content,
        JUBDissAlertCallBack _Nonnull dissAlertCallBack,
        JUBSetErrorCallBack  _Nonnull setErrorCallBack
    ) {
        NSLog(@"content = %@", content);
        if (nil == content) {
            isDone = YES;
            dissAlertCallBack();
        }
        else if (        [content isEqual:@""]
                 || [JUBFILAmount isValid:content]
                 ) {
            //隐藏弹框
            amount = content;
            isDone = YES;
            dissAlertCallBack();
        }
        else {
            setErrorCallBack([JUBFILAmount formatRules]);
            isDone = NO;
        }
    } keyboardType:UIKeyboardTypeDecimalPad];
    customInputAlert.title = [JUBFILAmount title:(JUB_NS_ENUM_FIL_COIN)self.selectedMenuIndex];
    customInputAlert.message = [JUBFILAmount message];
    customInputAlert.textFieldPlaceholder = [JUBFILAmount formatRules];
    customInputAlert.limitLength = [JUBFILAmount limitLength];
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    // Convert to the smallest unit
    return [JUBFILAmount convertToProperFormat:amount
                                           opt:(JUB_NS_ENUM_FIL_COIN)self.selectedMenuIndex];
}


- (NSUInteger) tx_proc:(NSUInteger)contextID
                amount:(NSString*)amount
                  root:(Json::Value)root {
    
    JUB_RV rv = JUBR_ERROR;
    
    switch(self.selectedMenuIndex) {
        case JUB_NS_ENUM_FIL_COIN::BTN_FIL:
            rv = [self transaction_proc:contextID amount:amount root:root];
            break;
        default:
            
            break;
    }   // switch(self.selectedMenuIndex) end
    
    return rv;
}


- (NSUInteger) transaction_proc:(NSUInteger)contextID
                         amount:(NSString*)amount
                           root:(Json::Value)root {
    
    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
    
    
    FilecoinProtosTransactionFIL * transactionFil = [[FilecoinProtosTransactionFIL alloc]init];
    transactionFil.path.change = root["FIL"]["bip32_path"]["change"].asBool();
    transactionFil.path.addressIndex = root["FIL"]["bip32_path"]["addressIndex"].asUInt();
    
    transactionFil.nonce = root["FIL"]["nonce"].asUInt();
    transactionFil.gasLimit = root["FIL"]["gasLimit"].asUInt();
    
    transactionFil.gasFeeCapInAtto = [NSString stringWithCString:root["FIL"]["gasFeeCapInAtto"].asCString() encoding:NSUTF8StringEncoding];
    transactionFil.gasPremiumInAtto = [NSString stringWithCString:root["FIL"]["gasPremiumInAtto"].asCString() encoding:NSUTF8StringEncoding];

    transactionFil.valueInAtto = [NSString stringWithCString:root["FIL"]["valueInAtto"].asCString() encoding:NSUTF8StringEncoding];
    if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
        transactionFil.valueInAtto = amount;
    }
    transactionFil.to = [NSString stringWithCString:root["FIL"]["to"].asCString() encoding:NSUTF8StringEncoding];
    transactionFil.input = [NSString stringWithCString:root["FIL"]["data"].asCString() encoding:NSUTF8StringEncoding];
    
    char* raw = nullptr;
    
    rvStr = [g_sdk signTransactionFIL:contextID pbTx:transactionFil];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionFIL() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionFIL() OK.]"]];
    raw = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    if (raw) {
        size_t txLen = strlen(raw)/2;
        [self addMsgData:[NSString stringWithFormat:@"tx raw[%lu]: %s.", txLen, raw]];
    
    }
    
    return rv;
}

@end

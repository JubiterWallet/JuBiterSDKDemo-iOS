//
//  JUBXRPController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/5/12.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"

#import "JUBXRPController.h"
#import "JUBXRPAmount.h"

@interface JUBXRPController ()

@end


@implementation JUBXRPController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"XRP options";
    
    self.optItem = JUB_NS_ENUM_MAIN::OPT_XRP;
}


- (NSArray*) subMenu {
    
    return @[
        BUTTON_TITLE_XRP
    ];
}


#pragma mark - 通讯库寻卡回调
- (void) CoinXRPOpt:(NSUInteger)deviceID {
    
    const char* json_file = JSON_FILE_XRP;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", json_file]
                                                         ofType:@"json"];
    Json::Value root = readJSON([filePath UTF8String]);
    
    [self XRP_test:deviceID
              root:root
            choice:(int)self.optIndex];
}


#pragma mark - XRP applet
- (void) XRP_test:(NSUInteger)deviceID
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
//            rv = JUB_ClearContext(contextID);
            rv = [g_sdk clearContext:contextID];
            if (JUBR_OK != rv) {
                [self addMsgData:[NSString stringWithFormat:@"[JUB_ClearContext() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            }
            else {
                [self addMsgData:[NSString stringWithFormat:@"[JUB_ClearContext() OK.]"]];
            }
            [sharedData setCurrContextID:0];
        }
        
//        CONTEXT_CONFIG_XRP cfg;
//        cfg.mainPath = (char*)root["main_path"].asCString();
        
        CommonProtosContextCfg * cfg = [[CommonProtosContextCfg alloc]init];
        cfg.mainPath = [NSString stringWithCString:root["main_path"].asCString() encoding:NSUTF8StringEncoding];
        
//        rv = JUB_CreateContextXRP(cfg, deviceID, &contextID);
        CommonProtosResultInt * rvInt = [g_sdk createContextXRP:cfg deviceID:deviceID];
        rv = rvInt.stateCode;
        
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        contextID = rvInt.value;
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextXRP() OK.]"]];
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


- (void) get_address_pubkey:(NSUInteger)contextID {
    
    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    JUB_CHAR_PTR mainXpub;
//    rv = JUB_GetMainHDNodeXRP(contextID, JUB_ENUM_PUB_FORMAT::HEX, &mainXpub);
    
    rvStr = [g_sdk getMainHDNodeXRP:contextID pbFormat:CommonProtosENUM_PUB_FORMAT_Hex];
    rv = rvStr.stateCode;
    
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    mainXpub = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeXRP() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"Main xpub(%@): %s.", [sharedData currMainPath], mainXpub]];
//    rv = JUB_FreeMemory(mainXpub);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
    
//    BIP44_Path path;
//    path.change       = [sharedData currPath].change;
//    path.addressIndex = [sharedData currPath].addressIndex;

    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change       = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
    JUB_CHAR_PTR xpub;
//    rv = JUB_GetHDNodeXRP(contextID, JUB_ENUM_PUB_FORMAT::HEX, path, &xpub);
    rvStr = [g_sdk getHDNodeXRP:contextID pbFormat:CommonProtosENUM_PUB_FORMAT_Hex pbPath:path];
    rv = rvStr.stateCode;
    
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    xpub = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeXRP() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"input xpub(%@/%u/%llu): %s.", [sharedData currMainPath], path.change, path.addressIndex, xpub]];
//    rv = JUB_FreeMemory(xpub);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
//
    JUB_CHAR_PTR address;
//    rv = JUB_GetAddressXRP(contextID, path, BOOL_FALSE, &address);
    rvStr = [g_sdk getAddressXRP:contextID pbPath:path bShow:NO];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressXRP() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"input address(%@/%d/%llu): %s.", [sharedData currMainPath], path.change, path.addressIndex, address]];
//    rv = JUB_FreeMemory(address);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
}


- (void) show_address_test:(NSUInteger)contextID {
    
    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr= [[CommonProtosResultString alloc]init];
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
//    BIP44_Path path;
//    path.change       = [sharedData currPath].change;
//    path.addressIndex = [sharedData currPath].addressIndex;
    
    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change       = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
    JUB_CHAR_PTR address;
//    rv = JUB_GetAddressXRP(contextID, path, BOOL_TRUE, &address);
    rvStr = [g_sdk getAddressXRP:contextID pbPath:path bShow:YES];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressXRP() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%d/%llu) is: %s.", [sharedData currMainPath], path.change, path.addressIndex, address]];
    
//    rv = JUB_FreeMemory(address);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
}


- (NSUInteger) set_my_address_proc:(NSUInteger)contextID {
    
    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return rv;
    }
    
//    BIP44_Path path;
//    path.change       = [sharedData currPath].change;
//    path.addressIndex = [sharedData currPath].addressIndex;
    
    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change       = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
    JUB_CHAR_PTR address = nullptr;
//    rv = JUB_SetMyAddressXRP(contextID, path, &address);
    rvStr = [g_sdk setMyAddressXRP:contextID pbPath:path];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressXRP() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"set my address is: %s.", address]];
//    rv = JUB_FreeMemory(address);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return rv;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
    
    return rv;
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
                 || [JUBXRPAmount isValid:content]
                 ) {
            //隐藏弹框
            amount = content;
            isDone = YES;
            dissAlertCallBack();
        }
        else {
            setErrorCallBack([JUBXRPAmount formatRules]);
            isDone = NO;
        }
    } keyboardType:UIKeyboardTypeDecimalPad];
    customInputAlert.title = [JUBXRPAmount title:JUB_NS_ENUM_XRP_COIN::BTN_XRP];
    customInputAlert.message = [JUBXRPAmount message];
    customInputAlert.textFieldPlaceholder = [JUBXRPAmount formatRules];
    customInputAlert.limitLength = [JUBXRPAmount limitLength];
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    // Convert to the smallest unit
    return [JUBXRPAmount convertToProperFormat:amount
                                           opt:JUB_NS_ENUM_XRP_COIN::BTN_XRP];
}


- (NSUInteger) tx_proc:(NSUInteger)contextID
                amount:(NSString*)amount
                  root:(Json::Value)root {
    
    NSUInteger rv = JUBR_ERROR;
    
    switch(self.selectedMenuIndex) {
    default:
        rv = [self transaction_proc:contextID
                             amount:amount
                               root:root];
        break;
    }   // switch(self.selectedMenuIndex) end
    
    return rv;
}


- (NSUInteger) transaction_proc:(NSUInteger)contextID
                         amount:(NSString*)amount
                           root:(Json::Value)root {
    
    JUB_RV rv = JUBR_ERROR;
    RippleProtosTransactionXRP * xrp = [[RippleProtosTransactionXRP alloc]init];
//    BIP44_Path path;
//    path.change = (JUB_ENUM_BOOL)root["XRP"]["bip32_path"]["change"].asBool();
//    path.addressIndex = root["XRP"]["bip32_path"]["addressIndex"].asUInt();
    
    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change = (JUB_ENUM_BOOL)root["XRP"]["bip32_path"]["change"].asBool();
    path.addressIndex = root["XRP"]["bip32_path"]["addressIndex"].asUInt();
    
//    JUB_TX_XRP xrp;
//    xrp.type = (JUB_ENUM_XRP_TX_TYPE)root["XRP"]["type"].asUInt();
//    xrp.memo.type   = (char*)root["XRP"]["memo"]["type"].asCString();
//    xrp.memo.data   = (char*)root["XRP"]["memo"]["data"].asCString();
//    xrp.memo.format = (char*)root["XRP"]["memo"]["format"].asCString();
    
    xrp.type = (RippleProtosENUM_XRP_TX_TYPE)root["XRP"]["type"].asUInt();
    xrp.memo.type = [NSString stringWithCString:root["XRP"]["memo"]["type"].asCString() encoding:NSUTF8StringEncoding];
    xrp.memo.data_p = [NSString stringWithCString:root["XRP"]["memo"]["data"].asCString() encoding:NSUTF8StringEncoding];
    xrp.memo.format = [NSString stringWithCString:root["XRP"]["memo"]["format"].asCString() encoding:NSUTF8StringEncoding];
    
    switch (xrp.type/**xrp.type*/) {
    case RippleProtosENUM_XRP_TX_TYPE_Pymt: //JUB_ENUM_XRP_TX_TYPE::PYMT:
    {
//        xrp.account  = (char*)root["XRP"]["account"].asCString();
//        xrp.fee      = (char*)root["XRP"]["fee"].asCString();
//        xrp.flags    = (char*)root["XRP"]["flags"].asCString();
//        xrp.sequence = (char*)root["XRP"]["sequence"].asCString();
//        xrp.lastLedgerSequence = (char*)root["XRP"]["lastLedgerSequence"].asCString();
        xrp.account = [NSString stringWithCString:root["XRP"]["account"].asCString() encoding:NSUTF8StringEncoding];
        xrp.fee = [NSString stringWithCString:root["XRP"]["fee"].asCString() encoding:NSUTF8StringEncoding];
        xrp.flags = [NSString stringWithCString:root["XRP"]["flags"].asCString() encoding:NSUTF8StringEncoding];
        xrp.sequence = [NSString stringWithCString:root["XRP"]["sequence"].asCString() encoding:NSUTF8StringEncoding];
        xrp.lastLedgerSequence = [NSString stringWithCString:root["XRP"]["lastLedgerSequence"].asCString() encoding:NSUTF8StringEncoding];
        break;
    }
    default:
        return JUBR_ARGUMENTS_BAD;
    }   // switch (xrp.type) end
    
    //typedef struct stPaymentXRP {
    //    JUB_ENUM_XRP_PYMT_TYPE type;
    //    JUB_PYMT_AMOUNT amount;
    //    JUB_CHAR_PTR destination;
    //    JUB_CHAR_PTR destinationTag;
    //    JUB_CHAR_PTR invoiceID;     // [Optional]
    //    JUB_PYMT_AMOUNT sendMax;    // [Optional]
    //    JUB_PYMT_AMOUNT deliverMin; // [Optional]
    //} JUB_PYMT_XRP;
    std::string strType = std::to_string((unsigned int)xrp.type);
    char* sType = new char[strType.length()+1];
    std::memset(sType, 0x00, strType.length()+1);
    std::copy(strType.begin(), strType.end(), sType);
//    xrp.pymt.type = (JUB_ENUM_XRP_PYMT_TYPE)root["XRP"][sType]["type"].asUInt();
    xrp.pymt.type = (RippleProtosENUM_XRP_PYMT_TYPE)root["XRP"][sType]["type"].asUInt();

    switch (xrp.pymt.type) {
    case RippleProtosENUM_XRP_PYMT_TYPE_Dxrp://JUB_ENUM_XRP_PYMT_TYPE::DXRP:
    {
//        xrp.pymt.destination    = (char*)root["XRP"][sType]["destination"].asCString();
//        xrp.pymt.amount.value   = (char*)root["XRP"][sType]["amount"]["value"].asCString();
//        if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
//            xrp.pymt.amount.value = (char*)[amount UTF8String];
//        }
//        xrp.pymt.destinationTag = (char*)root["XRP"][sType]["destinationTag"].asCString();
        xrp.pymt.destination = [NSString stringWithCString:root["XRP"][sType]["destination"].asCString() encoding:NSUTF8StringEncoding];
        xrp.pymt.amount.value = [NSString stringWithCString:root["XRP"][sType]["amount"]["value"].asCString() encoding:NSUTF8StringEncoding];
        if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
            xrp.pymt.amount.value = amount;
        }
        xrp.pymt.destinationTag = [NSString stringWithCString:root["XRP"][sType]["destinationTag"].asCString() encoding:NSUTF8StringEncoding];
        
        break;
    }
    default:
        return JUBR_ARGUMENTS_BAD;
    }   // switch (xrp.pymt.type) end
    char* raw = nullptr;
//    rv = JUB_SignTransactionXRP(contextID,
//                                path,
//                                xrp,
//                                &raw);
    CommonProtosResultString * rvStr = [g_sdk signTransactionXRP:contextID pbPath:path pbTx:xrp];
    if (sType) {
        delete[] sType; sType = nullptr;
    }
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionXRP() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionXRP() OK.]"]];
    raw = (char *)rvStr.value.UTF8String;
    if (raw) {
        size_t txLen = strlen(raw)/2;
        [self addMsgData:[NSString stringWithFormat:@"tx raw[%lu]: %s.", txLen, raw]];
        
//        rv = JUB_FreeMemory(raw);
//        if (JUBR_OK != rv) {
//            [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//            return rv;
//        }
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
    }
    
    return rv;
}


@end

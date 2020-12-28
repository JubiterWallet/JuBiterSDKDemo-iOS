//
//  JUBEOSController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/5/12.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"

#import "JUBEOSController.h"
#import "JUBEOSAmount.h"

@interface JUBEOSController ()

@end


@implementation JUBEOSController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"EOS options";
    
    self.optItem = JUB_NS_ENUM_MAIN::OPT_EOS;
}


- (NSArray*) subMenu {
    
    return @[
        BUTTON_TITLE_EOS,
        BUTTON_TITLE_EOSTOKEN,
        BUTTON_TITLE_EOSBUYRAM,
        BUTTON_TITLE_EOSSELLRAM,
        BUTTON_TITLE_EOSSTAKE,
        BUTTON_TITLE_EOSUNSTAKE,
    ];
}


#pragma mark - 通讯库寻卡回调
- (void) CoinEOSOpt:(NSUInteger)deviceID {
    
    const char* json_file = "";
    switch (self.selectedMenuIndex) {
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS:
    {
        json_file = JSON_FILE_EOS;
        break;
    }
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS_TOKEN:
    {
        json_file = JSON_FILE_EOS_TOKEN;
        break;
    }
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS_BUYRAM:
    {
        json_file = JSON_FILE_EOS_BUYRAM;
        break;
    }
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS_SELLRAM:
    {
        json_file = JSON_FILE_EOS_SELLRAM;
        break;
    }
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS_STAKE:
    {
        json_file = JSON_FILE_EOS_STAKE;
        break;
    }
    case JUB_NS_ENUM_EOS_OPT::BTN_EOS_UNSTAKE:
    {
        json_file = JSON_FILE_EOS_UNSTAKE;
        break;
    }
    default:
        break;
    }   // switch (self.selectedMenuIndex) end
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", json_file]
                                                         ofType:@"json"];
    Json::Value root = readJSON([filePath UTF8String]);
    
    [self EOS_test:deviceID
              root:root
            choice:(int)self.optIndex];
}


#pragma mark - EOS applet
- (void) EOS_test:(NSUInteger)deviceID
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
        
//        CONTEXT_CONFIG_EOS cfg;
//        cfg.mainPath = (char*)root["main_path"].asCString();
//        rv = JUB_CreateContextEOS(cfg, deviceID, &contextID);
        CommonProtosContextCfg * cfg = [[CommonProtosContextCfg alloc]init];
        cfg.mainPath = [NSString stringWithCString:root["main_path"].asCString() encoding:NSUTF8StringEncoding];
        CommonProtosResultInt * rvInt = [[CommonProtosResultInt alloc]init];
        rvInt = [g_sdk createContextEOS:cfg deviceID:deviceID];
        rv = rvInt.stateCode;
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        contextID = rvInt.value;
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextEOS() OK.]"]];
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
    
    char* pubkey = nullptr;
//    rv = JUB_GetMainHDNodeEOS(contextID, JUB_ENUM_PUB_FORMAT::HEX, &pubkey);
    rvStr = [g_sdk getMainHDNodeEOS:contextID pbFormat:CommonProtosENUM_PUB_FORMAT_Hex];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    pubkey = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeEOS() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"MainXpub(%@) in hex format: %s.", [sharedData currMainPath], pubkey]];
//    rv = JUB_FreeMemory(pubkey);
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
    
    pubkey = nullptr;
//    rv = JUB_GetHDNodeEOS(contextID, JUB_ENUM_PUB_FORMAT::HEX, path, &pubkey);
    rvStr = [g_sdk getHDNodeEOS:contextID pbFormat:CommonProtosENUM_PUB_FORMAT_Hex pbPath:path];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    pubkey = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeEOS() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"pubkey(%@/%d/%llu) in hex format: %s.", [sharedData currMainPath], path.change, path.addressIndex, pubkey]];
//    rv = JUB_FreeMemory(pubkey);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
    
    char* address = nullptr;
//    rv = JUB_GetAddressEOS(contextID, path, BOOL_FALSE, &address);
    rvStr = [g_sdk getAddressEOS:contextID pbPath:path bShow:NO];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressEOS() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"address(%@/%d/%llu): %s.", [sharedData currMainPath], path.change, path.addressIndex, address]];
//    rv = JUB_FreeMemory(address);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
}


- (void) show_address_test:(NSUInteger)contextID {
    
    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
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
//    rv = JUB_GetAddressEOS(contextID, path, BOOL_TRUE, &address);
    rvStr = [g_sdk getAddressEOS:contextID pbPath:path bShow:YES];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressEOS() OK.]"]];
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
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return rv;
    }
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];

//    BIP44_Path path;
//    path.change       = [sharedData currPath].change;
//    path.addressIndex = [sharedData currPath].addressIndex;
    
    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change       = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
    JUB_CHAR_PTR address = nullptr;
//    rv = JUB_SetMyAddressEOS(contextID, path, &address);
    rvStr = [g_sdk setMyAddressEOS:contextID pbPath:path];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetMyAddressEOS() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Set my address(%@/%u/%llu) is: %s.", [sharedData currMainPath], path.change, path.addressIndex, address]];
    
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
                 || [JUBEOSAmount isValid:content
                                      opt:(JUB_NS_ENUM_EOS_OPT)self.selectedMenuIndex]
                 ) {
            //隐藏弹框
            amount = content;
            isDone = YES;
            dissAlertCallBack();
        }
        else {
            setErrorCallBack([JUBEOSAmount formatRules:(JUB_NS_ENUM_EOS_OPT)self.selectedMenuIndex]);
            isDone = NO;
        }
    } keyboardType:UIKeyboardTypeDecimalPad];
    customInputAlert.title = [JUBEOSAmount title:(JUB_NS_ENUM_EOS_OPT)self.selectedMenuIndex];
    customInputAlert.message = [JUBEOSAmount message];
    customInputAlert.textFieldPlaceholder = [JUBEOSAmount formatRules:(JUB_NS_ENUM_EOS_OPT)self.selectedMenuIndex];
    customInputAlert.limitLength = [JUBEOSAmount limitLength];
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    return [JUBEOSAmount convertToProperFormat:amount
                                           opt:(JUB_NS_ENUM_EOS_OPT)self.selectedMenuIndex];
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
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
    EOSProtosActionListEOS * actionEos = [[EOSProtosActionListEOS alloc]init];
//    BIP44_Path path;
//    path.change = (JUB_ENUM_BOOL)root["EOS"]["bip32_path"]["change"].asBool();
//    path.addressIndex = root["EOS"]["bip32_path"]["addressIndex"].asUInt();
    
    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change = (JUB_ENUM_BOOL)root["EOS"]["bip32_path"]["change"].asBool();
    path.addressIndex = root["EOS"]["bip32_path"]["addressIndex"].asUInt();
    
    if (!root["EOS"]["actions"].isArray()) {
        return JUBR_ARGUMENTS_BAD;
    }
    
//    std::vector<JUB_ACTION_EOS> actions;
    actionEos.actionsArray = [[NSMutableArray alloc]init];
    //EOS Test
    for (Json::Value::iterator it = root["EOS"]["actions"].begin(); it != root["EOS"]["actions"].end(); ++it) {
//        JUB_ACTION_EOS action;
//        action.type = (JUB_ENUM_EOS_ACTION_TYPE)(*it)["type"].asUInt();
//        action.currency = (char*)(*it)["currency"].asCString();
//        action.name     = (char*)(*it)["name"].asCString();
        
        EOSProtosActionEOS * action = [[EOSProtosActionEOS alloc]init];
        action.type = (EOSProtosENUM_EOS_ACTION_TYPE)(*it)["type"].asUInt();
        action.currency = [NSString stringWithCString:(*it)["currency"].asCString() encoding:NSUTF8StringEncoding];
        action.name = [NSString stringWithCString:(*it)["name"].asCString() encoding:NSUTF8StringEncoding];
        
        std::string strType = std::to_string((unsigned int)action.type);
        char* sType = new char[strType.length()+1];
        memset(sType, 0x00, strType.length()+1);
        std::copy(strType.begin(), strType.end(), sType);
        
        switch (action.type) {
        case EOSProtosENUM_EOS_ACTION_TYPE_Xfer: //JUB_ENUM_EOS_ACTION_TYPE::XFER:
        {
//            action.transfer.from  = (char*)(*it)[sType]["from"].asCString();
//            action.transfer.to    = (char*)(*it)[sType]["to"].asCString();
//            action.transfer.asset = (char*)(*it)[sType]["asset"].asCString();
//            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
//                NSString* asset = [JUBEOSAmount replaceAmount:amount
//                                                        asset:[NSString stringWithFormat:@"%s", action.transfer.asset]];
//                action.transfer.asset = (char*)[asset UTF8String];
//            }
//            action.transfer.memo  = (char*)(*it)[sType]["memo"].asCString();
//
//            JUB_CHAR_PTR memoHash;
//            rv = JUB_CalculateMemoHash(action.transfer.memo, &memoHash);
//            if (JUBR_OK != rv) {
//                [self addMsgData:[NSString stringWithFormat:@"[JUB_CalculateMemoHash() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//                return rv;
//            }
//            [self addMsgData:[NSString stringWithFormat:@"[JUB_CalculateMemoHash() OK.]"]];
//            [self addMsgData:[NSString stringWithFormat:@"Memo Hash: %s.", memoHash]];
//            JUB_FreeMemory(memoHash);
            action.xferAction.from = [NSString stringWithCString:(*it)[sType]["from"].asCString() encoding:NSUTF8StringEncoding];
            action.xferAction.to = [NSString stringWithCString:(*it)[sType]["to"].asCString() encoding:NSUTF8StringEncoding];
            action.xferAction.asset = [NSString stringWithCString:(*it)[sType]["asset"].asCString() encoding:NSUTF8StringEncoding];
            
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
//                NSString* asset = [JUBEOSAmount replaceAmount:amount
//                                                        asset:[NSString stringWithFormat:@"%s", action.transfer.asset]];
//                action.transfer.asset = (char*)[asset UTF8String];
                NSString* asset = [JUBEOSAmount replaceAmount:amount asset:action.xferAction.asset];
                action.xferAction.asset = asset;
            }
//            action.transfer.memo  = (char*)(*it)[sType]["memo"].asCString();
            action.xferAction.memo = [NSString stringWithCString:(*it)[sType]["memo"].asCString() encoding:NSUTF8StringEncoding];
            
            JUB_CHAR_PTR memoHash;
            rvStr = [g_sdk calculateMemoHash:action.xferAction.memo];
            rv = rvStr.stateCode;
            if (JUBR_OK != rv) {
                [self addMsgData:[NSString stringWithFormat:@"[JUB_CalculateMemoHash() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
                return rv;
            }
            memoHash = (JUB_CHAR_PTR)rvStr.value.UTF8String;
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CalculateMemoHash() OK.]"]];
            [self addMsgData:[NSString stringWithFormat:@"Memo Hash: %s.", memoHash]];
            
            break;
        }
        case EOSProtosENUM_EOS_ACTION_TYPE_Dele://JUB_ENUM_EOS_ACTION_TYPE::DELE:
        {
//            action.delegate.from     = (char*)(*it)[sType]["from"].asCString();
//            action.delegate.receiver = (char*)(*it)[sType]["receiver"].asCString();
//            action.delegate.netQty   = (char*)(*it)[sType]["stake_net_quantity"].asCString();
//            action.delegate.cpuQty   = (char*)(*it)[sType]["stake_cpu_quantity"].asCString();
//            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
//                NSString* asset = [NSString stringWithFormat:@"%@ EOS", amount];
//                action.delegate.netQty = (char*)[asset UTF8String];
//                action.delegate.cpuQty = (char*)[asset UTF8String];
//            }
//            action.delegate.bStake = true;
            action.deleAction.from = [NSString stringWithCString:(*it)[sType]["from"].asCString() encoding:NSUTF8StringEncoding];
            action.deleAction.receiver = [NSString stringWithCString:(*it)[sType]["receiver"].asCString() encoding:NSUTF8StringEncoding];
            action.deleAction.netQty   = [NSString stringWithCString:(*it)[sType]["stake_net_quantity"].asCString() encoding:NSUTF8StringEncoding];
            action.deleAction.cpuQty   = [NSString stringWithCString:(*it)[sType]["stake_cpu_quantity"].asCString() encoding:NSUTF8StringEncoding];
            
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                NSString* asset = [NSString stringWithFormat:@"%@ EOS", amount];
                action.deleAction.netQty = asset;
                action.deleAction.cpuQty = asset;
            }
            action.deleAction.stake = YES;
            break;
        }
        case EOSProtosENUM_EOS_ACTION_TYPE_Undele://JUB_ENUM_EOS_ACTION_TYPE::UNDELE:
        {
//            action.delegate.from     = (char*)(*it)[sType]["from"].asCString();
//            action.delegate.receiver = (char*)(*it)[sType]["receiver"].asCString();
//            action.delegate.netQty   = (char*)(*it)[sType]["unstake_net_quantity"].asCString();
//            action.delegate.cpuQty   = (char*)(*it)[sType]["unstake_cpu_quantity"].asCString();
//            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
//                NSString* asset = [NSString stringWithFormat:@"%@ EOS", amount];
//                action.delegate.netQty = (char*)[asset UTF8String];
//                action.delegate.cpuQty = (char*)[asset UTF8String];
//            }
//            action.delegate.bStake = false;
            
            action.deleAction.from = [NSString stringWithCString:(*it)[sType]["from"].asCString() encoding:NSUTF8StringEncoding];
            action.deleAction.receiver = [NSString stringWithCString:(*it)[sType]["receiver"].asCString() encoding:NSUTF8StringEncoding];
            action.deleAction.netQty   = [NSString stringWithCString:(*it)[sType]["unstake_net_quantity"].asCString() encoding:NSUTF8StringEncoding];
            action.deleAction.cpuQty   = [NSString stringWithCString:(*it)[sType]["unstake_cpu_quantity"].asCString() encoding:NSUTF8StringEncoding];
            
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                NSString* asset = [NSString stringWithFormat:@"%@ EOS", amount];
                action.deleAction.netQty = asset;
                action.deleAction.cpuQty = asset;
            }
            action.deleAction.stake = false;
            
            break;
        }
        case EOSProtosENUM_EOS_ACTION_TYPE_Buyram://JUB_ENUM_EOS_ACTION_TYPE::BUYRAM:
        {
//            action.buyRam.payer    = (char*)(*it)[sType]["payer"].asCString();
//            action.buyRam.quant    = (char*)(*it)[sType]["quant"].asCString();
//            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
//                NSString* asset = [NSString stringWithFormat:@"%@ EOS", amount];
//                action.buyRam.quant = (char*)[asset UTF8String];
//            }
//            action.buyRam.receiver = (char*)(*it)[sType]["receiver"].asCString();
            action.buyRamAction.payer = [NSString stringWithCString:(*it)[sType]["payer"].asCString() encoding:NSUTF8StringEncoding];
            action.buyRamAction.quant = [NSString stringWithCString:(*it)[sType]["quant"].asCString() encoding:NSUTF8StringEncoding];
            
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                NSString* asset = [NSString stringWithFormat:@"%@ EOS", amount];
                action.buyRamAction.quant = asset;
            }
            
            action.buyRamAction.receiver = [NSString stringWithCString:(*it)[sType]["receiver"].asCString() encoding:NSUTF8StringEncoding];
            break;
        }
        case EOSProtosENUM_EOS_ACTION_TYPE_Sellram://JUB_ENUM_EOS_ACTION_TYPE::SELLRAM:
        {
//            action.sellRam.account = (char*)(*it)[sType]["account"].asCString();
//            action.sellRam.bytes   = (char*)(*it)[sType]["bytes"].asCString();
//            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
//                action.sellRam.bytes = (char*)[amount UTF8String];
//            }
            action.sellRamAction.account = [NSString stringWithCString:(*it)[sType]["account"].asCString() encoding:NSUTF8StringEncoding];
            action.sellRamAction.byte = [NSString stringWithCString:(*it)[sType]["bytes"].asCString() encoding:NSUTF8StringEncoding];
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                action.sellRamAction.byte = amount;
            }
            break;
        }
//        case JUB_ENUM_EOS_ACTION_TYPE::NS_ITEM_EOS_ACTION_TYPE:
        default:
            if (sType) {
                delete [] sType; sType = nullptr;
            }
            return JUBR_ARGUMENTS_BAD;
        }   // switch (action.type) end
//        actions.push_back(action);
        [actionEos.actionsArray addObject:action];
        if (sType) {
            delete [] sType; sType = nullptr;
        }
    }
//    size_t actionCnt = actions.size();
//    JUB_ACTION_EOS_PTR pActions = new JUB_ACTION_EOS[actionCnt*sizeof(JUB_ACTION_EOS)+1];
//    memset(pActions, 0x00, actionCnt*sizeof(JUB_ACTION_EOS)+1);
//    int i=0;
//    for (const JUB_ACTION_EOS& action:actions) {
//        pActions[i] = action;
//        ++i;
//    }
    
    JUB_CHAR_PTR actionsInJSON = nullptr;
//    rv = JUB_BuildActionEOS(contextID,
//                            pActions, actionCnt,
//                            &actionsInJSON);
    rvStr = [g_sdk buildActionEOS:contextID pbActionList:actionEos];
//    if (pActions) {
//        delete [] pActions; pActions = nullptr;
//    }
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildActionEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildActionEOS() OK.]"]];
    actionsInJSON = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    if (actionsInJSON) {
        [self addMsgData:[NSString stringWithFormat:@"action in JSON: %s.", actionsInJSON]];
    }
    
//    char* chainID    = (char*)root["EOS"]["chainID"].asCString();
//    char* expiration = (char*)root["EOS"]["expiration"].asCString();
//    char* referenceBlockId = (char*)root["EOS"]["referenceBlockId"].asCString();
//
    char* refBlockT = (char*)root["EOS"]["referenceBlockTime"].asCString();
    int yy, month, dd, hh, mm, ss;
    sscanf(refBlockT, "%d-%d-%d %d:%d:%d",
           &yy, &month, &dd,
           &hh, &mm, &ss);
    tm refblocktime;
    refblocktime.tm_year = yy - 1900;
    refblocktime.tm_mon = month - 1;
    refblocktime.tm_mday = dd;
    refblocktime.tm_hour = hh;
    refblocktime.tm_min = mm;
    refblocktime.tm_sec = ss;
    refblocktime.tm_isdst = -1;
    time_t tRefblocktime = mktime(&refblocktime);
    
    time_t localTime;
    tRefblocktime += localtime(&localTime)->tm_gmtoff;
    std::string strReferenceBlockTime = std::to_string(tRefblocktime);
    char* referenceBlockTime = new char[strReferenceBlockTime.length()+1];
    memset(referenceBlockTime, 0x00, strReferenceBlockTime.length()+1);
    std::copy(strReferenceBlockTime.begin(), strReferenceBlockTime.end(), referenceBlockTime);
    
    EOSProtosTransactionEOS * transactionEOS = [[EOSProtosTransactionEOS alloc]init];
    transactionEOS.path = path;
    transactionEOS.chainId = [NSString stringWithCString:root["EOS"]["chainID"].asCString() encoding:NSUTF8StringEncoding];
    transactionEOS.expiration = [NSString stringWithCString:root["EOS"]["expiration"].asCString() encoding:NSUTF8StringEncoding];
    transactionEOS.referenceBlockId = [NSString stringWithCString:root["EOS"]["referenceBlockId"].asCString() encoding:NSUTF8StringEncoding];
    transactionEOS.referenceBlockTime = [NSString stringWithCString:referenceBlockTime encoding:NSUTF8StringEncoding];
    transactionEOS.actionsInJson = [NSString stringWithCString:actionsInJSON encoding:NSUTF8StringEncoding];
    
    JUB_CHAR_PTR raw = nullptr;
//    rv = JUB_SignTransactionEOS(contextID,
//                                path,
//                                chainID,
//                                expiration,
//                                referenceBlockId,
//                                referenceBlockTime,
//                                actionsInJSON,
//                                &raw);
    rvStr = [g_sdk signTransactionEOS:contextID pbTx:transactionEOS];
    
    if (referenceBlockTime) {
        delete [] referenceBlockTime; referenceBlockTime = nullptr;
    }
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return rv;
//    }
    
    rv = rvStr.stateCode;
    
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
    
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionEOS() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionEOS() OK.]"]];
    
//    rv = JUB_FreeMemory(actionsInJSON);
    raw = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    if (raw) {
        [self addMsgData:[NSString stringWithFormat:@"tx raw in JSON: %s.", raw]];
        
//        rv = JUB_FreeMemory(raw);
//        if (JUBR_OK != rv) {
//            [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//            return rv;
//        }
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
    }
    
    return JUBR_OK;
}


@end

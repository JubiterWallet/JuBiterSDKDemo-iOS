//
//  JUBTRXController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/10/26.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"

#import "JUBTRXController.h"
#import "JUBTRXAmount.h"

@interface JUBTRXController ()
@property (nonatomic,assign)Transaction_Contract_ContractType transferType;
@end


@implementation JUBTRXController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"TRX options";
    self.transferType = Transaction_Contract_ContractType_AccountCreateContract;
    self.buttonArray[3].disEnable = YES;
    self.optItem = JUB_NS_ENUM_MAIN::OPT_TRX;
}

- (NSString *)inputResource
{
    __block NSString * resourceStr = @"";
    __block BOOL isDone = NO;
    JUBCustomInputAlert *  resourceAlert =[JUBCustomInputAlert showCallBack:^(NSString * _Nullable content, JUBDissAlertCallBack  _Nonnull dissAlertCallBack, JUBSetErrorCallBack  _Nonnull setErrorCallBack) {
        resourceStr = content;
        dissAlertCallBack();
        isDone = YES;
    } keyboardType:UIKeyboardTypeNumberPad];
    resourceAlert.title = [JUBTRXAmount title:(JUB_NS_ENUM_TRX_OPT)self.selectedMenuIndex];
    resourceAlert.message = [JUBTRXAmount message];
    resourceAlert.textFieldPlaceholder = [JUBTRXAmount formatResourceRules];
    resourceAlert.limitLength = 1;
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }

    
    return resourceStr;
}

- (NSString *)inputDuration
{
    __block NSString * durationStr = @"";
    __block BOOL isDone = NO;

    JUBCustomInputAlert * durationAlert = [JUBCustomInputAlert showCallBack:^(NSString * _Nullable content, JUBDissAlertCallBack  _Nonnull dissAlertCallBack, JUBSetErrorCallBack  _Nonnull setErrorCallBack) {
        durationStr = content;
        dissAlertCallBack();
        isDone = YES;
    } keyboardType:UIKeyboardTypeNumberPad];
    durationAlert.title = [JUBTRXAmount title:(JUB_NS_ENUM_TRX_OPT)self.selectedMenuIndex];
    durationAlert.message = [JUBTRXAmount message];
    durationAlert.textFieldPlaceholder = [JUBTRXAmount formatDurationRules];
    durationAlert.limitLength = 2;
    
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    return durationStr;
}

- (NSArray*) subMenu {
    return @[
        BUTTON_TITLE_TRX,
        BUTTON_TITLE_TRC10,
        BUTTON_TITLE_TRCFree,
        BUTTON_TITLE_TRCUnfreeze,
        BUTTON_TITLE_TRC20,
        BUTTON_TITLE_TRC20_TRANSFER
    ];
}


#pragma mark - 通讯库寻卡回调
- (void) CoinTRXOpt:(NSUInteger)deviceID {
    
    const char* json_file = JSON_FILE_TRX;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", json_file]
                                                         ofType:@"json"];
    Json::Value root = readJSON([filePath UTF8String]);
    
    [self TRX_test:deviceID
              root:root
            choice:(int)self.optIndex];
}


#pragma mark - TRX applet
- (void) TRX_test:(NSUInteger)deviceID
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
        
//        CONTEXT_CONFIG_TRX cfg;
//        cfg.mainPath = (char*)root["main_path"].asCString();
//        rv = JUB_CreateContextTRX(cfg, deviceID, &contextID);
        CommonProtosContextCfg * cfg = [[CommonProtosContextCfg alloc]init];
        cfg.mainPath = [NSString stringWithCString:root["main_path"].asCString() encoding:NSUTF8StringEncoding];

        CommonProtosResultInt * rvInt = [g_sdk createContextTRX:cfg deviceID:deviceID];
        rv = rvInt.stateCode;
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        contextID = rvInt.value;
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextTRX() OK.]"]];
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
//    rv = JUB_GetMainHDNodeTRX(contextID, JUB_ENUM_PUB_FORMAT::HEX, &pubkey);
    rvStr = [g_sdk getMainHDNodeTRX:contextID pbFormat:CommonProtosENUM_PUB_FORMAT_Hex];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    pubkey = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeTRX() OK.]"]];
    
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
//    rv = JUB_GetHDNodeTRX(contextID, JUB_ENUM_PUB_FORMAT::HEX, path, &pubkey);
    rvStr = [g_sdk getHDNodeTRX:contextID pbFormat:CommonProtosENUM_PUB_FORMAT_Hex pbPath:path];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    pubkey = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeTRX() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"pubkey(%@/%d/%llu) in hex format: %s.", [sharedData currMainPath], path.change, path.addressIndex, pubkey]];
//    rv = JUB_FreeMemory(pubkey);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
    
    char* address = nullptr;
//    rv = JUB_GetAddressTRX(contextID, path, BOOL_FALSE, &address);
    rvStr = [g_sdk getAddressTRX:contextID pbPath:path bShow:NO];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressTRX() OK.]"]];
    
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
//    rv = JUB_GetAddressTRX(contextID, path, BOOL_TRUE, &address);
    rvStr = [g_sdk getAddressTRX:contextID pbPath:path bShow:YES];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressTRX() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%d/%llu) is: %s.", [sharedData currMainPath], path.change, path.addressIndex, address]];
    
//    rv = JUB_FreeMemory(address);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
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
                 || [JUBTRXAmount isValid:content
                                      opt:(JUB_NS_ENUM_TRX_OPT)self.selectedMenuIndex]
                 ) {
            //隐藏弹框
            amount = content;
            isDone = YES;
            dissAlertCallBack();
        }
        else {
            setErrorCallBack([JUBTRXAmount formatRules]);
            isDone = NO;
        }
    } keyboardType:UIKeyboardTypeDecimalPad];
    customInputAlert.title = [JUBTRXAmount title:(JUB_NS_ENUM_TRX_OPT)self.selectedMenuIndex];
    customInputAlert.message = [JUBTRXAmount message];
    customInputAlert.textFieldPlaceholder = [JUBTRXAmount formatRules];
    customInputAlert.limitLength = [JUBTRXAmount limitLength];
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    return [JUBTRXAmount convertToProperFormat:amount
                                           opt:(JUB_NS_ENUM_TRX_OPT)self.selectedMenuIndex];
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

- (Transaction_Contract_ContractType)TransferType
{
    switch(self.selectedMenuIndex) {
        case 0:
            self.transferType = Transaction_Contract_ContractType_TransferContract;
            break;
        case 1:
            self.transferType = Transaction_Contract_ContractType_TransferAssetContract;
            break;
        case 2:
            self.transferType = Transaction_Contract_ContractType_FreezeBalanceContract;
            break;
        case 3:
            self.transferType = Transaction_Contract_ContractType_UnfreezeBalanceContract;
            break;
        case 4:
            self.transferType = Transaction_Contract_ContractType_TriggerSmartContract;
            break;
        case 5:
            self.transferType = Transaction_Contract_ContractType_GetContract;
            break;
    default:
        break;
    }
    return self.transferType;
}

- (NSUInteger) transaction_proc:(NSUInteger)contextID
                         amount:(NSString*)amount
                           root:(Json::Value)root {
    
    JUB_RV rv = JUBR_ERROR;
    
    if (!root["TRX"]["contracts"].isObject()) {
        return JUBR_ARGUMENTS_BAD;
    }
    
    Transaction_Contract * contrTRX = [[Transaction_Contract alloc]init];
    contrTRX.type = [self TransferType];
    
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
    rvStr = [g_sdk checkAddressTRX:contextID address:[NSString stringWithCString:root["TRX"]["contracts"]["owner_address"].asCString() encoding:NSUTF8StringEncoding]];
    NSData * ownerAddressData = [JUBTRXAmount StrToHex:rvStr.value];
    
    NSString * trc20Abi = @"";
    
    rvStr = [g_sdk checkAddressTRX:contextID address:[NSString stringWithCString:root["TRX"]["TRC20"]["contract_address"].asCString() encoding:NSUTF8StringEncoding]];
    
    NSString * contractAddress = rvStr.value;
    
    if (contrTRX.type == Transaction_Contract_ContractType_TransferAssetContract) {
        NSString * assetName = [NSString stringWithCString:root["TRX"]["TRC10"]["assetName"].asCString() encoding:NSUTF8StringEncoding];
        NSString * assetID = [NSString stringWithCString:root["TRX"]["TRC10"]["assetID"].asCString() encoding:NSUTF8StringEncoding];
        NSInteger unitDP = root["TRX"]["TRC10"]["dp"].asUInt64();
        
        rv = [g_sdk setTRC10Asset:contextID assetName:assetName unitDP:unitDP assetID:assetID];
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_setTRC10Asset() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return rv;
        }
    }
    
    BOOL bERC20 = NO;
    if (32 == contrTRX.type) {
        bERC20 = YES;
        contrTRX.type = Transaction_Contract_ContractType_TriggerSmartContract;
    }
    std::string strType = std::to_string((unsigned int)contrTRX.type);
    char* sType = new char[strType.length()+1];
    memset(sType, 0x00, strType.length()+1);
    std::copy(strType.begin(), strType.end(), sType);
    
    if (bERC20) {
        NSString * tokenName = [NSString stringWithCString:root["TRX"]["TRC20"]["tokenName"].asCString() encoding:NSUTF8StringEncoding];
        NSInteger unitDP = root["TRX"]["TRC20"]["dp"].asUInt64();
        NSString * tokenTo = [NSString stringWithCString:root["TRX"]["TRC20"]["token_to"].asCString() encoding:NSUTF8StringEncoding];
        NSString * tokenValue = [NSString stringWithCString:root["TRX"]["TRC20"]["token_value"].asCString() encoding:NSUTF8StringEncoding];
        
        CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
        rvStr = [g_sdk buildTRC20Abi:contextID tokenName:tokenName unitDP:unitDP contractAddress:contractAddress tokenTo:tokenTo tokenValue:tokenValue];
        rv = rvStr.stateCode;
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_buildTRC20Abi() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return rv;
        }
        trc20Abi = rvStr.value;
    }
        Transaction_raw * tx = [[Transaction_raw alloc]init];
    
        tx.refBlockBytes = [JUBTRXAmount StrToHex:[NSString stringWithCString:root["TRX"]["pack"]["ref_block_bytes"].asCString() encoding:NSUTF8StringEncoding]];
        tx.refBlockNum = 0;
        tx.refBlockHash = [JUBTRXAmount StrToHex:[NSString stringWithCString:root["TRX"]["pack"]["ref_block_hash"].asCString() encoding:NSUTF8StringEncoding]];
        tx.data_p = nil;
        tx.expiration = [NSString stringWithCString:root["TRX"]["pack"]["expiration"].asCString() encoding:NSUTF8StringEncoding].integerValue;
        tx.timestamp = [NSString stringWithCString:root["TRX"]["pack"]["timestamp"].asCString() encoding:NSUTF8StringEncoding].integerValue;
        tx.feeLimit = 0;
    
    switch (contrTRX.type) {
        case Transaction_Contract_ContractType_TransferContract:
        {
            TransferContract * transfer = [[TransferContract alloc]init];
            
            transfer.ownerAddress = ownerAddressData;

            rvStr = [g_sdk checkAddressTRX:contextID address:[NSString stringWithCString:root["TRX"]["contracts"][sType]["to_address"].asCString() encoding:NSUTF8StringEncoding]];
            transfer.toAddress = [JUBTRXAmount StrToHex:rvStr.value];

            transfer.amount = root["TRX"]["contracts"][sType]["amount"].asUInt64();
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                transfer.amount = amount.intValue;
                
            }
            [contrTRX.parameter packWithMessage:transfer error:nil];
            
            break;
        }
        case Transaction_Contract_ContractType_TransferAssetContract:
        {
            TransferAssetContract *transferAsset = [[TransferAssetContract alloc]init];
            
            transferAsset.assetName = [NSData dataWithBytes:root["TRX"]["contracts"][sType]["asset_name"].asCString() length:7];
            
            transferAsset.ownerAddress = ownerAddressData;

            CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
            rvStr = [g_sdk checkAddressTRX:contextID address:[NSString stringWithCString:root["TRX"]["contracts"][sType]["to_address"].asCString() encoding:NSUTF8StringEncoding]];
            transferAsset.toAddress = [JUBTRXAmount StrToHex:rvStr.value];
            
            transferAsset.amount = root["TRX"]["contracts"][sType]["amount"].asUInt();
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                transferAsset.amount = amount.intValue;
            }
            [contrTRX.parameter packWithMessage:transferAsset error:nil];

            break;
        }
        case Transaction_Contract_ContractType_FreezeBalanceContract:
        {
            FreezeBalanceContract * freezeBalance = [[FreezeBalanceContract alloc]init];
            CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
            
            freezeBalance.ownerAddress = ownerAddressData;
            
            freezeBalance.frozenBalance = root["TRX"]["contracts"][sType]["frozen_balance"].asUInt64();
            if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
                freezeBalance.frozenBalance = amount.intValue;
            }
            freezeBalance.resource = (ResourceCode)root["TRX"]["contracts"][sType]["resource"].asUInt64();
            NSString * res = [self inputResource];
            if (res.length && ([res isEqualToString:@"0"] || [res isEqualToString:@"1"])) {
                freezeBalance.resource = (ResourceCode)res.intValue;
            }
            freezeBalance.frozenDuration = root["TRX"]["contracts"][sType]["frozen_duration"].asUInt64();
            NSString * fDuration = [self inputDuration];
            if (fDuration.length) {
                freezeBalance.frozenDuration = fDuration.intValue;
            }
            
            rvStr = [g_sdk checkAddressTRX:contextID address:[NSString stringWithCString:root["TRX"]["contracts"][sType]["receiver_address"].asCString() encoding:NSUTF8StringEncoding]];

            freezeBalance.receiverAddress = [JUBTRXAmount StrToHex:rvStr.value];
            [contrTRX.parameter packWithMessage:freezeBalance error:nil];
            
            break;
        }
        case Transaction_Contract_ContractType_UnfreezeBalanceContract:
        {
            UnfreezeBalanceContract * unfreezeBalance = [[UnfreezeBalanceContract alloc]init];
            CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
            
            unfreezeBalance.ownerAddress = ownerAddressData;
            unfreezeBalance.resource = (ResourceCode)root["TRX"]["contracts"][sType]["resource"].asUInt64();
            NSString * res = [self inputResource];
            if (res.length && ([res isEqualToString:@"0"] || [res isEqualToString:@"1"])) {
                unfreezeBalance.resource = (ResourceCode)res.intValue;
            }
            rvStr = [g_sdk checkAddressTRX:contextID address:[NSString stringWithCString:root["TRX"]["contracts"][sType]["receiver_address"].asCString() encoding:NSUTF8StringEncoding]];
            unfreezeBalance.receiverAddress = [JUBTRXAmount StrToHex:rvStr.value];
            
            [contrTRX.parameter packWithMessage:unfreezeBalance error:nil];

            break;
        }
        case Transaction_Contract_ContractType_CreateSmartContract:
        {
            //noting

            break;
        }
        case Transaction_Contract_ContractType_TriggerSmartContract:
        {
            NSString * feeStr = [NSString stringWithCString:root["TRX"]["contracts"][sType]["fee_limit"].asCString() encoding:NSUTF8StringEncoding];
            tx.feeLimit = feeStr.intValue;
            TriggerSmartContract *triggerSmart = [[TriggerSmartContract alloc]init];
            
            triggerSmart.ownerAddress = ownerAddressData;
            
            if (bERC20) {
                triggerSmart.contractAddress = [JUBTRXAmount StrToHex:contractAddress];
                triggerSmart.data_p = [JUBTRXAmount StrToHex:trc20Abi];
            } else {
                
                CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
                rvStr = [g_sdk checkAddressTRX:contextID address:[NSString stringWithCString:root["TRX"]["contracts"][sType]["contract_address"].asCString() encoding:NSUTF8StringEncoding]];
                
                triggerSmart.contractAddress =[JUBTRXAmount StrToHex:rvStr.value
                                               ];
                triggerSmart.data_p =  [JUBTRXAmount StrToHex:[NSString stringWithCString:root["TRX"]["contracts"][sType]["data"].asCString() encoding:NSUTF8StringEncoding]];
            }

            triggerSmart.callValue = root["TRX"]["contracts"][sType]["call_value"].asUInt64();
            triggerSmart.callTokenValue = root["TRX"]["contracts"][sType]["call_token_value"].asUInt64();
            triggerSmart.tokenId = root["TRX"]["contracts"][sType]["token_id"].asUInt64();
            [contrTRX.parameter packWithMessage:triggerSmart error:nil];
            break;
        }
        default:
        return JUBR_ARGUMENTS_BAD;
    }
    [tx.contractArray addObject:contrTRX];

    NSString * packContractInPb = [JUBTRXAmount HexToStr:tx.data];
    
    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change = (JUB_ENUM_BOOL)root["TRX"]["bip32_path"]["change"].asBool();
    path.addressIndex = root["TRX"]["bip32_path"]["addressIndex"].asInt64();
    
    JUB_CHAR_PTR rawInJSON = nullptr;
    
    NSLog(@"packContractInPb:%@---%d",packContractInPb,contrTRX.type);
    rvStr = [g_sdk signTransactionTRX:contextID pbPath:path packedContractInPb:packContractInPb];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionTRX() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionTRX() OK.]"]];
    rawInJSON = (JUB_CHAR_PTR)rvStr.value.UTF8String;

    if (rawInJSON) {
        [self addMsgData:[NSString stringWithFormat:@"tx raw in JSON: %s.", rawInJSON]];
    }
    
    return JUBR_OK;
}


@end

//
//  JUBBTCController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/4/28.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"
#import "JUBBTCAmount.h"

#import "JUBBTCController.h"

@interface JUBBTCController ()

@end


@implementation JUBBTCController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"BTC options";
    
    self.optItem = JUB_NS_ENUM_MAIN::OPT_BTC;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    switch ([sharedData deviceType]) {
    case JUB_NS_ENUM_DEV_TYPE::SEG_BLE:
        self.navRightButtonTitle = BUTTON_TITLE_SETUNIT;
        break;
    case JUB_NS_ENUM_DEV_TYPE::SEG_NFC:
    default:
        break;
    }   // switch ([sharedData deviceType]) end
}


- (NSArray*) subMenu {
    
    return @[
        BUTTON_TITLE_BTCP2PKH,
        BUTTON_TITLE_BTCP2WPKH,
        BUTTON_TITLE_LTC,
        BUTTON_TITLE_DASH,
        BUTTON_TITLE_BCH,
        BUTTON_TITLE_QTUM,
        BUTTON_TITLE_QTUM_QRC20,
        BUTTON_TITLE_USDT,
        BUTTON_TITLE_HCASH
    ];
}


- (void) navRightButtonCallBack {
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    JUBListAlert *listAlert = [JUBListAlert showCallBack:^(NSString *_Nonnull selectedItem) {
        NSLog(@"UNIT selected: %@", selectedItem);
        if (!selectedItem) {
            NSLog(@"JUBBTCController::JUBListAlert canceled");
            return;
        }
        
        BitcoinProtosBTC_UNIT_TYPE unit = [JUBBTCAmount stringToEnumUnit:selectedItem];
        [sharedData setCoinUnit:unit];
    }];
    
    listAlert.title = @"Please select UNIT:";
    [listAlert addItems:@[
        TITLE_UNIT_BTC,
        TITLE_UNIT_cBTC,
        TITLE_UNIT_mBTC,
        TITLE_UNIT_uBTC,
        TITLE_UNIT_Satoshi
    ]];
    [listAlert setTextAlignment:NSTextAlignment::NSTextAlignmentRight];
}


#pragma mark - 通讯库寻卡回调
- (void) CoinBTCOpt:(NSUInteger)deviceID {
    
    const char* json_file = "";
    BitcoinProtosENUM_COIN_TYPE_BTC coinType = BitcoinProtosENUM_COIN_TYPE_BTC::BitcoinProtosENUM_COIN_TYPE_BTC_Coinbtc;
    /*使用OC类型
     BitcoinProtosENUM_COIN_TYPE_BTC_Coinbtc = 0,
     BitcoinProtosENUM_COIN_TYPE_BTC_Coinbch = 1,
     BitcoinProtosENUM_COIN_TYPE_BTC_Coinltc = 2,
     BitcoinProtosENUM_COIN_TYPE_BTC_Coinusdt = 3,
     BitcoinProtosENUM_COIN_TYPE_BTC_Coindash = 4,
     BitcoinProtosENUM_COIN_TYPE_BTC_Coinqtum = 5,
     */
//    JUB_ENUM_COINTYPE_BTC coinType = JUB_ENUM_COINTYPE_BTC::COINBTC;
    switch ((JUB_NS_ENUM_BTC_COIN)self.selectedMenuIndex) {
    case JUB_NS_ENUM_BTC_COIN::BTN_BTC_P2PKH:
    {   
        json_file = JSON_FILE_BTC_44;
//        coinType = COINBTC;
        coinType = BitcoinProtosENUM_COIN_TYPE_BTC_Coinbtc;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_BTC_P2WPKH:
    {
        json_file = JSON_FILE_BTC_49;
//        coinType = COINBTC;
        coinType = BitcoinProtosENUM_COIN_TYPE_BTC_Coinbtc;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_LTC:
    {
        json_file = JSON_FILE_LTC;
//        coinType = COINLTC;
        coinType = BitcoinProtosENUM_COIN_TYPE_BTC_Coinltc;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_DASH:
    {
        json_file = JSON_FILE_DASH;
//        coinType = COINDASH;
        coinType = BitcoinProtosENUM_COIN_TYPE_BTC_Coindash;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_BCH:
    {
        json_file = JSON_FILE_BCH;
//        coinType = COINBCH;
        coinType = BitcoinProtosENUM_COIN_TYPE_BTC_Coinbch;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM:
    {
        json_file = JSON_FILE_QTUM;
//        coinType = COINQTUM;
        coinType = BitcoinProtosENUM_COIN_TYPE_BTC_Coinqtum;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM_QRC20:
    {
        json_file = JSON_FILE_QTUM_QRC20;
//        coinType = COINQTUM;
        coinType = BitcoinProtosENUM_COIN_TYPE_BTC_Coinqtum;
        break;
    }
    case JUB_NS_ENUM_BTC_COIN::BTN_USDT:
    {
        json_file = JSON_FILE_BTC_USDT;
//        coinType = COINUSDT;
        coinType = BitcoinProtosENUM_COIN_TYPE_BTC_Coinusdt;
        break;
    }
    default:
        json_file = JSON_FILE_HCASH;
        break;
    }   // switch ((JUB_NS_ENUM_BTC_COIN)self.selectedMenuIndex) end
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", json_file]
                                                         ofType:@"json"];
    Json::Value root = readJSON([filePath UTF8String]);
    
    switch (self.selectedMenuIndex) {
    case JUB_NS_ENUM_BTC_COIN::BTN_HCASH:
    {
        [self HC_test:deviceID
                 root:root
               choice:(int)self.optIndex];
        break;
    }   // case JUB_NS_ENUM_BTC_COIN::BTN_HCASH end
    default:
    {
        [self BTC_test:deviceID
                  root:root
                choice:(int)self.optIndex
              coinType:coinType];
        break;
    }   // default end
    }   // switch (self.selectedMenuIndex) end
}


#pragma mark - BTC applet
- (void) BTC_test:(NSUInteger)deviceID
             root:(Json::Value)root
           choice:(int)choice
         coinType:(BitcoinProtosENUM_COIN_TYPE_BTC)coinType {
    
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
        
//        CONTEXT_CONFIG_BTC cfg;
//        cfg.mainPath = (char*)root["main_path"].asCString();
//        cfg.coinType = coinType;
        
        BitcoinProtosContextCfgBTC * cfg = [[BitcoinProtosContextCfgBTC alloc]init];
        cfg.mainPath = [NSString stringWithUTF8String:root["main_path"].asCString()];
        cfg.coinType = coinType;
        /*使用OC类型
         BitcoinProtosENUM_TRAN_STYPE_BTC_P2Pkh = 0,
         BitcoinProtosENUM_TRAN_STYPE_BTC_P2ShP2Wpkh = 1,
         BitcoinProtosENUM_TRAN_STYPE_BTC_P2ShMultisig = 2,
         BitcoinProtosENUM_TRAN_STYPE_BTC_P2Pk = 3,
         */
        if (BitcoinProtosENUM_COIN_TYPE_BTC_Coinbch == coinType) {
            cfg.transType = BitcoinProtosENUM_TRAN_STYPE_BTC_P2Pkh;
        }
        else {
            if (root["p2sh-segwit"].asBool()) {
//                cfg.transType = p2sh_p2wpkh;
                cfg.transType = BitcoinProtosENUM_TRAN_STYPE_BTC_P2ShP2Wpkh;
            }
            else {
//                cfg.transType = p2pkh;
                cfg.transType = BitcoinProtosENUM_TRAN_STYPE_BTC_P2Pkh;
            }
        }
        
//        rv = JUB_CreateContextBTC(cfg, deviceID, &contextID);
        CommonProtosResultInt* rv = [g_sdk createContextBTC:cfg deviceID:deviceID];
        
        if (JUBR_OK != rv.stateCode) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextBTC() return %@ (0x%2llx).]", [JUBErrorCode GetErrMsg:rv.stateCode], rv.stateCode]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextBTC() OK.]"]];
        [sharedData setCurrMainPath:[NSString stringWithFormat:@"%@", cfg.mainPath]];
        [sharedData setCurrCoinType:cfg.coinType];
        contextID = rv.value;
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
    
//    JUB_RV rv = JUBR_ERROR;
    
    CommonProtosResultString * rvStr;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
//    JUB_CHAR_PTR mainXpub;
//    rv = JUB_GetMainHDNodeBTC(contextID, &mainXpub);
    rvStr = [g_sdk getMainHDNodeBTC:contextID];
    
    if (JUBR_OK != rvStr.stateCode) {
        [self addMsgData:[NSString stringWithFormat:@"[getMainHDNodeBTC return %@ (0x%2llx).]", [JUBErrorCode GetErrMsg:rvStr.stateCode], rvStr.stateCode]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[getMainHDNodeBTC OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"Main xpub(%@): %@.", [sharedData currMainPath], rvStr.value]];
    
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
    path.change = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
//    JUB_CHAR_PTR xpub;
//    rv = JUB_GetHDNodeBTC(contextID, path, &xpub);
    
    rvStr = [g_sdk getHDNodeBTC:contextID pbPath:path];
    
    if (JUBR_OK != rvStr.stateCode) {
        [self addMsgData:[NSString stringWithFormat:@"[getHDNodeBTC return %@ (0x%2llx).]", [JUBErrorCode GetErrMsg:rvStr.stateCode], rvStr.stateCode]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[getHDNodeBTC OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"input xpub(%@/%u/%llu): %@.", [sharedData currMainPath], path.change, path.addressIndex, rvStr.value]];
    
//    rv = JUB_FreeMemory(xpub);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
    
//    JUB_CHAR_PTR address;
//    rv = JUB_GetAddressBTC(contextID, path, BOOL_FALSE, &address);
    rvStr = [g_sdk getAddressBTC:contextID pbPath:path bShow:NO];
    
    if (JUBR_OK != rvStr.stateCode) {
        [self addMsgData:[NSString stringWithFormat:@"[getAddressBTC return %@ (0x%2llx).]", [JUBErrorCode GetErrMsg:rvStr.stateCode], rvStr.stateCode]];
        return;
    }
    NSString * address = rvStr.value;
    [self addMsgData:[NSString stringWithFormat:@"[getAddressBTC OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"input address(%@/%d/%llu): %@.", [sharedData currMainPath], path.change, path.addressIndex, address]];
    
//    rv = JUB_CheckAddressBTC(contextID, address);
    NSInteger rv = [g_sdk checkAddressBtc:contextID address:address];
    
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[checkAddressBtc return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[checkAddressBtc OK.]"]];

//    rv = JUB_FreeMemory(address);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
}


- (void) show_address_test:(NSUInteger)contextID {
    
//    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
//    BIP44_Path path;
//    path.change       = [sharedData currPath].change;
//    path.addressIndex = [sharedData currPath].addressIndex;
    
    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
//    JUB_CHAR_PTR address;
//    rv = JUB_GetAddressBTC(contextID, path, BOOL_TRUE, &address);
    rvStr = [g_sdk getAddressBTC:contextID pbPath:path bShow:YES];
    
    if (JUBR_OK != rvStr.stateCode) {
        [self addMsgData:[NSString stringWithFormat:@"[getAddressBTC return %@ (0x%2llx).]", [JUBErrorCode GetErrMsg:rvStr.stateCode], rvStr.stateCode]];
        return;
    }
    NSString * address = rvStr.value;
    [self addMsgData:[NSString stringWithFormat:@"[getAddressBTC OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%d/%llu) is: %@.", [sharedData currMainPath], path.change, path.addressIndex, address]];
    
//    rv = JUB_FreeMemory(address);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
}


- (NSUInteger) set_my_address_proc:(NSUInteger)contextID {
    
    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr;
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return rv;
    }
    
//    BIP44_Path path;
//    path.change       = [sharedData currPath].change;
//    path.addressIndex = [sharedData currPath].addressIndex;
    CommonProtosBip44Path * path = [[CommonProtosBip44Path alloc]init];
    path.change = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
//    JUB_CHAR_PTR address = nullptr;
//    rv = JUB_SetMyAddressBTC(contextID, path, &address);
    rvStr = [g_sdk setMyAddressBTC:contextID pbPath:path];

    if (JUBR_OK != rvStr.stateCode) {
        [self addMsgData:[NSString stringWithFormat:@"[setMyAddressBTC return %@ (0x%2llx).]", [JUBErrorCode GetErrMsg:rvStr.stateCode], rvStr.stateCode]];
        return rvStr.stateCode;
    }
    NSString * address = rvStr.value;
    [self addMsgData:[NSString stringWithFormat:@"[setMyAddressBTC OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"set my address is: %@.", address]];
    
//    rv = JUB_FreeMemory(address);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return rv;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
    
    return rvStr.stateCode;
}


- (NSUInteger) set_unit_test:(NSUInteger)contextID {
    
    JUB_RV rv = JUBR_ERROR;
    
    
//    JUB_ENUM_BTC_UNIT_TYPE unit = [[JUBSharedData sharedInstance] coinUnit];
    BitcoinProtosBTC_UNIT_TYPE unit = [[JUBSharedData sharedInstance] coinUnit];
    
//    if (JUB_ENUM_BTC_UNIT_TYPE::ns == unit) {
//        return JUBR_OK;
//    }
    
//    rv = JUB_SetUnitBTC(contextID, unit);
    rv = [g_sdk setUnitBTC:contextID pbUnit:unit];
    if (   JUBR_OK               != rv
//        && JUBR_IMPL_NOT_SUPPORT != rv
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SetUnitBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SetUnitBTC() OK.]"]];
    
    return rv;
}


- (NSString*) inputAmount {
    
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return nil;
    }
    
    BitcoinProtosBTC_UNIT_TYPE coinUnit = [sharedData coinUnit];
    
    __block
    NSString *amount = nil;
    
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
                 || [JUBBTCAmount isValid:content]
                 ) {
            //隐藏弹框
            amount = content;
            isDone = YES;
            dissAlertCallBack();
        }
        else {
            setErrorCallBack([JUBBTCAmount formatRules]);
            isDone = NO;
        }
    } keyboardType:UIKeyboardTypeDecimalPad];
    customInputAlert.title = [JUBBTCAmount title:coinUnit];
    customInputAlert.message = [JUBBTCAmount message];
    customInputAlert.textFieldPlaceholder = [JUBBTCAmount formatRules];
    customInputAlert.limitLength = [JUBBTCAmount limitLength];
    
    while (!isDone) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    // Convert to the smallest unit
    NSString *smallestUnit;
    switch ((JUB_NS_ENUM_BTC_COIN)self.selectedMenuIndex) {
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM_QRC20:
    case JUB_NS_ENUM_BTC_COIN::BTN_USDT:
        smallestUnit = [JUBBTCAmount convertToProperFormat:amount
                                                       opt:(JUB_NS_ENUM_BTC_COIN)self.selectedMenuIndex];
        break;
    default:
        smallestUnit = [JUBBTCAmount convertToTheSmallestUnit:amount
                                                        point:@"."
                                                      decimal:[JUBBTCAmount enumUnitToDecimal:coinUnit]];
        break;
    }
    
    return smallestUnit;
}


- (NSUInteger) tx_proc:(NSUInteger)contextID
                amount:(NSString*)amount
                  root:(Json::Value)root {
    
    JUB_RV rv = JUBR_ERROR;
    
    switch((JUB_NS_ENUM_BTC_COIN)self.selectedMenuIndex) {
    case JUB_NS_ENUM_BTC_COIN::BTN_BTC_P2PKH:
    case JUB_NS_ENUM_BTC_COIN::BTN_BTC_P2WPKH:
    case JUB_NS_ENUM_BTC_COIN::BTN_LTC:
    case JUB_NS_ENUM_BTC_COIN::BTN_DASH:
    case JUB_NS_ENUM_BTC_COIN::BTN_BCH:
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM:
        rv = [self transaction_proc:contextID
                             amount:amount
                               root:root];
        break;
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM_QRC20:
        rv = [self transactionQTUM_proc:contextID
                                 amount:amount
                                   root:root];
        break;
    case JUB_NS_ENUM_BTC_COIN::BTN_USDT:
        rv = [self transactionUSDT_proc:contextID
                                 amount:amount
                                   root:root];
        break;
    case JUB_NS_ENUM_BTC_COIN::BTN_HCASH:
        rv = [self transactionHC_proc:contextID
                               amount:amount
                                 root:root];
        break;
    default:
        break;
    }
    
    return rv;
}


- (NSUInteger) transaction_proc:(NSUInteger)contextID
                         amount:(NSString*)amount
                           root:(Json::Value)root {
    
    BitcoinProtosTransactionBTC * pbTransaction = [[BitcoinProtosTransactionBTC alloc]init];
    JUB_RV rv = JUBR_ERROR;
    
    JUB_UINT32 version = root["ver"].asInt();
    pbTransaction.inputsArray = [NSMutableArray array];
    pbTransaction.outputsArray = [NSMutableArray array];
    pbTransaction.version = version;
    pbTransaction.locktime = 0;

//    std::vector<INPUT_BTC> inputs;
//    std::vector<OUTPUT_BTC> outputs;
    int inputNumber = root["inputs"].size();
    
//    INPUT_BTC selfdefInput;
    BitcoinProtosInputBTC * selfdefInput;
    for (int i = 0; i < inputNumber; i++) {
//        INPUT_BTC input;
//        input.type = JUB_ENUM_SCRIPT_BTC_TYPE::P2PKH;
//        input.preHash = (char*)root["inputs"][i]["preHash"].asCString();
//        input.preIndex = root["inputs"][i]["preIndex"].asInt();
//        input.path.change = (JUB_ENUM_BOOL)root["inputs"][i]["bip32_path"]["change"].asBool();
//        input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
//        input.amount = root["inputs"][i]["amount"].asUInt64();
//        input.nSequence = 0xffffffff;
//        inputs.push_back(input);
        
//        selfdefInput = input;
        
        BitcoinProtosInputBTC * input = [[BitcoinProtosInputBTC alloc]init];
       
        input.preHash = [NSString stringWithCString:root["inputs"][i]["preHash"].asCString() encoding:NSUTF8StringEncoding];
        input.preIndex = root["inputs"][i]["preIndex"].asInt();
        input.path.change = (JUB_ENUM_BOOL)root["inputs"][i]["bip32_path"]["change"].asBool();
        input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
        input.amount = root["inputs"][i]["amount"].asUInt64();

        [pbTransaction.inputsArray addObject:input];
        selfdefInput = input;
    }
    if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
        selfdefInput.amount = [amount longLongValue];
//        inputs.push_back(selfdefInput);
        [pbTransaction.inputsArray addObject:selfdefInput];
    }
    
    int outputNumber = root["outputs"].size();
    
//    JUB_CHAR_PTR changeAddress = nil;
//    OUTPUT_BTC selfdefOutput;
    BitcoinProtosOutputBTC * selfdefOutput = [[BitcoinProtosOutputBTC alloc]init];

    for (int i = 0; i < outputNumber; i++) {
//        OUTPUT_BTC output;
//        output.type = JUB_ENUM_SCRIPT_BTC_TYPE::P2PKH;
//        output.stdOutput.address = (char*)root["outputs"][i]["address"].asCString();
//        output.stdOutput.amount = root["outputs"][i]["amount"].asUInt64();
//        output.stdOutput.changeAddress = (JUB_ENUM_BOOL)root["outputs"][i]["change_address"].asBool();
//        if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
//            output.stdOutput.changeAddress = JUB_ENUM_BOOL::BOOL_TRUE;
//        }
//        if (output.stdOutput.changeAddress) {
//            output.stdOutput.path.change = (JUB_ENUM_BOOL)root["outputs"][i]["bip32_path"]["change"].asBool();
//            output.stdOutput.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();
//
//            rv = JUB_GetAddressBTC(contextID,
//                                   output.stdOutput.path, JUB_ENUM_BOOL::BOOL_FALSE, &changeAddress);
//            if (JUBR_OK == rv) {
//                output.stdOutput.address = changeAddress;
//            }
//        }
//        outputs.push_back(output);
//
//        selfdefOutput = output;
        
        BitcoinProtosOutputBTC * output = [[BitcoinProtosOutputBTC alloc]init];
        output.type = BitcoinProtosENUM_SCRIPT_TYPE_BTC_ScP2Pkh;
        output.stdOutput.address = [NSString stringWithCString:root["outputs"][i]["address"].asCString() encoding:NSUTF8StringEncoding];
        output.stdOutput.amount = root["outputs"][i]["amount"].asUInt64();
        output.stdOutput.changeAddress = (JUB_ENUM_BOOL)root["outputs"][i]["change_address"].asBool();
        
        if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
            output.stdOutput.changeAddress = YES;
        }
        if (output.stdOutput.changeAddress) {
            output.stdOutput.path.change = (JUB_ENUM_BOOL)root["outputs"][i]["bip32_path"]["change"].asBool();
            output.stdOutput.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();
            
            CommonProtosResultString * rvStr = [g_sdk getAddressBTC:contextID pbPath:output.stdOutput.path bShow:NO];
            rv = rvStr.stateCode;

            if (JUBR_OK == rv) {
                NSString * changeAddress = rvStr.value;
                output.stdOutput.address = changeAddress;
            }
        }
        [pbTransaction.outputsArray addObject:output];
        selfdefOutput = output;
    }
    if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
//        selfdefOutput.stdOutput.changeAddress = JUB_ENUM_BOOL::BOOL_FALSE;
        selfdefOutput.stdOutput.changeAddress = NO;
        selfdefOutput.stdOutput.amount = [amount longLongValue];
//        outputs.push_back(selfdefOutput);
        [pbTransaction.outputsArray addObject:selfdefOutput];
    }
    
//    char* raw = nullptr;
//    rv = JUB_SignTransactionBTC(contextID,
//                                version,
//                                &inputs[0], (JUB_UINT16)inputs.size(),
//                                &outputs[0], (JUB_UINT16)outputs.size(),
//                                0,
//                                &raw);
    
    
    CommonProtosResultString * rvStr = [g_sdk signTransactionBTC:contextID pbTx:pbTransaction];
    
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        if (nil != changeAddress) {
//            rv = JUB_FreeMemory(changeAddress);
//        }
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() OK.]"]];
//    if (nil != changeAddress) {
//        rv = JUB_FreeMemory(changeAddress);
//    }
    if (JUBR_USER_CANCEL == rv) {
        [self addMsgData:[NSString stringWithFormat:@"[User cancel the transaction !]"]];
        return rv;
    }
    char * raw = (char *)rvStr.value.UTF8String;

    if (   JUBR_OK != rv
        || nullptr == raw
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() OK.]"]];
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


- (NSUInteger) transactionQTUM_proc:(NSUInteger)contextID
                             amount:(NSString*)amount
                               root:(Json::Value)root {
    
    BitcoinProtosTransactionBTC * pbTransaction = [[BitcoinProtosTransactionBTC alloc]init];
    JUB_RV rv = JUBR_ERROR;
    
    JUB_UINT32 version = root["ver"].asInt();
    pbTransaction.inputsArray = [NSMutableArray array];
    pbTransaction.outputsArray = [NSMutableArray array];
    pbTransaction.version = version;
    pbTransaction.locktime = 0;

//    std::vector<INPUT_BTC> inputs;
//    std::vector<OUTPUT_BTC> outputs;
    int inputNumber = root["inputs"].size();
    
    for (int i = 0; i < inputNumber; i++) {
//        INPUT_BTC input;
//        input.type = JUB_ENUM_SCRIPT_BTC_TYPE::P2PKH;
//        input.preHash = (char*)root["inputs"][i]["preHash"].asCString();
//        input.preIndex = root["inputs"][i]["preIndex"].asInt();
//        input.path.change = (JUB_ENUM_BOOL)root["inputs"][i]["bip32_path"]["change"].asBool();
//        input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
//        input.amount = root["inputs"][i]["amount"].asUInt64();
//        inputs.push_back(input);
        
        BitcoinProtosInputBTC * input = [[BitcoinProtosInputBTC alloc]init];
        input.preHash = [NSString stringWithCString:root["inputs"][i]["preHash"].asCString() encoding:NSUTF8StringEncoding];
        input.preIndex = root["inputs"][i]["preIndex"].asInt();
        input.path.change = (JUB_ENUM_BOOL)root["inputs"][i]["bip32_path"]["change"].asBool();
        input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
        input.amount = root["inputs"][i]["amount"].asUInt64();
        [pbTransaction.inputsArray addObject:input];
    }
    
    int outputNumber = root["outputs"].size();
    
//    JUB_CHAR_PTR changeAddress = nil;
    for (int i = 0; i < outputNumber; i++) {
//        OUTPUT_BTC output;
//        output.type = JUB_ENUM_SCRIPT_BTC_TYPE::P2PKH;
//        output.stdOutput.address = (char*)root["outputs"][i]["address"].asCString();
//        output.stdOutput.amount = root["outputs"][i]["amount"].asUInt64();
//        output.stdOutput.changeAddress = (JUB_ENUM_BOOL)root["outputs"][i]["change_address"].asBool();
//        if (output.stdOutput.changeAddress) {
//            output.stdOutput.path.change = (JUB_ENUM_BOOL)root["outputs"][i]["bip32_path"]["change"].asBool();
//            output.stdOutput.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();
//            rv = JUB_GetAddressBTC(contextID,
//                                   output.stdOutput.path, JUB_ENUM_BOOL::BOOL_FALSE, &changeAddress);
//            if (JUBR_OK == rv) {
//                output.stdOutput.address = changeAddress;
//            }
//        }
//        outputs.push_back(output);
        
        BitcoinProtosOutputBTC * output = [[BitcoinProtosOutputBTC alloc]init];
        output.type = BitcoinProtosENUM_SCRIPT_TYPE_BTC_ScP2Pkh;
        output.stdOutput.address = [NSString stringWithCString:root["outputs"][i]["address"].asCString() encoding:NSUTF8StringEncoding];
        
        output.stdOutput.amount = root["outputs"][i]["amount"].asUInt64();
        output.stdOutput.changeAddress = root["outputs"][i]["change_address"].asBool();
        if (output.stdOutput.changeAddress) {
            output.stdOutput.path.change = (JUB_ENUM_BOOL)root["outputs"][i]["bip32_path"]["change"].asBool();
            output.stdOutput.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();
            CommonProtosResultString * rvStr = [g_sdk
                                                getAddressBTC:contextID pbPath:output.stdOutput.path bShow:NO];
            rv = rvStr.stateCode;
            if (JUBR_OK == rv) {
                NSString * changeAddress = rvStr.value;
                output.stdOutput.address = changeAddress;
            }
        }

        [pbTransaction.outputsArray addObject:output];
        
    }
    
//    OUTPUT_BTC QRC20_output;
//    JUB_CHAR_CPTR contractAddress = (char*)root["QRC20_contractAddr"].asCString();
//    JUB_UINT8 decimal = root["QRC20_decimal"].asUInt64();
//    JUB_CHAR_CPTR symbol = (char*)root["QRC20_symbol"].asCString();
//    JUB_UINT64 gasLimit = root["gasLimit"].asUInt64();
//    JUB_UINT64 gasPrice = root["gasPrice"].asUInt64();
//    JUB_CHAR_CPTR to = (char*)root["QRC20_to"].asCString();
//    JUB_CHAR_CPTR value = (char*)root["QRC20_amount"].asCString();

//    if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
//        value = (char*)[amount UTF8String];
//    }
//    rv = JUB_BuildQRC20Outputs(contextID,
//                               contractAddress, decimal, symbol,
//                               gasLimit, gasPrice,
//                               to, value,
//                               &QRC20_output);
    
    NSString * contractAddress = [NSString stringWithFormat:@"%s",root["QRC20_contractAddr"].asCString()];
    JUB_UINT8 decimal = root["QRC20_decimal"].asUInt64();
    NSString * symbol = [NSString stringWithFormat:@"%s",(char*)root["QRC20_symbol"].asCString()];
    JUB_UINT64 gasLimit = root["gasLimit"].asUInt64();
    JUB_UINT64 gasPrice = root["gasPrice"].asUInt64();
    NSString * to = [NSString stringWithFormat:@"%s",root["QRC20_to"].asCString()];
    NSString * value = [NSString stringWithFormat:@"%s",root["QRC20_amount"].asCString()];
    if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
        value = amount;
    }

    CommonProtosResultAny * rvAny = [g_sdk buildQRC20Outputs:contextID contractAddr:contractAddress decimal:decimal symbol:symbol gasLimit:gasLimit gasPrice:gasPrice to:to value:value];
    rv = rvAny.stateCode;
    
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildQRC20Outputs() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        if (nil != changeAddress) {
//            rv = JUB_FreeMemory(changeAddress);
//        }
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildQRC20Outputs() OK.]"]];
//    outputs.emplace_back(QRC20_output);
    NSArray * outpusArrs = rvAny.valueArray;
    NSMutableArray * pbArr = outpusArrs[0];
    [pbTransaction.outputsArray addObject:pbArr[0]];
    
    
    char* raw = nullptr;

    CommonProtosResultString * rvStr = [g_sdk signTransactionBTC:contextID pbTx:pbTransaction];
    rv = rvStr.stateCode;
//    rv = JUB_SignTransactionBTC(contextID, version, &inputs[0], (JUB_UINT16)inputs.size(), &outputs[0], (JUB_UINT16)outputs.size(), 0, &raw);
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//    if (nil != changeAddress) {
//        rv = JUB_FreeMemory(changeAddress);
//    }
    if (JUBR_USER_CANCEL == rv) {
        [self addMsgData:[NSString stringWithFormat:@"[User cancel the transaction !]"]];
        return rv;
    }
    raw = (char*)rvStr.value.UTF8String;
    if (   JUBR_OK != rv
        || nullptr == raw
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[Error sign tx.]"]];
        return rv;
    }
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


- (NSUInteger) transactionUSDT_proc:(NSUInteger)contextID
                             amount:(NSString*)amount
                               root:(Json::Value)root {
    
    JUB_RV rv = JUBR_ERROR;

    JUB_UINT32 version = root["ver"].asInt();
    
    std::vector<INPUT_BTC> inputs;
    std::vector<OUTPUT_BTC> outputs;
    BitcoinProtosTransactionBTC * pbTransaction = [[BitcoinProtosTransactionBTC alloc]init];
    pbTransaction.inputsArray = [NSMutableArray array];
    pbTransaction.outputsArray = [NSMutableArray array];
    pbTransaction.version = version;
    int inputNumber = root["inputs"].size();
    
    for (int i = 0; i < inputNumber; i++) {
//        INPUT_BTC input;
//        input.type = JUB_ENUM_SCRIPT_BTC_TYPE::P2PKH;
//        input.preHash = (char*)root["inputs"][i]["preHash"].asCString();
//        input.preIndex = root["inputs"][i]["preIndex"].asInt();
//        input.path.change = (JUB_ENUM_BOOL)root["inputs"][i]["bip32_path"]["change"].asBool();
//        input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
//        input.amount = root["inputs"][i]["amount"].asUInt64();
//        input.nSequence = 0xffffffff;
//        inputs.push_back(input);
        BitcoinProtosInputBTC * input = [[BitcoinProtosInputBTC alloc]init];
        input.preHash = [NSString stringWithCString:root["inputs"][i]["preHash"].asCString() encoding:NSUTF8StringEncoding];
        input.preIndex = root["inputs"][i]["preIndex"].asInt();
        input.path.change = (JUB_ENUM_BOOL)root["inputs"][i]["bip32_path"]["change"].asBool();
        input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
        input.amount = root["inputs"][i]["amount"].asUInt64();
        [pbTransaction.inputsArray addObject:input];
    }
    
    int outputNumber = root["outputs"].size();
    
    JUB_CHAR_PTR changeAddress = nil;
    for (int i = 0; i < outputNumber; i++) {
//        OUTPUT_BTC output;
//        output.type = JUB_ENUM_SCRIPT_BTC_TYPE::P2PKH;
//        output.stdOutput.address = (char*)root["outputs"][i]["address"].asCString();
//        output.stdOutput.amount = root["outputs"][i]["amount"].asUInt64();
//        output.stdOutput.changeAddress = (JUB_ENUM_BOOL)root["outputs"][i]["change_address"].asBool();
//        if (output.stdOutput.changeAddress) {
//            output.stdOutput.path.change = (JUB_ENUM_BOOL)root["outputs"][i]["bip32_path"]["change"].asBool();
//            output.stdOutput.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();
//
//            rv = JUB_GetAddressBTC(contextID,
//                                   output.stdOutput.path, JUB_ENUM_BOOL::BOOL_FALSE, &changeAddress);
//            if (JUBR_OK == rv) {
//                output.stdOutput.address = changeAddress;
//            }
//        }
//        outputs.push_back(output);
        BitcoinProtosOutputBTC * output = [[BitcoinProtosOutputBTC alloc]init];
        output.type = BitcoinProtosENUM_SCRIPT_TYPE_BTC_ScP2Pkh;
        output.stdOutput.address = [NSString stringWithCString:root["outputs"][i]["address"].asCString() encoding:NSUTF8StringEncoding];
        output.stdOutput.amount = root["outputs"][i]["amount"].asUInt64();
        output.stdOutput.changeAddress = (JUB_ENUM_BOOL)root["outputs"][i]["change_address"].asBool();
        if (output.stdOutput.changeAddress) {
            output.stdOutput.path.change = (JUB_ENUM_BOOL)root["outputs"][i]["bip32_path"]["change"].asBool();
            output.stdOutput.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();
            
            CommonProtosResultString * rvStr = [g_sdk getAddressBTC:contextID pbPath:output.stdOutput.path bShow:NO];
            rv = rvStr.stateCode;

            if (JUBR_OK == rv) {
                NSString * changeAddress = rvStr.value;
                output.stdOutput.address = changeAddress;
            }
        }
        [pbTransaction.outputsArray addObject:output];
    }
    
    OUTPUT_BTC USDT_outputs[2] = {};
    JUB_UINT64 USDTAmt = root["USDT_amount"].asUInt64();
    if (NSComparisonResult::NSOrderedSame != [amount compare:@""]) {
        USDTAmt = [amount longLongValue];
    }
    NSString * USDTToStr = [NSString stringWithCString:root["USDT_to"].asCString() encoding:NSUTF8StringEncoding];
//    rv = JUB_BuildUSDTOutputs(contextID, (char*)root["USDT_to"].asCString(), USDTAmt, USDT_outputs);
    CommonProtosResultAny * rvAny = [g_sdk buildUSDTOutputs:contextID USDTTo:USDTToStr amount:USDTAmt];
    rv = rvAny.stateCode;
    
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildUSDTOutputs() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        if (nil != changeAddress) {
//            rv = JUB_FreeMemory(changeAddress);
//        }
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_BuildUSDTOutputs() OK.]"]];
//    outputs.emplace_back(USDT_outputs[0]);
//    outputs.emplace_back(USDT_outputs[1]);
    NSArray * outpusArrs = rvAny.valueArray;
    NSMutableArray * pbArr = outpusArrs[0];
    [pbTransaction.outputsArray addObject:pbArr[0]];
    [pbTransaction.outputsArray addObject:pbArr[1]];

    
    char* raw = nullptr;
//    rv = JUB_SignTransactionBTC(contextID,
//                                version,
//                                &inputs[0], (JUB_UINT16)inputs.size(),
//                                &outputs[0], (JUB_UINT16)outputs.size(),
//                                0,
//                                &raw);
    CommonProtosResultString * rvStr = [g_sdk signTransactionBTC:contextID pbTx:pbTransaction];
    rv = rvStr.stateCode;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionBTC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//    if (nil != changeAddress) {
//        rv = JUB_FreeMemory(changeAddress);
//    }
    if (JUBR_USER_CANCEL == rv) {
        [self addMsgData:[NSString stringWithFormat:@"[User cancel the transaction !]"]];
        return rv;
    }
    raw = (char *)rvStr.value.UTF8String;
    if (   JUBR_OK != rv
        || nullptr == raw
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[Error sign tx.]"]];
        return rv;
    }
    if (raw) {
        size_t txLen = strlen(raw)/2;
        [self addMsgData:[NSString stringWithFormat:@"tx raw[%lu]: %s.", txLen, raw]];
//
//        rv = JUB_FreeMemory(raw);
//        if (JUBR_OK != rv) {
//            [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//            return rv;
//        }
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
    }
    
    return rv;
}


#pragma mark - Hcash applet
- (void)HC_test:(NSUInteger)deviceID
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
        
        CONTEXT_CONFIG_HC cfg;
        cfg.mainPath = (char*)root["main_path"].asCString();
        rv = JUB_CreateContextHC(cfg, (JUB_UINT16)deviceID, &contextID);
        if (JUBR_OK != rv) {
            [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextHC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
            return;
        }
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextHC() OK.]"]];
        [sharedData setCurrMainPath:[NSString stringWithFormat:@"%s", cfg.mainPath]];
        [sharedData setCurrContextID:contextID];
        
        [self CoinOptHC:contextID
                   root:root
                 choice:choice];
    }
    catch (...) {
        error_exit("[Error format json file.]\n");
        [self addMsgData:[NSString stringWithFormat:@"[JUB_CreateContextHC() OK.]"]];
    }
}


- (void) CoinOptHC:(NSUInteger)contextID
              root:(Json::Value)root
            choice:(int)choice {
    
    switch (choice) {
    case JUB_NS_ENUM_OPT::GET_ADDRESS:
    {
        [self get_address_pubkey_HC:contextID];
        break;
    }
    case JUB_NS_ENUM_OPT::SHOW_ADDRESS:
    {
        [self show_address_test_HC:contextID];
        break;
    }
    case JUB_NS_ENUM_OPT::TRANSACTION:
    {
        if (JUBR_OK != [self verify_user:contextID]) {
            break;
        }
        
        [self transaction_test:contextID
                        amount:[[JUBSharedData sharedInstance] amount]
                          root:root];
        break;
    }
    case JUB_NS_ENUM_OPT::SET_TIMEOUT:
    {
        [self set_time_out_test:contextID];
        break;
    }
    case JUB_NS_ENUM_OPT::SET_MY_ADDRESS:
    default:
        break;
    }   // switch (choice) end
}


- (void) get_address_pubkey_HC:(NSUInteger)contextID {
    
    JUB_RV rv = JUBR_ERROR;
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
    JUBSharedData *sharedData = [JUBSharedData sharedInstance];
    if (nil == sharedData) {
        return;
    }
    
    JUB_CHAR_PTR mainXpub;
//    rv = JUB_GetMainHDNodeHC(contextID, &mainXpub);
    rvStr = [g_sdk getMainHDNodeHC:contextID];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeHC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    mainXpub = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetMainHDNodeHC() OK.]"]];
    
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
    path.change = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
//    JUB_CHAR_PTR xpub;
//    rv = JUB_GetHDNodeHC(contextID, path, &xpub);
    rvStr = [g_sdk getHDNodeHC:contextID pbPath:path];
    rv = rvStr.stateCode;
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeHC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    JUB_CHAR_PTR xpub = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetHDNodeHC() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"input xpub(%@/%u/%llu): %s.", [sharedData currMainPath], path.change, path.addressIndex, xpub]];
//    rv = JUB_FreeMemory(xpub);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"] ];
    
//    JUB_CHAR_PTR address;
//    rv = JUB_GetAddressHC(contextID, path, BOOL_FALSE, &address);
    rvStr = [g_sdk getAddressHC:contextID pbPath:path bShow:NO];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressHC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    JUB_CHAR_PTR address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressHC() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"input address(%@/%d/%llu): %s.", [sharedData currMainPath], path.change, path.addressIndex, address]];
//    rv = JUB_FreeMemory(address);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
}


- (void) show_address_test_HC:(NSUInteger)contextID {
    
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
    path.change = [sharedData currPath].change;
    path.addressIndex = [sharedData currPath].addressIndex;
    
//    JUB_CHAR_PTR address;
//    rv = JUB_GetAddressHC(contextID, path, BOOL_TRUE, &address);
    rvStr = [g_sdk getAddressHC:contextID pbPath:path bShow:YES];
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressHC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return;
    }
    JUB_CHAR_PTR address = (JUB_CHAR_PTR)rvStr.value.UTF8String;
    [self addMsgData:[NSString stringWithFormat:@"[JUB_GetAddressHC() OK.]"]];
    [self addMsgData:[NSString stringWithFormat:@"Show address(%@/%d/%llu): %s.", [sharedData currMainPath], path.change, path.addressIndex, address]];
    
//    rv = JUB_FreeMemory(address);
//    if (JUBR_OK != rv) {
//        [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
//        return;
//    }
//    [self addMsgData:[NSString stringWithFormat:@"[JUB_FreeMemory() OK.]"]];
}


- (NSUInteger) transactionHC_proc:(NSUInteger)contextID
                           amount:(NSString*)amount
                             root:(Json::Value)root {
    HcashProtosTransactionHC * pbTransaction = [[HcashProtosTransactionHC alloc]init];
    JUB_RV rv = JUBR_ERROR;
    
    JUB_UINT32 version = root["ver"].asInt();
    
    //    std::vector< INPUT_HC>  inputs;
    //    std::vector<OUTPUT_HC> outputs;
    pbTransaction.inputsArray = [NSMutableArray array];
    pbTransaction.outputsArray = [NSMutableArray array];
    pbTransaction.version = version;
    pbTransaction.locktime = 0;
    int inputNumber = root["inputs"].size();
    
    for (int i = 0; i < inputNumber; i++) {
//        INPUT_HC input;
//        input.path.change = (JUB_ENUM_BOOL)root["inputs"][i]["bip32_path"]["change"].asBool();
//        input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
//        input.amount = root["inputs"][i]["amount"].asUInt64();
//        inputs.push_back(input);
        HcashProtosInputHC * input = [[HcashProtosInputHC alloc]init];
        input.path.change = root["inputs"][i]["bip32_path"]["change"].asBool();
        input.path.addressIndex = root["inputs"][i]["bip32_path"]["addressIndex"].asInt();
        input.amount = root["inputs"][i]["amount"].asUInt64();
        [pbTransaction.inputsArray addObject:input];
    }
    
    int outputNumber = root["outputs"].size();
    
    for (int i = 0; i < outputNumber; i++) {
//        OUTPUT_HC output;
//        output.changeAddress = (JUB_ENUM_BOOL)root["outputs"][i]["change_address"].asBool();
//        if (output.changeAddress) {
//            output.path.change = (JUB_ENUM_BOOL)root["outputs"][i]["bip32_path"]["change"].asBool();
//            output.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();
//        }
//        outputs.push_back(output);
        HcashProtosOutputHC * output = [[HcashProtosOutputHC alloc]init];
        output.changeAddress = root["outputs"][i]["change_address"].asBool();
        if (output.changeAddress) {
            output.path.change = root["outputs"][i]["bip32_path"]["change"].asBool();
            output.path.addressIndex = root["outputs"][i]["bip32_path"]["addressIndex"].asInt();
        }
        [pbTransaction.outputsArray addObject:output];
    }
    
    char* unsignedRaw = (char*)root["unsigned_tx"].asCString();
    
    char* raw = nullptr;
//    rv = JUB_SignTransactionHC(contextID,
//                               version,
//                               &inputs[0], (JUB_UINT16)inputs.size(),
//                               &outputs[0], (JUB_UINT16)outputs.size(),
//                               unsignedRaw,
//                               &raw);
    CommonProtosResultString * rvStr = [[CommonProtosResultString alloc]init];
    rvStr = [g_sdk signTransactionHC:contextID unsignedTrans:[NSString stringWithCString:unsignedRaw encoding:NSUTF8StringEncoding] pbTx:pbTransaction];
    rv = rvStr.stateCode;
    if (   JUBR_OK != rv
        || /*nullptr == raw*/rvStr.value.length
        ) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionHC() return %@ (0x%2lx).]", [JUBErrorCode GetErrMsg:rv], rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_SignTransactionHC() OK.]"]];
    raw = (JUB_CHAR_PTR)rvStr.value.UTF8String;
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

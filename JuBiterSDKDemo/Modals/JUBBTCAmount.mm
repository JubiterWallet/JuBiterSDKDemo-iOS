//
//  JUBBTCAmount.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/9/4.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBBTCAmount.h"
#import <JubSDKCore/JUB_SDK_BTC.h>


@implementation JUBBTCAmount


//+ (NSString*)title:(JUB_ENUM_BTC_UNIT_TYPE)coinUnit {
//
//    return [JUBAmount title:[JUBBTCAmount enumUnitToString:coinUnit]];
//}

+ (NSString *)title:(BitcoinProtosBTC_UNIT_TYPE)coinUnit
{
    return [JUBAmount title:[JUBBTCAmount enumUnitToString:coinUnit]];
}

//+ (NSString*)enumUnitToString:(JUB_ENUM_BTC_UNIT_TYPE)unit {
//
//    NSString* strUnit = TITLE_UNIT_mBTC;
//    switch (unit) {
//    case JUB_ENUM_BTC_UNIT_TYPE::BTC:
//        strUnit = TITLE_UNIT_BTC;
//        break;
//    case JUB_ENUM_BTC_UNIT_TYPE::cBTC:
//        strUnit = TITLE_UNIT_cBTC;
//        break;
//    case JUB_ENUM_BTC_UNIT_TYPE::uBTC:
//        strUnit = TITLE_UNIT_uBTC;
//        break;
//    case JUB_ENUM_BTC_UNIT_TYPE::Satoshi:
//        strUnit = TITLE_UNIT_Satoshi;
//        break;
//    case JUB_ENUM_BTC_UNIT_TYPE::mBTC:
//    default:
//        break;
//    }
//
//    return strUnit;
//}

+ (NSString*)enumUnitToString:(BitcoinProtosBTC_UNIT_TYPE)unit {
    
    NSString* strUnit = TITLE_UNIT_mBTC;
    switch (unit) {
    case BitcoinProtosBTC_UNIT_TYPE_Btc:
        strUnit = TITLE_UNIT_BTC;
        break;
    case BitcoinProtosBTC_UNIT_TYPE_CBtc:
        strUnit = TITLE_UNIT_cBTC;
        break;
    case BitcoinProtosBTC_UNIT_TYPE_UBtc:
        strUnit = TITLE_UNIT_uBTC;
        break;
    case BitcoinProtosBTC_UNIT_TYPE_Satoshi:
        strUnit = TITLE_UNIT_Satoshi;
        break;
    case BitcoinProtosBTC_UNIT_TYPE_MBtc:
    default:
        break;
    }
    
    return strUnit;
}


//+ (JUB_ENUM_BTC_UNIT_TYPE)stringToEnumUnit:(NSString*)unitString {
//
//    JUB_ENUM_BTC_UNIT_TYPE unit = JUB_ENUM_BTC_UNIT_TYPE::ns;
//
//    if ([unitString isEqual:TITLE_UNIT_BTC]) {
//        unit = JUB_ENUM_BTC_UNIT_TYPE::BTC;
//    }
//    else if ([unitString isEqual:TITLE_UNIT_cBTC]) {
//        unit = JUB_ENUM_BTC_UNIT_TYPE::cBTC;
//    }
//    else if ([unitString isEqual:TITLE_UNIT_mBTC]) {
//        unit = JUB_ENUM_BTC_UNIT_TYPE::mBTC;
//    }
//    else if ([unitString isEqual:TITLE_UNIT_uBTC]) {
//        unit = JUB_ENUM_BTC_UNIT_TYPE::uBTC;
//    }
//    else if ([unitString isEqual:TITLE_UNIT_Satoshi]) {
//        unit = JUB_ENUM_BTC_UNIT_TYPE::Satoshi;
//    }
//
//    return unit;
//}

+ (BitcoinProtosBTC_UNIT_TYPE)stringToEnumUnit:(NSString*)unitString
{
    BitcoinProtosBTC_UNIT_TYPE unit = BitcoinProtosBTC_UNIT_TYPE_Btc;
    if ([unitString isEqual:TITLE_UNIT_BTC]) {
        unit = BitcoinProtosBTC_UNIT_TYPE_Btc;
    }
    else if ([unitString isEqual:TITLE_UNIT_cBTC]) {
        unit = BitcoinProtosBTC_UNIT_TYPE_CBtc;
    }
    else if ([unitString isEqual:TITLE_UNIT_mBTC]) {
        unit = BitcoinProtosBTC_UNIT_TYPE_MBtc;
    }
    else if ([unitString isEqual:TITLE_UNIT_uBTC]) {
        unit = BitcoinProtosBTC_UNIT_TYPE_UBtc;
    }
    else if ([unitString isEqual:TITLE_UNIT_Satoshi]) {
        unit = BitcoinProtosBTC_UNIT_TYPE_Satoshi;
    }
    
    return unit;
}


//+ (NSUInteger)enumUnitToDecimal:(JUB_ENUM_BTC_UNIT_TYPE)unit {
//
//    NSUInteger decimal = 0;
//
//    switch (unit) {
//    case JUB_ENUM_BTC_UNIT_TYPE::BTC:
//        decimal = 8;
//        break;
//    case JUB_ENUM_BTC_UNIT_TYPE::cBTC:
//        decimal = 6;
//        break;
//    case JUB_ENUM_BTC_UNIT_TYPE::mBTC:
//        decimal = 5;
//        break;
//    case JUB_ENUM_BTC_UNIT_TYPE::uBTC:
//        decimal = 2;
//        break;
//    case JUB_ENUM_BTC_UNIT_TYPE::Satoshi:
//        decimal = 8;
//        break;
//    default:
//        break;
//    }
//
//    return decimal;
//}

+ (NSUInteger)enumUnitToDecimal:(BitcoinProtosBTC_UNIT_TYPE)unit {
    
    NSUInteger decimal = 0;
    
    switch (unit) {
    case BitcoinProtosBTC_UNIT_TYPE_Btc:
        decimal = 8;
        break;
    case BitcoinProtosBTC_UNIT_TYPE_CBtc:
        decimal = 6;
        break;
    case BitcoinProtosBTC_UNIT_TYPE_MBtc:
        decimal = 5;
        break;
    case BitcoinProtosBTC_UNIT_TYPE_UBtc:
        decimal = 2;
        break;
    case BitcoinProtosBTC_UNIT_TYPE_Satoshi:
        decimal = 8;
        break;
    default:
        break;
    }
    
    return decimal;
}


+ (NSString*)convertToProperFormat:(NSString*)amount
                               opt:(JUB_NS_ENUM_BTC_COIN)opt {
    
    NSString *amt = amount;
    if (   nil == amount
        || [amount isEqual:@""]
        ) {
        return amt;
    }
    
    switch (opt) {
    case JUB_NS_ENUM_BTC_COIN::BTN_QTUM_QRC20:
        amt = [JUBAmount convertToTheSmallestUnit:amount
                                            point:@"."
                                          decimal:decimalQRC20];
        break;
    case JUB_NS_ENUM_BTC_COIN::BTN_USDT:
        amt = [JUBAmount convertToTheSmallestUnit:amount
                                            point:@"."
                                          decimal:decimalUSDT];
        break;
    default:
        break;
    }
    
    return amt;
}


@end

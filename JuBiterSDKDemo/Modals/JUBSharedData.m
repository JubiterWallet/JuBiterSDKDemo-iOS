//
//  JUBSharedData.m
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/8/10.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"


JubSDK* g_sdk;


@implementation JUBSharedData
@synthesize currDeviceID = _currDeviceID;

static JUBSharedData *_sharedDataInstance;


- (id) init {
    
    if (self = [super init]) {
        // custom initialization
        if (nil == g_sdk) {
            g_sdk = [[JubSDK alloc] init];
        }
        
        _optItem = 0;
        
        _userPin = nil;
        _neoPin = nil;
        _deviceCert = nil;
        
        _verifyMode = VERIFY_MODE_ITEM;
        _deviceType = SEG_NFC;
//        _coinUnit = mBTC;
        _coinUnit = BitcoinProtosBTC_UNIT_TYPE_MBtc;
        _comMode = COMMODE_NS_ITEM;
        _deviceClass = DEVICE_NS_ITEM;

        _currDeviceID = 0;
        _currContextID = 0;
    }
    
    return self;
}


+ (JUBSharedData *) sharedInstance {
    
    if (!_sharedDataInstance) {
        _sharedDataInstance = [[JUBSharedData alloc] init];
    }
    
    return _sharedDataInstance;
}


@end

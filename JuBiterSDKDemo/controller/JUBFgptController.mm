//
//  JUBFgptController.mm
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/8/13.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBPinAlertView.h"
#import "JUBSharedData.h"

#import "JUBFgptController.h"


@interface JUBFgptController ()

@end


@implementation JUBFgptController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.optItem = JUB_NS_ENUM_MAIN::OPT_DEVICE;
//
//    NSArray *buttonTitleArray = @[
//        BUTTON_TITLE_QUERYBATTERY,
//        BUTTON_TITLE_DEVICEINFO,
//        BUTTON_TITLE_DEVICEAPPLETS,
//        BUTTON_TITLE_DEVICECERT,
//        BUTTON_TITLE_DEVICE_CHANGEPIN,
////        BUTTON_TITLE_SENDONEAPDU,
//        BUTTON_TITLE_DEVICE_RESET,
//        BUTTON_TITLE_GENERATESEED,
//        BUTTON_TITLE_IMPORTMNEMONIC12,
//        BUTTON_TITLE_IMPORTMNEMONIC18,
//        BUTTON_TITLE_IMPORTMNEMONIC24,
//        BUTTON_TITLE_EXPORTMNEMONIC,
//    ];
//
//    NSMutableArray *buttonModelArray = [NSMutableArray array];
//
//    for (NSString *title in buttonTitleArray) {
//
//        JUBButtonModel *model = [[JUBButtonModel alloc] init];
//
//        model.title = title;
//
//        //默认支持全部通信类型，不传就是默认，如果传多个通信类型可以直接按照首页顶部的通信类型index传，比如说如果支持NFC和BLE，则直接传@"01"即可，同理如果只支持第一和第三种通信方式，则传@"02"
//        if (   [title isEqual:BUTTON_TITLE_DEVICE_CHANGEPIN]
//            || [title isEqual:BUTTON_TITLE_DEVICE_RESET]
//            || [title isEqual:BUTTON_TITLE_GENERATESEED]
//            || [title isEqual:BUTTON_TITLE_IMPORTMNEMONIC12]
//            || [title isEqual:BUTTON_TITLE_IMPORTMNEMONIC18]
//            || [title isEqual:BUTTON_TITLE_IMPORTMNEMONIC24]
//            ) {
//            model.transmitTypeOfButton = [NSString stringWithFormat:@"%li",
//                                          (long)JUB_NS_ENUM_DEV_TYPE::SEG_NFC];
//        }
//        else if ([title isEqual:BUTTON_TITLE_QUERYBATTERY]) {
//            model.transmitTypeOfButton = [NSString stringWithFormat:@"%li",
//                                          (long)JUB_NS_ENUM_DEV_TYPE::SEG_BLE];
//        }
//        else {
//            model.transmitTypeOfButton = [NSString stringWithFormat:@"%li%li",
//                                          (long)JUB_NS_ENUM_DEV_TYPE::SEG_NFC,
//                                          (long)JUB_NS_ENUM_DEV_TYPE::SEG_BLE];
//        }
//
//        [buttonModelArray addObject:model];
//    }
//
//    self.buttonArray = buttonModelArray;
    
}


//测试类型的按钮点击回调
- (void)selectedTestActionTypeIndex:(NSInteger)index {
    
    NSLog(@"JUBDeviceController--selectedTransmitTypeIndex = %ld, Type = %ld, selectedTestActionType = %ld", (long)self.selectedTransmitTypeIndex, (long)self.selectCoinTypeIndex, (long)index);
    
    self.optIndex = index;
    
    switch (self.selectedTransmitTypeIndex) {
    case JUB_NS_ENUM_DEV_TYPE::SEG_BLE:
    {
        [self beginBLESession];
        break;
    }
    case JUB_NS_ENUM_DEV_TYPE::SEG_NFC:
    default:
        break;
    }
    
}




#pragma mark - 业务
- (void)enroll_fgpt_test:(JUB_UINT16)deviceID {
    
    JUB_RV rv = JUBR_ERROR;
    
    JUB_BYTE fgptIndex = 0;
    JUB_ULONG times = 0;
    JUB_BYTE fgptID = 0;
    rv = JUB_EnrollFingerprint(deviceID, &fgptIndex, &times, &fgptID);
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_EnrollFingerprint() return 0x%2lx.]", rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_EnrollFingerprint() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"FingerprintID is: %i.", fgptID]];
}


- (void)enum_fgpt_test:(JUB_UINT16)deviceID {
    
    JUB_RV rv = JUBR_ERROR;
    
    JUB_CHAR_PTR fgptList = nil;
    rv = JUB_EnumFingerprint(deviceID, &fgptList);
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_EnumFingerprint() return 0x%2lx.]", rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_EnumFingerprint() OK.]"]];
    
    std::string fingerprintList = fgptList;
    JUB_FreeMemory(fgptList);
    
    [self addMsgData:[NSString stringWithFormat:@"FingerprintIDs are: %@.", [NSString stringWithUTF8String:fingerprintList.c_str()]]];
}


- (void)erase_fgpt_test:(JUB_UINT16)deviceID {
    
    JUB_RV rv = JUBR_ERROR;
    
    rv = JUB_EraseFingerprint(deviceID);
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_EraseFingerprint() return 0x%2lx.]", rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_EraseFingerprint() OK.]"]];
}


- (void)delete_fgpt_test:(JUB_UINT16)deviceID {
    
    JUB_RV rv = JUBR_ERROR;
    
    JUB_BYTE fgptID = 0;
    rv = JUB_DeleteFingerprint(deviceID, fgptID);
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_DeleteFingerprint() return 0x%2lx.]", rv]];
        return;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_DeleteFingerprint() OK.]"]];
}


@end

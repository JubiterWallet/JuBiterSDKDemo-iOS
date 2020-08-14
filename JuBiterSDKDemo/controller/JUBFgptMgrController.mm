//
//  JUBFgptMgrController.m
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/8/13.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"
#import "JUBFingerEntryAlert.h"


#import "JUBFgptMgrController.h"


@interface JUBFgptMgrController ()

@end

@implementation JUBFgptMgrController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //这个fingerArray可以任意时候向他赋值,界面会自动更新
    if (JUBR_OK != [self enum_fgpt_test:[[[JUBSharedData sharedInstance] currDeviceID] intValue]]) {
        [self setFingerArray:nil];
    }
}


#pragma mark - 业务
- (JUB_RV)enum_fgpt_test:(JUB_UINT16)deviceID {
    
    JUB_RV rv = JUBR_ERROR;
    
    JUB_CHAR_PTR fgptList = nil;
    rv = JUB_EnumFingerprint(deviceID, &fgptList);
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_EnumFingerprint() return 0x%2lx.]", rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_EnumFingerprint() OK.]"]];
    
    NSString* fingerprintList = [NSString stringWithUTF8String:std::string(fgptList).c_str()];
    JUB_FreeMemory(fgptList);
    
    [self addMsgData:[NSString stringWithFormat:@"FingerprintIDs are: %@.", fingerprintList]];
    
    [self setFingerArray:[fingerprintList componentsSeparatedByString:@" "]];
    
    return rv;
}


- (FgptEnrollInfo)enroll_fgpt_test:(JUB_UINT16)deviceID
                         fgptIndex:(NSUInteger)fgptIndex {
    
    JUB_RV rv = JUBR_ERROR;
    
    NSUInteger fgptNextIndex = fgptIndex;
    JUB_ULONG times = 0;
    NSUInteger assignedID = 0;
    rv = JUB_EnrollFingerprint(deviceID,
                               (JUB_BYTE_PTR)(&fgptNextIndex), &times,
                               (JUB_BYTE_PTR)(&assignedID));
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_EnrollFingerprint() return 0x%2lx.]", rv]];
        return FgptEnrollInfo{assignedID, fgptNextIndex, times, rv};
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_EnrollFingerprint() OK.]"]];
    
    [self addMsgData:[NSString stringWithFormat:@"FingerprintID is: %lu.", assignedID]];
    
    return FgptEnrollInfo{assignedID, fgptNextIndex, times, rv};
}


- (JUB_RV)erase_fgpt_test:(JUB_UINT16)deviceID {
    
    JUB_RV rv = JUBR_ERROR;
    
    rv = JUB_EraseFingerprint(deviceID);
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_EraseFingerprint() return 0x%2lx.]", rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_EraseFingerprint() OK.]"]];
    
    return rv;
}


- (JUB_RV)delete_fgpt_test:(JUB_UINT16)deviceID
                    fgptID:(JUB_BYTE)fgptID {
    
    JUB_RV rv = JUBR_ERROR;
    
    rv = JUB_DeleteFingerprint(deviceID, fgptID);
    if (JUBR_OK != rv) {
        [self addMsgData:[NSString stringWithFormat:@"[JUB_DeleteFingerprint() return 0x%2lx.]", rv]];
        return rv;
    }
    [self addMsgData:[NSString stringWithFormat:@"[JUB_DeleteFingerprint() OK.]"]];
    
    return rv;
}


//指纹录入
- (void)fingerPrintEntry {
    
//    JUBFingerEntryAlert *fingerEntryAlert = [JUBFingerEntryAlert show];
    
//    [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
//
//        //在你使用的时候直接使用这部分内容就可以，定时器可以去掉了
//        if (fingerEntryAlert.fingerNumber == 5) {
//
//            [timer invalidate];
//
//            [fingerEntryAlert dismiss];
//
//            return;
//
//        }
//
//        //这个fingerNumber可以任意时候向他赋值,界面会自动更新
//        fingerEntryAlert.fingerNumber = fingerEntryAlert.fingerNumber + 1;
//
//    }];
    
    FgptEnrollInfo fgptEnrollInfo = [self enroll_fgpt_test:[[[JUBSharedData sharedInstance] currDeviceID] intValue]
                                                 fgptIndex:0];
    if (JUBR_OK != fgptEnrollInfo.rv) {
        return;
    }
}


//清空指纹
- (void)clearFingerPrint {
    
    //向设备发送清空指纹的指令
    //
    if (JUBR_OK != [self erase_fgpt_test:[[[JUBSharedData sharedInstance] currDeviceID] intValue]]) {
        return;
    }
    
    //这里应该先完成与设备的通信，设备清空成功，再刷新界面，如果通信失败，则不刷新界面
    self.fingerArray = nil;
}


//删除指纹
- (void)selectedFinger:(NSInteger)selectedFingerIndex {
    
    NSLog(@"selectedFingerIndex = %ld", (long)selectedFingerIndex);
    
    //向设备发送清空指纹的指令
    //
    if (JUBR_OK != [self delete_fgpt_test:[[[JUBSharedData sharedInstance] currDeviceID] intValue]
                                   fgptID:(JUB_BYTE)selectedFingerIndex]) {
        return;
    }
    
    //这里应该先完成与设备的通信，设备清空成功，再刷新界面，如果通信失败，则不刷新界面
    NSMutableArray *fingerArray = [self.fingerArray mutableCopy];
    
    [fingerArray removeObjectAtIndex:selectedFingerIndex];
    
    self.fingerArray = fingerArray;
}

@end

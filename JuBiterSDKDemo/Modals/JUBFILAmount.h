//
//  JUBFILAmount.h
//  JuBiterSDKDemo
//
//  Created by Administrator on 2021/1/26.
//  Copyright © 2021 pengshanshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUBAmount.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JUB_NS_ENUM_FIL_COIN) {
    BTN_FIL
};

#define TITLE_FIL       @"Transfer"


#define TITLE_UNIT_FIL       @"FIL"

static NSUInteger decimalFIL = 6;

@interface JUBFILAmount : JUBAmount

+ (NSString*)title:(JUB_NS_ENUM_FIL_COIN)opt;
+ (NSString*)formatRules;

+ (NSString*)enumUnitToString:(JUB_NS_ENUM_FIL_COIN)opt;
+ (NSString*)enumUnitToUnitStr:(JUB_NS_ENUM_FIL_COIN)opt;

+ (BOOL)isValid:(NSString*)amount;
+ (BOOL)isValid:(NSString*)amount
            opt:(JUB_NS_ENUM_FIL_COIN)opt;

+ (NSString*)convertToProperFormat:(NSString*)amount
                               opt:(JUB_NS_ENUM_FIL_COIN)opt;

@end

NS_ASSUME_NONNULL_END

//
//  JUBSharedData.m
//  JuBiterSDKDemo
//
//  Created by panmin on 2020/8/10.
//  Copyright © 2020 JuBiter. All rights reserved.
//

#import "JUBSharedData.h"


@implementation JUBSharedData
@synthesize currDeviceID = _currDeviceID;

static JUBSharedData *_sharedDataInstance;


- (id) init {
    
    if (self = [super init]) {
        // custom initialization
    }
    
    return self;
}


+ (JUBSharedData  *) sharedInstance {
    
    if (!_sharedDataInstance) {
        _sharedDataInstance = [[JUBSharedData alloc] init];
    }
    
    return _sharedDataInstance;
}

@end

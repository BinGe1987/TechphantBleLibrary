//
//  BluetoothClientManager.m
//  JXBlueSDK
//
//  Created by BinGe on 2019/8/12.
//  Copyright © 2019 JX. All rights reserved.
//

#import "BluetoothClientManager.h"


@implementation BluetoothClientManager

static BluetoothClient *cline;

+ (BluetoothClient *)getClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cline = [BluetoothClient new];
    });
    return cline;
}

@end

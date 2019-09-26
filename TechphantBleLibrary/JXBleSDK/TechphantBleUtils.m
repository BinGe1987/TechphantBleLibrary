//
//  TechphantBleUtils.m
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/19.
//  Copyright © 2019 JX. All rights reserved.
//

#import "TechphantBleUtils.h"
#import "BabyBluetooth.h"
#import <UIKit/UIKit.h>
#import "BluetoothClientManager.h"

@implementation TechphantBleUtils

+ (BOOL)isBluetoothSupported {
    return !([BabyBluetooth shareBabyBluetooth].centralManager.state == CBManagerStateUnsupported);
}

+ (BOOL)isBluetoothEnable {
    return [BabyBluetooth shareBabyBluetooth].centralManager.state == CBManagerStatePoweredOn;
}

+ (BOOL)isBluetoothState {
    return [BabyBluetooth shareBabyBluetooth].centralManager.state;
}

+ (NSArray *)getConnectedBTLeDevices {
    return [[BabyBluetooth shareBabyBluetooth] findConnectedPeripherals];
}

@end

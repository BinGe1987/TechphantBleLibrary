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

@implementation TechphantBleUtils

+ (BOOL)isBluetoothEnable {
    return [BabyBluetooth shareBabyBluetooth].centralManager.state == CBManagerStatePoweredOn;
}

@end

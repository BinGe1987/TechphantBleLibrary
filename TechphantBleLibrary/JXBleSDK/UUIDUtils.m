//
//  UUIDUtils.m
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/21.
//  Copyright © 2019 JX. All rights reserved.
//

#import "UUIDUtils.h"

/**
 * 主服务
 */
NSString * const UUID_MASTER_SERVER = @"FFF0";
/**
 * 写
 */
NSString * const UUID_MASTER_WRITE = @"FFF6";
/**
 * 通知
 */
NSString * const UUID_MASTER_NOTIFY= @"FFF4";
/**
 * 配置
 */
NSString * const UUID_MASTER_CONFIG= @"2902";

/**
 * 设备内容
 */
NSString * const UUID_DEVICES_SERVER= @"180A";
/**
 * 蓝牙版本
 */
NSString * const UUID_DEVICES_BLE_VERSION_CODE= @"2A26";
/**
 * MCU版本
 */
NSString * const UUID_DEVICES_MCU_VERSION_CODE= @"2A28";
/**
 * 协议版本
 */
NSString * const UUID_DEVICES_MCU_AGREEMENT_CODE= @"2A24";

@implementation UUIDUtils

@end

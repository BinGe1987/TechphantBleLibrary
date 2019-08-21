//
//  UUIDUtils.h
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/21.
//  Copyright © 2019 JX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 主服务
 */
extern NSString * const UUID_MASTER_SERVER;
/**
 * 写
 */
extern NSString * const UUID_MASTER_WRITE;
/**
 * 通知
 */
extern NSString * const UUID_MASTER_NOTIFY;
/**
 * 配置
 */
extern NSString * const UUID_MASTER_CONFIG;

/**
 * 设备内容
 */
extern NSString * const UUID_DEVICES_SERVER;
/**
 * 蓝牙版本
 */
extern NSString * const UUID_DEVICES_BLE_VERSION_CODE;
/**
 * MCU版本
 */
extern NSString * const UUID_DEVICES_MCU_VERSION_CODE;
/**
 * 协议版本
 */
extern NSString * const UUID_DEVICES_MCU_AGREEMENT_CODE;


@interface UUIDUtils : NSObject

@end

NS_ASSUME_NONNULL_END

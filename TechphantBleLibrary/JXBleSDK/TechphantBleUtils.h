//
//  TechphantBleUtils.h
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/19.
//  Copyright © 2019 JX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TechphantBleUtils : NSObject

/**
 * 查看是否支持蓝牙
 *
 * @return True:支持 False:不支持
 */
+ (BOOL)isBluetoothSupported;
/**
 * 蓝牙固件是否可用
 *
 * @return 返回蓝牙是否可用
 */
+ (BOOL)isBluetoothEnable;
/**
 * 获取已连接的低功耗蓝牙设备
 * @return 返回低功耗蓝牙连接列表
 */
+ (NSArray *)getConnectedBTLeDevices;

@end

NS_ASSUME_NONNULL_END

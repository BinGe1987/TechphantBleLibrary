//
//  BluetoothClient.h
//  JXBlueSDK
//
//  Created by BinGe on 2019/8/12.
//  Copyright © 2019 JX. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BTScanRequestOptions.h"
#import "ScanResultModel.h"

NS_ASSUME_NONNULL_BEGIN


/**
 蓝牙状态监听器

 @param isBleOpen 参数为蓝牙的开关状态
 */
typedef void (^BleStateChangeListener)(BOOL isBleOpen);

@interface BluetoothClient : NSObject


/**
 设置蓝牙状态监听器

 @param listener 监听器代理
 */
- (void)setOnBleStateChangeListener:(_Nullable BleStateChangeListener) listener;

/**
 判断蓝牙是否已打开

 @return 打开返回YES，关闭返回NO
 */
- (BOOL)isBleOpen;


/**
 打开蓝牙

 @return 打开成功返回YES，打开失败返回NO
 */
//- (BOOL)openBle;


/**
搜索设备

 @param request 搜索参数（包含时间，重试次数）
 @param onStarted 开始搜索回调
 @param onDeviceFound 发现设备回调
 @param onStopped 停止搜索回调
 @param onCanceled 取消搜索回调
 */
- (void)startScan:(BTScanRequestOptions * _Nullable)request onStarted:(void(^)(void))onStarted onDeviceFound:(void (^)(ScanResultModel *model))onDeviceFound onStopped:(void(^)(void))onStopped onCanceled:(void(^)(void))onCanceled;

/**
 停止搜索
 */
- (void)stopScan;


/**
 连接设备

 @param model 连接的设备数据
 */
- (void)connect:(ScanResultModel *)model onConnectedStateChange:(void (^)(int state))onConnectedStateChange onServiceDiscover:(void (^)(void))onServiceDiscover onCharacteristicChange:(void (^)(NSString *serviceUUID, NSString *characterUUID, NSData *value))onCharacteristicChange onCharacteristicWrite:(void (^)(NSString *serviceUUID, NSString *characterUUID, NSData *value))onCharacteristicWrite onCharacteristicRead:(void (^)(NSString *serviceUUID, NSString *characterUUID, NSData *value))onCharacteristicRead;

/**
 断开连接
 
 @param model 断开连接的设备数据
 */
- (void)disconnect:(ScanResultModel * _Nullable)model;


/**
 发送数据

 @param serviceUUID 接收数据的服务
 @param characteristicUUID 接收数据的服务对应的特征
 @param value 发送的数据
 */
- (void)sendWithService:(NSString *)serviceUUID characteristic:(NSString *)characteristicUUID value:(NSData *)value block:(void(^)(NSArray *array))block;

@end

NS_ASSUME_NONNULL_END

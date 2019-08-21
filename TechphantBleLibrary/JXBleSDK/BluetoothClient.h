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
#import "BTConnectOptions.h"
#import "ScanResultModel.h"
#import "CodeUtils.h"
#import "UUIDUtils.h"

NS_ASSUME_NONNULL_BEGIN

/**
 蓝牙状态监听器

 @param isBleOpen 参数为蓝牙的开关状态
 */
typedef void (^BleStateChangeListener)(BOOL isBleOpen);

//读取特征值的block，在connect时传入
typedef void (^onReadChangedBlock)(NSString *uuid, NSInteger status, NSString *value);
//写入特征值的block，在connect时传入
typedef void (^onWriteChangedBlock)(NSString *uuid, NSInteger status, NSString *value);
//特征值变化的block，在connect时传入
typedef void (^onReceivedChangedBlock)(NSString *uuid, NSArray *values);


@interface BluetoothClient : NSObject


/**
 设置蓝牙状态监听器

 @param listener 监听器代理
 */
- (void)setOnBleStateChangeListener:(_Nullable BleStateChangeListener) listener;

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

 @param address 设备的mac地址
 @param options 连接选项
 @param onConnectedStateChange 设备连接状态回调
 @param onReadChanged 读取180A服务特征值回调
 @param onWriteChanged 写FFF0服务特征值回调
 @param onReceivedChanged FFF0服务特征值变化回调
 */
- (void)connect:(NSString *)address options:(BTConnectOptions *)options
            onConnectedStateChange:(void (^)(NSInteger state))onConnectedStateChange
            onReadChanged:(onReadChangedBlock)onReadChanged
            onWriteChanged:(onWriteChangedBlock)onWriteChanged
            onReceivedChanged:(onReceivedChangedBlock)onReceivedChanged;

/**
 断开连接
 */
- (void)disconnect:(NSString *)address;


/**
 读取特征值，通过connect时的onReadChanged回调

 @param uuid 特征的UUID
 */
- (NSInteger)readCharacterInfo:(NSString *)uuid;

/**
发送数据
 
 @param address 设备的mac地址
 @param commands 发送的命令组
 */
- (NSInteger)send:(NSString *)address command:(NSArray<NSString *> *)commands;

@end

NS_ASSUME_NONNULL_END

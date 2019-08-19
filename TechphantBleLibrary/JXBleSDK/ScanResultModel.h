//
//  ScanResultModel.h
//  JXBleDemo
//
//  Created by BinGe on 2019/8/13.
//  Copyright © 2019 JX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanResultModel : NSObject

//源数据
@property (nonatomic, assign) id peripheral;

//外设名称
@property (nonatomic, copy) NSString *name;

//蓝牙地址
@property (nonatomic, copy) NSString *address;

//蓝牙密钥ID
@property (nonatomic, copy) NSString *btSecretID;

//mcu版本号
@property (nonatomic, copy) NSString *mcuVersionCode;

//信号量
@property (nonatomic, assign) NSInteger rssi;

//是否绑定标志位
@property (nonatomic, assign) NSInteger bindingStatus;

//广播内容
@property (nonatomic) Byte* scanRecord;




@end

NS_ASSUME_NONNULL_END

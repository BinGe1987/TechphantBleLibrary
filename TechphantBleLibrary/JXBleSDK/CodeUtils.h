//
//  CodeUtils.h
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/21.
//  Copyright © 2019 JX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//CONNECT
extern NSInteger const  TP_CODE_CONNECT;//连接
extern NSInteger const  TP_CODE_DISCONNECT;//断开
extern NSInteger const  TP_CODE_READ;
extern NSInteger const  TP_CODE_WRITE;
extern NSInteger const  TP_CODE_NOTIFY;
extern NSInteger const  TP_CODE_DEVICE_NOT_FOUND;//未找到设备

extern NSInteger const  TP_CODE_RECEVIER_TIME_OUT;//接收数据超时

extern NSInteger const  TP_CODE_READ_SUCCESS;//读取成功
extern NSInteger const  TP_CODE_READ_FAILED;//读取失败
extern NSInteger const  TP_CODE_READ_TIME_OUT;//读取超时

extern NSInteger const  TP_CODE_WRITE_SUCCESS;//写入成功
extern NSInteger const  TP_CODE_WRITE_FAILED;//写入失败
extern NSInteger const  TP_CODE_WRITE_TIME_OUT;//写入超时

//SCAN
extern NSInteger const  TP_CODE_SCAN_START;
extern NSInteger const  TP_CODE_SCAN_CANCEL;
extern NSInteger const  TP_CODE_SCAN_FOUND;



@interface CodeUtils : NSObject

@end

NS_ASSUME_NONNULL_END

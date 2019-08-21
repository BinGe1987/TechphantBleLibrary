//
//  CodeUtils.m
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/21.
//  Copyright © 2019 JX. All rights reserved.
//

#import "CodeUtils.h"

//CONNECT
NSInteger const  TP_CODE_CONNECT = 1;//连接
NSInteger const  TP_CODE_DISCONNECT = 2;//断开
NSInteger const  TP_CODE_READ = 3;
NSInteger const  TP_CODE_WRITE = 4;
NSInteger const  TP_CODE_NOTIFY = 5;

NSInteger const  TP_CODE_RECEVIER_TIME_OUT = 7;//接收数据超时

NSInteger const  TP_CODE_READ_SUCCESS = 10;//读取成功
NSInteger const  TP_CODE_READ_FAILED = 11;//读取失败
NSInteger const  TP_CODE_READ_TIME_OUT = 12;//读取超时

NSInteger const  TP_CODE_WRITE_SUCCESS = 15;//写入成功
NSInteger const  TP_CODE_WRITE_FAILED = 16;//写入失败
NSInteger const  TP_CODE_WRITE_TIME_OUT = 17;//写入超时

//SCAN
NSInteger const  TP_CODE_SCAN_START = 20;
NSInteger const  TP_CODE_SCAN_CANCEL = 21;
NSInteger const  TP_CODE_SCAN_FOUND = 22;



@implementation CodeUtils

@end

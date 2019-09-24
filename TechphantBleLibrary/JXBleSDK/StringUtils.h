//
//  StringUtils.h
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/21.
//  Copyright © 2019 JX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StringUtils : NSObject

/**
 * 转16进制字符输出
 *
 *
 * @param data 16进制byte数据
 * @return 16进制字符串
 */
+ (NSString *)Char2Hex:(NSData *)data;


/**
 * 十六进制字符转byte
 *
 * @param hexString 16进制字符串
 * @return byte array
 */
+ (NSData *)hexStringToBytes:(NSString *)hexString;


/**
 判断值是否为空

 @param string 需要判断的值
 @return YES为空， NO为非空
 */
+ (BOOL)isEmpty:(NSString *)string;

@end

NS_ASSUME_NONNULL_END

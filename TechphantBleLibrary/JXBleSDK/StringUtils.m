//
//  StringUtils.m
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/21.
//  Copyright © 2019 JX. All rights reserved.
//

#import "StringUtils.h"

@implementation StringUtils

+ (NSString *)Char2Hex:(NSData *)data
{
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    NSString* result = [NSString stringWithString:hexString];
    return result;
}

+ (NSData *)hexStringToBytes:(NSString *)hexString
{
    if (!hexString || [hexString length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([hexString length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [hexString length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [hexString substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

+ (BOOL)isEmpty:(NSString *)string {
    if (!string) {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]]) {
        return !string || [string length] == 0;
    } else {
        NSString *value = [NSString stringWithFormat:@"%@", string];
        return !value || [value length] == 0;
    }
}

@end

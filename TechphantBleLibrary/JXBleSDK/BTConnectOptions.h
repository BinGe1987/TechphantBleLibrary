//
//  BTConnectOptions.h
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/19.
//  Copyright © 2019 JX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTConnectOptions : NSObject

/**
 重试次数
 */
@property (atomic, assign) NSInteger retry;

/**
 超时时长ms
 */
@property (atomic, assign) NSInteger timeout;

-(instancetype)init;

-(instancetype)initWithConnectRetry:(int)times connectTimeout:(int)timeout;

@end

NS_ASSUME_NONNULL_END

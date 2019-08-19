//
//  BluetoothClientManager.h
//  JXBlueSDK
//
//  Created by BinGe on 2019/8/12.
//  Copyright © 2019 JX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BluetoothClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface BluetoothClientManager : NSObject

+ (BluetoothClient *)getClient;

@end

NS_ASSUME_NONNULL_END

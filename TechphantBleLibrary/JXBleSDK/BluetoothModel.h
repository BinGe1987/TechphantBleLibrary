//
//  BluetoothModel.h
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/21.
//  Copyright © 2019 JX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BluetoothModel : NSObject

@property (nonatomic, strong) id peripheral;
@property (nonatomic, copy) id readChanged;
@property (nonatomic, copy) id writeChanged;
@property (nonatomic, copy) id receivedChanged;

@end

NS_ASSUME_NONNULL_END

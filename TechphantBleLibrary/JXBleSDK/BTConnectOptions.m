//
//  BTConnectOptions.m
//  TechphantBleLibrary
//
//  Created by BinGe on 2019/8/19.
//  Copyright © 2019 JX. All rights reserved.
//

#import "BTConnectOptions.h"

@implementation BTConnectOptions

-(instancetype)init {
    return [self initWithConnectRetry:3 connectTimeout:5000];
}

-(instancetype)initWithConnectRetry:(int)times connectTimeout:(int)timeout {
    self = [super init];
    if (self) {
        self.retry = times;
        self.timeout = timeout;
    }
    return self;
}

@end

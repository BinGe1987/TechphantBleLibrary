//
//  BluetoothClient.m
//  JXBlueSDK
//
//  Created by BinGe on 2019/8/12.
//  Copyright © 2019 JX. All rights reserved.
//

#import "BluetoothClient.h"
#import "BabyBluetooth.h"

@interface BluetoothClient()

@property (nonatomic, strong) NSMutableDictionary *peripheralDic;

@property (nonatomic, strong) CBPeripheral *connectedPeripheral;

@property (nonatomic, assign) id readValueBlock;

@end

@implementation BluetoothClient

BabyBluetooth *baby;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"BluetoothClient create.");
        self.peripheralDic = [NSMutableDictionary new];
        
        //初始化BabyBluetooth 蓝牙库
        baby = [BabyBluetooth shareBabyBluetooth];

    }
    return self;
}

- (void)setOnBleStateChangeListener:(_Nullable BleStateChangeListener) listener {
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (listener) {
            listener(central.state == CBManagerStatePoweredOn);
        }
    }];
}

- (BOOL)isBleOpen {
    return baby.centralManager.state == CBManagerStatePoweredOn;
}


- (BOOL)openBle {
    NSURL *url = [NSURL URLWithString:@"app-Prefs:root=Bluetooth"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
    return YES;
}

- (void)startScan:(BTScanRequestOptions * _Nullable)request onStarted:(void(^)(void))onStarted onDeviceFound:(void (^)(ScanResultModel *model))onDeviceFound onStopped:(void(^)(void))onStopped onCanceled:(void(^)(void))onCanceled {
    
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {

        if (peripheralName.length == 0) {
            return NO;
        }
        
        if ([peripheralName hasPrefix:@"H"]||[peripheralName hasPrefix:@"h"]||
            [peripheralName hasPrefix:@"T"]||[peripheralName hasPrefix:@"t"]||
            [peripheralName hasPrefix:@"E"]||[peripheralName hasPrefix:@"e"])
        {
            NSLog(@"搜索到了设备过滤器2:%@",peripheralName);
            return YES;
        }
        return NO;
    }];
    
//    baby setb
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (onDeviceFound) {
            
            ScanResultModel *model = [[ScanResultModel alloc] init];
            model.peripheral = peripheral;
            model.name = peripheral.name;
            model.rssi = [RSSI integerValue];
            NSData *data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
            if (data) {
                NSLog(@"advertisementData = %@", advertisementData);
                NSString *kCBAdvDataManufacturerString = [NSString stringWithFormat:@"%@", data];
                kCBAdvDataManufacturerString = [kCBAdvDataManufacturerString stringByReplacingOccurrencesOfString:@" " withString:@""];
                if (kCBAdvDataManufacturerString.length > 14 && [kCBAdvDataManufacturerString hasPrefix:@"<"] && [kCBAdvDataManufacturerString hasSuffix:@">"]) {
                    NSMutableString *macString = [[NSMutableString alloc] init];
                    [macString appendString:[[kCBAdvDataManufacturerString substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
                    [macString appendString:@":"];
                    [macString appendString:[[kCBAdvDataManufacturerString substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
                    [macString appendString:@":"];
                    [macString appendString:[[kCBAdvDataManufacturerString substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
                    [macString appendString:@":"];
                    [macString appendString:[[kCBAdvDataManufacturerString substringWithRange:NSMakeRange(7, 2)] uppercaseString]];
                    [macString appendString:@":"];
                    [macString appendString:[[kCBAdvDataManufacturerString substringWithRange:NSMakeRange(9, 2)] uppercaseString]];
                    [macString appendString:@":"];
                    [macString appendString:[[kCBAdvDataManufacturerString substringWithRange:NSMakeRange(11, 2)] uppercaseString]];
                    model.address = macString;
                    NSLog(@"mac = %@", model.address);
                    [self.peripheralDic setObject:peripheral forKey:model.address];
                    onDeviceFound(model);
                }
            }
//            onDeviceFound(model);
        }
        
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        if (onStopped) {
            onStopped();
        }
    }];
    
    baby.scanForPeripherals().begin();
    if (onStarted) {
        onStarted();
    }
}

- (void)stopScan {
    [baby cancelScan];
}

- (void)connect:(ScanResultModel *)model onConnectedStateChange:(void (^)(int state))onConnectedStateChange onServiceDiscover:(void (^)(void))onServiceDiscover onCharacteristicChange:(void (^)(NSString *serviceUUID, NSString *characterUUID, NSData *value))onCharacteristicChange onCharacteristicWrite:(void (^)(NSString *serviceUUID, NSString *characterUUID, NSData *value))onCharacteristicWrite onCharacteristicRead:(void (^)(NSString *serviceUUID, NSString *characterUUID, NSData *value))onCharacteristicRead
{
    CBPeripheral *peripheral = model.peripheral;
    
    //连接外设
    baby.having(peripheral).enjoy();
//    [baby AutoReconnect:peripheral];
    
    //连接回调
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"连接成功 %@", peripheral.name);
        self.connectedPeripheral = peripheral;
        if (onConnectedStateChange) {
            if (self.connectedPeripheral && self.connectedPeripheral == model.peripheral) {
                onConnectedStateChange(1);
            } else {
                onConnectedStateChange(-1);
            }
        }
    }];
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开连接");
        self.connectedPeripheral = nil;
        if (onConnectedStateChange) {
            onConnectedStateChange(0);
        }
    }];
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"连接失败");
        self.connectedPeripheral = nil;
        if (onConnectedStateChange) {
            onConnectedStateChange(-1);
        }
    }];
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        if ([[service.UUID UUIDString] isEqualToString:@"FFF0"]) {
            for (CBCharacteristic *c in service.characteristics) {
                NSLog(@"搜索服务:%@ 的特征：%@",service.UUID.UUIDString,c.UUID.UUIDString);
                if ([[c.UUID UUIDString] isEqualToString:@"FFF4"]) {
                    NSLog(@"设置服务:%@ 的特征：%@ 为可读",service.UUID.UUIDString,c.UUID.UUIDString);
                    [peripheral setNotifyValue:YES forCharacteristic:c];
                }
            }
        }
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"读取数据1 UUID:%@ value is:%@",characteristics.UUID.UUIDString,characteristics.value);
    }];
    //写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"写数据成功:%@", characteristic.value);
    }];
}

- (void)disconnect:(ScanResultModel * _Nullable)model {
    //断开所有peripheral的连
    [baby cancelAllPeripheralsConnection];
}

- (void)sendWithService:(NSString *)serviceUUID characteristic:(NSString *)characteristicUUID value:(NSData *)value block:(void(^)(NSArray *array))block {
    if (self.connectedPeripheral) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        //设置读取characteristics的委托
        [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
            NSLog(@"读取数据2 UUID:%@ value is:%@",characteristics.UUID.UUIDString,characteristics.value);
            if ([self mergeData:characteristics.value toArray:array]) {
                if (block) {
                    block(array);
                }
            }
        }];
        for (CBService *service in self.connectedPeripheral.services) {
            if ([service.UUID.UUIDString isEqualToString:serviceUUID]) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    [self.connectedPeripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    NSLog(@"%@ 写入数据: %@", self.connectedPeripheral.name, value);
                    usleep(200 * 1000);
                    return;
                }
            }
        }
    }
}

- (BOOL)mergeData:(NSData *)buffer toArray:(NSMutableArray *)array{
    if (!buffer || [buffer length] == 0) {
        return NO;
    }
    Byte *bytes = (Byte *)[buffer bytes];
    Byte header = bytes[0];
    if (header != 0x9a) {
        return NO;
    }
    //包长
    int length = bytes[1];
    //包编号
    int number = bytes[2];
    if (number == 1) {
        [array removeAllObjects];
    }
    //源数据字符串
    NSString *originData = [[[[NSString stringWithFormat:@"%@", buffer] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    //分包数
    int count = length / 15 + 1;
    [array insertObject:originData atIndex:number - 1];
    //结束
    if (number == count) {
        return YES;
    }
    
    return NO;
}

@end

//
//  BluetoothClient.m
//  JXBlueSDK
//
//  Created by BinGe on 2019/8/12.
//  Copyright © 2019 JX. All rights reserved.
//

#import "BluetoothClient.h"
#import "BabyBluetooth.h"
#import "BluetoothModel.h"
#import "StringUtils.h"

@interface BluetoothClient()

@property (nonatomic, strong) NSMutableDictionary<NSString*, BluetoothModel *> *peripheralDic;

@property (nonatomic, strong) BluetoothModel *connectedModel;

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
                    BluetoothModel *bluetoothModel = [BluetoothModel new];
                    bluetoothModel.peripheral = peripheral;
                    [self.peripheralDic setObject:bluetoothModel forKey:model.address];
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
    
    baby.scanForPeripherals().begin().stop(request.duration/1000.0);
    if (onStarted) {
        onStarted();
    }
}

- (void)stopScan {
    [baby cancelScan];
}

- (void)connect:(NSString *)address options:(BTConnectOptions *)options
            onConnectedStateChange:(void (^)(NSInteger state))onConnectedStateChange
            onReadChanged:(onReadChangedBlock)onReadChanged
            onWriteChanged:(onWriteChangedBlock)onWriteChanged
            onReceivedChanged:(onReceivedChangedBlock)onReceivedChanged
{
    BluetoothModel *bleMode = [self.peripheralDic objectForKey:address];
    bleMode.readChanged = onReadChanged;
    bleMode.writeChanged = onWriteChanged;
    bleMode.receivedChanged = onReceivedChanged;
//    CBPeripheral *connPeripheral = [self.peripheralDic objectForKey:address];
//    self.readChanged = onReadChanged;
    //连接外设
    baby.having(bleMode.peripheral).enjoy();
    [baby AutoReconnect:bleMode.peripheral];
    
    //连接回调
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"连接成功 %@", peripheral.name);
        if (peripheral == bleMode.peripheral) {
            [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {}];
            self.connectedModel = bleMode;
            onConnectedStateChange(TP_CODE_CONNECT);
        }
        
    }];
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开连接 %@", peripheral.name);
        [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {}];
        if (peripheral == bleMode.peripheral) {
            self.connectedModel = nil;
            onConnectedStateChange(TP_CODE_DISCONNECT);
        }
    }];
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"连接失败 %@", peripheral.name);
        if (peripheral == bleMode.peripheral) {
            self.connectedModel = nil;
            onConnectedStateChange(TP_CODE_DISCONNECT);
        }
    }];
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        if ([[service.UUID UUIDString] isEqualToString:@"FFF0"]) {
            for (CBCharacteristic *c in service.characteristics) {
                NSLog(@"service:%@ 的特征：%@",service.UUID.UUIDString,c.UUID.UUIDString);
                if ([[c.UUID UUIDString] isEqualToString:@"FFF4"]) {
//                    NSLog(@"ervice:%@ 的特征：%@ 为可读",service.UUID.UUIDString,c.UUID.UUIDString);
                    [peripheral setNotifyValue:YES forCharacteristic:c];
                }
            }
        }
    }];

}

- (void)disconnect:(NSString *)address; {
    //断开所有peripheral的连
    BluetoothModel *model = [self.peripheralDic objectForKey:address];
    if (model) {
        [baby AutoReconnectCancel:model.peripheral];
        [baby cancelPeripheralConnection :model.peripheral];
    }
}

- (void)readCharacterInfo:(NSString *)uuid {
    if (self.connectedModel) {
        CBPeripheral *peripheral = self.connectedModel.peripheral;
        for (CBService *service in peripheral.services) {
            if ([service.UUID.UUIDString isEqualToString:@"180A"]) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID.UUIDString isEqualToString:uuid]) {
                        if (self.connectedModel.readChanged) {
                            NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];
                            value = [[[value stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
                            onReadChangedBlock block = self.connectedModel.readChanged;
                            block(uuid, 1, value);
                        }
                    }
                }
            }
        }
    }
}

- (void)send:(NSString *)address command:(NSArray<NSString *> *)commands {
    //设置读取characteristics的委托
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"read value UUID:%@ value is:%@",characteristics.UUID.UUIDString,characteristics.value);
        if ([characteristics.UUID.UUIDString isEqualToString:@"FFF4"]) {
            if ([self mergeData:characteristics.value toArray:array]) {
                if (self.connectedModel.receivedChanged) {
                    onReceivedChangedBlock block = self.connectedModel.receivedChanged;
                    block(characteristics.UUID.UUIDString, array);
                }
            }
        }
    }];
    //写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        if (self.connectedModel.writeChanged) {
            onWriteChangedBlock block = self.connectedModel.writeChanged;
            if (error) {
                NSLog(@"write error %@", error.domain);
                block(characteristic.UUID.UUIDString, 1, error.domain);
            } else {
                NSLog(@"write success");
                block(characteristic.UUID.UUIDString, 0, [NSString stringWithFormat:@"%@",characteristic.value]);
            }
        }
    }];
    
    
    for (NSString *command in commands) {
        NSData *value = [StringUtils hexStringToBytes:command];
        if (self.connectedModel) {
            CBPeripheral *peripheral = self.connectedModel.peripheral;
            for (CBService *service in peripheral.services) {
                if ([service.UUID.UUIDString isEqualToString:@"FFF0"]) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                        if ([characteristic.UUID.UUIDString isEqualToString:@"FFF6"]) {
                            [self.connectedModel.peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                            NSLog(@"%@ 写入数据: %@", peripheral.name, value);
                            usleep(100 * 1000);
                            break;
                        }
                    }
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

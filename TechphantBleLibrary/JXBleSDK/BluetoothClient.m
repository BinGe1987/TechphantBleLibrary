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

@property (nonatomic, assign) onReadChangedBlock readChanged;
@property (nonatomic, assign) onWriteChangedBlock writeChanged;
@property (nonatomic, assign) onReceivedChangedBlock receivedChanged;

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

- (void)connect:(NSString *)address options:(BTConnectOptions *)options
            onConnectedStateChange:(void (^)(NSInteger state))onConnectedStateChange
            onReadChanged:(onReadChangedBlock)onReadChanged
            onWriteChanged:(onWriteChangedBlock)onWriteChanged
            onReceivedChanged:(onReceivedChangedBlock)onReceivedChanged
{
    CBPeripheral *connPeripheral = [self.peripheralDic objectForKey:address];
//    self.readChanged = onReadChanged;
    //连接外设
    baby.having(connPeripheral).enjoy();
    [baby AutoReconnect:connPeripheral];
    
    //连接回调
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"连接成功 %@", peripheral.name);
        if (peripheral == connPeripheral) {
            [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {}];
            self.connectedPeripheral = connPeripheral;
            self.readChanged = onReadChanged;
            self.writeChanged = onWriteChanged;
            self.receivedChanged = onReceivedChanged;
            onConnectedStateChange(TP_CODE_CONNECT);
        }
        
    }];
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开连接 %@", peripheral.name);
        [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {}];
        if (peripheral == connPeripheral) {
            self.connectedPeripheral = nil;
            self.readChanged = nil;
            self.writeChanged = nil;
            self.receivedChanged = nil;
            onConnectedStateChange(TP_CODE_DISCONNECT);
        }
    }];
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"连接失败 %@", peripheral.name);
        if (peripheral == connPeripheral) {
            self.connectedPeripheral = nil;
            self.readChanged = nil;
            self.writeChanged = nil;
            self.receivedChanged = nil;
            onConnectedStateChange(TP_CODE_DISCONNECT);
        }
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

}

- (void)disconnect:(NSString *)address; {
    //断开所有peripheral的连
    CBPeripheral *p = [self.peripheralDic objectForKey:address];
    if (p) {
        [baby AutoReconnectCancel:p];
        [baby cancelPeripheralConnection:p];
    }
}

- (void)readCharacterInfo:(NSString *)uuid {
    if (self.connectedPeripheral) {
        for (CBService *service in self.connectedPeripheral.services) {
            if ([service.UUID.UUIDString isEqualToString:@"180A"]) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID.UUIDString isEqualToString:uuid]) {
                        if (self.readChanged) {
                            NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];
                            value = [[[value stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
                            self.readChanged(uuid, 1, value);
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
        NSLog(@"读取数据 UUID:%@ value is:%@",characteristics.UUID.UUIDString,characteristics.value);
        if ([characteristics.UUID.UUIDString isEqualToString:@"FFF4"]) {
            if ([self mergeData:characteristics.value toArray:array]) {
                if (self.receivedChanged) {
                    self.receivedChanged(characteristics.UUID.UUIDString, array);
                }
            }
        }
    }];
    //写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        if (self.writeChanged) {
            if (error) {
                NSLog(@"写数据失败 %@", error.domain);
                self.writeChanged(characteristic.UUID.UUIDString, 1, error.domain);
            } else {
                NSLog(@"写数据成功");
                self.writeChanged(characteristic.UUID.UUIDString, 0, [NSString stringWithFormat:@"%@",characteristic.value]);
            }
        }
    }];
    
    
    for (NSString *command in commands) {
        NSData *value = [self convertHexStringToData:command];
        if (self.connectedPeripheral) {
            for (CBService *service in self.connectedPeripheral.services) {
                if ([service.UUID.UUIDString isEqualToString:@"FFF0"]) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                        if ([characteristic.UUID.UUIDString isEqualToString:@"FFF6"]) {
                            [self.connectedPeripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                            NSLog(@"%@ 写入数据: %@", self.connectedPeripheral.name, value);
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

- (NSData *)convertHexStringToData:(NSString *)hexString
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
    
//    Byte *bytes = (Byte *)[hexData bytes];
//    for(int i=0;i<[hexData length];i++) {
//        NSLog(@"byte[%d] = %x\n",i, bytes[i]);
//    }
    return hexData;
}

@end

//
//  LFTcpClient.m
//  SocketClient
//
//  Created by Lemon on 15-5-22.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

#import "LFTcpClient.h"
#import "SdkTcpClient.h"
#import "SdkObject.h"

@interface LFTcpClient ()
{
    SdkTcpClient *_sdkTcpClient;
    
}

@end

static void RcvCallback(unsigned char * buffer, int length, void *pSyn)
{
    LFTcpClient *tcpClient = (__bridge LFTcpClient *)pSyn;
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSString *dataString = [NSString stringWithCString:(const char *)buffer encoding:enc];
    
    NSLog(@"tcp--->%@",dataString);

    
//    NSString *dataStr = [NSString stringWithCString:(const char*)buffer encoding:NSUTF8StringEncoding];
    
    [tcpClient.delegate onTcpClient:tcpClient didReadData:dataString length:length];

    
}

static void ConnectCallback(ErroCode result, void *pSyn)
{
     LFTcpClient *tcpClient = (__bridge LFTcpClient *)pSyn;
    

    [tcpClient.delegate onTcpClient:tcpClient didConnect:result];

}

static void DisconnectCallback(ErroCode code, void *pSyn)
{
    LFTcpClient *tcpClient = (__bridge LFTcpClient *)pSyn;
    
    [tcpClient.delegate onTcpClientDidDisconnect:tcpClient error:code];
    
}


@implementation LFTcpClient

- (void)dealloc
{
    if (_sdkTcpClient)
    {
        _sdkTcpClient->SetRcvCallback(NULL);
        delete _sdkTcpClient, _sdkTcpClient = NULL;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _sdkTcpClient = SdkTcpClient::GetNewObject();
        
        if (_sdkTcpClient->GetObjectState() != OBJECT_STATE_INIT_SUCCESS) {
            _sdkTcpClient->GetLastErro();
        }
        _sdkTcpClient->SetRcvCallback(RcvCallback);
        _sdkTcpClient->SetDisconnectCallback(DisconnectCallback);
        _sdkTcpClient->SetDisconnectSynObject((__bridge void *)self);
        _sdkTcpClient->SetRcvSynObject((__bridge void *)self);
    }
    return self;
}

- (void)tcpClient:(void *)tcp
{
    _sdkTcpClient = (SdkTcpClient *)tcp;
    _sdkTcpClient->SetRcvCallback(RcvCallback);
    _sdkTcpClient->SetDisconnectCallback(DisconnectCallback);
    _sdkTcpClient->SetDisconnectSynObject((__bridge void *)self);
    _sdkTcpClient->SetRcvSynObject((__bridge void *)self);
    
}

- (instancetype)initWithSubTcp:(void *)tcp
{
    self = [super init];
    if (self)
    {
        _sdkTcpClient = (SdkTcpClient *)tcp;
        
        if (_sdkTcpClient->GetObjectState() != OBJECT_STATE_INIT_SUCCESS) {
            _sdkTcpClient->GetLastErro();
        }
        _sdkTcpClient->SetRcvCallback(RcvCallback);
        _sdkTcpClient->SetDisconnectCallback(DisconnectCallback);
        _sdkTcpClient->SetDisconnectSynObject((__bridge void *)self);
        _sdkTcpClient->SetRcvSynObject((__bridge void *)self);
    }
    return self;
}
- (long long)beginConnect:(NSString *)ip port:(UInt16)port timerout:(int)timerout
{
    NSAssert(ip != nil, @"ip 不能为空");
    return _sdkTcpClient->BeginConnect([ip cStringUsingEncoding:NSUTF8StringEncoding], port, timerout, ConnectCallback, (__bridge void *)self);
}

- (long long)sendData:(NSData *)data
{
    NSAssert(data != nil, @"发送数据不能为空");
    
    return _sdkTcpClient->Send((unsigned char *)data.bytes, 0, (int)data.length);
}


- (long long)EnableHeartBeat:(int)waitTime Interval:(int)interval Quantity:(int)quantity
{
    return _sdkTcpClient->EnableHeartBeat(waitTime, interval, quantity);
}
- (long long)disconnect
{
    return _sdkTcpClient->Disconnect();
}


#pragma mark - getter setter

- (BOOL)state
{
    
    return _sdkTcpClient->GetState();
}
- (NSString *)ip
{
    NSString *ipString = [NSString stringWithFormat:@"%s",_sdkTcpClient->GetIP()];
    return ipString;
}

- (int)port
{
    
    return _sdkTcpClient->GetPort();
}


@end

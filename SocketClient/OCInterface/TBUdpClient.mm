//
//  TBUdpClient.m
//  SocketClient
//
//  Created by 郑云 on 15/5/27.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

#import "TBUdpClient.h"
#import "SdkObject.h"
#import "SdkUdpClient.h"

@interface TBUdpClient ()
{
    SdkUdpClient *_sdkUdpClient;
}

@end

static void RcvCallback(unsigned char * pBuffer, int length,const char * pIp, unsigned short port, void *pSyn)
{
    TBUdpClient *udpClient = (__bridge TBUdpClient *)pSyn;
    if (pBuffer != NULL)
    {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        
        NSString *dataString = [NSString stringWithCString:(const char *)pBuffer encoding:enc];
        
        NSLog(@"udp--->%@",dataString);
        [udpClient.delegate onUdpClient:udpClient didReceiveData:dataString withLength:length fromHost:[NSString stringWithCString:(const char *)pIp encoding:NSUTF8StringEncoding] port:port];
    }
    else
    {
       
       [udpClient.delegate onUdpClientDidReceiveError: [udpClient getLastError]];

    }
    
}


@implementation TBUdpClient


- (void)dealloc
{
    if (_sdkUdpClient)
    {
        delete _sdkUdpClient, _sdkUdpClient = NULL;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {

        _sdkUdpClient = SdkUdpClient::GetNewObject();
        
        if (_sdkUdpClient->GetObjectState() != OBJECT_STATE_INIT_SUCCESS)
        {
            
            NSLog(@"%lld",_sdkUdpClient->GetLastErro());
            
        }
        _sdkUdpClient->SetRcvCallback(RcvCallback);
        _sdkUdpClient->SetRcvSynObject((__bridge void *)self);
        
    }
    return self;
}


- (long long)enableBroadcast
{
    return _sdkUdpClient->EnableBroadcast();
}

- (long long) sendData:(NSData *)data ip:(NSString *)ip port:(UInt16)port
{
//    NSAssert(data != nil, @"发送数据不能为空");
    
    return _sdkUdpClient->Send((unsigned char *)data.bytes, 0, (int)data.length, [ip cStringUsingEncoding:NSUTF8StringEncoding], port);
}

- (long long)close
{
    return _sdkUdpClient->Close();
}

- (long long)getLastError
{
    return _sdkUdpClient->GetLastErro();
}

- (instancetype)initWithPort:(unsigned short)port
{

    NSLog(@"%d",port);
    self = [super init];
    if (self)
    {
        _sdkUdpClient = SdkUdpClient::GetNewObject(NULL,port);
        
        if (_sdkUdpClient->GetObjectState() != OBJECT_STATE_INIT_SUCCESS)
        {
            
            NSLog(@"%lld",_sdkUdpClient->GetLastErro());
            
        }
        _sdkUdpClient->SetRcvCallback(RcvCallback);
        _sdkUdpClient->SetRcvSynObject((__bridge void *)self);
        
    }
    return self;
    
}
@end

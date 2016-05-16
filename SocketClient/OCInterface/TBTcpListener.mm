//
//  TBTcpListener.m
//  SocketClient
//
//  Created by 郑云 on 15/7/2.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

#import "TBTcpListener.h"
#import "SdkTcpListener.h"

@interface TBTcpListener ()
{
    SdkTcpListener *_sdkTcpServer;
}

@end

static void acceptCallBack(SdkTcpClient *pClient, void *pSyn)
{
    TBTcpListener *tcpListener = (__bridge TBTcpListener*)  pSyn;
    
    LFTcpClient *tcpClient = [[LFTcpClient alloc]initWithSubTcp:pClient];
//    LFTcpClient *tcpClient = [LFTcpClient new];
//    [tcpClient tcpClient:pClient];
    [tcpListener.delegate receiveClient:tcpClient];
    
}


@implementation TBTcpListener

- (void)dealloc
{
    if (_sdkTcpServer)
    {
        delete _sdkTcpServer, _sdkTcpServer = NULL;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _sdkTcpServer = SdkTcpListener::GetNewObject();
        
    }
    return self;
}



- (long long)start:(int)port
{
    _sdkTcpServer = SdkTcpListener::GetNewObject();
    long long error =  _sdkTcpServer->Start(port);
    
    _sdkTcpServer->BeginAccept(acceptCallBack, (__bridge void *)self);
    
    return error;
}

- (void)stop
{

    _sdkTcpServer->Stop();
}

- (SdkTcpClient *)accept
{
   return _sdkTcpServer ->Accept();
}

@end

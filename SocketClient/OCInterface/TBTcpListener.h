//
//  TBTcpListener.h
//  SocketClient
//
//  Created by 郑云 on 15/7/2.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LFTcpClient.h"

@protocol TBTcpListenerDelegate;
@interface TBTcpListener : NSObject
{

}

@property (nonatomic, assign) long long state;
@property (nonatomic, weak) id<TBTcpListenerDelegate> delegate;


- (long long)start:(int)port;

- (void)stop;

//- (SdkTcpClient *)accept;

@end
@protocol TBTcpListenerDelegate <NSObject>

- (void)receiveClient:(LFTcpClient *)client;

@end
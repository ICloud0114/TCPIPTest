//
//  LFTcpClient.h
//  SocketClient
//
//  Created by Lemon on 15-5-22.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LFTcpClientDelegate;
@interface LFTcpClient : NSObject

@property (nonatomic, weak) id<LFTcpClientDelegate> delegate;

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign, readonly) BOOL state;
@property (nonatomic, copy, readonly) NSString * ip;
@property (nonatomic, assign, readonly) int port;

@property (nonatomic,copy)NSString *receiveData;

- (long long)beginConnect:(NSString *)ip port:(UInt16)port timerout:(int)timerout;

- (long long)sendData:(NSData *)data;

- (long long)EnableHeartBeat:(int)waitTime Interval:(int)interval Quantity:(int)quantity;

- (long long)disconnect;

- (void)tcpClient:(void *)tcp;

- (instancetype)initWithSubTcp:(void *)tcp;

@end

@protocol LFTcpClientDelegate <NSObject>




- (void)onTcpClient:(LFTcpClient *)tcpClient didConnect:(long long)result;


- (void)onTcpClientDidDisconnect:(LFTcpClient *)tcpClient error:(long long)error;

- (void)onTcpClient:(LFTcpClient *)tcpClient didReadData:(NSString *)str length:(int)length;

@end

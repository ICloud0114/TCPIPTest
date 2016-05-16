//
//  TBUdpClient.h
//  SocketClient
//
//  Created by 郑云 on 15/5/27.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TBUdpClientDelegate;

@interface TBUdpClient : NSObject
@property (nonatomic, weak) id<TBUdpClientDelegate> delegate;

@property (nonatomic, assign) long tag;


/**
 *  发送数据
 *
 *  @param data 数据源
 *  @param ip   目标主机
 *  @param port 端口
 *
 *  @return 成功返回ERR_NO_ERRO， 否则为库错误代码
 */
- (long long)sendData:(NSData *)data ip:(NSString *)ip port:(UInt16)port;
/**
 *  开启当前UDP对象的广播功能
 *
 *  @param flag   flag description
 *  @param errPtr <#errPtr description#>
 *
 *  @return 成功返回ERR_NO_ERRO，否则为库错误代码
 */
- (long long)enableBroadcast;

/**
 *  关闭UDP通信
 *
 *  @return 成功返回ERR_NO_ERRO， 否则为库错误代码
 */
- (long long)close;


- (long long)getLastError;
- (instancetype)initWithPort:(unsigned short)port;

@end
@protocol TBUdpClientDelegate <NSObject>


- (void)onUdpClient:(TBUdpClient *)udpClient createObjectError:(long long)error;
- (void)onUdpClient:(TBUdpClient *)udpClient didSendDataWithTag:(long)tag;

- (void)onUdpClient:(TBUdpClient *)udpClient didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;

- (BOOL)onUdpClient:(TBUdpClient *)udpClient didReceiveData:(NSString *)string withLength:(int)length fromHost:(NSString *)host port:(UInt16)port;

- (void)onUdpClient:(TBUdpClient *)udpClient didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error;

- (void)onUdpClientDidClose:(TBUdpClient *)udpClient;


- (void)onUdpClientDidReceiveError:(long long)error;

@end
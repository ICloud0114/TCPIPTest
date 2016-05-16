//
//  ipaddress.m
//  SocketClient
//
//  Created by 郑云 on 15/7/22.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

#import "IpAddress.h"

#import "IPAdress.h"
@implementation IpAddress

+ (NSString *)deviceIPAdress {
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    return [NSString stringWithFormat:@"%s", ip_names[1]];
}
@end

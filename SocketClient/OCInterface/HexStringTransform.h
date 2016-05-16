//
//  HexStringTransform.h
//  SocketClient
//
//  Created by 郑云 on 15/7/9.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HexStringTransform : NSObject


+ (NSString *)hexStringFromString:(NSString *)string;
+ (NSString *)stringFromHexString2:(NSString *)hexString;
@end

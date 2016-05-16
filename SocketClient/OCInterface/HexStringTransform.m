//
//  HexStringTransform.m
//  SocketClient
//
//  Created by 郑云 on 15/7/9.
//  Copyright (c) 2015年 拓邦软件中心. All rights reserved.
//

#import "HexStringTransform.h"

@implementation HexStringTransform


+ (NSString *)hexStringFromString:(NSString *)string
{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%X",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0 %@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@ %@",hexStr,newHexStr];
    }
    NSLog(@"------十六进制======%@",hexStr);
    return hexStr;
}

+ (NSString *)stringFromHexString2:(NSString *)hexString
{
    
    NSString *newString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    char *myBuffer = (char *)malloc((int)[newString length] / 2 + 1);
    bzero(myBuffer, [newString length] / 2 + 1);
    for (int i = 0; i < [newString length] - 1; i += 2)
    {
        unsigned int anInt;
        NSString * hexCharStr = [newString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}



@end

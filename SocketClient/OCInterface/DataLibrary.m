//
//  DataLibrary.m
//  SOMY
//
//  Created by smile on 14-10-17.
//  Copyright (c) 2014年 easaa. All rights reserved.
//

#import "DataLibrary.h"
#import "TBUdpClient.h"

#define DATABASENAME @"SocketClient"
@implementation DataLibrary
{
    FMDatabase *dataBase;
}

+(DataLibrary*)shareDataLibrary
{
    static DataLibrary *library ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (library == nil)
        {
            library = [[DataLibrary alloc] init];
        }
    });
    return library;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        path = [path  stringByAppendingPathComponent:DATABASENAME];
        dataBase = [FMDatabase databaseWithPath:path];
    }
    return self;
}

-(BOOL)creatProductTable:(NSString *)tableName
{
//    actid imageUrl title site distance date
    
    [dataBase open];
    NSString *sql = @"";
    if ([tableName isEqualToString:@"TCP"])
    {
        sql = [NSString stringWithFormat:@"create table if not exists %@ (p_id INTEGER PRIMARY KEY AUTOINCREMENT,ip varchar,port varchar,state varchar,autoConnect varchar,repeat varchar,autoWrap varchar,autoReply varchar)",tableName];
    }
    else if([tableName isEqualToString:@"UDP"])
    {
        sql = [NSString stringWithFormat:@"create table if not exists %@ (p_id INTEGER PRIMARY KEY AUTOINCREMENT,ip varchar,port varchar,autoWrap varchar,repeat varchar,autoReply varchar)",tableName];
    }
    else if([tableName isEqualToString:@"HISTORY"])
    {
        sql = [NSString stringWithFormat:@"create table if not exists %@ (p_id INTEGER PRIMARY KEY AUTOINCREMENT,history varchar)",tableName];
    }
    if ([dataBase executeUpdate:sql])
    {
        [dataBase close];
        NSLog(@"创建成功");
        return YES;
    }
    else
    {
        NSLog(@"ERROR----> %@",[dataBase lastError]);
        [dataBase close];
        return NO;
    }
    
}



- (NSMutableArray*)getallDataByTable:(NSString *)tableName
{
    [dataBase open];
    
   
    NSMutableArray *arr = [NSMutableArray array];
    
    if ([tableName isEqualToString:@"TCP"])
    {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ order by p_id ASC",tableName];
        
        FMResultSet *rs = [dataBase executeQuery:sql];
        while ([rs next])
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            
            [dic setValue:[rs stringForColumn:@"p_id"] forKey:@"p_id"];
            [dic setValue:[rs stringForColumn:@"ip"] forKey:@"ip"];
            [dic setValue:[rs stringForColumn:@"port"] forKey:@"port"];
            [dic setValue:[rs stringForColumn:@"state"] forKey:@"state"];
            [dic setValue:[rs stringForColumn:@"autoConnect"] forKey:@"autoConnect"];
            [dic setValue:[rs stringForColumn:@"autoWrap"] forKey:@"autoWrap"];
            [dic setValue:[rs stringForColumn:@"repeat"] forKey:@"repeat"];
            [dic setValue:[rs stringForColumn:@"autoReply"] forKey:@"autoReply"];
            [arr addObject:dic];
            NSLog(@"data----->%@",dic);
        }
    }
    else if([tableName isEqualToString:@"UDP"])
    {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ order by p_id ASC",tableName];
        
        FMResultSet *rs = [dataBase executeQuery:sql];
        while ([rs next])
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            
            [dic setValue:[rs stringForColumn:@"ip"] forKey:@"ip"];
            [dic setValue:[rs stringForColumn:@"port"] forKey:@"port"];
            [dic setValue:[rs stringForColumn:@"autoWrap"] forKey:@"autoWrap"];
            [dic setValue:[rs stringForColumn:@"p_id"] forKey:@"p_id"];
            [dic setValue:[rs stringForColumn:@"repeat"] forKey:@"repeat"];
            [dic setValue:[rs stringForColumn:@"autoReply"] forKey:@"autoReply"];
            
            [arr addObject:dic];
             NSLog(@"data----->%@",dic);

        }
    }
    else if([tableName isEqualToString:@"HISTORY"])
    {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ order by p_id DESC",tableName];
        
        FMResultSet *rs = [dataBase executeQuery:sql];
        
        while ([rs next])
        {
            [arr addObject:[rs stringForColumn:@"history"]];
        }
    
    }

    
    
    [dataBase close];
    
    return arr;
}

- (BOOL)insertData:(NSDictionary *)data intoTable:(NSString *)tableName
{
    [dataBase open];
    
    NSLog(@"insert data---->%@",data);
    NSString *sql = @"";
    
    if ([tableName isEqualToString:@"TCP"])
    {
        sql = [NSString stringWithFormat:@"replace into %@ (ip,port,state,autoConnect,repeat,autoWrap,autoReply) values ('%@','%@','%@','%@','%@','%@','%@')",tableName, data[@"ip"], data[@"port"],data[@"state"],data[@"autoConnect"],data[@"repeat"],data[@"autoWrap"],data[@"autoReply"]];
    }
    else if([tableName isEqualToString:@"UDP"])
    {
        sql = [NSString stringWithFormat:@"replace into %@ (ip,port,repeat,autoWrap,autoReply) values ('%@','%@','%@','%@','%@')",tableName, data[@"ip"], data[@"port"],data[@"repeat"],data[@"autoWrap"],data[@"autoReply"]];
    }
    else if([tableName isEqualToString:@"HISTORY"])
    {
        sql = [NSString stringWithFormat:@"replace into %@ (history) values ('%@')",tableName, data[@"history"]];
    }
    
    if ([dataBase executeUpdate:sql])
    {
        [dataBase close];
        return YES;
    }
    else
    {
        NSLog(@"ERROR----> %@",[dataBase lastError]);
        [dataBase close];
        return NO;
    }
    
}


- (BOOL)replaceData:(NSDictionary*)data intoTable:(NSString *)tableName
{
    [dataBase open];
    
    NSLog(@"replace data---->%@",data);
    NSString *sql = @"";
    
    if ([tableName isEqualToString:@"TCP"])
    {
        sql = [NSString stringWithFormat:@"replace into %@ (p_id,ip,port,state,autoConnect,repeat,autoWrap,autoReply) values ('%@','%@','%@','%@','%@','%@','%@','%@')",tableName, data[@"p_id"], data[@"ip"], data[@"port"],data[@"state"],data[@"autoConnect"],data[@"repeat"],data[@"autoWrap"],data[@"autoReply"]];
    }
    else if([tableName isEqualToString:@"UDP"])
    {
        sql = [NSString stringWithFormat:@"replace into %@ (p_id,ip,port,repeat,autoWrap,autoReply) values ('%@','%@','%@','%@','%@','%@')",tableName, data[@"p_id"], data[@"ip"], data[@"port"],data[@"repeat"],data[@"autoWrap"],data[@"autoReply"]];
    }
    
    if ([dataBase executeUpdate:sql])
    {
        [dataBase close];
        return YES;
    }
    else
    {
        NSLog(@"ERROR----> %@",[dataBase lastError]);
        [dataBase close];
        return NO;
    }
}
- (BOOL)checkDataListByTable:(NSString *)tableName withIp:(NSString *)ip andPort:(NSString *)port
{
    [dataBase open];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where ip = '%@' and port = '%@'",tableName,ip,port];
    
    FMResultSet *rs = [dataBase executeQuery:sql];
    
    NSInteger count = 0;
    while ([rs next])
    {
        ++ count;
    }
    [dataBase close];
    
    if (count)
    {
                NSLog(@"已存在");
        return YES;
    }
    else
    {
        
                NSLog(@"未存在");
        return NO;
    }
}

- (NSString *)checkDataListByTable:(NSString *)tableName withDataString:(NSString *)dataString
{
    [dataBase open];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where history = '%@'",tableName,dataString];
    
    FMResultSet *rs = [dataBase executeQuery:sql];
    

    while ([rs next])
    {
        return [rs stringForColumn:@"p_id"];
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    NSString *nextsql = [NSString stringWithFormat:@"select * from %@ order by p_id DESC",tableName];
    
    FMResultSet *nextRs = [dataBase executeQuery:nextsql];
    
    NSString *lastPid = @"";
    while ([nextRs next])
    {
        [arr addObject:[nextRs stringForColumn:@"history"]];
        lastPid = [nextRs stringForColumn:@"p_id"];
    }
    
    if (arr.count >= 30)
    {
        [self deleteDataListByTable:@"HISTORY" pid:lastPid];
    }
    
    [dataBase close];
    
    return @"invalid";

}
- (BOOL)deleteDataListByTable:(NSString *)tableName withIp:(NSString *)ip andPort:(NSString *)port
{
    [dataBase open];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where ip='%@' and port='%@'",tableName,ip,port];
    if ([dataBase executeUpdate:sql])
    {
        [dataBase close];
                NSLog(@"删除成功");
        return YES;
    }
    else
    {
        [dataBase close];
                NSLog(@"删除失败");
                NSLog(@"ERROR----> %@",[dataBase lastError]);
        return NO;
    }
}
- (BOOL)deleteDataListByTable:(NSString *)tableName pid:(NSString *)pid
{
    [dataBase open];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where p_id='%@'",tableName,pid];
    if ([dataBase executeUpdate:sql])
    {
        [dataBase close];
        NSLog(@"删除成功");
        return YES;
    }
    else
    {
        [dataBase close];
        NSLog(@"删除失败");
        NSLog(@"ERROR----> %@",[dataBase lastError]);
        return NO;
    }
}


- (BOOL)cleanTable:(NSString *)name
{
    return [dataBase executeUpdate:@"delete from temperature"];
}

- (BOOL)deleteTable:(NSString *)name
{
    NSString *sql = [NSString stringWithFormat:@"drop table %@",name];
    return [dataBase executeUpdate:sql];
}
//查找数据库中所有表名
- (BOOL)queryByTableName:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"select * from sqlite_master where type = 'table'"];
    FMResultSet *rs = [dataBase executeQuery:sql];
    NSMutableArray *arr = [NSMutableArray array];
    while ([rs next])
    {
        NSString *string = [rs stringForColumn:@"name"];
        [arr addObject:string];
    }
    return YES;
}

@end

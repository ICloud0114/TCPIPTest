//
//  DataLibrary.h
//  SOMY
//
//  Created by smile on 14-10-17.
//  Copyright (c) 2014年 easaa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDatabase.h>


@interface DataLibrary : NSObject

+(DataLibrary*)shareDataLibrary;
- (BOOL)creatProductTable:(NSString *)tableName;

//- (id)getFirstDataByTable:(NSString *)tableName;

//- (id)getTitleByTable:(NSString *)tableName andLevelId:(NSString *)Id;

- (NSMutableArray *)getallDataByTable:(NSString *)tableName;

//- (NSMutableArray *)getDataByTable:(NSString *)tableName andSuperLevel:(NSString *)firstLevel;

//- (NSString *)getMaxTemperatureFromTable:(NSString *)tableName;

- (BOOL)insertData:(NSDictionary*)data intoTable:(NSString *)tableName;
- (BOOL)replaceData:(NSDictionary*)data intoTable:(NSString *)tableName;

//- (BOOL)deleteData:(NSDictionary *)data withTime:(NSString *)time;

//- (BOOL)searchActivityIdByTable:(NSString *)tableName andActivityId:(NSString *)Id;

- (BOOL)checkDataListByTable:(NSString *)tableName withIp:(NSString *)ip andPort:(NSString *)port;

- (NSString *)checkDataListByTable:(NSString *)tableName withDataString:(NSString *)dataString;

- (BOOL)deleteDataListByTable:(NSString *)tableName withIp:(NSString *)ip andPort:(NSString *)port;
- (BOOL)deleteDataListByTable:(NSString *)tableName pid:(NSString *)pid;
//- (BOOL)deleteProductByProductID:(NSString *)pid FromTable:(NSString *)tableName;

- (BOOL)cleanTable:(NSString *)name;

- (BOOL)deleteTable:(NSString *)name;

@end

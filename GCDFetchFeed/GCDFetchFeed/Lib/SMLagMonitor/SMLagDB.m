//
//  SMLagDB.m
//  DecoupleDemo
//
//  Created by DaiMing on 2017/8/3.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import "SMLagDB.h"


@interface SMLagDB()

@property (nonatomic, copy) NSString *clsCallDBPath;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation SMLagDB

+ (SMLagDB *)shareInstance {
    static SMLagDB *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SMLagDB alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _clsCallDBPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"clsCall.sqlite"];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:_clsCallDBPath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_clsCallDBPath] == NO) {
            FMDatabase *db = [FMDatabase databaseWithPath:_clsCallDBPath];
            if ([db open]) {
                /* clsCall 表记录方法读取频次的表
                 cid: 主id
                 fid: 父id 暂时不用
                 cls: 类名
                 mtd: 方法名
                 path: 完整路径标识
                 timecost: 方法消耗时长
                 calldepth: 层级
                 frequency: 调用次数
                 lastcall: 是否是最后一个 call
                 */
                NSString *createSql = @"create table clscall (cid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, fid integer, cls text, mtd text, path text, timecost double, calldepth integer, frequency integer, lastcall integer)";
                [db executeUpdate:createSql];
                
                /* stack 表记录
                 sid: id
                 stackcontent: 堆栈内容
                 insertdate: 日期
                 */
                NSString *createStackSql = @"create table stack (sid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, stackcontent text, insertdate double)";
                [db executeUpdate:createStackSql];
            }
        }
    }
    return self;
}

#pragma mark - 卡顿和CPU超标堆栈
//添加 stack 表数据
- (RACSignal *)increaseWithStackString:(NSString *)str {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [self.dbQueue inDatabase:^(FMDatabase *db){
            if ([db open]) {
                [db executeUpdate:@"insert into stack (stackcontent, insertdate) values (?, ?)",str, [NSDate date]];
                [db close];
                [subscriber sendCompleted];
            }
        }];
        
        return nil;
    }];
}
//stack 分页查询
- (RACSignal *)selectStackWithPage:(NSUInteger)page {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.clsCallDBPath];
        if ([db open]) {
            FMResultSet *rs = [db executeQuery:@"select * from stack order by sid desc limit ?, 50",@(page * 50)];
            NSUInteger count = 0;
            NSMutableArray *arr = [NSMutableArray array];
            while ([rs next]) {
                [arr addObject:[rs stringForColumn:@"stackcontent"]];
                count++;
            }
            if (count > 0) {
                [subscriber sendNext:arr];
            } else {
                [subscriber sendError:nil];
            }
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}
//stack 表清除
- (void)clearStackData {
    FMDatabase *db = [FMDatabase databaseWithPath:self.clsCallDBPath];
    if ([db open]) {
        [db executeUpdate:@"delete from stack"];
        [db close];
    }
}

#pragma mark - ClsCall方法调用频次
//添加记录
- (RACSignal *)increaseWithClsCallModel:(SMCallTraceTimeCostModel *)model {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [self.dbQueue inDatabase:^(FMDatabase *db){
            if ([db open]) {
                FMResultSet *rsl = [db executeQuery:@"select cid,frequency from clscall where path = ?", model.path];
                if ([rsl next]) {
                    //有相同路径就更新路径访问频率
                    int fq = [rsl intForColumn:@"frequency"] + 1;
                    int cid = [rsl intForColumn:@"cid"];
                    [db executeUpdate:@"update clscall set frequency = ? where cid = ?", @(fq), @(cid)];
                } else {
                    //没有就添加一条记录
                    NSNumber *lastCall = @0;
                    if (model.lastCall) {
                        lastCall = @1;
                    }
                    [db executeUpdate:@"insert into clscall (cls, mtd, path, timecost, calldepth, frequency, lastcall) values (?, ?, ?, ?, ?, ?, ?)", model.className, model.methodName, model.path, @(model.timeCost), @(model.callDepth), @1, lastCall];
                }
                [db close];
                [subscriber sendCompleted];
            }
        }];
        
        return nil;
    }];
}

//分页查询
- (RACSignal *)selectClsCallWithPage:(NSUInteger)page {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        FMDatabase *db = [FMDatabase databaseWithPath:self.clsCallDBPath];
        if ([db open]) {
            FMResultSet *rs = [db executeQuery:@"select * from clscall where lastcall=? order by frequency desc limit ?, 50",@1, @(page * 50)];
            NSUInteger count = 0;
            NSMutableArray *arr = [NSMutableArray array];
            while ([rs next]) {
                SMCallTraceTimeCostModel *model = [self clsCallModelFromResultSet:rs];
                [arr addObject:model];
                count ++;
            }
            if (count > 0) {
                [subscriber sendNext:arr];
            } else {
                [subscriber sendError:nil];
            }
            [subscriber sendCompleted];
            [db close];
        }
        return nil;
    }];
}

//清除数据
- (void)clearClsCallData {
    FMDatabase *db = [FMDatabase databaseWithPath:self.clsCallDBPath];
    if ([db open]) {
        [db executeUpdate:@"delete from clscall"];
        [db close];
    }
}

//结果封装成 model
- (SMCallTraceTimeCostModel *)clsCallModelFromResultSet:(FMResultSet *)rs {
    SMCallTraceTimeCostModel *model = [[SMCallTraceTimeCostModel alloc] init];
    model.className = [rs stringForColumn:@"cls"];
    model.methodName = [rs stringForColumn:@"mtd"];
    model.path = [rs stringForColumn:@"path"];
    model.timeCost = [rs doubleForColumn:@"timecost"];
    model.callDepth = [rs intForColumn:@"calldepth"];
    model.frequency = [rs intForColumn:@"frequency"];
    model.lastCall = [rs boolForColumn:@"lastcall"];
    return model;
}


@end

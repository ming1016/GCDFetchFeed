//
//  SMCallTraceDemo.m
//  GCDFetchFeed
//
//  Created by denglibing on 2023/12/20.
//  Copyright © 2023 Starming. All rights reserved.
//

#import "SMCallTraceDemo.h"

#import "SMCallTrace.h"

@implementation SMCallTraceDemo

+ (void)test {
    [SMCallTrace start];
    
    [self test1_1];
    [self test2_1];
    [self test3_1];
    
    [self test1_1];
    [self test2_1];
    [self test3_1];
    
    [SMCallTrace stop];
    [SMCallTrace save];
    
    // 打印的日志如下：
    /*
     0|  39.11|+[SMCallTraceDemo test1_1]
     1|  13.03|  +[SMCallTraceDemo test1_2]
     1|  14.02|  +[SMCallTraceDemo test1_3]

     0|  69.08|+[SMCallTraceDemo test2_1]
     1|  23.02|  +[SMCallTraceDemo test2_2]
     1|  24.03|  +[SMCallTraceDemo test2_3]

     0|  99.32|+[SMCallTraceDemo test3_1]
     1|  33.13|  +[SMCallTraceDemo test3_2]
     1|  34.14|  +[SMCallTraceDemo test3_3]

     0|  39.29|+[SMCallTraceDemo test1_1]
     1|  13.09|  +[SMCallTraceDemo test1_2]
     1|  14.06|  +[SMCallTraceDemo test1_3]

     0|  68.76|+[SMCallTraceDemo test2_1]
     1|  23.06|  +[SMCallTraceDemo test2_2]
     1|  24.13|  +[SMCallTraceDemo test2_3]

     0|  99.24|+[SMCallTraceDemo test3_1]
     1|  33.09|  +[SMCallTraceDemo test3_2]
     1|  34.07|  +[SMCallTraceDemo test3_3]
     */
}

+ (void)test1_1 {
    usleep(11 * 1000);
    [self test1_2];
    [self test1_3];
}

+ (void)test1_2 {
    usleep(12 * 1000);
}

+ (void)test1_3 {
    usleep(13 * 1000);
}

+ (void)test2_1 {
    usleep(21 * 1000);
    [self test2_2];
    [self test2_3];
}

+ (void)test2_2 {
    usleep(22 * 1000);
}

+ (void)test2_3 {
    usleep(23 * 1000);
}


+ (void)test3_1 {
    usleep(31 * 1000);
    [self test3_2];
    [self test3_3];
}

+ (void)test3_2 {
    usleep(32 * 1000);
}

+ (void)test3_3 {
    usleep(33 * 1000);
}

@end

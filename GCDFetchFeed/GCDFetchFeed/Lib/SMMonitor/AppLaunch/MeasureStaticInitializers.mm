//
//  MeasureStaticInitializers.m
//  GCDFetchFeed
//
//  Created by Ming on 2024/11/8.
//  Copyright © 2024 Starming. All rights reserved.
//


#import <Foundation/Foundation.h>

// MARK: - 通过修改__mod_init_func来hook所有的初始化函数
//#include <unistd.h>
//#include <mach-o/getsect.h>
//#include <mach-o/loader.h>
//#include <mach-o/dyld.h>
//#include <dlfcn.h>
//#include <vector>
//
//static NSMutableArray *sInitInfos;
//static NSTimeInterval sSumInitTime;
//
//extern "C"
//const char* getallinitinfo(){
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [sInitInfos addObject:[NSString stringWithFormat:@"SumInitTime=%@",@(sSumInitTime)]];
//    });
//    
//    NSString *msg = [NSString stringWithFormat:@"%@",sInitInfos];
//    return msg.UTF8String;
//}
//
//
//using namespace std;
//#ifndef __LP64__
//typedef uint32_t MemoryType;
//#else /* defined(__LP64__) */
//typedef uint64_t MemoryType;
//#endif /* defined(__LP64__) */
//
//
//static std::vector<MemoryType> *g_initializer;
//static int g_cur_index;
//static MemoryType g_aslr;
//
//
//
//struct MyProgramVars
//{
//    const void*        mh;
//    int*            NXArgcPtr;
//    const char***    NXArgvPtr;
//    const char***    environPtr;
//    const char**    __prognamePtr;
//};
//
//typedef void (*OriginalInitializer)(int argc, const char* argv[], const char* envp[], const char* apple[], const MyProgramVars* vars);
//
//void myInitFunc_Initializer(int argc, const char* argv[], const char* envp[], const char* apple[], const struct MyProgramVars* vars){
//    printf("my init func\n");
//    ++g_cur_index;
//    OriginalInitializer func = (OriginalInitializer)g_initializer->at(g_cur_index);
//    
//    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
//    
//    func(argc,argv,envp,apple,vars);
//    
//    CFTimeInterval end = CFAbsoluteTimeGetCurrent();
//    sSumInitTime += 1000.0 * (end-start);
//    NSString *cost = [NSString stringWithFormat:@"%p=%@",func,@(1000.0*(end - start))];
//    [sInitInfos addObject:cost];
//}
//
//static void hookModInitFunc(){
//    Dl_info info;
//    dladdr((const void *)hookModInitFunc, &info);
//    
//#ifndef __LP64__
//    //        const struct mach_header *mhp = _dyld_get_image_header(0); // both works as below line
//    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
//    unsigned long size = 0;
//    MemoryType *memory = (uint32_t*)getsectiondata(mhp, "__DATA", "__mod_init_func", & size);
//#else /* defined(__LP64__) */
//    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
//    unsigned long size = 0;
//    MemoryType *memory = (uint64_t*)getsectiondata(mhp, "__DATA", "__mod_init_func", & size);
//#endif /* defined(__LP64__) */
//    for(int idx = 0; idx < size/sizeof(void*); ++idx){
//        MemoryType original_ptr = memory[idx];
//        g_initializer->push_back(original_ptr);
//        memory[idx] = (MemoryType)myInitFunc_Initializer;
//    }
//    
//    NSLog(@"zero mod init func : size = %@",@(size));
//    
//    [sInitInfos addObject:[NSString stringWithFormat:@"ASLR=%p",mhp]];
//    g_aslr = (MemoryType)mhp;
//}
//
//@interface FooObject : NSObject @end
//@implementation FooObject
//+ (void)load{
//    printf("foo object load \n");
//    
//    sInitInfos = [NSMutableArray new];
//    g_initializer = new std::vector<MemoryType>();
//    g_cur_index = -1;
//    g_aslr = 0;
//    
//    hookModInitFunc();
//}
//@end

// MARK: - constructor and destructor
//#include <iostream>
//#include <chrono>
//
//static std::chrono::high_resolution_clock::time_point start_time;
//static std::chrono::high_resolution_clock::time_point end_time;
//
//// 定义构造函数，用于记录开始时间
//__attribute__((constructor))
//void record_start_time() {
//    start_time = std::chrono::high_resolution_clock::now();
//}
//
//// 定义析构函数，用于记录结束时间并计算时间差
//__attribute__((destructor))
//void record_end_time() {
//    end_time = std::chrono::high_resolution_clock::now();
//    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time).count();
//    std::cout << "Static Initializers Execution Time: " << duration << " microseconds" << std::endl;
//}
//
//// 示例静态初始化器
//static int static_var = []() {
//    // 模拟一些初始化工作
//    for (int i = 0; i < 1000000; ++i);
//    return 0;
//}();

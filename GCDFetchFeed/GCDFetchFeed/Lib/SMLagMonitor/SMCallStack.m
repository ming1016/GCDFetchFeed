//
//  SMCallStack.m
//
//  Created by DaiMing on 2017/6/22.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import "SMCallStack.h"


//为通用回溯设计结构支持栈地址由小到大，地址里存储上个栈指针的地址
typedef struct SMStackFrame {
    const struct SMStackFrame *const previous;
    const uintptr_t return_address;
} SMStackFrame;

//存储 thread 信息的结构体
typedef struct SMThreadInfoStruct {
    double cpuUsage;
    integer_t userTime;
} SMThreadInfoStruct;

static mach_port_t _smMainThreadId;
@implementation SMCallStack

+ (void)load {
    _smMainThreadId = mach_thread_self();
}

#pragma mark - Interface
+ (NSString *)callStackWithType:(SMCallStackType)type {
    if (type == SMCallStackTypeAll) {
        thread_act_array_t threads; //int 组成的数组比如 thread[1] = 5635
        mach_msg_type_number_t thread_count = 0; //mach_msg_type_number_t 是 int 类型
        const task_t this_task = mach_task_self(); //int
        //根据当前 task 获取所有线程
        kern_return_t kr = task_threads(this_task, &threads, &thread_count);
        if (kr != KERN_SUCCESS) {
            return @"fail get all threads";
        }
        NSMutableString *reStr = [NSMutableString stringWithFormat:@"Call %u threads:\n", thread_count];
        for (int i = 0; i < thread_count; i++) {
            //当前执行的指令
            [reStr appendString:smStackOfThread(threads[i])];
        }
        //task info
        NSString *memStr = @"";
        struct mach_task_basic_info taskBasicInfo;
        mach_msg_type_number_t taskInfoCount = sizeof(taskBasicInfo) / sizeof(integer_t);
        if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&taskBasicInfo, &taskInfoCount) == KERN_SUCCESS) {
            memStr = [NSString stringWithFormat:@"used %llu MB \n",taskBasicInfo.resident_size / (1024 * 1024)];
        }
        
        NSLog(@"%@%@",memStr,reStr);
        //释放虚存缓存，防止leak
        assert(vm_deallocate(mach_task_self(), (vm_address_t)threads, thread_count * sizeof(thread_t)) == KERN_SUCCESS);
        return [reStr copy];
    } else if (type == SMCallStackTypeMain) {
        //主线程
        NSString *reStr = smStackOfThread((thread_t)_smMainThreadId);
        assert(vm_deallocate(mach_task_self(), (vm_address_t)_smMainThreadId, 1 * sizeof(thread_t)) == KERN_SUCCESS);
        NSLog(@"%@",reStr);
        return [reStr copy];
    } else {
        //当前线程
        char name[256];
        mach_msg_type_number_t count;
        thread_act_array_t list;
        //根据当前 task 获取所有线程
        task_threads(mach_task_self(), &list, &count);
        NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
        NSThread *nsthread = [NSThread currentThread]; //当前执行的指令
        NSString *originName = [nsthread name];
        [nsthread setName:[NSString stringWithFormat:@"%f",currentTimestamp]];
        NSString *reStr = @"";
        
        for (int i = 0; i < count; ++i) {
            //_np 是指 not POSIX ，这里的 POSIX 是指操作系统的一个标准，特别是与 Unix 兼容的操作系统。np 表示与标准不兼容
            pthread_t pt = pthread_from_mach_thread_np(list[i]);
            if (pt) {
                name[0] = '\0';
                //获得线程名字
                pthread_getname_np(pt, name, sizeof name);
                if (!strcmp(name, [nsthread name].UTF8String)) {
                    [nsthread setName:originName];
                    reStr = smStackOfThread(list[i]);
                    assert(vm_deallocate(mach_task_self(), (vm_address_t)list[i], 1 * sizeof(thread_t)) == KERN_SUCCESS);
                    NSLog(@"%@",reStr);
                    return [reStr copy];
                }
            }
        }
        [nsthread setName:originName];
        reStr = smStackOfThread(mach_thread_self());
        NSLog(@"%@",reStr);
        return [reStr copy];
    }
    return @"";
}

#pragma mark - get stack of mach_thread
//当前栈帧结构
NSString *smStackOfThread(thread_t thread) {
    //thread info
    SMThreadInfoStruct threadInfoSt = {0};
    thread_info_data_t threadInfo;
    thread_basic_info_t threadBasicInfo;
    mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
    
    if (thread_info((thread_act_t)thread, THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount) == KERN_SUCCESS) {
        threadBasicInfo = (thread_basic_info_t)threadInfo;
        if (!(threadBasicInfo->flags & TH_FLAGS_IDLE)) {
            threadInfoSt.cpuUsage = threadBasicInfo->cpu_usage / 10;
            threadInfoSt.userTime = threadBasicInfo->system_time.microseconds;
        }
    }
    
    uintptr_t buffer[100];
    int i = 0;
    NSMutableString *reStr = [NSMutableString stringWithFormat:@"Stack of thread: %u:\n CPU used: %.1f percent\n user time: %d second\n", thread, threadInfoSt.cpuUsage, threadInfoSt.userTime];
    
    //回溯栈的算法
    /*
     栈帧布局参考：
     https://en.wikipedia.org/wiki/Call_stack
     http://www.cs.cornell.edu/courses/cs412/2008sp/lectures/lec20.pdf
     http://eli.thegreenplace.net/2011/09/06/stack-frame-layout-on-x86-64/
     */
    _STRUCT_MCONTEXT machineContext; //线程栈里所有的栈指针
    //通过 thread_get_state 获取完整的 machineContext 信息，包含 thread 状态信息
    mach_msg_type_number_t state_count = smThreadStateCountByCPU();
    kern_return_t kr = thread_get_state(thread, smThreadStateByCPU(), (thread_state_t)&machineContext.__ss, &state_count);
    if (kr != KERN_SUCCESS) {
        return [NSString stringWithFormat:@"Fail get thread: %u", thread];
    }
    //通过指令指针来获取当前指令地址
    const uintptr_t instructionAddress = smMachInstructionPointerByCPU(&machineContext);
    buffer[i] = instructionAddress;
    ++i;
    
    //
    uintptr_t linkRegisterPointer = smMachThreadGetLinkRegisterPointerByCPU(&machineContext);
    if (linkRegisterPointer) {
        buffer[i] = linkRegisterPointer;
        i++;
    }
    
    if (instructionAddress == 0) {
        return @"Fail to get instruction address";
    }
    
    SMStackFrame stackFrame = {0};
    //通过栈基址指针获取当前栈帧地址
    const uintptr_t framePointer = smMachStackBasePointerByCPU(&machineContext);
    if (framePointer == 0 || smMemCopySafely((void *)framePointer, &stackFrame, sizeof(stackFrame)) != KERN_SUCCESS) {
        return @"Fail frame pointer";
    }
    for (; i < 32; i++) {
        buffer[i] = stackFrame.return_address;
        if (buffer[i] == 0 || stackFrame.previous == 0 || smMemCopySafely(stackFrame.previous, &stackFrame, sizeof(stackFrame)) != KERN_SUCCESS) {
            break;
        }
    }
    
    //处理dlsym，对地址进行符号化解析
    //1.找到地址所属的内存镜像，
    //2.然后定位镜像中的符号表
    //3.最后在符号表中找到目标地址的符号
    int stackLength = i;
    //DL_info 用来保存解析的结果
    Dl_info symbolicated[stackLength];
    smSymbolicate(buffer, symbolicated, stackLength, 0);
    for (int i = 0; i < stackLength; ++i) {
        [reStr appendFormat:@"%@", smOutputLog(i, buffer[i], &symbolicated[i])];
    }
    [reStr appendFormat:@"\n"];
    return reStr;
}

#pragma mark - buildStack
NSString* smOutputLog(const int entryNum, const uintptr_t address, const Dl_info* const dlInfo) {
    const char* name = dlInfo->dli_fname;
    if (name == NULL) {
        return @"";
    }
    //获取路径最后文件名
    //strrchr 查找某字符在字符串中最后一次出现的位置
    char* lastFile = strrchr(dlInfo->dli_fname, '/');
    NSString *fname = @"";
    if (lastFile == NULL) {
        fname = [NSString stringWithFormat:@"%-30s",name];
    } else {
        fname = [NSString stringWithFormat:@"%-30s",lastFile + 1];
    }
    
    uintptr_t offset = address - (uintptr_t)dlInfo->dli_saddr;
    const char* sname = dlInfo->dli_sname;
    if (sname == NULL) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@ 0x%08" PRIxPTR " %s + %lu\n", fname, (uintptr_t)address, sname, offset];
    
}

#pragma mark - Thread info


#pragma mark - MachineContext
kern_return_t smMemCopySafely(const void *const src, void *const dst, const size_t byteSize) {
    vm_size_t bytesCopied = 0;
    return vm_read_overwrite(mach_task_self(), (vm_address_t)src, (vm_size_t)byteSize, (vm_address_t)dst, &bytesCopied);
}

#pragma mark - Symbolicate
void smSymbolicate(const uintptr_t* const stackBuffer, Dl_info* const symbolsBuffer, const int stackLength, const int skippedEntries) {
    int i = 0;
    if (!skippedEntries && i < stackLength) {
        smDladdr(stackBuffer[i], &symbolsBuffer[i]);
        i++;
    }
    for (; i < stackLength; i++) {
        smDladdr(smInstructionAddressByCPU(stackBuffer[i]), &symbolsBuffer[i]);
    }
}
bool smDladdr(const uintptr_t address, Dl_info* const info) {
    info->dli_fname = NULL;
    info->dli_fbase = NULL;
    info->dli_sname = NULL;
    info->dli_saddr = NULL;
    //根据地址获取是哪个 image
    const uint32_t idx = smDyldImageIndexFromAddress(address);
    if (idx == UINT_MAX) {
        return false;
    }
    /*
     Header
     ------------------
     Load commands
     Segment command 1 -------------|
     Segment command 2              |
     ------------------             |
     Data                           |
     Section 1 data |segment 1 <----|
     Section 2 data |          <----|
     Section 3 data |          <----|
     Section 4 data |segment 2
     Section 5 data |
     ...            |
     Section n data |
     */
    /*----------Mach Header---------*/
    //根据 image 的序号获取 mach_header
    const struct mach_header* machHeader = _dyld_get_image_header(idx);
    //返回 image_index 索引的 image 的虚拟内存地址 slide 的数量，如果 image_index 超出范围返回0
    //动态链接器加载 image 时，image 必须映射到未占用地址的进程的虚拟地址空间。动态链接器通过添加一个值到 image 的基地址来实现，这个值是虚拟内存 slide 数量
    const uintptr_t imageVMAddressSlide = (uintptr_t)_dyld_get_image_vmaddr_slide(idx);
    /*-----------ASLR 的偏移量---------*/
    //https://en.wikipedia.org/wiki/Address_space_layout_randomization
    const uintptr_t addressWithSlide = address - imageVMAddressSlide;
    //根据 Image 的 Index 来获取 segment 的基地址
    //段定义Mach-O文件中的字节范围以及动态链接器加载应用程序时这些字节映射到虚拟内存中的地址和内存保护属性。 因此，段总是虚拟内存页对齐。 片段包含零个或多个节。
    const uintptr_t segmentBase = smSegmentBaseOfImageIndex(idx) + imageVMAddressSlide;
    if (segmentBase == 0) {
        return false;
    }
    //
    info->dli_fname = _dyld_get_image_name(idx);
    info->dli_fbase = (void*)machHeader;
    
    /*--------------Mach Segment-------------*/
    //地址最匹配的symbol
    const nlistByCPU* bestMatch = NULL;
    uintptr_t bestDistance = ULONG_MAX;
    uintptr_t cmdPointer = smCmdFirstPointerFromMachHeader(machHeader);
    if (cmdPointer == 0) {
        return false;
    }
    //遍历每个 segment 判断目标地址是否落在该 segment 包含的范围里
    for (uint32_t iCmd = 0; iCmd < machHeader->ncmds; iCmd++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPointer;
        /*----------目标 Image 的符号表----------*/
        //Segment 除了 __TEXT 和 __DATA 外还有 __LINKEDIT segment，它里面包含动态链接器的使用的原始数据，比如符号，字符串和重定位表项。
        //LC_SYMTAB 描述了 __LINKEDIT segment 内查找字符串和符号表的位置
        if (loadCmd->cmd == LC_SYMTAB) {
            //获取字符串和符号表的虚拟内存偏移量。
            const struct symtab_command* symtabCmd = (struct symtab_command*)cmdPointer;
            const nlistByCPU* symbolTable = (nlistByCPU*)(segmentBase + symtabCmd->symoff);
            const uintptr_t stringTable = segmentBase + symtabCmd->stroff;
            
            for (uint32_t iSym = 0; iSym < symtabCmd->nsyms; iSym++) {
                //如果 n_value 是0，symbol 指向外部对象
                if (symbolTable[iSym].n_value != 0) {
                    //给定的偏移量是文件偏移量，减去 __LINKEDIT segment 的文件偏移量获得字符串和符号表的虚拟内存偏移量
                    uintptr_t symbolBase = symbolTable[iSym].n_value;
                    uintptr_t currentDistance = addressWithSlide - symbolBase;
                    //寻找最小的距离 bestDistance，因为 addressWithSlide 是某个方法的指令地址，要大于这个方法的入口。
                    //离 addressWithSlide 越近的函数入口越匹配
                    if ((addressWithSlide >= symbolBase) && (currentDistance <= bestDistance)) {
                        bestMatch = symbolTable + iSym;
                        bestDistance = currentDistance;
                    }
                }
            }
            if (bestMatch != NULL) {
                //将虚拟内存偏移量添加到 __LINKEDIT segment 的虚拟内存地址可以提供字符串和符号表的内存 address。
                info->dli_saddr = (void*)(bestMatch->n_value + imageVMAddressSlide);
                info->dli_sname = (char*)((intptr_t)stringTable + (intptr_t)bestMatch->n_un.n_strx);
                if (*info->dli_sname == '_') {
                    info->dli_sname++;
                }
                //所有的 symbols 的已经被处理好了
                if (info->dli_saddr == info->dli_fbase && bestMatch->n_type == 3) {
                    info->dli_sname = NULL;
                }
                break;
            }
        }
        cmdPointer += loadCmd->cmdsize;
    }
    
    return true;
}
//通过 address 找到对应的 image 的游标，从而能够得到 image 的更多信息
uint32_t smDyldImageIndexFromAddress(const uintptr_t address) {
    //返回当前 image 数，这里 image 不是线程安全的，因为另一个线程可能正处在添加或者删除 image 期间
    const uint32_t imageCount = _dyld_image_count();
    const struct mach_header* machHeader = 0;
    //O(n2)的方式查找，考虑优化
    for (uint32_t iImg = 0; iImg < imageCount; iImg++) {
        //返回一个指向由 image_index 索引的 image 的 mach 头的指针，如果 image_index 超出了范围，那么久返回 NULL
        machHeader = _dyld_get_image_header(iImg);
        if (machHeader != NULL) {
            //查找 segment command
            uintptr_t addressWSlide = address - (uintptr_t)_dyld_get_image_vmaddr_slide(iImg);
            uintptr_t cmdPointer = smCmdFirstPointerFromMachHeader(machHeader);
            if (cmdPointer == 0) {
                continue;
            }
            for (uint32_t iCmd = 0; iCmd < machHeader->ncmds; iCmd++) {
                const struct load_command* loadCmd = (struct load_command*)cmdPointer;
                //在遍历mach header里的 load command 时判断 segment command 是32位还是64位的，大部分系统的 segment 都是32位的
                if (loadCmd->cmd == LC_SEGMENT) {
                    const struct segment_command* segCmd = (struct segment_command*)cmdPointer;
                    if (addressWSlide >= segCmd->vmaddr && addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                } else if(loadCmd->cmd == LC_SEGMENT_64){
                    const struct segment_command_64* segCmd = (struct segment_command_64*)cmdPointer;
                    if (addressWSlide >= segCmd->vmaddr && addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                }
                
                cmdPointer += loadCmd->cmdsize;
            }
            
        }
    }
    
    return UINT_MAX;
}
uintptr_t smCmdFirstPointerFromMachHeader(const struct mach_header* const machHeader) {
    switch (machHeader->magic) {
        case MH_MAGIC:
        case MH_CIGAM:
        case MH_MAGIC_64:
        case MH_CIGAM_64:
            return (uintptr_t)(((machHeaderByCPU*)machHeader) + 1);
        default:
            return 0; // Header 不合法
    }
}
uintptr_t smSegmentBaseOfImageIndex(const uint32_t idx) {
    const struct mach_header* machHeader = _dyld_get_image_header(idx);
    //查找 segment command 返回 image 的地址
    uintptr_t cmdPtr = smCmdFirstPointerFromMachHeader(machHeader);
    if (cmdPtr == 0) {
        return 0;
    }
    for (uint32_t i = 0; i < machHeader->ncmds; i++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        const segmentComandByCPU* segmentCmd = (segmentComandByCPU*)cmdPtr;
        if (strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
            return (uintptr_t)(segmentCmd->vmaddr - segmentCmd->fileoff);
        }
        cmdPtr += loadCmd->cmdsize;
    }
    
    return 0;
}

#pragma mark - Deal with CPU seperate
/*
 //X86 for example
 SP/ESP/RSP: 栈顶部地址的栈指针
 BP/EBP/RBP: 栈基地址指针
 IP/EIP/RIP: 指令指针保留程序计数当前指令地址
 */
uintptr_t smMachStackBasePointerByCPU(mcontext_t const machineContext) {
    //Stack base pointer for holding the address of the current stack frame.
#if defined(__arm64__)
    return machineContext->__ss.__fp;
#elif defined(__arm__)
    return machineContext->__ss.__r[7];
#elif defined(__x86_64__)
    return machineContext->__ss.__rbp;
#elif defined(__i386__)
    return machineContext->__ss.__ebp;
#endif
}
uintptr_t smMachInstructionPointerByCPU(mcontext_t const machineContext) {
    //Instruction pointer. Holds the program counter, the current instruction address.
#if defined(__arm64__)
    return machineContext->__ss.__pc;
#elif defined(__arm__)
    return machineContext->__ss.__pc;
#elif defined(__x86_64__)
    return machineContext->__ss.__rip;
#elif defined(__i386__)
    return machineContext->__ss.__eip;
#endif
}
uintptr_t smInstructionAddressByCPU(const uintptr_t address) {
#if defined(__arm64__)
    const uintptr_t reAddress = ((address) & ~(3UL));
#elif defined(__arm__)
    const uintptr_t reAddress = ((address) & ~(1UL));
#elif defined(__x86_64__)
    const uintptr_t reAddress = (address);
#elif defined(__i386__)
    const uintptr_t reAddress = (address);
#endif
    return reAddress - 1;
}
mach_msg_type_number_t smThreadStateCountByCPU() {
#if defined(__arm64__)
    return ARM_THREAD_STATE64_COUNT;
#elif defined(__arm__)
    return ARM_THREAD_STATE_COUNT;
#elif defined(__x86_64__)
    return x86_THREAD_STATE64_COUNT;
#elif defined(__i386__)
    return x86_THREAD_STATE32_COUNT;
#endif
}
/*
 * target_thread 的执行状态，比如机器寄存器
 * THREAD_STATE_FLAVOR_LIST 0
 * these are the supported flavors
 #define x86_THREAD_STATE32      1
 #define x86_FLOAT_STATE32       2
 #define x86_EXCEPTION_STATE32   3
 #define x86_THREAD_STATE64      4
 #define x86_FLOAT_STATE64       5
 #define x86_EXCEPTION_STATE64   6
 #define x86_THREAD_STATE        7
 #define x86_FLOAT_STATE         8
 #define x86_EXCEPTION_STATE     9
 #define x86_DEBUG_STATE32       10
 #define x86_DEBUG_STATE64       11
 #define x86_DEBUG_STATE         12
 #define THREAD_STATE_NONE       13
 14 and 15 are used for the internal x86_SAVED_STATE flavours
 #define x86_AVX_STATE32         16
 #define x86_AVX_STATE64         17
 #define x86_AVX_STATE           18
*/
thread_state_flavor_t smThreadStateByCPU() {
#if defined(__arm64__)
    return ARM_THREAD_STATE64;
#elif defined(__arm__)
    return ARM_THREAD_STATE;
#elif defined(__x86_64__)
    return x86_THREAD_STATE64;
#elif defined(__i386__)
    return x86_THREAD_STATE32;
#endif
}
uintptr_t smMachThreadGetLinkRegisterPointerByCPU(mcontext_t const machineContext) {
#if defined(__i386__)
    return 0;
#elif defined(__x86_64__)
    return 0;
#else
    return machineContext->__ss.__lr;
#endif
}


@end

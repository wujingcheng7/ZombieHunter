//
//  DPLogic.c
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#include "DPLogic.h"
#include <malloc/malloc.h>
#include <dlfcn.h>
#include <string.h>
#include <stdatomic.h>
#include "fishhook.h"
#include "DPRuntimeMethod.h"

// MARK: - 全局变量定义

int dp_maxStealMemorySize = DP_DEFAULT_MAX_STEAL_MEMORY_SIZE;
int dp_maxStealMemoryNumber = DP_DEFAULT_MAX_STEAL_MEMORY_NUMBER;
int dp_batchFreeNumber = DP_DEFAULT_BATCH_FREE_NUMBER;

// MARK: - 内部隐藏变量定义

void (*dp_orig_free)(void *) = NULL;
DPQueue* dp_unfreeQueue = NULL;
int dp_unfreeSize = 0;
atomic_bool dp_freeDidSwizzled = false;
atomic_bool dp_monitorShouldWork = false;

// MARK: - 方法实现

void dp_always_free_really(void* p) {
    if (atomic_load(&dp_freeDidSwizzled)) {
        dp_orig_free(p);
    } else {
        free(p); // 未被交换过，直接调用原版 free 即可
    }
}

// 释放部分内存
void dp_free_some_mem(size_t freeNum) {
    size_t count = dp_queue_length(dp_unfreeQueue);
    freeNum = freeNum > count ? count : freeNum;
    for (int i = 0; i < freeNum; i++) {
        void* unfreePoint = dp_queue_get(dp_unfreeQueue);
        size_t memSize = malloc_size(unfreePoint);
        __sync_fetch_and_sub(&dp_unfreeSize, (int)memSize);
        dp_always_free_really(unfreePoint);
    }
}

void dp_free_some_memory_if_needed(void) {
    dp_free_some_mem(dp_batchFreeNumber);
}

void dp_my_free(void* p) {
    if (!atomic_load(&dp_monitorShouldWork)) {
        // 已经停止监控了，直接释放即可
        dp_orig_free(p);
        return;
    }
    if (dp_is_oc_object(p)) {
        // OC 对象这里不管，让 DDZombieMonitor 去处理
        dp_orig_free(p);
        return;
    }
    int unFreeCount = (int)dp_queue_length(dp_unfreeQueue);
    if (unFreeCount > dp_maxStealMemoryNumber * 0.9 || dp_unfreeSize > dp_maxStealMemorySize) {
        // 空间不够了，释放一些空间，这个对象也直接释放
        dp_free_some_mem(dp_batchFreeNumber);
        dp_orig_free(p);
    } else {
        // 0x55 处理，让野指针提前暴露
        size_t memSize = malloc_size(p);
        memset(p, 0x55, memSize);
        __sync_fetch_and_add(&dp_unfreeSize, (int)memSize);
        dp_queue_put(dp_unfreeQueue, p);
    }
}

// 初始化安全释放
void dp_swizzle_free(void) {
    if (atomic_load(&dp_freeDidSwizzled)) {
        return;
    }
    dp_unfreeQueue = dp_queue_create(dp_maxStealMemoryNumber);
    struct rebinding rebindings_arr[] = {
        {
            .name = "free",
            .replacement = (void *)dp_my_free,
            .replaced = (void **)&dp_orig_free
        }
    };
    size_t rebindings_size = sizeof(rebindings_arr) / sizeof(rebindings_arr[0]);
    rebind_symbols(rebindings_arr, rebindings_size);
    atomic_store(&dp_freeDidSwizzled, true);
    return;
}

void dp_start_monitor(void) {
    dp_init_registeredClass();
    dp_swizzle_free();
    atomic_store(&dp_monitorShouldWork, true);
}

void dp_end_monitor(void) {
    atomic_store(&dp_monitorShouldWork, false);
}

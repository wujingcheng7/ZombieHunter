//
//  DPLogic.h
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#ifndef DPLogic_h
#define DPLogic_h

#include <stdbool.h>
#include "DPQueue.h"

// MARK: - 宏

/// 最多保存的内存尺寸（默认 10 MB）
#define DP_DEFAULT_MAX_STEAL_MEMORY_SIZE    (10 * 1024 * 1024)  // 10 MB
/// 最多保留的指针数量（默认 10 M 个）
#define DP_DEFAULT_MAX_STEAL_MEMORY_NUMBER  (10 * 1000 * 1000)  // 10 M 个
/// 每次释放的指针数量（默认 100 个）
#define DP_DEFAULT_BATCH_FREE_NUMBER        100

// MARK: - 全局变量声明

/// 最多保存多少尺寸 C 指针，默认值最多保存 10 MB
extern int dp_maxStealMemorySize;
/// 最多保留多少数量 C 指针，默认值最多保存 10 M
extern int dp_maxStealMemoryNumber;
/// 每次释放多少个指针，默认值 100 个
extern int dp_batchFreeNumber;

// MARK: - 函数声明

#ifdef __cplusplus
extern "C" {
#endif

/// 总是直接调用 free 函数
void dp_always_free_really(void* p);
/// 开始监控
void dp_start_monitor(void);
/// 停止监控
void dp_end_monitor(void);

#ifdef __cplusplus
}
#endif

#endif /* DPLogic_h */

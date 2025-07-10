//
//  DPQueue.h
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#ifndef DPQueue_h
#define DPQueue_h

#include <stdlib.h>
#include <pthread.h>

// MARK: - 队列定义

// 队列节点结构
typedef struct DPQueueNode {
    void* data;
    struct DPQueueNode* next;
} DPQueueNode;

// 队列主体结构（线程安全）
typedef struct {
    DPQueueNode* head;  // 队首指针
    DPQueueNode* tail;  // 队尾指针
    pthread_mutex_t lock;  // 互斥锁
    size_t capacity;     // 队列容量上限
    size_t size;         // 当前队列长度
} DPQueue;

// 创建队列（容量为max_size）
DPQueue* dp_queue_create(size_t max_size);

// 入队操作（线程安全）
void dp_queue_put(DPQueue* queue, void* data);

// 出队操作（线程安全）
void* dp_queue_get(DPQueue* queue);

// 获取队列长度（线程安全）
size_t dp_queue_length(DPQueue* queue);

// 销毁队列（需由调用者确保内存释放）
void dp_queue_destroy(DPQueue* queue);

#endif /* DPQueue_h */

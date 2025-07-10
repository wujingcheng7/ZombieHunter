//
//  DPQueue.c
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#include "DPQueue.h"
#include <stdlib.h>
#include <pthread.h>
#include <DPLogic.h>

// 创建队列（容量为max_size）
DPQueue* dp_queue_create(size_t max_size) {
    DPQueue* queue = (DPQueue*)malloc(sizeof(DPQueue));
    if (!queue) return NULL;

    queue->head = queue->tail = NULL;
    queue->size = 0;
    queue->capacity = max_size;
    pthread_mutex_init(&queue->lock, NULL);  // 初始化锁
    return queue;
}

// 入队操作（线程安全）
void dp_queue_put(DPQueue* queue, void* data) {
    pthread_mutex_lock(&queue->lock);  // 加锁

    // 容量检查：超限时拒绝入队（或可扩展为淘汰旧数据）
    if (queue->size >= queue->capacity) {
        pthread_mutex_unlock(&queue->lock);
        return;
    }

    // 创建新节点
    DPQueueNode* node = (DPQueueNode*)malloc(sizeof(DPQueueNode));
    if (!node) {
        pthread_mutex_unlock(&queue->lock);
        return;
    }
    node->data = data;
    node->next = NULL;

    // 更新队列
    if (queue->tail) {
        queue->tail->next = node;
        queue->tail = node;
    } else {  // 空队列初始化
        queue->head = queue->tail = node;
    }
    queue->size++;
    pthread_mutex_unlock(&queue->lock);  // 解锁
}

// 出队操作（线程安全）
void* dp_queue_get(DPQueue* queue) {
    pthread_mutex_lock(&queue->lock);
    if (!queue->head) {  // 空队列
        pthread_mutex_unlock(&queue->lock);
        return NULL;
    }

    // 移除头节点
    DPQueueNode* node = queue->head;
    void* data = node->data;
    queue->head = node->next;
    if (!queue->head) {
        queue->tail = NULL;
    }
    queue->size--;
    dp_always_free_really(node);  // 释放节点内存

    pthread_mutex_unlock(&queue->lock);
    return data;
}

// 获取队列长度（线程安全）
size_t dp_queue_length(DPQueue* queue) {
    pthread_mutex_lock(&queue->lock);
    size_t size = queue->size;
    pthread_mutex_unlock(&queue->lock);
    return size;
}

// 销毁队列（需由调用者确保内存释放）
void dp_queue_destroy(DPQueue* queue) {
    pthread_mutex_lock(&queue->lock);
    DPQueueNode* cur = queue->head;
    while (cur) {
        DPQueueNode* next = cur->next;
        dp_always_free_really(cur);
        cur = next;
    }
    pthread_mutex_unlock(&queue->lock);
    pthread_mutex_destroy(&queue->lock);
    dp_always_free_really(queue);
}

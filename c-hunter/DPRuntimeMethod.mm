//
//  DPRuntimeMethod.c
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#include "DPRuntimeMethod.h"
#import <objc/runtime.h>

bool dp_is_oc_object(void* p) {
    // 检查是否是有效的 isa 指针
    Class cls = object_getClass((__bridge id)p);
    if (!cls) return false;
    // 检查是否是已知的类
    const char *className = class_getName(cls);
    return (className && strlen(className) > 0);
}

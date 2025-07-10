//
//  DPRuntimeMethod.c
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#include "DPRuntimeMethod.h"
#import <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>

CFMutableSetRef registeredClasses;

void dp_init_registeredClass(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registeredClasses = CFSetCreateMutable(NULL, 0, NULL);
        unsigned int count = 0;
        Class *classes = objc_copyClassList(&count);
        for (unsigned int i = 0; i < count; i++) {
            CFSetAddValue(registeredClasses, (__bridge const void *)(classes[i]));
        }
        free(classes);
        classes=NULL;
    });
}

bool dp_is_oc_object(void* p) {
    // 检查是否是有效的 isa 指针
    Class cls = object_getClass((__bridge id)p);
    if (!cls) return false;
    return CFSetContainsValue(registeredClasses, &cls);
}

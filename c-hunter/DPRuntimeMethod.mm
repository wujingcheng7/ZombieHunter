//
//  DPRuntimeMethod.c
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#include "DPRuntimeMethod.h"
#include <malloc/malloc.h>
#import <os/lock.h>
#import <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>

CFMutableSetRef registeredClasses;
static os_unfair_lock zombieCheckLock = OS_UNFAIR_LOCK_INIT;

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

bool dp_is_oc_object(void *p) {
    if (!p) {
        return false;
    }
    vm_address_t address = (vm_address_t)p;
    if (address < 0x1000 || address > UINT32_MAX) {
        return false;
    }
    id idP = (__bridge id)p;
    if (!idP) {
        return false;
    }
    Class cls = object_getClass(idP);
    if (!cls) {
        return false;
    }
    bool result = CFSetContainsValue(registeredClasses, (void *)cls);
    return result;
}

////  HYZombie.m
//  DDZombieDetector
//
//  Created by Alex Ting on 2018/7/14.
//  Copyright © 2018年 Alex. All rights reserved.
//

#if __has_feature(objc_arc)
#error This file must be compiled without ARC. Use -fno-objc-arc flag.
#endif

#import "DDZombie.h"
#import "DDZombieMonitor.h"
#import "DDThreadStack.hpp"

#import <objc/runtime.h>

@interface DDZombie ()

@property (nonatomic, assign)DDThreadStack *threadStack;

@end

@implementation DDZombie

+ (Class)zombieIsa
{
    return [self class];
}

+ (NSInteger)zombieInstanceSize
{
    return class_getInstanceSize([DDZombie zombieIsa]);
}

-(void)setThreadStackObj:(void *)stack {
    self.threadStack = (DDThreadStack *)stack;
}

- (size_t)calculateThreadStackSizeAndFreeThreadStack {
    size_t threadStackMemSize = 0;
    if (self.threadStack) {
        threadStackMemSize = self.threadStack->occupyMemorySize();
        delete self.threadStack;
        self.threadStack = NULL;
    }
    return threadStackMemSize;
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    @autoreleasepool {
        DDThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(aSelector) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature* sig = [super methodSignatureForSelector:@selector(doNothing)];
    return sig;
}

- (void)doNothing
{
    // 我只是保护一下crash，什么也不干
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [self doNothing];
}

-(void)dealloc{
    @autoreleasepool {
        DDThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    [super dealloc];
}

-(instancetype)retain
{
    @autoreleasepool {
        DDThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    return nil;
}

- (id)copy
{
    @autoreleasepool {
        DDThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    return nil;
}

- (id)mutableCopy
{
    @autoreleasepool {
        DDThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    return nil;
}

-(oneway void)release{
    @autoreleasepool {
        DDThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
}

- (instancetype)autorelease{
    @autoreleasepool {
        DDThreadStack* zombieStack = hy_getCurrentStack();
        [self handleZombieWithSelector:NSStringFromSelector(_cmd) zombieStack:zombieStack deallocStack:self.threadStack];
        delete zombieStack;
    }
    return nil;
}

- (void)handleZombieWithSelector:(NSString *)selectorName zombieStack:(DDThreadStack *)zombieStack deallocStack:(DDThreadStack *)deallocStack
{
    @autoreleasepool {
        if ([DDZombieMonitor sharedInstance].handle) {
            NSString *deallocStackInfo = nil;
            NSString *zombieStackInfo = nil;
            if (deallocStack) {
                deallocStackInfo = [[NSString alloc]initWithUTF8String:deallocStack->currentStackInfo().c_str()];
            }
            if (zombieStack) {
                zombieStackInfo = [[NSString alloc]initWithUTF8String:zombieStack->currentStackInfo().c_str()];
            }
            
            NSString *realClassString = NSStringFromClass(self.realClass);
            [DDZombieMonitor sharedInstance].handle(realClassString, self, selectorName, deallocStackInfo, zombieStackInfo);
        }
    }
    
    if ([DDZombieMonitor sharedInstance].crashWhenDetectedZombie) {
        assert(0); ///如果不保护，刚直接进入assert中断程序
    }
}

@end

//  DDZombie.h
//  DDZombieDetector
//
//  Created by Alex Ting on 2018/7/14.
//  Copyright © 2018年 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDZombie : NSObject

@property (nonatomic, assign)Class realClass;

+ (Class)zombieIsa;
+ (NSInteger)zombieInstanceSize;

- (void)setThreadStackObj:(void *)stack;
- (size_t)calculateThreadStackSizeAndFreeThreadStack;

@end

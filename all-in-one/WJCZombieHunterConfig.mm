//
//  WJCZombieHunterConfig.m
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#import "WJCZombieHunterConfig.h"
#import "DPLogic.h"

// MARK: - C Config

@implementation WJCZombieHunterCConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldWork = YES;
        _maxStealMemorySizeBytes = DP_DEFAULT_MAX_STEAL_MEMORY_SIZE;
        _maxStealMemoryNumber = DP_DEFAULT_MAX_STEAL_MEMORY_NUMBER;
        _batchFreeNumber = DP_DEFAULT_BATCH_FREE_NUMBER;
    }
    return self;
}

- (BOOL)crashWhenDetectedZombie {
    return YES;
}

@end

// MARK: - OC Config

@implementation WJCZombieHunterOCConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldWork = YES;
        _crashWhenDetectedZombie = YES;
        _maxOccupyMemorySizeBytes = 10 * 1024 * 1024;
        _traceDeallocStack = YES;
        _detectStrategy = WJCZombieOCDetectStrategyAll;
        _blackList = nil;
        _whiteList = nil;
        _filterList = nil;
        _handler = nil;
    }
    return self;
}

@end

// MARK: - Total Config

@implementation WJCZombieHunterConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _cConfig = [WJCZombieHunterCConfig new];
        _ocConfig = [WJCZombieHunterOCConfig new];
    }
    return self;
}

@end

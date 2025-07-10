//
//  WJCZombieHunter.m
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#import "WJCZombieHunter.h"
#import "DDZombieMonitor.h"
#import "DPLogic.h"

@implementation WJCZombieHunter

+ (void)startWorkWithConfig:(WJCZombieHunterConfig *)config {
    [self stopWork];
    if (config.ocConfig.shouldWork) {
        WJCZombieHunterOCConfig *ocConfig = config.ocConfig;
        DDZombieMonitor *ocMonitor = [DDZombieMonitor sharedInstance];
        ocMonitor.crashWhenDetectedZombie = ocConfig.crashWhenDetectedZombie;
        ocMonitor.maxOccupyMemorySize = ocConfig.maxOccupyMemorySizeBytes;
        ocMonitor.traceDeallocStack = ocConfig.traceDeallocStack;
        ocMonitor.detectStrategy = [self strategyConvert:ocConfig.detectStrategy];
        ocMonitor.blackList = ocConfig.blackList;
        ocMonitor.whiteList = ocConfig.whiteList;
        ocMonitor.filterList = ocConfig.filterList;
        ocMonitor.handle = ocConfig.handler;
        [ocMonitor startMonitor];
    }
    if (config.cConfig.shouldWork) {
        WJCZombieHunterCConfig *cConfig = config.cConfig;
        dp_maxStealMemorySize = (int)cConfig.maxStealMemorySizeBytes;
        dp_maxStealMemoryNumber = (int)cConfig.maxStealMemoryNumber;
        dp_batchFreeNumber = (int)cConfig.batchFreeNumber;
        dp_start_monitor();
    }
}

+ (void)stopWork {
    [[DDZombieMonitor sharedInstance] stopMonitor]; // OC stop
    dp_end_monitor(); // C stop
}

+ (DDZombieDetectStrategy)strategyConvert:(WJCZombieOCDetectStrategy)origin {
    switch (origin) {
        case WJCZombieOCDetectStrategyAll:
            return DDZombieDetectStrategyAll;
        case WJCZombieOCDetectStrategyCustomObjectOnly:
            return DDZombieDetectStrategyCustomObjectOnly;
        case WJCZombieOCDetectStrategyWhitelist:
            return DDZombieDetectStrategyWhitelist;
        case WJCZombieOCDetectStrategyBlacklist:
            return DDZombieDetectStrategyBlacklist;
        default:
            return DDZombieDetectStrategyCustomObjectOnly;
    }
}

@end

//
//  WJCZombieHunter.m
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#import "WJCZombieHunter.h"
#import "DDZombieMonitor.h"
#import "DDBinaryImages.h"
#import "DPLogic.h"

@interface WJCZombieHunter ()

@property (nonatomic, readwrite) BOOL isMonitoring;
@property (nonatomic, strong, nonnull) DDZombieMonitor *ocMonitor;

@end

@implementation WJCZombieHunter

+ (WJCZombieHunter *)shared {
    static WJCZombieHunter *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [WJCZombieHunter new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _ocMonitor = [DDZombieMonitor sharedInstance];
    }
    return self;
}

- (void)handleMemoryWarning {
    dp_free_some_memory_if_needed();
}

+ (void)startMonitoringWithConfig:(WJCZombieHunterConfig *)config {
    [[self shared] startMonitoringWithConfig:config];
}

- (void)startMonitoringWithConfig:(WJCZombieHunterConfig *)config {
    [self stopMonitoring];
    @synchronized (self) {
        self.isMonitoring = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        if (config.ocConfig.shouldWork) {
            WJCZombieHunterOCConfig *ocConfig = config.ocConfig;
            DDZombieMonitor *ocMonitor = self.ocMonitor;
            ocMonitor.crashWhenDetectedZombie = ocConfig.crashWhenDetectedZombie;
            ocMonitor.maxOccupyMemorySize = ocConfig.maxOccupyMemorySizeBytes;
            ocMonitor.traceDeallocStack = ocConfig.traceDeallocStack;
            ocMonitor.detectStrategy = [WJCZombieHunter strategyConvert:ocConfig.detectStrategy];
            ocMonitor.blackList = ocConfig.blackList;
            ocMonitor.whiteList = ocConfig.whiteList;
            ocMonitor.filterList = ocConfig.filterList;
            WJCZombieDetectionHandler handler = ocConfig.handler;
            if (handler) {
                ocMonitor.handle = ^(NSString *className,
                                     void *obj,
                                     NSString *selectorName,
                                     NSString *deallocStack,
                                     NSString *zombieStack) {
                    WJCZombieInfo *zombieInfo = [WJCZombieInfo new];
                    zombieInfo.className = className ?: @"";
                    zombieInfo.obj = obj;
                    zombieInfo.selectorName = selectorName ?: @"";
                    zombieInfo.deallocStack = deallocStack ?: @"";
                    zombieInfo.zombieStack = zombieStack ?: @"";
                    if (handler) {
                        handler(zombieInfo);
                    }
                };
            } else {
                ocMonitor.handle = nil;
            }
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
}

+ (void)stopMonitoring {
    [[self shared] stopMonitoring];
}

- (void)stopMonitoring {
    @synchronized (self) {
        if (!self.isMonitoring) {
            return;
        }
        self.isMonitoring = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidReceiveMemoryWarningNotification
                                                      object:nil];
        [[DDZombieMonitor sharedInstance] stopMonitor]; // OC stop
        dp_end_monitor(); // C stop
    }
}

+ (BOOL)isMonitoring {
    return [self shared].isMonitoring;
}

+ (NSArray *)binaryImages {
    return [DDBinaryImages binaryImages];
}

- (NSArray *)binaryImages {
    return [DDBinaryImages binaryImages];
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

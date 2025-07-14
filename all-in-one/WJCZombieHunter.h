//
//  WJCZombieHunter.h
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#import <Foundation/Foundation.h>
#import "WJCZombieHunterConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface WJCZombieHunter : NSObject

+ (BOOL)isMonitoring;
+ (void)startMonitoringWithConfig:(WJCZombieHunterConfig *)config NS_SWIFT_NAME(startMonitoring(config:));
+ (void)stopMonitoring;
+ (NSMutableArray<NSString *>*)binaryImages;

@end

NS_ASSUME_NONNULL_END

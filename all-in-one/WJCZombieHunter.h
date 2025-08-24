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

@property (nonatomic, readonly) BOOL isMonitoring;

+ (instancetype)shared;
+ (BOOL)isMonitoring;
+ (void)startMonitoringWithConfig:(WJCZombieHunterConfig *)config NS_SWIFT_NAME(startMonitoring(config:));
- (void)startMonitoringWithConfig:(WJCZombieHunterConfig *)config NS_SWIFT_NAME(startMonitoring(config:));
+ (void)stopMonitoring;
- (void)stopMonitoring;
+ (NSArray<NSString *>*)binaryImages;
- (NSArray<NSString *>*)binaryImages;

@end

NS_ASSUME_NONNULL_END

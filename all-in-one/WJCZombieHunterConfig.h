//
//  WJCZombieHunterConfig.h
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WJCZombieOCDetectStrategy) {
    WJCZombieOCDetectStrategyAll = 0, // 监控所有对象，强制过滤类除外, 默认使用该策略
    WJCZombieOCDetectStrategyBlacklist = 1, // 使用黑名单
    WJCZombieOCDetectStrategyWhitelist = 2, // 使用白名单
    WJCZombieOCDetectStrategyCustomObjectOnly = 3, // 只监控自定义对象
};

/// Config for C Language
@interface WJCZombieHunterCConfig : NSObject

/// ShouldWorkForCLanguage ? Default is YES
@property (nonatomic) BOOL shouldWork;
/// 监测到 zombie 时是否触发 crash，Always is YES
@property (nonatomic, readonly) BOOL crashWhenDetectedZombie;
/// 最多保留多少总内存的 C 指针？Default is 10 MB
@property (nonatomic) NSInteger maxStealMemorySizeBytes;
/// 最多保留多少个 C 指针? Default is 10 M
@property (nonatomic) NSInteger maxStealMemoryNumber;
/// 每次释放多少个指针？默认值 100 个
@property (nonatomic) NSInteger batchFreeNumber;

@end

/// Config for Objective-C Language
@interface WJCZombieHunterOCConfig : NSObject

/// Default is YES
@property (nonatomic) BOOL shouldWork;
/// 监测到 zombie 时是否触发 crash，Default is YES
@property (nonatomic) BOOL crashWhenDetectedZombie;
/// 组件最大占用内存大小，包括延迟释放内存大小和释放栈内存大小，Default is 10M[10 * 1024 * 1024]
@property (nonatomic) NSInteger maxOccupyMemorySizeBytes;
/// 是否记录 dealloc 栈，Default is YES
@property (nonatomic) BOOL traceDeallocStack;
/// 监控策略，Default is .all
@property (nonatomic) WJCZombieOCDetectStrategy detectStrategy;
/// Only work when self.detectStrategy == .blacklist，Default is nil
@property (nonatomic, strong, nullable) NSArray<NSString*> *blackList;
/// Only work when self.detectStrategy == .whitelist，Default is nil
@property (nonatomic, strong, nullable) NSArray<NSString*> *whiteList;
/// 强制过滤类，不受监控策略影响，主要用于过滤频繁创建的对象，比如log。Default is nil
@property (nonatomic, strong, nullable) NSArray<NSString*> *filterList;
/**
 * handle，监测到zombie时调用
 * @param className zombie对象名
 * @param obj zombie对象地址
 * @param selectorName selector
 * @param deallocStack zombie对象释放栈，格式:{\ntid:xxx\nstack:[xxx,xxx,xxx]\n},栈为未符号化的函数地址
 * @param zombieStack  zombie对象调用栈，格式:{\ntid:xxx\nstack:[xxx,xxx,xxx]\n},栈为未符号化的函数地址
 */
@property (nonatomic, strong, nullable) void (^handler)(NSString * _Nullable className,
                                                        void *obj,
                                                        NSString * _Nullable selectorName,
                                                        NSString * _Nullable deallocStack,
                                                        NSString * _Nullable zombieStack);

@end

@interface WJCZombieHunterConfig : NSObject

/// Config for C Language
@property (nonatomic, readonly, nonnull) WJCZombieHunterCConfig* cConfig;
/// Config for Objective-C Language
@property (nonatomic, readonly, nonnull) WJCZombieHunterOCConfig* ocConfig;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END

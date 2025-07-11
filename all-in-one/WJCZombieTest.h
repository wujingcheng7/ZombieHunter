//
//  WJCZombieTest.h
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WJCZombieTest : NSObject

/**
 * 测试OC僵尸对象（自定义Swift方法名）
 * @param accidentalCoverage 是否发生意外内存覆盖
 * 若 accidentalCoverage 为 false，通常会立即发生崩溃
 * 若 accidentalCoverage 为 true，不会立即发生崩溃而是获得错误的结果。但是如果先让 WJCZombieHunter 开始工作，则可以捕获这一信息。
 */
+ (void)testOCZombieWithAccidentalCoverage:(BOOL)accidentalCoverage
NS_SWIFT_NAME(testOCObjectZombie(accidentalCoverage:));

@end

NS_ASSUME_NONNULL_END

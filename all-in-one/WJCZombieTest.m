//
//  WJCZombieTest.m
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/11.
//

#import "WJCZombieTest.h"
#import <UIKit/UIKit.h>

#define WJCZombieTestCorrectMagicNumber 19450815
#define WJCZombieTestWrongMagicNumber 19310918

@implementation WJCZombieTest

+ (void)testOCZombieWithAccidentalCoverage:(BOOL)accidentalCoverage {
    [self logOCEvent:accidentalCoverage event:@"start"];
    __unsafe_unretained UIView* zombieObject;
    NSMutableArray *array = [NSMutableArray new];

    @autoreleasepool {
        UIView *newObject = [UIView new];
        newObject.tag = WJCZombieTestCorrectMagicNumber;
        zombieObject = newObject;
    }

    // zombieObject 现在是僵尸对象了

    if (accidentalCoverage) {
        @autoreleasepool { // 假如释放的内存上又意外填上了另一个对象的指针，而那个对象有着相似的内存结构
            UIView* accidentalObject = [UIView new];
            accidentalObject.tag = WJCZombieTestWrongMagicNumber;
            [array addObject:accidentalObject];
            [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nil];
        }
    }

    // 这里调用一下僵尸对象
    NSInteger result = zombieObject.tag;
    [self logOCEvent:accidentalCoverage
               event:[[NSString alloc] initWithFormat:@"result[%d]%@",
                      result,
                      (result == WJCZombieTestCorrectMagicNumber) ? @"✅" : @"❌"
                     ]];
    [self logOCEvent:accidentalCoverage event:@"end"];
}

+ (void)logOCEvent:(BOOL)accidentalCoverage event:(NSString *)event {
    NSLog(@"[ZombieHunter]-accidentalCoverage[%@]-correct[%d]-%@",
          accidentalCoverage ? @"YES" : @"NO",
          WJCZombieTestCorrectMagicNumber,
          event);
}

@end

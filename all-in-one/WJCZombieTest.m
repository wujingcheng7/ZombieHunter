//
//  WJCZombieTest.m
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/11.
//

#import "WJCZombieTest.h"

#define WJCZombieTestRightMagicNumber 233
#define WJCZombieTestAccidentMagicNumber -1

@interface WJCZombieTestObject : NSObject

@property (nonatomic) NSInteger magicNumber;

@end

@implementation WJCZombieTestObject

@end

@implementation WJCZombieTest

+ (void)testOCZombieWithAccidentalCoverage:(BOOL)accidentalCoverage {
    [self logOCEvent:accidentalCoverage event:@"start"];
    __unsafe_unretained WJCZombieTestObject* zombieObject;
    NSMutableArray *array = [NSMutableArray new];

    @autoreleasepool {
        WJCZombieTestObject *newObject = [WJCZombieTestObject new];
        newObject.magicNumber = WJCZombieTestRightMagicNumber;
        zombieObject = newObject;
    }

    // zombieObject 现在是僵尸对象了

    if (accidentalCoverage) {
        @autoreleasepool { // 假如释放的内存上又意外填上了另一个对象的指针，而那个对象有着相似的内存结构
            WJCZombieTestObject* accidentalObject = [WJCZombieTestObject new];
            accidentalObject.magicNumber = WJCZombieTestAccidentMagicNumber;
            [array addObject:accidentalObject];
            [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nil];
        }
    }

    // 这里调用一下僵尸对象
    [self logOCEvent:accidentalCoverage
               event:[[NSString alloc] initWithFormat:@"result[%d]%@",
                      zombieObject.magicNumber,
                      (zombieObject.magicNumber == WJCZombieTestRightMagicNumber) ? @"✅" : @"❌"
                     ]];
    [self logOCEvent:accidentalCoverage event:@"end"];
}

+ (void)logOCEvent:(BOOL)accidentalCoverage event:(NSString *)event {
    NSLog(@"[ZombieHunter]-accidentalCoverage[%@]-correct[%d]-%@",
          accidentalCoverage ? @"YES" : @"NO",
          WJCZombieTestRightMagicNumber,
          event);
}

@end

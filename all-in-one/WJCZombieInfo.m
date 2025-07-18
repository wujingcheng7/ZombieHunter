//
//  WJCZombieInfo.m
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/15.
//

#import "WJCZombieInfo.h"
#import "WJCZombieHunter.h"
#import <UIKit/UIKit.h>

@implementation WJCZombieInfo

- (NSString *)jsonFileText {
    if (!_jsonFileText) {
        NSString *addressString = [NSString stringWithFormat:@"%p", self.obj] ?: @"0x0";
        NSDictionary *jsonDict = @{
            @"model": [[UIDevice currentDevice] model],
            @"systemVersion": [[UIDevice currentDevice] systemVersion],
            @"systemName": [[UIDevice currentDevice] systemName],
            @"bundleId": [[NSBundle mainBundle] bundleIdentifier],
            @"appVersion": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
            @"appBuildVersion": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
            @"zombieObjectAddress": addressString ?: @"0x0",
            @"className": self.className,
            @"selectorName": self.selectorName,
            @"zombieStack": self.zombieStack,
            @"deallocStack": self.deallocStack,
            @"binaryImages": [WJCZombieHunter binaryImages] ?: @[]
        };
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&error];
        if (!error && jsonData) {
            _jsonFileText = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
            _jsonFileText = @"{}"; // Fallback empty JSON
        }
    }
    return _jsonFileText;
}

@end

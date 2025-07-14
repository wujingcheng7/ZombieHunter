# ZombieHunter

| Helps detect wild pointers/zombie objects/dangling references in iOS projects early, supports OC/C

## [中文介绍](README_CN.md)

## Features

### Objective-C Objects

- Expose OC zombie objects early
- Provide detailed information when exposed:
  - Class name
  - Method name
  - Object address
  - Stack trace when object was deallocated
  - Stack trace when object was called
- Offers 4 monitoring strategies:
  - Monitor only custom objects (default strategy)
  - Use blacklist
  - Use whitelist
  - Monitor all objects (with mandatory class filtering)
- Configurable maximum memory usage (default: 10MB)
- Configurable whether to record deallocation stack (default: YES)
- Configurable whether to crash when zombie is detected (default: YES)
- Can use Symbolicating.py file to symbolize stack traces

### C Pointers

- Expose wild pointers early
- Configurable maximum memory usage (default: 10MB)

## Usage

### Podfile Code

```ruby
pod 'ZombieHunter'
# If you only want to use in Debug mode:
# pod 'ZombieHunter', :configurations => ['Debug', 'Inhouse', 'Dev']
```

### Starting and Stopping Monitoring

```Objective-C
@import ZombieHunter; // import pod

- (void)whenEverYourWantToStartMonitorZombie {
    // Create default config with separate settings for cConfig and ocConfig
    WJCZombieHunterConfig *config = [WJCZombieHunterConfig new];

    // Custom NSObject wild pointer settings
    config.ocConfig.shouldWork = YES; // Whether to detect NSObject objects
    config.ocConfig.crashWhenDetectedZombie = YES; // Whether to crash immediately when wild pointer is detected
    config.ocConfig.detectStrategy = WJCZombieOCDetectStrategyAll; // Custom monitoring strategy
    config.ocConfig.traceDeallocStack = YES; // Whether to record call stack when object is first deallocated
    config.ocConfig.whiteList = nil; // Custom whitelist (requires config.ocConfig.detectStrategy = .whitelist)
    config.ocConfig.blackList = nil; // Custom blacklist (requires config.ocConfig.detectStrategy = .blacklist)
    config.ocConfig.filterList = nil; // Custom filter list
    config.ocConfig.maxOccupyMemorySizeBytes = 50 * 1024 * 1024; // Custom max memory cache
    config.ocConfig.handler = ^(NSString * _Nullable className,
                                void * _Nonnull obj,
                                NSString * _Nullable selectorName,
                                NSString * _Nullable deallocStack,
                                NSString * _Nullable zombieStack) {
        // Custom handling of this information
    };

    // Custom C wild pointer settings (completely independent from NSObject settings)
    config.cConfig.shouldWork = YES; // Whether to detect C wild pointers
    config.cConfig.crashWhenDetectedZombie; // Always YES. Set config.cConfig.shouldWork = NO if you don't want immediate crash
    config.cConfig.maxStealMemorySizeBytes = 50 * 1024 * 1024; // Custom max memory cache

    [WJCZombieHunter startWorkWithConfig:config]; // Start monitoring
}

- (void)whenEverYourWantToStopMonitorZombie {
    [WJCZombieHunter stopWork]; // Stop monitoring
}

- (void)testZombieWithAccidentalCoverage {
    /*
     If ZombieHunter OC monitoring is NOT enabled:
     Output: [ZombieHunter]-accidentalCoverage[YES]-correct[19450815]-result[19310918]❌
     This indicates your program isn't crashing yet, but producing uncontrolled incorrect results

     If ZombieHunter OC monitoring is enabled:
     The ocConfig.handler will provide detailed information, allowing you to take any desired action 
     (e.g., upload logs/force quit the app/etc.)
     */
    [WJCZombieTest testOCZombieWithAccidentalCoverage:YES];
}

- (void)testZombieWithoutAccidentalCoverage {
    /*
     If ZombieHunter OC monitoring is NOT enabled:
     Immediate crash: Thread 1: EXC_BAD_ACCESS

     If ZombieHunter OC monitoring is enabled:
     The ocConfig.handler will provide detailed information, allowing you to take any desired action
     (e.g., upload logs/prevent immediate crash/etc.)
     */
    [WJCZombieTest testOCZombieWithAccidentalCoverage:NO];
}
```

### Code Notes

```Objective-C
// Please only use classes and methods with WJC prefix, do not use other classes/methods directly
```

## Contributions

### Contribution Summary

- Core code for OC zombie objects comes from AlexTing0's open source library
- Core concept for C wild pointers comes from TencentBuglyTeam/Chen Qifeng's technical articles
- C wild pointer code depends on Facebook's fishhook (using latest code due to bug in fishhook 0.2)
  - Current fishhook version: aadc161ac3b80db07a9908851839a17ba63a9eb1
- wujingcheng7 integrated these components:
  - Created pod version for easy integration and direct use

### Contribution Links

- AlexTing0
  - homepage: <https://github.com/AlexTing0>
  - article: <https://github.com/AlexTing0/Monitor_Zombie_in_iOS>
  - repo: <https://github.com/AlexTing0/DDZombieMonitor>

- TencentBuglyTeam/Chen Qifeng
  - homepage: <https://cloud.tencent.com/developer/user/1069749>
  - article1: <https://cloud.tencent.com/developer/article/1070505>
  - article2: <https://cloud.tencent.com/developer/article/1070512>
  - article3: <https://cloud.tencent.com/developer/article/2256759>

- FacebookTeam
  - homepage: <https://github.com/facebook>
  - repo: <https://github.com/facebook/fishhook>
  - repoVersion: aadc161ac3b80db07a9908851839a17ba63a9eb1

## License

ZombieHunter uses MIT license, free to use

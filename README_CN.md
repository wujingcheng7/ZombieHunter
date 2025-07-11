# ZoombieHunter

| 帮助你尽早发现 iOS 项目中的 野指针/僵尸对象/悬垂引用，支持 OC/C

## 功能

### Objective-C 对象

- 让 OC 僵尸对象尽早暴露
- 暴露时提供详细信息
  - 类名
  - 方法名
  - 对象地址
  - 对象释放时的栈
  - 对象调用时的栈
- 提供 4 种监控策略
  - 只监控自定义对象, 默认使用该策略
  - 使用黑名单
  - 使用白名单
  - 监控所有对象，强制过滤类除外
- 可控制最大占用内存大小，默认 10MB
- 可控制是否记录释放栈，默认 YES
- 可控制检测到Zoombie时是否崩溃，默认YES
- 可使用 Symbolicating.py 文件，对栈信息进行符号化

### C 指针

- 让野指针尽早暴露
- 可控制最大占用内存大小，默认 10MB

## 使用方式

### Podfile 文件代码

```Ruby
pod 'ZoombieHunter'
# 如果你只希望在 Debug 模式下使用，可以使用如下代码
# pod 'ZombieHunter', :configurations => ['Debug', 'Inhouse', 'Dev']
```

### 发起监控和停止监控

```Objective-C
@import ZombieHunter; // import pod

- (void)whenEverYourWantToStartMonitorZombie {
    // 新建一个默认设置，包含 cConfig 和 ocConfig 两个完全独立的配置
    WJCZombieHunterConfig *config = [WJCZombieHunterConfig new];

    // 自定义 Objective-C NSObject 野指针 相关设置
    config.ocConfig.shouldWork = YES; // 是否检测 NSObject 对象
    config.ocConfig.crashWhenDetectedZombie = YES; // 野指针被发现时，是否立即触发崩溃
    config.ocConfig.detectStrategy = WJCZombieOCDetectStrategyAll; // 自定义监控策略
    config.ocConfig.traceDeallocStack = YES; // 是否记录对象首次释放时的调用栈
    config.ocConfig.whiteList = nil; // 自定义监控白名单，需要 config.ocConfig.detectStrategy = .whitelist
    config.ocConfig.blackList = nil; // 自定义监控黑名单，需要 config.ocConfig.detectStrategy = .blacklist
    config.ocConfig.filterList = nil; // 自定义过滤名单
    config.ocConfig.maxOccupyMemorySizeBytes = 50 * 1024 * 1024; // 自定义最大内存缓存
    config.ocConfig.handler = ^(NSString * _Nullable className,
                                void * _Nonnull obj,
                                NSString * _Nullable selectorName,
                                NSString * _Nullable deallocStack,
                                NSString * _Nullable zombieStack) {
        // 自定义如何使用这些信息
    };

    // 自定义 C 野指针 相关设置，这些设置与 NSObject 设置完全独立
    config.cConfig.shouldWork = YES; // 你可以决定是否检测 C 野指针
    config.cConfig.crashWhenDetectedZombie; // 总是为 YES。若不希望其立即崩溃，可以设置 config.cConfig.shouldWork = NO;
    config.cConfig.maxStealMemorySizeBytes = 50 * 1024 * 1024; // 自定义最大内存缓存

    [WJCZombieHunter startWorkWithConfig:config]; // 开始监控
}

- (void)whenEverYourWantToStopMonitorZombie {
    [WJCZombieHunter stopWork]; // 停止监控
}
```

### 代码注意事项

```Objective-C
// 请注意，请使用 WJC 前缀的相关的类和方法，其他类和方法请不要直接使用
```

## 贡献

### 贡献简述

- OC 僵尸对象的核心代码来自于 AlexTing0 的开源库
- C 野指针的核心思路来自于 TencentBuglyTeam/陈其锋 的技术文章
- C 野指针的代码依赖于 Facebook 的 fishhook，由于 fishhook 0.2 有 bug，所以直接使用了其最新代码
  - 当前版本使用的 fishhook 版本: aadc161ac3b80db07a9908851839a17ba63a9eb1
- wujingcheng7 整合了上述内容
  - 制作成 pod 版本，可以快速引入并且直接使用

### 贡献链接

- AlexTing0
  - homepage: <https://github.com/AlexTing0>
  - article: <https://github.com/AlexTing0/Monitor_Zombie_in_iOS>
  - repo: <https://github.com/AlexTing0/DDZombieMonitor>

- TencentBuglyTeam/陈其锋
  - homepage: <https://cloud.tencent.com/developer/user/1069749>
  - article1: <https://cloud.tencent.com/developer/article/1070505>
  - article2: <https://cloud.tencent.com/developer/article/1070512>
  - article3: <https://cloud.tencent.com/developer/article/2256759>

- FacebookTeam
  - homepage: <https://github.com/facebook>
  - repo: <https://github.com/facebook/fishhook>
  - repoVersion: aadc161ac3b80db07a9908851839a17ba63a9eb1

## 开源协议

ZoombieHunter 使用 MIT 协议，可以随意使用

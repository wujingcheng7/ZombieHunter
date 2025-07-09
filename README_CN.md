# ZoombieHunter

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

## 使用方式

### Podfile 文件代码

```Ruby
pod 'ZoombieHunter'
```

## 贡献

作者复制了 AlexTing0 的开源库，OC 僵尸对象的核心代码来自于这里
作者阅读了 TencentBuglyTeam/陈其锋 的技术文章，C 野指针的核心思路来自于这里
整理后形成了这个库，并且制作成 pod 以方便所有人使用
特此鸣谢以下优秀开发者:

- AlexTing0
  - homepage: <https://github.com/AlexTing0>
  - article: <https://github.com/AlexTing0/Monitor_Zombie_in_iOS>
  - repo: <https://github.com/AlexTing0/DDZombieMonitor>

- TencentBuglyTeam/陈其锋
  - homepage: <https://cloud.tencent.com/developer/user/1069749>
  - article1: <https://cloud.tencent.com/developer/article/1070505>
  - article2: <https://cloud.tencent.com/developer/article/1070512>
  - article3: <https://cloud.tencent.com/developer/article/2256759>

## 开源协议

ZoombieHunter 使用 MIT 协议，可以随意使用

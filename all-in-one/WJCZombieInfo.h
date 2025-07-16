//
//  WJCZombieInfo.h
//  ZombieHunter
//
//  Created by 吴京城(wujingcheng7) on 2025/7/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WJCZombieInfo : NSObject

/// Zombie object's class name
/// 僵尸对象的类名
@property (nonatomic, strong, nonnull) NSString *className;
/// Pointer address of the zombie object
/// 僵尸对象的内存地址指针
@property (nonatomic, assign, nonnull) void *obj;
/// Name of the selector that was called on the zombie object
/// 在僵尸对象上调用的方法选择器名称
@property (nonatomic, strong, nonnull) NSString *selectorName;
/// Deallocation stack trace (format: {\ntid:xxx\nstack:[xxx,xxx,xxx]\n})
/// 对象释放时的调用栈（格式：{\ntid:xxx\nstack:[xxx,xxx,xxx]\n}）
@property (nonatomic, strong, nonnull) NSString *deallocStack;
/// Zombie call stack trace (format: {\ntid:xxx\nstack:[xxx,xxx,xxx]\n})
/// 僵尸对象调用时的调用栈（格式：{\ntid:xxx\nstack:[xxx,xxx,xxx]\n}）
@property (nonatomic, strong, nonnull) NSString *zombieStack;
/// Complete JSON string for Python parser (contains all zombie info in JSON format)
/// 完整的JSON字符串，作为Python解析脚本的输入数据源（包含所有僵尸对象信息）
@property (nonatomic, strong, nonnull) NSString *jsonFileText;

@end

NS_ASSUME_NONNULL_END

# ASItem
一个 Keychain 的 OC 封装

我们知道，Keychain 的安全在非越狱状态下是系统级的，所以使用 keychain 就等于把数据存储安全提高到 ios 的系统级别，因此针对 keychain 存储做了简单封装，可以满足基本的存储要求。以下提供简单的使用案例

存储
```objc
ASItem *item = ASItem.new;
item.service = @"Login-Password";
item.account = @"Login-Account";
item.valueString = @"password";
[item cover];
```

查询
```objc
ASItemQuery *query = ASItemQuery.new;
query.service = @"Login-Password";
query.account = @"Login-Account";
NSArray<ASItem *> *items = query.match;
if (items.count > 0) {
    NSString *password = items[0].valueString;
}
```

该封装可以配置基本上所有的 kSecClassGenericPassword 相关的属性，并作了一些注释，具体可以参考头文件

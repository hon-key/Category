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

# ReqRes
一个基于 AFNetworking 和 YYModel 的'面向接口'的网络请求框架

通过业务总结，设计出一套极简单的接口对接框架

这套框架具备以下优点：

- 简洁

面向对象，通过 YYModel 来转化 json 与 属性，使得属性即接口

抽离通用的请求模块，使得接入一个接口只需要关心最少的和接口有关的东西

调用方式很简洁，具备面向对象的特点，易读

- 扩展性强

可以参照针对 PureRequest 类所扩展出来的 Request（带基础参数的 request） ResponseWithExtractData（解出 json 中 嵌套 data 的 request） RequestWithPage （带分页的 request）进行扩展

举个简单的栗子，接入一个发送验证码的接口：

接口采用 POST 方式交互， json 的方式传输请求体，返回的 content 也为 json 数据

```objc
// 声明响应接口，继承 Response，Response 里包含错误码和错误信息的基本字段（可以自定义），包含最基本的错误判断方法
@interface VerifyNoSenderResult : Response
@end

// 声明请求接口，继承 Request，request 包含基本的信息验证字段（可以自定义），泛型为 VerifyNoSenderResult
@interface VerifyNoSender : Request <VerifyNoSenderResult *>
@property (nonatomic,copy) NSString *mobile; // 手机号
@end
```

```objc
@implementation VerifyNoSender
// 设置响应类，让框架可以识别需要解析的类
+ (Class)responseClass {
    retunrn VerifyNoSenderResult.class;
}
// 设置为 POST，这一步可以省略，因为默认为 POS，目前只支持 GET/POST
- (RQHTTPMethod)httpMethodForRequest {
    return RQHTTPMethodPOST;
}
// 设置连接
- (NSString *)urlForRequest {
    return [NSString stringWithFormat:@"%@/sendVerifyNo",@"你的服务器域名"];
}
// 设置请求体为 json 格式，这一步可以省略，因为默认为 json 格式，也可以设置为NO，那么会以 formData 表单格式进行提交
- (BOOL)jsonEncodingForRequest {
    return YES;
}
@end

@implementation VerifyNoSenderResult
@end
```

# MsgStation
一个可以再某些应用场景取代 KVO 的工具

按照某种业务场景，甚至是在写一些基础设施的时候，我们需要解耦某一些类。换句话说，我们在某种程度上不应该把某些类相关联在一起，因为这样会增加复杂度，降低可维护性，同时可能提高出现 bug 的可能性

这个时候我们通常会用到 KVO 来解决这个问题，比如说当用户在一个页面的操作产生了一个结果，这个结果会影响到另外一个页面：

我们可能会用 KVO 来发送通知让那个页面知道，但我们知道，KVO 只适用于两个页面同时被实例化的情况下，而且存在旧 ios 操作系统版本不 remove observer 就有可能崩溃的麻烦问题。

或者我们可能会创建全局变量来获取，但是这样无形之中我们就多了一道管理全局变量的任务，要知道，共享全局变量是多线程问题的罪魁祸首。

那何不针对这种问题统一搞一个可控的全局变量呢？MsgStation 就是为了这个而生的

顾名思义，MsgStation 就是消息站，一个通过离线存储消息的公共区，是一个线程安全的公共区。

按照上面我们举的栗子，当一个用户对一个页面操作产生的结果会影响另外一个页面时，我们可以这样写：

```objc
// 当一个用户对页面A的操作产生了一个结果，调用该代码，塞入一个站内消息：OperationA
[MsgStation.station pushMessage:[[MsgStationMessage alloc] initWithName:@"OperationA" checkableCount:1 data:nil]];
```

```objc
// 当用户进入页面B的时候，check 一下这个 OperationA，如果存在这个消息，就做一下操作
MsgStationMessage *message = [[MsgStation station] checkMessageWithName:@"OperationA"];
if (message) {
    // do something...
}
```

这样做的优点在于，首先两个页面解耦合，其次，页面B不需要事先存在并接受通知。

不仅如此，checkableCount 传入 NSIntegerMax 可以让消息常驻，以此来设定一些已发生事件

在一定程度上，MsgStation 可以替代 KVO 来执行更安全和更便捷的非耦合通讯

# Category

### UIButton (CountDown)
一个简洁的按钮倒计时，倒计时业务较多的情况下可以使用，避免代码冗余

### UIButton (Observer)
一个非常简洁易用的，基于 KVC 的数据监控按钮，按钮可以对一组数据的值进行监控，并自动判断是否应该让按钮不可点击
对于这类业务非常频繁的项目，它会非常合适，极大避免代码冗余

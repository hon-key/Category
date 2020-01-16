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

# Category

### UIButton (CountDown)
一个简洁的按钮倒计时，倒计时业务较多的情况下可以使用，避免代码冗余

### UIButton (Observer)
一个非常简洁易用的，基于 KVC 的数据监控按钮，按钮可以对一组数据的值进行监控，并自动判断是否应该让按钮不可点击
对于这类业务非常频繁的项目，它会非常合适，极大避免代码冗余

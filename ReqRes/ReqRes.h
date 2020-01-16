//  Copyright (c) 2020 HJ-Cai
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <Foundation/Foundation.h>

#pragma mark - Response
@interface Responding : NSObject
/**
网络错误/解析错误/响应错误
*/
@property (nonatomic,strong) NSError *error;
/**
如果请求的响应不是不可以被解析成 NSDictionary，会在这里原样返回
*/
@property (nonatomic,strong) id responseObject;
@end

@interface Response : Responding <YYModel>
/**
服务器返回的错误码，根据业务自定义
*/
@property (nonatomic,copy) NSString *error_code;
/**
服务器返回的错误信息，根据业务自定义
*/
@property (nonatomic,copy) NSString *error_msg;
/**
是否有错误并显示错误信息，如果有错误，返回 YES，否则返回 NO
*/
- (BOOL)hasErrorAndShowIt;
/**
如果有错误，返回 YES，否则返回NO
*/
- (BOOL)hasError;

@end

/**
 针对 json 里嵌套 Data 的接口，为了减少不必要的代码，直接解包 data
*/
@interface ResponseWithExtractData : Response
@end

#pragma mark - Request
typedef NS_ENUM(NSInteger, RQHTTPMethod) {
    RQHTTPMethodPOST = 1,
    RQHTTPMethodGET = 2,
};

@interface Requesting <RespType : NSObject *> : NSObject

/**
定义该请求的 response 类型，默认为 NSObject
*/
@property (class,nonatomic,strong,readonly) Class responseClass;
/**
 该请求的链接，默认为 nil，需要重载
 */
- (NSString *)urlForRequest;
/**
 设置该请求的 HTTP method，默认为 POST
 如果为 POST，所有参数都将转化为 json 或者 formData 的格式放入 body 里
 如果为 GET，所有参数都将转化为 query string 的格式放入 url 后
 */
- (RQHTTPMethod)httpMethodForRequest;
/**
 是否将请求参数转化为 json 的格式放入 body 里，POST 模式下有效，默认为 YES
 如果为 NO，参数将转化为 formData 的格式放入 body 里
 */
- (BOOL)jsonEncodingForRequest;
/**
该请求的超时时间，默认为 10s
*/
- (NSTimeInterval)timeoutInterval;


- (void)requestWithCompletion:(void(^)(RespType result))completion;
@end

@interface PureRequest <RespType : Response *> : Requesting <RespType> <YYModel>

@end

/**
 带基础参数的 Request，基础参数可自定义
*/
@interface Request <RespType : Response *> : PureRequest <RespType> <YYModel>
@property (nonatomic,copy) NSString *ur; // 当前登录用户名
@property (nonatomic,copy) NSString *ses; // 当前 sessionId
@property (nonatomic,copy) NSString *mcr; // 当前商户Id
@property (nonatomic,assign) NSInteger vr; // 版本号
@end

/**
 针对分页接口的 Request
*/
@interface RequestWithPage <RespType : Response *> : Request <RespType>
@property (nonatomic,assign) NSInteger pgNo; // 当前页
@property (nonatomic,assign) NSInteger pgSz; // 每一页的大小
@end

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

#import "ReqRes.h"
#import "sys/utsname.h"
#import <AFNetworking/AFNetworking.h>

AFURLSessionManager * session() {
    static AFURLSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:nil];
        manager.operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        ((AFJSONResponseSerializer *)manager.responseSerializer).acceptableContentTypes = [NSSet setWithArray:@[
        @"multipart/form-data",@"application/json",@"text/html",@"text/text",@"text/json",@"text/plain",
        @"text/javascript",@"text/xml",@"image/*",@"text/x-c",@"application/x-www-form-urlencoded"
        ]];
    });
    return manager;
}

@implementation Requesting

+ (Class)responseClass {
    return Response.class;
}

- (NSString *)urlForRequest {
    return nil;
}

- (RQHTTPMethod)httpMethodForRequest {
    return RQHTTPMethodPOST;
}

- (BOOL)jsonEncodingForRequest {
    return YES;
}

- (NSTimeInterval)timeoutInterval {
    return 10;
}

- (void)requestWithCompletion:(void (^)(NSObject *))completion {
    
    NSAssert(![self.class.responseClass isKindOfClass:Response.class], @"%@ 类的 responseClass 必须是 Response 的子类",NSStringFromClass(self.class));
    
    AFHTTPRequestSerializer *requestSerializer;
    if (self.jsonEncodingForRequest) {
        requestSerializer = AFJSONRequestSerializer.serializer;
    }else {
        requestSerializer = AFHTTPRequestSerializer.serializer;
    }
    
    requestSerializer.timeoutInterval = self.timeoutInterval;
    [requestSerializer setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    NSString *method;
    switch (self.httpMethodForRequest) {
        case RQHTTPMethodPOST:method = @"POST";break;
        case RQHTTPMethodGET:method = @"GET";break;
        default:method = @"POST";break;
    }
    
    NSError *error = nil;
    NSDictionary *parameters = [self yy_modelToJSONObject];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:self.urlForRequest relativeToURL:nil] absoluteString] parameters:parameters error:&error];
    if (error) {
        if (completion) {
            dispatch_async(session().completionQueue ?: dispatch_get_main_queue(), ^{
                Response *response = [[self.class.responseClass alloc] init];
                response.error = error;
                completion(response);
            });
        }
        return;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [session() dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        // TODO: 增加上行监控
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        // TODO: 增加下行监控
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [self logResponse:dataTask param:parameters object:responseObject error:error];
        
        if (completion) {
            Response *response = [[self.class.responseClass alloc] init];
            response.responseObject = responseObject;
            if (error) {
                response.error = error;
            } else if ([responseObject isKindOfClass:NSDictionary.class]) {
                [response yy_modelSetWithDictionary:responseObject];
            }
            completion(response);
        }
        
    }];
    
    [self logRequest:dataTask param:parameters];
    
    [dataTask resume];
    
}

- (NSString *)userAgent {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return _sfmt(@"iOS_%d_%ld_%f_%@",LESHUA_APP_TYPE,LESHUA_SOFTWARE_VERSION,[[[UIDevice currentDevice] systemVersion] floatValue],deviceString);
}

- (void)logRequest:(NSURLSessionDataTask *)task param:(NSDictionary *)params {
    #if DEBUG
        NSData *jsonData = params ? [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:NULL] : nil;
        NSString *jsonString = jsonData ? [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] : @"<null>";
        NSLog(@"\
              \n--------------------------------------------------------------------------------------\
              \n|                                       Request                                      |\
              \n--------------------------------------------------------------------------------------\
              \n%@\n\
              \n%@\n\
              \n%@\n\
              \n\
              \n--------------------------------------------------------------------------------------\
              \n|                                                                                    |\
              \n--------------------------------------------------------------------------------------",task,self.urlForRequest,jsonString);
    #endif
}

- (void)logResponse:(NSURLSessionDataTask *)task param:(NSDictionary *)params object:(id)response error:(NSError *)error {
    #if DEBUG
        NSData *reqData = params ? [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:NULL] : nil;
        NSString *reqJson = reqData ? [[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding] : @"<null>";
        NSString *respJson;
        if ([response isKindOfClass:NSDictionary.class]) {
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:NULL];
            respJson = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        }else {
            respJson = response ? [response description] : error.description;
        }
        NSLog(@"\
              \n--------------------------------------------------------------------------------------\
              \n|                                       Response                                     |\
              \n--------------------------------------------------------------------------------------\
              \n%@\n\
              \n%@\n\
              \n%@\n\
              \n%@\n\
              \n--------------------------------------------------------------------------------------\
              \n|                                                                                    |\
              \n--------------------------------------------------------------------------------------",task,self.urlForRequest,reqJson,respJson);
    #endif
}

@end

@implementation PureRequest

@end

@implementation Request
- (instancetype)init {
    if (self = [super init]) {
        // init your basic parameters
    }
    return self;
}
@end

@implementation RequestWithPage
- (instancetype)init {
    if (self = [super init]) {
        self.pgNo = 1;
        self.pgSz = 20;
    }
    return self;
}

@end

#pragma mark - Response

@implementation Responding

@end

@implementation Response

- (BOOL)hasErrorAndShowIt {
    if (self.error || !self.error_code || self.error_code.integerValue != 0) {
        // show error
        //[MBProgressHUD showInfoMessage:self.error.localizedDescription ?: self.error_msg ?: @"网络错误"];
        return YES;
    }
    return NO;
}

- (BOOL)hasError {
    if (self.error || !self.error_code || self.error_code.integerValue != 0) {
        return YES;
    }
    return NO;
}

@end

@implementation ResponseWithExtractData
- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
    NSDictionary *data = dic[@"data"];
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictM = [dic mutableCopy];
        [dictM addEntriesFromDictionary:data];
        return [dictM copy];
    }
    return dic;
}
@end







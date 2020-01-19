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

NS_ASSUME_NONNULL_BEGIN

@interface MsgStationMessage : NSObject
/**
 站内消息的id，相同 id 的站内消息会覆盖
 */
@property (nonatomic,copy,readonly) NSString *name;
/**
 所携带的自定义数据，可以为 nil
 */
@property (nonatomic,strong,readonly,nullable) id data;
/**
 站内消息可 check 次数，设置为 NSIntegerMax 可以让消息作为常驻消息永久驻留在消息站
 */
@property (nonatomic,assign,readonly) NSInteger checkableCount;
/**
 初始化
 */
- (instancetype)initWithName:(NSString *)name checkableCount:(NSInteger)count data:(nullable id)data;
@end

@interface MsgStation : NSObject

+ (instancetype)station;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 push 一个消息
 */
- (void)pushMessage:(MsgStationMessage *)message;
/**
 check 一个消息，每 check 一次，目标消息的 checkableCount 减少一次，少于 0 时会被移除
 */
- (MsgStationMessage *)checkMessageWithName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END

//  Copyright (c) 2019 HJ-Cai
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

#import <UIKit/UIKit.h>

#pragma mark - 按钮倒计时
@interface UIButton (CountDown)
@property (nonatomic,strong) NSTimer *countDown_timer;
/**
 开始倒计时
*/
- (BOOL)countDownFrom:(NSUInteger)integer;
/**
 是否正在倒计时
*/
- (BOOL)inCountDown;
@end


#pragma mark - 按钮可否点击监控
@interface ButtonObserverHandler : NSObject
@property (nonatomic,strong) id obj;
@property (nonatomic,strong) BOOL (^handler)(id obj,NSString *key);
+ (instancetype)handlerWithObj:(id)obj action:(BOOL (^)(id obj,NSString *key))action;
@end

@interface UIButton (Observer)
@property (nonatomic,strong) NSMutableDictionary<NSString *,NSMutableArray<ButtonObserverHandler *> *> *observerObject;
/**
 监控 obj 的 key 属性，action 中判断是否可以点击
*/
- (void)observerObject:(id)obj forKey:(NSString *)key jugdement:(BOOL(^)(id obj,NSString *key))action;
/**
 监控 obj 的 key 属性，采用是否为nil来判断是否可以点击
*/
- (void)observerObject:(id)obj forKey:(NSString *)key;
/**
 监控 obj 的一组 key 属性，采用是否为nil来判断是否可以点击
*/
- (void)observerObject:(id)obj forKeys:(NSArray<NSString *> *)keys;
/**
 监控 obj 的一组 key 属性，action 中判断是否可以点击
*/
- (void)observerObject:(id)obj forKeys:(NSArray<NSString *> *)keys jugdement:(BOOL(^)(id obj,NSString *key))action;
/**
 清除对一组 key 属性的监控
*/
- (void)deleteAllObserverObjectForKeys:(NSArray<NSString *> *)keys;
/**
 清除对 key 属性的监控
*/
- (void)deleteAllObserverObjectForKey:(NSString *)key;
/**
 清除对所有 key 属性的监控
*/
- (void)deleteAllObserverObject;
/**
 立即检查一遍
*/
- (void)checkedAllObserverObjectNow;
@end

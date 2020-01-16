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

#import "UIButton+Tools.h"

@implementation UIButton(CountDown)
- (void)setCountDown_timer:(NSTimer *)countDown_timer {
    objc_setAssociatedObject(self, @selector(countDown_timer), countDown_timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSTimer *)countDown_timer {
    return objc_getAssociatedObject(self, _cmd);
}
- (BOOL)countDownFrom:(NSUInteger)integer {
    if (integer <= 0) return NO;
    if (objc_getAssociatedObject(self, _cmd)) return NO;
    objc_setAssociatedObject(self, _cmd, @(integer - 1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, @selector(countDown_method), [self titleForState:UIControlStateNormal], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setTitle:[NSString stringWithFormat:@"%ld",integer] forState:UIControlStateNormal];
    self.countDown_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown_method) userInfo:nil repeats:YES];
    return YES;
}

- (void)countDown_method {
    NSInteger integer = ((NSNumber *)objc_getAssociatedObject(self, @selector(countDownFrom:))).integerValue;
    if (integer == 0) {
        objc_setAssociatedObject(self, @selector(countDownFrom:), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self setTitle:objc_getAssociatedObject(self, _cmd) forState:UIControlStateNormal];
        [self.countDown_timer invalidate];
        self.countDown_timer = nil;
        return;
    }
    [self setTitle:[NSString stringWithFormat:@"%ld",integer] forState:UIControlStateNormal];
    integer--;
    objc_setAssociatedObject(self, @selector(countDownFrom:), @(integer), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)inCountDown {
    return objc_getAssociatedObject(self, @selector(countDownFrom:)) ? YES : NO;
}

@end

@implementation ButtonObserverHandler
+ (instancetype)handlerWithObj:(id)obj action:(BOOL (^)(id obj,NSString *key))action {
    ButtonObserverHandler *handler = ButtonObserverHandler.new;
    handler.obj = obj;
    handler.handler = action;
    return handler;
}
@end

@implementation UIButton (Observer)
- (void)setObserverObject:(NSMutableDictionary<NSString *,NSMutableArray<ButtonObserverHandler *> *> *)observerObject {
    objc_setAssociatedObject(self, @selector(observerObject), observerObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary<NSString *,NSMutableArray<ButtonObserverHandler *> *> *)observerObject {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)observerObject:(id)obj forKey:(NSString *)key jugdement:(BOOL (^)(id, NSString *))action {
    if (!self.observerObject) self.observerObject = NSMutableDictionary.new;
    for (ButtonObserverHandler *handler in self.observerObject[key]) {
        if (handler.obj == obj) {
            handler.handler = action;
            return;
        }
    }
    if (!self.observerObject[key]) self.observerObject[key] = NSMutableArray.new;
    [obj addObserver:self forKeyPath:key options:0 context:nil];
    [self.observerObject[key] addObject:[ButtonObserverHandler handlerWithObj:obj action:action]];
}
- (void)observerObject:(id)obj forKeys:(NSArray<NSString *> *)keys jugdement:(BOOL (^)(id, NSString *))action {
    for (NSString *key in keys) {
        [self observerObject:obj forKey:key jugdement:action];
    }
}
- (void)observerObject:(id)obj forKey:(NSString *)key {
    [self observerObject:obj forKey:key jugdement:nil];
}

- (void)observerObject:(id)obj forKeys:(NSArray<NSString *> *)keys {
    for (NSString *key in keys) {
        [self observerObject:obj forKey:key];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    for (NSString *key in self.observerObject.allKeys) {
        NSMutableArray<ButtonObserverHandler *> *handlers = self.observerObject[key];
        for (ButtonObserverHandler *handler in handlers) {
            id value = [handler.obj valueForKey:key];
            if (handler.handler) {
                if (handler.handler([handler.obj valueForKey:key], key) == NO) {
                    self.enabled = NO;
                    return;
                }
            }else if ([value isKindOfClass:NSString.class]) {
                if (str == nil || [str length] < 1) {
                    self.enabled = NO;
                    return;
                }
            }else {
                if (value == nil) {
                    self.enabled = NO;
                    return;
                }
            }
        }
    }
    self.enabled = YES;
}

- (void)deleteAllObserverObjectForKeys:(NSArray<NSString *> *)keys {
    for (NSString *key in keys) {
        [self deleteAllObserverObjectForKey:key];
    }
}

- (void)deleteAllObserverObjectForKey:(NSString *)key {
    if ([self.observerObject.allKeys containsObject:key]) {
        for (ButtonObserverHandler *handler in self.observerObject[key]) {
            [handler.obj removeObserver:self forKeyPath:key];
            handler.handler = nil;
        }
        [self.observerObject removeObjectForKey:key];
    }
}

- (void)deleteAllObserverObject {
    [self deleteAllObserverObjectForKeys:self.observerObject.allKeys];
}

- (void)checkedAllObserverObjectNow {
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
}

@end

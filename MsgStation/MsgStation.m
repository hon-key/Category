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

#import "MsgStation.h"

static NSMutableDictionary<NSString *,MsgStationMessage *> *msg_pool() {
    static NSMutableDictionary *pool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [NSMutableDictionary new];
    });
    return pool;
}

static NSLock *msg_lock() {
    static NSLock *lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [[NSLock alloc] init];
    });
    return lock;
}

static void push_msg(MsgStationMessage *msg) {
    msg_pool()[msg.name] = msg;
}

static MsgStationMessage *get_msg(NSString *name) {
    MsgStationMessage *msg;
    msg = msg_pool()[name];
    return msg;
}

static void pop_msg(NSString *name) {
    msg_pool()[name] = nil;
}

@interface MsgStationMessage ()
- (void)setCount:(NSInteger)count;
@end

@implementation MsgStation
- (instancetype)initWithPrivate {
    if (self = [super init]) {

    }
    return self;
}

+ (instancetype)station {
    static MsgStation *station;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        station = [[MsgStation alloc] initWithPrivate];
    });
    return station;
}

- (void)pushMessage:(MsgStationMessage *)message {
    [msg_lock() lock];
    if (message.name && message.checkableCount > 0) {
        push_msg(message);
    }
    [msg_lock() unlock];
}
- (MsgStationMessage *)checkMessageWithName:(NSString *)name {
    MsgStationMessage *msg = nil;
    [msg_lock() lock];
    if (name) {
        MsgStationMessage *tmpMsg = msg_pool()[name];
        if (tmpMsg) {
            [tmpMsg setCount:tmpMsg.checkableCount - 1];
            if (tmpMsg.checkableCount <= 0) {
                pop_msg(tmpMsg.name);
            }
        }
        msg = tmpMsg;
    }
    [msg_lock() unlock];
    return msg;
}
@end

@implementation MsgStationMessage
- (instancetype)initWithName:(NSString *)name checkableCount:(NSInteger)count data:(id)data {
    if (self = [super init]) {
        _name = name;
        _data = data;
        _checkableCount = count;
    }
    return self;
}
- (void)setCount:(NSInteger)count {
    _checkableCount = count;
}
@end

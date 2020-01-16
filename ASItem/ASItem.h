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
@import Security;

NS_ASSUME_NONNULL_BEGIN

typedef NSString * ASItemNotificationUserInfoKey;
extern ASItemNotificationUserInfoKey ASItemNotificationUserInfoKeyErrorMsg;
extern ASItemNotificationUserInfoKey ASItemNotificationUserInfoKeyItemDict;

/// KeyChain 存储失败会发送该通知
extern NSString * const ASItemSaveErrorNotification;
/// KeyChain 读取失败会发送该通知
extern NSString * const ASItemMatchErrorNotification;
/// KeyChain 删除失败会发送该通知
extern NSString * const ASItemDeleteErrorNotification;

typedef NS_ENUM(NSInteger, ASItemChoice) {
    ASItemChoiceNO = 0, // equal to NO
    ASItemChoiceYES = 1, // eqaul to YES
    ASItemChoiceUndefined = 2,
};


@interface ASItem : NSObject

/**
 kSecAttrAccessibleWhenUnlocked : 解锁状态下可查询。转移设备会连带转移
 kSecAttrAccessibleAfterFirstUnlock : 首次解锁后可查询，直到下次重启之前，前后台都可以查询。转移设备会连带转移
 kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly : 只有设备存在密码锁状态下才可查询。移除密码锁会删除数据，转移设备也不会连带转移
 kSecAttrAccessibleWhenUnlockedThisDeviceOnly : 只有解锁状态下菜可查询。转移设备不会连带转移
 kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly : 首次解锁后可查询，直到下次重启之前，前后台都可以查询。转移设备不会连带转移
 默认为 kSecAttrAccessibleWhenUnlocked,如果是查询，则默认为空
 */
@property (nonatomic,assign,nullable) CFStringRef accessible;

/**
 是否需要设备访问控制，如果 YES，查询时需要面容识别或者指纹识别或者密码识别，否则不需要，默认为 NO
 要是用面容识别，必须要在 info.plist 内添加 Privacy - Face ID Usage Description 字符串
 */
@property (nonatomic,assign) BOOL accessControl;

/**
 设置查询的访问组
 如果是添加数据，该字符串为数据被添加到的访问组的名字。访问组的名字必须存在于：Keychain Access Groups Entitlement / App Groups Entitlement 中，也可以是 app id。可空，如果为空，默认添加到第一个访问组（如果有），或者 app id 中，否则会报错
 如果是查询、更新和删除数据，设置该字符串可以限定查询的访问组，查询的访问组必须在 Keychain Access Groups Entitlement / App Groups Entitlement 中，也可以是 app id。
 默认为空
 */
@property (nonatomic,copy,nullable) NSString *accessGroup;

/**
 设置是否可以同步到iCloud
 如果是添加数据，设置可以同步到iCloud将会随同 iCloud 移植到其他设备
 如果是查询数据，如果为 NO ,则默认不会查询可以同步到 iCloud 的数据，如果为 YES ,则会只会查询同步到 iCloud 的数据
 */
@property (nonatomic,assign) BOOL synchronizable;

/**
 需要存储的数据
 如果 valueString 不为 nil，取 valueString
 否则 取 valueData
 */
@property (nonatomic,copy,nullable) NSString *valueString;
@property (nonatomic,strong,nullable) NSData *valueData;

/**
 数据的创建日期
 */
@property (nonatomic,strong,readonly,nullable) NSDate *creationDate;

/**
 数据的最后一次修改日期
 */
@property (nonatomic,strong,readonly,nullable) NSDate *modificationDate;

/**
 设置数据的标签，默认为 nil
 */
@property (nonatomic,copy,nullable) NSString *label;

/**
 设置数据的描述，默认为 nil
 */
@property (nonatomic,strong,nullable) NSString *descriptionInfo;

/**
 设置数据的备注，默认为 nil
 */
@property (nonatomic,strong,nullable) NSString *comment;

/**
 设置数据的创建者，一个大于 0 的数，默认为 0
 */
@property (nonatomic,assign) NSUInteger creator;

/**
 设置数据的类型，一个大于 0 的数，默认为 0
 */
@property (nonatomic,assign) NSUInteger type;

/**
 是否是可见的(是否被展示)，默认为 NO
 */
@property (nonatomic,assign) ASItemChoice isInvisible;

/**
 是否数据不可用，默认为 NO
 */
@property (nonatomic,assign) ASItemChoice isNegative;

/**
 设置数据的账户名，可以用来区分不同账户的数据，默认为 "default-account",如果是查询，默认为 nil
 */
@property (nonatomic,copy,nullable) NSString *account;

/**
 设置数据的服务名，用来区分某个账户下的不同数据，默认为 "default-service"，如果是查询，默认为 nil
 */
@property (nonatomic,copy,nullable) NSString *service;

/**
 kSecAttrGeneric
 设置用户自定义数据，默认为 nil
 */
@property (nonatomic,strong,nullable) NSData *generic;

/**
 保存 ASItem 对象
 如果已经在对应的 account 和 service 组合之下保存过，再次保存会失败
 覆盖保存调用 -update
 */
- (BOOL)save;

/**
 覆盖保存 ASItem 对象
 */
- (BOOL)cover;

/*
 删除对应的 account 和 service 组合的 ASItem
 */
- (BOOL)remove;

@end

@interface ASItemQuery : ASItem

/**
 设置是否无视是否同步到iCloud
 如果为 YES 则不论是否可以同步到 iCloud 数据都会查询，如果为 NO,则使用 synchronizable 的策略
 */
@property (nonatomic,assign) BOOL synchronizableAny;

/**
 设置查询数据时的大小写敏感性。如果为 YES，忽略大小写，如果为 NO 不忽略。默认为 NO
 */
@property (nonatomic,assign) BOOL caseInsensitive;

/**
 设置返回最大结果数, 0 代表全部，默认全部
 */
@property (nonatomic,assign) NSUInteger limit;

/**
 设置是否返回使用了设备访问控制的数据，默认为 YES
 */
@property (nonatomic,assign) BOOL useAuthentication;

/**
 如果数据使用了设备访问控制，设置访问控制时的提示信息，默认为 nil
 */
@property (nonatomic,copy,nullable) NSString *authenticationPrompt;


- (nonnull NSArray<ASItem *> *)match;

@end

NS_ASSUME_NONNULL_END

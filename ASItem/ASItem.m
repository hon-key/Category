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

#import "ASItem.h"

ASItemNotificationUserInfoKey ASItemNotificationUserInfoKeyErrorMsg = @"com.AppSecurityStorage.notifiaction.key.error.msg";
ASItemNotificationUserInfoKey ASItemNotificationUserInfoKeyItemDict = @"com.AppSecurityStorage.notifiaction.key.item.dict";

NSString * const ASItemSaveErrorNotification = @"com.AppSecurityStorage.save.error";
NSString * const ASItemMatchErrorNotification = @"com.AppSecurityStorage.match.error";
NSString * const ASItemDeleteErrorNotification = @"com.AppSecurityStorage.delete.error";
#define AS_ID __bridge id

#define BoolTrans(value) ((AS_ID)(value ? kCFBooleanTrue : kCFBooleanFalse))

@interface ASItem ()
- (void)assignParamsWithItemDictionary:(NSDictionary *)itemDict;
@end

@implementation ASItem

- (instancetype)init {
    
    if (self = [super init]) {
        self.accessible = kSecAttrAccessibleWhenUnlocked;
        self.account = @"default-account";
        self.service = @"default-service";
    }
    return self;
    
}

- (BOOL)save {
    
    NSMutableDictionary *itemDict = [self createDictionaryForItem];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)itemDict, nil);
    if (status != errSecSuccess) {
        if (@available(iOS 11.3, *)) {
            NSString *errorMsg = (AS_ID)SecCopyErrorMessageString(status, NULL);
            NSLog(@"[AppSecurityStorage] - add item error - %@",errorMsg);
            [NSNotificationCenter.defaultCenter postNotificationName:ASItemSaveErrorNotification object:nil userInfo:@{
                ASItemNotificationUserInfoKeyErrorMsg:errorMsg,
                ASItemNotificationUserInfoKeyItemDict:itemDict,
            }];
        } else {
            NSLog(@"[AppSecurityStorage] - add item error - %d",(int)status);
            [NSNotificationCenter.defaultCenter postNotificationName:ASItemSaveErrorNotification object:nil userInfo:@{
                ASItemNotificationUserInfoKeyErrorMsg:[NSString stringWithFormat:@"errorStatus:%d",(int)status],
                ASItemNotificationUserInfoKeyItemDict:itemDict,
            }];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)remove {
    
    NSDictionary *query = @{
        (AS_ID)kSecClass : (AS_ID)kSecClassGenericPassword,
        (AS_ID)kSecAttrService : self.service,
        (AS_ID)kSecAttrAccount : self.account
    };
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status != errSecSuccess) {
        if (@available(iOS 11.3, *)) {
            NSString *errorMsg = (AS_ID)SecCopyErrorMessageString(status, NULL);
            NSLog(@"[AppSecurityStorage] - delete item error - %@",errorMsg);
            [NSNotificationCenter.defaultCenter postNotificationName:ASItemDeleteErrorNotification object:nil userInfo:@{
                ASItemNotificationUserInfoKeyErrorMsg:errorMsg,
                ASItemNotificationUserInfoKeyItemDict:query,
            }];
        } else {
            NSLog(@"[AppSecurityStorage] - delete item error - %d",(int)status);
            [NSNotificationCenter.defaultCenter postNotificationName:ASItemDeleteErrorNotification object:nil userInfo:@{
                ASItemNotificationUserInfoKeyErrorMsg:[NSString stringWithFormat:@"errorStatus:%d",(int)status],
                ASItemNotificationUserInfoKeyItemDict:query,
            }];
        }
        return NO;
    }
    
    return YES;
    
}

- (BOOL)cover {
    
    [self remove];
    return [self save];
    
}

- (NSMutableDictionary *)createDictionaryForItem {
    
    NSMutableDictionary *itemDict = [NSMutableDictionary new];
    itemDict[(AS_ID)kSecClass] = (AS_ID)kSecClassGenericPassword;
    
    if (self.accessControl) {
        CFErrorRef err = NULL;
        SecAccessControlRef ac = SecAccessControlCreateWithFlags(kCFAllocatorDefault, self.accessible ?: kSecAttrAccessibleWhenUnlocked, kSecAccessControlUserPresence, &err);
        if (err != NULL) {
            NSLog(@"[AppSecurityStorage] - AccessControlError - %@",(AS_ID)CFErrorCopyDescription(err));
        }else {
            itemDict[(AS_ID)kSecAttrAccessControl] = (AS_ID)ac;
        }
    }else {
        itemDict[(AS_ID)kSecAttrAccessible] = ((AS_ID)self.accessible) ?: ((AS_ID)kSecAttrAccessibleWhenUnlocked);
    }
    
    if (self.accessGroup) {
        itemDict[(AS_ID)kSecAttrAccessGroup] = self.accessGroup;
    }
    
    itemDict[(AS_ID)kSecAttrSynchronizable] = BoolTrans(self.synchronizable);
    
    if (self.valueString) {
        itemDict[(AS_ID)kSecValueData] = [self.valueString dataUsingEncoding:NSUTF8StringEncoding];
    }else {
        itemDict[(AS_ID)kSecValueData] = self.valueData;
    }
    
    if (self.label) {
        itemDict[(AS_ID)kSecAttrLabel] = self.label;
    }
    
    if (self.descriptionInfo) {
        itemDict[(AS_ID)kSecAttrDescription] = self.descriptionInfo;
    }
    
    if (self.comment) {
        itemDict[(AS_ID)kSecAttrComment] = self.comment;
    }
    
    if (self.creator > 0) {
        itemDict[(AS_ID)kSecAttrCreator] = @(self.creator);
    }
    
    if (self.type > 0) {
        itemDict[(AS_ID)kSecAttrType] = @(self.type);
    }
    
    itemDict[(AS_ID)kSecAttrIsInvisible] = BoolTrans(self.isInvisible);
    itemDict[(AS_ID)kSecAttrIsNegative] = BoolTrans(self.isNegative);
    
    itemDict[(AS_ID)kSecAttrAccount] = self.account;
    itemDict[(AS_ID)kSecAttrService] = self.service;
    if (self.generic) {
        itemDict[(AS_ID)kSecAttrGeneric] = self.generic;
    }
    
    return itemDict;
    
}

- (void)assignParamsWithItemDictionary:(NSDictionary *)itemDict {
    
    self.accessible = (__bridge CFStringRef)itemDict[(AS_ID)kSecAttrAccessible];
    
    id obj = itemDict[(AS_ID)kSecAttrAccessControl];
    if (![[obj description] isEqualToString:[NSString stringWithFormat:@"<SecAccessControlRef: %@>",(AS_ID)self.accessible]]) {
        self.accessControl = YES;
    }else {
        self.accessControl = NO;
    }
    
    self.accessGroup = itemDict[(AS_ID)kSecAttrAccessGroup];
    
    self.synchronizable = ((NSNumber *)itemDict[(AS_ID)kSecAttrSynchronizable]).boolValue;
    
    self.valueData = itemDict[(AS_ID)kSecValueData];
    self.valueString = [[NSString alloc] initWithData:self.valueData encoding:NSUTF8StringEncoding];
    
    _creationDate = itemDict[(AS_ID)kSecAttrCreationDate];
    _modificationDate = itemDict[(AS_ID)kSecAttrModificationDate];
    
    self.label = itemDict[(AS_ID)kSecAttrLabel];
    self.descriptionInfo = itemDict[(AS_ID)kSecAttrDescription];
    self.comment = itemDict[(AS_ID)kSecAttrComment];
    
    self.creator = ((NSNumber *)itemDict[(AS_ID)kSecAttrCreator]).unsignedIntegerValue;
    self.type = ((NSNumber *)itemDict[(AS_ID)kSecAttrType]).unsignedIntegerValue;
    
    self.isInvisible = ((NSNumber *)itemDict[(AS_ID)kSecAttrIsInvisible]).boolValue ? ASItemChoiceYES : ASItemChoiceNO;
    self.isNegative = ((NSNumber *)itemDict[(AS_ID)kSecAttrIsNegative]).boolValue ? ASItemChoiceYES : ASItemChoiceNO;
    
    self.account = itemDict[(AS_ID)kSecAttrAccount];
    self.service = itemDict[(AS_ID)kSecAttrService];
    
}

@end

@interface ASItemQuery ()

@end

@implementation ASItemQuery

- (instancetype)init {
    
    if (self = [super init]) {
        self.accessible = NULL;
        self.useAuthentication = YES;
        self.service = nil;
        self.account = nil;
        self.isNegative = ASItemChoiceUndefined;
        self.isInvisible = ASItemChoiceUndefined;
    }
    return self;
    
}

- (NSArray<ASItem *> *)match {
    
    NSMutableDictionary *itemDict = [self createDictionaryForItem];
    
    if (self.accessible == NULL) {
        [itemDict removeObjectForKey:(AS_ID)kSecAttrAccessible];
    }
    
    if (self.synchronizableAny) {
        itemDict[(AS_ID)kSecAttrSynchronizable] = (AS_ID)kSecAttrSynchronizableAny;
    }
    
    [itemDict removeObjectForKey:(AS_ID)kSecValueData];
    
    if (self.isNegative == ASItemChoiceUndefined) {
        [itemDict removeObjectForKey:(AS_ID)kSecAttrIsNegative];
    }
    
    if (self.isInvisible == ASItemChoiceUndefined) {
        [itemDict removeObjectForKey:(AS_ID)kSecAttrIsInvisible];
    }
    
    itemDict[(AS_ID)kSecMatchCaseInsensitive] = BoolTrans(self.caseInsensitive);
    
    if (self.limit == 0) {
        itemDict[(AS_ID)kSecMatchLimit] = (AS_ID)kSecMatchLimitAll;
    }else {
        itemDict[(AS_ID)kSecMatchLimit] = @(self.limit);
    }
    
    if (@available(iOS 9.0, *)) {
        if (self.useAuthentication) {
            itemDict[(AS_ID)kSecUseAuthenticationUI] = (AS_ID)kSecUseAuthenticationUIAllow;
        }else {
            itemDict[(AS_ID)kSecUseAuthenticationUI] = (AS_ID)kSecUseAuthenticationUISkip;
        }
    }else {
        itemDict[(AS_ID)kSecUseNoAuthenticationUI] = BoolTrans(!self.useAuthentication);
    }
    
    itemDict[(AS_ID)kSecUseOperationPrompt] = self.authenticationPrompt ?: @"未定义";
    
    itemDict[(AS_ID)kSecReturnData] = BoolTrans(YES);
    itemDict[(AS_ID)kSecReturnAttributes] = BoolTrans(YES);
    
    CFTypeRef resultRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)itemDict, &resultRef);
    if (status != errSecSuccess) {
        if (@available(iOS 11.3, *)) {
            NSString *errorMsg = (AS_ID)SecCopyErrorMessageString(status, NULL);
            NSLog(@"[AppSecurityStorage] - match item error - %@",errorMsg);
            [NSNotificationCenter.defaultCenter postNotificationName:ASItemMatchErrorNotification object:nil userInfo:@{
                ASItemNotificationUserInfoKeyErrorMsg:errorMsg,
                ASItemNotificationUserInfoKeyItemDict:itemDict,
            }];
        } else {
            NSLog(@"[AppSecurityStorage] - match item error - %d",(int)status);
            [NSNotificationCenter.defaultCenter postNotificationName:ASItemMatchErrorNotification object:nil userInfo:@{
                ASItemNotificationUserInfoKeyErrorMsg:[NSString stringWithFormat:@"errorStatus:%d",(int)status],
                ASItemNotificationUserInfoKeyItemDict:itemDict,
            }];
        }
    }
    
    NSArray *itemDicts = (__bridge NSArray *)resultRef;
    
    NSMutableArray *returnedArray = [NSMutableArray new];
    for (NSDictionary *itemDict in itemDicts) {
        
        ASItem *item = [ASItem new];
        
        [item assignParamsWithItemDictionary:itemDict];
        [returnedArray addObject:item];
        
    }
    
    return returnedArray;
    
}

@end

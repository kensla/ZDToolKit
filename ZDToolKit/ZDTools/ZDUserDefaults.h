//
//  ZDUserDefaults.h
//  Pods-ZDToolKitDemo
//
//  Created by 钟远科 on 2017/11/22.
//

#import <Foundation/Foundation.h>

@interface ZDUserDefaults : NSObject

#pragma mark - Helper

void UserDefaultSynchronize(void);

void UserDefaultRemoveKey(NSString *key);

void UserDefaultRegister(NSDictionary *defaultDictionary);

NSDictionary *UserDefaultAllValue(void);

void UserDefaultClearAllExcept(NSArray *keys);

void UserDefaultClearAll(void);


#pragma mark - Getter

id UserDefaultObject(NSString *key);

NSString *UserDefaultString(NSString *key);

NSArray *UserDefaultArray(NSString *key);

NSDictionary *UserDefaultDictionary(NSString *key);

NSData *UserDefaultData(NSString *key);

NSArray *UserDefaultStringArray(NSString *key);

NSInteger UserDefaultInteger(NSString *key);

float UserDefaultFloat(NSString *key);

double UserDefaultDouble(NSString *key);

BOOL UserDefaultBool(NSString *key);

NSURL *UserDefaultURL(NSString *key);


#pragma mark - Setter

void SetUserDefaultInteger(NSString *key, NSInteger value);

void SetUserDefaultFloat(NSString *key, float value);

void SetUserDefaultDouble(NSString *key, double value);

void SetUserDefaultBool(NSString *key, BOOL value);

void SetUserDefaultURL(NSString *key, NSURL *value);

void SetUserDefaultObject(NSString *key, id value);

@end

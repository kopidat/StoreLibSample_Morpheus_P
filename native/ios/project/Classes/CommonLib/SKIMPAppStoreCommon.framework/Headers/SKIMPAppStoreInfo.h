//
//  SKIMPAppStoreInfo.h
//  SKIMPAppStoreCommon
//
//  Created by Sungoh Kang on 2021/06/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^SKIMPFrameworkAPISuccess)(NSString *successMessage, NSInteger successCode);
typedef void (^SKIMPFrameworkAPIFailure)(NSString *failureMassage, NSInteger errorCode);

@interface SKIMPAppStoreInfo : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (SKIMPAppStoreInfo *)sharedInstance;

- (void)SKIMemberStoreLogin:(NSString *)appName;
- (void)SKIPartnerStoreLogin:(NSString *)appName;
- (void)SKIMemberStoreUpdate:(NSString *)appName;
- (void)SKIPartnerStoreUpdate:(NSString *)appName;

- (void)SKIMemberStoreInstall;
- (void)SKIPartnerStoreInstall;

- (NSString *)getAES256Encrypt:(NSString *)plainText;
- (NSString *)getAES256Decrypt:(NSString *)encText;

- (NSDictionary *)getMemberStoreUserInfo;
- (NSDictionary *)getPartnerStoreUserInfo;

- (void)SKIMemberStoreAuthCheck:(SKIMPFrameworkAPISuccess)success failure:(SKIMPFrameworkAPIFailure)failure;
- (void)SKIPartnerStoreAuthCheck:(SKIMPFrameworkAPISuccess)success failure:(SKIMPFrameworkAPIFailure)failure;

@end

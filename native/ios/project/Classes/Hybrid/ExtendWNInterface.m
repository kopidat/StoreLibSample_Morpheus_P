//
//  ExtendWNInterface.m
//

#import "ExtendWNInterface.h"

@interface ExtendWNInterface ()

@property (nonatomic, assign) PPWebViewController *viewctrl;

@end

@implementation ExtendWNInterface

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)checkValidParameters:(NSDictionary *)parameters fromValidClasses:(NSDictionary *)validClasses errorMessage:(NSString **)errorMessage {
    
    for ( NSString *key in validClasses ) {
        Class validClass = [validClasses objectForKey:key];
        id parameter = [parameters objectForKey:key];
        
        if ( parameter == nil ) {
            *errorMessage = [NSString stringWithFormat:@"key(%@) is null", key];
            return NO;
        }
        
        if ( ![parameter isKindOfClass:validClass] ) {
            *errorMessage = [NSString stringWithFormat:@"key(%@) is invalid type", key];
            return NO;
        }
        
        if ( [validClass isEqual:[NSString class]] && [[parameter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            *errorMessage = [NSString stringWithFormat:@"key(%@) is invalid", key];
            return NO;
        }
        else if ( [validClass isEqual:[NSDictionary class]] ) {
            *errorMessage = [NSString stringWithFormat:@"key(%@) is invalid", key];
            return NO;
        }
        else if ( [validClass isKindOfClass:[NSArray class]] ) {
            *errorMessage = [NSString stringWithFormat:@"key(%@) is invalid", key];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)isAlive {
    if (![[PPNavigationController ppNavigationController] existViewController:_viewController]) {
        PPDebug(@"Already released view controller!!");
        return NO;
    }
    
    return YES;
}

// Callback 구조를 설명하기 위한 Sample Interface
- (NSString *)wnSampleCallback:(NSString *)jsonString {
    NSDictionary *options = [jsonString objectFromJsonString];
    
    if (!options) {
        return [@{@"status":@"FAIL", @"error":@"invalid params"} jsonString];
    }

    NSString *invalidMessage = nil;
    NSDictionary *validClasses = @{
        @"callback": [NSString class]
    };
    
    if ( ! [self checkValidParameters:options fromValidClasses:validClasses errorMessage:&invalidMessage] ) {
        return [@{@"status":@"FAIL", @"error":invalidMessage} jsonString];
    }
    
    NSString *callback = [options objectForKey:@"callback"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSDictionary *resultInfo = @{
            @"status": @"SUCCESS"
        };
        
        [self.viewController callCbfunction:callback withObjects:resultInfo, nil];
    });
    
    return [@{ @"status": @"PROCESSING" } jsonString];
}

- (void)exWNAES256Encrypt:(NSString *)plainText {
    NSLog(@"plainText : %@", plainText);
    NSString *encStr = [[SKIMPAppStoreInfo sharedInstance] getAES256Encrypt:plainText];
    NSLog(@"encStr : %@", encStr);
}

- (void)exWNAES256Decrypt:(NSString *)encText {
    NSLog(@"encText : %@", encText);
    NSString *decStr = [[SKIMPAppStoreInfo sharedInstance] getAES256Decrypt:encText];
    NSLog(@"decStr : %@", decStr);
}

// Store 인증
// memberYN : Y - 멤버스토어 인증
// memberYN : N - 파트너스토어 인증
- (void)exWNStoreLib_auth:(NSString *)memberYN :(NSString *)callbackNm {
    NSMutableDictionary __block *resultDic = [[NSMutableDictionary alloc] init];
    if ([memberYN isEqualToString:@"Y"]) {
        [[SKIMPAppStoreInfo sharedInstance] SKIMemberStoreAuthCheck:^(NSString *successMessage, NSInteger successCode) {
            NSLog(@"successMessage : %@", successMessage);
            NSLog(@"successCode : %ld", successCode);
            [resultDic setObject:[NSString stringWithFormat:@"%ld", successCode] forKey:@"code"];
            [resultDic setObject:successMessage forKey:@"msg"];
            [self.viewctrl callCbfunction:callbackNm withObjects:resultDic, nil];
        } failure:^(NSString *failureMassage, NSInteger errorCode) {
            NSLog(@"failureMessage : %@", failureMassage);
            NSLog(@"errorCode : %ld", errorCode);
            [resultDic setObject:[NSString stringWithFormat:@"%ld", errorCode] forKey:@"code"];
            [resultDic setObject:failureMassage forKey:@"msg"];
            [self.viewctrl callCbfunction:callbackNm withObjects:resultDic, nil];
        }];
    } else {
        [[SKIMPAppStoreInfo sharedInstance] SKIPartnerStoreAuthCheck:^(NSString *successMessage, NSInteger successCode) {
            NSLog(@"successMessage : %@", successMessage);
            NSLog(@"successCode : %ld", successCode);
            [resultDic setObject:[NSString stringWithFormat:@"%ld", successCode] forKey:@"code"];
            [resultDic setObject:successMessage forKey:@"msg"];
            [self.viewctrl callCbfunction:callbackNm withObjects:resultDic, nil];
        } failure:^(NSString *failureMassage, NSInteger errorCode) {
            NSLog(@"failureMessage : %@", failureMassage);
            NSLog(@"errorCode : %ld", errorCode);
            [resultDic setObject:[NSString stringWithFormat:@"%ld", errorCode] forKey:@"code"];
            [resultDic setObject:failureMassage forKey:@"msg"];
            [self.viewctrl callCbfunction:callbackNm withObjects:resultDic, nil];
        }];
    }
}

// 로그인일 위한 스토어 호출
// memberYN : Y - 멤버스토어 호출
// memberYN : N - 파트너스토어 호출
- (void)exWNStoreLib_login:(NSString *)memberYN :(NSString *)appName {
    if ([memberYN isEqualToString:@"Y"]) {
        [[SKIMPAppStoreInfo sharedInstance] SKIMemberStoreLogin:appName];
    } else {
        [[SKIMPAppStoreInfo sharedInstance] SKIPartnerStoreLogin:appName];
    }
}

// 업데이트를 위한 스토어 호출
// memberYN : Y - 멤버스토어 호출
// memberYN : N - 파트너스토어 호출
- (void)exWNStoreLib_update:(NSString *)memberYN :(NSString *)appName {
    if ([memberYN isEqualToString:@"Y"]) {
        [[SKIMPAppStoreInfo sharedInstance] SKIMemberStoreUpdate:appName];
    } else {
        [[SKIMPAppStoreInfo sharedInstance] SKIPartnerStoreUpdate:appName];
    }
}

// 스토어 설치 페이지 이동
// memberYN : Y - 멤버스토어 설치페이지 이동
// memberYN : N - 파트너스토어 설치페이지 이동
- (void)exWNStoreLib_goAppStoreInstallPage:(NSString *)memberYN {
    if ([memberYN isEqualToString:@"Y"]) {
        [[SKIMPAppStoreInfo sharedInstance] SKIMemberStoreInstall];
    } else {
        [[SKIMPAppStoreInfo sharedInstance] SKIPartnerStoreInstall];
    }
}

// 로그인 사용자 정보
// memberYN : Y - 멤버스토어 로그인 사용자 정보
// memberYN : N - 파트너스토어 로그인 사용자 정보
- (void)exWNStoreLib_getUserInfo:(NSString *)memberYN :(NSString *)callbackNm {
    NSDictionary *loginInfoDic = [[NSDictionary alloc] init];
    if ([memberYN isEqualToString:@"Y"]) {
        loginInfoDic = [[SKIMPAppStoreInfo sharedInstance] getMemberStoreUserInfo];
    } else {
        loginInfoDic = [[SKIMPAppStoreInfo sharedInstance] getPartnerStoreUserInfo];
    }
    [self.viewctrl callCbfunction:callbackNm withObjects:loginInfoDic, nil];
}

@end

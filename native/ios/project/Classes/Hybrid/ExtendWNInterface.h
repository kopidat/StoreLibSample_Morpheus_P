//
//  ExtendWNInterface.h
//

#import <UIKit/UIKit.h>
#import <SKIMPAppStoreCommon/SKIMPAppStoreInfo.h>

@interface ExtendWNInterface : NSObject<WNInterface>

@property (nonatomic, readonly) PPWebViewController *viewController;

@end

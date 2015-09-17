//
//  InAppPurchaseHelper.h
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#define PRODUCTID @""
UIKIT_EXTERN NSString *const InAppPurchaseHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface InAppPurchaseHelper : NSObject

+ (InAppPurchaseHelper *)sharedInstance;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
//
//  InAppPurchaseManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 1/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMStore.h"
#import <RMStore/RMStoreKeychainPersistence.h>
#import "Utilities.h"
#import "ReceiptVerifier.h"
#import "SKProduct+LocalizedPrice.h"
#import "VTDCrypto.h"
#import "VIPUtilities.h"
#import "IAPHelper.h"
#import "IAPShare.h"

@protocol IAPManagerDelegate <NSObject>
@required

- (void)PurchaseCompleted:(BOOL)Success
         withErrorMessage:(NSString *)Error
                 withType:(NSString *)type
                 withName:(NSString *)name
                  withSKU:(NSString *)SKU
                withPrice:(NSString *)price;

- (void)ProductsLoaded:(BOOL)Success;

@end

@protocol IAPRestoreDelegate <NSObject>
@required

- (void)RestoreCompleted:(BOOL)Success withErrorMessage:(NSString *)Error withType:(NSString *)type;

@end

@protocol IAPManagerDatasource <NSObject>
@required

- (NSString *)GetKeychainKey;
- (NSString *)GetAppID;

@end

@interface InAppPurchaseManager : NSObject <RMStoreReceiptVerificator>
{
    RMStoreKeychainPersistence *_RMStoreKeychain;
    RMStore *_RMStore;
    NSArray *_Products;
    NSMutableArray *_PIDs;
    bool _ProductsLoaded;
    ReceiptVerifier *_ReceiptVerifier;
    NSMutableDictionary *_IAP;
    NSMutableDictionary *_ProductPricing;
    NSMutableDictionary *_ProductInfo;
    VTDCrypto *_VTDCrypto;
}

@property (weak) id <IAPManagerDelegate> delegate;
@property (weak) id <IAPRestoreDelegate> restoreDelegate;
@property (weak) id <IAPManagerDatasource> datasource;

- (id)initWithDatasource:(id<IAPManagerDatasource>)adatasource;

- (bool)AreProductsLoaded;
- (void)LoadProducts;

- (void)PurchaseProduct:(NSString *)PID;
- (NSDictionary *)GetProductPricing;

- (bool)UseForm;

- (int)GetNumberOfForms;
- (bool)HasFreeForms;
- (bool)HasSubscription;
- (bool)HasExportSubscription;

- (void)VerifySubscriptions;

- (void)RemoveSubscription:(NSString *)type;

- (void)RestoreSubscriptions;

- (void)IncForms:(int)NumForms;

//Note: For testing
- (void)ClearAllForms;
//Note: For testing
- (void)LoadForms;

//Used for the transfer of forms from MRF to CRF
- (void)TransferIAPIntoShared;
- (void)TransferSharedIntoIAP;

@end

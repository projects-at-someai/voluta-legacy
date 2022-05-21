//
//  InAppPurchaseManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 1/2/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "InAppPurchaseManager.h"

@implementation InAppPurchaseManager

@synthesize delegate;
@synthesize restoreDelegate;
@synthesize datasource;

- (id)initWithDatasource:(id<IAPManagerDatasource>)adatasource {
    
    self = [super init];
    
    if (self) {

        datasource = adatasource;

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *pListPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, IAP_PLIST_NAME];

        _Products = [[NSArray alloc] initWithContentsOfFile:pListPath];

        _PIDs = [[NSMutableArray alloc] init];

        for (int i = 0; i < [_Products count]; i++) {

            NSDictionary *product = [_Products objectAtIndex:i];
            [_PIDs addObject:[product objectForKey:@"Product ID"]];
        }

        _ReceiptVerifier = [ReceiptVerifier sharedInstance];

        _RMStore = [RMStore defaultStore];
        _RMStore.receiptVerificator = self;
        
        _ProductsLoaded = NO;
        
        if ([Utilities HasNetworkConnectivity]) {
            
            [self LoadProducts];
        }
        
        _VTDCrypto = [[VTDCrypto alloc] init];
        
        NSData *IAPData =  [KeychainWrapper searchKeychainCopyMatchingIdentifier:[datasource GetKeychainKey]];

        if (IAPData == nil) {
            
            //check for legacy forms from previous versions
            int numlegacy = [self GetLegacyFormCount];
            
            _IAP = [[NSMutableDictionary alloc] init];
            
            [_IAP setObject:@"No" forKey:IAP_SUBSCRIPTION];
            [_IAP setObject:@"No" forKey:IAP_EXPORT_SUBSCRIPTION];
            
            if (numlegacy > 0) {
                
                [_IAP setObject:[NSNumber numberWithInt:numlegacy] forKey:IAP_NUMFORMS];
                [self ClearLegacyForms];
            }
            else {
                
                [_IAP setObject:[NSNumber numberWithInt:INITIAL_NUM_FREE_FORMS] forKey:IAP_NUMFORMS];
            }
            
            [_IAP setObject:[NSNumber numberWithInt:INITIAL_NUM_FREE_FORMS] forKey:IAP_NUMFREEFORMS];
            
            IAPData = [NSKeyedArchiver archivedDataWithRootObject:_IAP];
            
            //Encrypt IAPData
            NSData *encIAPData = [_VTDCrypto Encrypt:IAPData withPassword:@"0!5~0$8;8*1$0*2^1$2#1!3"];
            
            [KeychainWrapper createKeychainValueFromData:encIAPData
                                           forIdentifier:[datasource GetKeychainKey]];
            
        }
        else {
            
            [self LoadIAP:IAPData];
            
        }
    }
    
    return self;
}

- (int)GetLegacyFormCount {
    
    int numlegacyforms = 0;
    
    NSData *numFormsData = [KeychainWrapper searchKeychainCopyMatchingIdentifier:@"NTFS"];
    
    if (numFormsData != nil) {
        
        NSString *numForms = [[NSString alloc] initWithData:numFormsData
                                                   encoding:NSUTF8StringEncoding];
        numlegacyforms += [numForms intValue];
    }
    
    numFormsData = [KeychainWrapper searchKeychainCopyMatchingIdentifier:@"NTFS-UK"];
    
    if (numFormsData != nil) {
        
        NSString *numForms = [[NSString alloc] initWithData:numFormsData
                                                   encoding:NSUTF8StringEncoding];
        numlegacyforms += [numForms intValue];
    }
    
    numFormsData = [KeychainWrapper searchKeychainCopyMatchingIdentifier:@"NTFS-AUS"];
    
    if (numFormsData != nil) {
        
        NSString *numForms = [[NSString alloc] initWithData:numFormsData
                                                   encoding:NSUTF8StringEncoding];
        numlegacyforms += [numForms intValue];
    }
    
    return numlegacyforms;
}

- (void)ClearLegacyForms {
    
    NSData *numFormsData = [KeychainWrapper searchKeychainCopyMatchingIdentifier:@"NTFS"];
    
    if (numFormsData != nil) {
        
        [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"NTFS"];
    }
    
    numFormsData = [KeychainWrapper searchKeychainCopyMatchingIdentifier:@"NTFS-UK"];
    
    if (numFormsData != nil) {
        
        [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"NTFS-UK"];
    }
    
    numFormsData = [KeychainWrapper searchKeychainCopyMatchingIdentifier:@"NTFS-AUS"];
    
    if (numFormsData != nil) {
        
        [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"NTFS-AUS"];
    }
}

- (void)LoadProducts {

    [_RMStore requestProducts:[NSSet setWithArray:_PIDs] success:^(NSArray *products, NSArray *invalidProductIdentifiers)
    {
        
        if (!_ProductPricing) {
            
            _ProductPricing = [[NSMutableDictionary alloc] init];
        }
        
        [_ProductPricing removeAllObjects];

        if (!_ProductInfo) {

            _ProductInfo = [[NSMutableDictionary alloc] init];
        }

        [_ProductInfo removeAllObjects];

        for (SKProduct *product in products)
        {
            //NSLog(@"test: %@", product.localizedPrice);

            [_ProductPricing setObject:product.localizedPrice forKey:product.productIdentifier];

            [_ProductInfo setObject:product forKey:product.productIdentifier];
        }
        
        _ProductsLoaded = YES;
        
        if (delegate) {
            [delegate ProductsLoaded:YES];
        }
        
        
    }
                      failure:^(NSError *error)
    {
    
        _ProductsLoaded = NO;
        
        if (delegate) {
            [delegate ProductsLoaded:NO];
        }
    }];

}

- (bool)AreProductsLoaded {
    
    return _ProductsLoaded;
}

- (bool)HasSubscription {
    
#ifdef IS_UNLIMITED
    
    return YES;
    
#else
    
    bool hasvip = [VIPUtilities IsValid];
    
    NSString *sub = [_IAP objectForKey:IAP_SUBSCRIPTION];
    
    return ((sub != nil && [sub isEqualToString:@"Yes"]) || hasvip);
    
#endif
    
}

- (bool)HasExportSubscription {
    
#ifdef IS_UNLIMITED

    return YES;
    
#else
    
    bool hasvip = [VIPUtilities IsValid];
    
    NSString *sub = [_IAP objectForKey:IAP_EXPORT_SUBSCRIPTION];
    
    return ((sub != nil && [sub isEqualToString:@"Yes"]) || hasvip);
    
#endif
    
    
}

- (bool)HasFreeForms {
    
    NSNumber *FreeForms = [_IAP objectForKey:IAP_NUMFREEFORMS];
    
    return ([FreeForms intValue] > 0);
}

- (int)GetNumberOfForms {
    
    NSNumber *NumForms = [_IAP objectForKey:IAP_NUMFORMS];
    
    return [NumForms intValue];
}

- (bool)UseForm {
    
#ifdef IS_UNLIMITED
    
    return YES;
    
#else
    
    bool hasvip = [VIPUtilities IsValid];
    
    NSNumber *NumForms = [_IAP objectForKey:IAP_NUMFORMS];
    NSNumber *FreeForms = [_IAP objectForKey:IAP_NUMFREEFORMS];
    
    int numforms = [NumForms intValue];
    int freeforms = [FreeForms intValue];
    
    if ([self HasSubscription] || hasvip) {
        
        return YES;
    }
    
    if (numforms > 0) {
        
        numforms--;
        [_IAP setObject:[NSNumber numberWithInt:numforms] forKey:IAP_NUMFORMS];
        
        if (freeforms > 0) {
            freeforms--;
            [_IAP setObject:[NSNumber numberWithInt:freeforms] forKey:IAP_NUMFREEFORMS];
        }
        
        [self SaveIAP];
        
        return YES;
    }
    else {
        
        return NO;
    }
    
#endif
    
}

- (void)IncForms:(int)NumForms {
    
    NSNumber *NFs = [_IAP objectForKey:IAP_NUMFORMS];
    int numforms = [NFs intValue];
    
    numforms += NumForms;
    
    [_IAP setObject:[NSNumber numberWithInt:numforms] forKey:IAP_NUMFORMS];
    
    [self SaveIAP];
}

//Note: For Testing
- (void)ClearAllForms {
    
    [_IAP setObject:[NSNumber numberWithInt:0] forKey:IAP_NUMFORMS];
    
    [self SaveIAP];
}


//Note: For Testing
- (void)LoadForms {
    
    [_IAP setObject:[NSNumber numberWithInt:100] forKey:IAP_NUMFORMS];
    
    [self SaveIAP];
}

- (void)VerifySubscriptions {
    
#ifdef IS_UNLIMITED
    
    return;
    
#else

    if ([Utilities HasNetworkConnectivity]) {

        bool hasvip = [VIPUtilities IsValid];

        if (hasvip) {

            bool isexpired = [VIPUtilities IsExpired];

            if (isexpired) {

                NSLog(@"VIP expired, checking black list");

                bool validated = [VIPUtilities CheckBlackList];

                if (!validated) {

                    NSLog(@"User is black listed");
                    [VIPUtilities DisableVIP];
                }
                else {

                    NSLog(@"User is not black listed, update expiration");
                    [VIPUtilities UpdateExpiration];
                    return;
                }
            }
            else {

                NSLog(@"VIP still active");
                return;
            }

        }
        else {

            NSLog(@"Not a VIP");
        }


    }
    else {

        NSLog(@"No netwrok connectivity, checking VIP black list tomorrow")
        [VIPUtilities UpdateExpirationSingleDay];
        return;

    }
    

    //Only verify every 24 hours
    NSData *checkDate = [KeychainWrapper getKeychainData:SUB_CHECK_DATE];
    
    NSInteger hoursBetweenDates = 0;
    NSDate *currentDate = [NSDate date];
    
    if (checkDate != nil) {
        
        NSDate *lastCheckedDate = [NSKeyedUnarchiver unarchiveObjectWithData:checkDate];
        
        NSTimeInterval distanceBetweenDates = [currentDate timeIntervalSinceDate:lastCheckedDate];
        double secondsInAnHour = 3600;
        hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    }
    
    //note: for testing
    //hoursBetweenDates = 25;
    
    if ((hoursBetweenDates >= 24 || checkDate == nil)) {
        
        checkDate = [NSKeyedArchiver archivedDataWithRootObject:currentDate];
        [KeychainWrapper updateKeychainValueFromData:checkDate forIdentifier:SUB_CHECK_DATE];
        
        [self CheckUnlimitedSubscription];
        [self CheckExportSubscription];
    }
    
#endif
    
}

- (void)CheckUnlimitedSubscription {
    
#ifdef IS_UNLIMITED
    
    return;
    
#else
    
    bool hasvip = [VIPUtilities IsValid];
    
    if (hasvip) {
        return;
    }
    
    NSString *subscription = [_IAP objectForKey:IAP_SUBSCRIPTION];
    
    if ([subscription isEqualToString:@"Yes"]) {
        
        NSLog(@"Checking subscription");
        
        NSString *expirationString = [_IAP objectForKey:IAP_SUBSCRIPTION_EXPIRATION];
        
        if (expirationString == nil) {
            
            expirationString = @"0";
            [_IAP setObject:expirationString forKey:IAP_SUBSCRIPTION_EXPIRATION];
            [self SaveIAP];
        }
        
        NSTimeInterval expire = [expirationString doubleValue];
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        bool isExpired = expire < currentTime;
        
        if (isExpired) {
            
            NSLog(@"Subscription expired");

            if ([Utilities HasNetworkConnectivity]) {

                NSLog(@"Have network connectivity, validating receipt")

                NSData *receipt = [_IAP objectForKey:IAP_SUBSCRIPTION_RECEIPT];

                if (receipt != nil) {

                    [_ReceiptVerifier verifyReceipt:receipt
                                  completionHandler:^(NSDictionary *result)
                     {

                         NSString *status = [result objectForKey:@"status"];
                         BOOL success = [status isEqualToString:@"Valid"];

                         if (success) {

                             NSLog(@"Subscription has been renewed");
                             [self UpdateKeychain:result];

                         }
                         else {

                             //Signal purchase couldnt be completed

                             NSString *msg = [result objectForKey:@"message"];

                             if ([msg isEqualToString:@"Expired subscription"]) {

                                 NSLog(@"Subscription could not be renewed");
                                 [self RemoveSubscription:[result objectForKey:@"type"]];
                             }

                         }

                     }];
                }
                else {

                    NSLog(@"Subscription could not be renewed");
                    [self RemoveSubscription:@"Unlimited"];

                }
            }
            else {

                NSLog(@"Subscription expired, but no network connectivity, checking later");

            }

            
        }
    }
    
#endif

}

- (void)CheckExportSubscription {
    
#ifdef IS_UNLIMITED
    
    return;
    
#else
    
    bool hasvip = [VIPUtilities IsValid];
    
    if (hasvip) {
        return;
    }
    
    NSString *export_subscription = [_IAP objectForKey:IAP_EXPORT_SUBSCRIPTION];
    
    if ([export_subscription isEqualToString:@"Yes"]) {
        
        NSString *expirationString = [_IAP objectForKey:IAP_EXPORT_SUBSCRIPTION_EXPIRATION];
        
        if (expirationString == nil) {
            
            expirationString = @"0";
            [_IAP setObject:expirationString forKey:IAP_EXPORT_SUBSCRIPTION_EXPIRATION];
            [self SaveIAP];
        }
        
        NSTimeInterval expire = [expirationString doubleValue];
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        bool isExpired = expire < currentTime;
        
        if (isExpired) {

            NSLog(@"Export subscription expired");

            if ([Utilities HasNetworkConnectivity]) {

                NSData *receipt = [_IAP objectForKey:IAP_EXPORT_SUBSCRIPTION_RECEIPT];

                if (receipt != nil) {

                    [_ReceiptVerifier verifyReceipt:[_IAP objectForKey:IAP_EXPORT_SUBSCRIPTION_RECEIPT]
                                  completionHandler:^(NSDictionary *result)
                     {

                         NSString *status = [result objectForKey:@"status"];
                         BOOL success = [status isEqualToString:@"Valid"];

                         if (success) {

                             [self UpdateKeychain:result];

                         }
                         else {

                             //Signal purchase couldnt be completed

                             NSString *msg = [result objectForKey:@"message"];

                             if ([msg isEqualToString:@"Expired subscription"]) {

                                 [self RemoveSubscription:[result objectForKey:@"type"]];
                             }

                         }

                     }];
                }
                else {

                    NSLog(@"Subscription could not be renewed");
                    [self RemoveSubscription:@"Unlimited"];

                }
            }
            else {

                NSLog(@"No network connectivity, checking subscription again later");
            }

        }
    }
    
#endif
    
}

- (void)PurchaseProduct:(NSString *)PID {
    
    __weak InAppPurchaseManager *weakSelf = self;
    __weak SKProduct *product = [_ProductInfo objectForKey:PID];


    /*
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {

                                                      NSLog(@"Purchased/Subscribed to product with id: %@", [note object]);

                                                      if (weakSelf.delegate) {

                                                          [weakSelf.delegate PurchaseCompleted:YES
                                                                              withErrorMessage:nil
                                                                                      withType:PID
                                                                                      withName:product.localizedTitle
                                                                                       withSKU:product.productIdentifier
                                                                                     withPrice:[product.price stringValue]];
                                                      }
                                                  }];

    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:PID];
     */


    /*
    [[IAPShare sharedHelper].iap buyProduct:product
                               onCompletion:^(SKPaymentTransaction* transaction){
                                   
                                   if (weakSelf.delegate) {

                                       [weakSelf.delegate PurchaseCompleted:YES
                                                           withErrorMessage:nil
                                                                   withType:PID
                                                                   withName:product.localizedTitle
                                                                    withSKU:product.productIdentifier
                                                                  withPrice:[product.price stringValue]];
                                   }


                               }];

    */

    [_RMStore addPayment:PID success:^(SKPaymentTransaction *transaction) {
        
        NSLog(@"Add payment successful: %@\n", transaction.transactionIdentifier);
        
        if (weakSelf.delegate) {

            [weakSelf.delegate PurchaseCompleted:YES
                                withErrorMessage:nil
                                        withType:PID
                                        withName:product.localizedTitle
                                         withSKU:product.productIdentifier
                                       withPrice:[product.price stringValue]];
        }
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        
        NSLog(@"Add payment failed: %@", error);
        
        if (weakSelf.delegate) {

            [weakSelf.delegate PurchaseCompleted:NO
                                withErrorMessage:[NSString stringWithFormat:@"Payment failed: %@", error]
                                        withType:PID
                                        withName:product.localizedTitle
                                         withSKU:product.productIdentifier
                                       withPrice:[product.price stringValue]];

        }

    }];
}

- (NSDictionary *)GetProductPricing {
    
    return [_ProductPricing copy];
}

#pragma mark - RMStoreReceiptVerificator
- (void)verifyTransaction:(SKPaymentTransaction*)transaction
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *error))failureBlock {
    
    [_ReceiptVerifier verifyPurchase:transaction completionHandler:^(NSDictionary *result){

        NSString *status = [result objectForKey:@"status"];
        BOOL success = [status isEqualToString:@"Valid"];
        
        if (success) {
            
            [self UpdateKeychain:result];

            successBlock();

        }
        else {
            

            //Signal purchase couldnt be completed
            
            NSString *msg = [result objectForKey:@"message"];
            
            if ([msg isEqualToString:@"Expired subscription"]) {
                
                [self RemoveSubscription:[result objectForKey:@"type"]];
                successBlock();
            }
            else {
                
                NSError *CustomError = nil;
                
                failureBlock(CustomError);
            }


            
        }
        
    }];

}

- (void)UpdateKeychain:(NSDictionary *)PurchaseResult {
    
    NSString *type = [PurchaseResult objectForKey:@"type"];
    
    if ([type isEqualToString:@"Unlimited"]) {
        
        //Update subscription keychain
        [_IAP setObject:@"Yes" forKey:IAP_SUBSCRIPTION];
        
        //Update subscription expiration date
        NSString *expirationString = [PurchaseResult objectForKey:@"Expiration Date"];
        double expire = [expirationString doubleValue] /1000.0f;
        
        if (expirationString != nil) {
            
            [_IAP setObject:[NSString stringWithFormat:@"%f",expire] forKey:IAP_SUBSCRIPTION_EXPIRATION];
        }
        
        //Update subscription receipt
        [_IAP setObject:[PurchaseResult objectForKey:@"Receipt"] forKey:IAP_SUBSCRIPTION_RECEIPT];
        
    }
    else if ([type isEqualToString:@"DatabaseExport"]) {
        
        //Update subscription keychain
        [_IAP setObject:@"Yes" forKey:IAP_EXPORT_SUBSCRIPTION];
        
        //Update subscription expiration date
        NSString *expirationString = [PurchaseResult objectForKey:@"Expiration Date"];
        double expire = [expirationString doubleValue] /1000.0f;
        
        if (expirationString != nil) {
            
            [_IAP setObject:[NSString stringWithFormat:@"%f",expire] forKey:IAP_EXPORT_SUBSCRIPTION_EXPIRATION];
        }
        
        //Update subscription receipt
        [_IAP setObject:[PurchaseResult objectForKey:@"Receipt"] forKey:IAP_EXPORT_SUBSCRIPTION_RECEIPT];
        
    }
    else {
        
        NSRange range = [type rangeOfString:@"Form"];
        NSString *NumForms = [type substringToIndex:range.location];
        int numforms = [NumForms intValue];
        
        //Update number of forms in keychain
        
        NSNumber *formcount = [_IAP objectForKey:IAP_NUMFORMS];
        formcount = [NSNumber numberWithInt:(numforms + [formcount intValue])];
        [_IAP setObject:formcount forKey:IAP_NUMFORMS];
        
    }
    
    [self SaveIAP];
}

- (void)RemoveSubscription:(NSString *)type {
    
    if ([type isEqualToString:@"Unlimited"]) {
        
        [_IAP setObject:@"No" forKey:IAP_SUBSCRIPTION];
        [_IAP removeObjectForKey:IAP_SUBSCRIPTION_EXPIRATION];
        [_IAP removeObjectForKey:IAP_SUBSCRIPTION_RECEIPT];
    }
    else {
        
        [_IAP setObject:@"No" forKey:IAP_EXPORT_SUBSCRIPTION];
        [_IAP removeObjectForKey:IAP_EXPORT_SUBSCRIPTION_EXPIRATION];
        [_IAP removeObjectForKey:IAP_EXPORT_SUBSCRIPTION_RECEIPT];
    }
    
    [self SaveIAP];
    
}

- (void)RestoreSubscriptions {
    
#ifdef IS_UNLIMITED
    
    if (restoreDelegate) {
        [restoreDelegate RestoreCompleted:YES withErrorMessage:@"" withType:@""];
    }
    
    return;
    
#endif
    
    bool hasvip = [VIPUtilities IsValid];
    
    if (hasvip) {
        
        if (restoreDelegate) {
            [restoreDelegate RestoreCompleted:YES withErrorMessage:@"" withType:@""];
        }
        
        return;
    }
    
    [_RMStore restoreTransactionsOnSuccess:^(NSArray *transactions) {

        /*
        int count = 0;
        
        for (SKPaymentTransaction *transaction in transactions) {
            
            if (transaction.transactionState == SKPaymentTransactionStateRestored) {
                
                count++;
            }
        }
        */
        
        if (restoreDelegate) {
            [restoreDelegate RestoreCompleted:YES withErrorMessage:@"" withType:@""];
        }
        
    } failure:^(NSError *error) {

        NSString *err = [NSString stringWithFormat:@"restore error: %@",error];
        
        if (restoreDelegate) {
            [restoreDelegate RestoreCompleted:YES withErrorMessage:err withType:@""];
        }
    }];
}

- (void)SaveIAP {
    
    NSData *IAPData = [NSKeyedArchiver archivedDataWithRootObject:_IAP];
    
    //Encrypt IAPData
    NSData *encIAPData = [_VTDCrypto Encrypt:IAPData withPassword:@"0!5~0$8;8*1$0*2^1$2#1!3"];
    
    [KeychainWrapper updateKeychainValueFromData:encIAPData forIdentifier:[datasource GetKeychainKey]];
}

- (void)LoadIAP:(NSData *)IAP {
    
    //Decrypt IAPData and convert to NSMutableDictionary
    NSData *decIAPData = [_VTDCrypto Decrypt:IAP withPassword:@"0!5~0$8;8*1$0*2^1$2#1!3"];
    
    _IAP = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:decIAPData];
    
}

- (void)TransferIAPIntoShared {

    NSData *IAPData = [NSKeyedArchiver archivedDataWithRootObject:_IAP];

    //Encrypt IAPData
    NSData *encIAPData = [_VTDCrypto Encrypt:IAPData withPassword:@"0!5~0$8;8*1$0*2^1$2#1!3"];

    [KeychainWrapper updateKeychainValueFromDataInShared:encIAPData forIdentifier:@"MRF-CRF-IAP-KEY"];

    //Remove forms from current app
    NSNumber *formcount = [NSNumber numberWithInt:0];
    [_IAP setObject:formcount forKey:IAP_NUMFORMS];
    [self SaveIAP];

}

- (void)TransferSharedIntoIAP {

    NSData *IAPData =  [KeychainWrapper searchKeychainCopyMatchingIdentifierInShared:@"MRF-CRF-IAP-KEY"];

    if(IAPData) {

        NSData *decIAPData = [_VTDCrypto Decrypt:IAPData withPassword:@"0!5~0$8;8*1$0*2^1$2#1!3"];

        NSMutableDictionary *sharedIAP = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:decIAPData];

        NSNumber *sharedcount = [sharedIAP objectForKey:IAP_NUMFORMS];

        if([sharedcount intValue] > 0) {
            
            NSNumber *currentCount = [_IAP objectForKey:IAP_NUMFORMS];

            currentCount = [NSNumber numberWithInt:([currentCount intValue] + [sharedcount intValue])];

            [_IAP setObject:currentCount forKey:IAP_NUMFORMS];

            [self SaveIAP];

            //Set shared data to 0 and save
            currentCount = [NSNumber numberWithInt:0];
            [sharedIAP setObject:currentCount forKey:IAP_NUMFORMS];

            NSData *IAPData = [NSKeyedArchiver archivedDataWithRootObject:sharedIAP];

            //Encrypt IAPData
            NSData *encIAPData = [_VTDCrypto Encrypt:IAPData withPassword:@"0!5~0$8;8*1$0*2^1$2#1!3"];

            [KeychainWrapper updateKeychainValueFromDataInShared:encIAPData forIdentifier:@"MRF-CRF-IAP-KEY"];
        }


    }

}

@end

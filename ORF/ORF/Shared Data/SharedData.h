//
//  SharedData.h
//  ORF
//
//  Created by Francis Bowen on 5/26/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseSharedData.h"
#import "CloudServiceManager.h"
#import "Emailer.h"

#import "GeneralCSVListManager.h"

#import "RulesManager.h"

@protocol SharedDataDelegate <NSObject>
@optional
- (void)SetAuthorizationFlow:(id<OIDAuthorizationFlowSession>)CurrentFlow;

@end

@interface SharedData : BaseSharedData <
    CloudServiceDelegate,
    CloudServicePDFDelegate,
    CoreDataManagerDatasource,
    IAPManagerDatasource,
    EmailerCredentialsDelegate,
    GeneralCSVListDatasource
>
{
    CloudServiceManager *_CloudServiceManager;
    Emailer *_Emailer;

    GeneralCSVListManager *_GeneralCSVListManager;

    RulesManager *_RulesManager;
}

@property (weak) id <SharedDataDelegate> delegate;

+ (id)SharedInstance;

- (void)SetDelegate:(id<SharedDataDelegate>)adelegate;

- (CloudServiceManager *)GetCloudServices;
- (Emailer *)GetEmailer;

- (GeneralCSVListManager *)GetGeneralCSVListManager;

- (NSArray *)RulesItems;
- (void)ReloadRules;

@end

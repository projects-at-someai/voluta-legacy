//
//  SharedData.h
//  PRF
//
//  Created by Francis Bowen on 5/26/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseSharedData.h"
#import "CloudServiceManager.h"
#import "Emailer.h"

@protocol SharedDataDelegate <NSObject>
@optional
- (void)SetAuthorizationFlow:(id<OIDAuthorizationFlowSession>)CurrentFlow;

@end

@interface SharedData : BaseSharedData <
    CloudServiceDelegate,
    CloudServicePDFDelegate,
    CoreDataManagerDatasource,
    IAPManagerDatasource,
    EmailerCredentialsDelegate
>
{
    CloudServiceManager *_CloudServiceManager;
    Emailer *_Emailer;
}

@property (weak) id <SharedDataDelegate> delegate;

+ (id)SharedInstance;

- (void)SetDelegate:(id<SharedDataDelegate>)adelegate;

- (CloudServiceManager *)GetCloudServices;
- (Emailer *)GetEmailer;


@end

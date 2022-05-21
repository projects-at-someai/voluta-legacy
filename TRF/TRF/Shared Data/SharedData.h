//
//  SharedData.h
//  TRF
//
//  Created by Francis Bowen on 5/26/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseSharedData.h"
#import "CloudServiceManager.h"
#import "Emailer.h"
#import "InkListManager.h"
#import "NeedleListManager.h"
#import "InkThinnerListManager.h"
#import "DisposableGripListManager.h"
#import "DisposableTubeListManager.h"
#import "SalveListManager.h"

@protocol SharedDataDelegate <NSObject>
@optional
- (void)SetAuthorizationFlow:(OIDAuthorizationService *)CurrentFlow;
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
    
    InkListManager *_InkListManager;
    NeedleListManager *_NeedleListManager;
    InkThinnerListManager *_InkThinnerListManager;
    DisposableGripListManager *_DisposableGripListManager;
    DisposableTubeListManager *_DisposableTubeListManager;
    SalveListManager *_SalveListManager;
}

@property (weak) id <SharedDataDelegate> delegate;

+ (id)SharedInstance;

- (void)SetDelegate:(id<SharedDataDelegate>)adelegate;

- (CloudServiceManager *)GetCloudServices;
- (Emailer *)GetEmailer;

- (InkListManager *)GetInkListManager;
- (InkThinnerListManager *)GetInkThinnerListManager;
- (NeedleListManager *)GetNeedleListManager;
- (DisposableGripListManager *)GetDisposableGripListManager;
- (DisposableTubeListManager *)GetDisposableTubeListManager;
- (SalveListManager *)GetSalveListManager;

@end

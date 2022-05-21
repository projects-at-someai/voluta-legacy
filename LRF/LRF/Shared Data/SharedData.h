//
//  SharedData.h
//  LRF
//
//  Created by Francis Bowen on 5/26/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseSharedData.h"
#import "CloudServiceManager.h"
#import "LTRCoreDataManager.h"
#import "Emailer.h"

@interface SharedData : BaseSharedData <
    CloudServiceDelegate,
    FormDataManagerDatasource,
    IAPManagerDatasource,
    EmailerDelegate,
    EmailerCredentialsDelegate
>
{
    LTRCoreDataManager *_LTRCoreDataManager;
    CloudServiceManager *_CloudServiceManager;
    Emailer *_Emailer;
}

+ (id)SharedInstance;

- (LTRCoreDataManager *)GetLTRCoreDataManager;
- (CloudServiceManager *)GetCloudServices;
- (void)LoadTreatmentRecord;
- (Emailer *)GetEmailer;

@end

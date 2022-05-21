//
//  DefaultsTransferManager.h
//  TRF
//
//  Created by Francis Bowen on 10/3/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h> // Import the SQLite database framework
#import "EmployeeListManager.h"
#import "InkListManager.h"
#import "NeedleListManager.h"
#import "InkThinnerListManager.h"
#import "DisposableGripListManager.h"
#import "DisposableTubeListManager.h"
#import "CloudServiceManager.h"
#import "KeychainWrapper.h"
#import "SharedData.h"

#define DEFAULTS_PLIST  @"TRFDefaultsTransfer"

#define SQLSCT @"asd9085rjkvf0j3ceKjfjkqwerpoijusDvnbx0w90ru2enjksdVmv03eiopnsdvavkjn0jwfeiOvdsd"

@protocol DefaultsTransferManagerDelegate
@required
- (CloudServiceManager *)GetCloudServiceManager;

- (void)DBTransferComplete:(bool)Success;
- (void)DBTransferStatus:(CGFloat)CurrentItemNum withTotalNumber:(CGFloat)TotalItems;

@end

@interface DefaultsTransferManager : NSObject
{
    sqlite3 *_DB;
    
    EmployeeListManager *_EmployeeListManager;
    InkListManager *_InkListManager;
    NeedleListManager *_NeedleListManager;
    InkThinnerListManager *_InkThinnerListManager;
    DisposableGripListManager *_DisposableGripListManager;
    DisposableTubeListManager *_DisposableTubeListManager;
    
    CloudServiceManager *_CloudManager;
    
    NSString *_DocsDir;
    NSString *_TempDir;
    
}

@property (weak) id <DefaultsTransferManagerDelegate> delegate;

- (id)initWithDelegate:(id <DefaultsTransferManagerDelegate>)adelegate;
- (void)TransferAll;

@end

//
//  DefaultsTransferManager.h
//  PRF
//
//  Created by Francis Bowen on 10/3/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmployeeListManager.h"
#import "CloudServiceManager.h"
#import "KeychainWrapper.h"
#import "SharedData.h"

#define DEFAULTS_PLIST  @"PRFDefaultsTransfer"

#define SQLSCT @"VeR9085rjkvf0j3ce1slf8v04fboijusDvnbx0w90ru2enjksdVmv03eiopnsGLavkjn0jwfeiOvdsd"

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
    
    CloudServiceManager *_CloudManager;
    
    NSString *_DocsDir;
    NSString *_TempDir;
    
}

@property (weak) id <DefaultsTransferManagerDelegate> delegate;

- (id)initWithDelegate:(id <DefaultsTransferManagerDelegate>)adelegate;
- (void)TransferAll;

@end

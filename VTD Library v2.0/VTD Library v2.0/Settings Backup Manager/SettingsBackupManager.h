//
//  SettingsBackupManager.h
//  TRF
//
//  Created by Francis Bowen on 3/11/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompressionUtil.h"
#import "SettingsBackupPropertyListManager.h"
#import "VTDCrypto.h"
#import "KeychainWrapper.h"

@protocol SettingsBackupManagerDelegate
@optional
// Sent when the user selects a row in the recent searches list.
- (void)SettingsRestoreStarted;
- (void)SettingsRestoreComplete:(bool)success withErrorMessage:(NSString *)error;
@end

@protocol SettingsBackupManagerDatasource
@required
- (NSString *)GetAppID;
@end

@interface SettingsBackupManager : NSObject
{

    NSUserDefaults *defaults;
    
    NSString *documentsDir;
    NSString *tempDir;
    NSString *restoreFileName;
    
    SettingsBackupPropertyListManager *_SettingsBackupPlistManager;
    
    VTDCrypto *_VTDCrypto;
}

@property (weak) id <SettingsBackupManagerDelegate> delegate;
@property (weak) id <SettingsBackupManagerDatasource> datasource;
@property (nonatomic, retain) CompressionUtil *archiver;

- (NSString *)ExportSettings;
- (void)RestoreSettings:(NSString *)filename withPath:(NSString *)Path;

@end


//
//  SettingsBackupManager.m
//  TRF
//
//  Created by Francis Bowen on 3/11/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "SettingsBackupManager.h"

@implementation SettingsBackupManager

@synthesize archiver;
@synthesize delegate;
@synthesize datasource;

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        archiver = [[CompressionUtil alloc] init];
        defaults = [NSUserDefaults standardUserDefaults];
        
        _SettingsBackupPlistManager = [[SettingsBackupPropertyListManager alloc] init];
        
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDir = [documentPaths objectAtIndex:0];
        tempDir = [NSString stringWithFormat:@"%@/Temp",documentsDir];
    }
    
    return self;
}

- (NSString *)ExportSettings {
    
    return [self CreateSettingsBackup];
}

- (NSString *)CreateSettingsBackup {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMddyyyy"];
    NSDate *date = [NSDate date];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    NSString *fileName = [NSString stringWithFormat:@"%@/%@_%@.%@",
                          tempDir,
                          [datasource GetAppID],
                          dateString,
                          SETTINGS_EXTENSION];
    
    NSString *pListPath = [tempDir stringByAppendingPathComponent:@"settings.plist"];
    
    NSMutableDictionary *DefaultSettingsToSave = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    
    NSArray *SettingsToBackup = [_SettingsBackupPlistManager GetSettingsToBackup];
    
    for (int i = 0; i < [SettingsToBackup count]; i++) {
        
        NSDictionary *setting = [SettingsToBackup objectAtIndex:i];
        
        NSString *type = [setting objectForKey:@"type"];
        NSString *key = [setting objectForKey:@"key"];
        
        if (setting != nil && type != nil && key != nil) {
        
            if ([type isEqualToString:@"plist"]) {
                
                //Add plist
                NSMutableDictionary *pListEntry = [[NSMutableDictionary alloc] init];
                [pListEntry setObject:key forKey:@"FileName"];
                [pListEntry setObject:documentsDir forKey:@"Path"];
                [fileList addObject:pListEntry];
            }
            else if ([type isEqualToString:@"user defaults"]) {
                
                [self AddSettingToDic:key toDict:DefaultSettingsToSave withType:type];
            }
            else if ([type isEqualToString:@"keychain"]) {
                
                NSString *keyval = [KeychainWrapper keychainStringFromMatchingIdentifier:key];
                
                if (keyval != nil) {
                    
                    [self AddSettingToDic:keyval
                                   toDict:DefaultSettingsToSave
                                 withType:type];
                }
                
                
            }
            else if ([type isEqualToString:@"file"]) {
                
                [self AddSettingToDic:key
                               toDict:DefaultSettingsToSave
                             withType:type];
                
                //Add file to zip
                NSString *filename = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                
                if (filename != nil) {
                    
                    NSMutableDictionary *fileentry = [[NSMutableDictionary alloc] init];
                    [fileentry setObject:[filename lastPathComponent] forKey:@"FileName"];
                    
                    NSString *path = [filename stringByDeletingLastPathComponent];
                    
                    if (path == nil || [path isEqualToString:@""]) {
                        path = documentsDir;
                    }
                    
                    [fileentry setObject:path forKey:@"Path"];
                    [fileList addObject:fileentry];
                }
                
            }
            else if ([type isEqualToString:@"logo"]) {
                
                NSString *hasLogo = [defaults objectForKey:USING_LOGO_KEY];
                
                [self AddSettingToDic:USING_LOGO_KEY
                               toDict:DefaultSettingsToSave
                             withType:@"user defaults"];
                
                if(hasLogo != nil && [hasLogo isEqualToString:@"Yes"]) {
                    
                    //Add Logo.png
                    NSMutableDictionary *logoEntry = [[NSMutableDictionary alloc] init];
                    [logoEntry setObject:key forKey:@"FileName"];
                    [logoEntry setObject:documentsDir forKey:@"Path"];
                    [fileList addObject:logoEntry];
                }
            }

        }
        
    }
    
    [DefaultSettingsToSave writeToFile:pListPath atomically:NO];
    
    //Add settings.plist to finle list
    NSMutableDictionary *settingsEntry = [[NSMutableDictionary alloc] init];
    [settingsEntry setObject:@"settings.plist" forKey:@"FileName"];
    [settingsEntry setObject:tempDir forKey:@"Path"];
    [fileList addObject:settingsEntry];

    [archiver CompressFilesFromArrayList:fileName withFileList:fileList];
    
    if (!_VTDCrypto) {
        _VTDCrypto = [[VTDCrypto alloc] init];
    }
    
    NSData *plainData = [NSData dataWithContentsOfFile:fileName options:NSDataReadingMapped error:nil];
    NSData *encryptedData = [_VTDCrypto Encrypt:plainData withPassword:@"r2y12a20l13s"];
    
    NSString *encryptedFilename = [fileName stringByAppendingPathExtension:@"enc"];
    [encryptedData writeToFile:encryptedFilename atomically:NO];
    plainData = nil;
    encryptedData = nil;
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    [fm removeItemAtPath:fileName error:nil];
    
    return encryptedFilename;
    
}

- (void)AddSettingToDic:(NSString *)setting toDict:(NSMutableDictionary *)dict withType:(NSString *)type {
    
    NSString *val = [defaults objectForKey:setting];
    
    if(val != nil) {
        
        [dict setObject:val forKey:[NSString stringWithFormat:@"%@~%@",type,setting]];
    }
    
}

- (void)RestoreSettings:(NSString *)filename withPath:(NSString *)Path {
    
    restoreFileName = [NSString stringWithFormat:@"%@/%@",Path,filename];
    
    if (delegate) {
        
        //Signal view controller that the restore has started
        [delegate SettingsRestoreStarted];
    }
    
    [self ContinueRestoring];
    
}

- (void)ContinueRestoring {
    
    //decrypt file
    if (!_VTDCrypto) {
        _VTDCrypto = [[VTDCrypto alloc] init];
    }
    
    //NSString *decryptedFilename = [_VTDCrypto DecryptFileAtPath:restoreFileName withPassword:@"r2y12a20l13s"];
    NSData *encryptedData = [NSData dataWithContentsOfFile:restoreFileName options:NSDataReadingMapped error:nil];
    NSData *decryptedData = [_VTDCrypto Decrypt:encryptedData withPassword:@"r2y12a20l13s"];
    NSString *decryptedFilename = [restoreFileName stringByDeletingPathExtension];
    
    [decryptedData writeToFile:decryptedFilename atomically:NO];
    encryptedData = nil;
    decryptedData = nil;
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    bool didExtract = [archiver ExtractFiles:decryptedFilename toPath:tempDir];
    
    if (didExtract) {
        
        [self RestoreDefaults];
        [self RestorePlists];
        [self RestoreLogo];

        [fm removeItemAtPath:restoreFileName error:nil];

        if (delegate) {
            [delegate SettingsRestoreComplete:true withErrorMessage:nil];
        }
        
    }
    else {
        
        if (delegate) {
            [delegate SettingsRestoreComplete:false withErrorMessage:@"Settings file is not valid."];
        }
    }
}

- (void)RestoreDefaults {
    
    NSString *pListPath = [tempDir stringByAppendingPathComponent:@"settings.plist"];
    
    NSDictionary *settingsDict = [[NSDictionary alloc] initWithContentsOfFile:pListPath];
    
    NSArray *keys = [settingsDict allKeys];
    
    for (NSString *key in keys) {
        
        NSRange range = [key rangeOfString:@"~"];
    
        NSString *type = [key substringToIndex:range.location];
        NSString *k = [key substringFromIndex:(range.location + 1)];
        
        if ([type isEqualToString:@"file"]) {
            
            NSString *FileAndPath = [settingsDict objectForKey:key];
            [defaults setObject:FileAndPath forKey:k];
            
            //Is there a path? If not, set it to the documents directory
            NSString *path = [FileAndPath stringByDeletingLastPathComponent];
            NSString *filename = [FileAndPath lastPathComponent];
            
            if (path == nil || [path isEqualToString:@""]) {
                path = documentsDir;
            }
            
            //Copy file to path
            NSString *fileToCopy = [FileAndPath lastPathComponent];
            fileToCopy = [NSString stringWithFormat:@"%@/%@",tempDir,fileToCopy];
            NSFileManager *fm = [[NSFileManager alloc] init];
            [fm copyItemAtPath:fileToCopy toPath:[NSString stringWithFormat:@"%@/%@",path,filename] error:nil];
            
        }
        else if ([type isEqualToString:@"keychain"]) {
            
            [KeychainWrapper createKeychainValue:[settingsDict objectForKey:key] forIdentifier:k];
        }
        else {
            
            //user defaults
            [defaults setObject:[settingsDict objectForKey:key] forKey:k];
        }
        
        
    }
}

- (void)CopyFromTempToDocuments:(NSString *)Filename {

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error;
    
    NSString *pListPath = [tempDir stringByAppendingPathComponent:Filename];
    
    [fileManager removeItemAtPath:[documentsDir stringByAppendingPathComponent:Filename]
                            error:&error];
    
    [fileManager copyItemAtPath:pListPath
                         toPath:[documentsDir stringByAppendingPathComponent:Filename]
                          error:&error];
}

- (void)RestoreLogo {
    
    NSError *error;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    //Restore logo
    NSString *logoPath = [NSString stringWithFormat:@"%@/logo.png",tempDir];
    NSString *logoDestPath = [NSString stringWithFormat:@"%@/logo.png",documentsDir];
    bool logoExists = [filemgr fileExistsAtPath:logoPath];
    NSString *hasLogo = [defaults objectForKey:USING_LOGO_KEY];
    
    if (logoExists && hasLogo != nil && [hasLogo isEqualToString:@"Yes"]) {
        
        [filemgr removeItemAtPath:logoDestPath error:nil];
        [filemgr copyItemAtPath:logoPath toPath:logoDestPath error:&error];
        
    }
}

- (void)RestorePlists {
    
    NSArray *SettingsToBackup = [_SettingsBackupPlistManager GetSettingsToBackup];
    
    for (int i = 0; i < [SettingsToBackup count]; i++) {
        
        NSDictionary *setting = [SettingsToBackup objectAtIndex:i];
        
        NSString *type = [setting objectForKey:@"type"];
        NSString *key = [setting objectForKey:@"key"];
        
        if ([type isEqualToString:@"plist"]) {
            
            [self CopyFromTempToDocuments:key];
        }
        
    }
    
}

@end

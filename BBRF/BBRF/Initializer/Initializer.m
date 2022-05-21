//
//  Initializer.m
//  BBRF
//
//  Created by Francis Bowen on 11/13/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "Initializer.h"

@implementation Initializer

- (void)InitializeDefaults {
    
    //check for default settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:ORIENTATION_KEY] == nil)
    {
        [defaults setObject:ORIENTATION_AUTO forKey:ORIENTATION_KEY];
    }
    
    if ([defaults objectForKey:USING_DROPBOX_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:USING_DROPBOX_KEY];
    }
    
    if ([defaults objectForKey:USING_GOOGLEDRIVE_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:USING_GOOGLEDRIVE_KEY];
    }
    
    if ([defaults objectForKey:USING_ONEDRIVE_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:USING_ONEDRIVE_KEY];
    }
    
    if ([defaults objectForKey:USING_BOX_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:USING_BOX_KEY];
    }
    
    if ([defaults objectForKey:CAMERA_TYPE_KEY] == nil) {
        
        [defaults setObject:@"Front" forKey:CAMERA_TYPE_KEY];
    }
    
    if ([defaults objectForKey:REGION_KEY] == nil) {
        
        [defaults setObject:[Utilities GetCountryName] forKey:REGION_KEY];
    }
    
    if ([defaults objectForKey:INITIAL_POPUP_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:INITIAL_POPUP_KEY];
        [defaults setObject:@"" forKey:INITIAL_POPUP_TEXT_KEY];
    }
    
    if ([defaults objectForKey:USING_OPTIONALNOTES_KEY] == nil) {
        
        [defaults setObject:@"Yes" forKey:USING_OPTIONALNOTES_KEY];
    }
    
    if ([defaults objectForKey:FORCING_EMAIL_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:FORCING_EMAIL_KEY];
    }
    
    if ([defaults objectForKey:REQUIRE_SEC_GOVT_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:REQUIRE_SEC_GOVT_KEY];
    }
    
    if ([defaults objectForKey:USING_DEVICE_SYNC_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:USING_DEVICE_SYNC_KEY];
    }
    
    if ([defaults objectForKey:CAPTURE_ID_KEY] == nil) {
        
        [defaults setObject:@"Yes" forKey:CAPTURE_ID_KEY];
    }
    
    if ([defaults objectForKey:EMAIL_WAIVER_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:EMAIL_WAIVER_KEY];
    }
    
    if ([defaults objectForKey:CDATA_IS_LEECHED_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:CDATA_IS_LEECHED_KEY];
    }
    
    if ([defaults objectForKey:USING_UBIQUITOUS_FOLDER_KEY] == nil) {
        
        [defaults setObject:@"No" forKey:USING_UBIQUITOUS_FOLDER_KEY];
    }
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _DocumentsDir = [documentPaths objectAtIndex:0];
    
    NSLog(@"%@",_DocumentsDir);
    
    //Copy plists
    _VersionHasChanged = [Utilities HasVersionChanged];
    _RegionHasChanged = [Utilities HasRegionChanged];
    
    //EmployeeList
    if (![self CheckForPList:EMPLOYEELIST_PLST_NAME]) {
        
        NSLog(@"Employee plist not found, creating a new one in the documents directory");
        // Copy the database from the package to the users filesystem
        
        NSDictionary *emptyplist = [[NSDictionary alloc] init];
        
        [emptyplist writeToFile:[_DocumentsDir stringByAppendingPathComponent:EMPLOYEELIST_PLST_NAME] atomically:NO];
    }
    
    //Finalize
    if (_VersionHasChanged || _RegionHasChanged || ![self CheckForPList:FINALIZE_PLIST_NAME]) {
        
        NSLog(@"Copying %@", FINALIZE_PLIST_NAME);
        
        [self CopyDefaultRegionPList:[DEFAULT_FINALIZE_PLIST_NAME stringByDeletingPathExtension]
              withDestFileName:[_DocumentsDir stringByAppendingPathComponent:FINALIZE_PLIST_NAME]];
    }

    //Rules
    if (![self CheckForPList:RULES_PLIST_NAME]) {

        NSLog(@"Copying %@", RULES_PLIST_NAME);

        [self CopyDefaultPList:[DEFAULT_RULES_PLIST_NAME stringByDeletingPathExtension]
              withDestFileName:[_DocumentsDir stringByAppendingPathComponent:RULES_PLIST_NAME]];
    }

    /*
    //Health
    if (![self CheckForPList:HEALTH_PLIST_NAME]) {
        
        NSLog(@"Copying %@", HEALTH_PLIST_NAME);
        
        [self CopyDefaultPList:[DEFAULT_HEALTH_PLIST_NAME stringByDeletingPathExtension]
                    withDestFileName:[_DocumentsDir stringByAppendingPathComponent:HEALTH_PLIST_NAME]];
    }
    
    //Health items to check
    if (![self CheckForPList:HEALTHITEMSTOCHECK_PLIST_NAME]) {
        
        NSLog(@"Copying %@", HEALTHITEMSTOCHECK_PLIST_NAME);
        
        [self CopyDefaultPList:[DEFAULT_HEALTHITEMSTOCHECK_PLIST_NAME stringByDeletingPathExtension]
              withDestFileName:[_DocumentsDir stringByAppendingPathComponent:HEALTHITEMSTOCHECK_PLIST_NAME]];
    }
    */

    //How To
    if (_VersionHasChanged || _RegionHasChanged || ![self CheckForPList:HOWTO_PLIST_NAME]) {
        
        NSLog(@"Copying %@", HOWTO_PLIST_NAME);
        
        [self CopyDefaultPList:[DEFAULT_HOWTO_PLIST_NAME stringByDeletingPathExtension]
              withDestFileName:[_DocumentsDir stringByAppendingPathComponent:HOWTO_PLIST_NAME]];
    }
    
    //Legal
    if (![self CheckForPList:LEGAL_PLIST_NAME]) {
        
        NSLog(@"Copying %@", LEGAL_PLIST_NAME);
        
        [self CopyDefaultPList:[DEFAULT_LEGAL_PLIST_NAME stringByDeletingPathExtension]
              withDestFileName:[_DocumentsDir stringByAppendingPathComponent:LEGAL_PLIST_NAME]];
    }
    
    //PDF
    if (_VersionHasChanged || _RegionHasChanged || ![self CheckForPList:PDF_PLIST_NAME]) {
        
        NSLog(@"Copying %@", PDF_PLIST_NAME);
        
        [self CopyDefaultRegionPList:[DEFAULT_PDF_PLIST_NAME stringByDeletingPathExtension]
                    withDestFileName:[_DocumentsDir stringByAppendingPathComponent:PDF_PLIST_NAME]];
    }
    
    //PDF-International
    if (_VersionHasChanged || _RegionHasChanged || ![self CheckForPList:PDFINTER_PLIST_NAME]) {
        
        NSLog(@"Copying %@", PDFINTER_PLIST_NAME);
        
        [self CopyDefaultRegionPList:[DEFAULT_PDFINTER_PLIST_NAME stringByDeletingPathExtension]
              withDestFileName:[_DocumentsDir stringByAppendingPathComponent:PDFINTER_PLIST_NAME]];
    }
    
    //Settings and Options
    if (_VersionHasChanged || _RegionHasChanged || ![self CheckForPList:SETTINGSANDOPTIONS_PLIST_NAME]) {
        
        NSLog(@"Copying %@", SETTINGSANDOPTIONS_PLIST_NAME);
        
        [self CopyDefaultRegionPList:[DEFAULT_SETTINGSANDOPTIONS_PLIST_NAME stringByDeletingPathExtension]
                    withDestFileName:[_DocumentsDir stringByAppendingPathComponent:SETTINGSANDOPTIONS_PLIST_NAME]];
    }
    
    //Settings Backup
    if (_VersionHasChanged || _RegionHasChanged || ![self CheckForPList:SETTINGSBACKUP_PLIST_NAME]) {
        
        NSLog(@"Copying %@", SETTINGSBACKUP_PLIST_NAME);
        
        [self CopyDefaultRegionPList:[DEFAULT_SETTINGSBACKUP_PLIST_NAME stringByDeletingPathExtension]
              withDestFileName:[_DocumentsDir stringByAppendingPathComponent:SETTINGSBACKUP_PLIST_NAME]];
    }
    
    //Supporting Documents
    if (_VersionHasChanged || _RegionHasChanged || ![self CheckForPList:SUPPORTINGDOCUMENTS_PLIST_NAME]) {
        
        NSLog(@"Copying %@", SUPPORTINGDOCUMENTS_PLIST_NAME);
        
        [self CopyDefaultPList:[DEFAULT_SUPPORTINGDOCUMENTS_PLIST_NAME stringByDeletingPathExtension]
              withDestFileName:[_DocumentsDir stringByAppendingPathComponent:SUPPORTINGDOCUMENTS_PLIST_NAME]];
    }
    
    //Info Tables
    if (_VersionHasChanged || _RegionHasChanged || ![self CheckForPList:TABLES_PLIST_NAME]) {
        
        NSLog(@"Copying %@", TABLES_PLIST_NAME);
        
        [self CopyDefaultRegionPList:[DEFAULT_TABLES_PLIST_NAME stringByDeletingPathExtension]
                    withDestFileName:[_DocumentsDir stringByAppendingPathComponent:TABLES_PLIST_NAME]];
    }
    
    //In app purchases
    if (_VersionHasChanged || ![self CheckForPList:IAP_PLIST_NAME]) {
        
        NSLog(@"Copying %@", IAP_PLIST_NAME);
        
        [self CopyDefaultPList:[DEFAULT_IAP_PLIST_NAME stringByDeletingPathExtension]
              withDestFileName:[_DocumentsDir stringByAppendingPathComponent:IAP_PLIST_NAME]];
    }

    if (_VersionHasChanged) {
        
        _VersionHasChanged = NO;
        [[NSUserDefaults standardUserDefaults] setObject:[Utilities AppVersion] forKey:VERSION_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:[Utilities AppBuild] forKey:BUILD_KEY];
    }
    
    if (_RegionHasChanged) {
        
        _RegionHasChanged = NO;
        [[NSUserDefaults standardUserDefaults] setObject:[Utilities GetCountryName] forKey:REGION_KEY];
    }
    
}

- (bool)CheckForPList:(NSString *)PlistName {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *path = [_DocumentsDir stringByAppendingPathComponent:PlistName];
    
    return [fm fileExistsAtPath:path isDirectory:nil];
}

- (void)CopyDefaultPList:(NSString *)BundleFileName withDestFileName:(NSString *)DestFileName{
    
    NSString *DefaultPListPath = [[NSBundle mainBundle]
                                  pathForResource:BundleFileName
                                  ofType:@"plist"];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:DestFileName]) {
        [filemgr removeItemAtPath:DestFileName error:nil];
    }
    
    [filemgr copyItemAtPath:DefaultPListPath toPath:DestFileName error:nil];
}

- (void)CopyDefaultPListFromBundle:(NSString *)BundleFileName
                        fromBundle:(NSString *)BundleName
                  withDestFileName:(NSString *)DestFileName{
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:BundleName ofType:@"bundle"];
    
    
    
    NSString *DefaultPListPath = [[NSBundle bundleWithPath:bundlePath]
                                  pathForResource:BundleFileName
                                  ofType:@"plist"];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:DestFileName]) {
        [filemgr removeItemAtPath:DestFileName error:nil];
    }
    
    [filemgr copyItemAtPath:DefaultPListPath toPath:DestFileName error:nil];
}

- (void)CopyDefaultRegionPList:(NSString *)BundleFileName withDestFileName:(NSString *)DestFileName{
    
    NSString *CountryName = [Utilities GetCountryName];
    NSString *Region = @"US";
    
    if ([CountryName isEqualToString:REGION_UK]) {
        
        Region = @"UK";
    }
    else if ([CountryName isEqualToString:REGION_CAN]) {
        
        Region = @"CAN";
    }
    else if ([CountryName isEqualToString:REGION_AUS]) {
        
        Region = @"AUS";
    }
    else if ([CountryName isEqualToString:REGION_NZ]) {
        
        Region = @"NZ";
    }
    
    NSString *DefaultPListPath = [[NSBundle mainBundle]
                                  pathForResource:[NSString stringWithFormat:@"%@-%@",BundleFileName,Region]
                                  ofType:@"plist"];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:DestFileName]) {
        [filemgr removeItemAtPath:DestFileName error:nil];
    }
    
    [filemgr copyItemAtPath:DefaultPListPath toPath:DestFileName error:nil];
}

@end

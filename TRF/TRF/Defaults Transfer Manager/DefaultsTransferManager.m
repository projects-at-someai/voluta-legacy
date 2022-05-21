//
//  DefaultsTransferManager.m
//  TRF
//
//  Created by Francis Bowen on 10/3/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "DefaultsTransferManager.h"

@implementation DefaultsTransferManager

@synthesize delegate;

- (id)initWithDelegate:(id <DefaultsTransferManagerDelegate>)adelegate {
    
    self = [super init];
    
    if (self) {
        
        delegate = adelegate;
        
        _CloudManager = [delegate GetCloudServiceManager];
        
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _DocsDir = [documentPaths objectAtIndex:0];
        _TempDir = [NSString stringWithFormat:@"%@/temp",_DocsDir];
    }
    
    return self;
}

- (void)TransferAll {
    
    [self OpenDB];
    
    //v1 settings backup
    //NSString *archivefilename = [self CreateSettingsBackup];
    
    //Artist names from db
    [self LoadAllSpecialists:@"ArtistsTable"];
    
    //Inks from db
    [self LoadInkList];
    
    //Needles form db
    [self LoadNeedleList];
    
    //Ink Thinners from db
    [self LoadInkThinnerList];
    
    //Disposable Tubes from db
    [self LoadDisposableTubeList];
    
    //Disposable Grips from db
    [self LoadDisposableGripList];
    
    //Master and secondary PWs
    [self TransferPWs];
    
    //Defaults
    [self TransferDefaults];
    
    //Remove 'How long since you last ate?' item from HealthItemsToCheck
    [self ModifyHealthItemsToCheck];
    
    //Check if slideshow is enabled
    [self CheckSlideshowEnabled];
    
    //Check cloud services
    [self SetupCloudServices];
    
    //Upload settings backup
    //_CloudManager.uploadDelegate = nil;
    //[_CloudManager UploadFile:archivefilename withFilepath:_DocsDir];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Yes" forKey:APP_SETUP_KEY];
    
    [self CloseDB];
}

- (void)TransferDefaults {
    
    NSString *DefaultPListPath = [[NSBundle mainBundle]
                                  pathForResource:DEFAULTS_PLIST
                                  ofType:@"plist"];
    
    NSDictionary *defaultsplist = [[NSDictionary alloc] initWithContentsOfFile:DefaultPListPath];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (int i = 0; i < [defaultsplist count]; i++)
    {
        NSString *entry = [NSString stringWithFormat:@"Defaults%d",i];
        NSDictionary *defaultkeys = [defaultsplist objectForKey:entry];
        
        NSString *v1key = [defaultkeys objectForKey:@"v1key"];
        NSString *v2key = [defaultkeys objectForKey:@"v2key"];
        
        NSString *v1value = [defaults objectForKey:v1key];
        
        if (v1value != nil) {
            
            [defaults setObject:v1value forKey:v2key];
        }
        
    }
}

- (void)TransferPWs {

    /*
    //Transfer master pw from keychain
    NSData *masterpw = [KeychainWrapper getKeychainData:@"MasterPWKey"];
    [KeychainWrapper updateKeychainValueFromData:masterpw forIdentifier:MASTER_PW_KEY];
    
    //Transfer artist pw from keychain
    NSData *artistpw = [KeychainWrapper getKeychainData:@"ArtistPWKey"];
    [KeychainWrapper updateKeychainValueFromData:artistpw forIdentifier:SECONDARY_PW_KEY];
     
     */
    
    NSString *masterstr = [KeychainWrapper keychainStringFromMatchingIdentifier:@"MasterPWKey"];
    [KeychainWrapper updateKeychainValue:masterstr forIdentifier:MASTER_PW_KEY];
    
    NSString *secondarystr = [KeychainWrapper keychainStringFromMatchingIdentifier:@"ArtistPWKey"];
    [KeychainWrapper updateKeychainValue:secondarystr forIdentifier:SECONDARY_PW_KEY];

}

- (void)SetupCloudServices {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *dropbox = [defaults objectForKey:@"isUsingDropbox"];
    
    if (dropbox != nil &&
        [dropbox isEqualToString:@"Yes"] &&
        [_CloudManager isDropboxLinked]) {
        
        [defaults setObject:@"Yes" forKey:USING_DROPBOX_KEY];
        
        [_CloudManager SetServiceState:@"Dropbox" withState:@"Yes"];
    }
    
    NSString *googledrive = [defaults objectForKey:@"isUsingGoogleDrive"];
    
    if (googledrive != nil &&
        [googledrive isEqualToString:@"Yes"] &&
        [_CloudManager isGoogleDriveAuthorized]) {
        
        [defaults setObject:@"Yes" forKey:USING_GOOGLEDRIVE_KEY];
        
         [_CloudManager SetServiceState:@"Google Drive" withState:@"Yes"];
    }
    
    NSString *onedrive = [defaults objectForKey:@"isUsingOneDrive"];
    
    if (onedrive != nil &&
        [onedrive isEqualToString:@"Yes"] &&
        [_CloudManager isOneDriveAuthorized]) {
        
        [defaults setObject:@"Yes" forKey:USING_ONEDRIVE_KEY];
        
         [_CloudManager SetServiceState:@"OneDrive" withState:@"Yes"];
    }
}

- (void)OpenDB {
    
    NSString *DBFilename = [NSString stringWithFormat:@"%@/%@",_DocsDir,DB_NAME];
    
    // Open the database from the users filessytem
    if(sqlite3_open([DBFilename UTF8String], &_DB) == SQLITE_OK)
    {

        const char* sqlitekey = [SQLSCT UTF8String];
        
        sqlite3_key(_DB, sqlitekey, (int)strlen(sqlitekey));
        
    }
}

- (void)CloseDB {
    
    sqlite3_close(_DB);
}

- (void)LoadAllSpecialists:(NSString *)TableName {
    
    if (_EmployeeListManager == nil) {
        
        _EmployeeListManager = [[EmployeeListManager alloc] init];
    }
    
    //Note: this assumes the database is already open
    
    // Setup the SQL Statement and compile it for faster access
    NSString *select = [NSString stringWithFormat:@"select * from \"%@\"",TableName];
    const char *ArtistTableStmt = [select UTF8String];
    
    sqlite3_stmt *ArtistTableCompiledStmt;
    
    int num = 0;
    
    if(sqlite3_prepare_v2(_DB, ArtistTableStmt, -1, &ArtistTableCompiledStmt, NULL) == SQLITE_OK) {
    
        [_EmployeeListManager RemoveAll];
        
        // Loop through the results and add them to the feeds array
        int ret = sqlite3_step(ArtistTableCompiledStmt);
        
        while(ret == SQLITE_ROW)
        {
            
            char *name_str = (char *)sqlite3_column_text(ArtistTableCompiledStmt, 0);
            if (name_str != NULL) {
                
                NSString *name = [NSString stringWithUTF8String:name_str];
                
                [_EmployeeListManager AddEmployeeToList:name];
                num++;
            }
            
            name_str = nil;
            
            ret = sqlite3_step(ArtistTableCompiledStmt);
            
        }
        
        //NSLog(@"%d read from DB", totalRead);
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(ArtistTableCompiledStmt);
    ArtistTableCompiledStmt = nil;
    
    if (num > 0) {
        [_EmployeeListManager CommitEmployeeList];
    }
    
}

- (void)LoadInkList {
    
    //NSMutableArray *inks = [self readAllInks];
    
    if (_InkListManager == nil) {
        
        _InkListManager = [[InkListManager alloc] init];
    }
    
    /*
    [_InkListManager RemoveAll];
    
    for (NSString *ink in inks) {
        
        NSArray *components = [ink componentsSeparatedByString:@","];
        [_InkListManager AddInkFromBrand:[components objectAtIndex:0]
                              inCategory:[components objectAtIndex:1]
                               withColor:[components objectAtIndex:2]];
    }
    */
    
    [_InkListManager RestoreDefaults];
    
    [_InkListManager SaveToPList];
    
    //inks = nil;
}

- (void)LoadNeedleList {
    
    NSMutableArray *needles = [self readAllNeedles];
    
    if (_NeedleListManager == nil) {
        
        _NeedleListManager = [[NeedleListManager alloc] init];
    }
    
    [_NeedleListManager RemoveAll];
    
    for (NSString *needle in needles) {
        
        NSArray *components = [needle componentsSeparatedByString:@","];
        [_NeedleListManager AddNeedleFromConfiguration:[components objectAtIndex:0]
                                                inType:[components objectAtIndex:1]
                                              withSize:[components objectAtIndex:2]];
    }
    
    [_NeedleListManager SaveToPList];
    
    needles = nil;
}

- (void)LoadInkThinnerList {
    
    NSMutableArray *thinners = [self readAllInkThinners];
    
    if (_InkThinnerListManager == nil) {
        
        _InkThinnerListManager = [[InkThinnerListManager alloc] init];
    }
    
    [_InkThinnerListManager RemoveAll];
    
    for (NSString *thinner in thinners) {
        
        [_InkThinnerListManager AddInkThinner:thinner];
    }
    
    [_InkThinnerListManager SaveToPList];
    
    thinners = nil;
}

- (void)LoadDisposableTubeList {
    
    NSMutableArray *tubes = [self readAllDisposableTubes];
    
    if (_DisposableTubeListManager == nil) {
        
        _DisposableTubeListManager = [[DisposableTubeListManager alloc] init];
    }
    
    [_DisposableTubeListManager RemoveAll];
    
    for (NSString *tube in tubes) {
        
        [_DisposableTubeListManager AddDisposableTube:tube];
    }
    
    [_DisposableTubeListManager SaveToPList];
    
    tubes = nil;
}

- (void)LoadDisposableGripList {
    
    NSMutableArray *grips = [self readAllDisposableGrips];
    
    if (_DisposableGripListManager == nil) {
        
        _DisposableGripListManager = [[DisposableGripListManager alloc] init];
    }
    
    [_DisposableGripListManager RemoveAll];
    
    for (NSString *grip in grips) {
        
        [_DisposableGripListManager AddDisposableGrip:grip];
    }
    
    [_DisposableGripListManager SaveToPList];
    
    grips = nil;
}

#pragma mark - db read functions
- (NSMutableArray *)readAllInks {
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    // Setup the SQL Statement and compile it for faster access
    const char *ListTableStmt = "select * from InkTable";
    
    sqlite3_stmt *ListTableCompiledStmt;
    
    if(sqlite3_prepare_v2(_DB, ListTableStmt, -1, &ListTableCompiledStmt, NULL) == SQLITE_OK) {
        
        // Loop through the results and add them to the feeds array
        while(sqlite3_step(ListTableCompiledStmt) == SQLITE_ROW)
        {
            
            char *str0 = (char *)sqlite3_column_text(ListTableCompiledStmt, 0);
            char *str1 = (char *)sqlite3_column_text(ListTableCompiledStmt, 1);
            char *str2 = (char *)sqlite3_column_text(ListTableCompiledStmt, 2);
            
            if (str0 != NULL && str1 != NULL && str2 != NULL) {
                
                NSString *s0 = [NSString stringWithUTF8String:str0];
                NSString *s1 = [NSString stringWithUTF8String:str1];
                NSString *s2 = [NSString stringWithUTF8String:str2];
                
                NSString *val = [NSString stringWithFormat:@"%@,%@,%@",s0,s1,s2];
                
                [list addObject:val];
            }
            
            str0 = nil;
            str1 = nil;
            str2 = nil;
            
        }
        
        //NSLog(@"%d read from DB", totalRead);
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(ListTableCompiledStmt);
    ListTableCompiledStmt = nil;
    
    return list;
}

- (NSMutableArray *)readAllNeedles {
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    // Setup the SQL Statement and compile it for faster access
    const char *ListTableStmt = "select * from NeedleTable";
    
    sqlite3_stmt *ListTableCompiledStmt;
    
    if(sqlite3_prepare_v2(_DB, ListTableStmt, -1, &ListTableCompiledStmt, NULL) == SQLITE_OK) {
        
        // Loop through the results and add them to the feeds array
        while(sqlite3_step(ListTableCompiledStmt) == SQLITE_ROW)
        {
            
            char *str0 = (char *)sqlite3_column_text(ListTableCompiledStmt, 0);
            char *str1 = (char *)sqlite3_column_text(ListTableCompiledStmt, 1);
            char *str2 = (char *)sqlite3_column_text(ListTableCompiledStmt, 2);
            
            if (str0 != NULL && str1 != NULL && str2 != NULL) {
                
                NSString *s0 = [NSString stringWithUTF8String:str0];
                NSString *s1 = [NSString stringWithUTF8String:str1];
                NSString *s2 = [NSString stringWithUTF8String:str2];
                
                NSString *val = [NSString stringWithFormat:@"%@,%@,%@",s0,s1,s2];
                
                [list addObject:val];
            }
            
            str0 = nil;
            str1 = nil;
            str2 = nil;
        }
        
        //NSLog(@"%d read from DB", totalRead);
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(ListTableCompiledStmt);
    ListTableCompiledStmt = nil;
    
    return list;
    
}

- (NSMutableArray *)readAllInkThinners {
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    // Setup the SQL Statement and compile it for faster access
    const char *ListTableStmt = "select * from ThinnersTable";
    
    sqlite3_stmt *ListTableCompiledStmt;
    
    if(sqlite3_prepare_v2(_DB, ListTableStmt, -1, &ListTableCompiledStmt, NULL) == SQLITE_OK) {
        
        // Loop through the results and add them to the feeds array
        while(sqlite3_step(ListTableCompiledStmt) == SQLITE_ROW)
        {
            
            char *str0 = (char *)sqlite3_column_text(ListTableCompiledStmt, 0);
            
            if (str0 != NULL) {
                
                NSString *s0 = [NSString stringWithUTF8String:str0];
                
                [list addObject:s0];
            }
            
            str0 = nil;
            
        }
        
        //NSLog(@"%d read from DB", totalRead);
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(ListTableCompiledStmt);
    ListTableCompiledStmt = nil;
    
    return list;
}

- (NSMutableArray *)readAllDisposableTubes {
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    // Setup the SQL Statement and compile it for faster access
    const char *ListTableStmt = "select * from DisposableTubesTable";
    
    sqlite3_stmt *ListTableCompiledStmt;
    
    if(sqlite3_prepare_v2(_DB, ListTableStmt, -1, &ListTableCompiledStmt, NULL) == SQLITE_OK) {
        
        // Loop through the results and add them to the feeds array
        while(sqlite3_step(ListTableCompiledStmt) == SQLITE_ROW)
        {
            
            char *str0 = (char *)sqlite3_column_text(ListTableCompiledStmt, 0);
            
            if (str0 != NULL) {
                
                NSString *s0 = [NSString stringWithUTF8String:str0];
                
                [list addObject:s0];
            }
            
            str0 = nil;
        }
        
        //NSLog(@"%d read from DB", totalRead);
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(ListTableCompiledStmt);
    ListTableCompiledStmt = nil;
    
    return list;
}

- (NSMutableArray *)readAllDisposableGrips {
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    // Setup the SQL Statement and compile it for faster access
    const char *ListTableStmt = "select * from DisposableGripsTable";
    
    sqlite3_stmt *ListTableCompiledStmt;
    
    if(sqlite3_prepare_v2(_DB, ListTableStmt, -1, &ListTableCompiledStmt, NULL) == SQLITE_OK) {
        
        // Loop through the results and add them to the feeds array
        while(sqlite3_step(ListTableCompiledStmt) == SQLITE_ROW)
        {
            
            char *str0 = (char *)sqlite3_column_text(ListTableCompiledStmt, 0);
            
            if (str0 != NULL) {
                
                NSString *s0 = [NSString stringWithUTF8String:str0];
                
                [list addObject:s0];
            }
            
            str0 = nil;
            
        }
        
        //NSLog(@"%d read from DB", totalRead);
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(ListTableCompiledStmt);
    ListTableCompiledStmt = nil;
    
    return list;
}

- (NSMutableArray *)readAllArtists
{
    // Init the Array
    NSMutableArray *artistList = [[NSMutableArray alloc] init];
    
    [artistList removeAllObjects];
    
    // Setup the SQL Statement and compile it for faster access
    const char *ArtistTableStmt = "select * from ArtistsTable";
    
    sqlite3_stmt *ArtistTableCompiledStmt;
    
    if(sqlite3_prepare_v2(_DB, ArtistTableStmt, -1, &ArtistTableCompiledStmt, NULL) == SQLITE_OK) {
        
        // Loop through the results and add them to the feeds array
        while(sqlite3_step(ArtistTableCompiledStmt) == SQLITE_ROW)
        {
            
            char *name_str = (char *)sqlite3_column_text(ArtistTableCompiledStmt, 0);
            if (name_str != NULL) {
                
                NSString *name = [NSString stringWithUTF8String:name_str];
                [artistList addObject:name];
            }
            
        }
        
        //NSLog(@"%d read from DB", totalRead);
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(ArtistTableCompiledStmt);
    
    return artistList;
}


#pragma mark - v1 settings backup
- (NSString *)CreateSettingsBackup {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    /*
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMddyyyy"];
    NSDate *date = [NSDate date];
    NSString *dateString = [dateFormat stringFromDate:date];
    */
    
    NSString *fileName = [NSString stringWithFormat:@"TRFv1.Settings_v2"];
    NSString *fileNameWithPath = [NSString stringWithFormat:@"%@/TRFv1.Settings_v2", _DocsDir];
    
    [self CreateSettingsPList];
    
    //Create zip with legal.plist, health.plist, logo, and additional form.
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    
    //Add settings.plist
    NSMutableDictionary *settingsEntry = [[NSMutableDictionary alloc] init];
    [settingsEntry setObject:@"settings.plist" forKey:@"FileName"];
    [settingsEntry setObject:_DocsDir forKey:@"Path"];
    [fileList addObject:settingsEntry];
    
    //Add artists.plist
    NSMutableDictionary *artistsEntry = [[NSMutableDictionary alloc] init];
    [artistsEntry setObject:@"artists.plist" forKey:@"FileName"];
    [artistsEntry setObject:_DocsDir forKey:@"Path"];
    [fileList addObject:artistsEntry];
    
    //Add legal.plist
    NSMutableDictionary *legalEntry = [[NSMutableDictionary alloc] init];
    [legalEntry setObject:@"Legal.plist" forKey:@"FileName"];
    [legalEntry setObject:_DocsDir forKey:@"Path"];
    [fileList addObject:legalEntry];
    
    //Add health.plist
    NSMutableDictionary *healthEntry = [[NSMutableDictionary alloc] init];
    [healthEntry setObject:@"Health.plist" forKey:@"FileName"];
    [healthEntry setObject:_DocsDir forKey:@"Path"];
    [fileList addObject:healthEntry];
    
    //Add healthitemstocheck.plist
    NSMutableDictionary *healthItemsToCheckEntry = [[NSMutableDictionary alloc] init];
    [healthItemsToCheckEntry setObject:@"HealthItemsToCheck.plist" forKey:@"FileName"];
    [healthItemsToCheckEntry setObject:_DocsDir forKey:@"Path"];
    [fileList addObject:healthItemsToCheckEntry];
    
    //Add lists.plist
    NSMutableDictionary *listEntry = [[NSMutableDictionary alloc] init];
    [listEntry setObject:@"lists.plist" forKey:@"FileName"];
    [listEntry setObject:_DocsDir forKey:@"Path"];
    [fileList addObject:listEntry];
    
    NSString *hasLogo = [defaults objectForKey:@"hasLogo"];
    
    if(hasLogo != nil && [hasLogo isEqualToString:@"Yes"]) {
        
        //Add Logo.png
        NSMutableDictionary *logoEntry = [[NSMutableDictionary alloc] init];
        [logoEntry setObject:@"logo.png" forKey:@"FileName"];
        [logoEntry setObject:_DocsDir forKey:@"Path"];
        [fileList addObject:logoEntry];
    }
    
    NSString *isUsingAdditionalForm = [defaults objectForKey:@"isUsingAdditionalForm"];
    NSString *additionalFormFileName = [defaults objectForKey:@"additionalFormFileName"];
    
    if (isUsingAdditionalForm != nil &&
        additionalFormFileName != nil &&
        [isUsingAdditionalForm isEqualToString:@"Yes"] &&
        ![additionalFormFileName isEqualToString:@""]) {
        
        //Add additional form
        NSMutableDictionary *formEntry = [[NSMutableDictionary alloc] init];
        [formEntry setObject:additionalFormFileName forKey:@"FileName"];
        [formEntry setObject:_DocsDir forKey:@"Path"];
        [fileList addObject:formEntry];
    }
    
    CompressionUtil *archiver = [[CompressionUtil alloc] init];
    
    [archiver CompressFilesFromArrayList:fileNameWithPath withFileList:fileList];
    
    return fileName;
    
}

- (void)CreateSettingsPList
{
    NSString *pListPath = [_DocsDir stringByAppendingPathComponent:@"settings.plist"];
    
    NSMutableDictionary *DefaultSettingsToSave = [[NSMutableDictionary alloc] init];
    
    [self AddSettingToDic:@"hasLogo" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"studio-name-key" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"initial-popup-enable" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"isUsingAdditionalInfo" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"forcedEmail" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"orientation-key" toDict:DefaultSettingsToSave];
    //[self AddSettingToDic:@"slideshow-album" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"isUsingAdditionalForm" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"additionalFormFileName" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"isUsingAdditionalFormPopup" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"isAppendingAdditionalForm" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"isRequiringSecondGovernmentID" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"studio-legal-name-key" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"studio-address-key" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"studio-phone-number-key" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"studio-website-key" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"studio-email-key" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"studio-codes-key" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"initial-popup-text" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"slideshow-timeout" toDict:DefaultSettingsToSave];
    [self AddSettingToDic:@"initial-popup-enable" toDict:DefaultSettingsToSave];
    
    //write new plist
    [DefaultSettingsToSave writeToFile:pListPath atomically:YES];
    
    //Create artist plist
    pListPath = [_DocsDir stringByAppendingPathComponent:@"artists.plist"];
    
    NSMutableArray *artists = [self readAllArtists];
    NSMutableDictionary *ArtistsToSave = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [artists count]; i++) {
        NSString *name = [artists objectAtIndex:i];
        
        [ArtistsToSave setObject:name forKey:[NSString stringWithFormat:@"artist %d",i]];
    }
    
    [ArtistsToSave writeToFile:pListPath atomically:YES];
    
    //Create list plist
    pListPath = [_DocsDir stringByAppendingPathComponent:@"lists.plist"];
    
    NSMutableArray *inks = [self readAllInks];
    NSMutableArray *needles = [self readAllNeedles];
    NSMutableArray *thinners = [self readAllInkThinners];
    NSMutableArray *tubes = [self readAllDisposableTubes];
    NSMutableArray *grips = [self readAllDisposableGrips];
    NSMutableDictionary *ListsToSave = [[NSMutableDictionary alloc] init];
    
    [ListsToSave setObject:inks forKey:@"Inks"];
    [ListsToSave setObject:needles forKey:@"Needles"];
    [ListsToSave setObject:thinners forKey:@"Thinners"];
    [ListsToSave setObject:tubes forKey:@"Tubes"];
    [ListsToSave setObject:grips forKey:@"Grips"];
    
    [ListsToSave writeToFile:pListPath atomically:YES];
}

- (void)AddSettingToDic:(NSString *)setting toDict:(NSMutableDictionary *)dict {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *val = [defaults objectForKey:setting];
    
    if(val != nil) {
        
        [dict setObject:val forKey:setting];
    }
    
}

- (void)ModifyHealthItemsToCheck {
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *pListPath = [documentsDir stringByAppendingPathComponent:@"HealthItemsToCheck.plist"];
    NSMutableDictionary *HealthItemsToCheckDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:pListPath];
    
    [HealthItemsToCheckDictionary removeObjectForKey:@"How long since you last ate?"];
    
    //delete current file
    NSError *error;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    [filemgr removeItemAtPath:pListPath error:&error];
    
    //write new plist
    [HealthItemsToCheckDictionary writeToFile:pListPath atomically:YES];
}

- (void)CheckSlideshowEnabled {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *slideshowtimeout = [defaults objectForKey:@"slideshow-timeout"];
    
    if (![slideshowtimeout isEqualToString:@"Slideshow Disabled"]) {
        
        [defaults setObject:@"Yes" forKey:USING_SLIDESHOW_KEY];
    }

}

@end

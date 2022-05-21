#import "PersistentStack.h"

@interface PersistentStack ()

@property (nonatomic,strong,readwrite) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) NSURL* modelURL;
@property (nonatomic,strong) NSURL* storeURL;
@property (nonatomic,strong) NSString *StoreCoordinatorName;
@property (nonatomic,strong) NSPersistentStoreCoordinator *psc;

@end

@implementation PersistentStack

@synthesize delegate;
@synthesize ubiquitousURL;

- (id)initWithStoreURL:(NSURL*)storeURL
              modelURL:(NSURL*)modelURL
  StoreCoordinatorName:(NSString *)SCName
        PStackDelegate:(id<PersistentStackDelegate>)adelegate
{
    self = [super init];
    if (self) {
        
        delegate = adelegate;
        
        self.storeURL = storeURL;
        self.modelURL = modelURL;
        self.StoreCoordinatorName = SCName;
        
        [self setupManagedObjectContext];
    }
    return self;
}

- (bool)setupManagedObjectContext
{
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    self.managedObjectContext.persistentStoreCoordinator = self.psc;
    [self.managedObjectContext setUndoManager:nil];
    
    
    NSError *error;
    [self.managedObjectContext.persistentStoreCoordinator
     addPersistentStoreWithType:NSSQLiteStoreType
     configuration:nil
     URL:self.storeURL
     options:[self GetOptions]
     error:&error];
    
    if (error) {
        NSLog(@"error setting up psc: %@", error);
        return NO;
    }
    
    return YES;

}

- (void)InitSync {
    
    if ([self IsUsingICloud]) {
        
        /*
        _CloudFileSystem = [[CDEICloudFileSystem alloc]
                            initWithUbiquityContainerIdentifier:_StoreCoordinatorName];
        
        if (_CloudFileSystem != nil) {
            
            [self StartEnsemble];
        }
        else {
            
            NSLog(@"iCloud not set up for sync, not starting ensembles");
        }
        */
        
        //[self QueryForICloudFileListing];

    }
}

- (void)StartEnsemble {
    
    /*
    _CloudFileSystem = [[CDEICloudFileSystem alloc]
                        initWithUbiquityContainerIdentifier:_StoreCoordinatorName];
    
    _Ensemble = [[CDEPersistentStoreEnsemble alloc]
                 initWithEnsembleIdentifier:[delegate GetMainStoreName]
                 persistentStoreURL:self.storeURL
                 managedObjectModelURL:self.modelURL
                 cloudFileSystem:_CloudFileSystem];
    
    _Ensemble.delegate = self;
    
    if (!_Ensemble.isLeeched) {
        
        [self LeechCoreData];
    }
    */
    
}

- (void)SyncCoreData {
    
    /*
    if (!_Ensemble) {
        
        _Ensemble = [[CDEPersistentStoreEnsemble alloc]
                     initWithEnsembleIdentifier:[delegate GetMainStoreName]
                     persistentStoreURL:_storeURL
                     managedObjectModelURL:_modelURL
                     cloudFileSystem:_CloudFileSystem];
        
        _Ensemble.delegate = self;
    }
    
    if (_Ensemble) {
        
        if (!_Ensemble.isLeeched) {
            
            [self LeechCoreData];
        }
        else {
            
            [self MergeCoreData];
        }
        
    }
    */
}

- (void)LeechCoreData {
    
    NSLog(@"Leeching ensemble now...");
    
    /*
    dispatch_async(dispatch_get_main_queue(), ^{

        
        [_Ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
            
            NSLog(@"Leech complete");
            
            if (error) {
                
                NSLog(@"Could not leech to ensemble: %@", error);
            }
            else {
                
                [self MergeCoreData];
            }
            
        }];
        
    });
    */
}

- (void)MergeCoreData {
    
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *mergeStatus = [defaults objectForKey:SYNC_MERGE_STATUS];
    
    if ([mergeStatus isEqualToString:@"Merging"]) {
        
        NSLog(@"Already merging, exiting...");
        
        return;
    }
    
    [defaults setObject:@"Merging" forKey:SYNC_MERGE_STATUS];
    
    NSLog(@"Sync merging...");
    
    [_Ensemble mergeWithCompletion:^(NSError *err){
        
        NSLog(@"Sync merge complete");
        
        if (err) {
            NSLog(@"Merge failed with error: %@", err.description);
        }
        
        [defaults setObject:@"Idle" forKey:SYNC_MERGE_STATUS];
        
        InitialDBSize = [delegate NumClientsInDB];
        
    }];
    */
}

- (void)SwitchToICloud {
    
    /*
    ubiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (!ubiquitousURL) {
        NSLog(@"iCloud not setup, cannot continue");
        return;
    }
    
    if (!_CloudFileSystem) {
        
        _CloudFileSystem = [[CDEICloudFileSystem alloc]
                            initWithUbiquityContainerIdentifier:_StoreCoordinatorName];
    }

    if (!_Ensemble) {
        
        _Ensemble = [[CDEPersistentStoreEnsemble alloc]
                     initWithEnsembleIdentifier:[delegate GetMainStoreName] persistentStoreURL:_storeURL
                     managedObjectModelURL:_modelURL
                     cloudFileSystem:_CloudFileSystem];
        
        _Ensemble.delegate = self;
    }
    
    if (!_Ensemble.isLeeched) {
        
        NSLog(@"Ensembled not leeched yet. Leeching now...");
        
        [_Ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
            
            if (error) {
                NSLog(@"Could not leech to ensemble: %@", error);
                
                if (delegate) {
                    [delegate LeechComplete:NO withMsg:error.localizedDescription];
                }
            }
            else {
                
                NSLog(@"Leech complete");
                
                //[self SyncCoreData];
                
                //[self QueryForICloudFileListing];
                
                [self StartMergeTimer:120];
                
                if (delegate) {
                    [delegate LeechComplete:YES withMsg:@""];
                }
            }

            
        }];
    }
    else {
        
        NSLog(@"Already leeched complete");
        
        //[self SyncCoreData];
        
        //[self QueryForICloudFileListing];
        
        [self StartMergeTimer:120];
        
        if (delegate) {
            [delegate LeechComplete:YES withMsg:@""];
        }
    }

    //[self StartEnsemble];
    */
    
}

- (void)StartMergeTimer:(NSUInteger)PeriodInSec {
    
    /*
    if (!_MergeTimer) {
        
        _MergeTimer = [NSTimer scheduledTimerWithTimeInterval:PeriodInSec target:self selector:@selector(MergeTimerExceeded) userInfo:nil repeats:YES];
    }
    */
    
}

- (void)MergeTimerExceeded
{
    //[self MergeCoreData];
}

- (void)StopMergeTimer {
    
    if (_MergeTimer) {
        
        [_MergeTimer invalidate];
    
        _MergeTimer = nil;
    }
    
}

- (void)TransferImgsToUbiquitous {
    
    //Copy images
    NSURL *icloudImgs = [Utilities UbiquityImgsURLForContainer:nil];
    
    NSLog(@"ubiquitous folder: %@", icloudImgs.path);
    
    BOOL isDir = YES;
    NSError *error = nil;
    
    //Check and create ubiquitous folder
    if (![[NSFileManager defaultManager] fileExistsAtPath:icloudImgs.path isDirectory:&isDir]) {
        
        
        
        if (![[NSFileManager defaultManager]
              createDirectoryAtPath:icloudImgs.path
              withIntermediateDirectories:YES
              attributes:nil error:&error])
        {
            NSLog(@"Error creating ubiquitous folder: %@", error.localizedFailureReason);
            return;
        }
        
    }
    
    //Copy images to ubiquitous folder
    NSString *imgsDir = [Utilities GetImgsDirectory];
    
    NSArray *imgsList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imgsDir error:&error];
    
    if (error != nil) {
        
        NSLog(@"Error getting imgs list: %@", error.localizedDescription);
        
        if (delegate) {
            [delegate ImgTransferToUbiquitousComplete:YES];
        }
        
        return;
    }
    
    imgsDir = [NSString stringWithFormat:@"file://%@", imgsDir];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *err = nil;
        
        for (NSString *filename in imgsList) {
            
            NSURL *sourceURL = [[NSURL URLWithString:imgsDir] URLByAppendingPathComponent:filename];
            
            NSURL *destinationURL = [icloudImgs URLByAppendingPathComponent:filename];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:destinationURL.path]) {
                
                [[NSFileManager defaultManager] setUbiquitous:YES
                                                    itemAtURL:sourceURL
                                               destinationURL:destinationURL
                                                        error:&err];
            }
            else {
                
                NSLog(@"Image already exists in ubiquitous folder: %@", filename);
            }
            
            
            if (err != nil) {
                
                NSLog(@"Error copying images to icloud: %@", err.localizedDescription);
            }
            
        }
        
        NSLog(@"iCloud img transfer complete");
        
        if (delegate) {
            [delegate ImgTransferToUbiquitousComplete:YES];
        }
        
    });

}

- (void)SwitchToLocal {
    
    /*
    if (_MergeTimer) {
        
        [_MergeTimer invalidate];
        
        _MergeTimer = nil;
    }
    
    if (!_Ensemble) {
        
        _Ensemble = [[CDEPersistentStoreEnsemble alloc]
                     initWithEnsembleIdentifier:[delegate GetMainStoreName]
                     persistentStoreURL:_storeURL
                     managedObjectModelURL:_modelURL
                     cloudFileSystem:_CloudFileSystem];
        
        _Ensemble.delegate = self;
    }
    
    if (_Ensemble.isLeeched) {
        
        NSLog(@"Ensembled is leeched. Deleeching now...");
        
        [_Ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
            
            NSLog(@"Deleech complete");
            
            if (error)
            {
                NSLog(@"Could not deleech ensemble: %@", error);
                
                if (delegate) {
                    [delegate DeleechComplete:NO withMsg:error.localizedDescription];
                }
            }
            else
            {
                [_Ensemble dismantle];
                
                if (delegate) {
                    [delegate DeleechComplete:YES withMsg:@""];
                }
            }
            
            
        }];
    }
    else {
     
        //Note: For testing
        NSLog(@"Already deleeched");
        if (delegate) {
            [delegate DeleechComplete:YES withMsg:@""];
        }
        
    }

    _CloudFileSystem = nil;
    */
}

- (void)TransferImgsFromUbiquitous {
    
    /*
    [delegate ImageTransferStart:NO];
    
    NSError *error = nil;
    
    ubiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (!ubiquitousURL) {
        NSLog(@"iCloud not setup, cannot continue");
        
        if (delegate) {
            [delegate ImgTransferFromUbiquitousComplete:YES];
        }
        
        return;
    }
    
    //Move images back to images dir
    //Copy images to ubiquitous folder
    NSString *imgsDir = [Utilities GetImgsDirectory];
    
    NSURL *icloudImgs = [Utilities UbiquityImgsURLForContainer:nil];
    
    NSLog(@"ubiquitous folder: %@", icloudImgs.path);
    
    NSArray *imgsList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:icloudImgs.path error:&error];
    
    if (error != nil) {
        
        NSLog(@"Error getting ubiquitous imgs list: %@", error.localizedDescription);
        
        if (delegate) {
            [delegate ImgTransferFromUbiquitousComplete:YES];
        }
        
        return;
    }
    
    imgsDir = [NSString stringWithFormat:@"file://%@", imgsDir];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *err = nil;
        
        float numfiles = (float)[imgsList count];
        float count = 0.0f;
        
        for (NSString *filename in imgsList) {
            
            count += 1.0;
            
            @autoreleasepool {
                
                NSRange extrange = [filename rangeOfString:@".icloud"];
                
                NSString *fn = filename;
                
                if (extrange.location != NSNotFound) {
                    
                    fn = [fn substringToIndex:extrange.location];
                    fn = [fn substringFromIndex:1];
                    
                }
                
                NSURL *destinationURL = [[NSURL URLWithString:imgsDir] URLByAppendingPathComponent:fn];
                
                NSURL *sourceURL = [icloudImgs URLByAppendingPathComponent:fn];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:destinationURL.path]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        @autoreleasepool {
                            
                            NSData *sourceimg = [self ReadEncLocalImageData:sourceURL.path];
                            [sourceimg writeToFile:destinationURL.path atomically:NO];
                            [delegate TransferFromUbiquitousProgress:(count / numfiles)];
                        }
                        

                    
                    });
                    
                }
                else {
                    
                    NSLog(@"Image already exists in Imgs folder: %@", filename);
                }
                
                
                if (err != nil) {
                    
                    NSLog(@"Error copying images from icloud: %@", err.localizedDescription);
                }

            }
            
            
        }
        
        [delegate ImageTransferComplete:NO];
        
        NSLog(@"iCloud img transfer complete");
        
        if (delegate) {
            [delegate ImgTransferFromUbiquitousComplete:YES];
        }
        
    });
     
    */

}

- (void)QueryForICloudFileListing {
    
    /*
    NSLog(@"Querying for icloud file listing");
    
    if (_DataQuery == nil) {
        
        _DataQuery = [[NSMetadataQuery alloc] init];
        [_DataQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE '*'", NSMetadataItemFSNameKey]];
        [_DataQuery setSearchScopes:[NSArray
                                     arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope,
                                     nil]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(queryDidUpdateNotification:)
                                                     name:NSMetadataQueryDidUpdateNotification
                                                   object:_DataQuery];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(queryDidStartNotification:)
                                                     name:NSMetadataQueryDidStartGatheringNotification
                                                   object:_DataQuery];
        

    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
     
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(queryDidFinishNotification:)
                                                     name:NSMetadataQueryDidFinishGatheringNotification
                                                   object:_DataQuery];
        
        if (![_DataQuery startQuery]) {
            
            NSLog(@"Querying for icloud file listing failed");
        }
        
    });
    
     */
    
}

- (void)queryDidStartNotification:(NSNotification *)notification {
    
    NSLog(@"Starting icloud file listing query");
}

- (void)queryDidUpdateNotification:(NSNotification *)notification {
    
    /*
    NSLog(@"Updated icloud file listing query");
    
    // Stop the query, the single pass is completed.
    [_DataQuery stopQuery];
    
    NSLog(@"Number of Files on iCloud: %d", [_DataQuery resultCount]);
    
    NSString *ImgsPath = [Utilities GetImagesPath];
    NSUInteger ImgsCount = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:ImgsPath error:nil] count];
    
    NSUInteger DBSize = [delegate NumClientsInDB];
    
    NSLog(@"Number of Clients in DB: %d, Num Imgs Locally: %d", DBSize, ImgsCount);
 
    //Merge Ensembles
    [self SyncCoreData];
    */
}

- (void)queryDidFinishNotification:(NSNotification *)notification {
    
    /*
    NSLog(@"Finished icloud file listing query");
    
    // Stop the query, the single pass is completed.
    [_DataQuery stopQuery];
    
    NSLog(@"Number of Files on iCloud: %d", [_DataQuery resultCount]);
    
    NSString *ImgsPath = [Utilities GetImagesPath];
    NSUInteger ImgsCount = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:ImgsPath error:nil] count];
    
    NSUInteger DBSize = [delegate NumClientsInDB];
    
    NSLog(@"Number of Clients in DB: %d, Num Imgs Locally: %d", DBSize, ImgsCount);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:_DataQuery];
    
    //Finished, now only listen for updates
    [_DataQuery startQuery];
    
    NSLog(@"DB has not yet sync'd. Sync'ing again and leaving file query active...");
    [self SyncCoreData];
    */
}

- (void)DisableICloudFileQuery {
    
    /*
    if (_DataQuery) {
        
        [_DataQuery stopQuery];
        
        NSLog(@"iCould file query disabled");
    }
    */
}

- (void)EnableICloudFileQuery {
    
    /*
    if (_DataQuery) {
        
        [_DataQuery startQuery];
        
        NSLog(@"iCould file query enabled");
    }
    */
}

- (BOOL)downloadFileIfNotAvailable:(NSURL*)file {
    /*
    NSNumber*  isIniCloud = nil;
    
    if ([file getResourceValue:&isIniCloud forKey:NSURLIsUbiquitousItemKey error:nil]) {
        // If the item is in iCloud, see if it is downloaded.
        if ([isIniCloud boolValue]) {
            NSNumber*  isDownloaded = nil;
            if ([file getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemIsDownloadedKey error:nil]) {
                if ([isDownloaded boolValue])
                    return NO;
                
                // Download the file.
                NSFileManager*  fm = [NSFileManager defaultManager];
                NSError *downloadError = nil;
                [fm startDownloadingUbiquitousItemAtURL:file error:&downloadError];
                if (downloadError) {
                    NSLog(@"Error occurred starting download: %@", downloadError);
                }
                return YES;
            }
        }
    }
    */
    
    // Return YES as long as an explicit download was not started.
    return NO;
}

- (void)reloadStore:(NSPersistentStore *)store {
    
    if (store) {
        [self.psc removePersistentStore:store error:nil];
    }
    
    [self.psc addPersistentStoreWithType:NSSQLiteStoreType
                       configuration:nil
                                 URL:self.storeURL
                             options:[self GetOptions]
                               error:nil];
}

- (void)ReloadStore {
    
    //[self reloadStore:self.psc.persistentStores[0]];
    
    [self SyncCoreData];
}

- (bool)IsUsingICloud {
    
    /*
    NSString *isUsingSync = [[NSUserDefaults standardUserDefaults] objectForKey:USING_DEVICE_SYNC_KEY];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    
    if (isUsingSync != nil && [isUsingSync isEqualToString:@"Yes"] && cloudURL != nil) {
        
        return YES;
        
    }
    else {
        
        if (isUsingSync != nil && [isUsingSync isEqualToString:@"Yes"]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:@"No" forKey:USING_DEVICE_SYNC_KEY];
        }
        
        return NO;
        
    }
    */
    
    return NO;
    
}

- (NSURL *)GetCurrentURL {
    
    return [self.psc URLForPersistentStore:[[self.psc persistentStores] firstObject]];
}

- (NSDictionary *)GetOptions {
    
    return [self storeOptions];
}

- (NSDictionary*)storeOptions {
    
    /*
    return @{NSMigratePersistentStoresAutomaticallyOption:@YES,
             NSInferMappingModelAutomaticallyOption:@YES,
             NSSQLitePragmasOption:@{ @"journal_mode" : @"DELETE", @"cache_size" : @"50" }};
     */
    
    return @{NSMigratePersistentStoresAutomaticallyOption:@YES,
             NSInferMappingModelAutomaticallyOption:@YES,
             NSSQLitePragmasOption:@{ @"journal_mode" : @"DELETE"}};
}

- (NSDictionary*)iCloudOptions {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    
    return @{NSPersistentStoreUbiquitousContentURLKey:cloudURL,
             NSPersistentStoreUbiquitousContentNameKey:self.StoreCoordinatorName,
             NSMigratePersistentStoresAutomaticallyOption:@YES,
             NSInferMappingModelAutomaticallyOption:@YES,
             NSSQLitePragmasOption:@{ @"journal_mode" : @"DELETE" }};
}

- (void)BackupStore:(NSURL *)BackupURL {
    
    // assuming you only have one store.
    NSPersistentStore *store = [[self.psc persistentStores] firstObject];
    
    NSMutableDictionary *localStoreOptions = [[self storeOptions] mutableCopy];
    
    [self.psc migratePersistentStore:store
                           toURL:BackupURL
                         options:localStoreOptions
                        withType:NSSQLiteStoreType error:nil];
}

- (void)LoadFromBackup:(NSURL *)BackupURL {
    
    NSError *error;
    
    if ([self.psc persistentStoreForURL:BackupURL]) {
        
        NSLog(@"Backup store already in coordinator. Removing now...");
        [self.psc removePersistentStore:[self.psc persistentStoreForURL:BackupURL] error:&error];
    }
    
    NSPersistentStore *BackupPS = [self.psc addPersistentStoreWithType:NSSQLiteStoreType
                                                     configuration:nil
                                                               URL:BackupURL
                                                           options:[self storeOptions]
                                                             error:&error];
    
    if (BackupPS == nil) {

        NSLog(@"LoadFromBackup Unresolved error %@, %@", error, [error userInfo]);
        
        abort();
    }
    
    NSString *isUsingSync = [[NSUserDefaults standardUserDefaults] objectForKey:USING_DEVICE_SYNC_KEY];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    
    NSDictionary *options = nil;
    
    if (isUsingSync != nil && [isUsingSync isEqualToString:@"Yes"] && cloudURL != nil) {
        
        options = [self iCloudOptions];
        
    }
    else {
        
        if (isUsingSync != nil && [isUsingSync isEqualToString:@"Yes"]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:@"No" forKey:USING_DEVICE_SYNC_KEY];
        }
        
        options = [self storeOptions];
        
    }
    
    
    [self.psc migratePersistentStore:BackupPS
                               toURL:self.storeURL
                             options:options
                            withType:NSSQLiteStoreType error:nil];
    
    //cleanup
    [self.psc removePersistentStore:BackupPS error:&error];
    BackupPS = nil;
 
    [self saveContext];
}

- (void)EnableNotifications:(NSPersistentStoreCoordinator *)psc {
    
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(storesWillChange:)
               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
             object:psc];
    
    [dc addObserver:self
           selector:@selector(storesDidChange:)
               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
             object:psc];
    
    [dc addObserver:self
           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object:psc];
}

- (void)DisableNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                  object:nil];
}

- (NSManagedObjectModel*)managedObjectModel
{
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}

// Subscribe to NSPersistentStoreDidImportUbiquitousContentChangesNotification
- (void)persistentStoreDidImportUbiquitousContentChanges:(NSNotification*)note
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    //NSLog(@"%@", note.userInfo.description);
    NSLog(@"Imported more data from icloud");
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:note];
        
        // you may want to post a notification here so that which ever part of your app
        // needs to can react appropriately to what was merged. 
        // An exmaple of how to iterate over what was merged follows, although I wouldn't
        // recommend doing it here. Better handle it in a delegate or use notifications.
        // Note that the notification contains NSManagedObjectIDs
        // and not NSManagedObjects.
        NSDictionary *changes = note.userInfo;
        NSMutableSet *allChanges = [NSMutableSet new];
        [allChanges unionSet:changes[NSInsertedObjectsKey]];
        [allChanges unionSet:changes[NSUpdatedObjectsKey]];
        [allChanges unionSet:changes[NSDeletedObjectsKey]];
        
        for (NSManagedObjectID *objID in allChanges) {
            // do whatever you need to with the NSManagedObjectID
            // you can retrieve the object from with [moc objectWithID:objID]
        }
        
        if (delegate) {
            [delegate iCloudInsertedObjects:changes[NSInsertedObjectsKey]];
        }

    }];
}

// Subscribe to NSPersistentStoreCoordinatorStoresWillChangeNotification
// most likely to be called if the user enables / disables iCloud 
// (either globally, or just for your app) or if the user changes
// iCloud accounts.
- (void)storesWillChange:(NSNotification *)note {
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlockAndWait:^{
        [self saveContext];
        
        [moc reset];
    }];
    
    // now reset your UI to be prepared for a totally different
    // set of data (eg, popToRootViewControllerAnimated:)
    // but don't load any new data yet.
}

// Subscribe to NSPersistentStoreCoordinatorStoresDidChangeNotification
- (void)storesDidChange:(NSNotification *)note {
    // here is when you can refresh your UI and
    // load new data from the new store
}

- (NSPersistentStoreCoordinator *)psc {
    @synchronized(self) {
        
        if (_psc != nil) {
            return _psc;
        }
        
        _psc = [[NSPersistentStoreCoordinator alloc]
                initWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL]];
        
        return _psc;
    }
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *moc = self.managedObjectContext;
    if (moc != nil) {
        NSError *error = nil;
        if ([moc hasChanges] && ![moc save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"saveContext Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
    }
}

/*
#pragma mark - 

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble
didSaveMergeChangesWithNotification:(NSNotification *)notification {
    
    [_managedObjectContext performBlock:^{
        
        [_managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        
    }];
}

- (NSArray *)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble
  globalIdentifiersForManagedObjects:(NSArray *)objects {
    
    return [objects valueForKeyPath:@"dataKey"];
    
}
*/
- (void)dealloc {
    
    NSLog(@"Persistent stack dealloc");
}

- (NSData *)ReadEncLocalImageData:(NSString *)fullpath {
    
    NSError *error = nil;
    
    if ([Utilities IsUsingDataSync]) {
        
        //Attempt to download the file
        NSURL *icloudfn = [Utilities UbiquityImgsURLForContainer:nil];
        icloudfn = [icloudfn URLByAppendingPathComponent:[fullpath lastPathComponent]];
        
        __block NSData *data = nil;
        NSError *error = nil;
        NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [coordinator coordinateReadingItemAtURL:icloudfn options:0 error:&error byAccessor:^(NSURL *newURL) {
            data = [NSData dataWithContentsOfURL:newURL];

        }];
        
        if (data) {
            
            NSLog(@"File downloaded from icloud: %@", icloudfn);
            
            return data;
        }
        
        if (error || data == nil) {
            
            
            if (error) {
                
                NSLog(@"Downloading from icloud error: %@", error.localizedDescription);
            }
            
            
            if (!data) {
                
                NSLog(@"Image data is nil");
            }
            
            NSLog(@"Returning dummy image instead");
            NSData *dummy = nil;
            //dummy = [[NSData alloc] initWithBytes:0 length:100];
            dummy = [NSData dataWithBytes:(unsigned char[]){0x00} length:100];
            
            return dummy;
        }
        
    }
    
    NSData *encryptedimg = [NSData dataWithContentsOfFile:fullpath
                                                  options:NSDataReadingUncached
                                                    error:&error];
    
    if (error) {
        NSLog(@"ReadLocalImageData error: %@", error.localizedDescription);
        
        return [[NSData alloc] initWithBytes:0 length:100];
    }
    
    return encryptedimg;
    
}

@end

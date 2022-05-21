@import Foundation;
@import CoreData;

//#import <Ensembles/Ensembles.h>
#import "Utilities.h"

@protocol PersistentStackDelegate <NSObject>
@optional
- (void)iCloudInsertedObjects:(NSSet *)setOfObjects;
- (NSString *)GetMainStoreName;

- (void)LeechComplete:(bool)Success withMsg:(NSString *)msg;
- (void)ImgTransferToUbiquitousComplete:(bool)Success;
- (void)DeleechComplete:(bool)Success withMsg:(NSString *)msg;
- (void)ImgTransferFromUbiquitousComplete:(bool)Success;

- (void)ImageTransferStart:(bool)ToUbiquitous;
- (void)ImageTransferComplete:(bool)ToUbiquitous;

- (NSUInteger)NumClientsInDB;

- (void)TransferFromUbiquitousProgress:(float)progress;

@end

@interface PersistentStack : NSObject
{
    NSPersistentStoreCoordinator *_psc;
    
    //CDEICloudFileSystem *_CloudFileSystem;
    //CDEPersistentStoreEnsemble *_Ensemble;
    
    NSMetadataQuery *_DataQuery;
    
    NSInteger InitialDBSize;
    
    NSTimer *_MergeTimer;
    
}

- (id)initWithStoreURL:(NSURL*)storeURL
              modelURL:(NSURL*)modelURL
  StoreCoordinatorName:(NSString *)SCName
        PStackDelegate:(id<PersistentStackDelegate>)adelegate;

- (void)saveContext;
- (void)SwitchToICloud;
- (void)TransferImgsToUbiquitous;
- (void)SwitchToLocal;
- (void)TransferImgsFromUbiquitous;
- (void)ReloadStore;
- (void)BackupStore:(NSURL *)BackupURL;
- (void)LoadFromBackup:(NSURL *)BackupURL;
- (bool)IsUsingICloud;
- (NSURL *)GetCurrentURL;

- (void)SyncCoreData;
- (void)InitSync;

//- (void)EnableICloudFileQuery;
 - (void)DisableICloudFileQuery;
//- (void)QueryForICloudFileListing;

- (void)StartMergeTimer:(NSUInteger)PeriodInSec;
- (void)StopMergeTimer;

@property (weak) id<PersistentStackDelegate>delegate;
@property (nonatomic,strong,readonly) NSManagedObjectContext *managedObjectContext;
@property (strong) NSURL *ubiquitousURL;

@end

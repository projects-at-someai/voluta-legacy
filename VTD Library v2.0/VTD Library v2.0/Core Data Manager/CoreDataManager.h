//
//  CoreDataManager.h
//  LRF
//
//  Created by Francis Bowen on 6/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataExporters.h"
#import "Utilities.h"
#import "PersistentStack.h"
#import "VTDCrypto.h"
#import "CompressionUtil.h"
#import "FormDataManager.h"

#define CLIENTINFO_ENTITY_NAME @"ClientInformation"
#define CLIENTIMGS_ENTITY_NAME @"ClientImages"
#define SUPPORTINGDOCUMENTS_ENTITY_NAME @"SupportingDocuments"
#define SESSIONFINANCIALS_ENTITY_NAME @"SessionFinancials"
#define SPECIALISTINFO_ENTITY_NAME @"SpecialistInformation"
#define EXTRADATA_ENTITY_NAME @"ExtraData"
#define PENDINGUPLOADS_ENTITY_NAME @"PendingUploads"
#define SAVEFORLATER_ENTITY_NAME @"SaveForLater"

@protocol CoreDataManagerDatasource <NSObject>
- (NSString *)GetICloudStoreContainer;
- (NSString *)GetAppID;

@end

@protocol DataSyncDelegate <NSObject>

- (void)SyncStatusUpdate:(NSString *)msg
        withEnablingFlag:(bool)isEnabling
        withCompleteFlag:(bool)isComplete;

- (void)ImageTransferStart:(bool)ToUbiquitous;
- (void)ImageTransferComplete:(bool)ToUbiquitous;

//- (void)ReceivediCloudListToDownload:(NSArray *)iCloudURLList;

- (void)TransferFromUbiquitousProgress:(float)progress;

@end

@protocol FormLoadDelegate <NSObject>

- (void)LoadFormComplete;

@end

@interface CoreDataManager : NSObject <DataExportersDatasource, PersistentStackDelegate>
{
    PersistentStack *_PersistentStack;
    DataExporters *_DataExporters;
    NSURL *_StoreURL;
    NSURL *_ModelURL;
    VTDCrypto *_VTDCrypto;
    CompressionUtil *_VTDCompression;
}

- (id)initWithDatasource:(id<CoreDataManagerDatasource>)adatasource;

//Form Utilities
- (void)SaveForm:(FormDataManager *)FormData;
- (NSArray *)FindForms:(NSString *)TextToSearch;
- (bool)DoesFormExistWithFirstName:(NSString *)FirstName
                      withLastName:(NSString *)LastName
                          withDate:(NSString *)Date;
- (FormDataManager *)LoadFormFromClientInfo:(NSDictionary *)ClientInfo;


- (void)SaveClient:(NSDictionary *)ClientData;
- (void)ClearContext;
- (void)InvalidateManagedObject:(NSManagedObject *)MObj;

- (NSArray *)SearchForClient:(NSString *)TextToSearch;

- (NSManagedObject *)GetClient:(NSString *)FirstName
                  withLastName:(NSString *)LastName
                      withDate:(NSString *)Date;

- (void)RemoveForms:(NSArray *)Indices;
- (NSUInteger)RemoveDuplicates;

//Pending uploads
- (void)AddPendingUpload:(NSString *)FirstName
            withLastName:(NSString *)LastName
                withDate:(NSString *)Date
                 withDoB:(NSString *)DateOfBirth;

- (NSUInteger)NumPendingUploads;

- (void)RemovePendingUpload:(NSString *)FirstName
               withLastName:(NSString *)LastName
                   withDate:(NSString *)Date
                    withDoB:(NSString *)DateOfBirth;

- (NSArray *)GetListofPendingUploads;

//Save for later
- (void)AddSaveForLater:(NSString *)FirstName
           withLastName:(NSString *)LastName
               withDate:(NSString *)Date
                withDoB:(NSString *)DateOfBirth;

- (NSUInteger)NumSaveForLater;

- (void)RemoveSaveForLater:(NSString *)FirstName
              withLastName:(NSString *)LastName
                  withDate:(NSString *)Date
                   withDoB:(NSString *)DateOfBirth;

- (NSArray *)GetListofSaveForLater;     //array of dictionaries
- (NSArray *)GetSearchableSaveForLater; //array of strings
- (NSArray *)GetSearchResults:(NSArray *)searchableresults; //subset array of dictionaries

//Data export utilities
- (NSString *)ExportClientList:(NSString *)AppName;
- (NSString *)ExportAllFinancial:(NSString *)AppName;
- (NSString *)ExportDateRangeFinancial:(NSString *)AppName
                         withStartDate:(NSDate *)StartDate
                           withEndDate:(NSDate *)EndDate;
- (NSString *)ExportDateRangeAndEmployeeFinancial:(NSString *)AppName
                                    withStartDate:(NSDate *)StartDate
                                      withEndDate:(NSDate *)EndDate
                                 withEmployeeName:(NSString *)EmployeeName;
- (NSString *)ExportEmployeeFinancials:(NSString *)AppName
                      withEmployeeName:(NSString *)EmployeeName;

//Backup / Restore utilities
- (NSString *)CreateBackup;
- (void)RestoreBackupCoreData:(NSString *)BackupStore;

//Data syncing options
- (void)SwitchToICloud;
- (void)SwitchToLocal;
- (void)ReloadStore;
- (bool)IsUsingICloud;
- (void)InitSync;
- (void)SyncCoreData;

//- (void)EnableICloudFileQuery;
- (void)DisableICloudFileQuery;
//- (void)QueryForICloudFileListing;

- (void)StartMergeTimer:(NSUInteger)PeriodInSec;
- (void)StopMergeTimer;

//Extract images
- (void)ExtractAllImages:(NSString *)DestDir;

@property (weak) id <CoreDataManagerDatasource> datasource;
@property (weak) id <DataSyncDelegate> dsyncdelegate;
@property (weak) id <FormLoadDelegate> formloaddelegate;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

//
//  CloudServiceManager.h
//  LRF
//
//  Created by Francis Bowen on 6/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileUploader.h"
#import "FileDownloader.h"
#import "CloudFileListManager.h"
#import "PendingUploader.h"

@protocol CloudServiceDelegate
@optional
- (NSString *)GetAppFolderName;

- (NSString *)GetBoxClientID;
- (NSString *)GetBoxClientSecret;

- (NSString *)GetDropboxClientID;
- (NSString *)GetDropboxClientSecret;

- (NSString *)GetGoogleDriveClientID;
- (NSString *)GetGoogleDriveClientSecret;

- (NSString *)GetOneDriveClientID;

- (void)SetAuthorizationFlow:(id<OIDExternalUserAgentSession>)CurrentFlow;

@end

@protocol CloudServiceUploadDelegate
@optional
- (void)FileUploadComplete:(bool)UploadSuccessful;
@end

@protocol CloudServiceDownloadDelegate
@optional
- (void)FileDownloadComplete:(bool)DownloadSuccessful;
@end

@protocol CloudServicePendingUploadDelegate
@optional
- (void)PendingUploadComplete:(bool)UploadSuccessful;
- (void)PendingUploadProgress:(NSUInteger)CurrentPendingNum withTotal:(NSUInteger)TotalToUpload;

- (CoreDataManager *)GetCoreDataManager;
- (NSString *)GetTempPath;

@end

@protocol CloudServicePDFDelegate
@optional

- (NSArray *)GetAllergies;
- (NSArray *)GetDiseases;
- (NSArray *)GetHealthConditions;
- (NSDictionary *)HealthAnswers;

- (NSArray *)LegalItems;
- (NSArray *)RulesItems;

@end

@protocol CloudServiceUploadProgressDelegate
@optional
- (void)FileUploadProgress:(CGFloat)amount;
@end

@protocol CloudServiceDownloadProgressDelegate
@optional
- (void)FileDownloadProgress:(CGFloat)amount;
@end

@protocol CloudServiceFileListDelegate
@required
- (void)FileListReady:(bool)Success withFileList:(NSArray *)FileList;
@end

@protocol CloudServicePDFListDelegate
@required
- (void)PDFListReady:(bool)Success
        withFileList:(NSArray *)FileList
    fromCloudService:(NSString *)CloudService;
@end

@protocol CloudServiceLinkDelegate
@required
- (void)CloudServiceLinked:(BOOL)success withServiceName:(NSString *)ServiceName;
@end

@interface CloudServiceManager : NSObject <
    FileUploaderDelegate,
    FileUploaderServicesDatasource,
    GoogleDriveDelegate,
    OneDriveAuthDelegate,
    BoxAuthDelegate,
    EnabledServicesDatasource,
    CloudFileListingDelegate,
    FileDownloaderDelegate,
    DropboxDelegate,
    FileUploaderProgressDelegate,
    FileDownloaderProgressDelegate,
    PendingUploaderDelegate
>
{
    Dropbox *_Dropbox;
    GoogleDrive *_GoogleDrive;
    OneDrive *_OneDrive;
    Box *_Box;

    FileUploader *_FileUploader;
    FileDownloader *_FileDownloader;
    PendingUploader *_PendingUploader;
    
    CloudFileListManager *_FileListManager;
    
    NSMutableDictionary *_EnabledServices;
    
    NSString *_DownloadingService;

    bool _GettingPDFs;
    NSString *_CurrentCloudService;
}

@property (weak) id <CloudServiceDelegate> delegate;
@property (weak) id <CloudServiceUploadDelegate> uploadDelegate;
@property (weak) id <CloudServicePendingUploadDelegate> pendingDelegate;
@property (weak) id <CloudServiceDownloadDelegate> downloadDelegate;
@property (weak) id <CloudServiceUploadProgressDelegate> uploadProgressDelegate;
@property (weak) id <CloudServiceDownloadProgressDelegate> downloadProgressDelegate;
@property (weak) id <CloudServiceFileListDelegate> fileListDelegate;
@property (weak) id <CloudServicePDFListDelegate> pdfListDelegate;
@property (weak) id <CloudServiceLinkDelegate> linkDelegate;
@property (weak) id <CloudServicePDFDelegate> pdfDelegate;

- (id)initWithEnableList:(NSDictionary *)EnabledServices
            withDelegate:(id<CloudServiceDelegate>)adelegate;

- (void)UploadFile:(NSString *)Filename withFilepath:(NSString *)Filepath;
- (void)UploadFileAndReplace:(NSString *)Filename withFilepath:(NSString *)Filepath;
- (void)DownloadFile:(NSString *)CloudFileName
              toDest:(NSString *)DestPath
         fromService:(NSString *)Service;

- (void)CancelUpload;
- (void)CancelDownload;

- (void)UploadPendingForms:(NSArray *)PendingFormsList;

- (BOOL)HasAtLeastOneServiceEnabled;

- (NSArray *)ListOfEnabledServices;

- (void)GetFileListing:(NSString *)Service;

- (void)GetPDFList;

- (void)SetServiceState:(NSString *)Service withState:(NSString *)State;

//Dropbox
- (void)LinkDropbox:(UIViewController *)VC;
- (void)UnlinkDropbox;
- (BOOL)isDropboxAuthorized;
- (BOOL)isDropboxLinked;
- (BOOL)DropboxHandleOpenURL:(NSURL *)url;
- (void)SignalDropboxLinked:(BOOL)success;

//Google Drive
- (BOOL)isGoogleDriveAuthorized;
- (void)LinkGoogleDrive:(UIViewController *)ParentView;
- (void)UnlinkGoogleDrive;
- (void)CheckForExpiredGoogleDriveToken;

//OneDrive
- (BOOL)isOneDriveAuthorized;
- (void)LinkOneDrive:(UIViewController *)ParentView;
- (void)UnlinkOneDrive;

//Box
- (BOOL)isBoxAuthorized;
- (void)LinkBox;
- (void)UnlinkBox;

@end

//
//  CloudServiceManager.m
//  LRF
//
//  Created by Francis Bowen on 6/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "CloudServiceManager.h"

@implementation CloudServiceManager

@synthesize delegate;
@synthesize uploadDelegate;
@synthesize downloadDelegate;
@synthesize fileListDelegate;
@synthesize linkDelegate;
@synthesize uploadProgressDelegate;
@synthesize downloadProgressDelegate;
@synthesize pendingDelegate;
@synthesize pdfDelegate;
@synthesize pdfListDelegate;

- (id)initWithEnableList:(NSDictionary *)EnabledServices
            withDelegate:(id<CloudServiceDelegate>)adelegate {
    
    self = [super init];
    
    if (self) {
        
        delegate = adelegate;
        
        _Dropbox = [[Dropbox alloc] init];
        _Dropbox.delegate = self;
        [_Dropbox initDropbox];
        
        _GoogleDrive = [[GoogleDrive alloc] init];
        _GoogleDrive.delegate = self;
        [_GoogleDrive initGoogleDrive];
        
        _OneDrive = [[OneDrive alloc] init];
        _OneDrive.authDelegate = self;
        [_OneDrive initOneDrive];
        
        _Box = [[Box alloc] init];
        _Box.authDelegate = self;
        [_Box initBox];
        
        _EnabledServices = [EnabledServices mutableCopy];
        
        _FileListManager = [[CloudFileListManager alloc] initWithDelegate:self];

        _GettingPDFs = NO;
    }
    
    return self;
}

- (void)UploadFile:(NSString *)Filename withFilepath:(NSString *)Filepath {
    
    if (_FileUploader == nil) {
        _FileUploader = [[FileUploader alloc] init];
        _FileUploader.servicesDatasource = self;
        _FileUploader.enabledServicesDatasource = self;
        _FileUploader.progressDelegate = self;
    }
    
    _FileUploader.delegate = self;
    
    NSString *FilenameAndPath = [NSString stringWithFormat:@"%@/%@",Filepath,Filename];
    
    [_FileUploader UploadFile:Filename withFullPath:FilenameAndPath];
}

- (void)UploadFileAndReplace:(NSString *)Filename withFilepath:(NSString *)Filepath {
    
    if (_FileUploader == nil) {
        _FileUploader = [[FileUploader alloc] init];
        _FileUploader.servicesDatasource = self;
        _FileUploader.enabledServicesDatasource = self;
        _FileUploader.progressDelegate = self;
    }
    
    _FileUploader.delegate = self;
    
    NSString *FilenameAndPath = [NSString stringWithFormat:@"%@/%@",Filepath,Filename];
    
    [_FileUploader UploadFileAndReplace:Filename withFullPath:FilenameAndPath];
}

- (void)UploadPendingForms:(NSArray *)PendingFormsList {
    
    if (_PendingUploader == nil) {
        
        _PendingUploader = [[PendingUploader alloc] init];
        _PendingUploader.delegate = self;
    }
    
    [_PendingUploader UploadPendingForms:PendingFormsList];
    
}

- (void)CancelUpload {

    if (_FileUploader != nil) {
        
        [_FileUploader CancelCurrentUpload];
    }
}

- (void)DownloadFile:(NSString *)CloudFileName
              toDest:(NSString *)DestPath
         fromService:(NSString *)Service {
    
    if (_FileDownloader == nil) {
        
        _FileDownloader = [[FileDownloader alloc] initWithDelegate:self];
        _FileDownloader.progressDelegate = self;
    }
    
    _DownloadingService = Service;
    [_FileDownloader DownloadFile:CloudFileName toDest:DestPath fromService:Service];
    
}

- (void)CancelDownload {
    
    if (_FileDownloader != nil) {
        
        [_FileDownloader CancelDownload:_DownloadingService];
    }
}

- (void)GetFileListing:(NSString *)Service {
    
    [_FileListManager GetFileListing:Service];
}

- (void)GetPDFList {

    _GettingPDFs = YES;

    NSArray *enabledServices = [self ListOfEnabledServices];
    _CurrentCloudService = [enabledServices objectAtIndex:0];
    [_FileListManager GetFileListing:_CurrentCloudService];

    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *cloudservice = [defaults objectForKey:@"using-googledrive-key"];

    if(cloudservice != nil && [cloudservice isEqualToString:@"Yes"]) {

        [_FileListManager GetFileListing:@"Google Drive"];
    }
    else {

        cloudservice = [defaults objectForKey:@"using-dropbox-key"];

        if(cloudservice != nil && [cloudservice isEqualToString:@"Yes"]) {

            [_FileListManager GetFileListing:@"Dropbox"];
        }
        else {

            cloudservice = [defaults objectForKey:@"using-onedrive-key"];

            if(cloudservice != nil && [cloudservice isEqualToString:@"Yes"]) {

                [_FileListManager GetFileListing:@"OneDrive"];
            }
            else {

                cloudservice = [defaults objectForKey:@"using-box-key"];

                if(cloudservice != nil && [cloudservice isEqualToString:@"Yes"]) {

                    [_FileListManager GetFileListing:@"Box"];
                }
                else {

                    // couldnt find linked service

                }

            }

        }
    }
    */
}

- (BOOL)HasAtLeastOneServiceEnabled {
    
    for (NSString *service in _EnabledServices) {
        
        NSString *value = [_EnabledServices objectForKey:service];
        
        if ([value isEqualToString:@"Yes"]) {
            
            return YES;
        }
    }
    
    return NO;
}

- (NSArray *)ListOfEnabledServices {
    
    NSMutableArray *ListOfEnabledServices = [[NSMutableArray alloc] init];
    NSArray *services = [_EnabledServices allKeys];
    
    for (NSString *service in services) {
        
        NSString *enabled = [_EnabledServices objectForKey:service];
        
        if ([enabled isEqualToString:@"Yes"]) {
            
            [ListOfEnabledServices addObject:service];
        }
        
    }
    
    return [ListOfEnabledServices copy];
}

- (void)SetServiceState:(NSString *)Service withState:(NSString *)State {
    
    if (_EnabledServices) {
        
        [_EnabledServices setValue:State forKey:Service];
    }
}

#pragma mark - FileUploaderDelegate
- (void)FileUploadComplete:(bool)UploadSuccessful {
    
    if (uploadDelegate) {
        [uploadDelegate FileUploadComplete:UploadSuccessful];
    }
}

#pragma mark - FileUploaderServicesDatasource
- (Dropbox *)GetDropbox {
    
    return _Dropbox;
}

- (GoogleDrive *)GetGoogleDrive {
    
    return _GoogleDrive;
}

- (OneDrive *)GetOneDrive {
    
    return _OneDrive;
}

- (Box *)GetBox {
    
    return _Box;
}

#pragma mark - EnabledServicesDatasource
- (NSDictionary *)GetEnabledServices {
    
    return _EnabledServices;
}

#pragma mark - Dropbox
- (void)LinkDropbox:(UIViewController *)VC {

    [_Dropbox LinkDropbox:VC];
}

- (void)UnlinkDropbox {
    
    [_EnabledServices setValue:@"No" forKey:@"Dropbox"];
    [_Dropbox UnlinkDropbox];
}
- (BOOL)isDropboxAuthorized {
    
    bool isAuthorized = [_Dropbox isAuthorized];
    
    if (isAuthorized) {
        
        [_EnabledServices setValue:@"Yes" forKey:@"Dropbox"];
    }
    else {
        
        [_EnabledServices setValue:@"No" forKey:@"Dropbox"];
    }
    
    return isAuthorized;
}

- (BOOL)isDropboxLinked {
    
    return [_Dropbox isAuthorized];
}

- (BOOL)DropboxHandleOpenURL:(NSURL *)url {
    
    return [_Dropbox handleOpenURL:url];
}

- (void)SignalDropboxLinked:(BOOL)success {
    
    if (success) {
        [_EnabledServices setValue:@"Yes" forKey:@"Dropbox"];
    }
    else {
        [_EnabledServices setValue:@"No" forKey:@"Dropbox"];
    }
    
    if (linkDelegate) {
        [linkDelegate CloudServiceLinked:success withServiceName:@"Dropbox"];
    }
}

- (NSString *)GetDropboxClientID {
    
    return [delegate GetDropboxClientID];
}

- (NSString *)GetDropboxClientSecret {
    
    return [delegate GetDropboxClientSecret];
}

#pragma mark - Google Drive
- (BOOL)isGoogleDriveAuthorized {
    
    bool isAuthorized = [_GoogleDrive isAuthorized];
    
    if (isAuthorized) {
        
        [_EnabledServices setValue:@"Yes" forKey:@"Google Drive"];
    }
    else {
        
        [_EnabledServices setValue:@"No" forKey:@"Google Drive"];
    }
    
    return isAuthorized;
}

- (void)LinkGoogleDrive:(UIViewController *)ParentView {
    
    //_GoogleAuthController = [_GoogleDrive LinkGoogleDrive];
    //[ParentView presentViewController:_GoogleAuthController animated:NO completion:nil];
    
    [_GoogleDrive LinkGoogleDrive:ParentView];
}

- (void)UnlinkGoogleDrive {
    
    [_EnabledServices setValue:@"No" forKey:@"Google Drive"];
    [_GoogleDrive UnlinkGoogleDrive];
}

- (void)CheckForExpiredGoogleDriveToken {
    
    NSLog(@"Checking for expired google drive token");
    
    if ([[_EnabledServices objectForKey:@"Google Drive"] isEqualToString:@"Yes"]) {
        
        [_GoogleDrive CheckForExpiredGoogleDriveToken];
    }
    else {
        
        NSLog(@"Google drive is not enabled, token not checked");
    }
}

#pragma GoogleDriveDelegate
- (void)AuthComplete:(bool)success
{
    
    if (success) {
        [_EnabledServices setValue:@"Yes" forKey:@"Google Drive"];
    }
    else {
        [_EnabledServices setValue:@"No" forKey:@"Google Drive"];
    }
    
    if (linkDelegate) {
        [linkDelegate CloudServiceLinked:success withServiceName:@"Google Drive"];
    }
    
    /*
    [_GoogleAuthController dismissViewControllerAnimated:NO completion:^(){

        if (linkDelegate) {
            [linkDelegate CloudServiceLinked:success withServiceName:@"Google Drive"];
        }
        
    }];
    */

}

- (NSString *)GetGoogleDriveClientID {
    
    return [delegate GetGoogleDriveClientID];
}

- (NSString *)GetGoogleDriveClientSecret {
    
    return [delegate GetGoogleDriveClientSecret];
}

- (void)SetAuthorizationFlow:(id<OIDExternalUserAgentSession>)CurrentFlow {
    
    [delegate SetAuthorizationFlow:CurrentFlow];
}

#pragma mark - OneDrive
- (BOOL)isOneDriveAuthorized {
    
    bool isAuthorized = [_OneDrive isOneDriveAuthenticated];
    
    if (isAuthorized) {
        
        [_EnabledServices setValue:@"Yes" forKey:@"OneDrive"];
    }
    else {
        
        [_EnabledServices setValue:@"No" forKey:@"OneDrive"];
    }
    
    return isAuthorized;
}

- (void)LinkOneDrive:(UIViewController *)ParentView {
    
    [_OneDrive loginOneDrive:ParentView];
}

- (void)UnlinkOneDrive {
    
    [_EnabledServices setValue:@"No" forKey:@"OneDrive"];
    [_OneDrive logoutOneDrive];
}

#pragma OneDriveAuthDelegate
- (void)OneDriveAuthComplete:(bool)success
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (success) {
            [_EnabledServices setValue:@"Yes" forKey:@"OneDrive"];
        }
        else {
            [_EnabledServices setValue:@"No" forKey:@"OneDrive"];
        }
        
        if (linkDelegate) {
            [linkDelegate CloudServiceLinked:success withServiceName:@"OneDrive"];
        }
        
    });

}

- (NSString *)GetOneDriveClientID {
    
    return [delegate GetOneDriveClientID];
}

#pragma - Box
- (BOOL)isBoxAuthorized {

    bool isAuthorized = [_Box isAuthenticated];
    
    if (isAuthorized) {
        
        [_EnabledServices setValue:@"Yes" forKey:@"Box"];
    }
    else {
        
        [_EnabledServices setValue:@"No" forKey:@"Box"];
    }
    
    return isAuthorized;
}

- (void)LinkBox {
    
    [_Box linkBox];
}

- (void)UnlinkBox {
    
    [_EnabledServices setValue:@"No" forKey:@"Box"];
    [_Box unlinkBox];
}

#pragma BoxAuthDelegate
- (void)BoxAuthComplete:(bool)success {
    
    if (success) {
        [_EnabledServices setValue:@"Yes" forKey:@"Box"];
    }
    else {
        [_EnabledServices setValue:@"No" forKey:@"Box"];
    }
    
    if (linkDelegate) {
        [linkDelegate CloudServiceLinked:success withServiceName:@"Box"];
    }
}

- (NSString *)GetBoxClientID {

    return [delegate GetBoxClientID];
}

- (NSString *)GetBoxClientSecret {
    
    return [delegate GetBoxClientSecret];
}

#pragma CloudFileListingDelegate
- (void)CloudFileListComplete:(bool)FileListSuccessful withList:(NSMutableArray *)fileList {

    if(_GettingPDFs) {

        _GettingPDFs = NO;

        NSPredicate *extenstionPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] '.pdf'"];
        fileList = [[fileList filteredArrayUsingPredicate:extenstionPredicate] mutableCopy];

        NSPredicate *commaPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] ','"];
        fileList = [[fileList filteredArrayUsingPredicate:commaPredicate] mutableCopy];

        if(pdfListDelegate) {
            [pdfListDelegate PDFListReady:FileListSuccessful
                             withFileList:fileList
                         fromCloudService:_CurrentCloudService];
        }
    }
    else  {

        if (fileListDelegate) {
            [fileListDelegate FileListReady:FileListSuccessful withFileList:fileList];
        }
    }

}

- (NSString *)GetAppFolderName {
    
    return [delegate GetAppFolderName];
}

#pragma FileDownloaderDelegate
- (void)FileDownloadComplete:(bool)DownloadSuccessful {
    
    if (downloadDelegate) {
        [downloadDelegate FileDownloadComplete:DownloadSuccessful];
    }
}

#pragma FileUploaderProgressDelegate
- (void)FileUploadProgress:(float)percentage {
    
    //NSLog(@"Upload progress: %f", percentage);
    
    if (uploadProgressDelegate) {
        [uploadProgressDelegate FileUploadProgress:percentage];
    }
}

#pragma FileDownloaderProgressDelegate
- (void)FileDownloaderProgress:(float)percentage {
    
    //NSLog(@"Download progress: %f", percentage);
    
    if (downloadProgressDelegate) {
        [downloadProgressDelegate FileDownloadProgress:percentage];
    }
}

#pragma PendingUploaderDelegate
- (void)PendingUploadComplete:(bool)UploadSuccessful {
    
    if (pendingDelegate) {
        [pendingDelegate PendingUploadComplete:UploadSuccessful];
    }
}

- (void)PendingUploadProgress:(NSUInteger)NumUploaded withTotal:(NSUInteger)TotalToUpload {
    
    if (pendingDelegate) {
        [pendingDelegate PendingUploadProgress:NumUploaded withTotal:TotalToUpload];
    }
}

- (CoreDataManager *)GetCoreDataManager {

    return [pendingDelegate GetCoreDataManager];
}

- (FileUploader *)GetFileUploader {

    if (_FileUploader == nil) {
        _FileUploader = [[FileUploader alloc] init];
        _FileUploader.servicesDatasource = self;
        _FileUploader.enabledServicesDatasource = self;
        _FileUploader.progressDelegate = self;
    }
    
    return _FileUploader;
    
}

- (NSString *)GetTempPath {
    
    return [pendingDelegate GetTempPath];
}

#pragma mark - PDF Delegate for pending uploader
- (NSArray *)GetAllergies {
    
    return [pdfDelegate GetAllergies];
}

- (NSArray *)GetDiseases {
    
    return [pdfDelegate GetDiseases];
}

- (NSArray *)GetHealthConditions {
    
    return [pdfDelegate GetHealthConditions];
}

- (NSDictionary *)HealthAnswers {
    
    return [pdfDelegate HealthAnswers];
}

- (NSArray *)LegalItems {
    
    return [pdfDelegate LegalItems];
}

- (NSArray *)RulesItems {

    return [pdfDelegate RulesItems];
}

@end

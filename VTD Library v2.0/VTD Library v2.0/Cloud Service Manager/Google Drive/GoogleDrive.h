//
//  GoogleDrive.h
//  DIO Tattoo Forms
//
//  Created by Francis Bowen on 1/18/13.
//
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
//#import "GTMOAuth2ViewControllerTouch.h"
//#import "GTLDrive.h"
//#import "GTMHTTPFetcher.h"
#import <GTMSessionFetcher/GTMSessionFetcherService.h>

#import "GTLRDrive.h"
#import "GTMAppAuth.h"
#import "AppAuth.h"

#define PARTIAL_FILE_SIZE   10000000

@class AppDelegate;

@protocol GoogleDriveDelegate
@optional
- (void)AuthComplete:(bool)success;

- (NSString *)GetGoogleDriveClientID;
- (NSString *)GetGoogleDriveClientSecret;
- (NSString *)GetAppFolderName;

- (void)SetAuthorizationFlow:(id<OIDExternalUserAgentSession>)CurrentFlow;

@end

@protocol GoogleDriveDownloadDelegate
@optional
- (void)GoogleDriveDownloadComplete:(bool)success;
@end

@protocol GoogleDriveUploadProgressDelegate
@optional
- (void)UploadPercentageUpdate:(float)percentage;
@end

@protocol GoogleDriveDownloadProgressDelegate
@optional
- (void)DownloadPercentageUpdate:(float)percentage;
@end

@protocol GoogleDriveUploadDelegate
@optional
- (void)GoogleDriveUploadComplete:(bool)success;
- (void)FileDeleted:(bool)success;
@end

@protocol GoogleDriveFileListingDelegate
@optional
- (void)GoogleDriveFileListingComplete:(bool)success withList:(NSMutableArray *)GoogleDriveFileList;
@end

@interface GoogleDrive : NSObject
{
    GTLRDrive_FileList *_childList;
    bool folderExists;
    __block NSString *folderID;
    NSMutableArray *fileList;
    GTLRDrive_FileList *driveFilesInAppDirectory;
    
    GTLRServiceTicket *uploadTicket;
    
    bool cancelingDownload;
    
    NSString *downloadPath;
    
    GTMSessionFetcher *_fetcher;
    
    BOOL _isDeletingFile;
    NSString *_FileToDelete;
    
    GTMAppAuthFetcherAuthorization *_authorization;
    
    NSNumber *_FileSize;
    long long _NumBytesInFile;
    long long _CurrentOffset;
    long long _EndOffset;
    int _CurrentIteration;
    NSURLRequest *_DownloadRequest;
    NSString *_DownloadedFilename;
    NSString *_DownloadedFilenameAndPath;
    NSString *_DownloadedPath;

}

@property (nonatomic, retain) GTLRDriveService *driveService;
@property (weak) id <GoogleDriveDelegate> delegate;
@property (weak) id <GoogleDriveDownloadDelegate> downloadDelegate;
@property (weak) id <GoogleDriveUploadDelegate> uploadDelegate;
@property (weak) id <GoogleDriveUploadProgressDelegate> uploadProgressDelegate;
@property (weak) id <GoogleDriveDownloadProgressDelegate> downloadProgressDelegate;
@property (weak) id <GoogleDriveFileListingDelegate> listingDelegate;

@property GTLRDrive_File *driveFile;

- (void)initGoogleDrive;
- (void)LinkGoogleDrive:(UIViewController *)ParentVC;
- (void)UnlinkGoogleDrive;
- (BOOL)isAuthorized;
- (void)CheckForExpiredGoogleDriveToken;

- (void)uploadFile:(NSFileHandle *)filehandle withTitle:(NSString *)title;
- (void)getFileListing:(NSString *)folder;
- (void)downloadFile:(NSString *)fileName intoPath:(NSString *)destPath;
- (void)cancelDownload;
- (void)cancelUpload;
- (void)RemoveFile:(NSString *)filename;

@end

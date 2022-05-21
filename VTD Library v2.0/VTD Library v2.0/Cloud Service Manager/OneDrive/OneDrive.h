//
//  OneDrive.h
//  TRF
//
//  Created by Francis Bowen on 9/10/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OneDriveSDK/OneDriveSDK.h>

@protocol OneDriveAuthDelegate
@optional
- (void)OneDriveAuthComplete:(bool)success;

- (NSString *)GetAppFolderName;
- (NSString *)GetOneDriveClientID;

@end

@protocol OneDriveFileDelegate
@optional
- (void)OneDriveUploadComplete:(bool)success;
- (void)FileDeleted:(bool)success;
@end

@protocol OneDriveFileListingDelegate
@optional
- (void)OneDriveFileListingComplete:(bool)success withList:(NSMutableArray *)OneDriveFileList;
@end

@protocol OneDriveDownloadDelegate
@optional
- (void)OneDriveFileDownloadComplete:(bool)success;
@end

@protocol OneDriveUploadProgressDelegate
@optional
- (void)UploadPercentageUpdate:(float)percentage;
@end

@protocol OneDriveDownloadProgressDelegate
@optional
- (void)DownloadPercentageUpdate:(float)percentage;
@end


@interface OneDrive : NSObject
{
    ODClient *odClient;
    NSArray *_scopes;
    
    ODItem *rootODItem;
    NSString *appFolderID;
    
    NSString *currentPath;
    NSString *currentFName;
    
    NSMutableArray *fileList;
    NSMutableDictionary *driveFilesInAppDirectory;
    
    NSString *savePath;
    
    bool cancelingDownload;
    
    bool isUploading;
    bool isGettingListing;
}

@property (weak) id <OneDriveAuthDelegate> authDelegate;
@property (weak) id <OneDriveFileDelegate> fileDelegate;
@property (weak) id <OneDriveFileListingDelegate> fileListingDelegate;
@property (weak) id <OneDriveDownloadDelegate> downloadDelegate;
@property (weak) id <OneDriveUploadProgressDelegate> uploadProgressDelegate;
@property (weak) id <OneDriveDownloadProgressDelegate> downloadProgressDelegate;

- (void)initOneDrive;
- (bool)isOneDriveAuthenticated;
- (void)loginOneDrive:(UIViewController *)currentViewController;
- (void)logoutOneDrive;
- (void)uploadFile:(NSString *)path withFileName:(NSString *)fName;
- (void)getFileListing;
- (void)downloadFile:(NSString *)fileName intoPath:(NSString *)destPath;
- (void)cancelDownload;
- (void)cancelUpload;
- (void)RemoveFile:(NSString *)filename;

@end

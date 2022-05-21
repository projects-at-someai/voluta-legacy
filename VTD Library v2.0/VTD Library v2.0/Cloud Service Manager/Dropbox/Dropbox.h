//
//  Dropbox.h
//  TRF
//
//  Created by Francis Bowen on 10/2/13.
//  Copyright (c) 2013 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@protocol DropboxDelegate

- (NSString *)GetAppFolderName;
- (NSString *)GetDropboxClientID;
- (NSString *)GetDropboxClientSecret;
- (BOOL)DidHandleURL;

@end

@protocol DropboxUploadDelegate
@optional
- (void)DropboxUploadComplete:(bool)success;
- (void)FileDeleted:(bool)success;
@end

@protocol DropboxDownloadDelegate
@optional
- (void)DropboxDownloadComplete:(bool)success;
@end

@protocol DropboxListingDelegate
@optional
- (void)DropboxFileListingComplete:(bool)success withList:(NSMutableArray *)DropboxFileList;
@end

@protocol DropboxUploadPercentageDelegate
@optional
- (void)UploadPercentageUpdate:(float)percentage;
@end

@protocol DropboxDownloadPercentageDelegate
@optional
- (void)DownloadPercentageUpdate:(float)percentage;
@end

#define MAX_UPLOAD_ERROR    10

@interface Dropbox : NSObject
{

    NSMutableArray *fileList;
    NSString *currentFileDownloading;
    
    NSString *_filename;
    NSString *_destDir;
    NSString *_sourcePathAndFilename;
    unsigned long long sourceFileSize;
    int uploadErrorCount;
    
    DBDownloadUrlTask *_DownloadTask;
    DBBatchUploadTask *_UploadTask;
    
}

- (void)initDropbox;
- (void)LinkDropbox:(UIViewController *)rootVC;
- (void)UnlinkDropbox;
- (BOOL)isAuthorized;
- (BOOL)handleOpenURL:(NSURL *)url;


- (void)uploadSmallFile:(NSString *)filename toDest:(NSString *)destDir fromPath:(NSString *)pdfFileNameFullPath;
- (void)uploadLargeFile:(NSString *)filename toDest:(NSString *)destDir fromPath:(NSString *)pdfFileNameFullPath;
- (void)getFileListing;
- (void)downloadFile:(NSString *)filename intoPath:(NSString *)destPath;
- (void)cancelDownload;
- (void)cancelUpload;
- (void)RemoveFile:(NSString *)filename;

@property (weak) id <DropboxDelegate> delegate;
@property (weak) id <DropboxUploadDelegate> uploadDelegate;
@property (weak) id <DropboxDownloadDelegate> downloadDelegate;
@property (weak) id <DropboxListingDelegate> listingDelegate;
@property (weak) id <DropboxUploadPercentageDelegate> uploadPercentageDelegate;
@property (weak) id <DropboxDownloadPercentageDelegate> downloadPercentageDelegate;

@end

//
//  FileDownloader.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 10/6/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box.h"
#import "Dropbox.h"
#import "GoogleDrive.h"
#import "OneDrive.h"

@protocol FileDownloaderDelegate
@optional
- (void)FileDownloadComplete:(bool)DownloadSuccessful;

- (Dropbox *)GetDropbox;
- (GoogleDrive *)GetGoogleDrive;
- (OneDrive *)GetOneDrive;
- (Box *)GetBox;

@end

@protocol FileDownloaderProgressDelegate
@optional
- (void)FileDownloaderProgress:(float)percentage;
@end

@interface FileDownloader : NSObject <
    BoxDownloadDelegate,
    DropboxDownloadDelegate,
    GoogleDriveDownloadDelegate,
    OneDriveDownloadDelegate,
    DropboxDownloadPercentageDelegate,
    GoogleDriveDownloadProgressDelegate,
    OneDriveDownloadProgressDelegate,
    BoxDownloadProgressDelegate
>
{
    Box *_Box;
    Dropbox *_Dropbox;
    GoogleDrive *_GoogleDrive;
    OneDrive *_OneDrive;
}

@property (weak) id <FileDownloaderDelegate> delegate;
@property (weak) id <FileDownloaderProgressDelegate> progressDelegate;

- (id)initWithDelegate:(id<FileDownloaderDelegate>)adelegate;

- (void)DownloadFile:(NSString *)CloudFileName
              toDest:(NSString *)DestPath
         fromService:(NSString *)Service;
- (void)CancelDownload:(NSString *)Service;

@end

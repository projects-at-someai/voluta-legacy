//
//  FileUploader.h
//  DIO Tattoo Forms
//
//  Created by Francis Bowen on 2/1/13.
//
//

#import <Foundation/Foundation.h>
#import "Dropbox.h"
#import "GoogleDrive.h"
#import "OneDrive.h"
#import "Box.h"
#import "Utilities.h"

#define LARGE_FILESIZE_LIMIT    5242880
#define MAX_UPLOAD_RETRIES      3

@protocol FileUploaderDelegate
@optional
- (void)FileUploadComplete:(bool)UploadSuccessful;
@end

@protocol FileUploaderProgressDelegate
@optional
- (void)FileUploadProgress:(float)percentage;
@end

@protocol FileUploaderServicesDatasource
@optional
- (Dropbox *)GetDropbox;
- (GoogleDrive *)GetGoogleDrive;
- (OneDrive *)GetOneDrive;
- (Box *)GetBox;
@end

@protocol EnabledServicesDatasource
@optional
- (NSDictionary *)GetEnabledServices;
@end

@interface FileUploader : NSObject <
    DropboxUploadDelegate,
    GoogleDriveUploadDelegate,
    OneDriveFileDelegate,
    BoxUploadDelegate,
    DropboxUploadPercentageDelegate,
    OneDriveUploadProgressDelegate,
    GoogleDriveUploadProgressDelegate,
    BoxUploadProgressDelegate
>
{
    
    NSString *_pdfFileName;
    NSString *_pdfFileNameFullPath;
    NSString *_DBKey;
    
    bool isCanceling;
    
    Dropbox *_Dropbox;
    GoogleDrive *_GoogleDrive;
    OneDrive *_OneDrive;
    Box *_Box;
    
    //pdfCrypto *pdfEncryptor;
    
    NSDictionary *_EnabledServices;
    int _isUploadingCounter;
    int _isDeletingCounter;
    
    UInt8 _UploadErrorCounter;
}

@property (weak) id <FileUploaderDelegate> delegate;
@property (weak) id <FileUploaderProgressDelegate> progressDelegate;
@property (weak) id <FileUploaderServicesDatasource> servicesDatasource;
@property (weak) id <EnabledServicesDatasource> enabledServicesDatasource;

- (void)UploadFile:(NSString *)FileName withFullPath:(NSString *)FullPath;
- (void)UploadFileAndReplace:(NSString *)FileName withFullPath:(NSString *)FullPath;
- (void)CancelCurrentUpload;

@end

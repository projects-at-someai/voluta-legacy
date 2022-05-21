//
//  FileUploader.m
//  DIO Tattoo Forms
//
//  Created by Francis Bowen on 2/1/13.
//
//

#import "FileUploader.h"

@implementation FileUploader

@synthesize delegate;
@synthesize progressDelegate;
@synthesize servicesDatasource;
@synthesize enabledServicesDatasource;

- (void)UploadFile:(NSString *)FileName withFullPath:(NSString *)FullPath
{
    
    //Check for valid internet connection
    if ([Utilities HasNetworkConnectivity])
    {
        _pdfFileName = FileName;
        _pdfFileNameFullPath = FullPath;
        
        if (servicesDatasource) {
            
            _Dropbox = [servicesDatasource GetDropbox];
            _Dropbox.uploadDelegate = self;
            _Dropbox.uploadPercentageDelegate = self;
            
            _GoogleDrive = [servicesDatasource GetGoogleDrive];
            _GoogleDrive.uploadDelegate = self;
            _GoogleDrive.uploadProgressDelegate = self;
            
            _OneDrive = [servicesDatasource GetOneDrive];
            _OneDrive.fileDelegate = self;
            _OneDrive.uploadProgressDelegate = self;
            
            _Box = [servicesDatasource GetBox];
            _Box.uploadDelegate = self;
            _Box.uploadProgressDelegate = self;
        }
        
        [self StartUpload:_pdfFileName withFullPath:_pdfFileNameFullPath];
    }
    else
    {
        /*
        DBKey = [pdfFileName substringToIndex:[pdfFileName length] - 4];
        
        //encrypt pdf
        
        if (pdfEncryptor == nil) {
            pdfEncryptor = [[pdfCrypto alloc] init];
        }
        
        [pdfEncryptor encryptPDF:pdfFileNameFullPath withKey:DBKey];
        */
        NSLog(@"No internet connection, not uploading %@", _DBKey);
        
        if(delegate)
            [delegate FileUploadComplete:false];
    }
    
}

- (void)StartUpload:(NSString *)FileName withFullPath:(NSString *)FullPath
{
    
    _EnabledServices = [enabledServicesDatasource GetEnabledServices];
    _isUploadingCounter = 0;
    _UploadErrorCounter = 0;
    
    if ([[_EnabledServices objectForKey:@"Dropbox"] isEqualToString:@"Yes"]) {
        
        _isUploadingCounter++;
        
        [self UploadToDropbox];
        
    }
    
    if ([[_EnabledServices objectForKey:@"Google Drive"] isEqualToString:@"Yes"]) {
        
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:FullPath];
        _isUploadingCounter++;
        [_GoogleDrive uploadFile:file withTitle:FileName];
    }
    
    if ([[_EnabledServices objectForKey:@"OneDrive"] isEqualToString:@"Yes"]) {
        
        _isUploadingCounter++;
        [_OneDrive uploadFile:_pdfFileNameFullPath withFileName:_pdfFileName];
    }
    
    if ([[_EnabledServices objectForKey:@"Box"] isEqualToString:@"Yes"]) {
        
        _isUploadingCounter++;
        [_Box uploadFile:_pdfFileNameFullPath];
    }
    
}

- (void)UploadToDropbox {
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_pdfFileNameFullPath error:nil];
    
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber longLongValue];
    
    if (fileSize < LARGE_FILESIZE_LIMIT) {
        
        [_Dropbox uploadSmallFile:_pdfFileName toDest:@"/" fromPath:_pdfFileNameFullPath];
    }
    else {
        
        [_Dropbox uploadLargeFile:_pdfFileName toDest:@"/" fromPath:_pdfFileNameFullPath];
    }
}

- (void)CancelCurrentUpload
{
    isCanceling = true;
    
    if ([[_EnabledServices objectForKey:@"Dropbox"] isEqualToString:@"Yes"]) {
        
        [_Dropbox cancelUpload];
    }
    
    if ([[_EnabledServices objectForKey:@"Google Drive"] isEqualToString:@"Yes"]) {
        
        [_GoogleDrive cancelUpload];
    }
    
    if ([[_EnabledServices objectForKey:@"OneDrive"] isEqualToString:@"Yes"]) {
        
        [_OneDrive cancelUpload];
    }
    
    if ([[_EnabledServices objectForKey:@"Box"] isEqualToString:@"Yes"]) {
        
        [_Box cancelUpload];
    }
}

- (void)UploadFileAndReplace:(NSString *)FileName withFullPath:(NSString *)FullPath {

    //Check for valid internet connection
    if ([Utilities HasNetworkConnectivity])
    {
        _pdfFileName = FileName;
        _pdfFileNameFullPath = FullPath;
        
        if (servicesDatasource) {
            
            _Dropbox = [servicesDatasource GetDropbox];
            _Dropbox.uploadDelegate = self;
            _Dropbox.uploadPercentageDelegate = self;
            
            _GoogleDrive = [servicesDatasource GetGoogleDrive];
            _GoogleDrive.uploadDelegate = self;
            _GoogleDrive.uploadProgressDelegate = self;
            
            _OneDrive = [servicesDatasource GetOneDrive];
            _OneDrive.fileDelegate = self;
            _OneDrive.uploadProgressDelegate = self;
            
            _Box = [servicesDatasource GetBox];
            _Box.uploadDelegate = self;
            _Box.uploadProgressDelegate = self;
        }
        
        _EnabledServices = [enabledServicesDatasource GetEnabledServices];
        _isDeletingCounter = 0;
        
        if ([[_EnabledServices objectForKey:@"Dropbox"] isEqualToString:@"Yes"]) {
            
            _isDeletingCounter++;
            [_Dropbox RemoveFile:FileName];
        }
        
        if ([[_EnabledServices objectForKey:@"Google Drive"] isEqualToString:@"Yes"]) {
            
            _isDeletingCounter++;
            [_GoogleDrive RemoveFile:FileName];
        }
        
        if ([[_EnabledServices objectForKey:@"OneDrive"] isEqualToString:@"Yes"]) {
            
            _isDeletingCounter++;
            [_OneDrive RemoveFile:FileName];
        }
        
        if ([[_EnabledServices objectForKey:@"Box"] isEqualToString:@"Yes"]) {
            
            _isDeletingCounter++;
            [_Box RemoveFile:FileName];
        }
        
    }
    else
    {
        /*
         DBKey = [pdfFileName substringToIndex:[pdfFileName length] - 4];
         
         //encrypt pdf
         
         if (pdfEncryptor == nil) {
         pdfEncryptor = [[pdfCrypto alloc] init];
         }
         
         [pdfEncryptor encryptPDF:pdfFileNameFullPath withKey:DBKey];
         */
        NSLog(@"No internet connection, not uploading %@", _DBKey);
        
        if(delegate)
            [delegate FileUploadComplete:false];
    }
    
}

- (void)FileDeleted:(bool)success {
    
    _isDeletingCounter--;
    
    if (_isDeletingCounter == 0) {
        
        [self StartUpload:_pdfFileName withFullPath:_pdfFileNameFullPath];
    }
}

#pragma mark - GoogleUploadDelegate
- (void)GoogleDriveUploadComplete:(bool)success {

    [self CheckAllUploads:success];
}

#pragma mark - OneDriveFileDelegate
- (void)OneDriveUploadComplete:(bool)success {
    
    [self CheckAllUploads:success];
}

#pragma mark - DropboxUploadDelegate
- (void)DropboxUploadComplete:(bool)success {

    if (!success && (_UploadErrorCounter < MAX_UPLOAD_ERROR)) {
        
        _UploadErrorCounter++;
        
        //Try to upload to dropbox again
        [self UploadToDropbox];
    }
    else {
        
        [self CheckAllUploads:success];
    }

}

#pragma mark - BoxUploadDelegate
- (void)BoxUploadComplete:(bool)success {
    
    [self CheckAllUploads:success];
}

- (void)CheckAllUploads:(bool)success {
    
    if (success) {
        
        _isUploadingCounter--;
        
        if (_isUploadingCounter == 0) {
            
            if (delegate) {
                [delegate FileUploadComplete:YES];
            }
        }
    }
    else
    {
        if (delegate) {
            [delegate FileUploadComplete:NO];
        }
    }

}

- (void)UploadPercentageUpdate:(float)percentage
{
    if (progressDelegate)
    {
        [progressDelegate FileUploadProgress:percentage];
    }
}

@end

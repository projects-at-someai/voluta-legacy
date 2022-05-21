//
//  FileDownloader.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 10/6/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "FileDownloader.h"

@implementation FileDownloader

@synthesize delegate;
@synthesize progressDelegate;

- (id)initWithDelegate:(id<FileDownloaderDelegate>)adelegate {
    
    self = [super init];
    
    if (self) {
        
        delegate = adelegate;
        
        _Box = [delegate GetBox];
        _Box.downloadDelegate = self;
        _Box.downloadProgressDelegate = self;
        
        _Dropbox = [delegate GetDropbox];
        _Dropbox.downloadDelegate = self;
        _Dropbox.downloadPercentageDelegate = self;
        
        _GoogleDrive = [delegate GetGoogleDrive];
        _GoogleDrive.downloadDelegate = self;
        _GoogleDrive.downloadProgressDelegate = self;
        
        _OneDrive = [delegate GetOneDrive];
        _OneDrive.downloadDelegate = self;
        _OneDrive.downloadProgressDelegate = self;
    }
    
    return self;
}

- (void)DownloadFile:(NSString *)CloudFileName
              toDest:(NSString *)DestPath
         fromService:(NSString *)Service {
    
    if ([Service isEqualToString:@"Dropbox"]) {
        
        [_Dropbox downloadFile:CloudFileName intoPath:DestPath];
    }
    else if ([Service isEqualToString:@"Google Drive"]) {
        
        [_GoogleDrive downloadFile:CloudFileName intoPath:DestPath];
    }
    else if ([Service isEqualToString:@"OneDrive"]) {
        
        [_OneDrive downloadFile:CloudFileName intoPath:DestPath];
    }
    else if ([Service isEqualToString:@"Box"]) {
        
        [_Box downloadFile:CloudFileName intoPath:DestPath];
    }
    
}

- (void)CancelDownload:(NSString *)Service {
    
    if ([Service isEqualToString:@"Dropbox"]) {
        
        [_Dropbox cancelDownload];
    }
    else if ([Service isEqualToString:@"Google Drive"]) {
        
        [_GoogleDrive cancelDownload];
    }
    else if ([Service isEqualToString:@"OneDrive"]) {
        
        [_OneDrive cancelDownload];
    }
    else if ([Service isEqualToString:@"Box"]) {
        
        [_Box cancelDownload];
    }
}

- (void)FinishDownload:(bool)success {
    
    if (delegate) {
        [delegate FileDownloadComplete:success];
    }
}

#pragma mark -
#pragma BoxDownloadDelegate
- (void)BoxDownloadComplete:(bool)success {
    
    [self FinishDownload:success];
}

#pragma mark - 
#pragma DropboxDownloadDelegate
- (void)DropboxDownloadComplete:(bool)success {
    
    [self FinishDownload:success];
}

#pragma mark -
#pragma GoogleDriveDownloadDelegate
- (void)GoogleDriveDownloadComplete:(bool)success {
    
    [self FinishDownload:success];
    
}

#pragma mark -
#pragma OneDriveDownloadDelegate
- (void)OneDriveFileDownloadComplete:(bool)success {
    
    [self FinishDownload:success];
}

#pragma download progress delegate
- (void)DownloadPercentageUpdate:(float)percentage {
    
    if (progressDelegate) {
        [progressDelegate FileDownloaderProgress:percentage];
    }
}

@end

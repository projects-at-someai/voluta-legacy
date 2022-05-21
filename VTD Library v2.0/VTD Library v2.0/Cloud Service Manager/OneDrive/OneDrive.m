   //
//  OneDrive.m
//  TRF
//
//  Created by Francis Bowen on 9/10/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "OneDrive.h"

@implementation OneDrive

@synthesize authDelegate;
@synthesize fileDelegate;
@synthesize fileListingDelegate;
@synthesize downloadDelegate;
@synthesize uploadProgressDelegate;
@synthesize downloadProgressDelegate;

- (void)initOneDrive {
    
    _scopes = [NSArray arrayWithObjects:
               @"wl.signin",
               @"onedrive.readwrite",
               @"onedrive.appfolder",
               @"wl.offline_access", nil];
    
    [ODClient setMicrosoftAccountAppId:[authDelegate GetOneDriveClientID] scopes:_scopes];
    
    /*
    [ODClient clientWithCompletion:^(ODClient *client, NSError *error) {
    
        if (!error) {
            odClient = client;
        }
    }];
    */
    
    appFolderID = @"";
    
    odClient = [ODClient loadCurrentClient];
    
    if (odClient != nil) {
        [self getFolderID];
    }
    
    isUploading = NO;
    isGettingListing = NO;
}

- (bool)isOneDriveAuthenticated {
    
    return (odClient != nil);
}

- (void)loginOneDrive:(UIViewController *)currentViewController {
    
    [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error) {
    
        if (!error) {
            odClient = client;
            
            if (authDelegate) {
                [authDelegate OneDriveAuthComplete:YES];
            }
            
            [self getFolderID];
        }
        else {
            
            NSLog(@"OneDrive Login failed with error: %@", error);
            
            if (authDelegate) {
                [authDelegate OneDriveAuthComplete:NO];
            }
        }
    }];
}

- (void)logoutOneDrive {
    
    [odClient signOutWithCompletion:^(NSError *error) {
    
        if (!error) {
            odClient = nil;
        }
    }];
}

- (void)uploadFile:(NSString *)path withFileName:(NSString *)fName {

    currentPath = path;
    currentFName = fName;
    
    isUploading = YES;
    
    if ([appFolderID isEqualToString:@""]) {
        
        [self getFolderID];
    }
    else {

        ODItemContentRequest* contentRequest = [[[[odClient drive] items:appFolderID] itemByPath:fName] contentRequest];
        
        [contentRequest uploadFromFile:[NSURL fileURLWithPath:path] completion:^(ODItem *responseItem, NSError *error) {
            
            if (error) {
                NSLog(@"OneDrive uploadFile error: %@",error);
            }
            else {
                NSLog(@"OneDrive file upload successful: %@", fName);
            }
            
            isUploading = NO;
            
            if (fileDelegate) {
                [fileDelegate OneDriveUploadComplete:(error == nil)];
            }
            
            
        }];
    }

}

- (void)getFolderID
{
    [[[[odClient root] itemByPath:[authDelegate GetAppFolderName]] request]
     getWithCompletion:^(ODItem *item, NSError *error){
        //Returns an ODItem object or an error if there was one
        
        if (error) {
            
            //Create folder
            NSLog(@"OneDrive Folder not found: %@",error);
            
            [self createFolder:[authDelegate GetAppFolderName]
         withCompletionHandler:^(ODItem *item, NSError *error) {
                
                if (!error) {
                    
                    if (isUploading) {
                        [self uploadFile:currentPath withFileName:currentFName];
                    }
                }
            }];
            
        }
        else {
            
            appFolderID = item.id;
            
            if (isUploading) {
                [self uploadFile:currentPath withFileName:currentFName];
            }
            else if (isGettingListing) {
                [self getFileListing];
            }
        }
        
    }];

}

- (void)createFolder:(NSString *)folderName withCompletionHandler:(ODItemCompletionHandler)handler {
    
    ODItem *newFolder = [[ODItem alloc] initWithDictionary:@{[ODNameConflict rename].key : [ODNameConflict rename].value}];
    newFolder.name = folderName;
    newFolder.folder = [[ODFolder alloc] init];
    [[[[[odClient drive] items:@"root"] children] request] addItem:newFolder withCompletion:handler];
}

- (void)getFileListing {
    
    isGettingListing = YES;
    
    if ([appFolderID isEqualToString:@""]) {
        
        [self getFolderID];
    }
    else {

        if (fileList == nil) {
            
            fileList = [[NSMutableArray alloc] init];
        }
        
        [fileList removeAllObjects];
        
        if (!driveFilesInAppDirectory) {
            driveFilesInAppDirectory = [[NSMutableDictionary alloc] init];
        }
        
        [driveFilesInAppDirectory removeAllObjects];
        
        ODChildrenCollectionRequest *childrenRequest = [[[[odClient drive] items:appFolderID] children] request];
        
        [childrenRequest getWithCompletion:^(ODCollection *response, ODChildrenCollectionRequest *nextRequest, NSError *error){
            
            isGettingListing = NO;
            
            if (!error){
                
                NSArray *items = response.value;
                
                for (ODItem *item in items) {
                    
                    [fileList addObject:item.name];
                    [driveFilesInAppDirectory setObject:item.id forKey:item.name];
                }
                
                if (fileListingDelegate) {
                    [fileListingDelegate OneDriveFileListingComplete:YES withList:fileList];
                }
            }
            else {
                
                if (fileListingDelegate) {
                    [fileListingDelegate OneDriveFileListingComplete:NO withList:nil];
                }
            }
            
        }];

    }
    
}

- (void)downloadFile:(NSString *)fileName intoPath:(NSString *)destPath {
    
    NSString *fid = [driveFilesInAppDirectory objectForKey:fileName];
    
    if (fid != nil) {

        ODItemContentRequest *request = [[[odClient drive] items:fid] contentRequest];
        
        [request downloadWithCompletion:^(NSURL *filePath, NSURLResponse *urlResponse, NSError *error){
            // The file path to the item on disk, this is a temporary file and will be removed
            // after the block is done executing.
            
            if (!error) {
                
                NSError *fileError;
                
                NSFileManager *filemanager = [[NSFileManager alloc] init];
                NSString *fileandpath = [NSString stringWithFormat:@"%@/%@",destPath,fileName];
                [filemanager copyItemAtURL:filePath toURL:[NSURL fileURLWithPath:fileandpath] error:&fileError];
                
                if (!fileError) {

                    NSLog(@"OneDrive file download successful: %@", filePath);
                    
                    if (downloadDelegate) {
                        [downloadDelegate OneDriveFileDownloadComplete:YES];
                    }
                }
                else {
                    
                    if (downloadDelegate) {
                        [downloadDelegate OneDriveFileDownloadComplete:NO];
                    }
                }
                
            }
            else {
                
                if (downloadDelegate) {
                    [downloadDelegate OneDriveFileDownloadComplete:NO];
                }
            }
            
        }];
    }
    else {
        
        //File not found
        
        if (downloadDelegate) {
            [downloadDelegate OneDriveFileDownloadComplete:NO];
        }
    }

}

- (void)RemoveFile:(NSString *)filename {

    NSString *fid = [driveFilesInAppDirectory objectForKey:filename];
    
    if (fid != nil) {
        
        [[[[odClient drive] items:fid] request] deleteWithCompletion:^(NSError *error){
            //Returns an error if there was one.
            
            bool deleteSuccess = (error == nil);
            
            if (error) {
                NSLog(@"OneDrive delete error: %@",error);
            }
            
            if (fileDelegate) {
                [fileDelegate FileDeleted:deleteSuccess];
            }
        }];
    }
    else {
        
        //File does not exist
        if (fileDelegate) {
            [fileDelegate FileDeleted:YES];
        }
    }

}

- (void)cancelDownload {
    
}

- (void)cancelUpload {
    
}

@end

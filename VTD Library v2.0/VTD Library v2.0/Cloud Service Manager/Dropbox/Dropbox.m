//
//  Dropbox.m
//  TRF
//
//  Created by Francis Bowen on 10/2/13.
//  Copyright (c) 2013 Voluta Tattoo Digital. All rights reserved.
//

#import "Dropbox.h"

@implementation Dropbox

@synthesize delegate;
@synthesize listingDelegate;
@synthesize uploadDelegate;
@synthesize downloadDelegate;
@synthesize uploadPercentageDelegate;
@synthesize downloadPercentageDelegate;

- (void)initDropbox
{
    //Authenticate user
    //Dropbox info
    
    [DBClientsManager setupWithAppKey:[delegate GetDropboxClientID]];
    
    currentFileDownloading = @"";
}

- (void)LinkDropbox:(UIViewController *)rootVC
{
    [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                        controller:rootVC
                                           openURL:^(NSURL *url) {
                                               [[UIApplication sharedApplication] openURL:url];
                                           }];
}

- (void)UnlinkDropbox
{
    [DBClientsManager unlinkAndResetClients];
}

- (BOOL)isAuthorized
{
    return ([DBClientsManager authorizedClient] != nil);
}

- (BOOL)handleOpenURL:(NSURL *)url {
    
    DBOAuthCompletion completion = ^(DBOAuthResult *authResult) {
      if (authResult != nil) {
        if ([authResult isSuccess]) {
          NSLog(@"\n\nSuccess! User is logged into Dropbox.\n\n");
        } else if ([authResult isCancel]) {
          NSLog(@"\n\nAuthorization flow was manually canceled by user!\n\n");
        } else if ([authResult isError]) {
          NSLog(@"\n\nError: %@\n\n", authResult);
        }
      }
    };
    BOOL canHandle = [DBClientsManager handleRedirectURL:url completion:completion];
    
    return canHandle;
        
}

- (void)uploadSmallFile:(NSString *)filename toDest:(NSString *)destDir fromPath:(NSString *)pdfFileNameFullPath
{
    NSLog(@"Dropbox uploading small file");
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    _filename = filename;
    _destDir = destDir;
    _sourcePathAndFilename = pdfFileNameFullPath;
    
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:_sourcePathAndFilename];
    
    sourceFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:pdfFileNameFullPath error:nil] fileSize];
    
    uploadErrorCount = 0;

    [[[client.filesRoutes uploadData:[NSString stringWithFormat:@"/%@",filename] inputData:fileData]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESUploadError *routeError, DBRequestError *networkError) {

          if (result) {
              
              NSLog(@"%@\n", result);
              
              NSLog(@"File uploaded to dropbox successfully to path");
              
              if (uploadDelegate)
              {
                  [uploadDelegate DropboxUploadComplete:true];
              }
              
          } else {
              
              NSLog(@"File upload failed with error - %@", routeError);
              NSLog(@"File upload failed with network - %@", networkError);
              
              if (uploadDelegate)
              {
                  [uploadDelegate DropboxUploadComplete:false];
              }
          }
          
      }] setProgressBlock:^(int64_t uploaded, int64_t total, int64_t expectedTotal) {
          
          //NSLog(@"Uploaded: %lld  UploadedTotal: %lld  ExpectedToUploadTotal: %lld", uploaded, total, expectedTotal);
          
          CGFloat progress = ((CGFloat)(total) / (CGFloat)(expectedTotal));
          
          if (uploadPercentageDelegate)
          {
              [uploadPercentageDelegate UploadPercentageUpdate:progress];
          }
      }];
    
}

- (void)uploadLargeFile:(NSString *)filename toDest:(NSString *)destDir fromPath:(NSString *)pdfFileNameFullPath
{
    NSLog(@"Dropbox uploading large file");

    DBUserClient *client = [DBClientsManager authorizedClient];
    
    _filename = filename;
    _destDir = destDir;
    _sourcePathAndFilename = pdfFileNameFullPath;
    
    sourceFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:pdfFileNameFullPath error:nil] fileSize];
    
    uploadErrorCount = 0;
    
    NSMutableDictionary<NSURL *, DBFILESCommitInfo *> *uploadFilesUrlsToCommitInfo = [NSMutableDictionary new];

    DBFILESCommitInfo *commitInfo = [[DBFILESCommitInfo alloc] initWithPath:[NSString stringWithFormat:@"/%@",filename]
                                                                       mode:[[DBFILESWriteMode alloc] initWithOverwrite]
                                                                 autorename:nil
                                                             clientModified:nil
                                                                       mute:nil
                                                             propertyGroups:nil
                                                             strictConflict:nil];

    [uploadFilesUrlsToCommitInfo setObject:commitInfo forKey:[NSURL fileURLWithPath:pdfFileNameFullPath]];
    
    _UploadTask = [client.filesRoutes batchUploadFiles:uploadFilesUrlsToCommitInfo
                              queue:nil
                      progressBlock:^(int64_t uploaded, int64_t total, int64_t expectedTotal) {
                          
                          //NSLog(@"Uploaded: %lld  UploadedTotal: %lld  ExpectedToUploadTotal: %lld", uploaded, total, expectedTotal);
                          
                          CGFloat progress = ((CGFloat)(total) / (CGFloat)(expectedTotal));
                          
                          if (uploadPercentageDelegate)
                          {
                              [uploadPercentageDelegate UploadPercentageUpdate:progress];
                          }
                          
                      } responseBlock:^(NSDictionary<NSURL *, DBFILESUploadSessionFinishBatchResultEntry *> *fileUrlsToBatchResultEntries,
                                        DBASYNCPollError *finishBatchRouteError, DBRequestError *finishBatchRequestError,
                                        NSDictionary<NSURL *, DBRequestError *> *fileUrlsToRequestErrors) {
                          
                          if (fileUrlsToBatchResultEntries) {
                              
                              NSLog(@"%@\n", fileUrlsToBatchResultEntries);
                              
                              NSLog(@"File uploaded to dropbox successfully to path");
                              
                              if (uploadDelegate)
                              {
                                  [uploadDelegate DropboxUploadComplete:true];
                              }
                              
                          } else {
                              
                              NSLog(@"File upload failed with error - %@", finishBatchRequestError);
                              
                              if (uploadDelegate)
                              {
                                  [uploadDelegate DropboxUploadComplete:false];
                              }
                          }
                      }];
}

- (void)RemoveFile:(NSString *)filename {
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    [[client.filesRoutes delete_:[NSString stringWithFormat:@"\%@",filename]]
     setResponseBlock:^(DBFILESMetadata *result, DBFILESDeleteError *routeError, DBRequestError *error) {
         if (result) {
             
             NSLog(@"%@\n", result);
             
             if (uploadDelegate) {
                 [uploadDelegate FileDeleted:YES];
             }
             
         } else {
             // Error is with the route specifically (status code 409)
             if (routeError) {
                 if ([routeError isPathLookup]) {
                     // Can safely access this field
                     DBFILESLookupError *pathLookup = routeError.pathLookup;
                     NSLog(@"%@\n", pathLookup);
                 } else if ([routeError isPathWrite]) {
                     DBFILESWriteError *pathWrite = routeError.pathWrite;
                     NSLog(@"%@\n", pathWrite);
                     
                     // This would cause a runtime error
                     // DBFILESLookupError *pathLookup = routeError.pathLookup;
                 }
             }
             NSLog(@"%@\n%@\n", routeError, error);
             
             if (uploadDelegate) {
                 [uploadDelegate FileDeleted:NO];
             }
         }
     }];
    
}

- (void)getFileListing
{
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    [[client.filesRoutes listFolder:@""]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
         
         if (result) {

             fileList = [[NSMutableArray alloc] init];

             for (DBFILESMetadata *file in result.entries) {
                 
                 [fileList addObject:file.name];
                 
             }

             if ([result.hasMore boolValue]) {

                 NSLog(@"More pages exist...");
                 [self getFileListingContinue:client cursor:result.cursor];

             }
             else {

                 if ([fileList count] > 0) {

                     fileList = [fileList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                 }

                 if (listingDelegate) {
                     [listingDelegate DropboxFileListingComplete:true withList:fileList];
                 }

             }

         }
         else {
             
             NSLog(@"Error loading metadata: %@", error);
             
             if (listingDelegate) {
                 [listingDelegate DropboxFileListingComplete:false withList:nil];
             }
             
         }
     }];
}

- (void)getFileListingContinue:(DBUserClient *)client cursor:(NSString *)cursor {

    [[client.filesRoutes listFolderContinue:cursor]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderContinueError *routeError,
                        DBRequestError *networkError) {
         if (result) {

             NSLog(@"Got another page");

             NSString *cursor = result.cursor;
             BOOL hasMore = [result.hasMore boolValue];

             for (DBFILESMetadata *file in result.entries) {

                 [fileList addObject:file.name];

             }

             if (hasMore) {
                 [self getFileListingContinue:client cursor:cursor];
             } else {
                 NSLog(@"List folder complete.");
             }
         } else {
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
     }];
}

- (void)downloadFile:(NSString *)filename intoPath:(NSString *)destPath
{
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    currentFileDownloading = [NSString stringWithFormat:@"/%@",filename];
    
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //NSURL *outputDirectory = [NSURL URLWithString:destPath];
    
    NSString *outputstr = [NSString stringWithFormat:@"%@/%@",destPath,filename];
    NSURL *outputUrl = [NSURL fileURLWithPath:outputstr];
    
    _DownloadTask =  [[[client.filesRoutes downloadUrl:[NSString stringWithFormat:@"/%@",filename] overwrite:YES destination:outputUrl]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *error, NSURL *destination) {
          
          if (result) {
              NSLog(@"%@\n", result);
              
              NSLog(@"File loaded into path: %@", destPath);
              
              currentFileDownloading = @"";
              
              if (downloadDelegate) {
                  [downloadDelegate DropboxDownloadComplete:true];
              }

          } else {
              
              NSLog(@"%@\n%@\n", routeError, error);
              
              NSLog(@"There was an error loading the file - %@", error);
              
              if (downloadDelegate) {
                  [downloadDelegate DropboxDownloadComplete:false];
              }
          }
          
      }] setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
          
          //NSLog(@"%lld\n%lld\n%lld\n", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload);
      
          CGFloat progress = ((CGFloat)(totalBytesDownloaded) / (CGFloat)(totalBytesExpectedToDownload));
          
          if (downloadPercentageDelegate) {
              
              [downloadPercentageDelegate DownloadPercentageUpdate:progress];
          }
      
      }];

}

- (void)cancelDownload
{
    if (![currentFileDownloading isEqualToString:@""] && _DownloadTask)
    {
        [_DownloadTask cancel];
        
        if (downloadDelegate) {
            [downloadDelegate DropboxDownloadComplete:NO];
        }
    }

}

- (void)cancelUpload {

    if (_UploadTask) {
        
        [_UploadTask cancel];
        
        if (uploadDelegate) {
            [uploadDelegate DropboxUploadComplete:NO];
        }
    }

}

@end

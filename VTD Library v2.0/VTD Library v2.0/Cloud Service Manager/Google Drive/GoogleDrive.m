//
//  GoogleDrive.m
//  DIO Tattoo Forms
//
//  Created by Francis Bowen on 1/18/13.
//
//

#import "GoogleDrive.h"

/*! @brief The OIDC issuer from which the configuration will be discovered.
 */
static NSString *const kIssuer = @"https://accounts.google.com";

/*! @brief The OAuth client ID.
 @discussion For Google, register your client at
 https://console.developers.google.com/apis/credentials?project=_
 The client should be registered with the "iOS" type.
 */
static NSString *const kClientID = @"YOUR_CLIENT.apps.googleusercontent.com";

/*! @brief The OAuth redirect URI for the client @c kClientID.
 @discussion With Google, the scheme of the redirect URI is the reverse DNS notation of the
 client ID. This scheme must be registered as a scheme in the project's Info
 property list ("CFBundleURLTypes" plist key). Any path component will work, we use
 'oauthredirect' here to help disambiguate from any other use of this scheme.
 */
static NSString *const kRedirectURI =
@"com.googleusercontent.apps.YOUR_CLIENT:/oauthredirect";

static NSString *const kSuccessURLString = @"http://openid.github.io/AppAuth-iOS/redirect/";
static NSString *const kKeychainItemName = @"Voluta Google Drive";

@implementation GoogleDrive

@synthesize driveService;
@synthesize driveFile;
@synthesize delegate;
@synthesize downloadDelegate;
@synthesize uploadProgressDelegate;
@synthesize downloadProgressDelegate;
@synthesize uploadDelegate;
@synthesize listingDelegate;

- (GTLRDriveService *)driveService {
    static GTLRDriveService *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLRDriveService alloc] init];
        
        // Turn on the library's shouldFetchNextPages feature to ensure that all items
        // are fetched.  This applies to queries which return an object derived from
        // GTLRCollectionObject.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;
    });
    return service;
}

-(void)initGoogleDrive
{
    cancelingDownload = false;
    _isDeletingFile = NO;
    
    // Initialize the drive service & load existing credentials from the keychain if available
    
    _authorization =
    [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:kKeychainItemName];
    
    self.driveService.authorizer = _authorization;
    
    [self CheckForExpiredGoogleDriveToken];
    
}

-(void)UnlinkGoogleDrive
{

    if ([self isAuthorized])
    {
        
        GTLRDriveService *service = self.driveService;
        
        [GTMAppAuthFetcherAuthorization
         removeAuthorizationFromKeychainForName:kKeychainItemName];
        
        service.authorizer = nil;
        _authorization = nil;

    }

}

-(void)LinkGoogleDrive:(UIViewController *)ParentVC;
{
    if (![self isAuthorized])
    {
        NSLog(@"Google drive is not linked, setting up login now");
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        
        [self authWithAutoCodeExchange:nil withParentVC:ParentVC];
        
    }
    else {
        
        NSLog(@"Google drive already linked");
    }
    
}

- (void)saveState {
    
    if (_authorization.canAuthorize) {
        
        [GTMAppAuthFetcherAuthorization saveAuthorization:_authorization
                                        toKeychainForName:kKeychainItemName];
    } else {
        
        _authorization = nil;
        self.driveService.authorizer = nil;
        [GTMAppAuthFetcherAuthorization removeAuthorizationFromKeychainForName:kKeychainItemName];
    }
}


// Create sign-in

- (void)authWithAutoCodeExchange:(nullable id)sender
                    withParentVC:(UIViewController *)ParentVC {
    
    NSString *clientid = [delegate GetGoogleDriveClientID];

    NSString *clientID = [kClientID stringByReplacingOccurrencesOfString:@"YOUR_CLIENT" withString:clientid];
    NSString *clientredirect = [kRedirectURI stringByReplacingOccurrencesOfString:@"YOUR_CLIENT" withString:clientid];
    
    NSURL *issuer = [NSURL URLWithString:kIssuer];
    NSURL *redirectURI = [NSURL URLWithString:clientredirect];
    
    // discovers endpoints
    [OIDAuthorizationService
     discoverServiceConfigurationForIssuer:issuer
     completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
         
         if (!configuration) {
             
             NSLog(@"discoverServiceConfigurationForIssuer error: %@", [error localizedDescription]);
             
             driveService.authorizer = nil;
             
             return;
         }
         
         NSLog(@"discoverServiceConfigurationForIssuer config: %@", configuration);
         
         // builds authentication request
         NSArray<NSString *> *scopes = @[ kGTLRAuthScopeDrive, kGTLRAuthScopeDriveAppdata, kGTLRAuthScopeDriveFile, kGTLRAuthScopeDriveMetadata, OIDScopeOpenID, OIDScopeProfile];
         
         OIDAuthorizationRequest *request =
         [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                       clientId:clientID
                                                         scopes:scopes
                                                    redirectURL:redirectURI
                                                   responseType:OIDResponseTypeCode
                                           additionalParameters:nil];
         // performs authentication request
         //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
         NSLog(@"Initiating authorization request with scope: %@", request.scope);
         
        id<OIDExternalUserAgentSession> currentAuthorizationFlow =
         [OIDAuthState
          authStateByPresentingAuthorizationRequest:request
          presentingViewController:ParentVC
          callback:^(OIDAuthState *_Nullable authState,
                     NSError *_Nullable error) {
              if (authState) {
                  
                  _authorization =
                  [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                  
                  driveService.authorizer = _authorization;
                  
                  NSLog(@"Got authorization tokens. Access token: %@",
                        authState.lastTokenResponse.accessToken);
                  
                  [self saveState];
                  
                  _authorization =
                  [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:kKeychainItemName];
                  
                  self.driveService.authorizer = _authorization;
                  
                  [self CheckForExpiredGoogleDriveToken];
                  
                  if(delegate)
                      [delegate AuthComplete:true];
                  
              } else {
                  
                  _authorization = nil;
                  driveService.authorizer = nil;
                  
                  [self saveState];
                  
                  NSLog(@"Authorization error: %@", [error localizedDescription]);
                  
                  if(delegate)
                      [delegate AuthComplete:false];
              }
          }];
         
         [delegate SetAuthorizationFlow:currentAuthorizationFlow];
         
     }];
}

// Helper to check if user is authorized
- (BOOL)isAuthorized
{
    return [_authorization canAuthorize];
}

- (void)CheckForExpiredGoogleDriveToken {
    
    //Check for expired access token
    NSDate *date = [NSDate date];
    
    NSDate *tokenexpir = _authorization.authState.lastTokenResponse.accessTokenExpirationDate;
    
    if ([tokenexpir compare:date] == NSOrderedAscending || tokenexpir == nil) {
     
        NSLog(@"Access token is expired");

        NSLog(@"Begin token fetch in CheckForExpiredGoogleDriveToken");
        
        // Obtains fresh tokens from AppAuth.
        [_authorization.authState performActionWithFreshTokens:^(NSString *_Nullable accessToken,
                                                                 NSString *_Nullable idToken,
                                                                 NSError *_Nullable error) {
            
            if (error == nil) {
                
                NSLog(@"Google drive token refreshed");
            }
            else {
                
                NSLog(@"Google drive token could not be refreshed: %@", error.localizedDescription);
            }
        }];

     
    }
    else {
     
        NSLog(@"Access token not expired");
    }
    
}


/*
// Creates the auth controller for authorizing access to Googel Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                                clientID:[delegate GetGoogleDriveClientID]
                                                            clientSecret:[delegate GetGoogleDriveClientSecret]
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        NSLog(@"Google Drive Auth failed: %@",error.localizedDescription);
        self.driveService.authorizer = nil;
        
        if(delegate)
            [delegate AuthComplete:false];
        
    }
    else
    {
        NSLog(@"Google Drive Auth Successful");
        self.driveService.authorizer = authResult;
        
        if(delegate)
            [delegate AuthComplete:true];
    }
}
*/

- (void)checkForFolder:(NSString *)folderName withTitle:(NSString *)title withFileHandle:(NSFileHandle *)filehandle
{

    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.q = [NSString stringWithFormat:
               @"mimeType='application/vnd.google-apps.folder' and name='%@' and trashed=false",
               folderName];
    
    [self.driveService executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRDrive_FileList *files,
                                      NSError *error) {
        if (error == nil)
        {
            if (files.files.count > 0)
            {
                //NSLog(@"%@ folder found", folderName);
                
                GTLRDrive_File *file = [files.files objectAtIndex:0];
                folderID = file.identifier;
                
                NSString *mime_type = [self GetMimeType:title];
                
                [self insertFileWithService:title
                                description:@"Voluta Digital Forms"
                                   parentId:folderID
                                   mimeType:mime_type
                             withFileHandle:filehandle
                            completionBlock:^(GTLRDrive_File *dFile, NSError *err)  {
                                
                                if (uploadDelegate) {
                                    [uploadDelegate GoogleDriveUploadComplete:true];
                                }
                                
                            }];
            
            }
            else
            {
                //NSLog(@"%@ folder not found", folderName);
                [self createFolder:folderName withTitle:title withFileHandle:filehandle];
            }

        }
        else
        {
            NSLog(@"error checking for google directory: %@", error);
            
            if (uploadDelegate) {
                [uploadDelegate GoogleDriveUploadComplete:false];
            }

        }
    }];

}

- (void)createFolder:(NSString *)folderName withTitle:(NSString *)title withFileHandle:(NSFileHandle *)filehandle
{
    
    GTLRDrive_File *folderObj = [GTLRDrive_File object];
    folderObj.name = folderName;
    folderObj.originalFilename = folderName;
    folderObj.mimeType = @"application/vnd.google-apps.folder";

    
    GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:folderObj
                                                                   uploadParameters:nil];
    
    GTLRDriveService *service = self.driveService;
    
    [service executeQuery:query
        completionHandler:^(GTLRServiceTicket *ticket,
                            GTLRDrive_File *folderItem,
                            NSError *error) {
            
            if(error != nil)
            {
            
                NSLog(@"createFolder error: %@", error);
            
                if (uploadDelegate) {
                    [uploadDelegate GoogleDriveUploadComplete:false];
                }
                
            }
            else
            {
                folderID = folderItem.identifier;
                
                NSString *file_ext = [title pathExtension];
                file_ext = [file_ext lowercaseString];
                
                NSString *mime_type = [self GetMimeType:title];
                
                [self insertFileWithService:title
                                description:@"Voluta Digital Forms"
                                   parentId:folderID
                                   mimeType:mime_type
                             withFileHandle:filehandle
                            completionBlock:^(GTLRDrive_File *dFile, NSError *err) {
                                
                                if (uploadDelegate) {
                                    [uploadDelegate GoogleDriveUploadComplete:true];
                                }
                                
                            }];
                

            }
            
        }];
}

- (void)getFileListing:(NSString *)folder
{
    if (!fileList) {
        fileList = [[NSMutableArray alloc] init];
    }
    
    [fileList removeAllObjects];
    
    //First check for app folder
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.q = [NSString stringWithFormat:
               @"mimeType='application/vnd.google-apps.folder' and name='%@' and trashed=false",
               folder];
    
    [self.driveService executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRDrive_FileList *files,
                                      NSError *error) {
        if (error == nil)
        {
            if (files.files.count > 0)
            {
                //NSLog(@"%@ folder found", folderName);
                
                GTLRDrive_File *file = [files.files objectAtIndex:0];
                folderID = file.identifier;
                
                //Found app folder, now query for files in folder
                GTLRDriveQuery_FilesList *query2 = [GTLRDriveQuery_FilesList query];
                query2.q = [NSString stringWithFormat:@"'%@' IN parents", folderID];
                query2.fields = @"nextPageToken, files(id, name, size)";
                query2.pageSize = 1000;

                self.driveService.shouldFetchNextPages = true;

                [self.driveService executeQuery:query2
                              completionHandler:^(GTLRServiceTicket *ticket2,
                                                  GTLRDrive_FileList *files2,
                                                  NSError *error2) {

                                  if (!driveFilesInAppDirectory) {
                                      driveFilesInAppDirectory = [[GTLRDrive_FileList alloc] init];
                                  }

                                  if (error2 == nil)
                                  {

                                      driveFilesInAppDirectory = files2;

                                      if (_isDeletingFile) {

                                          bool fileFound = NO;
                                          NSString *FileToDeleteID = @"";

                                          for (GTLRDrive_File *file2 in files2.files) {

                                              if ([_FileToDelete isEqualToString:file2.name]) {
                                                  fileFound = YES;
                                                  FileToDeleteID = file2.identifier;
                                                  break;
                                              }
                                          }

                                          if (fileFound) {

                                              GTLRDriveQuery_FilesDelete *deletequery = [GTLRDriveQuery_FilesDelete queryWithFileId:FileToDeleteID];
                                              [self.driveService executeQuery:deletequery
                                                            completionHandler:^(GTLRServiceTicket *deleteticket,
                                                                                GTLRDrive_FileList *files,
                                                                                NSError *deleteerror) {

                                                                _isDeletingFile = NO;

                                                                if (uploadDelegate) {
                                                                    [uploadDelegate FileDeleted:(deleteerror == nil)];
                                                                }
                                                            }];

                                          }
                                          else {

                                              if (uploadDelegate) {
                                                  [uploadDelegate FileDeleted:YES];
                                              }
                                          }

                                      }
                                      else {

                                          for (GTLRDrive_File *file2 in files2.files) {
                                              [fileList addObject:file2.name];
                                          }

                                          if(files2.nextPageToken != nil) {
                                              NSLog(@"There's another page, continuing...");
                                              [self getFileListingContinue:query2];
                                          }
                                          else {

                                              if (fileList != nil && [fileList count] > 0) {

                                                  fileList = [[fileList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
                                              }

                                              if (listingDelegate) {
                                                  [listingDelegate GoogleDriveFileListingComplete:true withList:fileList];
                                              }
                                          }

                                      }

                                  }
                                  else
                                  {
                                      NSLog(@"Error getting gDrive file list: %@", error2);

                                      if (listingDelegate) {
                                          [listingDelegate GoogleDriveFileListingComplete:false withList:nil];
                                      }
                                  }

                              }];
                
            }
            else
            {
                NSLog(@"App folder not found, creating folder");
                
                GTLRDrive_File *folderObj = [GTLRDrive_File object];
                folderObj.name = folder;
                folderObj.originalFilename = folder;
                folderObj.mimeType = @"application/vnd.google-apps.folder";
                
                GTLRDriveQuery_FilesCreate *query3 = [GTLRDriveQuery_FilesCreate queryWithObject:folderObj
                                                                                uploadParameters:nil];
                [self.driveService executeQuery:query3
                              completionHandler:^(GTLRServiceTicket *ticket3,
                                                  GTLRDrive_File *folderItem,
                                                  NSError *error3) {
                        

                        if (error3 == nil)
                        {
                            NSLog(@"Folder created on google drive");
                            folderID = folderItem.identifier;
                        }
                        else {
                            
                            NSLog(@"Error creating folder on google drive: %@", [error3 localizedDescription]);
                        }
                        
                    }];
                
                if (listingDelegate && !_isDeletingFile) {
                    [listingDelegate GoogleDriveFileListingComplete:true withList:fileList];
                }
                else if (uploadDelegate && _isDeletingFile) {
                    [uploadDelegate FileDeleted:YES];
                }

            }
            
        }
        else
        {
            NSLog(@"error checking for google directory: %@", error);
            
            if (_isDeletingFile) {
                
                _isDeletingFile = NO;
                
                if (uploadDelegate) {
                    [uploadDelegate FileDeleted:NO];
                }
            }
            else {
                
                if (listingDelegate) {
                    [listingDelegate GoogleDriveFileListingComplete:false withList:nil];
                }
            }
            
        }
    }];
    
}

- (void)getFileListingContinue:(GTLRDriveQuery_FilesList *)query {

    [self.driveService executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRDrive_FileList *files,
                                      NSError *error) {
                      if (error == nil) {

                          for (GTLRDrive_File *file in files.files) {
                              [fileList addObject:file.name];
                          }

                          if(files.nextPageToken != nil) {
                              NSLog(@"There's another page, continuing...");
                              [self getFileListingContinue:query];
                          }
                          else {

                              if (fileList != nil && [fileList count] > 0) {

                                  fileList = [[fileList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
                              }

                              if (listingDelegate) {
                                  [listingDelegate GoogleDriveFileListingComplete:true withList:fileList];
                              }
                          }
                      }


                  }];

}

- (void)downloadFile:(NSString *)fileName intoPath:(NSString *)destPath
{

    for (GTLRDrive_File *file in driveFilesInAppDirectory.files) {
       
        if ([file.name isEqualToString:fileName])
        {
            cancelingDownload = false;
            downloadPath = destPath;
            
            [self downloadFileContentWithService:file completionBlock:^(NSData *fileData, NSError *error)
             {
                 if (error)
                 {
                     NSLog(@"Google Drive file download failed : %@", error);
                     
                     if (downloadDelegate) {
                         [downloadDelegate GoogleDriveDownloadComplete:false];
                     }
                 }
                 else
                 {
                     
                     
                     if (!cancelingDownload) {
                         
                         NSLog(@"Google Drive file download success");
                         [fileData writeToFile:destPath atomically:false];
                     }
                     else {
                         
                         NSLog(@"Canceled download");
                     }
                     
                     
                     if (downloadDelegate) {
                         
                         if (cancelingDownload)
                         {
                             [downloadDelegate GoogleDriveDownloadComplete:false];
                         }
                         else
                         {
                             [downloadDelegate GoogleDriveDownloadComplete:true];
                         }
                         
                     }
                     
                     cancelingDownload = false;
                 }
                 
                 
             }];
        }
    }
    

}

- (void)cancelDownload
{
    cancelingDownload = true;
    
    [_fetcher stopFetching];
    
    if (downloadDelegate) {
        
        [downloadDelegate GoogleDriveDownloadComplete:false];
    }
    
}

- (void)cancelUpload {
    
    [uploadTicket cancelTicket];
}

- (void)downloadFileContentWithService:(GTLRDrive_File *)file
                       completionBlock:(void (^)(NSData *, NSError *))completionBlock {
    
    if (file.identifier != nil) {
        

        //check if file exists
        _DownloadedFilenameAndPath = [NSString stringWithFormat:@"%@/%@", downloadPath, file.name];
        
        _DownloadedPath = downloadPath;
        
        if (![[NSFileManager defaultManager]
              fileExistsAtPath:_DownloadedFilenameAndPath]) {
            
            GTLRDriveService *service = self.driveService;
            
            GTLRQuery *query;
            
            query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:file.identifier];
            
            _FileSize = file.size;
            _NumBytesInFile = [_FileSize longLongValue];
            _CurrentOffset = 0;
            _CurrentIteration = 0;
            
            _DownloadRequest = [service requestForQuery:query];
            
            _DownloadedFilename = file.name;
            
            [self DownloadPartial:completionBlock];
            

        }
        else {
            
            completionBlock(nil, nil);
        }
        
        
    } else {
        completionBlock(nil,
                        [NSError errorWithDomain:NSURLErrorDomain
                                            code:NSURLErrorBadURL
                                        userInfo:nil]);
    }
}

- (void)DownloadPartial:(void (^)(NSData *, NSError *))completionBlock {
    
    GTLRDriveService *service = self.driveService;
    
    NSMutableURLRequest* request = [_DownloadRequest mutableCopy];
    
    //---------------- setting range for download resume -----------------------
    _EndOffset = _NumBytesInFile - 1;
    
    if (_CurrentOffset + PARTIAL_FILE_SIZE < _NumBytesInFile) {
        
        _EndOffset = _CurrentOffset + PARTIAL_FILE_SIZE - 1;
    }
    
    NSString* range = [NSString stringWithFormat:@"bytes=%@-%@",
                       [[NSNumber numberWithLongLong:_CurrentOffset] stringValue],
                       [[NSNumber numberWithLongLong:_EndOffset] stringValue]];
    
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    _fetcher = [service.fetcherService fetcherWithRequest:request];
    _fetcher.retryEnabled = YES;
    _fetcher.maxRetryInterval = 600;
    _fetcher.retryBlock = ^(BOOL suggestedWillRetry, NSError *error,
                            GTMSessionFetcherRetryResponse response) {
        // Perhaps examine error.domain and error.code, fetcher.request, or fetcher.retryCount
        //
        // Respond with YES to start the retry timer, NO to proceed to the failure
        // callback, or suggestedWillRetry to get default behavior for the
        // current error domain and code values.
        
        NSString *willretry = @"Yes";
        
        if (!suggestedWillRetry) {
            willretry = @"No";
        }
        
        NSLog(@"GTMSessionFetcher retry block: %@\nWill retry: %@", error.localizedDescription, willretry);
        
        response(suggestedWillRetry);
        
    };
    
    NSString *filename = [NSString stringWithFormat:@"pd%d",_CurrentIteration];
    
    [_fetcher setCommentWithFormat:@"Downloading %@", filename];
    _fetcher.destinationFileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", downloadPath, filename]];
    [_fetcher setRetryEnabled:YES];
    
    __weak typeof(self) weakSelf = self;
    
    [_fetcher setDownloadProgressBlock:^(int64_t bytesWritten,
                                         int64_t totalBytesWritten,
                                         int64_t totalBytesExpectedToWrite)
     {
         
         float percent = ((float)(totalBytesWritten + _CurrentIteration * PARTIAL_FILE_SIZE) / (float)_NumBytesInFile);
         
         if (weakSelf.downloadProgressDelegate && !cancelingDownload)
         {
             [weakSelf.downloadProgressDelegate DownloadPercentageUpdate:percent];
         }
         
     }];

    
    [_fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        
        if (error == nil) {
            NSLog(@"Retrieved file content");
            
            _CurrentIteration++;
        
            if (_EndOffset == (_CurrentOffset + PARTIAL_FILE_SIZE - 1)) {
                
                _CurrentOffset = _EndOffset + 1;
                [self DownloadPartial:completionBlock];
            }
            else {
                
                //Assemble all partial downloads
                [self AssemblePartialDownloads];
                
                completionBlock(nil, nil);
            }
            
        } else {
            
            NSLog(@"An error occurred: %@", error);
            completionBlock(nil, error);
        }
        
    }];
    
}

- (bool)AssemblePartialDownloads {
    
    bool success = NO;
    
    for (int i = 0; i < _CurrentIteration ; i++) {
        
        @autoreleasepool {
            
            NSFileManager *fm = [NSFileManager defaultManager];
            
            NSString *currentfn = [NSString stringWithFormat:@"pd%d",i];
            NSString *fnpath = [NSString stringWithFormat:@"%@/%@",_DownloadedPath,currentfn];
            
            if ([fm fileExistsAtPath:fnpath]) {
                
                NSData *pd = [NSData dataWithContentsOfFile:fnpath];
                
                if (i == 0) {
                    
                    [pd writeToFile:_DownloadedFilenameAndPath atomically:YES];
                    
                
                }
                else {
                    
                    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:_DownloadedFilenameAndPath];
                    [fh seekToEndOfFile];
                    [fh writeData:pd];
                }
                
                [fm removeItemAtPath:fnpath error:nil];
                
            }
            else {
                
                return NO;
            }
            
        }
        
    }
    
    success = YES;
    
    return success;
}

- (void)uploadFile:(NSFileHandle *)filehandle withTitle:(NSString *)title
{
    [self checkForFolder:[delegate GetAppFolderName] withTitle:title withFileHandle:filehandle];
}

- (void)insertFileWithService:(NSString *)title
                  description:(NSString *)description
                     parentId:(NSString *)parentId
                     mimeType:(NSString *)mimeType
               withFileHandle:(NSFileHandle *)filehandle
              completionBlock:(void (^)(GTLRDrive_File *, NSError *))completionBlock {
    
    GTLRDriveService *service = self.driveService;
    
    GTLRDrive_File *file = [GTLRDrive_File object];
    
    file.name = title;
    file.originalFilename = title;
    file.descriptionProperty = description;
    file.mimeType = mimeType;
    
    if(parentId != nil)
    {
        file.parents = @[ parentId ];
    }
    
    GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithFileHandle:filehandle MIMEType:mimeType];
    
    GTLRDriveQuery_FilesCreate *query = [GTLRDriveQuery_FilesCreate queryWithObject:file
                                                                   uploadParameters:uploadParameters];
    
    __weak typeof(self) weakSelf = self;
    
    query.executionParameters.uploadProgressBlock = ^(GTLRServiceTicket *callbackTicket,
                                                      unsigned long long numberOfBytesRead,
                                                      unsigned long long dataLength) {
        
        float percent = ((double)numberOfBytesRead / (double)dataLength);
        
        if (weakSelf.uploadProgressDelegate)
        {
            [weakSelf.uploadProgressDelegate UploadPercentageUpdate:percent];
        }

    };
    
    // queryTicket can be used to track the status of the request, more information can
    // be found on https://code.google.com/p/google-api-objectivec-client/wiki/Introduction#Uploading_Files
    uploadTicket = [service executeQuery:query
                       completionHandler:^(GTLRServiceTicket *ticket,
                                           GTLRDrive_File *insertedFile,
                                           NSError *error) {
                           
                                             if (error == nil) {
                                                 // Uncomment the following line to print the File ID.
                                                 // NSLog(@"File ID: %@", insertedFile.identifier);
                                                 NSLog(@"Google drive file uploaded successfully: %@",insertedFile.originalFilename);

                                                 if(completionBlock != nil)
                                                     completionBlock(insertedFile, nil);
                                                 
                                             } else {
                                                 NSLog(@"An error occurred: %@", error);
                                                 
                                                 if(completionBlock != nil)
                                                     completionBlock(nil, error);
                                             }
                                         }];
    
    
}

- (void)RemoveFile:(NSString *)filename {
    
    _isDeletingFile = YES;
    _FileToDelete = filename;
    
    [self getFileListing:[delegate GetAppFolderName]];
    
}

- (NSString *)GetMimeType:(NSString *)filename {
    
    NSString *file_ext = [filename pathExtension];
    file_ext = [file_ext lowercaseString];
    
    NSString *mime_type = @"";
    
    if ([file_ext isEqualToString:@"pdf"]) {
        
        mime_type = @"application/pdf";
        
    }
    else if ([file_ext isEqualToString:@"csv"]) {
        
        mime_type = @"text/csv";
    }
    else {
        
        mime_type = @"application/octet-stream";
    }
    
    return mime_type;
}

@end

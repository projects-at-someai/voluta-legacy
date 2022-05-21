//
//  Emailer.m
//  VTDLibrary
//
//  Created by Francis Bowen on 7/21/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "Emailer.h"

#import <GoogleSignIn/GoogleSignIn.h>

@implementation Emailer

@synthesize delegate;
@synthesize creddelegate;

- (id)initWithDelegate:(id<EmailerCredentialsDelegate>)cdelegate {

    self = [super init];
    
    if (self) {

        creddelegate = cdelegate;

        NSLog(@"Setting up google sign in");
        _config = [[GIDConfiguration alloc] initWithClientID:@"245989830177-2ueind3kb2qt9k78i1nvrcffcjg4de9v.apps.googleusercontent.com"];
        
        /*GIDSignIn.sharedInstance.scopes=[NSArray arrayWithObjects:@"https://www.googleapis.com/auth/gmail.send",@"https://www.googleapis.com/auth/gmail.readonly",@"https://www.googleapis.com/auth/gmail.modify", nil];
        */
        
        /*
        _authorization =
        [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:[creddelegate GetOAuth2KeychainName]];

        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *usingEmailer = [defaults objectForKey:USING_EMAILER_KEY];
        
        if (_authorization.authState != nil && [_authorization.authState refreshToken] != nil) {
        
            //Get access token from refresh token
            NSLog(@"Begin token fetch in init");

            // Obtains fresh tokens from AppAuth.
            [_authorization.authState performActionWithFreshTokens:^(NSString *_Nullable accessToken,
                                                                     NSString *_Nullable idToken,
                                                                     NSError *_Nullable error) {
                
                _Email = [_authorization userEmail];
                _AccessToken = accessToken;
                
                if (error == nil) {
                    
                    NSLog(@"Google drive token refreshed");
                }
                else {
                    
                    NSLog(@"Google drive token could not be refreshed: %@", error.localizedDescription);

                }
            }];
        }
        else if ([usingEmailer isEqualToString:@"Yes"]) {

            [self startOAuth2:nil];
        }
        */
    }
    
    return self;
}

- (void)saveState {

    /*
    if (_authorization.canAuthorize) {
        
        [GTMAppAuthFetcherAuthorization saveAuthorization:_authorization
                                        toKeychainForName:[creddelegate GetOAuth2KeychainName]];
    } else {
        
        [GTMAppAuthFetcherAuthorization removeAuthorizationFromKeychainForName:[creddelegate GetOAuth2KeychainName]];
    }
    */
}

- (void)SendEmail:(NSString *)EmailSubject
    withEmailBody:(NSString *)EmailBody
          toEmail:(NSString *)ToEmailAddress
   withAttachment:(NSString *)AttachmentPath {

    /*
    if (ToEmailAddress == nil || [ToEmailAddress isEqualToString:@""]) {
        
        NSString *err = @"Missing To-address";
        
        NSLog(@"Error sending email: %@", err);
        
        if (delegate) {
            [delegate EmailerSendFailure:err];
        }
        
        _isSending = NO;
        
        return;
    }
    
    //signal that an email will attempt to be sent
    if (delegate) {
        [delegate EmailerAttemptingToSend];
    }
    
    _isSending = YES;
    
    //Check for expired access token
    NSDate *date = [NSDate date];
    
    if ([[_authorization.authState.lastTokenResponse accessTokenExpirationDate] compare:date] == NSOrderedAscending) {
        
        NSLog(@"Access token is expired");
        
        if (!_SavedEmail) {
            _SavedEmail = [[NSMutableDictionary alloc] init];
        }
        
        [_SavedEmail removeAllObjects];
        [_SavedEmail setObject:EmailSubject forKey:@"EmailSubject"];
        [_SavedEmail setObject:EmailBody forKey:@"EmailBody"];
        [_SavedEmail setObject:ToEmailAddress forKey:@"ToEmailAddress"];
        
        if (AttachmentPath != nil) {
            
            [_SavedEmail setObject:AttachmentPath forKey:@"AttachmentPath"];
        }
        
        NSLog(@"Begin token fetch in SendEmail");

        // Obtains fresh tokens from AppAuth.
        [_authorization.authState performActionWithFreshTokens:^(NSString *_Nullable accessToken,
                                                                 NSString *_Nullable idToken,
                                                                 NSError *_Nullable error) {
            
            if (error == nil) {
                
                NSLog(@"Google drive token refreshed");
                
                _AccessToken = accessToken;
                _Email = [_authorization userEmail];
                
                if (_isSending) {
                    
                    [self Send:EmailSubject withEmailBody:EmailBody toEmail:ToEmailAddress withAttachment:AttachmentPath];
                }
                
            }
            else {
                
                NSLog(@"Google drive token could not be refreshed: %@", error.localizedDescription);
                
                [delegate EmailerNotAuthenticated];
            }
        }];
        
        return;
    }

    [self Send:EmailSubject withEmailBody:EmailBody toEmail:ToEmailAddress withAttachment:AttachmentPath];
     */
}

- (void)Send:(NSString *)EmailSubject withEmailBody:(NSString *)EmailBody toEmail:(NSString *)ToEmailAddress withAttachment:(NSString *)AttachmentPath {

    // refresh token
    _AccessToken = @"";

    [GIDSignIn.sharedInstance restorePreviousSignInWithCallback:^(GIDGoogleUser *user, NSError *error){
        
        if(error != nil) {
            NSLog(@"restoring previous signin with emailer error: %@", error.localizedDescription);
        }
        else {
            
            NSDate *timeStart = [NSDate date];
            NSTimeInterval timeSinceStart=0;
            while([_AccessToken isEqualToString:@""] && timeSinceStart<10){//wait for new token but no longer than 10s should be enough
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                         beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];//1sec increment actually ~0.02s
                timeSinceStart = [[NSDate date] timeIntervalSinceDate:timeStart];
            }
            if (timeSinceStart>=10) {//timed out
                return;
            }

            //compose rfc2822 message AND DO NOT base64 ENCODE IT and DO NOT ADD {raw etc} TOO, put 'To:' 1st, add \r\n between the lines and double that before the actual text message
            NSString *message = [NSString stringWithFormat:@"To: %@\r\nFrom: %@\r\nSubject: %@\r\n\r\n%@", ToEmailAddress, _Email, EmailSubject, EmailBody];

            NSURL *userinfoEndpoint = [NSURL URLWithString:@"https://www.googleapis.com/upload/gmail/v1/users/me/messages/send?uploadType=media"];

            NSLog(@"%@", message);

            //create request
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:userinfoEndpoint];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[message dataUsingEncoding:NSUTF8StringEncoding]];//message is plain UTF8 string

            //add all headers into session config, maybe ok adding to request too
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            configuration.HTTPAdditionalHeaders = @{
             //@"api-key"       : @"api-key here, may not need it though",
             @"Authorization" : [NSString stringWithFormat:@"Bearer %@", _AccessToken],
             @"Content-type"  : @"message/rfc822",
             @"Accept"        : @"application/json",
             @"Content-Length": [NSString stringWithFormat:@"%lu", (unsigned long)[message length]]
             };
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

             // performs HTTP request
            NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request
                                                            completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                                // Handle response
                if (error == nil) {

                    NSLog(@"Successfully sent email!");

                    if (delegate) {
                        [delegate EmailerSendSuccess];
                    }
                }
                else {

                    if (delegate) {
                        [delegate EmailerSendFailure:error.localizedDescription];
                    }

                }
            }];

            [postDataTask resume];
            
        }
    }];
    
    
}

- (bool)isAuthorized {
    
    return [GIDSignIn.sharedInstance hasPreviousSignIn];
}

#pragma mark - Google OAuth2
- (void) startOAuth2:(UIViewController *)parentVC
{
    NSLog(@"Starting Google Sign In");
    
    __weak __auto_type weakSelf = self;
    [GIDSignIn.sharedInstance signInWithConfiguration:_config presentingViewController:parentVC callback:^(GIDGoogleUser * _Nullable user, NSError * _Nullable error) {
      __auto_type strongSelf = weakSelf;
        
      if (strongSelf == nil) { return; }

      if (error == nil) {
          _AccessToken = user.authentication.idToken; // Safe to send to the server
          _Email = user.profile.email;
        
        // ...
      } else {
        // ...
          _AccessToken = @"";
          _Email = @"";
          NSLog(@"%@", error.localizedDescription);
      }
    }];
    
}

-(void)UnlinkGmail
{
    
    [GIDSignIn.sharedInstance disconnectWithCallback:^(NSError *error){
        NSLog(@"discconect error: %@", error.localizedDescription);
    }];
    
}

- (NSString *)GetEmail {
    
    if (!_Email && [GIDSignIn.sharedInstance hasPreviousSignIn]) {
        
        _Email = [GIDSignIn.sharedInstance currentUser].profile.email;
    }
    
    return _Email;
}

@end

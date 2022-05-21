//
//  Emailer.h
//  VTDLibrary
//
//  Created by Francis Bowen on 7/21/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <MailCore/MailCore.h>
//#import <GTMOAuth2/GTMOAuth2ViewControllerTouch.h>
//#import <GTMOAuth2/GTMOAuth2Authentication.h>
//#import <GTMOAuth2/GTMOAuth2SignIn.h>

//#import "GTLRDrive.h"
//#import "GTMAppAuth.h"
//#import "AppAuth.h"

#import <GoogleSignIn/GoogleSignIn.h>

@protocol EmailerDelegate <NSObject>
@optional

- (void)EmailerAttemptingToSend;
- (void)EmailerSendSuccess;
- (void)EmailerSendFailure:(NSString *)ErrorMessage;

- (void)AuthComplete:(bool)success;
- (void)EmailerNotAuthenticated;

//- (void)SetAuthorizationFlow:(OIDAuthorizationService *)CurrentFlow;

@end

@protocol EmailerCredentialsDelegate <NSObject>
@optional

- (NSString *)GetGoogleDriveClientID;
- (NSString *)GetGoogleDriveClientSecret;
- (NSString *)GetOAuth2KeychainName;

@end

@interface Emailer : NSObject
{
    NSString *_Email;
    NSString *_AccessToken;
    
    bool _isSending;
    NSMutableDictionary *_SavedEmail;
    
    GIDConfiguration *_config;
    
    //GTMAppAuthFetcherAuthorization *_authorization;
}

- (id)initWithDelegate:(id<EmailerCredentialsDelegate>)adelegate;

- (bool)isAuthorized;

- (void)SendEmail:(NSString *)EmailSubject
    withEmailBody:(NSString *)EmailBody
          toEmail:(NSString *)ToEmailAddress
   withAttachment:(NSString *)AttachmentPath;

- (void)startOAuth2:(UIViewController *)parentVC;
- (void)UnlinkGmail;

- (NSString *)GetEmail;

@property (nonatomic, assign) id<EmailerDelegate> delegate;
@property (nonatomic, assign) id<EmailerCredentialsDelegate> creddelegate;

@end

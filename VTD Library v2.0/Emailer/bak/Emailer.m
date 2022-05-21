//
//  Emailer.m
//  VTDLibrary
//
//  Created by Francis Bowen on 7/21/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "Emailer.h"

@implementation Emailer

@synthesize delegate;
@synthesize creddelegate;

- (id)initWithDelegate:(id<EmailerCredentialsDelegate>)cdelegate {

    self = [super init];
    
    if (self) {

        creddelegate = cdelegate;
        _Auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:[creddelegate GetOAuth2KeychainName]
                                                                      clientID:[creddelegate GetGoogleDriveClientID]
                                                                  clientSecret:[creddelegate GetGoogleDriveClientSecret]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *usingEmailer = [defaults objectForKey:USING_EMAILER_KEY];
        
        if (_Auth != nil && [_Auth refreshToken] != nil) {
        
            //Get access token from refresh token
            NSLog(@"Begin token fetch in init");
            [_Auth beginTokenFetchWithDelegate:self
                             didFinishSelector:@selector(auth:finishedRefreshWithFetcher:error:)];
        }
        else if ([usingEmailer isEqualToString:@"Yes"]) {

            [self startOAuth2:nil];
        }
    }
    
    return self;
}

- (void)SendEmail:(NSString *)EmailSubject
    withEmailBody:(NSString *)EmailBody
          toEmail:(NSString *)ToEmailAddress
   withAttachment:(NSString *)AttachmentPath {
    
    _isSending = YES;
    
    //Check for expired access token
    NSDate *date = [NSDate date];
    
    if ([[_Auth expirationDate] compare:date] == NSOrderedAscending) {
        
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
        [_Auth beginTokenFetchWithDelegate:self
                         didFinishSelector:@selector(auth:finishedRefreshWithFetcher:error:)];
        
        return;
    }

    MCOSMTPSession * smtpSession = [[MCOSMTPSession alloc] init];
    
    smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = _Email; //saved value
    smtpSession.connectionType = MCOConnectionTypeTLS;
    smtpSession.password = nil; //nil
    smtpSession.OAuth2Token = _AccessToken; //saved value
    smtpSession.authType = MCOAuthTypeXOAuth2;
    
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    
    //From
    MCOAddress *fromAddress = [MCOAddress addressWithMailbox:_Email];
    [[builder header] setFrom:fromAddress];
    
    //To
    MCOAddress *toAddress = [MCOAddress addressWithMailbox:ToEmailAddress];
    NSMutableArray *to = [[NSMutableArray alloc] init];
    [to addObject:toAddress];
    [[builder header] setTo:to];
    
    //Subject
    [[builder header] setSubject:EmailSubject];
    
    //Body
    [builder setHTMLBody:EmailBody];
    
    //Attachment
    if (AttachmentPath != nil && ![AttachmentPath isEqualToString:@""]) {
        
        MCOAttachment *attachment = [MCOAttachment attachmentWithContentsOfFile:AttachmentPath];
        [builder addAttachment:attachment];
    }

    NSData * rfc822Data = [builder data];
    
    //Send it
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        
        _isSending = NO;
        
        if(error) {
            
            NSDictionary *userinfo = error.userInfo;
            
            NSString *err = [userinfo objectForKey:@"NSLocalizedDescription"];
            
            NSLog(@"Error sending email:%@", error);
            
            if (delegate) {
                [delegate EmailerSendFailure:err];
            }
            
        } else {
            NSLog(@"Successfully sent email!");
            
            if (delegate) {
                [delegate EmailerSendSuccess];
            }
            
        }
    }];

}

- (bool)isAuthorized {
    
    bool authorized = false;
    
    if (_Auth != nil) {
        authorized = [_Auth canAuthorize];
    }
    
    return authorized;
}

#pragma mark - Google OAuth2
- (void) startOAuth2:(UIViewController *)parentVC
{

    NSLog(@"Starting OAuth2 for emailer");
    
    if ([_Auth refreshToken] == nil && parentVC != nil) {
        GTMOAuth2ViewControllerTouch *windowController =
        [[GTMOAuth2ViewControllerTouch alloc] initWithScope:@"https://mail.google.com/"
                                                   clientID:[creddelegate GetGoogleDriveClientID]
                                               clientSecret:[creddelegate GetGoogleDriveClientSecret]
                                           keychainItemName:@"Gmail-OAuth2-key"
                                                   delegate:self
                                           finishedSelector:@selector(viewController:finishedWithAuth:error:)];
        
        [parentVC presentViewController:windowController animated:NO completion:nil];
        
    }
    else if ([_Auth refreshToken] != nil) {
        
        NSLog(@"Begin token fetch in startOAuth2");
        [_Auth beginTokenFetchWithDelegate:self
                         didFinishSelector:@selector(auth:finishedRefreshWithFetcher:error:)];
    }
    else {
    
        [delegate EmailerNotAuthenticated];
    }
}

- (void)auth:(GTMOAuth2Authentication *)auth
finishedRefreshWithFetcher:(GTMSessionFetcher *)fetcher
       error:(NSError *)error {
    
    [self viewController:nil finishedWithAuth:auth error:error];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error
{
    if (error != nil) {
        // Authentication failed
        _Email = nil;
        _AccessToken = nil;
        
        [delegate EmailerNotAuthenticated];
        
        return;
    }
    
    _Email = [auth userEmail];
    _AccessToken = [auth accessToken];
    
    if (viewController != nil) {
        
        [viewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    if (_isSending) {
        
        [self SendEmail:[_SavedEmail objectForKey:@"EmailSubject"]
          withEmailBody:[_SavedEmail objectForKey:@"EmailBody"]
                toEmail:[_SavedEmail objectForKey:@"ToEmailAddress"]
         withAttachment:[_SavedEmail objectForKey:@"AttachmentPath"]];
    }
}

-(void)UnlinkGmail
{
    
    if (_Auth != nil)
    {
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:[creddelegate GetOAuth2KeychainName]];
        _Auth = nil;
    }
    
}

- (NSString *)GetEmail {
    
    return [_Auth userEmail];
}

@end

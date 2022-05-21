//
//  AppDelegate.h
//  CRF
//
//  Created by Francis Bowen on 5/18/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedData.h"
#import "SettingsAndOptionsViewController.h"
#import "iVersion.h"
#import "Initializer.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <GoogleSignIn/GoogleSignIn.h>

@protocol OIDAuthorizationFlowSession;

@interface AppDelegate : UIResponder <
    UIApplicationDelegate,
    SharedDataDelegate,
    GIDSignInDelegate
>
{
    Initializer *_Initializer;
    
}
@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong, nullable) id<OIDExternalUserAgentSession> currentAuthorizationFlow;

//- (NSURL *)applicationDocumentsDirectory;


@end


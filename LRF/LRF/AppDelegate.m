//
//  AppDelegate.m
//  LRF
//
//  Created by Francis Bowen on 5/18/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize
{
    //example configuration
    [iVersion sharedInstance].appStoreID = 1035140118;
    [iVersion sharedInstance].remoteVersionsPlistURL = [NSString stringWithFormat:@"%@/ver/LRF/versions.plist",VTD_SERVER];
    [iVersion sharedInstance].localVersionsPlistPath = @"versions.plist";
    [iVersion sharedInstance].showOnFirstLaunch = NO;
    [iVersion sharedInstance].groupNotesByVersion = YES;
    [iVersion sharedInstance].checkPeriod = 1.0f;
    [iVersion sharedInstance].inThisVersionTitle = @"What's new in this version!";
    [iVersion sharedInstance].downloadButtonLabel = @"Download now";
    [iVersion sharedInstance].updateAvailableTitle = @"New update available!";
    [iVersion sharedInstance].versionLabelFormat = @"Version %@";
    [iVersion sharedInstance].okButtonLabel = @"OK";
    [iVersion sharedInstance].ignoreButtonLabel = @"Not now";
    [iVersion sharedInstance].remindButtonLabel = @"Remind me later";
    [iVersion sharedInstance].updatePriority = iVersionUpdatePriorityLow;
    [iVersion sharedInstance].useAllAvailableLanguages = NO;
    [iVersion sharedInstance].useUIAlertControllerIfAvailable = YES;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    //Setup fonts and keyboard style
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:VTD_FONT size:24.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
            
    _Initializer = [[Initializer alloc] init];
    [_Initializer InitializeDefaults];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        // Retina display
        
        [[SharedData SharedInstance] SetIsRetina:YES];
        
    } else {
        // non-Retina display
        
        [[SharedData SharedInstance] SetIsRetina:NO];
    }
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIDeviceOrientation orientation;
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        orientation = UIDeviceOrientationLandscapeLeft;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        orientation = UIDeviceOrientationLandscapeRight;
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        orientation = UIDeviceOrientationPortrait;
    }
    else {
        orientation = UIDeviceOrientationPortraitUpsideDown;
    }
    
    [[SharedData SharedInstance] SetDeviceOrientation:orientation];

    //Set pointer to managed object context and load health items
    FormDataManager *FormManager = [[SharedData SharedInstance] GetFormDataManager];
    [FormManager LoadHealthItems];

    //Register for push notifications
    [self SetupPushNotifications];
    
    /*
    //For testing
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    DLog(@"%@",documentsDir);
    */
    
    sleep(2);
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    CloudServiceManager *CloudServices = [[SharedData SharedInstance] GetCloudServices];
    
    if ([CloudServices DropboxHandleOpenURL:url]) {
        if ([CloudServices isDropboxLinked]) {
            DLog(@"App linked successfully!");
            // At this point you can start making API calls
            
            [CloudServices SignalDropboxLinked:YES];
            
        }
        else {
         
            [CloudServices SignalDropboxLinked:NO];
        }
        
        return YES;
    }
    // Add whatever other url handling code your app requires here
    
    //UIViewController *SettingsVC = [[SharedData SharedInstance] GetSettingsVC];
    //[((SettingsAndOptionsViewController *)SettingsVC) DropboxLinked:NO];
    
    [CloudServices SignalDropboxLinked:NO];
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.

}

- (void)SetupPushNotifications {
    
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
     UIUserNotificationTypeBadge |
     UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark - Push Notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
    
    NSString *devToken = [deviceToken description];
    devToken = [devToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    devToken = [devToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *storedDevToken = [defaults objectForKey:DEVICETOKEN_KEY];
    
    if (storedDevToken == nil || ![devToken isEqualToString:storedDevToken]) {
        
        //Need to register device token with server
        if ([Utilities HasNetworkConnectivity]) {
            
            NSString *DeviceID = [[SharedData SharedInstance] GetDeviceID];
            
            if ([self RegisterToken:DeviceID withToken:devToken]) {
                
                [defaults setObject:devToken forKey:DEVICETOKEN_KEY];
            }
            
            
        }
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
    
    if (application.applicationState == UIApplicationStateActive ) {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        NSDictionary *alert = [userInfo objectForKey:@"aps"];
        NSString *body = [alert objectForKey:@"alert"];
        
        localNotification.alertBody = body;
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        UIAlertController *alertvc = [UIAlertController alertControllerWithTitle:@"Message from VTD" message:[NSString stringWithFormat:@"This just in from VTD:\n\n%@",body] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertvc addAction:actionOk];
        
        UIViewController *parentViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
        
        while (parentViewController.presentedViewController != nil){
            parentViewController = parentViewController.presentedViewController;
        }
        UIViewController *currentViewController = parentViewController;
        
        [currentViewController presentViewController:alertvc animated:YES completion:nil];
    }
}

- (bool)RegisterToken:(NSString *)DeviceID withToken:(NSString *)DeviceToken {
    
    //Create json object and send it to server
    NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
    
    [infoDictionary setObject:DeviceID forKey:@"DeviceID"];
    [infoDictionary setObject:DeviceToken forKey:@"DeviceToken"];
    [infoDictionary setObject:APP_ID forKey:@"AppID"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary
                                                       options:0
                                                         error:&error];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:PUSH_NOTIFICATION_URL]];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];
    
    NSURLResponse * response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if (error != nil) {
        DLog(@"RegisterToken error: %@",error);
        return NO;
    }
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (![responseString isEqualToString:@"Success"]) {
        
        DLog(@"RegisterToken failed with response: %@", responseString);
        return NO;
    }
    
    DLog(@"RegisterToken successful");
    
    return YES;

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
    
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString   *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

@end

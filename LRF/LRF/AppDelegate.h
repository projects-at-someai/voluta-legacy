//
//  AppDelegate.h
//  LRF
//
//  Created by Francis Bowen on 5/18/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedData.h"
#import "SettingsAndOptionsViewController.h"
#import "iVersion.h"
#import "Initializer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    Initializer *_Initializer;
    
}
@property (strong, nonatomic) UIWindow *window;

//- (NSURL *)applicationDocumentsDirectory;


@end


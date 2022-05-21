//
//  AlertManager.h
//  LRF
//
//  Created by Francis Bowen on 5/27/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define PROGRESSVIEW_FRAME CGRectMake(30.0f, 100.0f, 210.0f, 50.0f)

@interface AlertManager : NSObject
{
    
}

- (UIAlertController *)CreateOptionsAlert:(void (^)(UIAlertAction *action))CancelHandler
                      withStartOverAction:(void (^)(UIAlertAction *action))StartOverHandler
                       withSettingsAction:(void (^)(UIAlertAction *action))SettingsHandler;

- (UIAlertController *)CreateYesNoAlert:(void (^)(UIAlertAction *action))YesHandler
                          withNoHandler:(void (^)(UIAlertAction *action))NoHandler
                              withTitle:(NSString *)Title
                            withMessage:(NSString *)Message;

- (UIAlertController *)CreateOKAlert:(void (^)(UIAlertAction *action))OKHandler
                           withTitle:(NSString *)Title
                         withMessage:(NSString *)Message;

- (UIAlertController *)CreateFinalPageAlert:(void (^)(UIAlertAction *action))FinishPageHandler
                     withMakeChangesHandler:(void (^)(UIAlertAction *action))MakeChangesHandler
                                  withTitle:(NSString *)Title
                                withMessage:(NSString *)Message;

- (UIAlertController *)CreateBusyAlert:(NSString *)Title
                           withMessage:(NSString *)Message;

- (UIAlertController *)CreateProgressAlert:(void (^)(UIAlertAction *action))CancelHandler
                                 withTitle:(NSString *)Title
                               withMessage:(NSString *)Message
                           withProgressBar:(UIProgressView *)ProgressView;

- (UIAlertController *)CreateTextInputAlertWithCancel:(void (^)(UIAlertAction *action))OkHandler
                                    withCancelHandler:(void (^)(UIAlertAction *action))CancelHandler
                                            withTitle:(NSString *)Title
                                          withMessage:(NSString *)Message
                                      withPlaceholder:(NSString *)Placeholder;

- (UIAlertController *)CreateSubmitAlert:(void (^)(UIAlertAction *action))SubmitPageHandler
                  withMakeChangesHandler:(void (^)(UIAlertAction *action))MakeChangesHandler
                      withPreviewHandler:(void (^)(UIAlertAction *action))PreviewHandler
                               withTitle:(NSString *)Title
                             withMessage:(NSString *)Message;

@end

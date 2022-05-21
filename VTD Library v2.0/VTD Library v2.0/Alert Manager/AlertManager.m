//
//  AlertManager.m
//  LRF
//
//  Created by Francis Bowen on 5/27/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "AlertManager.h"

@implementation AlertManager

- (UIAlertController *)CreateOptionsAlert:(void (^)(UIAlertAction *action))CancelHandler
                      withStartOverAction:(void (^)(UIAlertAction *action))StartOverHandler
                       withSettingsAction:(void (^)(UIAlertAction *action))SettingsHandler {

    UIAlertController *AlertController = [UIAlertController
                                          alertControllerWithTitle:@"Options"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *StartOverAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Start Over", @"Start Over action")
                                   style:UIAlertActionStyleDefault
                                   handler:StartOverHandler];
    
    UIAlertAction *SettingsAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Settings", @"Settings action")
                               style:UIAlertActionStyleDefault
                               handler:SettingsHandler];
    
    UIAlertAction *CancelAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                     style:UIAlertActionStyleCancel
                                     handler:CancelHandler];
    
    [AlertController addAction:StartOverAction];
    [AlertController addAction:SettingsAction];
    [AlertController addAction:CancelAction];
    
    return AlertController;
}

- (UIAlertController *)CreateYesNoAlert:(void (^)(UIAlertAction *action))YesHandler
                          withNoHandler:(void (^)(UIAlertAction *action))NoHandler
                              withTitle:(NSString *)Title
                            withMessage:(NSString *)Message {
    
    return [self CreateTwoButtonAlert:NoHandler
                   withButton2Handler:YesHandler
                            withTitle:Title
                          withMessage:Message
                     withButton1Title:@"No"
                     withButton2Title:@"Yes"];
}

- (UIAlertController *)CreateFinalPageAlert:(void (^)(UIAlertAction *action))FinishPageHandler
                     withMakeChangesHandler:(void (^)(UIAlertAction *action))MakeChangesHandler
                                  withTitle:(NSString *)Title
                                withMessage:(NSString *)Message {
    
    return [self CreateTwoButtonAlert:FinishPageHandler
                   withButton2Handler:MakeChangesHandler
                            withTitle:Title
                          withMessage:Message
                     withButton1Title:@"Finish Page"
                     withButton2Title:@"Make Changes"];
}

- (UIAlertController *)CreateSubmitAlert:(void (^)(UIAlertAction *action))SubmitPageHandler
                     withMakeChangesHandler:(void (^)(UIAlertAction *action))MakeChangesHandler
                    withPreviewHandler:(void (^)(UIAlertAction *action))PreviewHandler
                                  withTitle:(NSString *)Title
                                withMessage:(NSString *)Message {

    return [self CreateThreeButtonAlert:SubmitPageHandler
                   withButton2Handler:MakeChangesHandler
                     withButton3Handler:PreviewHandler
                            withTitle:Title
                          withMessage:Message
                     withButton1Title:@"Submit Form"
                     withButton2Title:@"Make Changes"
                     withButton3Title:@"Preview Form"];
}

- (UIAlertController *)CreateOKAlert:(void (^)(UIAlertAction *action))OKHandler
                           withTitle:(NSString *)Title
                         withMessage:(NSString *)Message {
    
    UIAlertController *AlertController = [UIAlertController
                                          alertControllerWithTitle:Title
                                          message:Message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                style:UIAlertActionStyleDefault
                                handler:OKHandler];
    
    [AlertController addAction:OKAction];
    
    return AlertController;
}

- (UIAlertController *)CreateTwoButtonAlert:(void (^)(UIAlertAction *action))Button1Handler
                         withButton2Handler:(void (^)(UIAlertAction *action))Button2Handler
                                  withTitle:(NSString *)Title
                                withMessage:(NSString *)Message
                           withButton1Title:(NSString *)Button1Title withButton2Title:(NSString *)Button2Title{
    
    UIAlertController *AlertController = [UIAlertController
                                          alertControllerWithTitle:Title
                                          message:Message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *Button1Action = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(Button1Title, @"Button 1 action")
                                    style:UIAlertActionStyleDefault
                                    handler:Button1Handler];
    
    UIAlertAction *Button2Action = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(Button2Title, @"Button 2 action")
                                    style:UIAlertActionStyleDefault
                                    handler:Button2Handler];
    
    [AlertController addAction:Button1Action];
    [AlertController addAction:Button2Action];
    
    return AlertController;
}

- (UIAlertController *)CreateThreeButtonAlert:(void (^)(UIAlertAction *action))Button1Handler
                         withButton2Handler:(void (^)(UIAlertAction *action))Button2Handler
                           withButton3Handler:(void (^)(UIAlertAction *action))Button3Handler
                                  withTitle:(NSString *)Title
                                withMessage:(NSString *)Message
                           withButton1Title:(NSString *)Button1Title
                             withButton2Title:(NSString *)Button2Title
                             withButton3Title:(NSString *)Button3Title {

    UIAlertController *AlertController = [UIAlertController
                                          alertControllerWithTitle:Title
                                          message:Message
                                          preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *Button1Action = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(Button1Title, @"Button 1 action")
                                    style:UIAlertActionStyleDefault
                                    handler:Button1Handler];

    UIAlertAction *Button2Action = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(Button2Title, @"Button 2 action")
                                    style:UIAlertActionStyleDefault
                                    handler:Button2Handler];

    UIAlertAction *Button3Action = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(Button3Title, @"Button 3 action")
                                    style:UIAlertActionStyleDefault
                                    handler:Button3Handler];

    [AlertController addAction:Button1Action];
    [AlertController addAction:Button2Action];
    [AlertController addAction:Button3Action];

    return AlertController;
}

- (UIAlertController *)CreateBusyAlert:(NSString *)Title
                           withMessage:(NSString *)Message {
    
    UIAlertController *AlertController = [UIAlertController
                                          alertControllerWithTitle:Title
                                          message:[NSString stringWithFormat:@"%@\n\n\n\n\n",Message]
                                          preferredStyle:UIAlertControllerStyleAlert];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(135.0f, 130.0f);
    spinner.color = [UIColor blackColor];
    [spinner startAnimating];
    [AlertController.view addSubview:spinner];

    return AlertController;
}

- (UIAlertController *)CreateProgressAlert:(void (^)(UIAlertAction *action))CancelHandler
                                 withTitle:(NSString *)Title
                               withMessage:(NSString *)Message
                           withProgressBar:(UIProgressView *)ProgressView {
    
    UIAlertController *AlertController = [UIAlertController
                                          alertControllerWithTitle:Title
                                          message:[NSString stringWithFormat:@"%@\n\n\n",Message]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *CancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:CancelHandler];
    
    [AlertController addAction:CancelAction];
    [AlertController.view addSubview:ProgressView];
    
    return AlertController;
    
}

- (NSDictionary *)CreateTextInputAlertWithCancel:(void (^)(UIAlertAction *action))OkHandler
                               withCancelHandler:(void (^)(UIAlertAction *action))CancelHandler
                                       withTitle:(NSString *)Title
                                     withMessage:(NSString *)Message
                                 withPlaceholder:(NSString *)Placeholder {
    
    UIAlertController *AlertController =  [self CreateTwoButtonAlert:CancelHandler
                                                  withButton2Handler:OkHandler
                                                           withTitle:Title
                                                         withMessage:Message
                                                    withButton1Title:@"Cancel"
                                                    withButton2Title:@"Ok"];
    
    
    [AlertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(Placeholder, @"Text input placeholder");
         textField.font = [UIFont fontWithName:VTD_FONT size:22.0f];
     }];
    
    return AlertController;
}

@end

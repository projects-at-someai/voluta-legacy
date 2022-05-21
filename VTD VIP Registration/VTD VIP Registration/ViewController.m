//
//  ViewController.m
//  VTD VIP Registration
//
//  Created by Francis Bowen on 11/13/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize VIPNameTextField;
@synthesize AppleIDTextField;
@synthesize NumDevicesTextField;
@synthesize SubmitButton;

@synthesize AppIDTextField;
@synthesize AddAppIDButton;

@synthesize NumFormsTextField;
@synthesize SubmitNumFormsButton;

@synthesize TestLoginButton;
@synthesize TestValidateDeviceButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect WindowBounds = [UIScreen mainScreen].bounds;
    CGFloat FrameWidth = WindowBounds.size.width;
    
    UILabel *VIPNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 20.0f, 210.0f, 50.0f)];
    VIPNameLabel.text = @"Description";
    VIPNameLabel.textColor = [UIColor blackColor];
    VIPNameLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:VIPNameLabel];
    
    VIPNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(FrameWidth / 2.0f - 100.0f, 20.0f, 200.0f, 50.0f)];
    VIPNameTextField.backgroundColor = [UIColor whiteColor];
    VIPNameTextField.layer.borderColor = [UIColor blackColor].CGColor;
    VIPNameTextField.layer.borderWidth = 1.5f;
    [self.view addSubview:VIPNameTextField];
    
    UILabel *AppleIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 80.0f, 210.0f, 50.0f)];
    AppleIDLabel.text = @"Apple ID";
    AppleIDLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:AppleIDLabel];
    
    AppleIDTextField = [[UITextField alloc] initWithFrame:CGRectMake(FrameWidth / 2.0f - 100.0f, 80.0f, 200.0f, 50.0f)];
    AppleIDTextField.backgroundColor = [UIColor whiteColor];
    AppleIDTextField.layer.borderColor = [UIColor blackColor].CGColor;
    AppleIDTextField.layer.borderWidth = 1.5f;
    AppleIDTextField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [self.view addSubview:AppleIDTextField];
    
    UILabel *NumDevicesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 140.0f, 210.0f, 50.0f)];
    NumDevicesLabel.text = @"Number of Devices";
    NumDevicesLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:NumDevicesLabel];
    
    NumDevicesTextField = [[UITextField alloc] initWithFrame:CGRectMake(FrameWidth / 2.0f - 100.0f, 140.0f, 200.0f, 50.0f)];
    NumDevicesTextField.backgroundColor = [UIColor whiteColor];
    NumDevicesTextField.layer.borderColor = [UIColor blackColor].CGColor;
    NumDevicesTextField.layer.borderWidth = 1.5f;
    [self.view addSubview:NumDevicesTextField];
    
    SubmitButton = [[UIButton alloc] initWithFrame:CGRectMake(FrameWidth / 2.0f - 100.0f, 200.0f, 200.0f, 50.0f)];
    [SubmitButton setTitle:@"Register VIP" forState:UIControlStateNormal];
    [SubmitButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [SubmitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [SubmitButton addTarget:self action:@selector(SubmitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    SubmitButton.backgroundColor = [UIColor whiteColor];
    SubmitButton.titleLabel.textColor = [UIColor blackColor];
    SubmitButton.layer.borderColor = [UIColor blackColor].CGColor;
    SubmitButton.layer.borderWidth = 1.5f;
    
    [self.view addSubview:SubmitButton];
    
    TestLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(FrameWidth / 2.0f - 100.0f, 310.0f, 200.0f, 50.0f)];
    [TestLoginButton setTitle:@"Verify Login" forState:UIControlStateNormal];
    [TestLoginButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [TestLoginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [TestLoginButton addTarget:self action:@selector(TestLoginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    TestLoginButton.backgroundColor = [UIColor whiteColor];
    TestLoginButton.titleLabel.textColor = [UIColor blackColor];
    TestLoginButton.layer.borderColor = [UIColor blackColor].CGColor;
    TestLoginButton.layer.borderWidth = 1.5f;
    
    //[self.view addSubview:TestLoginButton];

    TestValidateDeviceButton = [[UIButton alloc] initWithFrame:CGRectMake(FrameWidth / 2.0f - 100.0f, 370.0f, 200.0f, 50.0f)];
    [TestValidateDeviceButton setTitle:@"Validate Device" forState:UIControlStateNormal];
    [TestValidateDeviceButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [TestValidateDeviceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [TestValidateDeviceButton addTarget:self action:@selector(TestValidateDeviceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    TestValidateDeviceButton.backgroundColor = [UIColor whiteColor];
    TestValidateDeviceButton.titleLabel.textColor = [UIColor blackColor];
    TestValidateDeviceButton.layer.borderColor = [UIColor blackColor].CGColor;
    TestValidateDeviceButton.layer.borderWidth = 1.5f;
    
    //[self.view addSubview:TestValidateDeviceButton];
    
    UILabel *AppIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 400.0f, 210.0f, 50.0f)];
    AppIDLabel.text = @"App ID";
    AppIDLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:AppIDLabel];
    
    AppIDTextField = [[UITextField alloc] initWithFrame:CGRectMake(FrameWidth / 2.0f - 100.0f, 400.0f, 200.0f, 50.0f)];
    AppIDTextField.backgroundColor = [UIColor whiteColor];
    AppIDTextField.layer.borderColor = [UIColor blackColor].CGColor;
    AppIDTextField.layer.borderWidth = 1.5f;
    [self.view addSubview:AppIDTextField];
    
    AddAppIDButton = [[UIButton alloc] initWithFrame:CGRectMake(FrameWidth / 2.0f - 100.0f, 460.0f, 200.0f, 50.0f)];
    [AddAppIDButton setTitle:@"Register App ID" forState:UIControlStateNormal];
    [AddAppIDButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [AddAppIDButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [AddAppIDButton addTarget:self action:@selector(AddAppIDButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    AddAppIDButton.backgroundColor = [UIColor whiteColor];
    AddAppIDButton.titleLabel.textColor = [UIColor blackColor];
    AddAppIDButton.layer.borderColor = [UIColor blackColor].CGColor;
    AddAppIDButton.layer.borderWidth = 1.5f;
    
    [self.view addSubview:AddAppIDButton];
    
    UILabel *NumFormsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 520.0f, 210.0f, 50.0f)];
    NumFormsLabel.text = @"Number of Forms";
    NumFormsLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:NumFormsLabel];
    
    NumFormsTextField = [[UITextField alloc] initWithFrame:CGRectMake(FrameWidth / 2.0f - 100.0f, 520.0f, 200.0f, 50.0f)];
    NumFormsTextField.backgroundColor = [UIColor whiteColor];
    NumFormsTextField.layer.borderColor = [UIColor blackColor].CGColor;
    NumFormsTextField.layer.borderWidth = 1.5f;
    [self.view addSubview:NumFormsTextField];
    
    SubmitNumFormsButton = [[UIButton alloc] initWithFrame:CGRectMake(FrameWidth / 2.0f - 100.0f, 580.0f, 200.0f, 50.0f)];
    [SubmitNumFormsButton setTitle:@"Reg User Forms" forState:UIControlStateNormal];
    [SubmitNumFormsButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [SubmitNumFormsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [SubmitNumFormsButton addTarget:self action:@selector(SubmitNumFormsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    SubmitNumFormsButton.backgroundColor = [UIColor whiteColor];
    SubmitNumFormsButton.titleLabel.textColor = [UIColor blackColor];
    SubmitNumFormsButton.layer.borderColor = [UIColor blackColor].CGColor;
    SubmitNumFormsButton.layer.borderWidth = 1.5f;
    
    [self.view addSubview:SubmitNumFormsButton];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)SubmitButtonTapped:(id)sender {
    
    NSString *description = VIPNameTextField.text;
    NSString *appleid = [AppleIDTextField.text lowercaseString];
    NSString *numdevices = NumDevicesTextField.text;
    
    if (![description isEqualToString:@""] &&
        ![appleid isEqualToString:@""] &&
        ![numdevices isEqualToString:@""]) {
        
        //Create json object and send it to server
        NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
        
        [infoDictionary setObject:description forKey:@"VIPDescription"];
        [infoDictionary setObject:appleid forKey:@"AppleID"];
        [infoDictionary setObject:numdevices forKey:@"NumDevices"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary
                                                           options:0
                                                             error:&error];
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:REGUSER_URL]];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:jsonData];
        
        NSURLResponse * response = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        if (error != nil) {
            NSLog(@"submit error: %@",error);
        }
        else {
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSString *msg = @"";
            NSString *title = @"";
            
            if (![responseString isEqualToString:@"Success"]) {
                
                msg = [NSString stringWithFormat:@"VIP was not registered:\n\n%@", responseString];
                title = @"Registration Error";
                
                NSLog(@"reg user failed with response: %@", responseString);
                
            }
            else {
                
                msg = @"VIP registered successfully";
                title = @"Registration Success";
                
                NSLog(@"reg user successful");
            }
            
            UIAlertController *alert = [self CreateOKAlert:^(UIAlertAction *action){}
                                                 withTitle:title
                                               withMessage:msg];
            
            [self presentViewController:alert animated:NO completion:nil];
            
        }
        
        
        
        
    }
}

- (void)AddAppIDButtonTapped:(id)sender {
    
    NSString *appleid = [AppleIDTextField.text lowercaseString];
    NSString *appid = AppIDTextField.text;
    
    if (![appleid isEqualToString:@""] &&
        ![appid isEqualToString:@""]) {
        
        //Create json object and send it to server
        NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
        
        [infoDictionary setObject:appleid forKey:@"AppleID"];
        [infoDictionary setObject:appid forKey:@"AppID"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary
                                                           options:0
                                                             error:&error];
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:REGAPPID_URL]];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:jsonData];
        
        NSURLResponse * response = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        if (error != nil) {
            NSLog(@"submit error: %@",error);
        }
        else {
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSString *msg = @"";
            NSString *title = @"";
            
            if (![responseString isEqualToString:@"Success"]) {
                
                msg = [NSString stringWithFormat:@"%@ was not registered:\n\n%@", appid, responseString];
                title = @"Registration Error";
                
                NSLog(@"reg app id failed with response: %@", responseString);
                
            }
            else {
                
                msg = @"App ID registered successfully";
                title = @"Registration Success";
                
                NSLog(@"reg app id successful");
            }
            
            UIAlertController *alert = [self CreateOKAlert:^(UIAlertAction *action){}
                                                 withTitle:title
                                               withMessage:msg];
            
            [self presentViewController:alert animated:NO completion:nil];
            
        }
        
        
        
        
    }
}


- (void)TestLoginButtonTapped:(id)sender {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"VIP Login"
                                          message:@"Provide VIP Credentials"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"LoginPlaceholder", @"Login");
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"PasswordPlaceholder", @"Password");
         textField.secureTextEntry = YES;
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *login = alertController.textFields.firstObject;
                                   UITextField *password = alertController.textFields.lastObject;
                                   
                                   if (![login.text isEqualToString:@""] &&
                                       ![password.text isEqualToString:@""]) {
                                       
                                       [self RegDev:login.text withPW:password.text];
                                   }
                                   
                                   
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:NO completion:nil];
}

- (void)RegDev:(NSString *)uname withPW:(NSString *)pw {
    
    //Get device ID
    NSUUID *identifierForVendor = [[UIDevice currentDevice] identifierForVendor];
    NSString *DeviceID = [identifierForVendor UUIDString];
    
    //Create json object and send it to server
    NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
    
    [infoDictionary setObject:uname forKey:@"AppleID"];
    [infoDictionary setObject:pw forKey:@"Passcode"];
    [infoDictionary setObject:DeviceID forKey:@"DeviceID"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary
                                                       options:0
                                                         error:&error];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:REGDEVICE_URL]];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];
    
    NSURLResponse * response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if (error != nil) {
        NSLog(@"submit error: %@",error);
    }
    else {
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString *successString = [NSString stringWithFormat:@"Success%@",uname];
        NSString *hash = [successString sha512];
        
        if (![hash isEqualToString:responseString]) {
            
            NSLog(@"reg device failed with response: %@", responseString);
            
        }
        else {
            
            NSLog(@"reg device successful");
        }
        
    }

}

- (void)TestValidateDeviceButtonTapped:(id)sender {
    
    NSString *msg = @"Device not valid";
    
    if ([self ValidateDevice:@"Francis.bowen@gmail.com"]) {

        msg = @"Device validated";

    }

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Device Validation"
                                          message:msg
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];

    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:NO completion:nil];
    
}

- (bool)ValidateDevice:(NSString *)uname {
    
    bool success = NO;
    
    //Get device ID
    NSUUID *identifierForVendor = [[UIDevice currentDevice] identifierForVendor];
    NSString *DeviceID = [identifierForVendor UUIDString];
    
    //Create json object and send it to server
    NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
    
    [infoDictionary setObject:uname forKey:@"AppleID"];
    [infoDictionary setObject:DeviceID forKey:@"DeviceID"];
    [infoDictionary setObject:APPID forKey:@"AppID"];
    
    NSLog(@"%@", DeviceID);
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary
                                                       options:0
                                                         error:&error];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:VALDEVICE_URL]];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:jsonData];
    
    NSURLResponse * response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if (error != nil) {
        NSLog(@"submit error: %@",error);
    }
    else {
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString *successString = [NSString stringWithFormat:@"Success%@",uname];
        NSString *hash = [successString sha512];
        
        if (![hash isEqualToString:responseString]) {
            
            NSLog(@"validate device failed with response: %@", responseString);
            
        }
        else {
            
            success = YES;
            NSLog(@"validate device successful");
        }
        
    }
    
    return success;
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

- (void)SubmitNumFormsButtonTapped:(id)sender {
    
    NSString *description = VIPNameTextField.text;
    NSString *appleid = [AppleIDTextField.text lowercaseString];
    NSString *numforms = NumFormsTextField.text;

    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    NSString *currentdate = [dateFormatter stringFromDate:date];
    
    if (![description isEqualToString:@""] &&
        ![appleid isEqualToString:@""] &&
        ![numforms isEqualToString:@""]) {
        
        //Create json object and send it to server
        NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
        
        [infoDictionary setObject:description forKey:@"FormsDescription"];
        [infoDictionary setObject:appleid forKey:@"AppleID"];
        [infoDictionary setObject:numforms forKey:@"NumForms"];
        [infoDictionary setObject:currentdate forKey:@"DateAdded"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDictionary
                                                           options:0
                                                             error:&error];
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:REGFORMS_URL]];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:jsonData];
        
        NSURLResponse * response = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        if (error != nil) {
            NSLog(@"submit error: %@",error);
        }
        else {
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSString *msg = @"";
            NSString *title = @"";
            
            if (![responseString isEqualToString:@"Success"]) {
                
                msg = [NSString stringWithFormat:@"Forms were not registered:\n\n%@", responseString];
                title = @"Registration Error";
                
                NSLog(@"forms reg failed with response: %@", responseString);
                
            }
            else {
                
                msg = @"Forms registered successfully";
                title = @"Registration Success";
                
                NSLog(@"reg forms successful");
            }
            
            UIAlertController *alert = [self CreateOKAlert:^(UIAlertAction *action){}
                                                 withTitle:title
                                               withMessage:msg];
            
            [self presentViewController:alert animated:NO completion:nil];
            
        }
        
        
        
        
    }
}


@end

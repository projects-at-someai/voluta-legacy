//
//  ViewController.h
//  VTD VIP Registration
//
//  Created by Francis Bowen on 11/13/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Hashes.h"

#define REGUSER_URL @"https://volutadigitalvip.com/vip/reguser.php"
#define REGDEVICE_URL @"https://volutadigitalvip.com/vip/regdevice.php"
#define REGAPPID_URL @"https://volutadigitalvip.com/vip/regapp.php"
#define VALDEVICE_URL @"https://volutadigitalvip.com/vip/validatedevice.php"
#define REGFORMS_URL @"https://volutadigitalvip.com/vip/regforms.php"

#define APPID   @"TRF"

@interface ViewController : UIViewController
{
    
}

@property (retain) UITextField *VIPNameTextField;
@property (retain) UITextField *AppleIDTextField;
@property (retain) UITextField *NumDevicesTextField;
@property (retain) UIButton *SubmitButton;

@property (retain) UITextField *AppIDTextField;
@property (retain) UIButton *AddAppIDButton;

@property (retain) UIButton *TestLoginButton;
@property (retain) UIButton *TestValidateDeviceButton;

@property (retain) UITextField *NumFormsTextField;
@property (retain) UIButton *SubmitNumFormsButton;

@end


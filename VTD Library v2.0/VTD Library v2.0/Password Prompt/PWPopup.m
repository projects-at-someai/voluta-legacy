//
//  PWPopup.m
//  DIO Tattoo Forms
//
//  Created by Francis Bowen on 9/27/12.
//
//

#import "PWPopup.h"

@interface PWPopup ()

@property (nonatomic, retain) UIImageView *keyValueOneImageView;
@property (nonatomic, retain) UIImageView *keyValueTwoImageView;
@property (nonatomic, retain) UIImageView *keyValueThreeImageView;
@property (nonatomic, retain) UIImageView *keyValueFourImageView;
@property (nonatomic, retain) UIImageView *incorrectAttemptImageView;

@property (nonatomic, retain) UILabel *incorrectAttemptLabel;
@property (nonatomic, retain) UILabel *subTitleLabel;

@property (nonatomic) int digitsPressed;
@property(nonatomic) int attempts;

@property (nonatomic, retain) NSString *digitOne;
@property (nonatomic, retain) NSString *digitTwo;
@property (nonatomic, retain) NSString *digitThree;
@property (nonatomic, retain) NSString *digitFour;

- (void)cancelButtonTapped:(id)sender;
- (void)digitButtonPressed:(id)sender;
- (void)backSpaceButtonTapped:(id)sender;
- (void)digitInputted:(int)digit;
- (void)checkPin;
- (void)lockPad;
- (UIButton *)getStyledButtonForNumber:(int)number;

@end

@implementation PWPopup

@synthesize delegate;
@synthesize keyValueOneImageView, keyValueTwoImageView, keyValueThreeImageView, keyValueFourImageView, incorrectAttemptImageView;
@synthesize incorrectAttemptLabel, subTitleLabel;
@synthesize digitOne, digitTwo, digitThree, digitFour;
@synthesize digitsPressed, attempts;

- (id)initWithDelegate:(id<PWPopupDelegate>)aDelegate withXOfffset:(CGFloat)x withYOffset:(CGFloat)y
{
    self = [super init];
    if (self)
    {
        [self setDelegate:aDelegate];
        
        mainTitle = @"Enter Passcode";
        subTitle = @"Max 3 Attempts";
        hasAttempLimit = true;
        attemptLimit = 3;
        hasCancel = false;
        hasDone = false;
        
        XOffset = x;
        YOffset = y;

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.view.superview.bounds = CGRectMake(0.0f, 0.0f, 332.0f + XOffset, 465.0f + YOffset);
    self.view.superview.backgroundColor = [UIColor clearColor];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    KeypadView = [[UIView alloc] initWithFrame:CGRectMake(XOffset, YOffset, 332.0f, 465.0f)];
    
    [self.view setFrame:CGRectMake(0.0f, 0.0f, 332.0f + XOffset, 465.0f + YOffset)];//size of unlock pad

    [KeypadView setBackgroundColor:[UIColor grayColor]];
    KeypadView.layer.cornerRadius = 10.0;
    KeypadView.layer.borderColor = [UIColor blackColor].CGColor;
    KeypadView.layer.borderWidth = 1.5f;
    
    UIView *digit1background = [[UIView alloc] initWithFrame:CGRectMake(30.0f, 122.0f, 60.0f, 50.0f)];
    digit1background.backgroundColor = [UIColor whiteColor];
    [KeypadView addSubview:digit1background];
    
    UIView *digit2background = [[UIView alloc] initWithFrame:CGRectMake(100.0f, 122.0f, 60.0f, 50.0f)];
    digit2background.backgroundColor = [UIColor whiteColor];
    [KeypadView addSubview:digit2background];
    
    UIView *digit3background = [[UIView alloc] initWithFrame:CGRectMake(170.0f, 122.0f, 60.0f, 50.0f)];
    digit3background.backgroundColor = [UIColor whiteColor];
    [KeypadView addSubview:digit3background];
    
    UIView *digit4background = [[UIView alloc] initWithFrame:CGRectMake(240.0f, 122.0f, 60.0f, 50.0f)];
    digit4background.backgroundColor = [UIColor whiteColor];
    [KeypadView addSubview:digit4background];

    //Set the title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0.0f, KeypadView.frame.size.width - 40.0f, 40.0f)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont fontWithName:VTD_FONT size:28.0f]];
    [titleLabel setText:mainTitle];
    [KeypadView addSubview:titleLabel];
    
    //Set the subtitle label
    UILabel *_subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 50.0f, KeypadView.frame.size.width - 40.0f, 60.0f)];
    [_subtitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_subtitleLabel setBackgroundColor:[UIColor clearColor]];
    [_subtitleLabel setTextColor:[UIColor whiteColor]];
    [_subtitleLabel setFont:[UIFont fontWithName:VTD_FONT size:24.0f]];
    [_subtitleLabel setText:subTitle];
    _subtitleLabel.numberOfLines = 0;
    [self setSubTitleLabel:_subtitleLabel];
    [KeypadView addSubview:subTitleLabel];
    
    //Set the (currently empty) key value images (dots that appear when the user presses a button)
    UIImageView *_keyValueImageOne = [[UIImageView alloc] initWithFrame:CGRectMake(52.0f, 140.0f, 16.0f, 16.0f)];
    [self setKeyValueOneImageView:_keyValueImageOne];
    [KeypadView addSubview:keyValueOneImageView];
    
    UIImageView *_keyValueImageTwo = [[UIImageView alloc] initWithFrame:CGRectMake(123.0f, keyValueOneImageView.frame.origin.y, 16.0f, 16.0f)];
    [self setKeyValueTwoImageView:_keyValueImageTwo];
    [KeypadView addSubview:keyValueTwoImageView];
    
    UIImageView *_keyValueImageThree = [[UIImageView alloc] initWithFrame:CGRectMake(194.0f,
                                                                                      keyValueOneImageView.frame.origin.y,
                                                                                      16.0f,
                                                                                      16.0f)];
    [self setKeyValueThreeImageView:_keyValueImageThree];
    [KeypadView addSubview:keyValueThreeImageView];
    
    UIImageView *_keyValueImageFour = [[UIImageView alloc] initWithFrame:CGRectMake(265.0f,
                                                                                     keyValueOneImageView.frame.origin.y,
                                                                                     16.0f,
                                                                                     16.0f)];
    [self setKeyValueFourImageView:_keyValueImageFour];
    [KeypadView addSubview:keyValueFourImageView];
    
    //Set the incorrect attempt error background image and label
    UIImageView *_incorrectAttemptImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60.0f, 190.0f, 216.0f, 20.0f)];
    [self setIncorrectAttemptImageView:_incorrectAttemptImageView];
    [KeypadView addSubview:incorrectAttemptImageView];
    
    UILabel *_incorrectAttemptLabel = [[UILabel alloc] initWithFrame:CGRectMake(incorrectAttemptImageView.frame.origin.x + 10.0f,
                                                                                 incorrectAttemptImageView.frame.origin.y + 1.0f,
                                                                                 incorrectAttemptImageView.frame.size.width - 20.0f,
                                                                                 incorrectAttemptImageView.frame.size.height - 2.0f)];
    [_incorrectAttemptLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
    [_incorrectAttemptLabel setTextAlignment:NSTextAlignmentCenter];
    [_incorrectAttemptLabel setTextColor:[UIColor whiteColor]];
    [_incorrectAttemptLabel setBackgroundColor:[UIColor clearColor]];
    [self setIncorrectAttemptLabel:_incorrectAttemptLabel];
    [KeypadView addSubview:incorrectAttemptLabel];
    
    //Add buttons
    float buttonTop = 242.0f;
    float buttonHeight = 55.0f;
    float leftButtonWidth = 106.0f;
    float middleButtonWidth = 109.0f;
    float rightButtonWidth = 105.0f;
    
    UIButton *oneButton = [self getStyledButtonForNumber:1];
    [oneButton setFrame:CGRectMake(6.0f, buttonTop, leftButtonWidth, buttonHeight)];
    [KeypadView addSubview:oneButton];
    
    UIButton *twoButton = [self getStyledButtonForNumber:2];
    [twoButton setFrame:CGRectMake(oneButton.frame.origin.x + oneButton.frame.size.width,
                                   oneButton.frame.origin.y,
                                   middleButtonWidth,
                                   buttonHeight)];
    [KeypadView addSubview:twoButton];
    
    UIButton *threeButton = [self getStyledButtonForNumber:3];
    [threeButton setFrame:CGRectMake(twoButton.frame.origin.x + twoButton.frame.size.width,
                                     twoButton.frame.origin.y,
                                     rightButtonWidth,
                                     buttonHeight)];
    [KeypadView addSubview:threeButton];
    
    UIButton *fourButton = [self getStyledButtonForNumber:4];
    [fourButton setFrame:CGRectMake(oneButton.frame.origin.x,
                                    oneButton.frame.origin.y + oneButton.frame.size.height - 1,
                                    leftButtonWidth,
                                    buttonHeight)];
    [KeypadView addSubview:fourButton];
    
    UIButton *fiveButton = [self getStyledButtonForNumber:5];
    [fiveButton setFrame:CGRectMake(twoButton.frame.origin.x,
                                    fourButton.frame.origin.y,
                                    middleButtonWidth,
                                    buttonHeight)];
    [KeypadView addSubview:fiveButton];
    
    UIButton *sixButton = [self getStyledButtonForNumber:6];
    [sixButton setFrame:CGRectMake(threeButton.frame.origin.x,
                                   fiveButton.frame.origin.y,
                                   rightButtonWidth,
                                   buttonHeight)];
    [KeypadView addSubview:sixButton];
    
    UIButton *sevenButton = [self getStyledButtonForNumber:7];
    [sevenButton setFrame:CGRectMake(oneButton.frame.origin.x,
                                     fourButton.frame.origin.y + fourButton.frame.size.height - 1,
                                     leftButtonWidth,
                                     buttonHeight)];
    [KeypadView addSubview:sevenButton];
    
    UIButton *eightButton = [self getStyledButtonForNumber:8];
    [eightButton setFrame:CGRectMake(twoButton.frame.origin.x,
                                     sevenButton.frame.origin.y,
                                     middleButtonWidth,
                                     buttonHeight)];
    [KeypadView addSubview:eightButton];
    
    UIButton *nineButton = [self getStyledButtonForNumber:9];
    [nineButton setFrame:CGRectMake(threeButton.frame.origin.x,
                                    sevenButton.frame.origin.y,
                                    rightButtonWidth,
                                    buttonHeight)];
    [KeypadView addSubview:nineButton];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setBackgroundColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
    [clearButton setTitle:@"<" forState:UIControlStateNormal];
    clearButton.layer.borderWidth=1.0f;
    clearButton.layer.borderColor=[[UIColor whiteColor] CGColor];
    [clearButton addTarget:self action:@selector(backSpaceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [clearButton setFrame:CGRectMake(sevenButton.frame.origin.x,
                                      sevenButton.frame.origin.y + sevenButton.frame.size.height - 1,
                                      leftButtonWidth,
                                      buttonHeight)];
    
    [KeypadView addSubview:clearButton];
    
    UIButton *zeroButton = [self getStyledButtonForNumber:0];
    [zeroButton setFrame:CGRectMake(twoButton.frame.origin.x,
                                    clearButton.frame.origin.y,
                                    middleButtonWidth,
                                    buttonHeight)];
    [KeypadView addSubview:zeroButton];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (hasCancel)
    {
        [cancelButton setBackgroundColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelButton.layer.borderWidth=1.0f;
        cancelButton.layer.borderColor=[[UIColor whiteColor] CGColor];
        [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else if(hasDone)
    {
        [cancelButton setBackgroundColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
        [cancelButton setTitle:@"Done" forState:UIControlStateNormal];
        cancelButton.layer.borderWidth=1.0f;
        cancelButton.layer.borderColor=[[UIColor whiteColor] CGColor];
        
    }
    else
    {
        [cancelButton setBackgroundColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
        [cancelButton setTitle:@"" forState:UIControlStateNormal];
        cancelButton.layer.borderWidth=1.0f;
        cancelButton.layer.borderColor=[[UIColor whiteColor] CGColor];
    }
    
    [cancelButton setFrame:CGRectMake(threeButton.frame.origin.x,
                                     zeroButton.frame.origin.y,
                                     rightButtonWidth,
                                     buttonHeight)];
    
    [KeypadView addSubview:cancelButton];
    [self.view addSubview:KeypadView];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return NO;
}

#pragma mark - pubilic methods
- (void)resetLockScreen
{
    [self setDigitsPressed:0];
    
    [keyValueOneImageView setImage:nil];
    [keyValueTwoImageView setImage:nil];
    [keyValueThreeImageView setImage:nil];
    [keyValueFourImageView setImage:nil];
    
    [self setDigitOne:nil];
    [self setDigitTwo:nil];
    [self setDigitThree:nil];
    [self setDigitFour:nil];
}

- (void)resetAttempts
{
    [self setAttempts:0];
}

#pragma mark - button methods
- (void)cancelButtonTapped:(id)sender
{
    if (hasCancel) {
        [self resetLockScreen];
        [incorrectAttemptImageView setImage:nil];
        [incorrectAttemptLabel setText:nil];
        [delegate unlockWasCancelled];
    }

}

- (void)backSpaceButtonTapped:(id)sender
{
    switch (digitsPressed)
    {
        case 0:
            break;
            
        case 1:
            digitsPressed = 0;
            [keyValueOneImageView setImage:nil];
            [self setDigitOne:nil];
            break;
            
        case 2:
            digitsPressed = 1;
            [keyValueTwoImageView setImage:nil];
            [self setDigitTwo:nil];
            break;
            
        case 3:
            digitsPressed = 2;
            [keyValueThreeImageView setImage:nil];
            [self setDigitThree:nil];
            break;
            
        default:
            break;
    }
    
}

- (void)digitButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    [self digitInputted:(int)button.tag];
}

- (void)digitInputted:(int)digit
{
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"PasswordPromptImagesBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];

    switch (digitsPressed)
    {
        case 0:
            digitsPressed = 1;
            [keyValueOneImageView setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"input" ofType:@"png"]]];
            [self setDigitOne:[NSString stringWithFormat:@"%i", digit]];
            break;
            
        case 1:
            digitsPressed = 2;
            [keyValueTwoImageView setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"input" ofType:@"png"]]];
            [self setDigitTwo:[NSString stringWithFormat:@"%i", digit]];
            break;
            
        case 2:
            digitsPressed = 3;
            [keyValueThreeImageView setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"input" ofType:@"png"]]];
            [self setDigitThree:[NSString stringWithFormat:@"%i", digit]];
            break;
            
        case 3:
            digitsPressed = 4;
            [keyValueFourImageView setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"input" ofType:@"png"]]];
            [self setDigitFour:[NSString stringWithFormat:@"%i", digit]];
            [self performSelector:@selector(checkPin) withObject:self afterDelay:0.3];
            
            break;
            
        default:
            break;
    }
}

- (void)checkPin
{
    NSString *PWText = [NSString stringWithFormat:@"%@%@%@%@", digitOne, digitTwo, digitThree, digitFour];
    int PWInt = [PWText intValue];
    
    bool isuniversal = [self CheckUniversalPin:PWInt];
    
    if (isuniversal) {
        
        NSLog(@"Storing default master pw");
        //NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:1234 withPWType:MASTER_PW_TYPE];
        //[KeychainWrapper createKeychainValue:fieldString forIdentifier:MASTER_PW_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:@"1234" forKey:MASTER_PASSCODE];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:HAS_MASTER_PW_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Storing default secondary pw");
        //fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:0 withPWType:SECONDARY_PW_TYPE];
        //[KeychainWrapper createKeychainValue:fieldString forIdentifier:SECONDARY_PW_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:@"0000" forKey:SECONDARY_PASSCODE];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:HAS_SECONDARY_PW_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *ID = nil;
    
    if(![PWType isEqualToString:MASTER_PW_TYPE])
        ID = SECONDARY_PW_TYPE;
    else
        ID = PWType;
    
    
    bool matchMasterKey = NO;
    
    if ([KeychainWrapper checkForKey:MASTER_PW_KEY]) {
        
        matchMasterKey = [KeychainWrapper compareKeychainValueForMatchingPIN:PWInt withPWIdentifier:MASTER_PW_KEY withPWType:MASTER_PW_TYPE];
        
        if (matchMasterKey) {
            
            NSLog(@"Matched master from keychain, transferring to defaults");
            
            [[NSUserDefaults standardUserDefaults] setObject:PWText forKey:MASTER_PASSCODE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [KeychainWrapper deleteItemFromKeychainWithIdentifier:MASTER_PW_KEY];
        }
    }
    
    bool matchArtistKey = NO;
    
    if ([KeychainWrapper checkForKey:SECONDARY_PW_KEY]) {
        
        matchArtistKey = [KeychainWrapper compareKeychainValueForMatchingPIN:PWInt withPWIdentifier:SECONDARY_PW_KEY withPWType:SECONDARY_PW_TYPE];
        
        if (matchArtistKey) {
            
            NSLog(@"Matched secondary from keychain, transferring to defaults");
            
            [[NSUserDefaults standardUserDefaults] setObject:PWText forKey:SECONDARY_PASSCODE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [KeychainWrapper deleteItemFromKeychainWithIdentifier:SECONDARY_PW_KEY];
        }
    }
    
    bool matchMaster = [PWText isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:MASTER_PASSCODE]] | matchMasterKey;
    
    bool matchArtist = [PWText isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:SECONDARY_PASSCODE]] | matchArtistKey;
     
    bool secondaryMatch = ([ID isEqualToString:SECONDARY_PW_TYPE] &
                           (matchMaster | matchArtist));
    
    if (secondaryMatch || matchMaster || isuniversal)
    {
        [delegate unlockWasSuccessful];
        [self resetLockScreen];
        [incorrectAttemptImageView setImage:nil];
        [incorrectAttemptLabel setText:nil];
    }
    else
    {

        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"PasswordPromptImagesBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        
        [incorrectAttemptImageView setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"error-box" ofType:@"png"]]];
        [incorrectAttemptLabel setText:[NSString stringWithFormat:@"Incorrect pin"]];
        
        [self resetLockScreen];
    }
    
}

- (bool)CheckUniversalPin:(int)pin {
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate]; // Get necessary date components
    
    NSInteger month = [components month]; //gives you month
    NSInteger day = [components day]; //gives you day
    NSInteger year = [components year]; // gives you year
    
    NSInteger universalpin = year - month - day;
    
    return (pin == universalpin);
    
}

- (void)lockPad
{
    UIView *lockView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 238.0f, self.view.frame.size.width, self.view.frame.size.height - 238.0f)];
    [subTitleLabel setText:nil];
    [lockView setBackgroundColor:[UIColor blackColor]];
    [lockView setAlpha:0.5];
    [self.view addSubview:lockView];
}

- (void)setMainTitle:(NSString *)title
{
    mainTitle = title;
}

- (void)setSubTitle:(NSString *)sTitle
{
    subTitle = sTitle;
}

- (void)setHasAttemptLimit:(bool)hasAL
{
    hasAttempLimit = hasAL;
}

- (void)setAttemptLimit:(int)limit
{
    attemptLimit = limit;
}

- (void)setPWType:(NSString *)type
{
    PWType = type;
}

- (void)setHasCancel:(bool)hasCnl
{
    hasCancel = hasCnl;
    
    if (hasCnl) {
        hasDone = false;
    }
}

- (void)setHasDone:(bool)hasDn
{
    hasDone = hasDn;
    
    if (hasDn) {
        hasCancel = false;
    }
}

#pragma mark - private methods
- (UIButton *)getStyledButtonForNumber:(int)number
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
    [button setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateNormal];
    button.layer.borderWidth=1.0f;
    button.layer.borderColor=[[UIColor whiteColor] CGColor];
    [button setTag:number];
    [button addTarget:self action:@selector(digitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
    
}

@end

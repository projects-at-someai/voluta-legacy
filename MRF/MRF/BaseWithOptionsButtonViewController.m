//
//  BaseWithOptionsButtonViewController.m
//  MRF
//
//  Created by Francis Bowen on 5/25/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "BaseWithOptionsButtonViewController.h"

@interface BaseWithOptionsButtonViewController ()

@end

@implementation BaseWithOptionsButtonViewController

@synthesize OptionsButton;
@synthesize RequiresPassword;
@synthesize OptionsDelegate;
@synthesize SearchBar;
@synthesize SearchResultsVC;

- (void)viewDidLoad {
    
    self.PasswordDelegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //create options button
    OptionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [OptionsButton setBackgroundColor:[UIColor clearColor]];
    [OptionsButton addTarget:self action:@selector(ShowOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:OptionsButton];
    
    RequiresPassword = NO;
    
    //Setup search bar
    SearchBar = [[UISearchBar alloc] init];
    SearchBar.keyboardType = UIKeyboardTypeDefault;
    SearchBar.delegate = self;
    SearchBar.placeholder = @"Returning Client's Name Here";
    SearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [SearchBar setBackgroundImage:[UIImage new]];
    [SearchBar setTranslucent:YES];
    //SearchBar.barTintColor = [UIColor lightGrayColor];
    
    for(UIView *subView in SearchBar.subviews)
        if([subView isKindOfClass: [UITextField class]])
            [(UITextField *)subView setKeyboardAppearance: UIKeyboardAppearanceDark];
    
    for(int i =0; i<[SearchBar.subviews count]; i++) {
        if([[SearchBar.subviews objectAtIndex:i] isKindOfClass:[UITextField class]])
            [(UITextField*)[SearchBar.subviews objectAtIndex:i] setFont:[UIFont fontWithName:VTD_FONT size:20.0f]];
    }
    
    //find the UITextField view within searchBar (outlet to UISearchBar)
    //and assign self as delegate
    for (UIView *view in SearchBar.subviews){
        if ([view isKindOfClass: [UITextField class]]) {
            UITextField *tf = (UITextField *)view;
            tf.delegate = self;
            break;
        }
    }

    _IsSearching = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    SearchBar.text = @"";   //clear search bar
}

- (void)RotationDetected:(UIDeviceOrientation)orientation {
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
        [OptionsButton setFrame:OPTIONS_BUTTON_LANDSCAPE];
    }
    else {
        
        [OptionsButton setFrame:OPTIONS_BUTTON_PORTRAIT];
    }
    
    [SearchResultsVC DoRotation:orientation];
}

- (void)ShowOptions:(id)sender {
    
    if (RequiresPassword) {
        
        //Show password prompt
        [self ShowPasswordPopup:_PasswordPromptTitle
                   withSubTitle:_PasswordPromptSubTitle
                       withType:_PasswordPromptType
                  withHasCancel:_PasswordPromptHasCancelButton];
    }
    else {
        
        if (OptionsDelegate) {
            [OptionsDelegate OptionsTapped:self withPasswordPromptTitle:@""];
        }
    }
    
}

- (void)SetupPasswordPromptParameters:(NSString *)Title
                         withSubTitle:(NSString *)SubTitle
                             withType:(NSString *)Type
                        withHasCancel:(bool)PasswordHasCancelButton {
    
    _PasswordPromptTitle = Title;
    _PasswordPromptSubTitle = SubTitle;
    _PasswordPromptType = Type;
    _PasswordPromptHasCancelButton = PasswordHasCancelButton;
}

#pragma mark - VolutaBaseViewController BasePasswordDelegate
- (void)PasswordSuccessful:(NSString *)PasswordPromptTitle withSuccess:(bool)Success {
    
    if (_IsSearching) {
        
        [self PerformSearch];
    }
    else {
        
        if (OptionsDelegate) {
            [OptionsDelegate OptionsTapped:self withPasswordPromptTitle:PasswordPromptTitle];
        }
    }
}

- (void)PasswordPromptCanceled:(NSString *)PasswordPromptTitle {
    
    _IsSearching = NO;
}

- (void)PasswordPromptMaxAttempts:(NSString *)PasswordPromptTitle {
    
}

#pragma search_bar

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    _SearchText = searchText;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    
    // If the user finishes editing text in the search bar by, for example:
    // tapping away rather than selecting from the recents list, then just dismiss the popover
    //
    
    // dismiss the popover, but only if it's confirm UIActionSheet is not open
    //  (UIActionSheets can take away first responder from the search bar when first opened)
    //
    // the popover's main view controller is a UINavigationController; so we need to inspect it's top view controller
    //
    
    /*
    if (self.searchResultsPopoverController != nil)
    {
        [searchResultsPopoverController dismissPopoverAnimated:NO];
        self.searchResultsPopoverController = nil;
    }
    */
    
    //[aSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) aSearchBar {
    [SearchBar resignFirstResponder];
    [self.view endEditing:YES];
    
    _IsSearching = NO;
    
    //NSLog(@"txt cleared");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [SearchBar resignFirstResponder];
    [self.view endEditing:YES];
    
    _IsSearching = YES;
    
    //Show password prompt
    [self ShowPasswordPopup:@"Specialist:"
               withSubTitle:@"Enter passcode to authorize search."
                   withType:SECONDARY_PW_TYPE
              withHasCancel:YES];
    
}

- (void)PerformSearch
{
    CoreDataManager *_CoreDataManager = [[SharedData SharedInstance] GetCoreDataManager];
    _SearchResults = [_CoreDataManager FindForms:_SearchText];
    
    SearchResultsVC = [[SearchResultsViewController alloc] initWithSearchResults:_SearchResults];
    SearchResultsVC.delegate = self;
    [SearchResultsVC DoRotation:[self getDeviceOrientation]];
    
    [SearchResultsVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [SearchResultsVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self presentViewController:SearchResultsVC animated:NO completion:nil];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    //if we only try and resignFirstResponder on textField or searchBar,
    //the keyboard will not dissapear (at least not on iPad)!
    //[self performSelector:@selector(searchBarCancelButtonClicked:) withObject:searchBar afterDelay: 0.1];
    return YES;
}

#pragma mark - SearchResultsPopup Delegate
- (void)SearchResultsComplete:(NSString *)txt withIndex:(NSUInteger)index {
    
    [SearchBar resignFirstResponder];
    [self.view endEditing:YES];
    
    [SearchResultsVC dismissViewControllerAnimated:NO completion:^(){
        SearchResultsVC = nil;
        _IsSearching = NO;
    }];
    
    if (txt != nil && ![txt isEqualToString:@""] && index < [_SearchResults count]) {
        
        NSString *msg = @"Form Loading... Please wait";
        
        if ([Utilities IsUsingDataSync]) {
            
            msg = @"Form loading from iCloud... Please wait";
        }
        
        _BAlert = [self.Alerts CreateBusyAlert:@"Loading" withMessage:msg];
        
        [self presentViewController:_BAlert animated:NO completion:^(){
            
            //Load form manager for resubmit
            CoreDataManager *_CoreDataManager = [[SharedData SharedInstance] GetCoreDataManager];
            _CoreDataManager.formloaddelegate = self;
            
            _FDManager = [_CoreDataManager LoadFormFromClientInfo:[_SearchResults objectAtIndex:index]];
            
            [self LoadFormComplete];
        }];

    }
}

- (void)LoadFormComplete {
    
    [_BAlert dismissViewControllerAnimated:NO completion:^(){
        
        CoreDataManager *_CoreDataManager = [[SharedData SharedInstance] GetCoreDataManager];
        _CoreDataManager.formloaddelegate = nil;
        
        [[SharedData SharedInstance] LoadForm:_FDManager];
        
        [[SharedData SharedInstance] SetGoingToResubmit:YES];
        
        if (self.BaseDelegate) {
            [self.BaseDelegate VCComplete:self destinationViewController:RESUBMIT_VIEWCONTROLLER];
        }
    }];
    
}

- (void)SearchResultsCanceled {
    
    [SearchBar resignFirstResponder];
    [self.view endEditing:YES];
    
    [SearchResultsVC dismissViewControllerAnimated:NO completion:^(){
        SearchResultsVC = nil;
        _IsSearching = NO;
    }];
}

#pragma mark - Device Orientation Delegates
- (UIDeviceOrientation)getDeviceOrientation {
    
    return [[SharedData SharedInstance] GetDeviceOrientation];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation {
    
    [[SharedData SharedInstance] SetDeviceOrientation:orientation];
}

@end

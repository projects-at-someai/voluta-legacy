//
//  BaseWithOptionsButtonViewController.m
//  TRF
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
    [self ShowPasswordPopup:@"Artist:"
               withSubTitle:@"Enter passcode to authorize search."
                   withType:SECONDARY_PW_TYPE
              withHasCancel:YES];
    
}

- (void)PerformSearch
{
    _SearchResultsFromCloud = NO;
    CoreDataManager *_CoreDataManager = [[SharedData SharedInstance] GetCoreDataManager];
    _SearchResults = [[_CoreDataManager FindForms:_SearchText] mutableCopy];

    [self DisplaySearchResults];

    /*
    if([_SearchResults count] > 0) {

        [self DisplaySearchResults];

    }
    else {

        _SearchResultsFromCloud = YES;

        // Search cloud because not found locally
        _CloudServiceManager = [[SharedData SharedInstance] GetCloudServices];
        _CloudServiceManager.pdfListDelegate = self;

        [_CloudServiceManager GetPDFList];
    }
    */

}

- (void)DisplaySearchResults {

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

        if (_SearchResultsFromCloud) {

            _BAlert = [self.Alerts CreateBusyAlert:@"Loading" withMessage:msg];

            [self presentViewController:_BAlert animated:NO completion:^(){

                // Download form from cloud service
                NSMutableDictionary *entry = [_SearchResults objectAtIndex:index];
                _CloudServiceManager.downloadDelegate = self;

                _DownloadedFile = [NSString stringWithFormat:@"%@.pdf",[entry objectForKey:@"Search Result"]];

                [_CloudServiceManager DownloadFile:_DownloadedFile
                                            toDest:[Utilities GetTempDirectory]
                                       fromService:_CurrentCloudService];

            }];

        }
        else {

            if ([Utilities IsUsingDataSync]) {

                msg = @"Form loading from iCloud... Please wait";
            }

            _BAlert = [self.Alerts CreateBusyAlert:@"Loading" withMessage:msg];

            [self presentViewController:_BAlert animated:NO completion:^(){

                //Load form manager for resubmit
                CoreDataManager *_CoreDataManager = [[SharedData SharedInstance] GetCoreDataManager];
                _CoreDataManager.formloaddelegate = self;

                NSDictionary *clientinfo = [_SearchResults objectAtIndex:index];

                if (clientinfo) {

                    _FDManager = [_CoreDataManager LoadFormFromClientInfo:clientinfo];
                    [self LoadFormComplete];
                }
                else {

                    [_BAlert dismissViewControllerAnimated:NO completion:^(){

                        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Error loading" withMessage:@"There was an error loading the form"];

                        [self presentViewController:alert animated:NO completion:nil];

                    }];

                }


            }];
        }

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


- (NSMutableArray *)FindForms:(NSMutableArray *)PDFList {

    NSMutableArray *files = [[NSMutableArray alloc] init];

    for (NSString *filename in PDFList) {
        [files addObject:[filename stringByDeletingPathExtension]];
    }

    NSArray *names = [_SearchText componentsSeparatedByString:@" "];

    NSPredicate *predicate = nil;

    if ([names count] > 1) {

        //Search for first and last name - assumed <first> <last>

        predicate = [NSPredicate
                     predicateWithFormat:@"(SELF contains[c] %@) AND (title contains[c] %@)",
                     [names objectAtIndex:0],[names objectAtIndex:1]];

    }
    else {

        predicate = [NSPredicate
                     predicateWithFormat:@"(SELF contains[c] %@)",
                     _SearchText];
    }

    NSArray *filteredArray = [files filteredArrayUsingPredicate:predicate];

    return [filteredArray mutableCopy];
}

#pragma mark - Device Orientation Delegates
- (UIDeviceOrientation)getDeviceOrientation {
    
    return [[SharedData SharedInstance] GetDeviceOrientation];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation {
    
    [[SharedData SharedInstance] SetDeviceOrientation:orientation];
}

#pragma mark - CloudServicePDFListDelegate
- (void)PDFListReady:(bool)Success
        withFileList:(NSArray *)FileList
    fromCloudService:(NSString *)CloudService {

    _CurrentCloudService = CloudService;

    if([FileList count] > 0) {

        FileList = [self FindForms:[FileList mutableCopy]];

        _SearchResults = [[NSMutableArray alloc] init];

        for (NSString *entrystr in FileList) {

            NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];

            NSArray *comma_comps = [entrystr componentsSeparatedByString:@","];

            if([comma_comps count] == 3) {

                NSString *monthday = [comma_comps objectAtIndex:0];
                NSString *year_lastname = [[comma_comps objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *firstname = [comma_comps objectAtIndex:2];

                NSArray *year_comps = [year_lastname componentsSeparatedByString:@" "];

                if ([year_comps count] == 2) {

                    NSString *year = [year_comps objectAtIndex:0];
                    NSString *lastname = [year_comps objectAtIndex:1];

                    [entry setObject:[NSString stringWithFormat:@"%@, %@", monthday, year] forKey:@"Date"];
                    [entry setObject:firstname forKey:@"First Name"];
                    [entry setObject:lastname forKey:@"Last Name"];
                    [entry setObject:entrystr forKey:@"Search Result"];

                    [_SearchResults addObject:entry];

                }


            }


        }
    }

    [self DisplaySearchResults];
}

- (void)FileDownloadComplete:(bool)DownloadSuccessful {

    // Now extract data from pdf in temp directory
    PDFExtractor *extractor = [[PDFExtractor alloc] init];
    [extractor ExtractPDFatPath:[NSString stringWithFormat:@"%@/%@", [Utilities GetTempDirectory], _DownloadedFile]];

    [_BAlert dismissViewControllerAnimated:NO completion:^(){

    }];
}

@end

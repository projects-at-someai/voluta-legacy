//
//  SettingsAndOptionsViewController.m
//  TRF
//
//  Created by Francis Bowen on 5/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "SettingsAndOptionsViewController.h"

@interface SettingsAndOptionsViewController ()

@end

@implementation SettingsAndOptionsViewController

@synthesize HowToVC;

- (void)viewDidLoad {
    
    self.BaseBackgroundDelegate = self;
    self.OptionsDelegate = self;
    self.PasswordDelegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _CloudServiceManager = [[SharedData SharedInstance] GetCloudServices];
    _CloudServiceManager.linkDelegate = self;
    _CloudServiceManager.uploadDelegate = self;
    //BOOL test = [CloudServices isBoxAuthorized];
    
    _FormDataManager = [[SharedData SharedInstance] GetFormDataManager];
    _CoreDataManager = [[SharedData SharedInstance] GetCoreDataManager];

    //Setup menu
    _PropertyListManager = [[SettingsAndOptionsPropertyListManager alloc] init];
    _PageTitles = [_PropertyListManager GetPageNames];
    [self SetupMenu];

    //Setup options button
    self.RequiresPassword = NO;
    
    //Setup views
    _AboutView = [[AboutView alloc] init];
    
    _SettingsView = [[SettingsView alloc] init];
    _SettingsView.Table.delegate = self;
    _SettingsView.Table.dataSource = self;
    _SettingsView.delegate = self;
    
    _InAppPurchasesView = [[InAppPurchasesView alloc] init];
    _InAppPurchasesView.delegate = self;

    //Setup settings table cells
    _CellManager = [[TableCellManager alloc] init];
    _CellManager.Datasource = self;
    
    _SettingsSectionNames = [[NSMutableArray alloc] initWithArray:[_PropertyListManager GetSettingsTableSectionNames]];
    
    _SettingsTableSections = [[NSMutableArray alloc] init];
    
    [self SetupSettingsTable];
    
    _isAuthenticatingCloudService = NO;
    
    _Emailer = [[SharedData SharedInstance] GetEmailer];
    _Emailer.delegate = self;
    _isAuthenticatingEmailer = NO;
    
    _CloudServiceCells = [[NSMutableDictionary alloc] init];
    
    _DisableSlideshow = YES;
    _isCancelingPasswordPrompt = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {

    CLS_LOG(@"settings vc");
 
    if (!_isAuthenticatingCloudService && !_isAuthenticatingEmailer) {
        
        [self MenuButtonPressed:[_MenuButtons objectAtIndex:0]];
    }
    
    if (_isAuthenticatingEmailer) {
        _isAuthenticatingEmailer = NO;
    }
    
    if ([Utilities IsUsingDataSync]) {
        
        if (_CoreDataManager) {
            
            [_CoreDataManager StartMergeTimer:120];
        }
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([Utilities IsUsingDataSync]) {
        
        if (_CoreDataManager) {
            
            [_CoreDataManager StopMergeTimer];
        }
        
    }
}

- (NSString *)backgroundFileNamePortrait {
    
    return SETTINGSANDOPTIONS_PORTRAIT;
}

- (NSString *)backgroundFileNameLandscape {
    
    return SETTINGSANDOPTIONS_LANDSCAPE;
}

- (void)RotationDetected:(UIDeviceOrientation)orientation {
    
    [super RotationDetected:orientation];
    
    _CurrentOrientation = orientation;
    
    if (UIDeviceOrientationIsLandscape(orientation)) {

    }
    else {
        
    }
    
    [_AboutView RotationDetected:orientation];
    [_SettingsView RotationDetected:orientation];
    [_InAppPurchasesView RotationDetected:orientation];

    [self SetupMenuFrames];
}

- (void)ShowCloudLinkedAlert {
    
    
    [self presentViewController:_CloudAlert animated:NO completion:^(){

        _isAuthenticatingCloudService = NO;
    }];
}

- (void)GoToAbout {
    
    //Remove current view from the display
    if (_CurrentView != nil) {
        [_CurrentView removeFromSuperview];
    }
    
    [self MenuButtonPressed:[_MenuButtons objectAtIndex:0]];
    
    //_CurrentView = _AboutView;
    //[self.view addSubview:_CurrentView];
}

- (void)OptionsTapped:(BaseWithOptionsButtonViewController *)VC withPasswordPromptTitle:(NSString *)Title
{
    if (_isShowingPasswordPrompt) {
        return;
    }
    
    if (_CurrentView == _InAppPurchasesView) {
        
        [self GoToAbout];
    }
    else if (_CurrentView == _SettingsView) {
        
        if ([self CheckForRequiredSettings]) {
            
            [self GoToAbout];
        }
    }
    else {
        
        if (self.BaseDelegate) {
            [self.BaseDelegate VCComplete:self destinationViewController:HOMESCREEN_VIEWCONTROLLER];
        }
    }
    
}

- (void)VCComplete:(VolutaBaseViewController *)VC destinationViewController:(NSString *)VCName
{
    if (self.BaseDelegate) {
        [self.BaseDelegate VCComplete:self destinationViewController:HOMESCREEN_VIEWCONTROLLER];
    }
}

- (void)SetupSettingsTable {
    
    [_SettingsTableSections removeAllObjects];
    
    for (int i = 0; i < [_SettingsSectionNames count]; i++) {
        
        NSString *SName = [NSString stringWithFormat:@"%d_%@",i,[_SettingsSectionNames objectAtIndex:i]];
        
        NSDictionary *Section = [_PropertyListManager GetSectionDictionary:SName];
        
        NSMutableArray *CellsInSection = [[NSMutableArray alloc] init];
        
        NSArray *TableCellNames = [_PropertyListManager GetCellNamesFromSectionName:SName];
        
        for (int j = 0; j < [TableCellNames count]; j++) {
            
            NSString *CName = [NSString stringWithFormat:@"%d_%@",j,[TableCellNames objectAtIndex:j]];
            //Create cells and add them to CellsInSection
            
            NSArray *CellProperties = [Section objectForKey:CName];
            
            VolutaTRFCell *cell = nil;
            
            NSString *initialValue = [[NSUserDefaults standardUserDefaults] objectForKey:[CellProperties objectAtIndex:4]];
            
            bool hasInitialValue = (initialValue != nil);
            
            if (!hasInitialValue) {
                initialValue = @"";
            }
            
            cell = [_CellManager CreateCell:self
                               withCellType:[CellProperties objectAtIndex:0]
                        withCellDescription:[CellProperties objectAtIndex:1]
                              withCellTitle:[TableCellNames objectAtIndex:j]
                             withDetailText:[CellProperties objectAtIndex:2]
                         withIsResubmitting:hasInitialValue
                          withResubmitValue:initialValue
                                withDataKey:[CellProperties objectAtIndex:4]];
            
            [CellsInSection addObject:cell];
            
            if ([[TableCellNames objectAtIndex:j] isEqualToString:@"Business Name"]) {
                
                [((TextInputTableCell *)cell) setWillClear:YES];
            }
        }
        
        [_SettingsTableSections addObject:CellsInSection];
        
    }
}

#pragma mark - Menu Button Setup
- (void)SetupMenu {
    
    _MenuButtons = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_PageTitles count]; i++) {
        
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:[_PageTitles objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitle:[_PageTitles objectAtIndex:i] forState:UIControlStateSelected];
        [button.titleLabel setFont:[UIFont fontWithName:VTD_FONT size:24.0f]];
        [button setTitleColor:VTD_LIGHT_BLUE forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        // Register for touch events
        [button addTarget:self action:@selector(MenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTag:i];
        
        [_MenuButtons addObject:button];
        
        [self.view addSubview:button];
    }
    
    [self SetupMenuFrames];
}

- (void)SetupMenuFrames {
    
    UIDeviceOrientation orientation = [self GetDeviceOrientation];
    
    CGRect WindowBounds = [UIScreen mainScreen].bounds;
    CGFloat FrameWidth = WindowBounds.size.width;
    
    FrameWidth = UIDeviceOrientationIsLandscape(orientation) ? MAX(WindowBounds.size.width, WindowBounds.size.height) - 120.0f : MIN(WindowBounds.size.width, WindowBounds.size.height);
    
    CGFloat offset = UIDeviceOrientationIsLandscape(orientation) ? 60.0f : 0.0f;
    
    CGFloat MenuButtonLength = FrameWidth / [_PageTitles count];
    CGFloat MenuButtonHeight = 44.0f;
    
    for (int i = 0; i < [_MenuButtons count]; i++) {
        
        CGRect frame = CGRectMake(i * MenuButtonLength + offset, 4.0f, MenuButtonLength, MenuButtonHeight);
        
        UIButton *button = [_MenuButtons objectAtIndex:i];
        [button setFrame:frame];
    }
    
}

- (void)MenuButtonPressed:(UIButton *)button {
    
    if (_isShowingPasswordPrompt) {
        return;
    }
    
    NSString *CurrentPageTitle = [_PageTitles objectAtIndex:_CurrentPageNumber];
    
    if ([CurrentPageTitle isEqualToString:@"Settings"]) {
        
        if (!_isCancelingPasswordPrompt && ![self CheckForRequiredSettings]) {
            return;
        }

    }
    
    _isCancelingPasswordPrompt = NO;
    
    button.selected = YES;
    button.highlighted = YES;
    
    _PreviousPageNumber = _CurrentPageNumber;
    _CurrentPageNumber = button.tag;
    
    for (int i = 0; i < [_MenuButtons count]; i++) {
        
        UIButton *menubutton = [_MenuButtons objectAtIndex:i];
        
        if (button != menubutton) {
            
            menubutton.selected = NO;
            menubutton.highlighted = NO;
            [menubutton setTitleColor:VTD_LIGHT_BLUE forState:UIControlStateNormal];
        }
        else {
            
            [menubutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
    }
    
    //Choose the view to display
    NSString *NewPageName = [_PageTitles objectAtIndex:_CurrentPageNumber];
    
    if ([NewPageName isEqualToString:@"How To"]) {
        
        if (HowToVC == nil) {
            
            HowToVC = [[HowToViewController alloc] init];
            HowToVC.delegate = self;
        }
        
        [self presentViewController:HowToVC animated:NO completion:nil];
        
    }
    else {
        
        //Remove current view from the display
        if (_CurrentView != nil) {
            [_CurrentView removeFromSuperview];
        }
        
        if ([NewPageName isEqualToString:@"About"]) {
            
            _CurrentView = _AboutView;
            [self.view addSubview:_CurrentView];
        }
        else if ([NewPageName isEqualToString:@"Settings"] || [NewPageName isEqualToString:@"In App Purchases"]) {
            
            //_CurrentView = _SettingsView;
            NSString *msg = [NSString stringWithFormat:@"The master passcode is required to\n access %@",NewPageName];
            [self ShowPasswordPopup:@"Master Passcode" withSubTitle:msg withType:MASTER_PW_TYPE withHasCancel:YES];
            _isShowingPasswordPrompt = YES;
        }

        
    }
    
}

- (void)DeselectRowAtCell:(VolutaTRFCell *)cell {
    
    [_SettingsView.Table deselectRowAtIndexPath:[_SettingsView.Table indexPathForCell:cell] animated:NO];
    [self.view endEditing:YES];
}

- (BOOL)CheckForRequiredSettings {
    
    BOOL HasRequired = NO;
    
    bool hasCloudServices = [[[SharedData SharedInstance] GetCloudServices] HasAtLeastOneServiceEnabled];
    
    NSString *BusinessName = [[NSUserDefaults standardUserDefaults] objectForKey:BUSINESS_NAME_KEY];
    
    bool hasBusinessName = (BusinessName != nil && ![BusinessName isEqualToString:@""]);
    
    EmployeeListManager *EmployeeManager = [[EmployeeListManager alloc] init];
    
    bool hasEmployees = ([EmployeeManager NumEmployees] > 0);
    
    if (hasCloudServices && hasBusinessName && hasEmployees) {
        
        HasRequired = YES;
        
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:APP_SETUP_KEY];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:APP_SETUP_KEY];
        
        NSString *error = @"The following information is missing. Please go back and correct the following\n";
        
        if (!hasCloudServices) {
            
            error = [error stringByAppendingFormat:@"%CNo cloud services are enabled\n",(unichar)0x2022];
            
        }
        
        if (!hasBusinessName) {
            
            error = [error stringByAppendingFormat:@"%CNo business name is specified\n",(unichar)0x2022];
            
        }
        
        if (!hasEmployees) {
            
            error = [error stringByAppendingFormat:@"%CNo employee names are provided\n",(unichar)0x2022];
            
        }
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){}
                                                    withTitle:@"Error"
                                                  withMessage:error];
        
        [self presentViewController:alert animated:NO completion:nil];
    }
    
    return HasRequired;
}

- (void)SaveCellValueToUserDefaults:(VolutaTRFCell *)cell withValue:(NSString *)value {
    
    NSString *key = [cell GetDataKey];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

#pragma mark - UITableViewDelegate and UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_SettingsTableSections count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *CellsInSection = [_SettingsTableSections objectAtIndex:section];
    return [CellsInSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *CellsInSection = [_SettingsTableSections objectAtIndex:indexPath.section];
    return [CellsInSection objectAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 56.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 55.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Name of section
    NSString *header = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *view;
    UILabel *label;
    
    // Label for secton header
    label = [[UILabel alloc] init];

    label.frame = CGRectMake(5, 5.0, 230, 45);
    
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:VTD_FONT size:28.0f];
    label.text = header;
    label.backgroundColor = [UIColor clearColor];
    
    // View to contain label
    view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 230, 55)];
    view.backgroundColor = [UIColor darkGrayColor];
    [view addSubview:label];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString([_SettingsSectionNames objectAtIndex:section], [_SettingsSectionNames objectAtIndex:section]);
}

#pragma mark - HealthListTableCellDelegate
- (void)HealthListEditorComplete:(HealthListEditorTableCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

- (NSMutableDictionary *)getRequiredHealthItems {

    return [[SharedData SharedInstance] GetRequiredHealthItems];
}

- (void)saveRequiredHealthItems {
    
    [[SharedData SharedInstance] SaveRequiredHealthItems];
}

- (void)LoadHealthItemsFromPList {
    
    [[SharedData SharedInstance] LoadHealthItemsFromPList];
}

- (void)reloadRequiredHealthItems {
    
    [[SharedData SharedInstance] ReloadRequiredHealthItems];
}

#pragma mark - LegalListTableCellDelegate
- (void)LegalEditorComplete:(LegalListEditorTableCell *)cell {
    
    [[SharedData SharedInstance] ReloadLegalClauses];
    [self DeselectRowAtCell:cell];
}

#pragma mark - Device Orientation Delegates
- (UIDeviceOrientation)getDeviceOrientation {
    
    return [[SharedData SharedInstance] GetDeviceOrientation];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation {
    
    [[SharedData SharedInstance] SetDeviceOrientation:orientation];
}

#pragma mark - TextInputTableCell Delegates
- (void)TextInputComplete:(TextInputTableCell *)cell withValue:(NSString *)value {

    [self DeselectRowAtCell:cell];
    [self.view endEditing:YES];
    [self SaveCellValueToUserDefaults:cell withValue:value];
}

- (void)TextInputCompleteWithReturn:(TextInputTableCell *)cell withValue:(NSString *)value {
    
    [self SaveCellValueToUserDefaults:cell withValue:value];
}

- (void)TextInputBeginEditing:(TextInputTableCell *)cell {
    
}

- (void)textChanged:(TextInputTableCell *)cell withString:(NSString *)value {
    
    [self SaveCellValueToUserDefaults:cell withValue:value];
}

#pragma mark - PickerPopupTableCellDelegate
- (void)PickerComplete:(PickerPopupTableCell *)cell withValue:(NSString *)value {
    
    [self DeselectRowAtCell:cell];
    [self SaveCellValueToUserDefaults:cell withValue:value];
}

#pragma mark - SegmentCompleteDelegate
- (void) SegmentComplete:(SegmentedTableCell *)cell withValue:(NSString *)value {
    
    [self DeselectRowAtCell:cell];
}

#pragma mark - TextfieldPopupTableCellDelegate
- (void)TextfieldComplete:(TextfieldPopupTableCell *)cell withValue:(NSString *)value {
    
    [self DeselectRowAtCell:cell];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Tap to Edit %@", cell.textLabel.text];
    
    [self SaveCellValueToUserDefaults:cell withValue:value];
}

#pragma mark - KeypadPopupTableCellDelegate
- (void)KeypadComplete:(KeypadPopupTableCell *)cell withValue:(NSString *)value {
    
    [self DeselectRowAtCell:cell];
    
    if ([[cell GetDescription] isEqualToString:@"Set Passcode"]) {
        
        /*
        NSString *PWType = nil;
        
        if ([[cell GetDataKey] isEqualToString:MASTER_PW_KEY]) {
            
            PWType = MASTER_PW_TYPE;
        }
        else {
            
            PWType = SECONDARY_PW_TYPE;
        }
        
        NSUInteger hashInt = [value integerValue];
        NSString *hash = [KeychainWrapper securedSHA256DigestHashForPIN:hashInt withPWType:PWType];
        
        [KeychainWrapper updateKeychainValue:hash forIdentifier:[cell GetDataKey]];
        */
        
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:[cell GetDataKey]];
        
        NSLog(@"updated pw: %@", [cell GetDataKey]);
        
    }
    else {
    
        [self SaveCellValueToUserDefaults:cell withValue:value];
    }
    
}

#pragma mark - GeneralTableCellDelegate
- (void)GeneralCellComplete:(VolutaTRFCell *)cell {
    
    [self DeselectRowAtCell:cell];
    
    if ([[cell GetDescription] isEqualToString:@"Remove Logo"]) {
        
        UIAlertController *alert = [self.Alerts CreateYesNoAlert:^(UIAlertAction *action)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USING_LOGO_KEY];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
            NSString *filePath = [documentsPath stringByAppendingPathComponent:@"logo.png"]; //Add the file name
            
            NSFileManager *fm = [[NSFileManager alloc] init];
            [fm removeItemAtPath:filePath error:nil];
            
            [self SetupSettingsTable];
            [_SettingsView.Table reloadData];
            
        }
                                                   withNoHandler:^(UIAlertAction *action){}
                                                       withTitle:@"Confirmation"
                                                     withMessage:@"Are you sure you want to remove the logo?"];
        
        [self presentViewController:alert animated:NO completion:nil];
        
    }
}

#pragma mark - SwitchTableCellDelegate
- (void)SwitchChanged:(bool)value withCell:(SwitchTableCell *)cell {
    
    if ([[[cell textLabel] text] isEqualToString:@"Enable Dropbox cloud"]) {
        
        [_CloudServiceCells setObject:cell forKey:@"Dropbox"];
        
        if(value)
        {
            bool dropboxLinked = [_CloudServiceManager isDropboxAuthorized];
            if (!dropboxLinked)
            {
                [[SharedData SharedInstance] SetSettingsVC:self];
                _isAuthenticatingCloudService = YES;
                [_CloudServiceManager LinkDropbox:self];
            }
            else {
                
                [self CloudServiceLinked:YES withServiceName:@"Dropbox"];
            }
        }
        else
        {
            [_CloudServiceManager UnlinkDropbox];
            [self UnlinkService:@"Dropbox"];
        }
        
    }
    else if ([[[cell textLabel] text] isEqualToString:@"Enable Google Drive cloud"]) {
        
        [_CloudServiceCells setObject:cell forKey:@"Google Drive"];
        
        if(value)
        {
            bool googdriveLinked = [_CloudServiceManager isGoogleDriveAuthorized];
            
            if (!googdriveLinked)
            {
                _isAuthenticatingCloudService = YES;
                [_CloudServiceManager LinkGoogleDrive:self];
            }
            else {
                
                [self CloudServiceLinked:YES withServiceName:@"Google Drive"];
            }
        }
        else
        {
            [_CloudServiceManager UnlinkGoogleDrive];
            [self UnlinkService:@"Google Drive"];
        }
    }
    else if ([[[cell textLabel] text] isEqualToString:@"Enable OneDrive cloud"]) {
        
        [_CloudServiceCells setObject:cell forKey:@"OneDrive"];
        
        if(value)
        {
            bool onedriveLinked = [_CloudServiceManager isOneDriveAuthorized];
            
            if (!onedriveLinked)
            {
                _isAuthenticatingCloudService = YES;
                [_CloudServiceManager LinkOneDrive:self];
            }
            else {
                
                [self CloudServiceLinked:YES withServiceName:@"OneDrive"];
            }
        }
        else
        {
            [_CloudServiceManager UnlinkOneDrive];
            [self UnlinkService:@"OneDrive"];
        }
        
    }
    else if ([[[cell textLabel] text] isEqualToString:@"Enable Box cloud"]) {
        
        [_CloudServiceCells setObject:cell forKey:@"Box"];
        
        if(value)
        {
            bool boxLinked = [_CloudServiceManager isBoxAuthorized];
            
            if (!boxLinked)
            {
                _isAuthenticatingCloudService = YES;
                [_CloudServiceManager LinkBox];
            }
            else {
                
                [self CloudServiceLinked:YES withServiceName:@"Box"];
            }
        }
        else
        {
            [_CloudServiceManager UnlinkBox];
            [self UnlinkService:@"Box"];
        }
    }
    else if ([[[cell textLabel] text] isEqualToString:@"Require Email"]) {
        
        //Check to make sure automatic emailer is enabled, if so, do not disable
        NSString *AutomaticEmailer = [[NSUserDefaults standardUserDefaults] objectForKey:USING_EMAILER_KEY];
        
        if (AutomaticEmailer != nil && [AutomaticEmailer isEqualToString:@"Yes"]) {
            
            if (!value) {
                
                UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action)
                                            {
                                                [((SwitchTableCell *)cell).cellSwitch setOn:YES];
                                            }
                                                            withTitle:@"Attention"
                                                          withMessage:@"Your automatic emailer is active, which requires email addresses"];
                
                [self presentViewController:alert animated:NO completion:nil];
            }
            
            NSString *key = [cell GetDataKey];
            
            [[NSUserDefaults standardUserDefaults] setValue:@"Yes" forKey:key];
        }
        else {
            
            NSString *val = value ? @"Yes" : @"No";
            NSString *key = [cell GetDataKey];
            
            [[NSUserDefaults standardUserDefaults] setValue:val forKey:key];
        }
    }
    else if ([[[cell textLabel] text] isEqualToString:@"Search the Cloud"]) {

        NSString *key = [cell GetDataKey];

        if (@available(iOS 11.0, *)) {

            NSString *val = value ? @"Yes" : @"No";
            [[NSUserDefaults standardUserDefaults] setValue:val forKey:key];

        }
        else {

            if (value) {

                UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action)
                                            {
                                                [((SwitchTableCell *)cell).cellSwitch setOn:NO];
                                                [[NSUserDefaults standardUserDefaults] setValue:@"No" forKey:key];
                                            }
                                                            withTitle:@"Attention"
                                                          withMessage:@"This feature requires iOS11+"];

                [self presentViewController:alert animated:NO completion:nil];
            }
        }

    }
    else {
        
        NSString *val = value ? @"Yes" : @"No";
        NSString *key = [cell GetDataKey];
        
        [[NSUserDefaults standardUserDefaults] setValue:val forKey:key];
        
    }
}

#pragma mark - CloudServiceLinkDelegate
- (void)CloudServiceLinked:(BOOL)success withServiceName:(NSString *)ServiceName {
    
    NSString *title = @"";
    NSString *message = @"";
    NSString *key = @"";
    NSString *value = @"";
    
    if (success) {
        
        title = [NSString stringWithFormat:@"%@ Linked",ServiceName];
        message = [NSString stringWithFormat:@"%@ Linked Successfully",ServiceName];
        value = @"Yes";
    }
    else {
        
        title = [NSString stringWithFormat:@"%@ Not Linked",ServiceName];
        message = [NSString stringWithFormat:@"%@ Failed to Link",ServiceName];
        value = @"No";
    }
    
    AlertManager *alerts = [[SharedData SharedInstance] GetAlertManager];
    _CloudAlert = [alerts CreateOKAlert:^(UIAlertAction *action){}
                              withTitle:title
                            withMessage:message];
    
    if ([ServiceName isEqualToString:@"Dropbox"]) {
        
        SwitchTableCell *cell = [_CloudServiceCells objectForKey:@"Dropbox"];
        [cell.cellSwitch setOn:[value isEqualToString:@"Yes"]];
        
        key = USING_DROPBOX_KEY;
    }
    else if ([ServiceName isEqualToString:@"Google Drive"]) {
        
        SwitchTableCell *cell = [_CloudServiceCells objectForKey:@"Google Drive"];
        [cell.cellSwitch setOn:[value isEqualToString:@"Yes"]];
        
        key = USING_GOOGLEDRIVE_KEY;
    }
    else if ([ServiceName isEqualToString:@"OneDrive"]) {
        
        SwitchTableCell *cell = [_CloudServiceCells objectForKey:@"OneDrive"];
        [cell.cellSwitch setOn:[value isEqualToString:@"Yes"]];
        
        key = USING_ONEDRIVE_KEY;
    }
    else if ([ServiceName isEqualToString:@"Box"]) {
        
        SwitchTableCell *cell = [_CloudServiceCells objectForKey:@"Box"];
        [cell.cellSwitch setOn:[value isEqualToString:@"Yes"]];
        
        key = USING_BOX_KEY;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        
    // Delay execution of my block for 10 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self ShowCloudLinkedAlert];
        
    });
    
    
    
}

- (void)UnlinkService:(NSString *)ServiceName {
    
    NSString *title = @"";
    NSString *message = @"";
    NSString *key = @"";
    NSString *value = @"";
    
    title = [NSString stringWithFormat:@"%@ Unlinked",ServiceName];
    message = [NSString stringWithFormat:@"%@ is no longer linked to the app",ServiceName];
    value = @"No";

    AlertManager *alerts = [[SharedData SharedInstance] GetAlertManager];
    UIAlertController *alert = [alerts CreateOKAlert:^(UIAlertAction *action){}
                                           withTitle:title
                                         withMessage:message];
    
    if ([ServiceName isEqualToString:@"Dropbox"]) {
        
        key = USING_DROPBOX_KEY;
    }
    else if ([ServiceName isEqualToString:@"Google Drive"]) {
        
        key = USING_GOOGLEDRIVE_KEY;
    }
    else if ([ServiceName isEqualToString:@"OneDrive"]) {
        
        key = USING_ONEDRIVE_KEY;
    }
    else if ([ServiceName isEqualToString:@"Box"]) {
        
        key = USING_BOX_KEY;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    
    [self presentViewController:alert animated:NO completion:nil];
}

#pragma mark - CloudServiceUploadDelegate
- (void)FileUploadComplete:(bool)UploadSuccessful {
    
    NSString *title = @"Upload Successful";
    NSString *message = @"File uploaded to your cloud";
    
    if (!UploadSuccessful) {
        
        title = @"Upload Error";
        message = @"File could not be uploaded.";
    }
    
    UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){}
                                                withTitle:title
                                              withMessage:message];
    
    [self presentViewController:alert animated:NO completion:nil];
}

#pragma mark - DatabaseViewerTableCellDelegate
- (void)DatabaseViewerComplete:(DatabaseViewerTableCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

- (NSArray *)GetClientList {
    
    return [_CoreDataManager FindForms:@"*.*"];
}

- (void)RemoveClients:(NSArray *)ClientIndices {
    
    [_CoreDataManager RemoveForms:ClientIndices];
}

- (void)RemoveDuplicates:(DatabaseViewerViewController *)DBViewerVC {
    
    UIAlertController *RemoveBusyAlert = [self.Alerts CreateBusyAlert:@"Removing Duplicates" withMessage:@"Removing Duplicate Entries. Please wait"];
    
    [self presentViewController:RemoveBusyAlert animated:NO completion:^() {
        
        NSUInteger numRemoved = [_CoreDataManager RemoveDuplicates];
        
        [RemoveBusyAlert dismissViewControllerAnimated:NO completion:^(){
        
            UIAlertController *ConfirmationAlert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){}
                                                                    withTitle:@"Complete"
                                                                  withMessage:[NSString stringWithFormat:@"%ld duplicates removed", numRemoved]];
            
            if (numRemoved > 0) {
                
                [DBViewerVC ReloadDBView];
            }
            
            [self presentViewController:ConfirmationAlert animated:NO completion:nil];
            
        }];
        
    }];
    

}

- (void)UploadSelectedClients:(NSArray *)ListOfClients {
    
    _UploadBusyAlert = [self.Alerts CreateBusyAlert:@"Uploading"
                                        withMessage:[NSString stringWithFormat:@"Uploading 1 of %ld", [ListOfClients count]]];
    
    _NumToUpload = [ListOfClients count];
    
    [self presentViewController:_UploadBusyAlert animated:NO completion:^() {
        
        _CloudServiceManager.pendingDelegate = self;
        [_CloudServiceManager UploadPendingForms:ListOfClients];
        

        
    }];

}

#pragma mark - CloudServicePendingUploadDelegate
- (void)PendingUploadComplete:(bool)UploadSuccessful {
    
    [_UploadBusyAlert dismissViewControllerAnimated:NO completion:^(){
        
        NSString *msg = @"The selected forms have been uploaded";
        
        if (!UploadSuccessful) {
            msg = @"There was a problem uploading your forms.";
        }
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Uploads" withMessage:msg];
        
        [self presentViewController:alert animated:NO completion:nil];
        
    }];
    
}

- (void)PendingUploadProgress:(NSUInteger)CurrentPendingNum withTotal:(NSUInteger)TotalToUpload {
    
    NSString *msg = [NSString stringWithFormat:@"Uploading %lu of %lu\n\n\n\n\n",(CurrentPendingNum + 1),(unsigned long)_NumToUpload];
    
    _UploadBusyAlert.message = msg;
}

- (NSString *)GetTempPath {
    
    return [[SharedData SharedInstance] GetTempPath];
}

#pragma mark - EmailCredentialsTableCellDelegate
- (void)EmailCredentialsComplete:(EmailCredentialsTableCell *)cell isEmailerEnabled:(bool)isEnabled {
    
    [self DeselectRowAtCell:cell];
    
    if (isEnabled) {
        
        //Reload table because force email option may have
        //changed when enabling automatic emailer
        [self SetupSettingsTable];
        [_SettingsView.Table reloadData];
    }
    
}

- (void)EmailCredentialsCanceled:(EmailCredentialsTableCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

- (void)SendTestEmail:(NSDictionary *)EmailData {
    
    NSString *EmailingPDF = [EmailData objectForKey:@"Email PDF to Client"];

    bool isEmailingPDF = [EmailingPDF isEqualToString:@"Yes"];
     
    NSString *attachment = [EmailData objectForKey:@"email attachment"];
    
    _BusyAlert = nil;
    
    if (attachment != nil && isEmailingPDF) {
        
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *DocumentsDir = [documentPaths objectAtIndex:0];
        
        attachment = [NSString stringWithFormat:@"%@/%@",DocumentsDir, attachment];
        
        [_Emailer SendEmail:@"Test Email"
              withEmailBody:@"This is a test email with an attachment"
                    toEmail:[_Emailer GetEmail]
             withAttachment:attachment];
    }
    else {
        
        [_Emailer SendEmail:@"Test Email"
              withEmailBody:@"This is a test email without an attachment"
                    toEmail:[_Emailer GetEmail]
             withAttachment:nil];
    }
    
}

#pragma mark -
#pragma Emailer delegate
- (void)EmailerAttemptingToSend {
    
    _BusyAlert = [self.Alerts CreateBusyAlert:@"Emailer Busy" withMessage:@"Sending test email. Please wait..."];
    
    [self presentViewController:_BusyAlert
                       animated:NO
                     completion:nil];
}

- (void)EmailerSendSuccess {
    
    NSLog(@"Emailer successfull");
    
    
    [_BusyAlert dismissViewControllerAnimated:NO completion:^(){
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){}
                                                    withTitle:@"Confirmation"
                                                  withMessage:@"Email settings are valid."];
        
        [self presentViewController:alert animated:NO completion:nil];
        
    }];
    
}

- (void)EmailerSendFailure:(NSString *)ErrorMessage {
    
    NSLog(@"Emailer failed: %@", ErrorMessage);
    
    UIAlertController *erralert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){}
                                                   withTitle:@"Settings Error"
                                                 withMessage:[NSString stringWithFormat:@"Email Settings Invalid: %@\n\nPlease disable then enable the emailer, and check all other settings",ErrorMessage]];
    
    if (_BusyAlert) {
        
        [_BusyAlert dismissViewControllerAnimated:NO completion:^(){
            
            [self presentViewController:erralert animated:NO completion:nil];
        }];
    }
    else {
        
        [self presentViewController:erralert animated:NO completion:nil];
    }
    
}


- (void)AuthComplete:(bool)success {
    
    
}

- (void)EmailerNotAuthenticated {
    
}

- (void)EmailerEnabled:(UIViewController *)VC {
    
    _isAuthenticatingEmailer = YES;
    [_Emailer startOAuth2:VC];
}

- (void)EmailerDisabled {
    
    _isAuthenticatingEmailer = NO;
    [_Emailer UnlinkGmail];
}

- (void)SetAuthorizationFlow:(id<OIDAuthorizationFlowSession>)CurrentFlow {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.currentAuthorizationFlow = CurrentFlow;
}

#pragma mark - FinancialsReportGeneratorTableCell
- (void)FinancialReportComplete:(FinancialsReportGeneratorTableCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

- (NSArray *)GetEmployeeList {
    
    EmployeeListManager *EmployeeManager = [[EmployeeListManager alloc] init];
    return [EmployeeManager GetEmployeeList];
}

#pragma mark - DatabaseExporterTableCellDelegate
- (void)DatabaseExporterComplete:(VolutaTRFCell *)cell withFilename:(NSString *)Filename {
    
    [self DeselectRowAtCell:cell];
    
    NSString *tempdirectory = [Utilities GetTempDirectory];
    [_CloudServiceManager UploadFile:Filename withFilepath:tempdirectory];
    
}

- (void)DatabaseExporterCanceled:(VolutaTRFCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

- (CoreDataManager *)GetCoreDataManager {
    
    return _CoreDataManager;
}

- (NSString *)GetAppName {
    
    return @"TRF";
}

- (bool)CanDatabaseExportProceed {
    
    InAppPurchaseManager *IAPManager = [[SharedData SharedInstance] GetIAPManager];
    
    return ([IAPManager HasSubscription] ||
            [IAPManager HasExportSubscription] ||
            [IAPManager HasFreeForms]);
}

- (void)DatabaseExporterDeclined {
    
    UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){}
                                                withTitle:@"Subscription Required"
                                              withMessage:@"The client list export requires either the 365 export subscription OR the unlimited subscription. Please visit the in-app purchases page for more information."];
    
    [self presentViewController:alert animated:NO completion:nil];
}

#pragma mark - PhoneNumberTableCellDelegate
- (bool)IsInternational {
    
    return NO;
}

#pragma mark - EmployeeListTableCellDelegate
- (void)editingComplete:(EmployeeListPopupTableCell *)cell {

    NSArray *employees = [self GetEmployeeList];
    
    if ([employees count] > 0) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:EMPLOYEE_LIST_KEY];
        NSString *msg = [NSString stringWithFormat:@"Tap to Edit %@", cell.textLabel.text];
        cell.detailTextLabel.text = msg;
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EMPLOYEE_LIST_KEY];
    }
    
    [self DeselectRowAtCell:cell];
}

- (NSString *)GetAddButtonTitle {
    
    return @"Add a Specialist";
}

#pragma mark - LogoSelectorTableCellDelegate
- (void)LogoSelectorCellComplete:(VolutaTRFCell *)cell withImage:(NSString *)ImageNameAndPath {
    
    [self DeselectRowAtCell:cell];
    
    if (ImageNameAndPath != nil) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:[cell GetDataKey]];
    }

    [_SettingsView.Table reloadData];
}

#pragma mark - SlideshowSetupTableCellDelegate
- (void)SlideshowSetupComplete:(VolutaTRFCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

#pragma mark - AdditionalFormSetupTableCellPopupDelegate
- (void)AdditionalFormSetupComplete:(VolutaTRFCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

- (CloudServiceManager *)GetCloudServiceManager {
    
    return [[SharedData SharedInstance] GetCloudServices];
}

#pragma mark - SegmentSupportingDocumentDelegate
- (void)SupportingDocumentsComplete:(NSMutableDictionary *)SupportingDocument {
    
    [_FormDataManager AddSupportingDocument:SupportingDocument];
}

#pragma mark - HowToViewControllerDelegate
- (void)HowToVCComplete {
    
    [HowToVC dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - DatabaseBackupTableCellDelegate
- (void)DatabaseBackupComplete:(VolutaTRFCell *)cell withSuccess:(bool)success {
    
    [self DeselectRowAtCell:cell];
}

- (bool)CanDatabaseBackupProceed {
    
    return YES;
}

#pragma mark - DatabaseRestoreTableCellDelegate
- (void)DatabaseRestoreComplete:(VolutaTRFCell *)cell withSuccess:(bool)success {
 
    [self DeselectRowAtCell:cell];
}

- (bool)CanDatabaseRestoreProceed {
    
    return YES;
}

#pragma mark - DatabaseSyncOptionsTableCellDelegate
- (void)DatabaseSyncOptionsComplete:(DatabaseSyncOptionsTableCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

#pragma mark - SettingsBackupTableCellDelegate
- (void)SettingsBackupComplete:(VolutaTRFCell *)cell withSuccess:(bool)success {
    
    [self DeselectRowAtCell:cell];
}

- (NSString *)GetAppID {
    
    return APP_ID;
}

#pragma mark - SettingsRestoreTableCellDelegate
- (void)SettingsRestoreComplete:(VolutaTRFCell *)cell withSuccess:(bool)success {
    
    [self DeselectRowAtCell:cell];
    
    if (success) {
        
        [self SetupSettingsTable];
    }
    
}

#pragma mark - PrivacyViewerTableCellDelegate
- (void)PrivacyViewerSelectionComplete:(VolutaTRFCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

- (NSString *)GetPrivacyPolicyURL {

    return PRIVACY_POLICY_URL;
}

#pragma mark - SubscriptionRestoreTableCellDelegate
- (void)SubscriptionRestoreComplete:(VolutaTRFCell *)cell withSuccess:(bool)success {
    
    [self DeselectRowAtCell:cell];
}

- (InAppPurchaseManager *)GetIAPManager {
    
    return [[SharedData SharedInstance] GetIAPManager];
}

#pragma mark - SettingsViewDelegate
- (void)SaveAndVerifySettings {
    
    if ([self CheckForRequiredSettings]) {
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action)
                                    {
                                        [_AboutView SetupBackgroundImage];
                                        [self GoToAbout];
                                    }
                                                    withTitle:@"Success!"
                                                  withMessage:@"Your settings have been verified and saved!"];
        
        
        [self presentViewController:alert animated:NO completion:nil];
    }

}

#pragma mark - IAPViewDelegate
- (void)IAPPurchaseStarted:(NSString *)PID withPrice:(NSString *)Price {
    
    NSRange unlimitedRange = [PID rangeOfString:@"Unlimited"];
    NSRange exportRange = [PID rangeOfString:@"DatabaseExport"];
    
    NSString *msg = @"Are you sure you want to purchase more forms?";
    
    if (unlimitedRange.location != NSNotFound) {
        
        msg = [NSString stringWithFormat:@"Are you sure you want to purchase the unlimited subscription for %@ per month?\n\nAdditional info about the subscription:\n• Subscription is auto-renewing monthly\n• Payment is charged to iTunes Account at confirmation of purchase\n• Subscription automatically renews monthly unless auto-renew is turned off at least 24-hours before the end of the current period\n• Account is charged for renewal within 24-hours prior to the end of the current period, and identifies the cost of the renewal\n• Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase\n• No cancellation of the current subscription is allowed during active subscription period\n• Privacy policy can be viewed at https://www.tattooandpiercingreleaseforms.com/vtd-apps-privacy-policies.html\n• Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication.", Price];
    }
    else if (exportRange.location != NSNotFound) {
        
        msg = [NSString stringWithFormat:@"Are you sure you want to purchase the database export subscription for %@ per year?\n\nAdditional info about the subscription:\n• Subscription is auto-renewing monthly\n• Payment is charged to iTunes Account at confirmation of purchase\n• Subscription automatically renews annually unless auto-renew is turned off at least 24-hours before the end of the current period\n• Account is charged for renewal within 24-hours prior to the end of the current period, and identifies the cost of the renewal\n• Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase\n• No cancellation of the current subscription is allowed during active subscription period\n• Privacy policy can be viewed at https://www.tattooandpiercingreleaseforms.com/vtd-apps-privacy-policies.html\n• Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication.", Price];
    }
    
    
    UIAlertController *confirmAlert = [self.Alerts CreateYesNoAlert:^(UIAlertAction *action)
                                       {
                                           [_InAppPurchasesView MakePurchase:PID];
                                           
                                           if (_BusyAlert == nil) {
                                               
                                               _BusyAlert = [self.Alerts CreateBusyAlert:@"Please Wait" withMessage:@"Making purchase..."];
                                           }
                                           
                                           [self presentViewController:_BusyAlert animated:NO completion:nil];
                                       }
                                                      withNoHandler:^(UIAlertAction *action){}
                                                          withTitle:@"Confirm Purchase"
                                                        withMessage:msg];
    
    [self presentViewController:confirmAlert animated:NO completion:nil];
    
    /*
     if (_BusyAlert == nil) {
     
     _BusyAlert = [self.Alerts CreateBusyAlert:@"Please Wait" withMessage:@"Making purchase..."];
     }
     
     [self presentViewController:_BusyAlert animated:NO completion:nil];
     */
}

- (void)IAPPurchaseEnded:(bool)Success {
    
    [_BusyAlert dismissViewControllerAnimated:NO completion:^(){
        
        NSString *msg = @"Your purchase has been made!";
        
        if (!Success) {
            
            msg = @"Unfortunately there was an error. Please try again later.";
        }
        
        UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){}
                                                    withTitle:@"Purchase"
                                                  withMessage:msg];
        
        [self presentViewController:alert animated:NO completion:nil];
        
    }];
}

- (void)IAPSubscriptionAbort {

    UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){} withTitle:@"Error" withMessage:@"You already have a subscription. There is nothing else for you to purchase!"];
    
    [self presentViewController:alert animated:NO completion:nil];
    
}

#pragma mark - BasePasswordDelegate
- (void)PasswordSuccessful:(NSString *)PasswordPromptTitle withSuccess:(bool)Success {
    
    _isShowingPasswordPrompt = NO;
    
    if (Success) {
        
        if ([[_PageTitles objectAtIndex:_CurrentPageNumber] isEqualToString:@"Settings"]) {
            
            _CurrentView = _SettingsView;
            [self.view addSubview:_SettingsView];
        }
        else if ([[_PageTitles objectAtIndex:_CurrentPageNumber] isEqualToString:@"In App Purchases"]) {
            
            [_InAppPurchasesView CheckAndLoadProducts];
            _CurrentView = _InAppPurchasesView;
            [self.view addSubview:_InAppPurchasesView];
            [self.view bringSubviewToFront:self.OptionsButton];
            
            if (![Utilities HasNetworkConnectivity]) {
                
                UIAlertController *alert = [self.Alerts CreateOKAlert:^(UIAlertAction *action){}
                                                            withTitle:@"No Internet Connection"
                                                          withMessage:@"An internet connection is required to make a purchase. Please check that you are connected to your cellular network or wifi."];
                
                [self presentViewController:alert animated:NO completion:nil];
                
            }
        }

    }
    
}

- (void)PasswordPromptCanceled:(NSString *)PasswordPromptTitle {
    
    _isShowingPasswordPrompt = NO;
    _isCancelingPasswordPrompt = YES;
    
    [self GoToAbout];
}

- (void)PasswordPromptMaxAttempts:(NSString *)PasswordPromptTitle {
    
    _isShowingPasswordPrompt = NO;
    _isCancelingPasswordPrompt = YES;
    
    [self GoToAbout];
}

- (FormDataManager *)GetFormDataManager {
    
    return _FormDataManager;
}

- (NSString *)GetICloudStoreContainer {
    
    return [[SharedData SharedInstance] GetICloudStoreContainer];
}

#pragma mark - InkListEditorTableCellDelegate
- (void)ListEditorComplete:(VolutaTRFCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

- (InkListManager *)GetInkListManager {
    
    return [[SharedData SharedInstance] GetInkListManager];
}

- (NSString *)GetInkTitle {

    return @"Pigment";
}

#pragma mark - InkThinnerListEditorTableCell
- (InkThinnerListManager *)GetInkThinnerListManager {
    
    return [[SharedData SharedInstance] GetInkThinnerListManager];
}

#pragma mark - BladeListEditorTableCellDelegate
- (BladeListManager *)GetBladeListManager {
    
    return [[SharedData SharedInstance] GetBladeListManager];
}

#pragma mark - NeedleListEditorTableCellDelegate
- (NeedleListManager *)GetNeedleListManager {

    return [[SharedData SharedInstance] GetNeedleListManager];
}

#pragma mark - SalvesListEditorTableCellDelegate
- (SalveListManager *)GetSalveListManager {
    
    return [[SharedData SharedInstance] GetSalveListManager];
}

#pragma mark - DataLogTableCellDelegate
- (void)DataLogSetupComplete:(VolutaTRFCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

#pragma mark - VIPLoginTableCellDelegate
- (void)VIPLoginComplete:(VolutaTRFCell *)cell {
    
    [self DeselectRowAtCell:cell];
}

@end

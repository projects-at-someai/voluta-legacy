//
//  TableCellManager.m
//  LRF
//
//  Created by Francis Bowen on 5/28/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "TableCellManager.h"

@implementation TableCellManager

@synthesize Datasource;

- (id)init {
    
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (VolutaTRFCell *)CreateCell:(UIViewController *)ParentViewController
                 withCellType:(NSString *)CellType
          withCellDescription:(NSString *)CellDescription
                withCellTitle:(NSString *)TitleText
               withDetailText:(NSString *)DetailText
           withIsResubmitting:(bool)IsResubmitting
            withResubmitValue:(NSString *)ResubmitValue
                  withDataKey:(NSString *)DataKey {
    
    VolutaTRFCell *cell;
    
    if ([DetailText isEqualToString:@"*"]) {
        DetailText = @"";
    }
    
    if ([CellType isEqualToString:@"TxtInput"]) {
                
        cell = [[TextInputTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TextInput"];
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:@""];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        ((TextInputTableCell *)cell).delegate = (id<TextInputTableCellDelegate>)ParentViewController;
        
        if (IsResubmitting) {
            [((TextInputTableCell *)cell) assignText:ResubmitValue];
        }
    }
    else if ([CellType isEqualToString:@"Header"] || [CellType isEqualToString:@"Legal Header"] ) {
        
        CGFloat fontSize = [DetailText floatValue];
        
        //Page description cell
        cell = [[VolutaTRFCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PageDescription"];

        //Configure cell...
        [[cell textLabel] setText:@""];
        [[cell detailTextLabel] setText:@""];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        if ([CellType isEqualToString:@"Legal Header"] ) {
            
            NSString *businessname = [[NSUserDefaults standardUserDefaults] objectForKey:BUSINESS_NAME_KEY];
            
            if (businessname == nil) {
                businessname = @"";
            }
            
            CellDescription = [CellDescription
                               stringByReplacingOccurrencesOfString:@"<BusinessName>"
                               withString:businessname];
        }
        
        CGRect r = [CellDescription boundingRectWithSize:CGSizeMake(460.0f, 0.0f)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont fontWithName:VTD_FONT size:fontSize]}
                                                 context:nil];
        
        UILabel *PageDescription = [[UILabel alloc] init];
        PageDescription.text = CellDescription;
        CGRect titleFrame;
        titleFrame.origin.x = 10.0f;
        titleFrame.origin.y = 10.0f;
        titleFrame.size.width = 480.0f;
        titleFrame.size.height = r.size.height + 20.0f;
        PageDescription.frame = titleFrame;
        PageDescription.backgroundColor = [UIColor clearColor];
        [PageDescription setFont:[UIFont fontWithName:VTD_FONT size:fontSize]];
        PageDescription.textAlignment = NSTextAlignmentCenter;
        PageDescription.numberOfLines = 0;
        
        [cell.contentView addSubview:PageDescription];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell SetCellHeight:(titleFrame.size.height + 20.0f)];
    }
    else if ([CellType isEqualToString:@"Picker"]) {
        
        if ([CellDescription isEqualToString:@"Artist Picker"]) {
            
            cell = [[ArtistPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                reuseIdentifier:@"Artist Picker Cell"
                                       withParentViewController:ParentViewController
                                                 withDatasource:(id<ArtistPickerTableCellDelegate>)ParentViewController];
        
        }
        else if ([CellDescription isEqualToString:@"Australian State Picker"]) {
            
            cell = [[AustralianStatePickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Australian State Picker" withParentViewController:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Body Placement Picker"]) {
            
            cell = [[BodyPlacementPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Body Placement Picker" withParentViewController:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Cosmetic Placement Picker"] || [CellDescription isEqualToString:@"Microblade Placement Picker"]) {
            
            cell = [[CosmeticLocationPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cosmetic Placement Picker" withParentViewController:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Canadian Province Picker"]) {
            
            cell = [[CanadianProvincePickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Canadian Province Cell" withParentViewController:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Hour Picker"]) {
            
            cell = [[HourTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Hour Picker Cell" withParentViewController:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Orientation Picker"]) {
            
            cell = [[OrientationPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Orienation Picker" withParentViewController:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Piercer Picker"]) {
            
            cell = [[PiercerPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                 reuseIdentifier:@"Piercer Picker"
                                        withParentViewController:ParentViewController
                                                  withDatasource:(id<PiercerPickerTableCellDelegate>)ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Slideshow Delay Picker"]) {
            
            cell = [[SlideshowDelayPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Slideshow Delay Picker" withParentViewController:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"US State Picker"]) {
            
            cell = [[StatePickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"US State Picker" withParentViewController:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"ORF Destination Picker"]) {

            cell = [[ORFDestinationPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ORF Destination Picker" withParentViewController:ParentViewController];

        }
        else if ([CellDescription isEqualToString:@"Timeout Picker"]) {
            
            cell = [[TimeoutPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Timeout Picker" withParentViewController:ParentViewController];
        }
        else if ([CellDescription isEqualToString:@"Employee Picker"]) {
            
            cell = [[EmployeePickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                  reuseIdentifier:@"Employee Picker"
                                         withParentViewController:ParentViewController
                                                   withDatasource:(id<EmployeePickerTableCellDatasource>)ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Referral Picker"]) {
            
            cell = [[ReferralPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Referral Picker" withParentViewController:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Orientation Picker"]) {
            
            cell = [[OrientationPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Orientation Picker" withParentViewController:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Client Piercing Picker"]) {
            
            cell = [[ClientPiercingPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Client Piercing Picker" withParentViewController:ParentViewController];
            
        }
        
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((PickerPopupTableCell *)cell).delegate = (id<PickerPopupTableCellDelegate>)ParentViewController;
        
        if (IsResubmitting) {
            [((PickerPopupTableCell *)cell) SetPickerValue:ResubmitValue];
        }
        
    }
    else if ([CellType isEqualToString:@"General CSV Picker"]) {

        cell = [[GeneralCSVPickerTableCell alloc] initWithStyle:UITableViewCellStyleValue1
                                            reuseIdentifier:@"General CSV Picker Cell"
                                   withParentViewController:ParentViewController
                                             withCSVFilename:CellDescription];

        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];

        ((PickerPopupTableCell *)cell).delegate = (id<PickerPopupTableCellDelegate>)ParentViewController;

        if (IsResubmitting) {
            [((PickerPopupTableCell *)cell) SetPickerValue:ResubmitValue];
        }
    }
    else if ([CellType isEqualToString:@"Keypad"]) {
        
        if ([CellDescription isEqualToString:@"Phone Number"]) {
        
            cell = [[PhoneNumberTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"US Phone Number" withParentViewController:ParentViewController];
            
            ((PhoneNumberTableCell *)cell).delegate = (id<PhoneNumberTableCellDelegate>)ParentViewController;
        }
        else if ([CellDescription isEqualToString:@"Set Passcode"]) {
            
            cell = [[SetPasswordTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Set Passcode" withParentViewController:ParentViewController];
        }
        else if ([CellDescription isEqualToString:@"US Zip Code"]) {
            
            cell = [[ZipCodeTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"US Zip Code" withParentViewController:ParentViewController];
        }
        
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((KeypadPopupTableCell *)cell).keypadpopupdelegate = (id<KeypadPopupTableCellDelegate>)ParentViewController;
        
        if (IsResubmitting) {
            [((KeypadPopupTableCell *)cell) SetKeypadText:ResubmitValue];
        }
        
    }
    else if ([CellType isEqualToString:@"Segment"]) {
        
        if ([CellDescription isEqualToString:@"Gender Selection"]) {
            
            cell = [[GenderSegmentedTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Gender Selection"];
            
            NSArray *genderItems = [[NSArray alloc] initWithObjects:@"Male", @"Female", @"Private", nil];
            
            UISegmentedControl *genderSegment = [[UISegmentedControl alloc] initWithItems:genderItems];
            genderSegment.frame = CGRectMake(270.0, 6.0, 210.0, 44.0);
            
            ((GenderSegmentedTableCell *)cell).SegmentedControl = genderSegment;
            
            [((GenderSegmentedTableCell *)cell).contentView addSubview:genderSegment];
            [((GenderSegmentedTableCell *)cell) startChangeEvent:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"General Segmented Cell"]) {
            
            cell = [[GeneralSegmentedTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"General Segmented Cell" withTxt:TitleText];
            
            NSArray *generalSegmentItems = [[NSArray alloc] initWithObjects:@"Yes", @"No", nil];
            UISegmentedControl *generalSegment = [[UISegmentedControl alloc] initWithItems:generalSegmentItems];
            
            NSInteger cellHeight = [(GeneralSegmentedTableCell *)cell getCellHeight];
            
            if (cellHeight != 56.0f) {
                
                generalSegment.frame = CGRectMake(388.0, cellHeight / 2 - 22.0f, 92.0, 44.0);
            }
            else
            {
                generalSegment.frame = CGRectMake(388.0, 6.0, 92.0, 44.0);
            }
            
            ((GeneralSegmentedTableCell *)cell).SegmentedControl = generalSegment;
            
            [((GeneralSegmentedTableCell *)cell).contentView addSubview:generalSegment];
            [((GeneralSegmentedTableCell *)cell) startChangeEvent:ParentViewController];
            
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;

            
        }
        else if ([CellDescription isEqualToString:@"ID Selection"]) {
            
            cell = [[IDSegmentedTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ID Selection" withParentViewController:ParentViewController];
            
            NSArray *IDItems = [[NSArray alloc] initWithObjects:@"Driver", @"Passport", @"State", @"Gov't", nil];
            
            UISegmentedControl *IDSegment = [[UISegmentedControl alloc] initWithItems:IDItems];
            IDSegment.frame = CGRectMake(129.0, 6.0, 351.0, 44.0);
            
            ((IDSegmentedTableCell *)cell).SegmentedControl = IDSegment;
            [((IDSegmentedTableCell *)cell).contentView addSubview:IDSegment];
            [((IDSegmentedTableCell *)cell) startChangeEvent:ParentViewController];
            
            ((IDSegmentedTableCell *)cell).supportingdocumentdelegate = (id<SegmentSupportingDocumentDelegate>)ParentViewController;
            
        }
        else if ([CellDescription isEqualToString:@"Promotions"]) {
            
            cell = [[PromotionsSegmentedTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Promotions"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSArray *promotionsItems = [[NSArray alloc] initWithObjects:@"Yes", @"No", nil];
            UISegmentedControl *promotionsSegment = [[UISegmentedControl alloc] initWithItems:promotionsItems];
            promotionsSegment.frame = CGRectMake(388.0, 6.0, 92.0, 44.0);
            
            UILabel *segmentTitle = [[UILabel alloc] init];
            segmentTitle.text =  @"Email Opt-in";
            segmentTitle.font = [UIFont fontWithName:VTD_FONT size:24.0f];
            
            CGRect titleFrame;
            titleFrame.origin.x = 14.0f;
            titleFrame.origin.y = 0.0f;
            titleFrame.size.width = 352.0f;
            titleFrame.size.height = 56.0f;
            segmentTitle.frame = titleFrame;
            [segmentTitle setNumberOfLines:2];
            segmentTitle.backgroundColor = [UIColor whiteColor];
            
            //[segmentTitle setFont:[UIFont boldSystemFontOfSize:17]];
            
            ((PromotionsSegmentedTableCell *)cell).SegmentedControl = promotionsSegment;
            
            [((PromotionsSegmentedTableCell *)cell).contentView addSubview:promotionsSegment];
            [((PromotionsSegmentedTableCell *)cell).contentView addSubview:segmentTitle];
            [((PromotionsSegmentedTableCell *)cell) startChangeEvent:ParentViewController];
            
        }
        else if ([CellDescription isEqualToString:@"Yes No Selection"]) {
            
            cell = [[YesNoSegmentedTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Yes No Selection"];
            
            NSArray *internationalItems = [[NSArray alloc] initWithObjects:@"Yes", @"No", nil];
            
            UISegmentedControl *internationalSegment = [[UISegmentedControl alloc] initWithItems:internationalItems];
            internationalSegment.frame = CGRectMake(388.0, 6.0, 92.0, 44.0);
            
            ((YesNoSegmentedTableCell *)cell).SegmentedControl = internationalSegment;
            
            [((YesNoSegmentedTableCell *)cell).contentView addSubview:internationalSegment];
            [((YesNoSegmentedTableCell *)cell) startChangeEvent:self];
        }
        
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:@""];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((SegmentedTableCell *)cell).segmentdelegate = (id<SegmentCompleteDelegate>)ParentViewController;
        
        if (IsResubmitting) {
            [((SegmentedTableCell *)cell) setSegmentWithTitle:ResubmitValue];
        }
    }
    else if ([CellType isEqualToString:@"Textfield"]) {
        
        cell = [[TextfieldPopupTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Textfield" withParentViewController:ParentViewController];
        
        [(TextfieldPopupTableCell *)cell setTitle:CellDescription];
        
        [[cell textLabel] setText:TitleText];
        
        if (IsResubmitting) {
            
            NSString *detail = [NSString stringWithFormat:@"Tap to Edit %@", cell.textLabel.text];
            [[cell detailTextLabel] setText:detail];
        }
        else {
            
            [[cell detailTextLabel] setText:DetailText];
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((TextfieldPopupTableCell *)cell).delegate = (id<TextfieldPopupTableCellDelegate>)ParentViewController;
        
        [((TextfieldPopupTableCell *)cell) setInitialText:ResubmitValue];

    }
    else if ([CellType isEqualToString:@"Signature"]) {
        
        cell = [[SignaturePopupTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Signature" withParentViewController:ParentViewController];
        
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((SignaturePopupTableCell *)cell).signatureDelegate = (id<SignaturePopupTableCellDelegate>)ParentViewController;
        
        if ([CellDescription isEqualToString:@"Client Signature"]) {
            
            [cell setHidden:YES];
        }
        
    }
    else if ([CellType isEqualToString:@"Legal Table"]) {
        
        cell = [[LegalPopupTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Legal Table" withParentViewController:ParentViewController];
        
        [[cell textLabel] setTextColor:[UIColor blueColor]];
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:@""];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((LegalPopupTableCell *)cell).legalDelegate = (id<LegalPopupTableCellDelegate>)ParentViewController;
        
        if (IsResubmitting) {
            [((LegalPopupTableCell *)cell) populateAllInitials:ResubmitValue];
        }
    }
    else if ([CellType isEqualToString:@"Rules Table"]) {
        
        cell = [[RulesPopupTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Rules Table" withParentViewController:ParentViewController];
        
        [[cell textLabel] setTextColor:[UIColor blueColor]];
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:@""];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((RulesPopupTableCell *)cell).rulesDelegate = (id<RulesPopupTableCellDelegate>)ParentViewController;
        
        if (IsResubmitting) {
            [((RulesPopupTableCell *)cell) populateAllInitials:ResubmitValue];
        }
    }
    else if ([CellType isEqualToString:@"Date Picker Popup"] || [CellType isEqualToString:@"Date Picker Popup - Treatment"]) {

        //NET TODO: parse celltype to pull-out title instead of static title
        if([CellType isEqualToString:@"Date Picker Popup - Treatment"])
            cell = [[DatePickerPopupTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DatePicker" withParentViewController:ParentViewController withTitle:@"Date of Treatment" withDateInitFlag:YES];
        else
            cell = [[DatePickerPopupTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DatePicker" withParentViewController:ParentViewController];

        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:@""];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((DatePickerPopupTableCell *)cell).datePickerDelegate = (id<DatePickerPopupTableCellDelegate>)ParentViewController;
        
        if (IsResubmitting) {
            [((DatePickerPopupTableCell *)cell) setInitialDate:ResubmitValue];
        }
        
    }
    else if ([CellType isEqualToString:@"General"]) {
        
        cell = [[GeneralCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier:@"General Cell"];
        
        if ([CellDescription isEqualToString:@"Date"]) {
            
            NSString *Date = [Utilities GetCurrentDate];
            [[cell detailTextLabel] setText:Date];
            
        }
        else {
            
            [[cell detailTextLabel] setText:DetailText];
            ((GeneralCell *)cell).delegate = (id<GeneralTableCellDelegate>)ParentViewController;
            
        }
        
        [[cell textLabel] setText:TitleText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];

    }
    else if ([CellType isEqualToString:@"Switch Cell"]) {
        
        //Switch cell
        cell = [[SwitchTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Switch Cell"];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:@""];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        // Add switch control
        UISwitch *sw = [[UISwitch alloc] init];
        sw.frame = CGRectMake(420.0, 16.0, 210.0, 44.0);
        
        ((SwitchTableCell *)cell).cellSwitch = sw;
        [cell.contentView addSubview:sw];
        [((SwitchTableCell *)cell) initChangeEvent:ParentViewController];
        
        ((SwitchTableCell *)cell).delegate = (id<SwitchTableCellDelegate>)ParentViewController;
        
        ((SwitchTableCell *)cell).cellName = TitleText;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (IsResubmitting) {
            
            [((SwitchTableCell *)cell).cellSwitch setOn:[ResubmitValue isEqualToString:@"Yes"] animated:NO];
        }
        else {
            
            [((SwitchTableCell *)cell).cellSwitch setOn:NO animated:NO];
        }
    }
    else if ([CellType isEqualToString:@"Supporting Documents"]) {
    
        cell = [[SupportingDocumentsListTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SupportingDocumentsCell" withParentViewController:ParentViewController];

        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((SupportingDocumentsListTableCell *)cell).delegate =
            (id<SupportingDocumentsListTableCellDelegate>)ParentViewController;
    }
    else if ([CellType isEqualToString:@"Session Financials"]) {
        
        cell = [[SessionFinancialsTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SessionFinancials" withParentViewController:ParentViewController withInitialData:nil];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((SessionFinancialsTableCell *)cell).delegate =
            (id<SessionFinancialsTableCellDelegate>)ParentViewController;
    }
    else if ([CellType isEqualToString:@"Edit Treatment Record"]) {
        
        cell = [[EditTreatmentRecordsTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"EditTreatmentRecordsCell"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((EditTreatmentRecordsTableCell *)cell).delegate =
        (id<EditTreatmentRecordsTableCellDelegate>)ParentViewController;
    }
    else if ([CellType isEqualToString:@"Database Viewer"]) {
        
        cell = [[DatabaseViewerTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"DatabaseViewerCell"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((DatabaseViewerTableCell *)cell).delegate =
        (id<DatabaseViewerTableCellDelegate>)ParentViewController;
    }
    else if ([CellType isEqualToString:@"Email Credentials"]) {
        
        cell = [[EmailCredentialsTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"EmailCredentialsCell"
                withParentViewController:ParentViewController
                withDelegate:(id<EmailCredentialsTableCellDelegate>)ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    else if ([CellType isEqualToString:@"Financial Report Generator"]) {
        
        cell = [[FinancialsReportGeneratorTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Financial Report Generator"
                withParentViewController:ParentViewController
                withDelegate:(id<FinancialsReportGeneratorTableCellDelegate>)ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    else if ([CellType isEqualToString:@"Database Exporter"]) {
        
        cell = [[DatabaseExporterTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Database Exporter"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((DatabaseExporterTableCell *)cell).delegate = (id<DatabaseExporterTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Employee List"]) {
        
        cell = [[EmployeeListPopupTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Employee List"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];

        if (IsResubmitting) {
            
            NSString *detail = [NSString stringWithFormat:@"Tap to Edit %@", cell.textLabel.text];
            [[cell detailTextLabel] setText:detail];
        }
        else {
            
            [[cell detailTextLabel] setText:DetailText];
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((EmployeeListPopupTableCell *)cell).delegate = (id<EmployeeListTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Image Selector"]) {
        
        cell = [[ImageSelectorTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Image Selector"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((ImageSelectorTableCell *)cell).delegate = (id<ImageSelectorTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Logo Selector"]) {
        
        cell = [[LogoSelectorTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Logo Selector"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((LogoSelectorTableCell *)cell).delegate = (id<LogoSelectorTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Slideshow Setup"]) {
        
        cell = [[SlideshowSetupTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Slideshow Setup"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((SlideshowSetupTableCell *)cell).delegate = (id<SlideshowSetupTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Additional Form Setup"]) {
        
        cell = [[AdditionalFormSetupTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Additional Form Setup"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        //delegate set in initialization of class
        //((AdditionalFormSetupTableCell *)cell).delegate = (id<AdditionalFormSetupTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Database Backup"]) {
        
        cell = [[DatabaseBackupTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Database Backup"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((DatabaseBackupTableCell *)cell).delegate = (id<DatabaseBackupTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Database Restore"]) {
        
        cell = [[DatabaseRestoreTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Database Restore"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    else if ([CellType isEqualToString:@"Device Sync Options"]) {
        
        cell = [[DatabaseSyncOptionsTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Database Sync"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((DatabaseSyncOptionsTableCell *)cell).delegate = (id<DatabaseSyncOptionsTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Settings Backup"]) {
        
        cell = [[SettingsBackupTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Settings Backup Cell"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((SettingsBackupTableCell *)cell).delegate = (id<SettingsBackupTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Settings Restore"]) {
        
        cell = [[SettingsRestoreTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Settings Restore Cell"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((SettingsRestoreTableCell *)cell).restoreDelegate = (id<SettingsRestoreTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Privacy Policy"]) {
        
        cell = [[PrivacyViewerTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Privacy Policy Cell"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((PrivacyViewerTableCell *)cell).delegate = (id<PrivacyViewerTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Subscriptions Restore"]) {
        
        cell = [[SubscriptionRestoreTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Subscriptions Restore"
                withParentViewController:ParentViewController
                withSubscriptionType:@""];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((SubscriptionRestoreTableCell *)cell).delegate = (id<SubscriptionRestoreTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"Data Logger Options"]) {
        
        cell = [[DataLogOptionsTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Data Log Options"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((DataLogOptionsTableCell *)cell).delegate = (id<DataLogOptionsTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"VIP Login"]) {
        
        cell = [[VIPLoginTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"VIP Login Cell"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        ((VIPLoginTableCell *)cell).delegate = (id<VIPLoginTableCellDelegate>)ParentViewController;
        
    }
    else if ([CellType isEqualToString:@"List Popup"]) {
        
        if ([CellDescription isEqualToString:@"Ink List"]) {
            
            cell = [[InkListTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Ink List Table Cell"
                    withParentViewController:ParentViewController];
            
            ((InkListTableCell *)cell).delegate = (id<InkListTableCellDelegate>)ParentViewController;
        }
        else if ([CellDescription isEqualToString:@"Needle List"]) {
            
            cell = [[NeedleListTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Needle List Table Cell"
                    withParentViewController:ParentViewController];
            
            ((NeedleListTableCell *)cell).delegate = (id<NeedleListTableCellDelegate>)ParentViewController;

        }
        else if ([CellDescription isEqualToString:@"Blade List"]) {

            cell = [[BladeListTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Blade List Table Cell"
                    withParentViewController:ParentViewController];

            ((BladeListTableCell *)cell).delegate = (id<BladeListTableCellDelegate>)ParentViewController;

        }
        else if ([CellDescription isEqualToString:@"Ink Thinner List"]) {
            
            cell = [[InkThinnerListTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Ink Thinner List Table Cell"
                    withParentViewController:ParentViewController];
            
            ((InkThinnerListTableCell *)cell).delegate = (id<InkThinnerListTableCellDelegate>)ParentViewController;

        }
        else if ([CellDescription isEqualToString:@"Disposable Grip List"]) {
            
            cell = [[DisposableGripListTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Disposable Grip List Table Cell"
                    withParentViewController:ParentViewController];
            
            ((DisposableGripListTableCell *)cell).delegate = (id<DisposableGripListTableCellDelegate>)ParentViewController;
            
        }
        else if ([CellDescription isEqualToString:@"Disposable Tube List"]) {
            
            cell = [[DisposableTubeListTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Disposable Tube List Table Cell"
                    withParentViewController:ParentViewController];
            
            ((DisposableTubeListTableCell *)cell).delegate = (id<DisposableTubeListTableCellDelegate>)ParentViewController;
        }
        else if ([CellDescription isEqualToString:@"Salve List"]) {
            
            cell = [[SalvesListTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Salves List Table Cell"
                    withParentViewController:ParentViewController];
            
            ((SalvesListTableCell *)cell).delegate = (id<SalvesListTableCellDelegate>)ParentViewController;
            
        }
        else if ([CellDescription isEqualToString:@"Piercing Jewelry List"]) {
            
            cell = [[PiercingJewelryListTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Jewelery Piercing List Table Cell"
                    withParentViewController:ParentViewController];
            
            ((PiercingJewelryListTableCell *)cell).delegate = (id<PiercingJewelryListTableCellDelegate>)ParentViewController;
            
        }
        
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        if (IsResubmitting) {

            
        }
        
    }
    else if ([CellType isEqualToString:@"List Editor"]) {
        
        if ([CellDescription isEqualToString:@"Health List Editor"]) {
            
            cell = [[HealthListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"HealthListEditorTableCell"
                    withParentViewController:ParentViewController];
            
            ((HealthListEditorTableCell *)cell).delegate =
            (id<HealthListTableCellDelegate>)ParentViewController;
        }
        else if ([CellDescription isEqualToString:@"Legal List Editor"]) {
            
            cell = [[LegalListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"LegalListEditorTableCell"
                    withParentViewController:ParentViewController];
            
            ((LegalListEditorTableCell *)cell).delegate =
            (id<LegalListTableCellDelegate>)ParentViewController;
        }
        else if ([CellDescription isEqualToString:@"Rules List Editor"]) {
            
            cell = [[RulesListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"RulesListEditorTableCell"
                    withParentViewController:ParentViewController];
            
            ((RulesListEditorTableCell *)cell).delegate =
            (id<RulesListTableCellDelegate>)ParentViewController;
        }
        else if ([CellDescription isEqualToString:@"General CSV List Editor"]) {

            cell = [[GeneralCSVListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"GeneralCSVListEditorTableCell"
                    withParentViewController:ParentViewController];

            ((GeneralCSVListEditorTableCell *)cell).delegate =
            (id<GeneralCSVListEditorTableCellDelegate>)ParentViewController;
        }
        else if ([CellDescription isEqualToString:@"Laser Treatment Record Editor"]) {
            
            cell = [[LaserTreatmentRecordEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"LaserTreatmentRecordEditorTableCell"
                    withParentViewController:ParentViewController];
            
            ((LaserTreatmentRecordEditorTableCell *)cell).delegate =
            (id<LaserTreatmentRecordEditorTableCellDelegate>)ParentViewController;
        }
        else if([CellDescription isEqualToString:@"Ink List Editor"]) {
            
            cell = [[InkListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Ink List Editor Table Cell"
                    withParentViewController:ParentViewController
                    withDelegate:(id<InkListEditorTableCellDelegate>)ParentViewController];

        }
        else if ([CellDescription isEqualToString:@"Needle List Editor"]) {
            
            cell = [[NeedleListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Needle List Editor Table Cell"
                    withParentViewController:ParentViewController];
            
            ((NeedleListEditorTableCell *)cell).delegate = (id<NeedleListEditorTableCellDelegate>)ParentViewController;
            
        }
        else if ([CellDescription isEqualToString:@"Blade List Editor"]) {

            cell = [[BladeListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Blade List Editor Table Cell"
                    withParentViewController:ParentViewController];

            ((BladeListEditorTableCell *)cell).delegate = (id<BladeListEditorTableCellDelegate>)ParentViewController;

        }
        else if ([CellDescription isEqualToString:@"Ink Thinner List Editor"]) {
            
            cell = [[InkThinnerListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Ink Thinner List Editor Table Cell"
                    withParentViewController:ParentViewController];
            
            ((InkThinnerListEditorTableCell *)cell).delegate = (id<InkThinnerListEditorTableCellDelegate>)ParentViewController;
            
        }
        else if ([CellDescription isEqualToString:@"Disposable Grip List Editor"]) {
            
            cell = [[DisposableGripsListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Disposable Grip List Editor Table Cell"
                    withParentViewController:ParentViewController];
            
            ((DisposableGripsListEditorTableCell *)cell).delegate = (id<DisposableGripsListEditorTableCellDelegate>)ParentViewController;
            
        }
        else if ([CellDescription isEqualToString:@"Disposable Tube List Editor"]) {
            
            cell = [[DisposableTubesListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Disposable Tube List Editor Table Cell"
                    withParentViewController:ParentViewController];
            
            ((DisposableTubesListEditorTableCell *)cell).delegate = (id<DisposableTubesListEditorTableCellDelegate>)ParentViewController;
        }
        else if ([CellDescription isEqualToString:@"Salves List Editor"]) {
            
            cell = [[SalvesListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Salves List Editor Table Cell"
                    withParentViewController:ParentViewController];
            
            ((SalvesListEditorTableCell *)cell).delegate = (id<SalvesListEditorTableCellDelegate>)ParentViewController;
        }
        else if ([CellDescription isEqualToString:@"Jewelry List Editor"]) {
            
            cell = [[JewelryListEditorTableCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:@"Jewelry List Editor Table Cell"
                    withParentViewController:ParentViewController];
            
            ((JewelryListEditorTableCell *)cell).delegate = (id<JewelryListEditorTableCellDelegate>)ParentViewController;
        }
        
        [[cell textLabel] setText:TitleText];
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    else if ([CellType isEqualToString:@"DB Transfer"]) {

        /*
        cell = [[DBTransferManagerCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"DB Transfer Cell"
                withParentViewController:ParentViewController
                withDelegate:(id<DBTransferManagerTableCellDelegate>)ParentViewController
                withAppName:@""];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        */
        
    }
    else if ([CellType isEqualToString:@"Piercing Select"]) {
        
        cell = [[PiercingSelectTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Piercing Select Cell"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    else if ([CellType isEqualToString:@"Service Select"]) {
        
        cell = [[ServiceSelectTableCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:@"Service Select Cell"
                withParentViewController:ParentViewController];
        
        // Configure the cell...
        [[cell textLabel] setText:TitleText];
        
        [[cell detailTextLabel] setText:DetailText];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    else if ([CellType isEqualToString:@"Padding"]) {
        
        cell = [[VolutaTRFCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"padding cell"];
        // Configure the cell...
        [cell setHidden:true];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    }
    
    [cell SetDataKey:DataKey];
    [cell SetDescription:CellDescription];
    [cell SetType:CellType];
    
    return cell;
}

- (NSMutableArray *)CreateHealthItemsCells:(UIViewController *)ParentViewController {
    
    NSMutableArray *HealthItemsCells = [[NSMutableArray alloc] init];
    
    NSArray *Allergies = [Datasource GetAllergies];
    NSArray *Diseases = [Datasource GetDiseases];
    NSArray *HealthConditions = [Datasource GetHealthConditions];
    
    _HealthItemNames = [[NSMutableArray alloc] init];
    _HealthItemTypes = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [Allergies count]; i++) {
        
        NSDictionary *AllergiesDict = [Allergies objectAtIndex:i];
        
        NSString *type = [AllergiesDict objectForKey:@"HealthItemType"];
        NSString *name = [AllergiesDict objectForKey:@"HealthItemName"];
        
        NSArray *cells = [self CreateHealthItemCell:name withType:type withParentViewController:ParentViewController];
        
        [HealthItemsCells addObjectsFromArray:cells];
    }
    
    for (int i = 0; i < [Diseases count]; i++) {
        
        NSDictionary *DiseasesDict = [Diseases objectAtIndex:i];
        
        NSString *type = [DiseasesDict objectForKey:@"HealthItemType"];
        NSString *name = [DiseasesDict objectForKey:@"HealthItemName"];
        
        NSArray *cells = [self CreateHealthItemCell:name withType:type withParentViewController:ParentViewController];
        
        [HealthItemsCells addObjectsFromArray:cells];
    }
    
    for (int i = 0; i < [HealthConditions count]; i++) {
        
        NSDictionary *HealthConditionsDict = [HealthConditions objectAtIndex:i];
        
        NSString *type = [HealthConditionsDict objectForKey:@"HealthItemType"];
        NSString *name = [HealthConditionsDict objectForKey:@"HealthItemName"];
        
        NSArray *cells = [self CreateHealthItemCell:name withType:type withParentViewController:ParentViewController];
        
        [HealthItemsCells addObjectsFromArray:cells];
    }
    
    return HealthItemsCells;
}

- (NSArray *)CreateHealthItemCell:(NSString *)name
                         withType:(NSString *)type
         withParentViewController:(UIViewController *)ParentViewController
{
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    VolutaTRFCell *cell = nil;
    
    if ([type isEqualToString:@"Header"]) {
        
        cell = [self CreateHealthHeaderTableCell:name];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    else if([type isEqualToString:@"Segment"]) {
        
        cell = [self CreateHealthSegmentTableCell:name
                                       hasOptions:NO
                         withParentViewController:ParentViewController];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if([type isEqualToString:@"Text"]) {
        
        cell = [self CreateHealthSegmentTableCell:name
                                       hasOptions:NO
                         withParentViewController:ParentViewController];
        
        [cell SetDataKey:name];
        [cell SetType:type];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cells addObject:cell];
        
        [_HealthItemTypes addObject:@"Segment"];
        [_HealthItemNames addObject:name];
        
        NSString *optionsTitle = @"If yes, list:";
        
        cell = [self CreateHealthTextInputTableCell:optionsTitle
                                        needsIndent:YES
                           withParentViewController:ParentViewController];
        [cell SetType:[NSString stringWithFormat:@"text-answer"]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
    }
    else if([type isEqualToString:@"Text-only"]) {
        
        cell = [self CreateHealthTextInputTableCell:name
                                        needsIndent:NO
                           withParentViewController:ParentViewController];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else if([type isEqualToString:@"Padding"]) {
        
        cell = [self CreatePaddingTableCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (cell != nil) {
    
        [cell SetDataKey:name];
        [cells addObject:cell];
        [_HealthItemTypes addObject:type];
        [_HealthItemNames addObject:name];
    }
    
    return cells;
}

- (VolutaTRFCell *)CreateHealthHeaderTableCell:(NSString *)headerText
{
    VolutaTRFCell *cell = [[VolutaTRFCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Header Cell"];

    UILabel * generalSegmentTitle = [[UILabel alloc] init];
    generalSegmentTitle.text =  headerText;
    
    CGRect titleFrame;
    titleFrame.origin.x = 130.0f;
    titleFrame.origin.y = 11.0f;
    titleFrame.size.width = 240.0f;
    titleFrame.size.height = 33.0f;
    
    generalSegmentTitle.frame = titleFrame;
    generalSegmentTitle.backgroundColor = [UIColor whiteColor];
    [generalSegmentTitle setFont:[UIFont fontWithName:VTD_FONT size:30.0f]];
    generalSegmentTitle.textAlignment = NSTextAlignmentCenter;
    
    [cell.contentView addSubview:generalSegmentTitle];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (GeneralSegmentedTableCell *)CreateHealthSegmentTableCell:(NSString *)segmentText
                                                 hasOptions:(BOOL)options
                                   withParentViewController:(UIViewController *)ParentViewController
{
    GeneralSegmentedTableCell *cell = [[GeneralSegmentedTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SegmentViewCell" withTxt:segmentText];
    
    NSArray *generalSegmentItems = [[NSArray alloc] initWithObjects:@"Yes", @"No", nil];
    UISegmentedControl *generalSegment = [[UISegmentedControl alloc] initWithItems:generalSegmentItems];
    
    NSRange loc = [segmentText rangeOfString:@"History"];
    
    if (loc.location != NSNotFound) {
        NSLog(@"Found it");
    }
    
    NSInteger cellHeight = [cell getCellHeight];
    
    if (cellHeight != 56.0f) {
        
        generalSegment.frame = CGRectMake(388.0, cellHeight / 2 - 22.0f, 92.0, 44.0);
    }
    else
    {
        generalSegment.frame = CGRectMake(388.0, 6.0, 92.0, 44.0);
    }
    
    cell.SegmentedControl = generalSegment;

    [cell.contentView addSubview:generalSegment];
    [cell startChangeEvent:self];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    ((GeneralSegmentedTableCell *)cell).delegate = (id<GeneralSegmentedTableCellDelegate>)ParentViewController;
    
    if (options) {
        ((GeneralSegmentedTableCell *)cell).hasOptions = @"Yes";
    }
    else
    {
        ((GeneralSegmentedTableCell *)cell).hasOptions = @"No";
    }
    
    NSMutableDictionary *requiredItems = [Datasource RequiredHealthItems];
    
    if (![Datasource IsResubmitting])
    {
        if ([requiredItems objectForKey:segmentText] == nil) {
            
            generalSegment.selectedSegmentIndex = 1;    //default to 'no' selection
        }
        else {
            
            generalSegment.selectedSegmentIndex = UISegmentedControlNoSegment;
        }
        
        
    }
    
    ((GeneralSegmentedTableCell *)cell).segmentdelegate = (id<SegmentCompleteDelegate>)ParentViewController;
    
    return cell;
}

- (TextInputTableCell *)CreateHealthTextInputTableCell:(NSString *)textTitle
                                           needsIndent:(BOOL)indent
                              withParentViewController:(UIViewController *)ParentViewController
{
    TextInputTableCell *cell = [[TextInputTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:textTitle];
    
    ((TextInputTableCell *)cell).delegate = (id<TextInputTableCellDelegate>)ParentViewController;
    cell.textLabel.text = textTitle;
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if(indent)
    {
        cell.indentationLevel = 2;
        cell.userInteractionEnabled = false;
    }
    else
    {
        cell.indentationLevel = -1;
        cell.userInteractionEnabled = true;
        
    }
    
    return cell;
}

- (VolutaTRFCell *)CreatePaddingTableCell
{
    VolutaTRFCell *cell = [[VolutaTRFCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PaddingCell"];

    [cell setHidden:true];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

@end

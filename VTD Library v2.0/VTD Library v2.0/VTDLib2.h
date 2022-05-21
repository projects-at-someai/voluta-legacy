//
//  VTDLib2.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 1/10/16.
//  Copyright © 2016 Voluta Tattoo Digital. All rights reserved.
//

#ifndef VTDLib2_h
#define VTDLib2_h

#import "Log.h"

#define VTD_SERVER @"https://volutadigitalvip.com"
#define PUSH_NOTIFICATION_URL   @"https://volutadigitalvip.com/pn/registerdevice.php"

#ifndef DLog
    #ifdef DEBUG
        #define DLog(_format_, ...) NSLog(_format_, ## __VA_ARGS__)
    #else
        #define DLog(_format_, ...)
    #endif
#endif

#ifndef VTD_FONT

    #define VTD_FONT    @"Economica-Regular"

#endif

#define INITIAL_NUM_FREE_FORMS  15

#ifndef NSUSERDEFAULTS_DEFINITIONS
#define NSUSERDEFAULTS_DEFINITIONS

    #define ORIENTATION_KEY             @"orientation-key"
    #define APP_SETUP_KEY               @"setup-complete-key"
    #define HAS_MASTER_PW_KEY           @"has-master-pw-key"
    #define HAS_SECONDARY_PW_KEY        @"has-secondary-pw-key"
    #define MASTER_PW_KEY               @"Master-PW-keychain"
    #define SECONDARY_PW_KEY            @"Secondary-PW-keychain"
    #define MASTER_PW_TYPE              @"MasterPWType"

//Note: ArtistPWType is required to remain compatible with TRF v1.x Cannot use
//      SecondaryPWType because pw hash uses this string

    #define SECONDARY_PW_TYPE           @"ArtistPWType"
    #define USING_DROPBOX_KEY           @"using-dropbox-key"
    #define USING_GOOGLEDRIVE_KEY       @"using-googledrive-key"
    #define USING_ONEDRIVE_KEY          @"using-onedrive-key"
    #define USING_BOX_KEY               @"using-box-key"
    #define BUSINESS_NAME_KEY           @"business-name-key"
    #define CAMERA_TYPE_KEY             @"camera-type-key"
    #define SDOCS_CAMERA_TYPE_KEY       @"sdocs-camera-type-key"
    #define REGION_KEY                  @"region-key"
    #define INITIAL_POPUP_KEY           @"initial-popup-key"
    #define INITIAL_POPUP_TEXT_KEY      @"initial-popup-text-key"
    #define USING_LOGO_KEY              @"using-logo-key"
    #define SLIDESHOW_ALBUM_KEY         @"slideshow-album-key"
    #define SLIDESHOW_DELAY_KEY         @"slideshow-delay-key"
    #define SLIDESHOW_TIMEOUT_KEY       @"slideshow-timeout-key"
    #define USING_SLIDESHOW_KEY         @"using-slideshow-key"
    #define USING_OPTIONALNOTES_KEY     @"using-optional-notes-key"
    #define FORCING_EMAIL_KEY           @"forcing-email-key"
    #define USING_ADDITIONAL_FORM_KEY   @"using-additional-form-key"
    #define IS_APPENDING_ADD_FORM_KEY   @"is-appending-add-form-key"
    #define ADD_FORM_REQUIRED_KEY       @"additional-form-required-key"
    #define ADD_FORM_FILENAME_KEY       @"additional-form-filename-key"
    #define REQUIRE_SEC_GOVT_KEY        @"require-second-govt-pic-key"
    #define USING_DEVICE_SYNC_KEY       @"using-devicesync-key"
    #define LEGAL_NAME_KEY              @"legal-name-key"
    #define BUSINESS_PHONENUMBER_KEY    @"business-phonenumber-key"
    #define BUSINESS_ADDRESS_KEY        @"business-address-key"
    #define BUSINESS_CITY_KEY           @"business-city-key"
    #define BUSINESS_STATE_KEY          @"business-state-key"
    #define BUSINESS_ZIP_KEY            @"business-zipcode-key"
    #define BUSINESS_WEBSITE_KEY        @"business-website-key"
    #define BUSINESS_EMAIL_KEY          @"business-email-key"
    #define EMAILER_USERNAME_KEY        @"emailer-username-key"
    #define EMAILER_SUBJECT_KEY         @"emailer-subject-key"
    #define EMAILER_BODY_KEY            @"emailer-body-key"
    #define EMAILER_ATTACHMENT_KEY      @"emailer-attachment-key"
    #define USING_EMAILER_KEY           @"using-emailer-key"
    #define VERSION_KEY                 @"version-key"
    #define BUILD_KEY                   @"build-key"
    #define REGION_KEY                  @"region-key"
    #define LOCAL_CODES_KEY             @"local-codes-key"
    #define CAPTURE_ID_KEY              @"capture-id-key"
    #define EMAIL_WAIVER_KEY            @"email-waiver-key"
    #define EMAIL_WAIVER_SUBJECT_KEY    @"email-waiver-subject-key"
    #define EMAIL_WAIVER_BODY_KEY       @"email-waiver-body-key"
    #define EMAIL_PDF_KEY               @"email-pdf-key"
    #define EMPLOYEE_LIST_KEY           @"has-employee-list-key"
    #define DEVICETOKEN_KEY             @"device-token-key"
    #define UPDATE_FLAG                 @"v1 update"
    #define USING_DATALOGGER_KEY        @"using-datalogger-key"
    #define IMAGES_EXTRACTED_KEY        @"images-extracted-key"
    #define CDATA_IS_LEECHED_KEY        @"core-data-is-leeched-key"
    #define USING_UBIQUITOUS_FOLDER_KEY @"using-ubiquitous-folder-key"
    #define SYNC_MERGE_STATUS           @"sync-merge-status"
    #define MASTER_PASSCODE             @"master-passcode"
    #define SECONDARY_PASSCODE          @"secondary-passcode"
    #define NUM_FORMS_REVIEW_KEY        @"num-forms-since-last-review-key"
    #define OUT_OF_FORMS_DATE           @"out-of-forms-date-key"
    #define SEARCH_CLOUD_KEY            @"search-cloud-key"
    #define SYNC_PROMPT_KEY             @"sync-prompt-key"
    #define INSTALL_DATE_KEY            @"install-date-key"
    #define UPDATE_DATE_KEY             @"update_date-key"
    #define VIP_EMAIL_KEY               @"Username"

#endif

#ifndef KEYCHAIN_DEFINITIONS
#define KEYCHAIN_DEFINITIONS

    #define DEVICEID_KEYCHAIN_KEY       @"deviceid-key"
    #define EMAILER_PW_KEY              @"emailer-pw-key"
    #define SUB_CHECK_DATE              @"subscription-check-date-key"
    #define EXPORT_SUB_CHECK_DATE       @"export-subscription-check-date-key"
    #define VIP_KEY                     @"vip-key"

#endif

#ifndef PLIST_NAMES
#define PLIST_NAMES

    #define EMPLOYEELIST_PLST_NAME                  @"EmployeeList.plist"

    #define DEFAULT_FINALIZE_PLIST_NAME             @"Finalize.plist"
    #define FINALIZE_PLIST_NAME                     @"Finalize.plist"

    #define DEFAULT_HEALTH_PLIST_NAME               @"DefaultHealth.plist"
    #define HEALTH_PLIST_NAME                       @"Health.plist"

    #define DEFAULT_HEALTHITEMSTOCHECK_PLIST_NAME   @"DefaultHealthItemsToCheck.plist"
    #define HEALTHITEMSTOCHECK_PLIST_NAME           @"HealthItemsToCheck.plist"

    #define DEFAULT_HOWTO_PLIST_NAME                @"HowTo.plist"
    #define HOWTO_PLIST_NAME                        @"HowTo.plist"

    #define DEFAULT_LEGAL_PLIST_NAME                @"DefaultLegal.plist"
    #define LEGAL_PLIST_NAME                        @"Legal.plist"

    #define DEFAULT_PDF_PLIST_NAME                  @"PDF.plist"
    #define PDF_PLIST_NAME                          @"PDF.plist"

    #define DEFAULT_PDFINTER_PLIST_NAME             @"PDFInternational.plist"
    #define PDFINTER_PLIST_NAME                     @"PDFInternational.plist"

    #define DEFAULT_SETTINGSANDOPTIONS_PLIST_NAME   @"SettingsAndOptions.plist"
    #define SETTINGSANDOPTIONS_PLIST_NAME           @"SettingsAndOptions.plist"

    #define DEFAULT_SETTINGSBACKUP_PLIST_NAME       @"SettingsBackup.plist"
    #define SETTINGSBACKUP_PLIST_NAME               @"SettingsBackup.plist"

    #define DEFAULT_SUPPORTINGDOCUMENTS_PLIST_NAME  @"SupportingDocuments.plist"
    #define SUPPORTINGDOCUMENTS_PLIST_NAME          @"SupportingDocuments.plist"

    #define DEFAULT_TABLES_PLIST_NAME               @"Tables.plist"
    #define TABLES_PLIST_NAME                       @"Tables.plist"

    #define DEFAULT_IAP_PLIST_NAME                  @"IAPProducts.plist"
    #define IAP_PLIST_NAME                          @"IAPProducts.plist"

    #define LRF_TRECORD_BUNDLE_NAME                 @"TreatmentRecordBundle"
    #define DEFAULT_LRF_TRECORD_PLIST_NAME          @"DefaultTreatmentRecord.plist"
    #define LRF_TRECORD_NAME                        @"TreatmentRecord.plist"

    #define DEFAULT_RULES_PLIST_NAME                @"DefaultRules.plist"
    #define RULES_PLIST_NAME                        @"Rules.plist"

#endif

#ifndef ORIENTATION_DEFINITIONS
#define ORIENTATION_DEFINITIONS

    #define ORIENTATION_AUTO        @"Auto Rotate"
    #define ORIENTATION_PORTRAIT    @"Fixed Portrait"
    #define ORIENTATION_LANDSCAPE   @"Fixed Landscape"

#endif

#ifndef IMAGE_TYPES_DEFINITIONS
#define IMAGE_TYPES_DEFINITIONS

    #define CLIENT_ID_IMAGE             @"Client ID"
    #define CLIENT_SIGNATURE_IMAGE      @"Client Signature"
    #define EMPLOYEE_SIGNATURE_IMAGE    @"Employee Signature"

#endif

#ifndef IAP_DEFINITIONS
#define IAP_DEFINITIONS

    #define IAP_SUBSCRIPTION                    @"SUBSCRIPTION"
    #define IAP_EXPORT_SUBSCRIPTION             @"EXPORT_SUBSCRIPTION"
    #define IAP_NUMFORMS                        @"NUM_FORMS"
    #define IAP_NUMFREEFORMS                    @"NUM_FREE_FRMS"
    #define IAP_SUBSCRIPTION_EXPIRATION         @"SUB_EXPIRATION"
    #define IAP_SUBSCRIPTION_RECEIPT            @"SUB_RECEIPT"
    #define IAP_EXPORT_SUBSCRIPTION_EXPIRATION  @"EXPORT_SUB_EXPIRATION"
    #define IAP_EXPORT_SUBSCRIPTION_RECEIPT     @"EXPORT_SUB_RECEIPT"

#endif

#define TABLES_US   @"Tables-US"
#define TABLES_UK   @"Tables-UK"
#define TABLES_CAN  @"Tables-CAN"
#define TABLES_AUS  @"Tables-AUS"
#define TABLES_NZ   @"Tables-NZ"

#define PDF_US   @"PDF-US"
#define PDF_UK   @"PDF-UK"
#define PDF_CAN  @"PDF-CAN"
#define PDF_AUS  @"PDF-AUS"
#define PDF_NZ   @"PDF-NZ"

#define SETTINGS_US   @"SettingsAndOptions-US"
#define SETTINGS_UK   @"SettingsAndOptions-UK"
#define SETTINGS_CAN  @"SettingsAndOptions-CAN"
#define SETTINGS_AUS  @"SettingsAndOptions-AUS"
#define SETTINGS_NZ   @"SettingsAndOptions-NZ"

#define FINALIZE_US   @"Finalize-US"
#define FINALIZE_UK   @"Finalize-UK"
#define FINALIZE_CAN  @"Finalize-CAN"
#define FINALIZE_AUS  @"Finalize-AUS"
#define FINALIZE_NZ   @"Finalize-NZ"

#define SETTINGSBACKUP_US   @"SettingsBackup-US"
#define SETTINGSBACKUP_UK   @"SettingsBackup-UK"
#define SETTINGSBACKUP_CAN  @"SettingsBackup-CAN"
#define SETTINGSBACKUP_AUS  @"SettingsBackup-AUS"
#define SETTINGSBACKUP_NZ   @"SettingsBackup-NZ"

#define REGION_US   @"United States"
#define REGION_UK   @"United Kingdom"
#define REGION_CAN  @"Canada"
#define REGION_AUS  @"Australia"
#define REGION_NZ  @"New Zealand"

#ifndef VIEWCONTROLLERNAME_DEFINITIONS

#define HOMESCREEN_VIEWCONTROLLER   @"HomeScreenViewController"
#define SETTINGS_VIEWCONTROLLER     @"SettingsViewController"
#define RESUBMIT_VIEWCONTROLLER     @"ResubmitViewController"
#define INFO_VIEWCONTROLLER         @"InfoViewController"
#define FINALIZE_VIEWCONTROLLER     @"FinalizeViewController"
#define IDCAPTURE_VIEWCONTROLLER    @"IDCaptureViewController"
#define IDVERIFY_VIEWCONTROLLER     @"IDVerifyViewController"
#define HOWTO_VIEWCONTROLLER        @"HowToViewController"
#define LONGTUTORIAL_VIEWCONTROLLER @"LongTutorialViewController"
#define FASTUTORIAL_VIEWCONTROLLER  @"FastTutorialViewController"

#endif

#ifndef BACKGROUND_FILENAME_DEFINITIONS
#define BACKGROUND_FILENAME_DEFINITIONS

    #define NO_BACKGROUND_IMAGE @"No-Background-Image"

    #define ABOUT_PORTRAIT @"P-About"
    #define ABOUT_LANDSCAPE @"L-About"

    #define FASTTUTORIAL_PORTRAIT @"P-FastTutorial"
    #define FASTTUTORIAL_LANDSCAPE @"L-FastTutorial"

    #define FINAL_PORTRAIT @"P-Final"
    #define FINAL_LANDSCAPE @"L-Final"

    #define HOMESCREEN_PORTRAIT @"P-Homescreen"
    #define HOMESCREEN_LANDSCAPE @"L-Homescreen"

    #define HOWTO_PORTRAIT @"P-HowTo"
    #define HOWTO_LANDSCAPE @"L-HowTo"

    #define IDCAPTURE_PORTRAIT @"P-IDCapture"
    #define IDCAPTURE_LANDSCAPE @"L-IDCapture"

    #define IDVERIFY_PORTRAIT @"P-IDVerify"
    #define IDVERIFY_LANDSCAPE @"L-IDVerify"

    #define INAPPPURCHASES_PORTRAIT @"P-InAppPurchases"
    #define INAPPPURCHASES_LANDSCAPE @"L-InAppPurchases"

    #define INFO_PORTRAIT @"P-InfoPage"
    #define INFO_LANDSCAPE @"L-InfoPage"

    #define INITIALSETUP_PORTRAIT @"P-InitialSetup"
    #define INITIALSETUP_LANDSCAPE @"L-InitialSetup"

    #define RESUBMIT_PORTRAIT @"P-Resubmit"
    #define RESUBMIT_LANDSCAPE @"L-Resubmit"

    #define SETTINGSANDOPTIONS_PORTRAIT @"P-SettingsAndOptions"
    #define SETTINGSANDOPTIONS_LANDSCAPE @"L-SettingsAndOptions"

    #define SUPPORTBACK_PORTRAIT @"P-Support"
    #define SUPPORTBACK_LANDSCAPE @"L-Support"

#endif

#define TRFLISTBUNDLE   @"TRFListsBundle"

#define CRFLISTBUNDLE   @"CRFListBundle"

#define SHAREDKEYCHAINGROUP @"4J99F7RRN6.VTDKeychainGroup"

#define REVIEW_THRESHOLD    50

#define OUT_OF_FORMS_PENDING_LIMIT  5

#ifndef VTD_LIGHT_BLUE

    #define VTD_LIGHT_BLUE [UIColor colorWithRed:171.0f/255.0f green:234.0f/255.0f blue:255.0f/255.0f alpha:1.0f]

#endif

#ifndef SYS_CHECK_DEFS
#define SYS_CHECK_DEFS

    #define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
    #define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
    #define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
    #define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
    #define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
    #endif


#endif /* VTDLib2_h */

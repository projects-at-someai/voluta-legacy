//
//  Utilities.m
//  LRF
//
//  Created by Francis Bowen on 6/18/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities


+ (NSString *)StringToHex:(NSString *)str
{
    NSUInteger len = [str length];
    unichar *chars = malloc(len * sizeof(unichar));
    [str getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        // [hexString [NSString stringWithFormat:@"%02x", chars[i]]]; /*previous input*/
        [hexString appendFormat:@"%02x", chars[i]]; /*EDITED PER COMMENT BELOW*/
    }
    free(chars);
    
    return hexString;
}

+ (NSString *)HexStringToString:(NSString *)HexString {
    
    // The hex codes should all be two characters.
    if (([HexString length] % 2) != 0)
        return nil;
    
    NSMutableString *string = [NSMutableString string];
    
    for (NSInteger i = 0; i < [HexString length]; i += 2) {
        
        NSString *hex = [HexString substringWithRange:NSMakeRange(i, 2)];
        NSInteger decimalValue = 0;
        sscanf([hex UTF8String], "%x", &decimalValue);
        [string appendFormat:@"%c", decimalValue];
    }
    
    return string;
}

+ (NSString *)GetCurrentDate {

    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    NSString *datestr = [dateFormatter stringFromDate:date];
    
    NSRange range = [datestr rangeOfString:@"/"];
    
    if (range.location != NSNotFound) {
        
        datestr = [datestr stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    }
    
    return datestr;
}



+ (NSString *)GetCurrentDateSimple {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd-yyyy";
    
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)DateStringToNSDate:(NSString *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:date];
    
    return dateFromString;
}

+ (NSString *)NSDateToDateString:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
 
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)DateStringToDateString:(NSString *)date {
    
    return [Utilities NSDateToDateString:[Utilities DateStringToNSDate:date]];
}

+ (NSString *)NSDateToDateWithTimeString:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy HH_mm_ss"];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)NSDateToDateWithTime12HourString:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm a"];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)GetCurrentDateAndTime {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy HH_mm_ss"];
    NSDate *date = [NSDate date];
    
    return [dateFormat stringFromDate:date];
}

+ (NSString *)GetPDFDate:(NSString *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    NSString *datestr = [dateFormatter stringFromDate:[Utilities DateStringToNSDate:date]];
    
    return datestr;
}

+ (NSUInteger)DaysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;

    NSCalendar *calendar = [NSCalendar currentCalendar];

    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];

    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];

    return labs([difference day]);
}

+ (BOOL)HasNetworkConnectivity {

    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

+ (NSString *)CreateClientKey:(NSDictionary *)ClientInfo {
    
    NSString *FirstName = [ClientInfo objectForKey:@"First Name"];
    NSString *LastName = [ClientInfo objectForKey:@"Last Name"];
    NSString *Date = [ClientInfo objectForKey:@"Date"];
    
    return [NSString stringWithFormat:@"%@-%@-%@",Date,LastName,FirstName];
}

+ (void)CreateDirectory:(NSString *)Path {
    
    NSFileManager *FileManager = [[NSFileManager alloc] init];
    
    BOOL isDirectory = true;
    NSError *error = nil;
    
    if(![FileManager fileExistsAtPath:Path isDirectory:&isDirectory]) {
        
        [FileManager createDirectoryAtPath:Path
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&error];
    }
    

}

+ (NSString *)GetTempDirectory {
    
    NSString *tempDirectory = [[Utilities GetDocsDirectory] stringByAppendingPathComponent:@"Temp"];
    
    return tempDirectory;
}

+ (NSString *)GetDocsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    return documentsDirectory;
}

+ (NSString *)GetImgsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:@"Imgs"];
}

+ (NSString *)GetCountryName {
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *country = [usLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
    
    return country;
}

+ (NSInteger)CalcAgeFromDateOfBirth:(NSDate *)DateOfBirth
{
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:DateOfBirth
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    
    return age;
    
}

+ (NSString *)AppVersion {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    return infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)AppBuild {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    return infoDictionary[(NSString*)kCFBundleVersionKey];
}

+ (BOOL)IsANewInstall {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *DefaultsVer = [defaults objectForKey:VERSION_KEY];
    
    return (DefaultsVer == nil);
}

+ (BOOL)HasVersionChanged {
        
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *DefaultsVer = [defaults objectForKey:VERSION_KEY];
    
    if (DefaultsVer == nil) {
        DefaultsVer = @"";
    }
    
    NSString *DefaultsBuild = [defaults objectForKey:BUILD_KEY];
    
    if (DefaultsBuild == nil) {
        DefaultsBuild = @"";
    }
    
    return (![version isEqualToString:DefaultsVer] || ![build isEqualToString:DefaultsBuild]);
}

+ (BOOL)HasRegionChanged {
    
    NSString *Region = [Utilities GetCountryName];
    
    NSString *defaultsRegion = [[NSUserDefaults standardUserDefaults] objectForKey:REGION_KEY];
    
    if (defaultsRegion == nil) {
        defaultsRegion = @"";
    }
    
    return (![defaultsRegion isEqualToString:Region]);
}

+ (NSString *)GetCountryCode {
    
    NSString *Region = @"US";
    
    NSString *Country = [Utilities GetCountryName];
    
    if ([Country isEqualToString:REGION_UK]) {
        Region = @"UK";
    }
    else if ([Country isEqualToString:REGION_CAN]) {
        Region = @"CAN";
    }
    else if ([Country isEqualToString:REGION_AUS]) {
        Region = @"AUS";
    }
    else if ([Country isEqualToString:REGION_NZ]) {
        Region = @"NZ";
    }
    
    return Region;
}

+ (NSString *)GetCurrencyCode:(NSString *)CountryCode {

    NSString *currency = @"USD";  //default is US dollar

    NSString *Country = [Utilities GetCountryName];

    if ([Country isEqualToString:REGION_UK]) {
        currency = @"GBP";
    }
    else if ([Country isEqualToString:REGION_CAN]) {
        currency = @"CAD";
    }
    else if ([Country isEqualToString:REGION_AUS]) {
        currency = @"AUD";
    }
    else if ([Country isEqualToString:REGION_NZ]) {
        currency = @"NZD";
    }

    return currency;
}

+ (bool)validateEmailAddress:(NSString *)checkString
{
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (UIImage *)CreateDummyWhiteImg {
    
    UIImage *dummy = nil;
    
    //create dummy white image
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(10, 10), YES, 0.0);
    
    [[UIColor whiteColor] setFill];
    UIRectFill(CGRectMake(0, 0, 10, 10));
    dummy = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return dummy;
}

// Return the iCloud Data URL
+ (NSURL *) ubiquityDataURLForContainer:(NSString *) container
{
    return [[NSFileManager defaultManager]
            URLForUbiquityContainerIdentifier:container];
}

// Return the iCloud Documents/Imgs URL
+ (NSURL *) UbiquityImgsURLForContainer:(NSString *)container
{
    
    NSURL *docs = [[self ubiquityDataURLForContainer:container] URLByAppendingPathComponent:@"Documents"];
    
    return [docs URLByAppendingPathComponent:@"Imgs"];
        
    /*
    NSURL *docs = [[self ubiquityDataURLForContainer:container] URLByAppendingPathComponent:@"Imgs"];
    
    return docs;
    */
}

+ (bool)IsUsingUbiquityFolder {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *UsingUbiq = [defaults objectForKey:USING_UBIQUITOUS_FOLDER_KEY];
    
    return (UsingUbiq != nil && [UsingUbiq isEqualToString:@"Yes"]);
}

+ (bool)IsUsingDataSync {
    
    NSString *isUsingSync = [[NSUserDefaults standardUserDefaults] objectForKey:USING_DEVICE_SYNC_KEY];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];

    return (isUsingSync != nil && [isUsingSync isEqualToString:@"Yes"] && cloudURL != nil);
}

+ (bool)IsSearchingCloud {

    NSString *isSearchingCloud = [[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_CLOUD_KEY];
    bool searchingCloud = (isSearchingCloud != nil && [isSearchingCloud isEqualToString:@"Yes"]);

    return searchingCloud;
}

+ (NSString *)GetImagesPath {
    
    NSString *ImgsPath = nil;
    
    if ([self IsUsingUbiquityFolder]) {
        
        ImgsPath = [Utilities UbiquityImgsURLForContainer:nil].path;
        
    }
    else {
        
        ImgsPath = [NSString stringWithFormat:@"%@/Imgs", [Utilities GetDocsDirectory]];
    }
    
    return ImgsPath;
}

+ (bool)IsSyncMerging {
    
    NSString *isSyncMerging = [[NSUserDefaults standardUserDefaults] objectForKey:SYNC_MERGE_STATUS];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    
    return (isSyncMerging != nil && [isSyncMerging isEqualToString:@"Merging"] && cloudURL != nil);
}

+ (NSString *) GetSharedLocationPath:(NSString *)appGroupName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *groupContainerURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:appGroupName];
    return [groupContainerURL relativePath];
}

+ (NSUInteger)CalcNumDaysSinceDate:(NSDate *)StartDate {

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:StartDate
                                                          toDate:[NSDate date]
                                                         options:0];

    return [components day];
}

+ (unsigned long long) GetFileSize:(NSString *)PathAndFileName {

    NSError *attributesError = nil;

    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:PathAndFileName error:&attributesError];

    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];


    unsigned long long fileSize = 0;

    if (attributesError == nil) {

        fileSize = [fileSizeNumber longLongValue];
    }

    return fileSize;
}

@end



//
//  Utilities.h
//  LRF
//
//  Created by Francis Bowen on 6/18/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface Utilities : NSObject

+ (NSString *)StringToHex:(NSString *)str;
+ (NSString *)HexStringToString:(NSString *)HexString;
+ (NSString *)GetCurrentDate;
+ (NSString *)GetCurrentDateSimple;
+ (NSString *)GetCurrentDateAndTime;
+ (NSString *)GetPDFDate:(NSString *)date;
+ (NSDate *)DateStringToNSDate:(NSString *)date;
+ (NSString *)NSDateToDateString:(NSDate *)date;
+ (NSString *)NSDateToDateWithTimeString:(NSDate *)date;
+ (NSString *)NSDateToDateWithTime12HourString:(NSDate *)date;
+ (NSString *)DateStringToDateString:(NSString *)date;
+ (NSUInteger)DaysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (BOOL)HasNetworkConnectivity;
+ (NSString *)CreateClientKey:(NSDictionary *)ClientInfo;
+ (void)CreateDirectory:(NSString *)Path;
+ (NSString *)GetTempDirectory;
+ (NSString *)GetDocsDirectory;
+ (NSString *)GetImgsDirectory;
+ (NSString *)GetCountryName;
+ (NSString *)GetCountryCode;
+ (NSString *)GetCurrencyCode:(NSString *)CountryCode;
+ (NSInteger)CalcAgeFromDateOfBirth:(NSDate *)DateOfBirth;
+ (BOOL)HasVersionChanged;
+ (NSString *)AppVersion;
+ (NSString *)AppBuild;
+ (BOOL)HasRegionChanged;
+ (BOOL)IsANewInstall;
+ (bool)validateEmailAddress:(NSString *)checkString;
+ (UIImage *)CreateDummyWhiteImg;
+ (NSUInteger)CalcNumDaysSinceDate:(NSDate *)StartDate;

+ (NSURL *) UbiquityImgsURLForContainer:(NSString *)container;
+ (bool)IsUsingUbiquityFolder;
+ (NSString *)GetImagesPath;
+ (bool)IsUsingDataSync;
+ (bool)IsSyncMerging;

+ (bool)IsSearchingCloud;

+ (NSString *) GetSharedLocationPath:(NSString *)appGroupName;

+ (unsigned long long) GetFileSize:(NSString *)PathAndFileName;

@end

//
//  EmployeeListManager.h
//  VTD Library v2.0
//
//  Created by Francis Bowen on 9/28/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmployeeListManager : NSObject
{
    NSMutableArray *_EmployeeList;
    NSString *_EmployeeListPlistPath;
}

- (void)AddEmployeeToList:(NSString *)EmployeeName;
- (void)RemoveEmployeeFromList:(NSString *)EmployeeName;
- (NSArray *)GetEmployeeList;
- (NSUInteger)NumEmployees;
- (void)CommitEmployeeList;
- (NSString *)GetEmployeeListPlist;
- (void)RemoveAll;

@end

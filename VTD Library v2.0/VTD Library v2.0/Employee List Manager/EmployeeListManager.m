//
//  EmployeeListManager.m
//  VTD Library v2.0
//
//  Created by Francis Bowen on 9/28/15.
//  Copyright © 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "EmployeeListManager.h"

@implementation EmployeeListManager

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        NSArray *DocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *DocumentsDir = [DocumentPaths objectAtIndex:0];
        _EmployeeListPlistPath = [DocumentsDir stringByAppendingPathComponent:EMPLOYEELIST_PLST_NAME];
        
        _EmployeeList = [[NSMutableArray alloc] init];
        
        [self LoadArrayFromPList];
        
    }
    
    return self;
}

- (void)LoadArrayFromPList
{

    NSDictionary *Employees = [[NSDictionary alloc] initWithContentsOfFile:_EmployeeListPlistPath];
    
    [_EmployeeList removeAllObjects];
    
    for (int i = 0; i < [Employees count]; i++)
    {
        NSString *entry = [NSString stringWithFormat:@"Employee%d",i];
        NSString *employee = [Employees objectForKey:entry];
        
        [_EmployeeList addObject:employee];
        
    }
}

- (void)AddEmployeeToList:(NSString *)EmployeeName {
    
    [_EmployeeList addObject:EmployeeName];
}

- (void)RemoveEmployeeFromList:(NSString *)EmployeeName {
    
    NSUInteger index = [_EmployeeList indexOfObject:EmployeeName];
    
    if (index < [_EmployeeList count]) {
    
        [_EmployeeList removeObjectAtIndex:index];
    }
}

- (NSArray *)GetEmployeeList {
    
    return [_EmployeeList copy];
}

- (void)CommitEmployeeList {
    
    NSMutableDictionary *ListToCommit = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [_EmployeeList count]; i++) {
        
        NSString *name = [_EmployeeList objectAtIndex:i];
        NSString *key = [NSString stringWithFormat:@"Employee%d",i];
        
        [ListToCommit setObject:name forKey:key];
    }
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSError *Error;
    
    [filemgr removeItemAtPath:_EmployeeListPlistPath error:&Error];
    
    [ListToCommit writeToFile:_EmployeeListPlistPath atomically:NO];
}

- (NSString *)GetEmployeeListPlist {
    
    return _EmployeeListPlistPath;
}

- (NSUInteger)NumEmployees {
    
    return [_EmployeeList count];
}

- (void)RemoveAll {
    
    [_EmployeeList removeAllObjects];
}

@end

//
//  CoreDataManager.m
//  LRF
//
//  Created by Francis Bowen on 6/19/15.
//  Copyright (c) 2015 Voluta Tattoo Digital. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager

@synthesize datasource;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize dsyncdelegate;
@synthesize formloaddelegate;

- (id)initWithDatasource:(id<CoreDataManagerDatasource>)adatasource {
    
    self = [super init];
    
    if (self) {
        
        datasource = adatasource;
        
        _StoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"VTD.sqlite"];
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CoreDataBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *modelPath = [bundle pathForResource:@"VTDDataModel" ofType:@"momd"];
        _ModelURL = [NSURL fileURLWithPath:modelPath];
        
        _PersistentStack = [[PersistentStack alloc] initWithStoreURL:_StoreURL
                                                            modelURL:_ModelURL
                                                StoreCoordinatorName:[datasource GetICloudStoreContainer]
                                                      PStackDelegate:self];
    
        self.managedObjectContext = _PersistentStack.managedObjectContext;
        self.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
        
        _DataExporters = [[DataExporters alloc] init];
        _DataExporters.delegate = self;
        _DataExporters.managedObjectContext = self.managedObjectContext;
        
        _VTDCrypto = [[VTDCrypto alloc] init];
    }
    
    return self;
}

- (void)SaveClient:(NSDictionary *)ClientData {
    
    NSLog(@"Saving client in core data");
    
    @autoreleasepool {
        
        NSDictionary *ClientInfo = [ClientData objectForKey:@"Client Info"];
        NSDictionary *ClientImages = [ClientData objectForKey:@"Client Images"];
        NSDictionary *ClientSupportingDocuments = [ClientData objectForKey:@"Supporting Documents"];
        NSDictionary *ClientSupprotingDocumentsImages = [ClientData objectForKey:@"Supporting Documents Images"];
        NSDictionary *SessionFinancials = [ClientData objectForKey:@"Session Financials"];
        NSDictionary *SpecialistInformation = [ClientData objectForKey:@"Specialist Information"];
        NSDictionary *ExtraData = [ClientData objectForKey:@"Extra Data"];
        
        NSString *firstname = [ClientInfo objectForKey:@"First Name"];
        NSString *lastname = [ClientInfo objectForKey:@"Last Name"];
        NSString *formdate = [ClientInfo objectForKey:@"Date"];
        
        NSString *dataKey = [Utilities CreateClientKey:ClientInfo];
        
        bool FormExists = [self DoesFormExistWithFirstName:firstname withLastName:lastname withDate:formdate];

        if (FormExists) {
            
            NSLog(@"Form already exists, merging data");
            
            NSManagedObject *PreviouslySavedForm = [self GetClient:firstname
                                                      withLastName:lastname
                                                          withDate:formdate];
            
            [PreviouslySavedForm setValue:dataKey forKey:@"dataKey"];
            [PreviouslySavedForm setValue:ClientInfo forKey:@"clientInfo"];
            [PreviouslySavedForm setValue:formdate forKey:@"date"];
            [PreviouslySavedForm setValue:firstname forKey:@"firstName"];
            [PreviouslySavedForm setValue:lastname forKey:@"lastName"];
            [PreviouslySavedForm setValue:[ClientInfo objectForKey:@"Employee Name"] forKey:@"employeeName"];
            
            NSManagedObject *PreviouslySavedImages = [PreviouslySavedForm valueForKey:@"images"];
            [PreviouslySavedImages setValue:dataKey forKey:@"dataKey"];
            
            NSManagedObject *PreviouslySavedSupportingDocuments = [PreviouslySavedForm valueForKey:@"supportingdocuments"];
            NSMutableDictionary *documents = [PreviouslySavedSupportingDocuments valueForKey:@"supportingDocs"];
            NSMutableArray *sdocslist = [[documents objectForKey:@"Supporting Documents List"] mutableCopy];
            
            //Add supporting documents list from current save to previously saved supporting documents list
            
            for (NSDictionary *sdoc in [ClientSupportingDocuments objectForKey:@"Supporting Documents List"]) {
                
                bool found = NO;
                
                for (NSDictionary *sdocument in sdocslist) {
                    
                    if ([[sdoc objectForKey:@"DocumentName"] isEqualToString:[sdocument objectForKey:@"DocumentName"]]) {
                        
                        found = YES;
                    }
                    
                }
                         
                if (!found) {
                    
                    [sdocslist addObject:sdoc];
                }
                
            }
            
            [documents setObject:sdocslist forKey:@"Supporting Documents List"];
            
            NSManagedObject *PreviouslySavedSessionFinancials = [PreviouslySavedForm valueForKey:@"financials"];
            NSDateFormatter *dt = [[NSDateFormatter alloc] init];
            [dt setDateFormat:@"MM-dd-yyyy"];
            NSString *date = [dt stringFromDate:[NSDate date]];
            
            [PreviouslySavedSessionFinancials setValue:SessionFinancials forKey:@"financialData"];
            [PreviouslySavedSessionFinancials setValue:date forKey:@"date"];
            [PreviouslySavedSessionFinancials setValue:dataKey forKey:@"dataKey"];
            
            NSManagedObject *PreviouslySavedSpecialistInformation = [PreviouslySavedForm valueForKey:@"specialistinformation"];
            [PreviouslySavedSpecialistInformation setValue:SpecialistInformation forKey:@"specialistInformation"];
            [PreviouslySavedSpecialistInformation setValue:dataKey forKey:@"dataKey"];
            
            NSManagedObject *PreviouslySavedExtraData = [PreviouslySavedForm valueForKey:@"extradata"];
            [PreviouslySavedExtraData setValue:ExtraData forKey:@"extraData"];
            [PreviouslySavedExtraData setValue:dataKey forKey:@"dataKey"];
            
            //[_PersistentStack saveContext];
            NSError *saveError = nil;
            
            [_managedObjectContext save:&saveError];
            
            if (saveError) {
                NSLog(@"Error saving form that already exists: %@", saveError.localizedDescription);
            }
            
            [_managedObjectContext reset];
            
        }
        else {
            
            NSLog(@"Form does not alrady exist, creating a new object");
            
            // Create a new managed object
            NSManagedObject *info = [NSEntityDescription insertNewObjectForEntityForName:CLIENTINFO_ENTITY_NAME
                                                                  inManagedObjectContext:self.managedObjectContext];
            
            [info setValue:dataKey forKey:@"dataKey"];
            [info setValue:ClientInfo forKey:@"clientInfo"];
            [info setValue:[ClientInfo objectForKey:@"Date"] forKey:@"date"];
            [info setValue:[ClientInfo objectForKey:@"First Name"] forKey:@"firstName"];
            [info setValue:[ClientInfo objectForKey:@"Last Name"] forKey:@"lastName"];
            [info setValue:[ClientInfo objectForKey:@"Employee Name"] forKey:@"employeeName"];
            
            NSManagedObject *imgs = [NSEntityDescription insertNewObjectForEntityForName:CLIENTIMGS_ENTITY_NAME
                                                                  inManagedObjectContext:_managedObjectContext];
            
            //[imgs setValue:ClientImages forKey:@"clientImgs"];
            [imgs setValue:dataKey forKey:@"dataKey"];
            
            NSManagedObject *docs = [NSEntityDescription insertNewObjectForEntityForName:SUPPORTINGDOCUMENTS_ENTITY_NAME
                                                                  inManagedObjectContext:_managedObjectContext];
            
            [docs setValue:ClientSupportingDocuments forKey:@"supportingDocs"];
            [docs setValue:dataKey forKey:@"dataKey"];
            
            NSManagedObject *financials = [NSEntityDescription insertNewObjectForEntityForName:SESSIONFINANCIALS_ENTITY_NAME
                                                                        inManagedObjectContext:_managedObjectContext];
            
            NSDateFormatter *dt = [[NSDateFormatter alloc] init];
            [dt setDateFormat:@"MM-dd-yyyy"];
            NSString *date = [dt stringFromDate:[NSDate date]];
            
            [financials setValue:SessionFinancials forKey:@"financialData"];
            [financials setValue:date forKey:@"date"];
            [financials setValue:dataKey forKey:@"dataKey"];
            
            
            NSManagedObject *specialistinfo = [NSEntityDescription
                                               insertNewObjectForEntityForName:SPECIALISTINFO_ENTITY_NAME
                                               inManagedObjectContext:_managedObjectContext];
            
            [specialistinfo setValue:SpecialistInformation forKey:@"specialistInformation"];
            [specialistinfo setValue:dataKey forKey:@"dataKey"];
            
            NSManagedObject *extradata = [NSEntityDescription
                                          insertNewObjectForEntityForName:EXTRADATA_ENTITY_NAME
                                          inManagedObjectContext:_managedObjectContext];
            
            [extradata setValue:ExtraData forKey:@"extraData"];
            [extradata setValue:dataKey forKey:@"dataKey"];
            
            //Link relationships
            [info setValue:imgs forKey:@"images"];
            [info setValue:docs forKey:@"supportingdocuments"];
            [info setValue:financials forKey:@"financials"];
            [info setValue:specialistinfo forKey:@"specialistinformation"];
            [info setValue:extradata forKey:@"extradata"];
            
            [imgs setValue:info forKey:@"information"];
            [docs setValue:info forKey:@"information"];
            [financials setValue:info forKey:@"information"];
            [specialistinfo setValue:info forKey:@"information"];
            [extradata setValue:info forKey:@"information"];
            
            [_PersistentStack saveContext];
            [_managedObjectContext reset];
            
        }
        
        NSString *ImgsPath = [Utilities GetImagesPath];
        
        [self SaveLocalImages:ClientImages
           withSupportingDocs:ClientSupprotingDocumentsImages
                  withDataKey:dataKey
                  withDestDir:ImgsPath];
        
    }
    
}

- (void)SaveLocalImages:(NSDictionary *)ClientImgs
     withSupportingDocs:(NSDictionary *)SDocs
            withDataKey:(NSString *)DataKey
            withDestDir:(NSString *)DestDir {
    
    @autoreleasepool {

        NSString *datakeyhex = [Utilities StringToHex:DataKey];
        
        //client ID
        NSData *clientID = [ClientImgs objectForKey:CLIENT_ID_IMAGE];
        
        if (clientID) {
            
            NSString *fn = [NSString stringWithFormat:@"%@-CID",datakeyhex];
            
            [self WriteEncryptedFile:DestDir
                              withFN:fn
                            withData:clientID
                              withPW:DataKey];
        }
        
        clientID = nil;
        
        //client signature
        NSData *clientSig = [ClientImgs objectForKey:CLIENT_SIGNATURE_IMAGE];
        
        if (clientSig) {
            
            NSString *fn = [NSString stringWithFormat:@"%@-CSIG",datakeyhex];
            
            [self WriteEncryptedFile:DestDir
                              withFN:fn
                            withData:clientSig
                              withPW:DataKey];
        }
        
        clientSig = nil;
        
        //employee signature
        NSData *employeeSig = [ClientImgs objectForKey:EMPLOYEE_SIGNATURE_IMAGE];
        
        if (employeeSig) {
            
            NSString *fn = [NSString stringWithFormat:@"%@-ESIG",datakeyhex];
            
            [self WriteEncryptedFile:DestDir
                              withFN:fn
                            withData:employeeSig
                              withPW:DataKey];
        }
        
        employeeSig = nil;
        
        //Save supporting documents images
        //Format: datahexkey-documenttype
        NSArray *sdoctypes = [SDocs allKeys];
        
        for (NSString *doctype in sdoctypes) {
            
            NSString *doctypehex = [Utilities StringToHex:doctype];
            NSString *fn = [NSString stringWithFormat:@"%@-%@",datakeyhex,doctypehex];

            UIImage *test = [UIImage imageWithData:UIImagePNGRepresentation([SDocs objectForKey:doctype])];
            
            [self WriteEncryptedFile:DestDir
                              withFN:fn
                            withData:UIImagePNGRepresentation([SDocs objectForKey:doctype])
                              withPW:DataKey];
            
        }
        
    }//End of autoreleasepool
    
}

- (void)SaveClientMO:(NSManagedObject *)ManagedObj
           toContext:(PersistentStack *)pstack
      withImagesDest:(NSString *)ImgsDir {
    
    @autoreleasepool {
        
        NSManagedObjectContext *context = pstack.managedObjectContext;
        
        // Create a new managed object
        NSManagedObject *info = [NSEntityDescription insertNewObjectForEntityForName:CLIENTINFO_ENTITY_NAME
                                                              inManagedObjectContext:context];
        
        [info setValue:[ManagedObj valueForKey:@"dataKey"] forKey:@"dataKey"];
        [info setValue:[ManagedObj valueForKey:@"clientInfo"] forKey:@"clientInfo"];
        [info setValue:[ManagedObj valueForKey:@"date"] forKey:@"date"];
        [info setValue:[ManagedObj valueForKey:@"firstName"] forKey:@"firstName"];
        [info setValue:[ManagedObj valueForKey:@"lastName"] forKey:@"lastName"];
        [info setValue:[ManagedObj valueForKey:@"employeeName"] forKey:@"employeeName"];
        
        NSManagedObject *imgs = [NSEntityDescription insertNewObjectForEntityForName:CLIENTIMGS_ENTITY_NAME
                                                              inManagedObjectContext:context];
        
        NSManagedObject *imgsObj = [ManagedObj valueForKey:@"images"];
        
        [imgs setValue:nil forKey:@"clientImgs"];
        [imgs setValue:[ManagedObj valueForKey:@"dataKey"] forKey:@"dataKey"];

        // *** Strip out images into Imgs folder if they exist ***
        NSDictionary *clientimgs = [imgsObj valueForKey:@"clientImgs"];
        
        if (clientimgs) {
            
            NSString *datakey = [ManagedObj valueForKey:@"dataKey"];
            NSString *datakeyhex = [Utilities StringToHex:datakey];
            
            //client ID
            NSData *clientID = [clientimgs objectForKey:CLIENT_ID_IMAGE];
            
            if (clientID) {
                
                NSString *fn = [NSString stringWithFormat:@"%@-CID",datakeyhex];
                
                [self WriteEncryptedFile:ImgsDir
                                  withFN:fn
                                withData:clientID
                                  withPW:datakey];
            }
            
            clientID = nil;
            
            //client signature
            NSData *clientSig = [clientimgs objectForKey:CLIENT_SIGNATURE_IMAGE];
            
            if (clientSig) {
                
                NSString *fn = [NSString stringWithFormat:@"%@-CSIG",datakeyhex];
                
                [self WriteEncryptedFile:ImgsDir
                                  withFN:fn
                                withData:clientSig
                                  withPW:datakey];
            }
            
            clientSig = nil;
            
            //employee signature
            NSData *employeeSig = [clientimgs objectForKey:EMPLOYEE_SIGNATURE_IMAGE];
            
            if (employeeSig) {
                
                NSString *fn = [NSString stringWithFormat:@"%@-ESIG",datakeyhex];
                
                [self WriteEncryptedFile:ImgsDir
                                  withFN:fn
                                withData:employeeSig
                                  withPW:datakey];
            }
            
            employeeSig = nil;

            
        }
        
        NSManagedObject *docsObj = [ManagedObj valueForKey:@"supportingdocuments"];
        NSDictionary *supportingDocs = [docsObj valueForKey:@"supportingDocs"];
        
        NSManagedObject *docs = [NSEntityDescription insertNewObjectForEntityForName:SUPPORTINGDOCUMENTS_ENTITY_NAME inManagedObjectContext:context];
        [docs setValue:supportingDocs forKey:@"supportingDocs"];
        [docs setValue:[ManagedObj valueForKey:@"dataKey"] forKey:@"dataKey"];
        
        NSManagedObject *financials = [NSEntityDescription insertNewObjectForEntityForName:SESSIONFINANCIALS_ENTITY_NAME
                                                                    inManagedObjectContext:context];
        
        NSManagedObject *financialsObj = [ManagedObj valueForKey:@"financials"];
        
        [financials setValue:[financialsObj valueForKey:@"financialData"] forKey:@"financialData"];
        [financials setValue:[financialsObj valueForKey:@"date"] forKey:@"date"];
        [financials setValue:[ManagedObj valueForKey:@"dataKey"] forKey:@"dataKey"];
        
        
        NSManagedObject *specialistinfo = [NSEntityDescription
                                           insertNewObjectForEntityForName:SPECIALISTINFO_ENTITY_NAME
                                           inManagedObjectContext:context];
        
        NSManagedObject *specialistObj = [ManagedObj valueForKey:@"specialistinformation"];
        
        [specialistinfo setValue:[specialistObj valueForKey:@"specialistInformation"] forKey:@"specialistInformation"];
        [specialistinfo setValue:[ManagedObj valueForKey:@"dataKey"] forKey:@"dataKey"];
        
        NSManagedObject *extradata = [NSEntityDescription
                                      insertNewObjectForEntityForName:EXTRADATA_ENTITY_NAME
                                      inManagedObjectContext:context];
        
        NSManagedObject *extraObj = [ManagedObj valueForKey:@"extradata"];
        
        [extradata setValue:[extraObj valueForKey:@"extraData"] forKey:@"extraData"];
        [extradata setValue:[ManagedObj valueForKey:@"dataKey"] forKey:@"dataKey"];
        
        //Link relationships
        [info setValue:imgs forKey:@"images"];
        [info setValue:docs forKey:@"supportingdocuments"];
        [info setValue:financials forKey:@"financials"];
        [info setValue:specialistinfo forKey:@"specialistinformation"];
        [info setValue:extradata forKey:@"extradata"];
        
        [imgs setValue:info forKey:@"information"];
        [docs setValue:info forKey:@"information"];
        [financials setValue:info forKey:@"information"];
        [specialistinfo setValue:info forKey:@"information"];
        [extradata setValue:info forKey:@"information"];
        
        @synchronized(context) {
            
            [pstack saveContext];
            
            [context refreshObject:info mergeChanges:NO];
            
            [context reset];

        }
        

    }
    
}


- (NSArray *)SearchForClient:(NSString *)TextToSearch {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CLIENTINFO_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    if (![TextToSearch isEqualToString:@"*.*"]) {
        
        NSArray *names = [TextToSearch componentsSeparatedByString:@" "];
        
        NSPredicate *predicate = nil;
        
        if ([names count] > 1) {
            
            //Search for first and last name - assumed <first> <last>
            
            predicate = [NSPredicate
                         predicateWithFormat:@"(firstName contains[c] %@) AND (lastName contains[c] %@)",
                         [names objectAtIndex:0],[names objectAtIndex:1]];
            
        }
        else {
         
            predicate = [NSPredicate
                         predicateWithFormat:@"(firstName contains[c] %@) OR (lastName contains[c] %@)",
                         TextToSearch,TextToSearch];
        }
        
        
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSMutableArray *Results = nil;
    
    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        
        Results = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [SearchResults count]; i++) {
            
            NSManagedObject *CurrentObject = [SearchResults objectAtIndex:i];
            
            NSString *FirstName = [CurrentObject valueForKey:@"firstName"];
            NSString *LastName = [CurrentObject valueForKey:@"lastName"];
            NSString *Date = [CurrentObject valueForKey:@"date"];
            
            if (FirstName != nil && LastName != nil && Date != nil) {
                
                NSString *Result = [NSString stringWithFormat:@"%@ %@, %@",
                                    Date,
                                    LastName,
                                    FirstName];
                
                NSMutableDictionary *ResultEntry = [[NSMutableDictionary alloc] init];
                [ResultEntry setObject:FirstName forKey:@"First Name"];
                [ResultEntry setObject:LastName forKey:@"Last Name"];
                [ResultEntry setObject:Date forKey:@"Date"];
                [ResultEntry setObject:Result forKey:@"Search Result"];
                
                [Results addObject:ResultEntry];
            }

        }
        
        //NSLog(@"%@", Results);
        
        //clear memory
        [_managedObjectContext reset];
    }
    
    return [Results copy];
}

- (NSArray *)SearchForFormsWithFirstName:(NSString *)FirstName
                            withLastName:(NSString *)LastName
                                withDate:(NSString *)Date {
 
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CLIENTINFO_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(firstName == %@) AND (lastName == %@) AND (date == %@)",
                              FirstName, LastName, Date];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;

    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        
        NSLog(@"Unable to execute fetch request in SearchForFormsWithFirstName:");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
        return nil;
        
    }
    
    return SearchResults;
}

- (NSManagedObject *)GetClient:(NSString *)FirstName
                  withLastName:(NSString *)LastName
                      withDate:(NSString *)Date {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CLIENTINFO_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(firstName == %@) AND (lastName == %@) AND (date == %@)",
                              FirstName, LastName, Date];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSManagedObject *FormData = nil;

    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        
        if (SearchResults != nil && [SearchResults count] > 0) {
            
            FormData = [SearchResults objectAtIndex:0];
        }
    }
    
    return FormData;
}

- (NSManagedObject *)GetClientFrom:(NSManagedObjectContext *)context
                     withFirstName:(NSString *)FirstName
                      withLastName:(NSString *)LastName
                          withDate:(NSString *)Date {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CLIENTINFO_ENTITY_NAME
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(firstName == %@) AND (lastName == %@) AND (date == %@)",
                              FirstName, LastName, Date];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSManagedObject *FormData = nil;
    
    NSArray *SearchResults = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        
        if (SearchResults != nil && [SearchResults count] > 0) {
            
            FormData = [SearchResults objectAtIndex:0];
        }
    }
    
    return FormData;
}

- (void)RemoveForms:(NSArray *)Indices {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CLIENTINFO_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    
    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
    
        for (int i = 0; i < [Indices count]; i++) {
            
            NSNumber *index = [Indices objectAtIndex:i];
            int intIndex = [index intValue];
            
            if (intIndex < [SearchResults count]) {
                
                NSManagedObject *objectToDelete = [SearchResults objectAtIndex:intIndex];
                [_managedObjectContext deleteObject:objectToDelete];
            }
            
        }
        
        [_PersistentStack saveContext];
        
        [_managedObjectContext reset];
    }
}

- (NSUInteger)RemoveDuplicates {
    
    NSUInteger numRemoved = 0;
    
    NSMutableArray *clientlist = [[self FindForms:@"*.*"] mutableCopy];
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"Search Result" ascending:YES];
    [clientlist sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
    
    bool duplicatesRemoved = NO;
    
    for (NSMutableDictionary *client in clientlist) {
    
        NSString *firstname = [client objectForKey:@"First Name"];
        NSString *lastname = [client objectForKey:@"Last Name"];
        NSString *date = [client objectForKey:@"Date"];
        
        NSArray *foundclients = [self SearchForFormsWithFirstName:firstname
                                                     withLastName:lastname
                                                         withDate:date];
        
        if ([foundclients count] > 1) {
            
            duplicatesRemoved = YES;
            
            NSMutableArray *ObjsToDel = [[NSMutableArray alloc] init];
            
            NSManagedObject *currentobj = [foundclients objectAtIndex:0];
            
            for (int i = 1; i < [foundclients count]; i++) {
            
                if ([self CurrentFormIsLarger:currentobj withNextObject:[foundclients objectAtIndex:i]]) {
                    
                    [ObjsToDel addObject:[foundclients objectAtIndex:i]];
                }
                else {
                    
                    [ObjsToDel addObject:currentobj];
                    currentobj = [foundclients objectAtIndex:i];
                }
                
            }
            
            NSLog(@"Removing %d duplicates for %@-%@, %@", [ObjsToDel count], date, lastname, firstname);
            
            numRemoved += [ObjsToDel count];
            
            for (NSManagedObject *objtodel in ObjsToDel) {
                
                [_managedObjectContext deleteObject:objtodel];
            }
        }
    }
    
    
    if (duplicatesRemoved) {
        
        [_PersistentStack saveContext];
        [_managedObjectContext reset];
    }
    
    return numRemoved;
}

- (bool)CurrentFormIsLarger:(NSManagedObject *)CurrentObj withNextObject:(NSManagedObject *)NextObj {
    
    NSUInteger currentSize = 0;
    
    NSMutableDictionary *currentClientInfo = [CurrentObj valueForKey:@"clientInfo"];
    currentSize += [self DictSize:currentClientInfo];
    
    NSManagedObject *currentSpecialistInformationObj = [CurrentObj valueForKey:@"specialistinformation"];
    NSMutableDictionary *currentSpecialistInfo = [currentSpecialistInformationObj valueForKey:@"specialistInformation"];
    currentSize += [self DictSize:currentSpecialistInfo];
    
    NSManagedObject *currentSupportingDocumentsObj = [CurrentObj valueForKey:@"supportingdocuments"];
    NSMutableDictionary *currentDocuments = [currentSupportingDocumentsObj valueForKey:@"supportingDocs"];
    currentSize += [self DictSize:currentDocuments];
    
    NSManagedObject *currentSessionFinancialsObj = [CurrentObj valueForKey:@"financials"];
    NSMutableDictionary *currentSessionFinancials = [currentSessionFinancialsObj valueForKey:@"financialData"];
    currentSize += [self DictSize:currentSessionFinancials];
    
    NSManagedObject *currentExtraDataObj = [CurrentObj valueForKey:@"extradata"];
    NSMutableDictionary *currentExtraData = [currentExtraDataObj valueForKey:@"extraData"];
    currentSize += [self DictSize:currentExtraData];
    
    NSUInteger nextSize = 0;
    
    NSMutableDictionary *nextClientInfo = [NextObj valueForKey:@"clientInfo"];
    nextSize += [self DictSize:nextClientInfo];
    
    NSManagedObject *nextSpecialistInformationObj = [NextObj valueForKey:@"specialistinformation"];
    NSMutableDictionary *nextSpecialistInfo = [nextSpecialistInformationObj valueForKey:@"specialistInformation"];
    nextSize += [self DictSize:nextSpecialistInfo];
    
    NSManagedObject *nextSupportingDocumentsObj = [NextObj valueForKey:@"supportingdocuments"];
    NSMutableDictionary *nextDocuments = [nextSupportingDocumentsObj valueForKey:@"supportingDocs"];
    nextSize += [self DictSize:nextDocuments];
    
    NSManagedObject *nextSessionFinancialsObj = [NextObj valueForKey:@"financials"];
    NSMutableDictionary *nextSessionFinancials = [nextSessionFinancialsObj valueForKey:@"financialData"];
    nextSize += [self DictSize:nextSessionFinancials];
    
    NSManagedObject *nextExtraDataObj = [NextObj valueForKey:@"extradata"];
    NSMutableDictionary *nextExtraData = [nextExtraDataObj valueForKey:@"extraData"];
    nextSize += [self DictSize:nextExtraData];
    
    return (currentSize >= nextSize);
}

- (NSUInteger)DictSize:(NSMutableDictionary *)dict {
    
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    
    return [data length];
}

#pragma mark - Pending Uploads
- (void)AddPendingUpload:(NSString *)FirstName
            withLastName:(NSString *)LastName
                withDate:(NSString *)Date
                 withDoB:(NSString *)DateOfBirth {
    
    // Create a new managed object
    NSManagedObject *pendingupload = [NSEntityDescription insertNewObjectForEntityForName:PENDINGUPLOADS_ENTITY_NAME
                                                                   inManagedObjectContext:self.managedObjectContext];
    
    [pendingupload setValue:FirstName forKey:@"firstName"];
    [pendingupload setValue:LastName forKey:@"lastName"];
    [pendingupload setValue:[Utilities DateStringToNSDate:Date] forKey:@"date"];
    [pendingupload setValue:DateOfBirth forKey:@"dateOfBirth"];
    [pendingupload setValue:[[NSMutableDictionary alloc] init] forKey:@"clientData"];
    
    [_PersistentStack saveContext];
    
    [_managedObjectContext reset];
}

- (NSUInteger)NumPendingUploads {
 
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:PENDINGUPLOADS_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    long numpending = [SearchResults count];
    
    if (numpending < 0) {
        numpending = 0;
    }
    
    [_managedObjectContext reset];
    
    return numpending;
}

- (void)RemovePendingUpload:(NSString *)FirstName
               withLastName:(NSString *)LastName
                   withDate:(NSString *)Date
                    withDoB:(NSString *)DateOfBirth {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:PENDINGUPLOADS_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(firstName == %@) AND (lastName == %@) AND (date == %@) AND (dateOfBirth == %@)",
                              FirstName, LastName, [Utilities DateStringToNSDate:Date], DateOfBirth];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        
        NSLog(@"Unable to execute fetch request for pending upload delete.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        
        for (NSManagedObject *pending in SearchResults) {
            
            [_managedObjectContext deleteObject:pending];
        }
        
        [_PersistentStack saveContext];
    }

}

- (NSArray *)GetListofPendingUploads {
    
    NSMutableArray *pendinguploads = [[NSMutableArray alloc] init];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:PENDINGUPLOADS_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    
    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        
        for (int i = 0; i < [SearchResults count]; i++) {
            
            NSManagedObject *CurrentObject = [SearchResults objectAtIndex:i];
            
            NSString *FirstName = [CurrentObject valueForKey:@"firstName"];
            NSString *LastName = [CurrentObject valueForKey:@"lastName"];
            NSString *Date = [Utilities NSDateToDateString:[CurrentObject valueForKey:@"date"]];
            NSString *DateOfBirth = [CurrentObject valueForKey:@"dateOfBirth"];
            
            if (FirstName != nil &&
                LastName != nil &&
                Date != nil &&
                DateOfBirth != nil) {
                
                NSMutableDictionary *ResultEntry = [[NSMutableDictionary alloc] init];
                [ResultEntry setObject:FirstName forKey:@"First Name"];
                [ResultEntry setObject:LastName forKey:@"Last Name"];
                [ResultEntry setObject:Date forKey:@"Date"];
                [ResultEntry setObject:DateOfBirth forKey:@"Date of Birth"];
                
                [pendinguploads addObject:ResultEntry];
            }
            else {
                
                if (FirstName == nil) {
                    NSLog(@"GetListOfPendingUploads failed to recall first name");
                }
                
                if (LastName == nil) {
                    NSLog(@"GetListOfPendingUploads failed to recall last name");
                }
                
                if (Date == nil) {
                    NSLog(@"GetListOfPendingUploads failed to recall date");
                }
                
                if (DateOfBirth == nil) {
                    NSLog(@"GetListOfPendingUploads failed to recall date of birth");
                }
                
            }
        }
        
        if ([pendinguploads count] > 0) {
            
            NSLog(@"Pending uploads:\n %@", pendinguploads);
        }
        
        
    }

    return [pendinguploads copy];
}

#pragma mark - Save For Later
- (void)AddSaveForLater:(NSString *)FirstName
           withLastName:(NSString *)LastName
               withDate:(NSString *)Date
                withDoB:(NSString *)DateOfBirth {

    // Create a new managed object
    NSManagedObject *saveforlater = [NSEntityDescription insertNewObjectForEntityForName:SAVEFORLATER_ENTITY_NAME
                                                                  inManagedObjectContext:self.managedObjectContext];

    [saveforlater setValue:FirstName forKey:@"firstName"];
    [saveforlater setValue:LastName forKey:@"lastName"];
    [saveforlater setValue:[Utilities DateStringToNSDate:Date] forKey:@"date"];
    [saveforlater setValue:DateOfBirth forKey:@"dateOfBirth"];
    [saveforlater setValue:[[NSMutableDictionary alloc] init] forKey:@"clientData"];

    [_PersistentStack saveContext];

    [_managedObjectContext reset];
}

- (NSUInteger)NumSaveForLater {

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:SAVEFORLATER_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

    long numpending = [SearchResults count];

    if (numpending < 0) {
        numpending = 0;
    }

    [_managedObjectContext reset];

    return numpending;
}

- (void)RemoveSaveForLater:(NSString *)FirstName
              withLastName:(NSString *)LastName
                  withDate:(NSString *)Date
                   withDoB:(NSString *)DateOfBirth {

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:SAVEFORLATER_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(firstName == %@) AND (lastName == %@) AND (date == %@) AND (dateOfBirth == %@)",
                              FirstName, LastName, [Utilities DateStringToNSDate:Date], DateOfBirth];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;

    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (SearchResults) {

        if (error) {

            NSLog(@"Unable to execute fetch request for save for later delete.");
            NSLog(@"%@, %@", error, error.localizedDescription);

        } else {

            for (NSManagedObject *savedforlater in SearchResults) {

                [_managedObjectContext deleteObject:savedforlater];
            }

            [_PersistentStack saveContext];
        }
    }

}

- (NSArray *)GetListofSaveForLater {

    NSMutableArray *saveforlater = [[NSMutableArray alloc] init];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:SAVEFORLATER_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error = nil;

    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (error) {

        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);

    } else {

        for (int i = 0; i < [SearchResults count]; i++) {

            NSManagedObject *CurrentObject = [SearchResults objectAtIndex:i];

            NSString *FirstName = [CurrentObject valueForKey:@"firstName"];
            NSString *LastName = [CurrentObject valueForKey:@"lastName"];
            NSString *Date = [Utilities NSDateToDateString:[CurrentObject valueForKey:@"date"]];
            NSString *DateOfBirth = [CurrentObject valueForKey:@"dateOfBirth"];

            if (FirstName != nil &&
                LastName != nil &&
                Date != nil &&
                DateOfBirth != nil) {

                NSString *Result = [NSString stringWithFormat:@"%@ %@, %@",
                                    [Utilities GetPDFDate:Date],
                                    LastName,
                                    FirstName];

                NSMutableDictionary *ResultEntry = [[NSMutableDictionary alloc] init];
                [ResultEntry setObject:FirstName forKey:@"First Name"];
                [ResultEntry setObject:LastName forKey:@"Last Name"];
                [ResultEntry setObject:Date forKey:@"Date"];
                [ResultEntry setObject:DateOfBirth forKey:@"Date of Birth"];
                [ResultEntry setObject:Result forKey:@"Search Result"];

                [saveforlater addObject:ResultEntry];
            }
            else {

                if (FirstName == nil) {
                    NSLog(@"GetListOfSaveForLater failed to recall first name");
                }

                if (LastName == nil) {
                    NSLog(@"GetListOfSaveForLater failed to recall last name");
                }

                if (Date == nil) {
                    NSLog(@"GetListOfSaveForLater failed to recall date");
                }

                if (DateOfBirth == nil) {
                    NSLog(@"GetListOfSaveForLater failed to recall date of birth");
                }

            }
        }

        if ([saveforlater count] > 0) {

            NSLog(@"Save for later list:\n %@", saveforlater);
        }


    }

    return [saveforlater copy];
}

- (NSArray *)GetSearchableSaveForLater {

    NSMutableArray *sfl = [[NSMutableArray alloc] init];

    if ([self NumSaveForLater] > 0) {

        NSArray *saveforlater = [self GetListofSaveForLater];

        for (NSMutableDictionary *entry in saveforlater) {

            NSString *firstname = [entry objectForKey:@"First Name"];
            NSString *lastname = [entry objectForKey:@"Last Name"];
            NSString *searchstr = [NSString stringWithFormat:@"%@ %@",firstname,lastname];

            [sfl addObject:searchstr];
        }



    }

    return [sfl copy];
}

- (NSArray *)GetSearchResults:(NSArray *)searchableresults {

    NSMutableArray *searchresults = [[NSMutableArray alloc] init];

    for (NSString *searchableresult in searchableresults) {

        NSArray *components = [searchableresult componentsSeparatedByString:@" "];

        NSString *firstname = [components objectAtIndex:0];
        NSString *lastname = [components objectAtIndex:1];

        NSArray *saveforlater = [self GetListofSaveForLater];

        for (NSMutableDictionary *entry in saveforlater) {

            if (([firstname isEqualToString:[entry objectForKey:@"First Name"]]) &&
                ([lastname isEqualToString:[entry objectForKey:@"Last Name"]])){

                [searchresults addObject:entry];

            }
        }

    }

    return searchresults;
}

#pragma mark - Data Exports
- (NSString *)ExportClientList:(NSString *)AppName {

    return [_DataExporters ExportClientList:AppName];
}

- (NSString *)ExportAllFinancial:(NSString *)AppName {

    return [_DataExporters ExportAllFinancial:AppName];
}

- (NSString *)ExportDateRangeFinancial:(NSString *)AppName
                         withStartDate:(NSDate *)StartDate
                           withEndDate:(NSDate *)EndDate {

    return [_DataExporters ExportDateRangeFinancial:AppName
                                      withStartDate:StartDate
                                        withEndDate:EndDate];
}

- (NSString *)ExportDateRangeAndEmployeeFinancial:(NSString *)AppName
                                    withStartDate:(NSDate *)StartDate
                                      withEndDate:(NSDate *)EndDate
                                 withEmployeeName:(NSString *)EmployeeName {
    
    return [_DataExporters ExportDateRangeAndEmployeeFinancial:AppName
                                                 withStartDate:StartDate
                                                   withEndDate:EndDate
                                              withEmployeeName:EmployeeName];
}

- (NSString *)ExportEmployeeFinancials:(NSString *)AppName
                      withEmployeeName:(NSString *)EmployeeName {
    
    return [_DataExporters ExportEmployeeFinancials:AppName withEmployeeName:EmployeeName];
}

- (NSString *)CreateBackup {
    
    // Convert the string into a date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy_HH_mm_ss"];
    NSDate *date = [NSDate date];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    NSString *backupStoreFilename = [NSString stringWithFormat:@"Temp/%@_%@.sqlite", [datasource GetAppID], dateString];
    NSString *backupArchiveFilename = [NSString stringWithFormat:@"Temp/%@_%@.%@", [datasource GetAppID], dateString, BACKUP_EXTENSION];
    
    NSURL *backupPathURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:backupStoreFilename];
    
    //[_PersistentStack BackupStore:backupPathURL];
    
    NSString *TempImgsDir = [NSString stringWithFormat:@"%@/Imgs",[Utilities GetTempDirectory]];
    
    [Utilities CreateDirectory:TempImgsDir];
    
    @autoreleasepool {
        
        PersistentStack *BackupPersistentStack = [[PersistentStack alloc]
                                                  initWithStoreURL:backupPathURL
                                                  modelURL:_ModelURL
                                                  StoreCoordinatorName:@"BACKUP-STORE"
                                                  PStackDelegate:self];

        NSManagedObjectContext *BackupMOC = BackupPersistentStack.managedObjectContext;
        NSPersistentStoreCoordinator *BackupPSC = BackupMOC.persistentStoreCoordinator;
        
        //Get client list from current main store
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:CLIENTINFO_ENTITY_NAME
                                                  inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error;
        NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            
            NSLog(@"Error: CreateBackup, searching for clients");

        }
        else {
            
            NSLog(@"Creating list of clients to backup");
            
            //Create list of clients to copy over
            NSMutableArray *clientlist = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [SearchResults count]; i++) {
                
                NSManagedObject *CurrentObject = [SearchResults objectAtIndex:i];
                
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                
                NSString *FirstName = [CurrentObject valueForKey:@"firstName"];
                NSString *LastName = [CurrentObject valueForKey:@"lastName"];
                NSString *Date = [CurrentObject valueForKey:@"date"];
                
                if (FirstName != nil && LastName != nil && Date != nil) {
                    
                    [data setObject:FirstName forKey:@"firstName"];
                    [data setObject:LastName forKey:@"lastName"];
                    [data setObject:Date forKey:@"date"];
                    
                    [clientlist addObject:data];
                }
                
            }
            
            [_managedObjectContext reset];
            
            NSString *ImgsDir = [Utilities GetImagesPath];
            
            NSArray *ImgsDirContents = [[NSFileManager defaultManager]
                                        contentsOfDirectoryAtPath:ImgsDir
                                        error:nil];
        
            NSLog(@"Reading clients from context and storing into backup context");
            
            for (int i = 0; i < [clientlist count]; i++) {
                
                @autoreleasepool {
                    
                    //NSManagedObject *CurrentObject = [SearchResults objectAtIndex:i];
                    NSMutableDictionary *data = [clientlist objectAtIndex:i];
                    
                    NSString *FirstName = [data objectForKey:@"firstName"];
                    NSString *LastName = [data objectForKey:@"lastName"];
                    NSString *Date = [data objectForKey:@"date"];
                    
                    if (FirstName != nil && LastName != nil && Date != nil) {
                        
                        NSManagedObject *frm = [self GetClient:FirstName
                                                  withLastName:LastName
                                                      withDate:Date];
                        
                        
                        if (frm != nil) {
                            
                            //[_managedObjectContext insertObject:CurrentObject];
                            NSManagedObject *backupclient = [self GetClientFrom:_managedObjectContext
                                                                  withFirstName:FirstName
                                                                   withLastName:LastName
                                                                       withDate:Date];
                            
                            //save client into backup persistent stack
                            [self SaveClientMO:backupclient
                                     toContext:BackupPersistentStack
                                withImagesDest:TempImgsDir];
                            
                            if ([Utilities IsUsingDataSync]) {
                                
                                //Copy over client images
                                NSMutableDictionary *clientInfo = [backupclient valueForKey:@"clientInfo"];
                                NSString *datakey = [Utilities CreateClientKey:clientInfo];
                                NSString *datakeyhex = [Utilities StringToHex:datakey];
                                NSString *match = [NSString stringWithFormat:@"*%@*",datakeyhex];
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
                                NSArray *results = [ImgsDirContents filteredArrayUsingPredicate:predicate];
                                
                                for (NSString *filename in results) {
                                    
                                    NSRange extrange = [filename rangeOfString:@".icloud"];
                                    
                                    NSString *fn = filename;
                                    
                                    if (extrange.location != NSNotFound) {
                                        
                                        fn = [fn substringToIndex:extrange.location];
                                        fn = [fn substringFromIndex:1];
                                        
                                    }
                                    
                                    NSString *fullpathsource = [ImgsDir stringByAppendingPathComponent:fn];
                                    NSString *fullpathdest = [TempImgsDir stringByAppendingPathComponent:fn];
                                    
                                    NSData *sourceimg = [self ReadEncLocalImageData:fullpathsource];
                                    [sourceimg writeToFile:fullpathdest atomically:NO];
                                    
                                    
                                    
                                    
                                }//End of for loop
                                
                            }//End of if statement
                            
                        }
                        
                        [_managedObjectContext reset];
                        
                        [BackupMOC reset];
                        
                    }
                    

                }
                
                
            }
            
            //[BackupMOC reset];

        }
    }

    NSLog(@"Compressing images and backup context")
    
    NSMutableArray *filesToArchive = [[NSMutableArray alloc] initWithObjects:[backupPathURL path], nil];
    
    //Add images to backup file
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSError *error;
    NSMutableArray *imgs = nil;
    
    if ([Utilities IsUsingDataSync]) {
        
        imgs = [fm contentsOfDirectoryAtPath:TempImgsDir error:&error];
    }
    else {
        
        imgs = [fm contentsOfDirectoryAtPath:[Utilities GetImagesPath] error:&error];
    }
    
    if (error == nil) {
        
        for (int i = 0; i < [imgs count]; i++) {
            
            NSString *dir = [Utilities GetImagesPath];
            
            if ([Utilities IsUsingDataSync]) {
                
                dir = TempImgsDir;
            }
            
            NSString *imgfn = [NSString stringWithFormat:@"%@/%@",dir,[imgs objectAtIndex:i]];
            [imgs replaceObjectAtIndex:i withObject:imgfn];
        }
        
        [filesToArchive addObjectsFromArray:imgs];
    }
    
    if (!_VTDCompression) {
        _VTDCompression = [[CompressionUtil alloc] init];
    }

    NSURL *archiveURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:backupArchiveFilename];
    [_VTDCompression CompressFilesFromArrayList:[archiveURL path] withFileList:filesToArchive];
    
    NSLog(@"Removing backup context and images directory");
    
    //remove backup sqlite
    [fm removeItemAtURL:backupPathURL error:nil];
    [fm removeItemAtPath:TempImgsDir error:nil];
    
    NSLog(@"Encrypting backup");
    //Encrypt database
    if (!_VTDCrypto) {
        _VTDCrypto = [[VTDCrypto alloc] init];
    }
    
    return [_VTDCrypto EncryptFileAtPath:[archiveURL path] withPassword:@"r2y12a20l13s"];
}

- (void)RestoreBackupCoreData:(NSString *)BackupStore {
    
    //Decrypt database
    if (!_VTDCrypto) {
        _VTDCrypto = [[VTDCrypto alloc] init];
    }
    
    NSString *decryptedFileName = [_VTDCrypto DecryptFileAtPath:BackupStore withPassword:@"r2y12a20l13s"];
    
    //Uncompress database
    if (!_VTDCompression) {
        _VTDCompression = [[CompressionUtil alloc] init];
    }
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSString *decryptedFilePath = [decryptedFileName stringByDeletingLastPathComponent];
    NSString *imgsPath = [Utilities GetImagesPath];
    
    NSArray *filesInFolder = [fm contentsOfDirectoryAtPath:decryptedFilePath error:nil];
    
    //Clear out temp folder
    for (NSString *fileToDelete in filesInFolder) {
        
        if (![[fileToDelete pathExtension] isEqualToString:[decryptedFileName pathExtension]]) {
            
            NSString *filetodel = [NSString stringWithFormat:@"%@/%@",decryptedFilePath,fileToDelete];
            [fm removeItemAtPath:filetodel error:nil];
        }

    }
    
    [_VTDCompression ExtractFiles:decryptedFileName toPath:decryptedFilePath];
    
    NSString *backupSQLFilename = [NSString stringWithFormat:@"%@/%@.sqlite",
                                   decryptedFilePath,
                                   [[decryptedFileName lastPathComponent] stringByDeletingPathExtension]];
    
    //Get list of files after extracting archive
    filesInFolder = [fm contentsOfDirectoryAtPath:decryptedFilePath error:nil];
    
    //Move all files exccept for backupSQL to Imgs
    for (NSString *fileToMove in filesInFolder) {
        
        NSString *fnpath = [NSString stringWithFormat:@"%@/%@",decryptedFilePath,fileToMove];
        NSString *fnnewpath = [NSString stringWithFormat:@"%@/%@",imgsPath,fileToMove];
        
        if (![[fnpath pathExtension] isEqualToString:@"sqlite"] &&
            ![[fnpath pathExtension] isEqualToString:[decryptedFileName pathExtension]]) {
            
            NSError *error;
            
            [fm moveItemAtPath:fnpath toPath:fnnewpath error:&error];
            
            if (error != nil) {
                
                NSLog(@"Error moving file to Imgs folder: %@", error.localizedDescription);
            }
        }
    }
    
    NSURL *BackupStoreURL = [NSURL fileURLWithPath:backupSQLFilename isDirectory:NO];
    
    
    @autoreleasepool {
        
        PersistentStack *BackupPersistentStack = [[PersistentStack alloc] initWithStoreURL:BackupStoreURL
                                                                                  modelURL:_ModelURL
                                                                      StoreCoordinatorName:@"BACKUP-STORE" PStackDelegate:self];

        NSManagedObjectContext *BackupMOC = BackupPersistentStack.managedObjectContext;
        NSPersistentStoreCoordinator *BackupPSC = BackupMOC.persistentStoreCoordinator;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:CLIENTINFO_ENTITY_NAME
                                                  inManagedObjectContext:BackupMOC];
        [fetchRequest setEntity:entity];
        
        NSError *error;
        NSArray *SearchResults = [BackupMOC executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            

        }
        else {
            

            //Create list of clients to copy over
            NSMutableArray *clientlist = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [SearchResults count]; i++) {
                
                NSManagedObject *CurrentObject = [SearchResults objectAtIndex:i];
                
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                
                NSString *FirstName = [CurrentObject valueForKey:@"firstName"];
                NSString *LastName = [CurrentObject valueForKey:@"lastName"];
                NSString *Date = [CurrentObject valueForKey:@"date"];
                
                if (FirstName != nil && LastName != nil && Date != nil) {
                    
                    [data setObject:FirstName forKey:@"firstName"];
                    [data setObject:LastName forKey:@"lastName"];
                    [data setObject:Date forKey:@"date"];
                    
                    [clientlist addObject:data];
                }
                
            }
            
            [BackupMOC reset];
            
            NSString *ImgsDir = [Utilities GetImagesPath];
            
            NSArray *TempDirContents = [[NSFileManager defaultManager]
                                        contentsOfDirectoryAtPath:[Utilities GetTempDirectory]
                                        error:nil];
            
            for (int i = 0; i < [clientlist count]; i++) {
                
                @autoreleasepool {
                    
                    //NSManagedObject *CurrentObject = [SearchResults objectAtIndex:i];
                    NSMutableDictionary *data = [clientlist objectAtIndex:i];
                    
                    NSString *FirstName = [data objectForKey:@"firstName"];
                    NSString *LastName = [data objectForKey:@"lastName"];
                    NSString *Date = [data objectForKey:@"date"];
                    
                    if (FirstName != nil && LastName != nil && Date != nil) {
                        
                         NSManagedObject *frm = [self GetClient:FirstName
                         withLastName:LastName
                         withDate:Date];

                        
                        if (frm == nil) {
                            
                            //[_managedObjectContext insertObject:CurrentObject];
                            NSManagedObject *backupclient = [self GetClientFrom:BackupMOC
                                                                  withFirstName:FirstName
                                                                   withLastName:LastName
                                                                       withDate:Date];
                            
                            [self SaveClientMO:backupclient
                                     toContext:_PersistentStack
                                withImagesDest:[Utilities GetImagesPath]];
                            
                            //Copy over client images
                            NSMutableDictionary *clientInfo = [backupclient valueForKey:@"clientInfo"];
                            NSString *datakey = [Utilities CreateClientKey:clientInfo];
                            NSString *datakeyhex = [Utilities StringToHex:datakey];
                            NSString *match = [NSString stringWithFormat:@"%@*",datakeyhex];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
                            NSArray *results = [TempDirContents filteredArrayUsingPredicate:predicate];
                            
                            for (NSString *filename in results) {
                                
                                NSString *fullpathsource = [[Utilities GetTempDirectory] stringByAppendingPathComponent:filename];
                                NSString *fullpathdest = [ImgsDir stringByAppendingPathComponent:filename];
                                
                                [[NSFileManager defaultManager]
                                 copyItemAtPath:fullpathsource
                                 toPath:fullpathdest
                                 error:nil];
                            }
                        }
                        else {
                            
                            NSLog(@"Found duplicate when importing backup");
                        }
                        
                        [_managedObjectContext reset];
                        
                        [BackupMOC reset];
                        
                    }
                    

                }
                
                
            }
            
            //[BackupMOC reset];
            
        }
    }
    
    
    //clean up - delete files
    [fm removeItemAtURL:BackupStoreURL error:nil];
    [fm removeItemAtPath:decryptedFileName error:nil];
    
}

#pragma mark - Persistent Store data sync
- (void)SwitchToICloud {
    
    NSString *imagesextracted = [[NSUserDefaults standardUserDefaults] objectForKey:IMAGES_EXTRACTED_KEY];
    
    if (!imagesextracted) {
        return;
    }
    
    [_PersistentStack SwitchToICloud];

}
- (void)SwitchToLocal {
    
    //Change to local store
    [_PersistentStack SwitchToLocal];
    
}

- (void)ReloadStore {
    
    [_PersistentStack ReloadStore];
}

- (bool)IsUsingICloud {
    
    return [_PersistentStack IsUsingICloud];
}

#pragma mark - DataExportersDatasource
- (NSString *)GetClientInfoEntity {
    
    return CLIENTINFO_ENTITY_NAME;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.VolutaDigital.LRF" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - PersistentStackDelegate
- (void)iCloudInsertedObjects:(NSSet *)setOfObjects {
    
    int numDeleted = 0;
    
    for (NSManagedObjectID *objID in setOfObjects) {
        // do whatever you need to with the NSManagedObjectID
        // you can retrieve the object from with [moc objectWithID:objID]
        
        NSManagedObject *CurrentObject = [_managedObjectContext objectWithID:objID];
        
        if ([[CurrentObject entity].name isEqualToString:@"ClientInformation"]) {
            
            NSString *FirstName = [CurrentObject valueForKey:@"firstName"];
            NSString *LastName = [CurrentObject valueForKey:@"lastName"];
            NSString *Date = [CurrentObject valueForKey:@"date"];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:CLIENTINFO_ENTITY_NAME
                                                      inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            
            NSPredicate *predicate = [NSPredicate
                                      predicateWithFormat:@"(firstName == %@) AND (lastName == %@) AND (date == %@)",
                                      FirstName, LastName, Date];
            [fetchRequest setPredicate:predicate];
            
            NSError *error = nil;
            
            NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if (error) {
                
                NSLog(@"Unable to execute fetch request.");
                NSLog(@"%@, %@", error, error.localizedDescription);
                
            } else {
                
                if (SearchResults != nil && [SearchResults count] > 1) {
                    
                    //Delete duplicates
                    for (int i = 1; i < [SearchResults count]; i++) {
                        
                        NSManagedObject *duplicateObj = [SearchResults objectAtIndex:i];
                        
                        NSManagedObject *ExtraData = [duplicateObj valueForKey:@"extradata"];
                        NSManagedObject *Financials = [duplicateObj valueForKey:@"financials"];
                        NSManagedObject *Images = [duplicateObj valueForKey:@"images"];
                        NSManagedObject *SpecialistInformation = [duplicateObj valueForKey:@"specialistinformation"];
                        NSManagedObject *SupportingDocuments = [duplicateObj valueForKey:@"supportingdocuments"];
                        
                        [_managedObjectContext deleteObject:duplicateObj];
                        
                        [_managedObjectContext deleteObject:ExtraData];
                        [_managedObjectContext deleteObject:Financials];
                        [_managedObjectContext deleteObject:Images];
                        [_managedObjectContext deleteObject:SpecialistInformation];
                        [_managedObjectContext deleteObject:SupportingDocuments];
                        
                        numDeleted++;
                    }
                }
            }
        }

    }
    
    if (numDeleted > 0) {
        
        NSLog(@"Num duplicates deleted in iCloudInsertedObjects: %d",numDeleted);
        [_PersistentStack saveContext];
    }
}

- (NSString *)GetMainStoreName {
    
    NSString *storename = [NSString stringWithFormat:@"%@_MainStore", [datasource GetAppID]];
    
    return storename;
}

- (void)LeechComplete:(bool)Success withMsg:(NSString *)msg {
    
    if (Success) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:@"Yes" forKey:CDATA_IS_LEECHED_KEY];
        
        [dsyncdelegate ImageTransferStart:YES];
        
        [_PersistentStack TransferImgsToUbiquitous];
    }
    else {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:@"No" forKey:CDATA_IS_LEECHED_KEY];
        
        NSString *errormsg = [NSString stringWithFormat:@"Error enabling core data sync"];
        
        if (msg) {
            
            errormsg = [errormsg stringByAppendingFormat:@":\n\n%@",msg];
        }
        
        if (dsyncdelegate) {
            [dsyncdelegate SyncStatusUpdate:errormsg
                           withEnablingFlag:YES
                           withCompleteFlag:NO];
        }
        
    }
}

- (void)ImgTransferToUbiquitousComplete:(bool)Success {
    
     NSLog(@"Finished transferring to ubiquitous");
    
    [dsyncdelegate ImageTransferComplete:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"Yes" forKey:USING_UBIQUITOUS_FOLDER_KEY];
    
    if (dsyncdelegate) {
        [dsyncdelegate SyncStatusUpdate:@"Sync Enabled"
                       withEnablingFlag:YES
                       withCompleteFlag:YES];
    }
    
}

- (void)DeleechComplete:(bool)Success withMsg:(NSString *)msg {
    
    if (Success) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:@"No" forKey:CDATA_IS_LEECHED_KEY];
        
        [_PersistentStack TransferImgsFromUbiquitous];
    }
    else {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:@"Yes" forKey:CDATA_IS_LEECHED_KEY];
        
        NSString *errormsg = [NSString stringWithFormat:@"Error disabling core data sync"];
        
        if (msg) {
            
            errormsg = [errormsg stringByAppendingFormat:@":\n\n%@",msg];
        }
        
        if (dsyncdelegate) {
            [dsyncdelegate SyncStatusUpdate:errormsg
                           withEnablingFlag:NO
                           withCompleteFlag:NO];
        }
    }
}

- (void)ImgTransferFromUbiquitousComplete:(bool)Success {
    
    NSLog(@"Finished transferring from ubiquitous. Sync is now disabled");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"No" forKey:USING_UBIQUITOUS_FOLDER_KEY];
    
    if (dsyncdelegate) {
        [dsyncdelegate SyncStatusUpdate:@"Sync Disabled."
                       withEnablingFlag:NO
                       withCompleteFlag:YES];
    }
}

- (void)InitPSSync {
    
    [_PersistentStack InitSync];
}

- (void)ClearContext {
    
    [_managedObjectContext reset];
}

- (void)InvalidateManagedObject:(NSManagedObject *)MObj {
    
    [_managedObjectContext refreshObject:MObj mergeChanges:NO];
}

- (void)SyncCoreData {
    
    [_PersistentStack SyncCoreData];
}

//Form Utilities
- (void)InitSync {
    
    [self InitPSSync];
}

- (void)SaveForm:(FormDataManager *)FormData {
    
    @autoreleasepool {
        
        NSMutableDictionary *_FormData = [[FormData GetFormData] copy];
        NSMutableDictionary *_FormImages = [[FormData GetFormImages] copy];
        NSMutableArray *_SupportingDocuments = [[FormData GetSupportingDocuments] copy];
        if (_SupportingDocuments == nil) {
            _SupportingDocuments = [[NSMutableArray alloc] init];
        }
        
        NSMutableDictionary *sdocimages = [FormData GetIndexedSupportingDocumentsImages];
        if (sdocimages == nil) {
            sdocimages = [[NSMutableDictionary alloc] init];
        }
        
        NSMutableDictionary *_SessionFinancials = [[FormData GetSessionFinancials] copy];
        NSMutableDictionary *_SpecialistData = [[FormData GetSpecialistData] copy];
        
        NSMutableDictionary *_ExtraData = [[FormData GetExtraData] copy];
        if (_ExtraData == nil) {
            _ExtraData = [[NSMutableDictionary alloc] init];
        }
        
        NSMutableDictionary *ClientData = [[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *sdocs = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_SupportingDocuments, @"Supporting Documents List", nil];
        
        [ClientData setObject:_FormData forKey:@"Client Info"];
        [ClientData setObject:_FormImages forKey:@"Client Images"];
        [ClientData setObject:sdocs forKey:@"Supporting Documents"];
        [ClientData setObject:sdocimages forKey:@"Supporting Documents Images"];
        [ClientData setObject:_SessionFinancials forKey:@"Session Financials"];
        [ClientData setObject:_SpecialistData forKey:@"Specialist Information"];
        [ClientData setObject:_ExtraData forKey:@"Extra Data"];
        
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            [self SaveClient:ClientData];
        });
        */
        
        [self performSelectorOnMainThread:@selector(SaveClient:) withObject:ClientData waitUntilDone:YES];
        
        NSLog(@"Reading back client from core data");
        
        //Read back data and compare
        int count = 0;
        while(![self ReadBackAndCompare:ClientData
                           withFormData:_FormData
                         withFormImages:_FormImages
                     withSpecialistData:_SpecialistData
                     withSupportingDocs:_SupportingDocuments
                  withSessionFinancials:_SessionFinancials
                          withExtraData:_ExtraData] && count < 3) {
            
            NSLog(@"Data read back was not the same, trying to save again");
            
            //[self performSelectorOnMainThread:@selector(SaveClient:) withObject:ClientData waitUntilDone:YES];
            
            [self SaveClient:ClientData];
            
            count++;
        }
        
        [ClientData removeAllObjects];
        ClientData = nil;
        
        _FormData = nil;
        _FormImages = nil;
        _SpecialistData = nil;
        _SupportingDocuments = nil;
        _SessionFinancials = nil;
        _ExtraData = nil;
        
    }
    
    //[_CoreDataManager ClearContext];
    
}

- (bool)ReadBackAndCompare:(NSMutableDictionary *)ClientData
              withFormData:(NSMutableDictionary *)FormData
            withFormImages:(NSMutableDictionary *)FormImages
        withSpecialistData:(NSMutableDictionary *)SpecialistData
        withSupportingDocs:(NSMutableArray *)SupportingDocs
     withSessionFinancials:(NSMutableDictionary *)SessFinancials
             withExtraData:(NSMutableDictionary *)ExData {
    
    NSMutableDictionary *formdata = [ClientData objectForKey:@"Client Info"];
    
    NSManagedObject *client = [self GetClient:[formdata objectForKey:@"First Name"]
                                 withLastName:[formdata objectForKey:@"Last Name"]
                                     withDate:[formdata objectForKey:@"Date"]];
    
    NSMutableDictionary *clientInfo = [client valueForKey:@"clientInfo"];
    //Compare to _FormData
    bool FormDataSame = [clientInfo isEqualToDictionary:FormData];
    
    if (!FormDataSame) {
        NSLog(@"Form data differs after save");
    }
    
    /*
    NSManagedObject *Images = [client valueForKey:@"images"];
    NSMutableDictionary *clientImages = [Images valueForKey:@"clientImgs"];
    //Compare to _FormImages
    bool FormImagesSame = [clientImages isEqualToDictionary:FormImages];
    
    if (!FormImagesSame) {
        NSLog(@"Form images differs after save");
    }
    */
    
    NSManagedObject *SpecialistInformation = [client valueForKey:@"specialistinformation"];
    NSMutableDictionary *specialistinfo = [SpecialistInformation valueForKey:@"specialistInformation"];
    //Compare to _SpecialistData
    bool SpecialistInfoSame = [specialistinfo isEqualToDictionary:SpecialistData];
    
    if (!SpecialistInfoSame) {
        NSLog(@"Specialist info differs after save");
    }
    
    NSManagedObject *SupportingDocuments = [client valueForKey:@"supportingdocuments"];
    NSMutableDictionary *documents = [SupportingDocuments valueForKey:@"supportingDocs"];
    NSMutableArray *supportingdocs = [documents objectForKey:@"Supporting Documents List"];
    
    bool SupportingDocsSame = [supportingdocs isEqualToArray:SupportingDocs];
    
    if (!SupportingDocsSame) {
        NSLog(@"Supporting docs differs after save");
    }
    
    NSManagedObject *SessionFinancials = [client valueForKey:@"financials"];
    NSMutableDictionary *sessionfinancials = [SessionFinancials valueForKey:@"financialData"];
    //Compare to _SessionFinancials
    bool SessionFinancialsSame = [sessionfinancials isEqualToDictionary:SessFinancials];
    
    if (!SessionFinancialsSame) {
        NSLog(@"Session financials differs after save");
    }
    
    NSManagedObject *ExtraData = [client valueForKey:@"extradata"];
    NSMutableDictionary *extradata = [ExtraData valueForKey:@"extraData"];
    //Compare to _ExtraData
    bool ExtraDataSame = [extradata isEqualToDictionary:ExData];
    
    if (!ExtraDataSame) {
        NSLog(@"Extra data differs after save");
    }
    
    return (FormDataSame &
            SpecialistInfoSame &
            SupportingDocsSame &
            SessionFinancialsSame &
            ExtraDataSame);
    
}

- (NSArray *)FindForms:(NSString *)TextToSearch {
    
    return [self SearchForClient:TextToSearch];
}

- (bool)DoesFormExistWithFirstName:(NSString *)FirstName
                      withLastName:(NSString *)LastName
                          withDate:(NSString *)Date {
    
    bool FormFound = NO;
    
    NSString *formattedDate = [Utilities DateStringToDateString:Date];
    
    NSManagedObject *Form = [self GetClient:FirstName
                               withLastName:LastName
                                   withDate:formattedDate];
    
    FormFound = (Form != nil);
    
    [self InvalidateManagedObject:Form];
    
    return FormFound;
}

- (FormDataManager *)LoadFormFromClientInfo:(NSDictionary *)ClientInfo {

    if (ClientInfo == nil) {
        return nil;
    }
    
    FormDataManager *LoadedClient = [[FormDataManager alloc] init];
    
    NSManagedObject *Form = [self GetClient:[ClientInfo objectForKey:@"First Name"]
                               withLastName:[ClientInfo objectForKey:@"Last Name"]
                                   withDate:[ClientInfo objectForKey:@"Date"]];
    
    NSMutableDictionary *clientInfo = [Form valueForKey:@"clientInfo"];
    [LoadedClient SetFormData:clientInfo];
    
    NSManagedObject *Images = [Form valueForKey:@"images"];
    NSMutableDictionary *clientImages = [Images valueForKey:@"clientImgs"];
    
    NSString *datakey = [Utilities CreateClientKey:clientInfo];
    NSString *datakeyhex = [Utilities StringToHex:datakey];
    
    if (clientImages == nil) {

        clientImages = [[NSMutableDictionary alloc] init];
        
        //Client image
        [clientImages setObject:[self ReadLocalImageData:[NSString stringWithFormat:@"%@-CID", datakeyhex] withPW:datakey]
                         forKey:CLIENT_ID_IMAGE];
        
        //Client signature
        [clientImages setObject:[self ReadLocalImageData:[NSString stringWithFormat:@"%@-CSIG", datakeyhex] withPW:datakey]
                         forKey:CLIENT_SIGNATURE_IMAGE];
        
        //Employee signature
        [clientImages setObject:[self ReadLocalImageData:[NSString stringWithFormat:@"%@-ESIG", datakeyhex] withPW:datakey]
                         forKey:EMPLOYEE_SIGNATURE_IMAGE];
        
    }
    

    [LoadedClient SetFormImages:clientImages];
    clientImages = nil;
    clientInfo = nil;
    
    NSManagedObject *SpecialistInformation = [Form valueForKey:@"specialistinformation"];
    NSMutableDictionary *specialistinfo = [SpecialistInformation valueForKey:@"specialistInformation"];
    [LoadedClient SetSpecialistData:specialistinfo];
    specialistinfo = nil;
    
    NSManagedObject *SupportingDocuments = [Form valueForKey:@"supportingdocuments"];
    NSMutableDictionary *documents = [SupportingDocuments valueForKey:@"supportingDocs"];
    NSMutableArray *sdocslist = [documents objectForKey:@"Supporting Documents List"];
    
    [LoadedClient SetSupportingDocuments:sdocslist];
    
    NSMutableArray *sdocsimages = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [sdocslist count]; i++) {
        
        NSDictionary *sdoc = [sdocslist objectAtIndex:i];
        
        if (sdoc) {
            
            NSString *doctype = [sdoc objectForKey:@"DocumentName"];
            
            if (doctype) {
                
                NSString *doctypehex = [Utilities StringToHex:doctype];
                NSString *fn = [NSString stringWithFormat:@"%@-%@",datakeyhex,doctypehex];
                
                NSData *imgdata = [self ReadLocalImageData:fn withPW:datakey];
                
                if (imgdata != nil) {
                    
                    [sdocsimages addObject:[UIImage imageWithData:imgdata]];
                }
            }
            

        }
        

    }
    
    [LoadedClient SetSupportingDocumentsImages:sdocsimages];
    
    documents = nil;
    
    NSManagedObject *SessionFinancials = [Form valueForKey:@"financials"];
    NSMutableDictionary *sessionfinancials = [SessionFinancials valueForKey:@"financialData"];
    [LoadedClient SetSessionFinancials:sessionfinancials];
    sessionfinancials = nil;
    
    NSManagedObject *ExtraData = [Form valueForKey:@"extradata"];
    NSMutableDictionary *extradata = [ExtraData valueForKey:@"extraData"];
    [LoadedClient SetExtraData:extradata];
    extradata = nil;
    
    [self InvalidateManagedObject:Form];
    
    Form = nil;
    Images = nil;
    SpecialistInformation = nil;
    SupportingDocuments = nil;
    SessionFinancials = nil;
    ExtraData = nil;
    
    /*
    if (formloaddelegate && [formloaddelegate respondsToSelector:@selector(LoadFormComplete)]) {
        
        [formloaddelegate LoadFormComplete];
    }
    */
    
    return LoadedClient;
}

- (NSData *)ReadLocalImageData:(NSString *)filename withPW:(NSString *)PW {
    
    NSString *fn = filename;
    
    NSString *fullpath = [NSString stringWithFormat:@"%@/%@",
                          [Utilities GetImagesPath],
                          fn];
    
    /*
    NSString *fullpath = @"";
    
    if ([Utilities IsUsingUbiquityFolder]) {
        
        NSArray *icloudfiles = [_PersistentStack GetICloudFileListing];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", filename]; // if you need case sensitive search avoid '[c]' in the predicate
        
        NSArray *results = [icloudfiles filteredArrayUsingPredicate:predicate];
        
        if ([results count] > 0) {
            
            fullpath = [results objectAtIndex:0];
            
            NSLog(@"Found image in icloud: %@", fullpath);
        }
        else {
            
            NSLog(@"Could not find image file in icloud");
            
            return nil;
        }
    }
    else {
     
        fullpath = [NSString stringWithFormat:@"%@/%@",
                    [Utilities GetImagesPath],
                    fn];
    }
    */
    
    NSError *error = nil;
    
    if ([Utilities IsUsingDataSync]) {
        
        //Attempt to download the file
        NSURL *icloudfn = [Utilities UbiquityImgsURLForContainer:nil];
        icloudfn = [icloudfn URLByAppendingPathComponent:[fullpath lastPathComponent]];
        
        __block NSData *data = nil;
        NSError *error = nil;
        NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [coordinator coordinateReadingItemAtURL:icloudfn options:0 error:&error byAccessor:^(NSURL *newURL) {
            data = [NSData dataWithContentsOfURL:newURL];
        }];
        
        if (data) {
            
            NSLog(@"File downloaded from icloud: %@", icloudfn);
        }
        
        if (error) {
            NSLog(@"Downloading from icloud error: %@", error.localizedDescription);
            
            NSLog(@"Returning dummy image instead");
            NSData *dummy = [NSData dataWithBytes:(unsigned char[]){0x00} length:100];
            
            return dummy;
        }
        
    }
    
    NSData *encryptedimg = [NSData dataWithContentsOfFile:fullpath
                                                  options:NSDataReadingUncached
                                                    error:&error];
    
    if (error) {
        NSLog(@"ReadLocalImageData error: %@", error.localizedDescription);

    }
    
    if (!_VTDCrypto) {
        _VTDCrypto = [[VTDCrypto alloc] init];
    }
    
    NSData *decryptedimg = [_VTDCrypto Decrypt:encryptedimg withPassword:PW];
    
    if (decryptedimg) {
        
        return decryptedimg;
    }
    else {
        
        NSLog(@"Image not found: %@", filename);
        return [NSData dataWithBytes:(unsigned char[]){0x00} length:100];
    }
    
}

- (NSData *)ReadEncLocalImageData:(NSString *)fullpath {
    
    NSError *error = nil;
    
    if ([Utilities IsUsingDataSync]) {
        
        //Attempt to download the file
        NSURL *icloudfn = [Utilities UbiquityImgsURLForContainer:nil];
        icloudfn = [icloudfn URLByAppendingPathComponent:[fullpath lastPathComponent]];
        
        __block NSData *data = nil;
        NSError *error = nil;
        NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [coordinator coordinateReadingItemAtURL:icloudfn options:0 error:&error byAccessor:^(NSURL *newURL) {
            data = [NSData dataWithContentsOfURL:newURL];
            
        }];
        
        if (data) {
            
            NSLog(@"File downloaded from icloud: %@", icloudfn);
            
            return data;
        }
        
        if (error || data == nil) {
            
            
            if (error) {
                
                NSLog(@"Downloading from icloud error: %@", error.localizedDescription);
            }
            
            
            if (!data) {
                
                NSLog(@"Image data is nil");
            }
            
            NSLog(@"Returning dummy image instead");
            NSData *dummy = [NSData dataWithBytes:(unsigned char[]){0x00} length:100];
            
            return dummy;
        }
        
    }
    
    NSData *encryptedimg = [NSData dataWithContentsOfFile:fullpath
                                                  options:NSDataReadingUncached
                                                    error:&error];
    
    if (error) {
        NSLog(@"ReadLocalImageData error: %@", error.localizedDescription);
        
        return [NSData dataWithBytes:(unsigned char[]){0x00} length:100];
    }
    
    return encryptedimg;
    
}

- (void)ExtractAllImages:(NSString *)DestDir {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Check for Imgs directory, create if missing
        NSFileManager *FileManager = [[NSFileManager alloc] init];
        
        BOOL isDirectory = true;
        NSError *error = nil;
        
        if(![FileManager fileExistsAtPath:DestDir isDirectory:&isDirectory]) {
            
            NSLog(@"Imgs folder not found, creating now");
            
            [FileManager createDirectoryAtPath:DestDir
                   withIntermediateDirectories:NO
                                    attributes:nil
                                         error:&error];
        }
        
        PersistentStack *ExtractPersistentStack = [[PersistentStack alloc] initWithStoreURL:_StoreURL
                                                                                   modelURL:_ModelURL
                                                                       StoreCoordinatorName:@"IMAGE_EXTRACT-STORE" PStackDelegate:self];
        
        NSManagedObjectContext *ExtractMOC = ExtractPersistentStack.managedObjectContext;

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:CLIENTINFO_ENTITY_NAME
                                                  inManagedObjectContext:ExtractMOC];
        [fetchRequest setEntity:entity];

        NSArray *SearchResults = [ExtractMOC executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            
            NSLog(@"Unable to execute fetch request in client image extract.");
            NSLog(@"%@, %@", error, error.localizedDescription);
            
        } else {
            
            if (!_VTDCrypto) {
                _VTDCrypto = [[VTDCrypto alloc] init];
            }
            
            NSLog(@"Entities fetched: %d", [SearchResults count]);
            
            for (int i = 0; i < [SearchResults count]; i++) {
                
                @autoreleasepool {
                    
                    NSManagedObject *CurrentObject = [SearchResults objectAtIndex:i];
                    NSManagedObject *imgsObj = [CurrentObject valueForKey:@"images"];
                    
                    NSMutableDictionary *clientImgs = [imgsObj valueForKey:@"clientImgs"];
                    
                    NSString *datakey = [CurrentObject valueForKey:@"dataKey"];
                    
                    NSString *datakeyhex = [Utilities StringToHex:datakey];
                    
                    //client ID
                    NSData *clientID = [clientImgs objectForKey:CLIENT_ID_IMAGE];
                    
                    if (clientID) {
                        
                        NSString *fn = [NSString stringWithFormat:@"%@-CID",datakeyhex];
                        
                        [self WriteEncryptedFile:DestDir
                                          withFN:fn
                                       withData:clientID
                                          withPW:datakey];
                    }
                    
                    clientID = nil;
                    
                    //client signature
                    NSData *clientSig = [clientImgs objectForKey:CLIENT_SIGNATURE_IMAGE];
                    
                    if (clientSig) {
                        
                        NSString *fn = [NSString stringWithFormat:@"%@-CSIG",datakeyhex];
                        
                        [self WriteEncryptedFile:DestDir
                                          withFN:fn
                                        withData:clientSig
                                          withPW:datakey];
                    }
                    
                    clientSig = nil;
                    
                    //employee signature
                    NSData *employeeSig = [clientImgs objectForKey:EMPLOYEE_SIGNATURE_IMAGE];
                    
                    if (employeeSig) {
                        
                        NSString *fn = [NSString stringWithFormat:@"%@-ESIG",datakeyhex];
                        
                        [self WriteEncryptedFile:DestDir
                                          withFN:fn
                                        withData:employeeSig
                                          withPW:datakey];
                    }
                    
                    employeeSig = nil;
                    
                    [imgsObj setValue:nil forKey:@"clientImgs"];
                    
                    
                    // *** Supporting documents extract *** //
                    
                    NSManagedObject *sdocsObj = [CurrentObject valueForKey:@"supportingdocuments"];
                    
                    NSMutableDictionary *supportingDocs = [[sdocsObj valueForKey:@"supportingDocs"] mutableCopy];
                    [sdocsObj setValue:supportingDocs forKey:@"supportingDocs"];
                    
                    if (supportingDocs != nil) {
                    
                        NSMutableArray *SupportingDocsList = [[supportingDocs objectForKey:@"Supporting Documents List"] mutableCopy];
                        
                        [supportingDocs setObject:SupportingDocsList forKey:@"Supporting Documents List"];


                        if (SupportingDocsList != nil && ([SupportingDocsList count] > 0)) {

                            NSLog(@"Found %d supporting documents for %@, extracting now", [SupportingDocsList count], datakey);
                            
                            for (int j = 0; j < [SupportingDocsList count]; j++) {
                                
                                NSMutableDictionary *sdoc = [[SupportingDocsList objectAtIndex:j] mutableCopy];
                                [SupportingDocsList replaceObjectAtIndex:j withObject:sdoc];
                                
                                NSString *doctype = [sdoc objectForKey:@"DocumentName"];
                                NSString *doctypehex = [Utilities StringToHex:doctype];
                                
                                
                                NSString *fn = [NSString stringWithFormat:@"%@-%@", datakeyhex, doctypehex];
                                
                                UIImage *sdocimg = [sdoc objectForKey:@"DocumentImage"];
                                
                                if (!sdocimg) {
                                    NSLog(@"Trying to store nil supporting document image in CoreDataManager. Creating dummy white image to store in its place");
                                    
                                    //create dummy white image
                                    sdocimg = [Utilities CreateDummyWhiteImg];
                                    
                                }

                                UIImage *test = [UIImage imageWithData:UIImagePNGRepresentation(sdocimg)];
                                
                                [self WriteEncryptedFile:DestDir
                                                  withFN:fn
                                                withData:UIImagePNGRepresentation(sdocimg)
                                                  withPW:datakey];
                                
                                if ([sdoc objectForKey:@"DocumentImage"]) {
                                    
                                    [sdoc removeObjectForKey:@"DocumentImage"];
                                }
                                
                            }//End of for loop saving supporting documents

                            
                        }//End of if going through SupporingDocsList
                        
                    }
                    
                    [ExtractMOC save:nil];
                    
                
                }//End of autoreleasepool

                
            }//End of for loop going through search results
         
            NSLog(@"Image extract complete");
        
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"Yes" forKey:IMAGES_EXTRACTED_KEY];

    });
    
}

- (void)WriteEncryptedFile:(NSString *)DestDir
                    withFN:(NSString *)Filename
                  withData:(NSData *)ImgData
                    withPW:(NSString *)PW {
    
    if (ImgData) {
        
        NSFileManager *FileManager = [[NSFileManager alloc] init];
        
        BOOL isDirectory = NO;
        NSError *error = nil;
        
        //check if image exists in Imgs directory, write to dir if not
        NSString *imgpath = [NSString stringWithFormat:@"%@/%@",DestDir,Filename];
        
        if(![FileManager fileExistsAtPath:imgpath isDirectory:&isDirectory]) {
            
            //Encrypt data
            NSData *encryptedimg = [_VTDCrypto Encrypt:ImgData withPassword:PW];
            
            NSError* error;
            if (![encryptedimg writeToFile:imgpath options:NSDataWritingAtomic error:&error]) {
                NSLog(@"write error %@", error);
            }
            
        }
        else {
            
            NSLog(@"Image alrady exists in %@ dir, skipping", DestDir);
        }
        
    }
    else {
        
        NSLog(@"image nill in WriteEncryptedFile");
    }

    
}

/*
- (void)EnableICloudFileQuery {
    
    [_PersistentStack EnableICloudFileQuery];
}
*/
 
- (void)DisableICloudFileQuery {
 
    [_PersistentStack DisableICloudFileQuery];
}

- (void)StartMergeTimer:(NSUInteger)PeriodInSec {
    
    [_PersistentStack StartMergeTimer:PeriodInSec];
}

- (void)StopMergeTimer {
    
    [_PersistentStack StopMergeTimer];
}

- (NSUInteger)NumClientsInDB {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CLIENTINFO_ENTITY_NAME
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSArray *SearchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    return [SearchResults count];
    
}

- (void)ImageTransferStart:(bool)ToUbiquitous {
    
    [dsyncdelegate ImageTransferStart:ToUbiquitous];
}

- (void)ImageTransferComplete:(bool)ToUbiquitous {

    [dsyncdelegate ImageTransferComplete:ToUbiquitous];
}

- (void)TransferFromUbiquitousProgress:(float)progress {
    
    [dsyncdelegate TransferFromUbiquitousProgress:progress];
}

/*
- (void)ReceivediCloudListToDownload:(NSArray *)iCloudURLList {
    
    [dsyncdelegate ReceivediCloudListToDownload:iCloudURLList];
}
*/

- (void)dealloc {
    
    NSLog(@"Core data manager dealloc");
}

@end

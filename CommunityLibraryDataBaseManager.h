//
//  CommunityLibraryDataBaseManager.h
//  Zero Platform
//
//  Created by Team Zero on 18/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CommunityLibraryDataBaseProtocol.h"

#import "ChatEntity.h"
#import "MessageEntity.h"
#import "UserEntity.h"
#import "FileEntity.h"

@interface CommunityLibraryDataBaseManager : NSObject <CommunityLibraryDataBaseProtocol>

+ (instancetype)sharedInstance;

#pragma mark - General
#pragma mark General Objects Methods

+ (id)newObjectForEntityName:(NSString *)entityName context:(NSManagedObjectContext *)context;
+ (void)deleteObject:(NSManagedObject *)object context:(NSManagedObjectContext *)context;
+ (void)deleteObjectsInEntity: (NSString*) entity inContext: (NSManagedObjectContext*) context;
+ (NSManagedObject *)existingObjectWithObjectID:(NSManagedObjectID *)managedObjectID
                                        context:(NSManagedObjectContext *)context;
+ (NSManagedObject*) getEntityWithPredicate: (NSPredicate*) predicate
                                    context: (NSManagedObjectContext*) context
                                 entityName: (NSString*) entityName;
+ (NSArray*) getAllObjectFromEntityWithEntityName: (NSString*) entityName
                                          context: (NSManagedObjectContext*) context;

#pragma mark General Context Methods

+ (NSManagedObjectContext*) mainContext;
- (NSManagedObjectContext*) mainManagedObjectContext;
+ (NSManagedObjectContext*) newNestedDatabaseContext;

#pragma mark General Context Save Methods

+ (void) saveMainContext;
+ (void) saveContext: (NSManagedObjectContext*) context;
+ (void) saveDatabaseForContext:(NSManagedObjectContext *)context error:(NSError *)error;


@end

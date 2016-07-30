//
//  UserEntity+CoreDataProperties.m
//  Zero Platform
//
//  Created by Team Zero on 22/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserEntity+CoreDataProperties.h"

@implementation UserEntity (CoreDataProperties)

@dynamic firstName;
@dynamic isOnline;
@dynamic lastName;
@dynamic pubNubId;
@dynamic serverId;
@dynamic avatarFile;
@dynamic chats;
@dynamic files;
@dynamic messages;

@end

//
//  MessageEntity+CoreDataProperties.m
//  CommunityLibrary
//
//  Created by Aleksandr Vnukov on 24.07.16.
//  Copyright © 2016 Aleksandr Vnukov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MessageEntity+CoreDataProperties.h"

@implementation MessageEntity (CoreDataProperties)

@dynamic messageId;
@dynamic text;
@dynamic time;
@dynamic type;
@dynamic isRead;
@dynamic chat;
@dynamic chatLastMessage;
@dynamic file;
@dynamic user;

@end

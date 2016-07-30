//
//  ChatEntity+CoreDataProperties.m
//  CommunityLibrary
//
//  Created by Aleksandr Vnukov on 25.07.16.
//  Copyright © 2016 Aleksandr Vnukov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatEntity+CoreDataProperties.h"

@implementation ChatEntity (CoreDataProperties)

@dynamic chatId;
@dynamic lastUpdateTime;
@dynamic name;
@dynamic startHostiryTimestamp;
@dynamic unreadMessagesCount;
@dynamic isMute;
@dynamic chatAvatarFile;
@dynamic files;
@dynamic lastMessage;
@dynamic messages;
@dynamic participants;

@end

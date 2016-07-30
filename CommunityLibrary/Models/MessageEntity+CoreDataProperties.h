//
//  MessageEntity+CoreDataProperties.h
//  CommunityLibrary
//
//  Created by Aleksandr Vnukov on 24.07.16.
//  Copyright © 2016 Aleksandr Vnukov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MessageEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *messageId;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSNumber *isRead;
@property (nullable, nonatomic, retain) ChatEntity *chat;
@property (nullable, nonatomic, retain) ChatEntity *chatLastMessage;
@property (nullable, nonatomic, retain) FileEntity *file;
@property (nullable, nonatomic, retain) UserEntity *user;

@end

NS_ASSUME_NONNULL_END

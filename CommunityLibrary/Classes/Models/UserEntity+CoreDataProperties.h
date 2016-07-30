//
//  UserEntity+CoreDataProperties.h
//  Zero Platform
//
//  Created by Team Zero on 22/7/16.
//  Copyright © 2016 Charter Partners. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSNumber *isOnline;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSNumber *pubNubId;
@property (nullable, nonatomic, retain) NSNumber *serverId;
@property (nullable, nonatomic, retain) FileEntity *avatarFile;
@property (nullable, nonatomic, retain) NSSet<ChatEntity *> *chats;
@property (nullable, nonatomic, retain) NSSet<FileEntity *> *files;
@property (nullable, nonatomic, retain) NSSet<MessageEntity *> *messages;

@end

@interface UserEntity (CoreDataGeneratedAccessors)

- (void)addChatsObject:(ChatEntity *)value;
- (void)removeChatsObject:(ChatEntity *)value;
- (void)addChats:(NSSet<ChatEntity *> *)values;
- (void)removeChats:(NSSet<ChatEntity *> *)values;

- (void)addFilesObject:(FileEntity *)value;
- (void)removeFilesObject:(FileEntity *)value;
- (void)addFiles:(NSSet<FileEntity *> *)values;
- (void)removeFiles:(NSSet<FileEntity *> *)values;

- (void)addMessagesObject:(MessageEntity *)value;
- (void)removeMessagesObject:(MessageEntity *)value;
- (void)addMessages:(NSSet<MessageEntity *> *)values;
- (void)removeMessages:(NSSet<MessageEntity *> *)values;

@end

NS_ASSUME_NONNULL_END

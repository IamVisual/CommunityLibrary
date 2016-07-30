//
//  ChatEntity+CoreDataProperties.h
//  CommunityLibrary
//
//  Created by Aleksandr Vnukov on 25.07.16.
//  Copyright © 2016 Aleksandr Vnukov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *chatId;
@property (nullable, nonatomic, retain) NSDate *lastUpdateTime;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *startHostiryTimestamp;
@property (nullable, nonatomic, retain) NSNumber *unreadMessagesCount;
@property (nullable, nonatomic, retain) NSNumber *isMute;
@property (nullable, nonatomic, retain) FileEntity *chatAvatarFile;
@property (nullable, nonatomic, retain) NSSet<FileEntity *> *files;
@property (nullable, nonatomic, retain) MessageEntity *lastMessage;
@property (nullable, nonatomic, retain) NSSet<MessageEntity *> *messages;
@property (nullable, nonatomic, retain) NSSet<UserEntity *> *participants;

@end

@interface ChatEntity (CoreDataGeneratedAccessors)

- (void)addFilesObject:(FileEntity *)value;
- (void)removeFilesObject:(FileEntity *)value;
- (void)addFiles:(NSSet<FileEntity *> *)values;
- (void)removeFiles:(NSSet<FileEntity *> *)values;

- (void)addMessagesObject:(MessageEntity *)value;
- (void)removeMessagesObject:(MessageEntity *)value;
- (void)addMessages:(NSSet<MessageEntity *> *)values;
- (void)removeMessages:(NSSet<MessageEntity *> *)values;

- (void)addParticipantsObject:(UserEntity *)value;
- (void)removeParticipantsObject:(UserEntity *)value;
- (void)addParticipants:(NSSet<UserEntity *> *)values;
- (void)removeParticipants:(NSSet<UserEntity *> *)values;

@end

NS_ASSUME_NONNULL_END

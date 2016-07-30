//
//  CommunityLibraryDataBaseProtocol.h
//  CommunityLibrary
//
//  Created by Aleksandr Vnukov on 23.07.16.
//  Copyright © 2016 Aleksandr Vnukov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatEntity;
@class MessageEntity;
@class UserEntity;

@protocol CommunityLibraryDataBaseProtocol <NSObject>

+ (void) clearDatabase;

#pragma mark ChatEntity General

+ (ChatEntity*)newChatEntityWithContext: (NSManagedObjectContext*) context;

+ (ChatEntity*) chatEntityWithChatId: (NSString*) chatId
                             context: (NSManagedObjectContext*) context;

- (ChatEntity*) updateChatEntityWithDic: (NSDictionary*) chatDic
                                context: (NSManagedObjectContext*) context;

#pragma mark ChatEntity

- (void) updateChats: (NSArray*) chats
     completionBlock: (void(^)(NSError* error, NSArray* subscribeChatsIds, NSArray* unsubscribeChatsIds)) completionBlock;

- (void) updateChatWithDic: (NSDictionary*) chatDic
           completionBlock: (void(^)(NSError* error, NSString* subscribeChats)) completionBlock;

- (void) updaChatWithChatId: (NSString*) chatId
                  muteState: (BOOL) muteState
            completionBlock: (void(^)(NSError* error, NSString* chatRoom)) completionBlock;

- (NSArray*) getAllChatsInContext: (NSManagedObjectContext*) context;

- (void) deleteChatWithChatId: (NSString*) chatId
              completionBlock: (void(^)(NSError* error, NSString* unsubscribeChats)) completionBlock;

#pragma mark MessageEntity General

+ (MessageEntity *)newMessageEntityWithContext:(NSManagedObjectContext *)context;

+ (MessageEntity*) messageEntityWithMessageId: (NSString*) messageId
                                      context: (NSManagedObjectContext*) context;

- (MessageEntity*) updateMessageEntityWithDic: (NSDictionary*) messageDic
                    chatStartHistoryTimeStamp: (NSNumber*) chatStartHistoryTimeStamp
                                      context: (NSManagedObjectContext*) context;

#pragma mark MessageEntity

- (void)    updateMessages: (NSArray*) messages
 chatStartHistoryTimeStamp: (NSNumber*) chatStartHistoryTimeStamp
           completionBlock: (void(^)(NSError* error)) completionBlock;

- (void) updateMessageWithDic: (NSDictionary*) messageDic
              completionBlock: (void(^)(NSError* error)) completionBlock;

- (NSArray*) getAllMessagesForChatId: (NSString*) chatId
                           predicate: (NSPredicate*) predicate
                           inContext: (NSManagedObjectContext*) context;

+ (void) updateReadStateYesForMessageId: (NSString*) messageId;

+ (NSUInteger) unreadMessagesCountForChatWithId: (NSString*) chatId
                                        context: (NSManagedObjectContext*) context;

#pragma mark UserEntity General

+ (UserEntity *)newUserEntityWithContext:(NSManagedObjectContext *)context;

+ (UserEntity*) userEntityWithUserId: (NSNumber*) userId
                             context: (NSManagedObjectContext*) context;

- (UserEntity*) updateUserEntityWithDic: (NSDictionary*) userDic
                                context: (NSManagedObjectContext*) context;

#pragma mark UserEntity

- (void) updateUsers: (NSArray*) users
     completionBlock: (void(^)(NSError* error)) completionBlock;

- (void) updateUserWithDic: (NSDictionary*) userDic
           completionBlock: (void(^)(NSError* error)) completionBlock;

- (NSArray*) getAllUsersInContext: (NSManagedObjectContext*) context;

@end
